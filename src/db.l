# 07aug20 Software Lab. Alexander Burger

(symbols '(llvm))

(local) (dbfErr dbRdErr dbWrErr jnlErr dbSyncErr)

(de NIL dbfErr (Exe)
   (err Exe 0 ($ "Bad DB file") null) )

(de NIL dbRdErr ()
   (err 0 0 ($ "DB read: %s") (strErrno)) )

(de NIL dbWrErr ()
   (err 0 0 ($ "DB write: %s") (strErrno)) )

(de NIL jnlErr (Exe)
   (err Exe 0 ($ "Bad Journal") null) )

(de NIL dbSyncErr (Exe)
   (err Exe 0 ($ "DB fsync error: %s") (strErrno)) )

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

# Read file number from buffer into '$DbFile'
(de i1 dbfBuf ((i8* . P))
   (let N
      (|  # Two bytes little endian
         (shl (i32 (val 2 P)) 8)
         (i32 (val P)) )
      (and
         (> (val $DBs) N)
         (prog
            (set $DbFile  # Set current file
               (ofs (val $DbFiles) (* N (dbFile T))) )
            YES ) ) ) )

# Locking
(local) (rdLockDb wrLockDb unLockDb tryLock lockJnl unLockJnl)

(de void rdLockDb ()
   (unless (== $T (val $Solo))  # Not already locked whole DB
      (while
         (lt0
            (rdLock ((dbFile (val $DbFiles)) fd) 0 1 YES) )  # Descriptor of first file
         (unless (== (gErrno) EINTR)
            (lockErr) ) ) ) )

(de void wrLockDb ()
   (unless (== $T (val $Solo))  # Not already locked whole DB
      (while (lt0 (wrLock ((dbFile (val $DbFiles)) fd) 0 1 YES))  # Descriptor of first file
         (unless (== (gErrno) EINTR)
            (lockErr) ) ) ) )

(de void unLockDb ((i64 . Len))
   (unless (== $T (val $Solo))  # Not already locked whole DB
      (unless Len
         (let (P (val $DbFiles)  C (val $DBs))
            (while (dec 'C)
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
         (unless
            (or
               (== (gErrno) EINTR)  # Interrupted
               (== @ EACCES)  # Locked by another process
               (== @ EAGAIN) )  # Memory-mapped by another process
            (lockErr) )
         (let Pid T
            (while (lt0 (setq Pid (getLock (Db: fd) N Len)))
               (unless (== (gErrno) EINTR)
                  (lockErr) ) )
            (when (gt0 Pid)
               (ret Pid) ) ) ) ) )

(de void lockJnl ()
   (while (lt0 (wrLock (fileno (val $DbJnl)) 0 0 YES))
      (unless (== (gErrno) EINTR)
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
         $Ptr (ofs Blk BLK) ) ) )

(de void blkPoke ((i64 . Pos) (i8* . Buf) (i32 . Siz))
   (let Db: (dbFile (val $DbFile))
      (unless (== Siz (i32 (pwrite (Db: fd) Buf (i64 Siz) Pos)))
         (dbWrErr) )
      (let Jnl (val $DbJnl)
         (when Jnl
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
   (let
      (Db: (dbFile (val $DbFile))
         Siz (Db: siz)
         P (b8 (i64 Siz)) )
      (blkPeek 0 P (* 2 BLK))  # Read 'free' and 'next' from block zero
      (let N (getAdr P)
         (cond
            ((and N (Db: flu))
               (blkPeek (shl N (i64 (Db: sh))) P BLK)  # Get free link
               (Db: flu (dec (Db: flu))) )
            ((== (setq N (getAdr (ofs P BLK))) (hex "FFFFFFFFFFC0"))  # Max object ID
               (err 0 0 ($ "DB Oversize") null) )
            (T (setAdr (+ N BLKSIZE) (ofs P BLK))) )  # Increment next
         (blkPoke 0 P (* 2 BLK))  # Write back
         (memset P 0 (i64 Siz))  # Init new block
         (blkPoke (shl N (i64 (Db: sh))) P Siz)
         N ) ) )

(de newId (Exe (i32 . N))
   (when (>= (dec 'N) (val $DBs))
      (dbfErr Exe) )
   (set $DbFile  # Set current file
      (ofs (val $DbFiles) (* N (dbFile T))) )
   (unless (val $DbLog)
      (set $Protect (inc (val $Protect))) )
   (wrLockDb)
   (when (val $DbJnl)
      (lockJnl) )
   (prog1
      (extNm ((dbFile (val $DbFile)) db) (newBlock))
      (when (val $DbJnl)
         (unLockJnl) )
      (unLockDb 1)
      (unless (val $DbLog)
         (set $Protect (dec (val $Protect))) ) ) )

(de i1 isLife (Sym)
   (let
      (Nm (name (& (val (tail Sym)) -9))
         N (objId Nm) )
      (when N
         (cond
            ((> (val $DBs) (objFile Nm))
               (setq Nm (add Nm Nm))
               (when @@  # Dirty
                  (ret YES) )
               (add Nm Nm)
               (when @@  # Loaded
                  (ret YES) )
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
      (if
         (and
            (symb? X)
            (sym? (val (tail X)))
            (isLife X) )
         X
         $Nil ) ) )

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
               (? (=0 (setq N (getAdr P)))  # No more links
                  (setAdr Free P)  # Append old 'free' list
                  (blkPoke Pos P BLK) )
               (blkPoke Pos P BLK) ) ) ) ) )

(de i32 getBlock ()
   (let P (val $Ptr)
      (when (== P (val $End))
         (unless (val $BlkLink)
            (ret 0) )
         (setq P (rdBlock @)) )
      (set $Ptr (inc P))
      (i32 (val P)) ) )

(de void putBlock ((i8 . B))
   (let P (val $Ptr)
      (when (== P (val $End))
         (let Link (val $BlkLink)
            (ifn Link
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
      (set $Ptr (inc P)) ) )

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
                  (unless Tos
                     (goto 1) )
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
      (when (val $DBs)  # DB open
         (unLockDb 0) )  # Unlock all
      (unsync)
      $T ) )

# (extern 'sym) -> sym | NIL
(de _extern (Exe)
   (let
      (Sym (needSymb Exe (eval (cadr Exe)))
         Nm (name (& (val (tail Sym)) -9)) )
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

(local) (ignLog transaction fsyncDB restore truncLog)

(de void ignLog ()
   (stderrMsg ($ "Discarding incomplete transaction\n") null) )

# Test for existing transaction
(de i1 transaction ()
   (let (Log (val $DbLog)  A (b8 BLK))
      (fseek0 Log)
      (if (fread A 2 1 Log)  # Read first file number
         (loop
            (? (== (val (i16* A)) (hex "FFFF")) YES)  # Byte order doesn't matter
            (?
               (or
                  (not (dbfBuf A))
                  (<> (fread A BLK 1 Log) 1)
                  (not (fseekOfs Log ((dbFile (val $DbFile)) siz)))
                  (<> (fread A 2 1 Log) 1) )
               (ignLog)
               NO ) )
         (unless (feof Log)
            (ignLog) )  # Discard incomplete transaction
         NO ) ) )

(de void fsyncDB (Exe)
   (let (P (val $DbFiles)  C (val $DBs))
      (loop
         (let Db: (dbFile P)
            (when (and (Db: drt) (lt0 (fsync (Db: fd))))
               (dbSyncErr Exe) ) )
         (? (=0 (dec 'C)))
         (setq P (ofs P (dbFile T))) ) ) )

(de void restore (Exe)
   (stderrMsg ($ "Last transaction not completed: Rollback\n") null)
   (let Log (val $DbLog)
      (fseek0 Log)
      (let (P (val $DbFiles)  C (val $DBs))
         (loop
            ((dbFile P) drt NO)
            (? (=0 (dec 'C)))
            (setq P (ofs P (dbFile T))) ) )
      (let (A (b8 BLK)  Buf (b8 (i64 (val $MaxBlkSize))))
         (loop
            (unless (== (fread A 2 1 Log) 1)  # Get file number
               (jnlErr Exe) )
            (? (== (val (i16* A)) (hex "FFFF")))  # Byte order doesn't matter
            (unless (dbfBuf A)
               (jnlErr Exe) )
            (let Db: (dbFile (val $DbFile))
               (unless
                  (and
                     (== (fread A BLK 1 Log) 1)
                     (== (fread Buf (Db: siz) 1 Log) 1) )
                  (jnlErr Exe) )
               (unless
                  (==
                     (pwrite
                        (Db: fd)
                        Buf
                        (i64 (Db: siz))
                        (shl (getAdr A) (i64 (Db: sh))) )
                     (i64 (Db: siz)) )
                  (dbWrErr) )
               (Db: drt YES) ) )
         (fsyncDB Exe) ) ) )

(de void truncLog (Exe)
   (let Log (val $DbLog)
      (unless (and (fseek0 Log) (truncate0 (fileno Log)))
         (err Exe 0 ($ "Log truncate error: %s") (strErrno)) ) ) )

# (pool ['sym1 ['lst] ['sym2] ['sym3]]) -> T
(de _pool (Exe)
   (let
      (X (cdr Exe)
         Sym1 (save (evSym X))  # Database name
         Dbs (save (evLst (shift X)))  # Database sizes
         Sym2 (save (evSym (shift X)))  # Replication journal
         Sym3 (save (evSym (shift X))) )  # Transaction log
      (set $Solo ZERO)  # Reset solo mode
      (when (val $DBs)
         (_rollback ZERO)
         (let (P (val $DbFiles)  C @)
            (loop
               (let Db: (dbFile P)
                  (close (Db: fd))
                  (free (Db: mark)) )
               (? (=0 (dec 'C)))
               (setq P (ofs P (dbFile T))) ) )
         (set $DBs 0)
         (when (val $DbJnl)
            (fclose @)
            (set $DbJnl null) )
         (when (val $DbLog)
            (fclose @)
            (set $DbLog null) ) )
      (unless (nil? Sym1)
         (let
            (Nm (xName Exe Sym1)  # DB name
               Len (pathSize Nm)
               Buf (pathString Nm (b8 (+ Len 4)))  # 4 bytes for AO file number
               End (ofs Buf Len)
               Siz (dbFile T) )  # Default to single dbFile
            (when (pair Dbs)
               (let L Dbs
                  (while (pair (shift L))
                     (inc 'Siz (dbFile T)) ) ) )
            (let
               (Db: (dbFile (set $DbFiles (alloc (val $DbFiles) Siz)))
                  P (b8 (+ BLK BLK 1))
                  Fnr (i32 0)
                  Max (i32 0) )
               (loop
                  (Db: db Fnr)
                  (if (atom Dbs)
                     (Db: sh 2)
                     (set (bufAo End Fnr) 0)
                     (Db: sh (i32 (++ Dbs))) )
                  (set $DbFile (Db:))  # Set current file
                  (cond
                     ((ge0 (Db: fd (openRdWr Buf)))  # Exists
                        (blkPeek 0 P (+ BLK BLK 1))  # Read block shift from block zero
                        (Db: siz
                           (shl
                              (i32 BLKSIZE)
                              (Db: sh (i32 (val (+ BLK BLK) P))) ) ) )  # Override block shift from 'Dbs'
                     ((and
                           (== (gErrno) ENOENT)
                           (ge0 (Db: fd (openRdWrExcl Buf))) )
                        (let
                           (N (shl (i32 BLKSIZE) (Db: sh))
                              Stk (stack)
                              Blk (b8 (i64 (Db: siz N))) )
                           (memset Blk 0 (i64 N))  # 'free' is null
                           (setAdr
                              (if (== (Db:) (val $DbFiles))  # First file
                                 (* 2 BLKSIZE)  # Block zero plus DB root
                                 BLKSIZE )
                              (ofs Blk BLK) )  # Address of 'next' in buffer
                           (set  # Set block shift in block zero
                              (inc (* 2 BLK)) Blk
                              (i8 (Db: sh)) )
                           (blkPoke 0 Blk N)  # Write DB block zero
                           (when (== (Db:) (val $DbFiles))  # First file
                              (memset Blk 0 16)  # Clear 'next' link in buffer
                              (setAdr 1 Blk)  # First block for DB root into link field
                              (blkPoke (i64 (Db: siz)) Blk N) )  # has block size position
                           (stack Stk) )
                        (closeOnExec Exe (Db: fd))
                        (when (> (Db: siz) Max)
                           (setq Max @) )
                        (Db: mark null)
                        (Db: mrks 0)
                        (Db: flu 0)
                        (Db: lck (Db: drt NO)) )
                     (T (openErr Exe Sym1)) )
                  (inc 'Fnr)
                  (? (atom Dbs)) )
               (set
                  $DBs Fnr
                  $MaxBlkSize Max
                  $DbBlock (alloc (val $DbBlock) (i64 Max)) ) ) )
         (unless (nil? Sym2)  # Replication journal
            (let Nm (xName Exe Sym2)  # Journal name
               (unless (fopen (pathString Nm (b8 (pathSize Nm))) ($ "a"))
                  (openErr Exe Sym2) )
               (set $DbJnl @)
               (closeOnExec Exe (fileno @)) ) )
         (unless (nil? Sym3)  # Transaction log
            (let Nm (xName Exe Sym3)  # Transaction log name
               (unless (fopen (pathString Nm (b8 (pathSize Nm))) ($ "a+"))
                  (openErr Exe Sym3) )
               (set $DbLog @)
               (closeOnExec Exe (fileno @))
               (when (transaction)
                  (restore Exe) )
               (truncLog Exe)  ) ) ) )
   $T )


(local) (dbFetch dbTouch dbZap)

(de void dbFetch (Exe Sym)
   Sym )

(de void dbTouch (Exe Sym)
   Sym )

# (touch 'sym) -> sym
(de _touch (Exe)
   (let X (eval (cadr Exe))
      (when (and (symb? X) (sym? (val (tail X))))
         (dbTouch Exe X) )
      X ) )

(de void dbZap (Sym)
   Sym )
