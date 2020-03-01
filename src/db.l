# 01mar20 Software Lab. Alexander Burger

(symbols '(llvm))

(local) (dbfErr dbRdErr dbWrErr)

(de NIL dbfErr (Exe)
   (err Exe 0 ($ "Bad DB file") null) )

(de NIL dbRdErr ()
   (err 0 0 ($ "DB read: %s") (strErrno)) )

(de NIL dbWrErr ()
   (err 0 0 ($ "DB write: %s") (strErrno)) )

# Intern an external symbol
(local) extern

(de extern (Name)
   (let (X (val $Extern)  C 0  Sym NIL)
      (loop
         (inc 'C)  # Next level
         (setq Sym (car X))  # Next symbol
         (let Nm (& (name (val (tail Sym))) (hex "3FFFFFFFFFFFFFF7"))  # Mask status and extern bits
            (? (== Nm Name))  # Found
            (if (> Name Nm)  # Symbol is smaller
               (let Y (cdr X)  # Get link cell
                  (? (atom Y)  # No link yet
                     (set 2 X
                        (cons $Nil (cons (setq Sym (consExt Name)) $Nil)) ) )
                  (? (atom (setq Y (cdr (setq X Y))))
                     (set 2 X
                        (cons (setq Sym (consExt Name)) $Nil) ) )
                  (setq X Y) )
               (let Y (cdr X)  # Get link cell
                  (? (atom Y)  # No link yet
                     (set 2 X
                        (cons (cons (setq Sym (consExt Name)) $Nil) $Nil) ) )
                  (? (atom (setq Y (cdr (setq X Y))))
                     (set X
                        (cons (setq Sym (consExt Name)) $Nil) ) )
                  (setq X Y) ) ) ) )
      (setq C (shr C 1))  # Half depth
      (when (> (shl 1 C) (val $ExtCnt))  # 2 ** (C/2)
         (setq X (val $Extern))
         (let N (val $ExtSkip)  # Levels to skip
            (if (> (inc 'N) C)  # Beyond half depth
               (set $ExtSkip 0)  # Don't skip
               (set $ExtSkip N)
               (loop  # Skip
                  (setq X
                     (if
                        (>
                           Name
                           (&
                              (name (val (tail (++ X))))
                              (hex "3FFFFFFFFFFFFFF7") ) )
                        (cdr X)
                        (car X) ) )
                  (? (=0 (dec 'C))) ) ) )
         (loop  # Pivot
            (let
               (Nm
                  (&
                     (name (val (tail (car X))))
                     (hex "3FFFFFFFFFFFFFF7") )
                  Y (cdr X) )
            (? (== Nm Name))  # Done
            (if (> Name Nm)  # Symbol is smaller
               (let Z (cdr Y)  # Get right node
                  (? (atom (cdr Z)))
                  (xchg Z X)  # Pivot left
                  (setq Z (cdr Z)  X (cdr Z))
                  (set  # Rotate pointers
                     2 Z (val Z)
                     Z (val Y)
                     Y (cdr Y)
                     2 Y X) )
               (let Z (car Y)  # Get left node
                  (? (atom (cdr Z)))
                  (xchg Z X)  # Pivot right
                  (setq Z (cdr Z)  X (val Z))
                  (set  # Rotate pointers
                     Z (cdr Z)
                     2 Z (cdr Y)
                     2 Y (val Y)
                     Y X) ) ) ) ) )
      Sym ) )

(local) (getAdr setAdr extNm objFile objId packAO packOct packExtNm chopExtNm)

# 6 bytes in little endian format
# Get block address from buffer
(de i64 getAdr ((i8* . P))
   (|
      (shl
         (|
            (shl
               (|
                  (shl
                     (|
                        (shl
                           (|
                              (shl (i64 (val 6 P)) 8)
                              (i64 (val 5 P)) )
                           8 )
                        (i64 (val 4 P)) )
                     8 )
                  (i64 (val 3 P)) )
               8 )
            (i64 (val 2 P)) )
         8 )
      (i64 (val P)) ) )

# Set block address in buffer
(de void setAdr ((i64 . N) (i8* . P))
   (set P (i8 N))
   (set 2 P (i8 (setq N (shr N 8))))
   (set 3 P (i8 (setq N (shr N 8))))
   (set 4 P (i8 (setq N (shr N 8))))
   (set 5 P (i8 (setq N (shr N 8))))
   (set 6 P (i8 (shr N 8))) )

# Build external symbol name
(de extNm ((i32 . File) (i64 . Obj))
   (cnt
      (|
         (& Obj (hex "FFFFF"))  # Lowest 20 bits
         (|
            (shl (i64 (& File (hex "FF"))) 20)  # Lower 8 bits
            (|
               (shl
                  (& (setq Obj (shr Obj 20)) (hex "FFF"))  # Middle 12 bits
                  28 )
               (|
                  (shl (i64 (shr File 8)) 40)  # Upper 8 bits
                  (shl (shr Obj 12) 48) ) ) ) ) ) )  # Highest 10 bits

# Get file number from external symbol name
(de i32 objFile (Name)
   (|
      (& (i32 (setq Name (shr Name 24))) (hex "FF"))  # Low 8 bits
      (& (i32 (shr Name 12)) (hex "FF00")) ) )  # High 8 bits

# Get object ID from external symbol name
(de i64 objId (Name)
   (|
      (|
         (& (setq Name (shr Name 4)) (hex "FFFFF"))  # Lowest 20 bits
         (& (setq Name (shr Name 8)) (hex "FFF00000")) )  # Middle 12 bits
      (& (shr Name 8) (hex "3FF00000000")) ) )  # Highest 10 bits

# Pack external symbol name
(de void packAO ((i32 . File) (i64* . P))
   (when (> File 15)
      (packAO (shr File 4) P) )  # Divide by 16
   (byteNum (+ (& (i8 File) 15) (char "@")) P) )  # Make ASCII letter

(de void packOct ((i64 . Obj) (i64* . P))
   (when (> Obj 7)
      (packOct (shr Obj 3) P) )  # Divide by 8
   (byteNum (+ (& (i8 Obj) 7) (char "0")) P) )  # Make ASCII digit

(de packExtNm (Name)
   (let (P (push 4 ZERO NIL)  Q (link (ofs P 1)))  # [cnt name link]
      (let File (objFile Name)
         (unless (=0 File)
            (packAO File P) ) )
      (packOct (objId Name) P)
      (prog1
         (consSym (val Q) 0)
         (drop Q) ) ) )

# Chop external symbol name
(de chopExtNm (Name)
   (let (R (link (push $Nil NIL))  N (objId Name))
      (loop
         (let A (+ (& N 7) (char "0"))  # Make ASCII digit
            (unless (=0 (setq N (shr N 3)))
               (setq A
                  (|
                     (shl A 8)
                     (+ (& N 7) (char "0")) ) )  # Second octal digit
               (unless (=0 (setq N (shr N 3)))
                  (setq A
                     (|
                        (shl A 8)
                        (+ (& N 7) (char "0")) ) ) ) )  # Third octal digit
            (set R
               (cons (consSym (cnt A) 0) (val R)) ) )
         (? (=0 (setq N (shr N 3)))) )
      (unless (=0 (setq N (objFile Name)))
         (let F (i32 0)
            (loop
               (setq F
                  (| F (+ (& N 15) (char "@"))) )  # Make ASCII letter
               (? (=0 (setq N (shr N 4))))
               (setq F (shl F 8)) )
            (set R
               (cons (consSym (cnt (i64 F)) 0) (val R)) ) ) )
      (pop R) ) )

# Locking
(local) (rdLockDb wrLockDb unLockDb tryLock lockJnl unLockJnl)

(de void rdLockDb ()
   (unless (== $T (val $Solo))  # Not already locked whole DB
      (while (lt0 (rdLock ((dbFile (val $DbFiles)) fd) 0 1))  # Descriptor of first file
         (unless (== (xErrno) EINTR)
            (lockErr) ) ) ) )

(de void wrLockDb ()
   (unless (== $T (val $Solo))  # Not already locked whole DB
      (while (lt0 (wrLock ((dbFile (val $DbFiles)) fd) 0 1 YES))  # Descriptor of first file
         (unless (== (xErrno) EINTR)
            (lockErr) ) ) ) )

(de void unLockDb ((i64 . Len))
   (unless (== $T (val $Solo))  # Not already locked whole DB
      (when (=0 Len)
         (let (P (val $DbFiles)  C (val $DBs))
            (until (=0 (dec 'C))
               (let Db: (dbFile (setq P (ofs P (dbFile T))))  # Skip first, increment by size of dbFile
                  (when (Db: lck)
                     (unLock (Db: fd) 0 0)
                     (Db: lck NO) ) ) ) )
         (set $Solo ZERO) )
      (unLock ((dbFile (val $DbFiles)) fd) 0 Len) ) )  # Descriptor of first file

(de i32 tryLock ((i64 . N) (i64 . Len))
   (let Db: (dbFile (val $DbFile))
      (loop
         (when (ge0 (wrLock (Db: fd) N Len NO))  # Try to lock
            (Db: lck YES)  # Set lock flag
            (cond
               ((=0 N) (set $Solo $T))  # Set solo mode
               ((== $T (val $Solo)) (set $Solo $Nil)) )  # Clear solo mode
            (ret 0) )
         (let E (xErrno)
            (or
               (== E EINTR)  # Interrupted
               (== E EACCES)  # Locked by another process
               (== E EAGAIN)  # Memory-mapped by another process
               (lockErr) ) )
         (let Pid NIL
            (while (lt0 (setq Pid (getLock (Db: fd) N Len)))
               (unless (== (xErrno) EINTR)
                  (lockErr) ) )
            (when (gt0 Pid)
               (ret Pid) ) ) ) ) )

(de void lockJnl ()
   (while (lt0 (wrLock (fileno (val $DbJnl)) 0 0 YES))
      (unless (== (xErrno) EINTR)
         (lockErr) ) ) )

(de void unLockJnl ()
   (let Jnl (val $DbJnl)
      (fflush Jnl)
      (unLock (fileno Jnl) 0 0) ) )

(local) (blkPeek rdBlock blkPoke wrBlock logBlock)

(de void blkPeek ((i64 . Pos) (i8* . Buf) (i32 . Siz))
   (let Db: (dbFile (val $DbFile))
      (unless (== (pread (Db: fd) Buf Siz Pos) Siz)
         (dbRdErr) ) ) )

(de void rdBlock ((i64 . N))
   (let (Db: (dbFile (val $DbFile))  Blk (val $DbBlock))
      (blkPeek
         (shl (set $BlkIndex N) (i64 (Db: sh)))
         Blk
         (Db: siz) )
      (set
         $BlkLink (& (getAdr Blk) BLKMASK)
         $BlkPtr (ofs Blk BLK) ) ) )

(de void blkPoke ((i64 . Pos) (i8* . Buf) (i32 . Siz))
   (let Db: (dbFile (val $DbFile))
      (unless (== (pwrite (Db: fd) Buf Siz Pos) Siz)
         (dbWrErr) )
      (let Jnl (val $DbJnl)
         (unless (=0 Jnl)
            (putc_unlocked (if (== Siz (Db: siz)) 0 Siz) Jnl)
            (let P (b8 (+ BLK 2))  # Allocate buffer
               (set P (i8 (Db: db)))  # Store file number
               (set 2 P (i8 (shr (Db: db) 8)))
               (setAdr
                  (shr Pos (i64 (Db: sh)))  # Un-shift position
                  (ofs P 2) )
               (unless
                  (and
                     (== 1 (fwrite P (+ BLK 2) 1 Jnl))  # Write file number and address
                     (== 1 (fwrite Buf Siz 1 Jnl)) )  # Write 'Buf'
                  (err 0 0 ($ "Journal write: %s") (strErrno)) ) ) ) ) ) )

(de void wrBlock ()
   (let Db: (dbFile (val $DbFile))
      (blkPoke
         (shl (val $BlkIndex) (i64 (Db: sh)))
         (val $DbBlock)
         (Db: siz) ) ) )

(de void logBlock ()
   (let
      (Db: (dbFile (val $DbFile))
         Log (val $DbLog)
         P (b8 (+ BLK 2)) )
      (set P (i8 (Db: db)))  # Store file number
      (set 2 P (i8 (shr (Db: db) 8)))
      (setAdr (val $BlkIndex) (ofs P 2))  # and block
      (unless
         (and
            (== 1 (fwrite P (+ BLK 2) 1 Log))  # Write file number and address
            (== 1 (fwrite (val $DbBlock) (Db: siz) 1 Log)) )  # Write block
         (err 0 0 ($ "Log write: %s") (strErrno)) ) ) )

(local) (newBlock newId isLife cleanUp)

(de i64 newBlock ()
   (let (Db: (dbFile (val $DbFile))  P (b8 (* BLK 2)))
      (blkPeek 0 P (* 2 BLK))  # Read 'free' and 'next' from block zero
      (let N (getAdr P)
         (cond
            ((and (n0 N) (n0 (Db: flu)))
               (blkPeek (shl N (i64 (Db: sh))) P BLK)  # Get free link
               (Db: flu (dec (Db: flu))) )
            ((== (setq N (getAdr (ofs P BLK))) (hex "FFFFFFFFFFC0"))  # Max object ID
               (err 0 0 ($ "DB Oversize") null) )
            (T (setAdr (+ N BLKSIZE) (ofs P BLK))) )  # Increment next
         (blkPoke 0 P (* 2 BLK))  # Write back
         (blkPoke (shl N (i64 (Db: sh))) (val $IniBlk) (Db: siz))
         N ) ) )

(de newId (Exe (i32 . N))
   (when (>= (dec 'N) (val $DBs))
      (dbfErr Exe) )
   (set $DbFile  # Set current file
      (ofs (val $DbFiles) (* N (dbFile T))) )
   (when (=0 (val $DbLog))
      (set $Protect (inc (val $Protect))) )
   (wrLockDb)
   (unless (=0 (val $DbJnl))
      (lockJnl) )
   (prog1
      (extNm ((dbFile (val $DbFile)) db) (newBlock))
      (unless (=0 (val $DbJnl))
         (unLockJnl) )
      (unLockDb 1)
      (when (=0 (val $DbLog))
         (set $Protect (dec (val $Protect))) ) ) )

(de i1 isLife (Sym)
   (let (Nm (name (val (tail Sym)))  N (objId Nm))
      (unless (=0 N)
         (let F (objFile Nm)
            (cond
               ((> (val $DBs) F)
                  (setq Nm (add Nm Nm))
                  (and @@ (ret YES))  # Dirty
                  (add Nm Nm)
                  (and @@ (ret YES))  # Loaded
                  (let
                     (Db:
                        (dbFile
                           (set $DbFile  # Set current file
                              (ofs (val $DbFiles) (* N (dbFile T))) ) )
                        P (b8 (* BLK 2)) )
                     (blkPeek BLK P BLK)  # Read 'next'
                     (when (> (getAdr P) N)
                        (blkPeek (shl N (i64 (Db: sh))) P BLK)  # Read link field
                        (when (== 1 (& (val P) BLKTAG))  # ID-Block
                           (ret YES) ) ) ) )
               ((pair (val $Ext))
                  (ret YES) ) ) ) )
      NO ) )

(de void cleanUp ((i64 . N))
   (let (P (b8 BLK)  Db: (dbFile (val $DbFile)))
      (blkPeek 0 P BLK)  # Read 'free'
      (let Free (getAdr P)
         (setAdr N P)
         (blkPoke 0 P BLK)  # Set new 'free'
         (loop
            (let Pos (shl N (i64 (Db: sh)))
               (blkPeek Pos P BLK)  # Get block link
               (set P (& (val P) BLKMASK))  # Clear tag
               (? (=0 (setq N (getAdr P))))  # No more links
               (blkPoke Pos P BLK) ) )
         (setAdr Free P)  # Append old 'free' list
         (blkPoke Pos P BLK) ) ) )


# (pool ['sym1 ['lst] ['sym2] ['sym3]]) -> T
(de _pool (Exe)
   #! ...
   (let N (i64 (val $MaxBlkSize))
      (set $DbBlock (alloc (val $DbBlock) N))
      (memset (set $IniBlk (alloc (val $IniBlk) N)) 0 N) )
   #! ...
   $T )


(local) (dbTouch)

(de dbTouch (Sym)
   Sym )
