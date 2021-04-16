# 16apr21 Software Lab. Alexander Burger

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

(local) (getAdr setAdr dbfBuf)

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
(de i8* dbfBuf ((i8* . P))
   (let N
      (|  # Two bytes little endian
         (shl (i32 (val 2 P)) 8)
         (i32 (val P)) )
      (if (> (val $DBs) N)  # Local file
         (set $DbFile  # Set current file
            (ofs (val $DbFiles) (* N (dbFile T))) )
         null ) ) )

# Locking
(local) (rdLockDb wrLockDb unLockDb tryLock lockJnl unLockJnl)

(de void rdLockDb ()
   (unless (t? (val $Solo))  # Not already locked whole DB
      (rdLockWait ((dbFile (val $DbFiles)) fd) 1) ) )  # Descriptor of first file

(de void wrLockDb ()
   (unless (t? (val $Solo))  # Not already locked whole DB
      (wrLockWait ((dbFile (val $DbFiles)) fd) 1) ) )  # Descriptor of first file

(de void unLockDb ((i64 . Len))
   (unless (t? (val $Solo))  # Not already locked whole DB
      (unless Len
         (let (Db (val $DbFiles)  C (val $DBs))  # Iterate DB files
            (while (dec 'C)
               (let Db: (dbFile (setq Db (ofs Db (dbFile T))))  # Skip first, increment by size of dbFile
                  (when (Db: lck)
                     (unLock (Db: fd) 0 0)
                     (Db: lck NO) ) ) ) )
         (set $Solo ZERO) )
      (unLock ((dbFile (val $DbFiles)) fd) 0 Len) ) )  # Descriptor of first file

(de i32 tryLock ((i8* . DbFile) (i64 . N) (i64 . Len))
   (let Db: (dbFile DbFile)
      (loop
         (? (ge0 (wrLock (Db: fd) N Len NO))  # Try to lock
            (Db: lck YES)  # Set lock flag
            (nond
               (N (set $Solo $T))  # Set solo mode
               ((t? (val $Solo)) (set $Solo $Nil)) )  # Clear solo mode
            0 )
         (unless
            (or
               (== (gErrno) EINTR)  # Interrupted
               (== @ EACCES)  # Locked by another process
               (== @ EAGAIN) )  # Memory-mapped by another process
            (lockErr) )
         (while (lt0 (getLock (Db: fd) N Len))
            (unless (== (gErrno) EINTR)
               (lockErr) ) )
         (? (gt0 @) @) ) ) )

(de void lockJnl ()
   (wrLockWait (fileno (val $DbJnl)) 0) )

(de void unLockJnl ()
   (let Jnl (val $DbJnl)
      (fflush Jnl)
      (unLock (fileno Jnl) 0 0) ) )

(local) (blkPeek rdBlock blkPoke wrBlock logBlock)

(de void blkPeek ((i64 . Pos) (i8* . Buf) (i32 . Siz))
   (let (S (i64 Siz)  Db: (dbFile (val $DbFile)))
      (unless (== S (pread (Db: fd) Buf S Pos))
         (dbRdErr) ) ) )

(de i8* rdBlock ((i64 . N))
   (let (Db: (dbFile (val $DbFile))  Blk (val $DbBlock))
      (blkPeek  # Read block
         (shl (set $BlkIndex N) (i64 (Db: sh)))
         Blk
         (Db: siz) )
      (set
         $BlkLink (& (getAdr Blk) BLKMASK)
         $BlkEnd (ofs Blk (Db: siz))
         $BlkPtr (ofs Blk BLK) )  # Pointer to data
      Blk ) )  # Pointer to block

(de void blkPoke ((i64 . Pos) (i8* . Buf) (i32 . Siz))
   (let Db: (dbFile (val $DbFile))
      (unless (== Siz (i32 (pwrite (Db: fd) Buf (i64 Siz) Pos)))
         (dbWrErr) )
      (when (val $DbJnl)
         (let Jnl @
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
                     (== 1 (fwrite Buf (i64 Siz) 1 Jnl)) )  # Write 'Buf'
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
            (== 1 (fwrite (val $DbBlock) (i64 (Db: siz)) 1 Log)) )  # Write block
         (err 0 0 ($ "Log write: %s") (strErrno)) ) ) )

(local) (newBlock newId isLife cleanUp getBlock putBlock)

(de i64 newBlock ()
   (let
      (Db: (dbFile (val $DbFile))
         Siz (Db: siz)
         P (b8 Siz) )
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
         (memset P 0 (i64 Siz) T)  # Init new block
         (blkPoke (shl N (i64 (Db: sh))) P Siz)
         N ) ) )

(de newId (Exe (i32 . N))
   (when (>= (dec 'N) (val $DBs))
      (dbfErr Exe) )
   (set $DbFile  # Set current file
      (ofs (val $DbFiles) (* N (dbFile T))) )
   (set $Protect (inc (val $Protect)))
   (wrLockDb)
   (when (val $DbJnl)
      (lockJnl) )
   (prog1
      (extNm
         ((dbFile (val $DbFile)) db)
         (shr (newBlock) 6) )
      (when (val $DbJnl)
         (unLockJnl) )
      (unLockDb 1)
      (set $Protect (dec (val $Protect))) ) )

(de i1 isLife (Sym)
   (let
      (Nm (name (& (val (tail Sym)) -9))
         F (objFile Nm)
         N (shl (objId Nm) 6) )
      (when N
         (cond
            ((> (val $DBs) F)  # Local file
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
                           (ofs (val $DbFiles) (* F (dbFile T))) ) )
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
            (ret -1) )
         (setq P (ofs (rdBlock @) BLK)) )
      (set $BlkPtr (inc P))
      (i32 (val P)) ) )

(de void putBlock ((i8 . B))
   (let P (val $BlkPtr)
      (when (== P (val $BlkEnd))
         (let Link (val $BlkLink)
            (ifn Link
               (let
                  (New (newBlock)
                     Cnt (i64 (val (setq P (val $DbBlock)))) )  # Block count (link is zero)
                  (setAdr (| New Cnt) P)
                  (wrBlock)  # Write new block
                  (set $BlkIndex New)  # Set new block index
                  (setAdr (if (== Cnt BLKTAG) Cnt (inc Cnt)) P)
                  (setq P (ofs P BLK)) )
               (wrBlock)  # Write current block
               (setq P (ofs (rdBlock Link) BLK)) ) ) )  # Read next block
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
                     (setq Tail (sym Tail)) )  # Set 'extern' tag
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
   (let (Log (val $DbLog)  Blk (b8 BLK))
      (fseek0 Log)
      (if (fread Blk 2 1 Log)  # Read first file number
         (loop
            (? (== (val (i16* Blk)) (hex "FFFF")) YES)  # Byte order doesn't matter
            (?
               (or
                  (=0 (dbfBuf Blk))
                  (<> (fread Blk BLK 1 Log) 1)
                  (not (fseekOfs Log ((dbFile (val $DbFile)) siz)))
                  (<> (fread Blk 2 1 Log) 1) )
               (ignLog)
               NO ) )
         (unless (feof Log)
            (ignLog) )  # Discard incomplete transaction
         NO ) ) )

(de void fsyncDB (Exe)
   (let (Db (val $DbFiles)  C (val $DBs))  # Iterate DB files
      (loop
         (let Db: (dbFile Db)
            (when (and (Db: drt) (lt0 (fsync (Db: fd))))
               (dbSyncErr Exe) ) )
         (? (=0 (dec 'C)))
         (setq Db (ofs Db (dbFile T))) ) ) )

(de void restore (Exe)
   (stderrMsg ($ "Last transaction not completed: Rollback\n") null)
   (let Log (val $DbLog)
      (fseek0 Log)
      (let (Db (val $DbFiles)  C (val $DBs))  # Iterate DB files
         (loop
            ((dbFile Db) drt NO)
            (? (=0 (dec 'C)))
            (setq Db (ofs Db (dbFile T))) ) )
      (let (Blk (b8 BLK)  Buf (b8 (val $MaxBlkSize)))
         (loop
            (unless (== (fread Blk 2 1 Log) 1)  # Get file number
               (jnlErr Exe) )
            (? (== (val (i16* Blk)) (hex "FFFF")))  # Byte order doesn't matter
            (if (dbfBuf Blk)
               (let Db: (dbFile @)
                  (unless
                     (and
                        (== (fread Blk BLK 1 Log) 1)
                        (== (fread Buf (i64 (Db: siz)) 1 Log) 1) )
                     (jnlErr Exe) )
                  (unless
                     (==
                        (pwrite
                           (Db: fd)
                           Buf
                           (i64 (Db: siz))
                           (shl (getAdr Blk) (i64 (Db: sh))) )
                        (i64 (Db: siz)) )
                     (dbWrErr) )
                  (Db: drt YES) )
               (jnlErr Exe) ) )
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
         (let (Db (val $DbFiles)  C @)  # Iterate DB files
            (loop
               (let Db: (dbFile Db)
                  (close (Db: fd))
                  (free (Db: mark)) )
               (? (=0 (dec 'C)))
               (setq Db (ofs Db (dbFile T))) ) )
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
               End (ofs Buf (dec Len))
               Siz (dbFile T) )  # Default to single dbFile
            (when (pair Dbs)
               (let L Dbs
                  (while (pair (shift L))
                     (inc 'Siz (dbFile T)) ) ) )
            (let
               (Db (set $DbFiles (alloc (val $DbFiles) Siz))
                  P (b8 (+ BLK BLK 1))
                  Fnr (i32 0)
                  Max (i32 0) )
               (loop
                  (let Db: (dbFile (set $DbFile Db))  # Set current file
                     (Db: db Fnr)
                     (if (atom Dbs)
                        (Db: sh 2)
                        (set (bufAo End Fnr) 0)
                        (Db: sh (i32 (int (++ Dbs)))) )
                     (cond
                        ((ge0 (Db: fd (openRdWr Buf)))  # Exists
                           (blkPeek 0 P (+ BLK BLK 1))  # Read block shift from block zero
                           (Db: siz
                              (shl
                                 (i32 BLKSIZE)
                                 (Db: sh (i32 (val (+ BLK BLK 1) P))) ) ) )  # Override block shift from 'Dbs'
                        ((and
                              (== (gErrno) ENOENT)
                              (ge0 (Db: fd (openRdWrExcl Buf))) )
                           (let
                              (N (shl (i32 BLKSIZE) (Db: sh))
                                 Stk (stack)
                                 Blk (b8 (Db: siz N)) )
                              (memset Blk 0 (i64 N) T)  # 'free' is null
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
                                 (memset Blk 0 16 T)  # Clear 'next' link in buffer
                                 (setAdr 1 Blk)  # First block for DB root into link field
                                 (blkPoke (i64 (Db: siz)) Blk N) )  # has block size position
                              (stack Stk) ) )
                        (T (openErr Exe Sym1)) )
                     (closeOnExec Exe (Db: fd))
                     (when (> (Db: siz) Max)
                        (setq Max @) )
                     (Db: mark null)
                     (Db: mrks 0)
                     (Db: flu -1)
                     (Db: lck (Db: drt NO))
                     (inc 'Fnr)
                     (? (atom Dbs))
                     (setq Db (ofs Db (dbFile T))) ) )
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

# (pool2 'sym . prg) -> any
(de _pool2 (Exe)
   (let
      (X (cdr Exe)
         Sym (evSym X)
         Nm (xName Exe Sym)
         Jnl (val $DbJnl)
         Log (val $DbLog)
         C (val $DBs)
         FDs (b32 C) )
      (set $DbJnl null  $DbLog null)  # Stop journal and transaction log
      (let (Db (val $DbFiles)  I (i32 0))  # Iterate DB files
         (loop
            (let Db: (dbFile Db)
               (set (ofs FDs I) (Db: fd)) )  # Save file descriptor
            (? (== C (inc 'I)))
            (setq Db (ofs Db (dbFile T))) ) )
      (let
         (Len (pathSize Nm)
            Buf (pathString Nm (b8 (+ Len 4)))  # 4 bytes for AO file number
            End (ofs Buf (dec Len)) )
         (let (Db (val $DbFiles)  I (i32 0))  # Iterate DB files
            (loop
               (let Db: (dbFile Db)
                  (set (bufAo End (Db: db)) 0)
                  (when (lt0 (Db: fd (openRdWr Buf)))  # Try to open
                     (openErr Exe Sym) )
                  (closeOnExec Exe @) )
               (? (== C (inc 'I)))
               (setq Db (ofs Db (dbFile T))) ) ) )
      (prog1
         (run (cdr X)
            (let (Db (val $DbFiles)  I (i32 0))  # Iterate DB files
               (loop
                  (let Db: (dbFile Db)
                     (close (Db: fd))  # Close file
                     (Db: fd (val (ofs FDs I))) )  # Restore file descriptor
                  (? (== C (inc 'I)))
                  (setq Db (ofs Db (dbFile T))) ) )
            (set $DbLog Log  $DbJnl Jnl) ) ) ) )

# (journal ['T] 'any ..) -> T
(de _journal (Exe)
   (let
      (X (cdr Exe)
         Sym (evSym X)
         Jnl (val $DbJnl)
         Log (val $DbLog)
         Buf (b8 (val $MaxBlkSize))
         Blk (b8 BLK) )
      (stkChk Exe)
      (when (t? Sym)
         (set $DbJnl null  $DbLog null)  # Stop journal and transaction log
         (setq Sym (evSym (shift X))) )
      (loop
         (let
            (Nm (xName Exe Sym)  # Journal name
               Fp (fopen (pathString Nm (b8 (pathSize Nm))) ($ "r")) )
            (unless Fp
               (openErr Exe Sym) )
            (while (ge0 (getc_unlocked Fp))
               (let Siz @
                  (unless (== (fread Blk 2 1 Fp) 1)  # Read file number
                     (jnlErr Exe) )
                  (if (dbfBuf Blk)  # Get file number from 'Buf' to 'DbFile'
                     (let Db: (dbFile @)
                        #! Temporary backward compatibility
                        (when (== Siz BLKSIZE)
                           (setq Siz (Db: siz)) )
                        #!
                        (unless Siz
                           (setq Siz (Db: siz)) )
                        (unless
                           (and
                              (== (fread Blk BLK 1 Fp) 1)
                              (== (fread Buf (i64 Siz) 1 Fp) 1) )
                           (jnlErr Exe) )
                        (blkPoke
                           (shl (getAdr Blk) (i64 (Db: sh)))
                           Buf
                           Siz ) )
                     (dbfErr Exe) ) ) )  # No local file
            (fclose Fp)
            (? (atom (shift X)))
            (setq Sym (evSym X)) ) )
      (set $DbLog Log  $DbJnl Jnl)
      $T ) )

# (id 'num ['num]) -> sym
# (id 'sym [NIL]) -> num
# (id 'sym T) -> (num . num)
(de _id (Exe)
   (let (X (cdr Exe)  Y (eval (++ X)))
      (if (cnt? Y)  # File number or object ID
         (extern
            (if (nil? (eval (car X)))
               (extNm 0 (int Y))
               (extNm (dec (i32 (int Y))) (xCnt Exe @)) ) )
         (needSymb Exe Y)
         (unless (sym? (val (tail (needSymb Exe Y))))
            (extErr Exe Y) )
         (let
            (Nm (name (& (val (tail Y)) -9))
               Z (cnt (objId Nm)) )
            (if (nil? (eval (car X)))  # Return only object ID
               Z
               (cons
                  (cnt (i64 (inc (objFile Nm))))
                  Z ) ) ) ) ) )

# (blk 'fd 'cnt 'siz ['fd2]) -> lst
# (blk 'fd 0) -> (cnt . siz)
(de _blk (Exe)
   (let (X (cdr Exe)  Db: (dbFile (b8 (dbFile T))))
      (Db: fd (i32 (evCnt Exe X)))  # File descriptor
      (if (=0 (evCnt Exe (shift X)))  # Block number
         (let Buf (b8 BLK)
            (unless
               (==
                  (+ BLK 1)
                  (pread (Db: fd) Buf (+ BLK 1) BLK) )
               (dbRdErr) )
            (cons
               (cnt (shr (getAdr Buf) 6))  # Block count
               (cnt (i64 (val (ofs Buf BLK)))) ) )  # Block shift
         (let
            (N (shl @ 6)  # Block index
               P (val $DbBlock)  # Block buffer
               Siz  # Block size
               (shl
                  (i32 BLKSIZE)
                  (Db: sh (i32 (evCnt Exe (shift X)))) )  # 'siz' scale factor
               Fd
               (i32
                  (if (atom (shift X))
                     -1
                     (evCnt Exe @)) ) )
            (when (> (Db: siz Siz) (val $MaxBlkSize))
               (set $MaxBlkSize Siz  $DbBlock (alloc P (i64 Siz))) )
            (set $DbFile (Db:))
            (when (ge0 Fd)
               (rdLockWait Fd 1) )  # Lock for reading
            (prog1
               (let Blk (rdBlock N)  # Read first block
                  (if (<> 1 (& (val Blk) BLKTAG))  # ID-Block
                     $Nil
                     (set
                        $GetBin (fun (i32) getBlock)
                        $Extn (val $ExtN) )
                     (let
                        (L (cons (binRead) $Nil)  # Read symbol value
                           R (save L) )
                        (until (nil? (binRead))  # Property key
                           (setq L (set 2 L (cons @ $Nil)))
                           (unless (t? (binRead))  # Next property value
                              (set L (cons @ (car L))) ) )
                        R ) ) )
               (when (ge0 Fd)
                  (unLock @ 0 0) ) ) ) ) ) )

# (seq 'cnt|sym1) -> sym | NIL
(de _seq (Exe)
   (let
      (X (eval (cadr Exe))
         F (dec (i32 (int X)))
         N 0
         Buf (b8 BLK) )
      (unless (cnt? X)
         (unless (sym? (val (tail (needSymb Exe X))))
            (extErr Exe X) )
         (let Nm (name (& (val (tail X)) -9))
            (setq
               F (objFile Nm)
               N (shl (objId Nm) 6) ) ) )
      (when (>= F (val $DBs))
         (dbfErr Exe) )
      (let Db:
         (dbFile
            (set $DbFile
               (ofs (val $DbFiles) (* F (dbFile T))) ) )
         (rdLockDb)  # Lock for reading
         (blkPeek BLK Buf BLK)  # Read 'next' from block zero
         (let Next (getAdr Buf)
            (prog1
               (loop
                  (? (>= (inc 'N BLKSIZE) Next) $Nil)
                  (blkPeek (shl N (i64 (Db: sh))) Buf BLK)  # Read link field
                  (? (== 1 (& (val Buf) BLKTAG))  # ID-Block
                     (extern (extNm F (shr N 6))) ) )
               (unLockDb 1) ) ) ) ) )  # Unlock

# (lieu 'any) -> sym | NIL
(de _lieu (Exe)
   (let X (eval (cadr Exe))
      (nond
         ((symb? X) $Nil)
         ((sym? (val (tail X))) $Nil)
         (NIL
            (let Nm (name (& (val (tail X)) -9))
               (setq Nm (add Nm Nm))
               (cond
                  (@@  # Dirty
                     (setq Nm (add Nm Nm))
                     (if @@ $Nil X) )  # Deleted
                  (T
                     (setq Nm (add Nm Nm))
                     (if @@ X $Nil) ) ) ) ) ) ) )  # Loaded

# (lock ['sym]) -> cnt | NIL
(de _lock (Exe)
   (if
      (if (nil? (eval (cadr Exe)))
         (tryLock (val $DbFiles) 0 0)  # Use first dbFile
         (let X (needSymb Exe @)
            (unless (sym? (val (tail (needSymb Exe X))))
               (extErr Exe X) )
            (let
               (Nm (name (& (val (tail X)) -9))
                  F (objFile Nm)
                  N (objId Nm) )
               (when (>= F (val $DBs))
                  (dbfErr Exe) )
               (let Db: (dbFile (ofs (val $DbFiles) (* F (dbFile T))))
                  (tryLock (Db:) (* N (i64 (Db: siz))) 1) ) ) ) )
      (cnt (i64 @))
      $Nil ) )

(local) (db dbFetch dbTouch dbZap)

(de void db (Exe Sym Nm)
   (save Sym)
   (let F (objFile Nm)  # Get file number
      (if (>= F (val $DBs))
         (let Ext (val $Ext)  # Non-local file
            (if
               (or
                  (atom Ext)  # First offset
                  (> (i32 (int (caar @))) (inc 'F)) )  # too big
               (dbfErr Exe)
               (while  # Find DB extension
                  (and
                     (pair (cdr Ext))
                     (>= F (i32 (int (caar @)))) )
                  (shift Ext) )
               (let
                  (V (push NIL $Nil ZERO Sym)  # [car cdr name arg]
                     E (push NIL V ZERO (cdar Ext)) )  # [car cdr name fun]
                  (set V (ofs V 3)  E (ofs E 3))
                  (let X (evList E)
                     (set Sym (++ X))  # Set value
                     (if (atom X)
                        (set (tail Sym) Nm)  # Set status/name
                        (set (tail Sym) (sym X))  # Set property list
                        (while (pair (cdr X))  # Find end
                           (setq X @) )
                        (set 2 X Nm) ) ) ) ) )  # Set status/name
         # Local file
         (set $DbFile
            (ofs (val $DbFiles) (* F (dbFile T))) )
         (rdLockDb)  # Lock for reading
         (let Blk (rdBlock (shl (objId Nm) 6))  # Read first block
            (unless (== 1 (& (val Blk) BLKTAG))  # ID-Block
               (err Exe Sym ($ "Bad ID") null) ) )
         (set
            $GetBin (fun (i32) getBlock)
            $Extn 0 )
         (set Sym (binRead))  # Read symbol value
         (if (nil? (binRead))  # First property key
            (set (tail Sym) Nm)  # Set status/name
            (set (tail Sym)  # Set tail
               (sym (setq Nm (cons @ Nm))) )
            (unless (t? (binRead))  # First property value
               (set Nm (cons @ (val Nm))) )  # Cons with key
            (until (nil? (binRead))  # Next property key
               (set 2 Nm (cons @ (cdr Nm)))
               (shift Nm)
               (unless (t? (binRead))  # Next property value
                  (set Nm (cons @ (val Nm))) ) ) )  # Cons with key
         (unLockDb 1) ) ) )  # Unlock

(de void dbFetch (Exe Sym)
   (let Nm (val (tail Sym))
      (when
         (and
            (num? Nm)  # No properties
            (prog (setq Nm (add Nm Nm)) (not @@))  # Not dirty
            (prog (setq Nm (add Nm Nm)) (not @@)) )  # Not loaded
         (set (tail Sym) (setq Nm (shr 1 Nm 2)))  # Set "loaded"
         (tailcall (db Exe Sym Nm)) ) ) )

(de void dbTouch (Exe Sym)
   (let (Q (tail Sym)  Nm (val Q))
      (unless (num? Nm)  # Has properties
         (setq Nm (any (& Nm -9)))  # Clear 'extern' tag
         (loop
            (setq Q (ofs Nm 1))  # Skip property
            (? (num? (setq Nm (val Q)))) ) )  # Find name
      (setq Nm (add Nm Nm))
      (unless @@  # Not yet dirty
         (setq Nm (add Nm Nm))
         (set Q (setq Nm (shr 2 Nm 2)))  # Set "dirty"
         (unless @@  # Not loaded
            (tailcall (db Exe Sym Nm)) ) ) ) )

# (touch 'sym) -> sym
(de _touch (Exe)
   (let X (eval (cadr Exe))
      (when (and (symb? X) (sym? (val (tail X))))
         (dbTouch Exe X) )
      X ) )

(de void dbZap (Sym)
   (let Tail (val (tail Sym))  # Get tail
      (unless (num? Tail)  # Any properties
         (setq Tail (& Tail -9))  # Clear 'extern' tag
         (loop
            (? (num? (shift Tail))) )  # Find name
         (setq Tail (sym Tail)) )  # Set 'extern' tag
      (set (tail Sym) (shr 3 (shl Tail 2) 2))  # Set "deleted"
      (set Sym $Nil) ) )  # Clear value

# (commit ['any] [exe1] [exe2]) -> T
(de _commit (Exe)
   (let (Args (cdr Exe)  Rpc (save (eval (++ Args)))  Notify NO)
      (set $Protect (inc (val $Protect)))
      (wrLockDb)
      (when (val $DbJnl)
         (lockJnl) )
      (when (val $DbLog)
         (let (Db (val $DbFiles)  C (val $DBs))  # Iterate DB files
            (loop
               (let Db: (dbFile Db)
                  (Db: drt NO)  # Clear dirty flag
                  (Db: flu 0) )  # and free list use count
               (? (=0 (dec 'C)))
               (setq Db (ofs Db (dbFile T))) ) )
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
                        (let F (objFile Nm)  # Get file number
                           (when (> (val $DBs) F)  # Local file
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
            (let (P (val $DbFiles)  C (val $DBs))  # Iterate DB files
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
      (eval (++ Args)) # Eval pre-expression
      (when (and (not (nil? Rpc)) (or (val $Tell) (val $Children)))
         (setq Notify YES)
         (set
            $BufX (val $TellBuf)  # Save current 'tell' env
            $PtrX (val $Ptr)
            $EndX (val $End) )
         (tellBeg (b8 (val PipeBufSize)))  # Start 'tell' message
         (prTell Rpc) )
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
               (let (Sym (val P)  Q (tail Sym)  Nm (val Q))  # Get external symbol
                  (unless (num? Nm)  # Any properties
                     (setq Nm (any (& Nm -9)))  # Clear 'extern' tag
                     (loop
                        (setq Q (ofs Nm 1))  # Skip property
                        (? (num? (setq Nm (val Q)))) ) )  # Find name
                  (let N (add Nm Nm)
                     (when @@  # Dirty or deleted
                        (let F (objFile Nm)  # Get file number
                           (setq N (add N N))
                           (cond
                              (@@  # Deleted
                                 (set Q (shr N 2))  # Set "not loaded"
                                 (when (> (val $DBs) F)  # Local file
                                    (set $DbFile
                                       (ofs (val $DbFiles) (* F (dbFile T))) )
                                    (cleanUp (shl (objId Nm) 6))
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
                                             (prTell Rpc) ) )
                                       (prTell Sym) ) ) )  # Send external symbol to 'tell'
                              (T  # Dirty
                                 (set Q (shr 1 N 2))  # Set "loaded"
                                 (when (> (val $DBs) F)  # Local file
                                    (set $DbFile
                                       (ofs (val $DbFiles) (* F (dbFile T))) )
                                    (let Blk (rdBlock (shl (objId Nm) 6))  # Read first block
                                       (set
                                          Blk (| (val Blk) 1)  # First block in object (might be new)
                                          $PutBin (fun (void i8) putBlock)
                                          $Extn 0 )
                                       (binPrint (val Sym))  # Print value
                                       (let L (& (val (tail Sym)) -9)  # Get Properties
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
                                          Blk )
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
                                                (prTell Rpc) ) )
                                          (prTell Sym) ) ) ) ) ) ) ) ) )  # Send external symbol to 'tell'
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
      (eval (car Args)) # Eval post-expression
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
      (set $Protect (dec (val $Protect)))
      (let (P (val $DbFiles)  C (val $DBs))  # Iterate DB files
         (loop
            ((dbFile P) flu -1)  # Init free list use count
            (? (=0 (dec 'C)))
            (setq P (ofs P (dbFile T))) ) )
      $T ) )

# (mark 'sym|0 [NIL | T | 0]) -> flg
(de _mark (Exe)
   (let (X (cdr Exe)  Y (eval (++ X)))
      (if (== Y ZERO)  # Clear all marks
         (let (Db (val $DbFiles)  C (val $DBs))  # Iterate DB files
            (while (ge0 (dec 'C))
               (let Db: (dbFile Db)
                  (Db: mrks 0)  # Set mark vector size to zero
                  (free (Db: mark))  # Free mark bit vector
                  (Db: mark null) )  # and set to null
               (setq Db (ofs Db (dbFile T))) )
            $Nil )
         (unless (sym? (val (tail (needSymb Exe Y))))
            (extErr Exe Y) )
         (let
            (Nm (name (& (val (tail Y)) -9))
               F (objFile Nm)
               N (objId Nm) )
            (if (>= F (val $DBs))
               $T  # Non-local file
               (let
                  (Flg (eval (car X))  # Second arg
                     Db: (dbFile (ofs (val $DbFiles) (* F (dbFile T))))
                     P (Db: mark)  # Mark bit vector
                     I (shr N 3) )  # Byte index
                  (when (>= I (Db: mrks))  # Greater or equal to mark vector size
                     (let J (inc I)
                        (memset
                           (ofs
                              (setq P (Db: mark (alloc P J)))  # Increase mark bit vector
                              (Db: mrks) )
                           0  # Clear new area
                           (- J (Db: mrks)) )
                        (Db: mrks J) ) )  # New mark vector size
                  (setq
                     P (ofs P I)  # Byte position in bit vector
                     N (i8 (shl 1 (& N 7))) )  # Bit position
                  (let B (val P)  # Old value
                     (cond
                        ((& B N)  # Bit is set
                           (when (== ZERO Flg)
                              (set P (& B (x| N -1))) )  # Clear mark
                           $T )  # Return T
                        (T  # Bit is not set
                           (when (== $T Flg)
                              (set P (| B N)) )  # Set mark
                           $Nil ) ) ) ) ) ) ) ) )  # Return NIL

# (free 'cnt) -> (sym . lst)
(de _free (Exe)
   (let
      (X (cdr Exe)
         F (dec (i32 (evCnt Exe X)))
         Buf (b8 (* BLK 2)) )
      (when (>= F (val $DBs))
         (dbfErr Exe) )
      (set $DbFile
         (ofs (val $DbFiles) (* F (dbFile T))) )
      (rdLockDb)  # Lock for reading
      (blkPeek 0 Buf (* 2 BLK))  # Read 'free' and 'next' from block zero
      (set $BlkLink (getAdr Buf))  # free' as next block
      (let
         (Y
            (cons  # CAR of result list
               (extern  # 'next' symbol
                  (extNm F (shr (getAdr (ofs Buf BLK)) 6)) )
               $Nil )
            R (save Y) )
         (while (val $BlkLink)  # Collect free list
            (setq Y
               (set 2 Y
                  (cons (extern (extNm F (shr @ 6))) $Nil) ) )
            (rdBlock @) )
         (unLockDb 1)  # Unlock
         R ) ) )

# (dbck ['cnt] 'flg) -> any
(de _dbck (Exe)
   (let
      (X (cdr Exe)
         Y (eval (car X))
         Jnl (val $DbJnl)
         Buf (b8 (* BLK 2))
         Cnt BLKSIZE
         Syms 0
         Blks 0 )
      (if (cnt? Y)
         (let F (dec (i32 (int Y)))
            (when (>= F (val $DBs))
               (dbfErr Exe) )
            (set $DbFile
               (ofs (val $DbFiles) (* F (dbFile T))) )
            (setq Y (eval (cadr X))) )  # Use first dbFile
         (set $DbFile (val $DbFiles)) )
      (set $Protect (inc (val $Protect)))
      (wrLockDb)
      (when Jnl
         (lockJnl)  # Write lock journal
         (set $DbJnl null) )  # Disable Journal
      (blkPeek 0 Buf (* 2 BLK))  # Read 'free' and 'next' from block zero
      (set $BlkLink (getAdr Buf))  # free' as next block
      (let Next (getAdr (ofs Buf BLK))  # Get 'next'
         (while (val $BlkLink)  # Check free list
            (let Blk (rdBlock @)
               (set Blk (| (val Blk) BLKTAG)) )  # Mark free list
            (when (> (inc 'Cnt BLKSIZE) Next)
               (setq Y (mkStr ($ "Circular free list")))
               (goto 9) )
            (wrBlock) )
         (set $DbJnl Jnl)  # Restore Journal
         (let P BLKSIZE
            (until (== P Next)  # Check all chains
               (let Blk (rdBlock P)
                  (case (& (val Blk) BLKTAG)
                     (0  # Free block
                        (inc 'Cnt BLKSIZE)
                        (memcpy Blk Buf BLK T)
                        (wrBlock)
                        (setAdr P Buf)
                        (blkPoke 0 Buf BLK) )
                     (1  # ID-block of symbol
                        (inc 'Syms)
                        (let I (i8 2)
                           (loop  # Check chains
                              (inc 'Blks)
                              (inc 'Cnt BLKSIZE)
                              (? (=0 (val $BlkLink)))
                              (unless
                                 (== I
                                    (& (val (rdBlock @)) BLKTAG) )
                                 (setq Y (mkStr ($ "Bad chain")))
                                 (goto 9) )
                              (when (> BLKTAG I)
                                 (inc 'I) ) ) ) ) ) )
               (inc 'P BLKSIZE) ) )
         (set $BlkLink (getAdr Buf))
         (set $DbJnl null)  # Disable Journal
         (while (val $BlkLink)  # Unmark free list
            (let Blk (rdBlock @)
               (when (& (val Blk) BLKTAG)
                  (set Blk (& (val Blk) BLKMASK))
                  (wrBlock) ) ) )
         (nond
            ((== Cnt Next)
               (setq Y (mkStr ($ "Bad count"))) )
            ((nil? Y)
               (setq Y (cons (cnt Blks) (cnt Syms))) ) ) )
      (: 9
         (when (set $DbJnl Jnl)
            (unLockJnl) )
         (unLockDb 1)  # Unlock
         (set $Protect (dec (val $Protect)))
         Y ) ) )
