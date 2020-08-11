# 11aug20 Software Lab. Alexander Burger

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
      (blkPeek  # Read block
         (shl (set $BlkIndex N) (i64 (Db: sh)))
         Blk
         (Db: siz) )
      (set
         $BlkLink (& (getAdr Blk) BLKMASK)
         $BlkEnd (ofs Blk (+ (Db: siz) BLK))
         $BlkPtr (ofs Blk BLK) ) ) )  # Point to block data

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
   (let P (val $BlkPtr)
      (when (== P (val $BlkEnd))
         (unless (val $BlkLink)
            (ret 0) )
         (setq P (rdBlock @)) )
      (set $BlkPtr (inc P))
      (i32 (val P)) ) )

(de void putBlock ((i8 . B))
   (let P (val $BlkPtr)
      (when (== P (val $BlkEnd))
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

(local) (db dbFetch dbTouch dbZap)

(de void db (Exe Sym)
   Sym
   #!
   )

(de void dbFetch (Exe Sym)
   (let Nm (val (tail Sym))
      (when
         (and
            (num? Nm)  # No properties
            (prog (setq Nm (add Nm Nm)) (not @@))  # Not dirty
            (prog (setq Nm (add Nm Nm)) (not @@)) )  # Not loaded
         (set (tail Sym) (shr 1 Nm 2))  # Set "loaded"
         (tailcall (db Exe Sym)) ) ) )

(de void dbTouch (Exe Sym)
   (let (Q (tail Sym)  Nm (val Q))
      (unless (num? Nm)  # Has properties
         (setq Nm (& Nm -9))  # Clear 'extern' tag
         (loop
            (setq Q (ofs Nm 1))  # Skip property
            (? (num? (setq Nm (car Q)))) ) )  # Find name
      (setq Nm (add Nm Nm))
      (unless @@  # Not yet dirty
         (setq Nm (add Nm Nm))
         (set Q (shr 2 Nm 2))  # Set "dirty"
         (unless @@  # Not loaded
            (tailcall (db Exe Sym)) ) ) ) )

# (touch 'sym) -> sym
(de _touch (Exe)
   (let X (eval (cadr Exe))
      (when (and (symb? X) (sym? (val (tail X))))
         (dbTouch Exe X) )
      X ) )

(de void dbZap (Sym)
   #!
   Sym )

# (commit ['any] [exe1] [exe2]) -> T
(de _commit (Exe)
   (let (X (cdr Exe)  Y (save (eval (++ X)))  Notify NO)
      (unless (val $DbLog)
         (set $Protect (inc (val $Protect))) )
      (wrLockDb)
      (when (val $DbJnl)
         (lockJnl) )
      (when (val $DbLog)
         (let (P (val $DbFiles)  C (val $DBs))
            (loop
               ((dbFile P) drt NO)  # Clear dirty flag
               ((dbFile P) flu 0)  # and free list use count
               (? (=0 (dec 'C)))
               (setq P (ofs P (dbFile T))) ) )
         (let (Tos 0  P (val $Extern))  # Iterate external symbol tree
            (loop
               (loop
                  (let X (cdr P)  # Get subtrees
                     (? (atom (car X)))  # Left subtree
                     (let Y P  # Go left
                        (setq P @)  # Invert tree
                        (set X Tos)
                        (setq Tos Y) ) ) )
               (loop
                  (let
                     (Nm (name (& (val (tail (val P))) -9))  # Get external symbol name
                        N (add Nm Nm) )
                     (when @@  # Dirty or deleted
                        (let F (objFile Nm)
                           (when (> (val $DBs) F)
                              (set $DbFile
                                 (ofs (val $DbFiles) (* F (dbFile T))) )
                              (rdBlock (shl (objId Nm) 6))
                              (loop
                                 (logBlock)
                                 (? (=0 (val $BlkLink)))
                                 (rdBlock @) )
                              (let Db: (dbFile (val $DbFile))
                                 (Db: drt YES)
                                 (add N N)
                                 (unless @@  # Not deleted
                                    (Db: flu (inc (Db: flu))) ) ) ) ) ) )
                  (let X (cdr P)
                     (? (pair (cdr X))  # Right subtree
                        (let Y P  # Go right
                           (setq P @)  # Invert tree
                           (set 2 X Tos)
                           (setq Tos (| Y 8)) ) ) )  # First visit
                  (loop
                     (unless Tos
                        (goto 1) )
                     (? (=0 (& Tos 8))  # Second visit
                        (let (X Tos  Y (cdr X))  # Nodes
                           (setq Tos (car Y))  # TOS on up link
                           (set Y P)
                           (setq P X) ) )
                     (setq Tos (& Tos -9))  # Clear visit bit
                     (let (X Tos  Y (cdr X))  # Nodes
                        (setq Tos (cdr Y))
                        (set 2 Y P)
                        (setq P X) ) ) ) ) )
         (: 1
            (let (P (val $DbFiles)  C (val $DBs))
               (loop
                  (when ((dbFile P) flu)
                     (let N @
                        (set $DbFile P)
                        (rdBlock 0)  # Save Block 0
                        (loop  # and free list
                           (logBlock)
                           (? (=0 (dec 'N)))
                           (? (=0 (val $BlkLink)))
                           (rdBlock @) ) ) )
                  (? (=0 (dec 'C)))
                  (setq P (ofs P (dbFile T))) ) )
            (let Log (val $DbLog)
               (putc_unlocked (hex "FF") Log)  # Write end marker
               (putc_unlocked (hex "FF") Log)
               (fflush Log)
               (when (lt0 (fsync (fileno Log)))
                  (err Exe 0 ($ "Transaction fsync error: %s") (strErrno)) ) ) ) )
      (eval (++ X)) # Eval pre-expression
      (when (and (not (nil? Y)) (or (val $Tell) (val $Children)))
         (setq Notify YES)
         (set
            $BufX (val $TellBuf)  # Save current 'tell' env
            $PtrX (val $Ptr)
            $EndX (val $End) )
         (tellBeg (b8 (val PipeBufSize)))  # Start 'tell' message
         (stkChk Exe)
         (prTell Y) )
      (let (Tos 0  P (val $Extern))  # Iterate external symbol tree
         (loop
            (loop
               (let X (cdr P)  # Get subtrees
                  (? (atom (car X)))  # Left subtree
                  (let Y P  # Go left
                     (setq P @)  # Invert tree
                     (set X Tos)
                     (setq Tos Y) ) ) )
            (loop
               (let (S (val P)  Q (tail S)  Nm (val Q))  # Get external symbol
                  (unless (num? Nm)  # Any properties
                     (setq Nm (& Nm -9))  # Clear 'extern' tag
                     (loop
                        (setq Q (ofs Nm 1))  # Skip property
                        (? (num? (setq Nm (car Q)))) ) )  # Find name
                  (let N (add Nm Nm)
                     (when @@  # Dirty or deleted
                        (let F (objFile Nm)
                           (add N N)
                           (cond
                              (@@  # Deleted
                                 (set Q (shr N 2))  # Set "not loaded"
                                 (when (> (val $DBs) F)
                                    (set $DbFile
                                       (ofs (val $DbFiles) (* F (dbFile T))) )
                                    (cleanUp (shl (i64 F) 6))
                                    (when Notify
                                       (let P (val $TellBuf)
                                          (when
                                             (>=  # Space for EXTERN+<8>+END
                                                (val $Ptr)
                                                (ofs P (- (val PipeBufSize) 10)) )
                                             (tellEnd 0)  # Send close 'tell' to all PIDs
                                             (set  # Partial 'tellBeg'
                                                (inc 'P 8) BEG  # 8 bytes space (PID and count)
                                                $Ptr (inc P) )  # Begin a list
                                             (prTell Y) ) )
                                       (prTell S) ) ) )  # Send external symbol to 'tell'
                              (T  # Dirty
                                 (set Q (shr 1 N 2))  # Set "loaded"
                                 (when (> (val $DBs) F)
                                    (set $DbFile
                                       (ofs (val $DbFiles) (* F (dbFile T))) )
                                    (rdBlock (shl (objId Nm) 6))
                                    (let Buf (val $DbBlock)
                                       (set
                                          Buf (| (val Buf) 1)  # First block in object (might be new)
                                          $PutBin (fun (void i8) putBlock)
                                          $Extn 0 )
                                       (binPrint (val S))  # Print value
                                       (let L (& (val (tail S)) -9)  # Get Properties
                                          (until (num? L)
                                             (let V (++ L)
                                                (nond
                                                   ((atom V)  # Not boolean
                                                      (unless (nil? (cdr V))  # Not volatile property
                                                         (binPrint @)  # Print key
                                                         (binPrint (car V)) ) )  # and value
                                                   ((nil? V)  # Not volatile property
                                                      (binPrint V)  # Print key
                                                      (binPrint $T) ) ) ) ) )  # and 'T'
                                       (putBlock NIX)
                                       (setAdr  # Clear link
                                          (i64 (& (val (val $DbBlock)) BLKTAG))  # Lowest byte of link field
                                          Buf )
                                       (wrBlock)  # Write block
                                       (when (val $BlkLink)  # More blocks
                                          (cleanUp @) )  # Clean up
                                       (when Notify
                                          (let P (val $TellBuf)
                                             (when
                                                (>=  # Space for EXTERN+<8>+END
                                                   (val $Ptr)
                                                   (ofs P (- (val PipeBufSize) 10)) )
                                                (tellEnd 0)  # Send close 'tell' to all PIDs
                                                (set  # Partial 'tellBeg'
                                                   (inc 'P 8) BEG  # 8 bytes space (PID and count)
                                                   $Ptr (inc P) )  # Begin a list
                                                (prTell Y) ) )
                                          (prTell S) ) ) ) ) ) ) ) ) )  # Send external symbol to 'tell'
               (let X (cdr P)
                  (? (pair (cdr X))  # Right subtree
                     (let Y P  # Go right
                        (setq P @)  # Invert tree
                        (set 2 X Tos)
                        (setq Tos (| Y 8)) ) ) )  # First visit
               (loop
                  (unless Tos
                     (goto 2) )
                  (? (=0 (& Tos 8))  # Second visit
                     (let (X Tos  Y (cdr X))  # Nodes
                        (setq Tos (car Y))  # TOS on up link
                        (set Y P)
                        (setq P X) ) )
                  (setq Tos (& Tos -9))  # Clear visit bit
                  (let (X Tos  Y (cdr X))  # Nodes
                     (setq Tos (cdr Y))
                     (set 2 Y P)
                     (setq P X) ) ) ) ) )
      (: 2
         (when Notify
            (tellEnd 0)
            (set
               $TellBuf (val $BufX)
               $Ptr (val $PtrX)
               $End (val $EndX) ) ) )
      (eval (car X)) # Eval post-expression
      (when (val $DbJnl)
         (unLockJnl) )
      (when (pair (val $Zap))  # Objects to delete
         (let
            (Z @
               Out (val $OutFile)
               Nm (xName Exe (cdr Z))
               S (pathString Nm (b8 (pathSize Nm)))
               Out: (outFile (b8 (outFile T))) )
            (when (lt0 (openWrAppend S))
               (openErr Exe (cdr Z)) )
            (Out: fd @)
            (Out: ix 0)
            (Out: tty NO)
            (set
               $OutFile (Out:)
               $PutBin (fun (void i8) _putStdout)
               $Extn 0 )
            (let Y (car Z)  # Print zap list
               (while (pair Y)
                  (binPrint (++ Y) ) )
               (flush (Out:))
               (close (Out: fd))
               (set Z $Nil)  # Clear zap list
               (set $OutFile Out) ) ) )  # Restore output channel
      (when (val $DbLog)
         (fsyncDB Exe)
         (truncLog Exe) )
      (unLockDb 0)  # Unlock all
      (unsync)
      (unless (val $DbLog)
         (set $Protect (dec (val $Protect))) )
      (let (P (val $DbFiles)  C (val $DBs))
         (loop
            ((dbFile P) flu -1)  # Init free list use count
            (? (=0 (dec 'C)))
            (setq P (ofs P (dbFile T))) ) )
      $T ) )

# (mark 'sym|0 [NIL | T | 0]) -> flg
(de _mark (Exe)
   #!
   Exe )

# (free 'cnt) -> (sym . lst)
(de _free (Exe)
   #!
   Exe )

# (dbck ['cnt] 'flg) -> any
(de _dbck (Exe)
   #!
   Exe )
