# 10apr20 Software Lab. Alexander Burger

(symbols '(llvm))

(local) (dbfErr dbRdErr dbWrErr)

(de NIL dbfErr (Exe)
   (err Exe 0 ($ "Bad DB file") null) )

(de NIL dbRdErr ()
   (err 0 0 ($ "DB read: %s") (strErrno)) )

(de NIL dbWrErr ()
   (err 0 0 ($ "DB write: %s") (strErrno)) )

(local) (getAdr setAdr)

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
         (or
            (== (xErrno) EINTR)  # Interrupted
            (== @ EACCES)  # Locked by another process
            (== @ EAGAIN)  # Memory-mapped by another process
            (lockErr) )
         (let Pid T
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
      (unless (== Siz (i32 (pread (Db: fd) Buf (i64 Siz) Pos)))
         (dbRdErr) ) ) )

(de i8* rdBlock ((i64 . N))
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
      (unless (== Siz (i32 (pwrite (Db: fd) Buf (i64 Siz) Pos)))
         (dbWrErr) )
      (let Jnl (val $DbJnl)
         (unless (=0 Jnl)
            (putc_unlocked (if (== Siz (Db: siz)) BLKSIZE Siz) Jnl)
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

(local) (newBlock newId isLife cleanUp getBlock putBlock)

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
         (cond
            ((> (val $DBs) (objFile Nm))
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
               (ret YES) ) ) )
      NO ) )

# (ext? 'any) -> sym | NIL
(de _extQ (Exe)
   (let X (eval (cadr Exe))
      (if (or (num? X) (not (sym? X)))
         $Nil
         (if (and (sym? (val (tail X))) (isLife X))
            X
            $Nil ) ) ) )

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

(de i32 getBlock ()
   (let P (val $BlkPtr)
      (when (== P (val $BlkEnd))
         (and (=0 (val $BlkLink)) (ret 0))
         (setq P (rdBlock @)) )
      (set $BlkPtr (inc P))
      (i32 (val P)) ) )

(de void putBlock ((i8 . B))
   (let P (val $BlkPtr)
      (when (== P (val $BlkEnd))
         (let Link (val $BlkLink)
            (if (=0 Link)
               (let (New (newBlock)  Cnt (i64 (val P)))  # Block count (link is zero)
                  (setAdr (| New Cnt) (val $DbBlock))
                  (wrBlock)  # Write new block
                  (set $BlkIndex New)  # Set new block index
                  (setAdr
                     (if (== Cnt BLKTAG) Cnt (inc Cnt))
                     (setq P (val $DbBlock)) )
                  (setq P (ofs P BLK)) )
               (wrBlock)  # Write current block
               (setq P (rdBlock Link)) ) ) )  # Read next block
      (set P B)
      (set $BlkPtr (inc P)) ) )

# (rollback) -> flg
(de _rollback (Exe)
   (if (and (=0 (val $DBs)) (atom (val $Ext)))
      $Nil
   (let (Tos 0  P (val $Extern))  # Iterate external symbol tree
      (loop
         (loop
            (let X (cdr P)  # Get subtrees
               (? (atom (cdr X)))  # Right subtree
               (let Y P  # Go right
                  (setq P @)  # Invert tree
                  (set 2 X Tos)
                  (setq Tos Y) ) ) )
         (loop
            (let (S (val P)  Tail (val (tail S)))  # Get external symbol
               (unless (num? Tail)  # Any properties
                  (setq Tail (& Tail -9))  # Clear 'extern' tag
                  (loop
                     (? (num? (shift Tail))) )  # Find name
                  (setq Tail (| Tail 8)) )  # Set 'extern' tag
               (set (tail S) (shr (shl Tail 2) 2))  # Strip status bits
               (set S $Nil) )  # Clear value
            (let X (cdr P)
               (? (pair (car X))  # Left subtree
                  (let Y P  # Go left
                     (setq P @)  # Invert tree
                     (set X Tos)
                     (setq Tos (| Y 8)) ) ) )  # First visit
            (loop
               (and (=0 Tos) (goto 1))
               (? (=0 (& Tos 8))  # Second visit
                  (let (X Tos  Y (cdr X))  # Nodes
                     (setq Tos (cdr Y))  # TOS on up link
                     (set 2 Y P)
                     (setq P X) ) )
               (setq Tos (& Tos -9))  # Clear visit bit
               (let (X Tos  Y (cdr X))  # Nodes
                  (setq Tos (car Y))
                  (set Y P)
                  (setq P X) ) ) ) ) )
   (: 1
      (when (pair (val $Zap))  # Objects to delete
         (set @ $Nil) ) )  # Clear zap list
   (unless (=0 (val $DBs))  # DB open
      (unLockDb 0) )  # Unlock all
   #! (unsync)
   $T ) )

# (extern 'sym) -> sym | NIL
(de _extern (Exe)
   (let
      (Sym (needSym Exe (eval (cadr Exe)))
         Nm (name (val (tail Sym))) )
      (when (== Nm ZERO)
         (ret $Nil) )
      (let
         (P (push 0 Nm)  # [cnt name]
            C (symChar P)
            F (i32 0) )
         (when (== C (char "{"))
            (setq C (symChar P)) )
         (while (>= C (char "@"))
            (when (> C (char "O"))  # A-O range
               (ret $Nil) )
            (setq
               F (| (shl F 4) (- C (char "@")))
               C (symChar P) ) )
         (let N 0
            (loop
               (unless (and (>= C (char "0")) (>= (char "7") C))
                  (ret $Nil) )
               (setq N
                  (|
                     (shl N 3)
                     (i64 (- C (char "0"))) ) )
               (?
                  (or
                     (=0 (setq C (symChar P)))
                     (== C (char "}")) ) ) )
            (if (isLife (setq Sym (extern (extNm F N))))
               Sym
               $Nil ) ) ) ) )

# (pool ['sym1 ['lst] ['sym2] ['sym3]]) -> T
(de _pool (Exe)
   (let
      (X (cdr Exe)
         Sym1 (save (evSym X))
         Lst (save (evLst (shift X)))
         Sym2 (save (evSym (shift X)))
         Sym3 (save (evSym (shift X))) )
      (set $Solo ZERO)  # Reset solo mode
      (unless (=0 (val $DBs))
         (_rollback ZERO)
         )
      (let N (i64 (val $MaxBlkSize))
         (set $DbBlock (alloc (val $DbBlock) N))
         (memset (set $IniBlk (alloc (val $IniBlk) N)) 0 N) )
      )
   $T )


(local) (dbFetch dbTouch dbZap)

(de dbFetch (Exe Sym)
   Sym )

(de dbTouch (Exe Sym)
   Sym )

# (touch 'sym) -> sym
(de _touch (Exe)
   (let X (eval (cadr Exe))
      (and
         (not (num? X))
         (sym? X)
         (sym? (val (tail X)))
         (dbTouch Exe X) )
      X ) )

(de dbZap (Sym)
   Sym )
