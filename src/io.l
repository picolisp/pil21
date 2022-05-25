# 25may22 Software Lab. Alexander Burger

(symbols '(llvm))

(local) (openErr closeErr pipeErr sizeErr eofErr badInput badFd writeErr
selectErr)

(de NIL openErr (Exe X)
   (err Exe X ($ "Open error: %s") (strErrno)) )

(de NIL closeErr ()
   (err 0 0 ($ "Close error: %s") (strErrno)) )

(de NIL pipeErr (Exe)
   (err Exe 0 ($ "Pipe error: %s") (strErrno)) )

(de NIL sizeErr (Exe)
   (err Exe 0 ($ "Size overflow") null) )

(de NIL eofErr ()
   (err 0 0 ($ "EOF Overrun") null) )

(de NIL badInput ()
   (let S (b8 2)
      (set S (i8 (val $Chr)))
      (set 2 S 0)
      (err 0 0 ($ "Bad input '%s'") S) ) )

(de NIL badFd (Exe Fd)
   (err Exe Fd ($ "Bad FD") null) )

(de NIL writeErr ((i8* . Fmt))
   (err 0 0 Fmt (strErrno)) )

(de NIL selectErr (Exe)
   (err Exe 0 ($ "Select error: %s") (strErrno)) )

(local) (closeOnExec rdLockWait wrLockWait)

(de void closeOnExec (Exe (i32 . Fd))
   (when (lt0 (fcntlCloExec Fd))
      (err Exe 0 ($ "SETFD %s") (strErrno)) ) )

(de void rdLockWait ((i32 . Fd) (i64 . Len))
   (while (lt0 (rdLock Fd 0 Len YES))
      (unless (== (gErrno) EINTR)
         (lockErr) ) ) )

(de void wrLockWait ((i32 . Fd) (i64 . Len))
   (while (lt0 (wrLock Fd 0 Len YES))
      (unless (== (gErrno) EINTR)
         (lockErr) ) ) )

(local) (initInFile initOutFile closeInFile closeOutFile)

(de i8* initInFile ((i32 . Fd) (i8* . Nm))
   (let I (val $InFDs)
      (when (>= Fd I)
         (let P
            (set $InFiles
               (i8**
                  (alloc
                     (i8* (val $InFiles))
                     (* 8 (i64 (set $InFDs (+ Fd 1)))) ) ) )
            (loop
               (set (ofs P I) null)
               (? (== I Fd))
               (inc 'I) ) ) ) )
   (let In:
      (inFile
         (let P (ofs (val $InFiles) Fd)
            (if (val P)
               @
               (set P (alloc null (inFile T))) ) ) )
      (In: name Nm)
      (In: tty (n0 (isatty (In: fd Fd))))
      (In: chr 0)
      (In: line (In: src 1))
      (In: ix (In: cnt 0))
      (In:) ) )

(de i8* initOutFile ((i32 . Fd))
   (let I (val $OutFDs)
      (when (>= Fd I)
         (let P
            (set $OutFiles
               (i8**
                  (alloc
                     (i8* (val $OutFiles))
                     (* 8 (i64 (set $OutFDs (+ Fd 1)))) ) ) )
            (loop
               (set (ofs P I) null)
               (? (== I Fd))
               (inc 'I) ) ) ) )
   (let Out:
      (outFile
         (let P (ofs (val $OutFiles) Fd)
            (if (val P)
               @
               (set P (alloc null (outFile T))) ) ) )
      (Out: tty (n0 (isatty (Out: fd Fd))))
      (Out: ix 0)
      (Out:) ) )

(de void closeInFile ((i32 . Fd))
   (when (> (val $InFDs) Fd)
      (let (P (ofs (val $InFiles) Fd)  In (val P))
         (when (== In (val $InFile))
            (set $Chr
               ((inFile (set $InFile (val (val $InFiles)))) chr) ) )   # Stdin
         (when In
            (let In: (inFile @)
               (free (In: name))
               (In: name null)
               (In: fd -1) ) ) ) ) )

(de void closeOutFile ((i32 . Fd))
   (when (> (val $OutFDs) Fd)
      (let (P (ofs (val $OutFiles) Fd)  Out (val P))
         (when (== Out (val $OutFile))
            (set $OutFile (val 2 (val $OutFiles))) )  # Stdout
         (when Out
            ((outFile @) fd -1) ) ) ) )

(local) (slow slowNb rdBytes rdBytesNb wrBytes clsChild wrChild flush flushAll)

(de i32 slow ((i8* . In))
   (let In: (inFile In)
      (In: ix 0)
      (loop
         (?
            (ge0
               (i32 (read (In: fd) (In: (buf)) BUFSIZ)) )
            (In: cnt @) )
         (? (<> (gErrno) EINTR)
            (In: cnt 0) )
         (sigChk 0) ) ) )

(de i32 slowNb ((i8* . In))
   (let In: (inFile In)
      (loop
         (let
            (Flg (nonBlocking (In: fd))
               N (i32 (read (In: fd) (In: (buf)) BUFSIZ)) )
            (fcntlSetFl (In: fd) Flg)
            (? (gt0 N)
               (In: ix 0)
               (In: cnt N) )
            (? (=0 N)
               (In: ix (In: cnt -1))
               0 ) )
         (? (== (gErrno) EAGAIN) -1)
         (? (<> @ EINTR)
            (In: ix (In: cnt 0)) )
         (sigChk 0) ) ) )

(de i1 rdBytes ((i32 . Fd) (i8* . P) (i32 . Cnt))
   (loop
      (loop
         (? (gt0 (i32 (read Fd P (i64 Cnt))))
            (inc 'P @)
            (dec 'Cnt @) )
         (unless (and @ (== (gErrno) EINTR))
            (ret NO) )
         (sigChk 0) )
      (? (=0 Cnt) YES) ) )

(de i64 rdBytesNb ((i32 . Fd) (i8* . P) (i32 . Cnt))
   (loop
      (let
         (Flg (nonBlocking Fd)
            N (i32 (read Fd P (i64 Cnt))) )
         (fcntlSetFl Fd Flg)
         (when (gt0 N)
            (loop
               (unless (dec 'Cnt N)
                  (ret 1) )
               (inc 'P N)
               (while
                  (le0
                     (setq N (i32 (read Fd P (i64 Cnt)))) )
                  (unless (and N (== (gErrno) EINTR))
                     (ret 0) )
                  (sigChk 0) ) ) )
         (? (=0 N) 0) )
      (? (== (gErrno) EAGAIN) -1)
      (? (<> @ EINTR) 0)
      (sigChk 0) ) )

(de i1 wrBytes ((i32 . Fd) (i8* . P) (i32 . Cnt))
   (loop
      (let N (i32 (write Fd P (i64 Cnt)))
         (if (lt0 N)
            (let E (gErrno)
               (? (== E EBADF) NO)
               (? (== E EPIPE) NO)
               (? (== E ECONNRESET) NO)
               (unless (== E EINTR)
                  (when (== Fd 2)  # Stderr
                     (bye 2) )
                  (writeErr ($ "bytes write: %s")) )
               (sigChk 0) )
            (? (=0 (dec 'Cnt N)) YES)
            (inc 'P N) ) ) ) )

(de void clsChild ((i8* . Cld))
   (let Cld: (child Cld)
      (when (== (Cld: pid) (val $Talking))
         (set $Talking 0) )
      (Cld: pid 0)
      (close (Cld: hear))
      (close (Cld: tell))
      (free (Cld: buf)) ) )

(de void wrChild ((i8* . Cld)  (i8* . P) (i32 . Cnt))
   (let (Cld: (child Cld)  C (Cld: cnt))
      (unless C
         (loop
            (let N (i32 (write (Cld: tell) P (i64 Cnt)))
               (if (lt0 N)
                  (let E (gErrno)
                     (? (== E EAGAIN))
                     (when (or (== E EPIPE) (== E ECONNRESET))
                        (clsChild Cld)
                        (ret) )
                     (unless (== E EINTR)
                        (writeErr ($ "child write: %s")) ) )
                  (unless (dec 'Cnt N)
                     (ret) )
                  (inc 'P N) ) ) ) )
      (let Siz (+ C Cnt 4)  # New buffer size
         (when (> Siz (hex "3FFFFFFF"))  # Allow max 1 GiB
            (sizeErr 0) )
         (let Q (ofs (Cld: buf (alloc (Cld: buf) (i64 Siz))) C)
            (set (i32* Q) Cnt)
            (memcpy (ofs Q 4) P (i64 Cnt))
            (Cld: cnt Siz) ) ) ) )

(de i1 flush ((i8* . Out))
   (ifn Out
      YES
      (let Out: (outFile Out)
         (ifn (Out: ix)
            YES
            (Out: ix 0)
            (wrBytes (Out: fd) (Out: (buf)) @) ) ) ) )

(de void flushAll ()
   (let (A (val $OutFiles)  N (val $OutFDs)  I (i32 0))
      (while (> N I)
         (flush (val (ofs A I)))
         (inc 'I) ) ) )

(local) (stdinByte getBinary binRead)

(de i32 stdinByte ()
   (let In: (inFile (val (val $InFiles)))  # Stdin
      (cond
         ((and
               (ge0 (In: fd))
               (or
                  (<> (In: ix) (In: cnt))
                  (and (ge0 @) (slow (In:))) ) )
            (let I (In: ix)
               (In: ix (+ I 1))
               (i32 (val (ofs (In: (buf)) I))) ) )
         ((In: tty) (bye 0))
         (T -1) ) ) )

(de i32 getBinary ()
   (let (In: (inFile (val $InFile))  I (In: ix))
      (when (== I (In: cnt))
         (when (or (lt0 I) (=0 (slow (In:))))  # Closed or EOF
            (ret -1) )
         (setq I 0) )
      (In: ix (+ I 1))
      (i32 (val (ofs (In: (buf)) I))) ) )

# Read binary PLIO expression
(de binRead ()
   (case (call $GetBin)
      (NIX $Nil)  # NIL
      (BEG
         (ifn (binRead)
            0
            (let (X (cons @ $Nil)  R (save X))
               (loop
                  (? (=0 (binRead)) @)
                  (? (== @ END) R)
                  (? (== @ -ZERO)  # DOT
                     (ifn (binRead)
                        0
                        (set 2 X (if (== @ END) R @))
                        R ) )
                  (setq X (set 2 X (cons @ $Nil))) ) ) ) )
      (DOT -ZERO)  # DOT -> -ZERO
      (END (i64 @))  # END
      (T
         (if (lt0 @)
            0  # EOF
            (let  # Atom
               (Tag (& @ 3)
                  Cnt (shr @ 2)
                  P (i64* (push NIL NIL ZERO NIL))  # [cnt last name link]
                  Q (link (ofs P 2)) )
               (cond
                  ((== Tag NUMBER)
                     (set P 3)  # 'cnt' for signed number
                     (when (== Cnt 63)  # More than one chunk
                        (loop
                           (loop
                              (when (lt0 (call $GetBin))
                                 (: 1
                                    (drop Q)
                                    (ret 0) ) )
                              (byteNum (i8 @) P)
                              (? (=0 (dec 'Cnt))) )
                           (when (lt0 (setq Cnt (call $GetBin)))
                              (goto 1) )
                           (? (<> Cnt 255)) )
                        (unless Cnt
                           (goto 2) ) )
                     (loop
                        (when (lt0 (call $GetBin))
                           (goto 1) )
                        (byteNum (i8 @) P)
                        (? (=0 (dec 'Cnt))) )
                     (: 2
                        (drop Q
                           (if (cnt? (val Q))
                              @
                              (let S (& (val (dig @)) 1)
                                 (| (half @) (shl S 3)) ) ) ) ) )
                  (T  # Symbol
                     (set P 4)  # 'cnt' for symbol name
                     (when (== Cnt 63)  # More than one chunk
                        (loop
                           (loop
                              (when (lt0 (call $GetBin))
                                 (goto 1) )
                              (byteSym (i8 @) P)
                              (? (=0 (dec 'Cnt))) )
                           (when (lt0 (setq Cnt (call $GetBin)))
                              (goto 1) )
                           (? (<> Cnt 255)) )
                        (unless Cnt
                           (goto 3) ) )
                     (loop
                        (when (lt0 (call $GetBin))
                           (goto 1) )
                        (byteSym (i8 @) P)
                        (? (=0 (dec 'Cnt))) )
                     (: 3
                        (drop Q
                           (let Nm (val Q)
                              (case Tag
                                 (TRANSIENT (consStr Nm))
                                 (INTERN (requestSym Nm))
                                 (T  # External
                                    (when (val $Extn)
                                       (let N
                                          (shl
                                             (& (i64 (+ (objFile Nm) @)) (hex "FFFF"))
                                             24 )  # Mask overflow
                                          (setq Nm
                                             (|
                                                (& Nm (hex "FFF00FFF00FFFFFF"))  # Mask object ID
                                                (&
                                                   (| N (shl N 12))
                                                   (hex "000FF000FF000000") ) ) ) ) )  # Mask file number
                                    (extern Nm) ) ) ) ) ) ) ) ) ) ) ) )

(local) (prCnt binPrint pr putTell prTell tellBeg tellEnd unsync)

# Binary print short number
(de void prCnt ((i8 . Tag) Num)
   (let N Num
      (while (setq N (shr N 8))
         (inc 'Tag 4) ) )
   (call $PutBin Tag)
   (loop
      (call $PutBin (i8 Num))
      (? (=0 (setq Num (shr Num 8)))) ) )

# Binary print expression
(de void binPrint (X)
   (cond
      ((cnt? X)
         (tailcall (prCnt (+ NUMBER 4) (shr X 3))) )
      ((big? X)
         (let (Y (pos X)  Z Y  N 8)
            (loop
               (let C (val (dig Z))
                  (? (cnt? (setq Z (val (big Z))))
                     (setq
                        Z (int Z)  # Normalize short
                        C (add C C)  # Get most significant bit of last digit
                        Z (add Z Z @@) ) )
                  (inc 'N 8) ) )
            (when Z  # Significant bits in short number
               (loop
                  (inc 'N)
                  (? (=0 (setq Z (shr Z 8)))) ) )
            (let (M (- N 63)  D (val (dig Y)))
               (when (ge0 M)
                  (setq N 63) )
               (setq Y (val (big Y)))
               (setq X (shr X X 4))  # Sign into highest bit
               (add X X)  # Keep in carry
               (setq D (add D D @@))
               (call $PutBin (i8 (shl N 2)))  # Output tag byte
               (let (S @@  C 8)
                  (loop
                     (loop
                        (call $PutBin (i8 D))  # Output next byte
                        (if (dec 'C)
                           (setq D (shr D 8))
                           (setq C 8)
                           (if (cnt? Y)
                              (setq D (int Y))
                              (setq
                                 D (val (dig Y))
                                 Y (val (big Y)) ) )
                           (setq
                              D (add D D S)
                              S @@ ) )
                        (? (=0 (dec 'N))) )
                     (? (lt0 M))
                     (? (=0 M) (call $PutBin 0))  # Output final zero
                     (when (ge0 (setq M (- (setq N M) 255)))
                        (setq N 255) )
                     (call $PutBin (i8 N)) ) ) ) ) )  # Output next chunk size
      ((nil? X) (call $PutBin NIX))
      ((pair X)
         (call $PutBin BEG)
         (let P (circ X)
            (ifn P
               (loop  # Non-circular
                  (binPrint (car X))
                  (? (nil? (shift X))
                     (call $PutBin END) )
                  (? (atom X)
                     (call $PutBin DOT)
                     (binPrint X) ) )
               (let Flg (== P X)  # Fully circular
                  (loop  # Non-circular part
                     (binPrint (car X))
                     (? (== P (shift X))) )
                  (call $PutBin DOT)
                  (unless Flg
                     (call $PutBin BEG)
                     (loop  # Circular part
                        (binPrint (car X))
                        (? (== P (shift X))) )
                     (call $PutBin DOT) )
                  (call $PutBin END) ) ) ) )
      ((sym? (val (tail X)))  # External symbol
         (let Nm (name (& @ -9))
            (when (val $Extn)
               (let N
                  (shl
                     (& (i64 (- (objFile Nm) @)) (hex "FFFF"))
                     24 )  # Mask overflow
                  (setq Nm
                     (|
                        (& Nm (hex "FFF00FFF00FFFFFF"))  # Mask object ID
                        (&
                           (| N (shl N 12))
                           (hex "000FF000FF000000") ) ) ) ) )  # Mask file number
            (tailcall
               (prCnt (+ EXTERN 4) (shr (shl Nm 2) 6)) ) ) )  # Strip status bits
      ((== (name @) ZERO) (call $PutBin NIX))
      (T
         (let
            (Nm @
               Tag
               (if (findSym X Nm (val $Intern))
                  (i8 INTERN)
                  (i8 TRANSIENT) ) )
            (if (cnt? Nm)
               (prCnt (+ Tag 4) (int Nm))
               (let (Y Nm  N 8)
                  (while (big? (setq Y (val (big Y))))
                     (inc 'N 8) )
                  (setq Y (int Y))
                  (while Y
                     (inc 'N)
                     (setq Y (shr Y 8)) )
                  (let (P (push 0 Nm)  M (- N 63)  C 8)  # [cnt name]
                     (when (ge0 M)
                        (setq N 63) )
                     (call $PutBin (+ Tag (i8 (shl N 2))))
                     (loop
                        (loop
                           (call $PutBin (symByte P))
                           (? (=0 (dec 'N))) )
                        (? (lt0 M))
                        (? (=0 M) (call $PutBin 0))
                        (when (ge0 (setq M (- (setq N M) 255)))
                           (setq N 255) )
                        (call $PutBin (i8 N)) ) ) ) ) ) ) ) )

(de void pr (X)
   (set $PutBin (fun (void i8) _putStdout))
   (tailcall (binPrint X)) )

(de void putTell ((i8 . B))
   (let P (val $Ptr)
      (set P B)
      (when (== (set $Ptr (inc P)) (val $End))
         (err 0 0 ($ "Tell PIPE_BUF") null) ) ) )

(de void prTell (X)
   (set
      $PutBin (fun (void i8) putTell)
      $Extn 0 )
   (tailcall (binPrint X)) )

(de void tellBeg ((i8* . P))
   (set
      $TellBuf P
      $End (ofs P (dec (val PipeBufSize)))
      (inc 'P 8) BEG  # 8 bytes space (PID and count)
      $Ptr (inc P) ) )  # Begin a list

(de void tellEnd ((i32 . Pid))
   (let (P (val $Ptr)  Q (val $TellBuf))
      (set P END)  # Close list
      (inc 'P)
      (let (D (i32 (- P Q))  N (- D 8))  # Size without PID and count
         (set
            (i32* Q) Pid
            (inc (i32* Q)) N )
         (when (val $Tell)
            (let Fd @
               (unless (wrBytes Fd Q D)
                  (close Fd)
                  (set $Tell 0) ) ) )
         (let
            (Cld (val $Child)  # Iterate children
               <Cld (ofs Cld (* (val $Children) (child T))) )
            (inc 'Q 8)
            (until (== Cld <Cld)
               (let Cld: (child Cld)
                  (when
                     (and
                        (Cld: pid)
                        (or (=0 Pid) (== Pid (Cld: pid))) )
                     (wrChild Cld Q N) ) )
               (setq Cld (ofs Cld (child T))) ) ) ) ) )

(de void unsync ()
   (when (val $Tell)
      (let Fd @
         (unless (wrBytes Fd (i8* (push 0)) 8)
            (close Fd)
            (set $Tell 0) ) ) )
   (set $Sync NO) )

(local) (waitFile currFd)

# Wait for pipe process if necessary
(de void waitFile ((i32 . Pid))
   (let Res (b32 1)
      (while (lt0 (waitpid Pid Res 0))
         (unless (== (gErrno) EINTR)
            (closeErr) )
         (sigChk 0) )
      (set $At2 (cnt (i64 (val Res)))) ) )

(de i32 currFd (Exe)
   (let (In (val $InFrames)  Out (val $OutFrames))
      (nond
         ((or In Out)
            (err Exe 0 ($ "No current fd") null) )
         (Out ((inFile ((ioFrame In) file)) fd))
         (In ((outFile ((ioFrame Out) file)) fd))
         (NIL
            (if
               (if (> In (stack))  # Assume stack is growing downwards
                  (> Out In)
                  (> In Out) )
               ((inFile ((ioFrame In) file)) fd)
               ((outFile ((ioFrame Out) file)) fd) ) ) ) ) )

(local) (pushInFile pushOutFile pushErrFile pushCtlFile)

(de void pushInFile ((i8* . Io) (i8* . In) (i32 . Pid))
   (let Io: (ioFrame Io)
      (when (val $InFile)
         ((inFile @) chr (val $Chr)) )
      (when (Io: link (val $InFrames))
         ((ioFrame @) fun (val (i8** $Get))) )
      (set $Get (fun (i32) _getStdin))
      (set $Chr
         ((inFile (Io: file (set $InFile In))) chr) )
      (Io: pid Pid)
      (set $InFrames (Io:)) ) )

(de void pushOutFile ((i8* . Io) (i8* . Out) (i32 . Pid))
   (let Io: (ioFrame Io)
      (when (Io: link (val $OutFrames))
         ((ioFrame @) fun (val (i8** $Put))) )
      (set $Put (fun (void i8) _putStdout))
      (Io: file (set $OutFile Out))
      (Io: pid Pid)
      (set $OutFrames (Io:)) ) )

(de void pushErrFile ((i8* . Ct))
   ((ctFrame Ct) link (val $ErrFrames))
   (set $ErrFrames Ct) )

(de void pushCtlFile ((i8* . Ct))
   ((ctFrame Ct) link (val $CtlFrames))
   (set $CtlFrames Ct) )

(local) (popInFiles tosInFile popOutFiles tosOutFile popErrFiles popCtlFiles)

(de void popInFiles ()
   (let (Io: (ioFrame (val $InFrames))  In: (inFile (Io: file)))
      (when (ge0 (In: fd))
         (ifn (Io: pid)
            (In: chr (val $Chr))
            (close (In: fd))
            (closeInFile (In: fd))
            (when (> (Io: pid) 1)
               (waitFile @) ) ) )
      (set $InFrames (Io: link)) ) )

(de void tosInFile ()
   (let Io: (ioFrame (val $InFrames))
      (set
         $Chr ((inFile (set $InFile (Io: file))) chr)
         (i8** $Get) (Io: fun) ) ) )

(de void popOutFiles ()
   (flush (val $OutFile))
   (let (Io: (ioFrame (val $OutFrames))  Out: (outFile (Io: file)))
      (when (ge0 (Out: fd))
         (when (Io: pid)
            (close (Out: fd))
            (closeOutFile (Out: fd))
            (when (> (Io: pid) 1)
               (waitFile @) ) ) )
      (set $OutFrames (Io: link)) ) )

(de void tosOutFile ()
   (let Io: (ioFrame (val $OutFrames))
      (set
         $OutFile (Io: file)
         (i8** $Put) (Io: fun) ) ) )

(de void popErrFiles ()
   (let Ct: (ctFrame (val $ErrFrames))
      (dup2 (Ct: fd) 2)  # Restore stderr
      (close (Ct: fd))
      (set $ErrFrames (Ct: link)) ) )

(de void popCtlFiles ()
   (let Ct: (ctFrame (val $CtlFrames))
      (if (ge0 (Ct: fd))
         (close @)
         (unLock (currFd 0) 0 0) )
      (set $CtlFrames (Ct: link)) ) )

# (path 'any) -> sym
(de _path (Exe)
   (let Nm (xName Exe (evSym (cdr Exe)))
      (mkStr (pathString Nm (b8 (pathSize Nm)))) ) )

(local) (pollfd hasData inReady waitFd)

(de i64* pollfd ((i32 . Fd))
   (let I (val $Nfds)
      (when (>= Fd I)
         (let P
            (set $Poll
               (i64*
                  (alloc
                     (i8* (val $Poll))
                     (* 8 #{pollfd}# (i64 (set $Nfds (+ Fd 1)))) ) ) )
            (loop
               (pollIgn (ofs P I))
               (? (== I Fd))
               (inc 'I) ) ) ) )
   (ofs (val $Poll) Fd) )

(de i1 hasData ((i32 . Fd))
   (and
      (> (val $InFDs) Fd)
      (val (ofs (val $InFiles) Fd))
      (let In: (inFile @)
         (and
            (ge0 (In: fd))
            (> (In: cnt) (In: ix)) ) ) ) )

(de i1 inReady ((i32 . Fd) (i1 . Flg))
   (let P (pollfd Fd)
      (cond
         ((>= Fd (val $InFDs))
            (readyIn P) )
         ((=0 (val (ofs (val $InFiles) Fd)))
            (readyIn P) )
         (T
            (let In: (inFile @)
               (if (lt0 (In: fd))
                  (readyIn P)
                  (or
                     (> (In: cnt) (In: ix))
                     (and
                        (readyIn P)
                        (or Flg (ge0 (slowNb (In:)))) ) ) ) ) ) ) ) )

(de i64 waitFd (Exe (i32 . Fd) (i64 . Ms))
   (let
      (Run (save (val $Run))
         At (save (val $At))
         Buf (b8 (val PipeBufSize))
         Pn (b32 2)
         Tim (getMsec) )
      (stkChk Exe)
      (loop
         (let Dly Ms
            (when (ge0 Fd)
               (if (hasData Fd)
                  (setq Dly 0)
                  (pollIn Fd (pollfd Fd)) ) )
            (let R Run  # '*Run' elements
               (while (pair R)
                  (let X (++ R)
                     (cond
                        ((sign? (car X))
                           (let N (int (cadr X))
                              (when (> Dly N)
                                 (setq Dly N) ) ) )
                        ((<> (i32 (int @)) Fd)
                           (let N @
                              (if (hasData N)
                                 (setq Dly 0)
                                 (pollIn N (pollfd N)) ) ) ) ) ) ) )
            (when (and (val $Hear) (<> @ Fd))  # RPC listener
               (let N @
                  (if (hasData N)
                     (setq Dly 0)
                     (pollIn N (pollfd N)) ) ) )
            (when (val $Spkr)  # RPC speaker
               (pollIn @ (pollfd @))
               (let
                  (Cld (val $Child)  # Iterate children
                     <Cld (ofs Cld (* (val $Children) (child T))) )
                  (until (== Cld <Cld)
                     (let Cld: (child Cld)
                        (when (Cld: pid)
                           (pollIn (Cld: hear) (pollfd (Cld: hear)))
                           (when (Cld: cnt)
                              (pollOut (Cld: tell) (pollfd (Cld: tell))) ) ) )
                     (setq Cld (ofs Cld (child T))) ) ) )
            (while (lt0 (gPoll (val $Poll) (val $Nfds) Dly))
               (unless (== (gErrno) EINTR)
                  (set $Run $Nil)
                  (selectErr Exe) )
               (sigChk Exe) ) )
         (let (Now (getMsec)  Dif (- Now Tim))
            (when (val $Spkr)  # RPC speaker
               (set $Protect (inc (val $Protect)))
               (let
                  (Cld (val $Child)  # Iterate children
                     <Cld (ofs Cld (* (val $Children) (child T))) )
                  (until (== Cld <Cld)
                     (let Cld: (child Cld)
                        (when (Cld: pid)
                           (when (readyIn (pollfd (Cld: hear)))
                              (cond
                                 ((=0 (rdBytesNb (Cld: hear) (i8* Pn) (* 2 4)))
                                    (clsChild Cld)
                                    (goto 1) )
                                 ((gt0 @)
                                    (cond
                                       ((=0 (val (i64* Pn)))  # PID and size are zero
                                          (when (== (Cld: pid) (val $Talking))
                                             (set $Talking 0) ) )
                                       ((> (val 2 Pn) (val PipeBufSize))
                                          (sizeErr Exe) )
                                       ((rdBytes (Cld: hear) Buf @)
                                          (let
                                             (Cld2 (val $Child)  # Iterate children
                                                <Cld2 (ofs Cld2 (* (val $Children) (child T))) )
                                             (until (== Cld2 <Cld2)
                                                (let Cld2: (child Cld2)
                                                   (when
                                                      (and
                                                         (<> Cld Cld2)
                                                         (Cld2: pid)
                                                         (or (=0 (val Pn)) (== @ (Cld2: pid))) )
                                                      (wrChild Cld2 Buf (val 2 Pn)) ) )
                                                (setq Cld2 (ofs Cld2 (child T))) ) ) )
                                       (T
                                          (clsChild Cld)
                                          (goto 1) ) ) ) ) )
                           (when (readyOut (pollfd (Cld: tell)))
                              (let
                                 (P (ofs (Cld: buf) (Cld: ofs))  # Buffer pointer plus offset
                                    N (val (i32* P)) )  # Size
                                 (ifn (wrBytes (Cld: tell) (ofs P 4) N)
                                    (clsChild Cld)
                                    (setq N (Cld: ofs (+ (Cld: ofs) N 4)))  # Add size plus size of size to buffer offset
                                    (when (>= (* 2 N) (Cld: cnt))
                                       (when (Cld: cnt (- (Cld: cnt) N))
                                          (memcpy
                                             (Cld: buf)
                                             (ofs (Cld: buf) N)
                                             (i64 (Cld: cnt)) )
                                          (Cld: buf (alloc (Cld: buf) (i64 (Cld: cnt)))) )
                                       (Cld: ofs 0) ) ) ) ) ) )
                     (: 1
                        (setq Cld (ofs Cld (child T))) ) ) )
               (when
                  (and
                     (=0 (val $Talking))
                     (readyIn (pollfd (val $Spkr)))
                     (gt0 (rdBytesNb (val $Spkr) (i8* Pn) 4)) )  # Slot
                  (let Cld (ofs (val $Child) (* (val Pn) (child T)))
                     (when ((child Cld) pid)
                        (set $Talking @)
                        (wrChild Cld $TBuf 2) ) ) )
               (set $Protect (dec (val $Protect))) )
            (let N (val $Hear)  # RPC listener
               (when (and N (<> N Fd) (inReady N NO))
                  (let In (val $InFile)
                     (set
                        $InFile (val (ofs (val $InFiles) (val $Hear)))
                        $GetBin (fun (i32) getBinary)
                        $Extn 0 )
                     (let E (binRead)
                        (cond
                           ((=0 E)
                              (close N)
                              (closeInFile N)
                              (closeOutFile N)
                              (set $Hear 0) )
                           ((t? E) (set $Sync YES))
                           (T (save E (evList E))) ) )
                     (set $InFile In) ) ) )
            (let R Run
               (while (pair R)
                  (let X (++ R)
                     (cond
                        ((sign? (car X))
                           (let Y (cdr X)
                              (if (gt0 (- (int (car Y)) Dif))  # Not yet timed out
                                 (set Y (sign (cnt @)))   # Store short negative number
                                 (let V (car X)  # Timeout value
                                    (set Y (pos V)  $At V)
                                    (run (cdr Y)) ) ) ) )  # Run body
                        ((<> (i32 (int @)) Fd)
                           (when (inReady @ NO)
                              (set $At (car X))  # File descriptor
                              (run (cdr X)) ) ) ) ) ) )  # Run body
            (and
               (gt0 Ms)
               (lt0 (dec 'Ms Dif))
               (setq Ms 0) )
            (setq Tim Now) )
         (sigChk Exe)
         (? (or (=0 Ms) (lt0 Fd) (inReady Fd YES)))
         (setq Run (safe (val $Run))) )
      (set $At At)
      Ms ) )

# (wait 'cnt|NIL . prg) -> any
# (wait 'cnt|NIL T 'fd) -> fd|NIL
(de _wait (Exe)
   (let
      (X (cdr Exe)
         N
         (if (nil? (eval (++ X)))
            292MY
            (xCnt Exe @) ) )
      (if (t? (car X))
         (let Fd (evCnt Exe (cdr X))  # Wait for file descriptor
            (if (waitFd Exe (i32 Fd) N)
               (cnt Fd)
               $Nil ) )
         (loop
            (? (not (nil? (run X))) @)  # 'prg'
            (? (=0 (waitFd Exe -1 N)) (run X))  # Timeout
            (setq N @) ) ) ) )

# (sync) -> flg
(de _sync (Exe)
   (cond
      ((or (=0 (val $Mic)) (=0 (val $Hear)))
         $Nil )
      ((val $Sync) $T)
      (T
         (let (Mic (val $Mic)  P (i8* $Slot)  Cnt 4)
            (loop
               (let N (write Mic P Cnt)
                  (cond
                     ((ge0 N)
                        (? (=0 (dec 'Cnt N)))
                        (setq P (ofs P N)) )
                     ((== (gErrno) EINTR) (sigChk Exe))
                     (T (writeErr ($ "sync write: %s"))) ) ) ) )
         (set $Sync NO)
         (loop
            (waitFd Exe -1 292MY)
            (? (val $Sync)) )
         $T ) ) )

# (hear 'cnt) -> cnt
(de _hear (Exe)
   (let
      (X (eval (cadr Exe))
         Fd (i32 (xCnt Exe X)) )
      (when
         (or
            (lt0 Fd)
            (>= Fd (val $InFDs))
            (=0 (val (ofs (val $InFiles) Fd)))
            (lt0 ((inFile @) fd)) )
         (badFd Exe X) )
      (when (val $Hear)
         (close @)
         (closeInFile @)
         (closeOutFile @) )
      (set $Hear Fd)
      X ) )

# (tell ['cnt] 'sym ['any ..]) -> any
(de _tell (Exe)
   (cond
      ((and (=0 (val $Tell)) (=0 (val $Children)))
         $Nil )
      ((atom (cdr Exe))
         (unsync)
         $Nil )
      (T
         (let (X @  Y (eval (car X))  Pid (i32 0))
            (when (cnt? Y)
               (setq
                  Pid (i32 (int @))
                  Y (eval (car (shift X))) ) )
            (let (TellBuf (val $TellBuf)  Ptr (val $Ptr)  End (val $End))
               (tellBeg (b8 (val PipeBufSize)))
               (stkChk Exe)
               (loop
                  (prTell Y)
                  (? (atom (shift X)))
                  (setq Y (eval (car X))) )
               (tellEnd Pid)
               (set $TellBuf TellBuf  $Ptr Ptr  $End End)
               Y ) ) ) ) )

# (poll 'cnt) -> cnt | NIL
(de _poll (Exe)
   (let
      (C (eval (cadr Exe))
         Fd (i32 (xCnt Exe C)) )
      (when (or (lt0 Fd) (>= Fd (val $InFDs)))
         (badFd Exe C) )
      (let In: (inFile (val (ofs (val $InFiles) Fd)))
         (ifn (and (In:) (ge0 (In: fd)))
            $Nil
            (let Poll (b64 1)
               (pollIn Fd Poll)
               (loop
                  (? (> (In: cnt) (In: ix)) C)
                  (while (lt0 (gPoll Poll 1 0))
                     (unless (== (gErrno) EINTR)
                        (selectErr Exe) ) )
                  (? (not (readyIn Poll)) $Nil)
                  (? (ge0 (slowNb (In:))) C) ) ) ) ) ) )

(local) (rdOpen wrOpen erOpen ctOpen)

(de void rdOpen (Exe X (i8* . Io))
   (cond
      ((nil? X)
         (pushInFile Io (val (val $InFiles)) 0) )  # Stdin
      ((num? X)
         (let N (i32 (int X))
            (pushInFile Io
               (cond
                  ((sign? X)
                     (let In (val $InFrames)
                        (loop
                           (unless (setq In ((ioFrame In) link))
                              (badFd Exe X) )
                           (? (=0 (dec 'N))) )
                        ((ioFrame In) file) ) )
                  ((>= N (val $InFDs))
                     (badFd Exe X) )
                  ((=0 (val (ofs (val $InFiles) N)))
                     (badFd Exe X) )
                  (T @) )
               0 ) ) )
      ((sym? X)
         (let
            (Nm (xName Exe X)
               S (pathString Nm (b8 (pathSize Nm)))
               Flg (== (val S) (char "+"))
               Fd T )
            (when Flg
               (setq S (ofs S 1)) )
            (while (lt0 (setq Fd (if Flg (openRdWrAppend S) (openRd S))))
               (unless (== (gErrno) EINTR)
                  (openErr Exe X) )
               (sigChk Exe) )
            (closeOnExec Exe Fd)
            (pushInFile Io (initInFile Fd (strdup S)) 1) ) )
      (T  # Pipe
         (let
            (Pfd (b32 2)
               Av (b8* (inc (length X)))
               Cmd (xName Exe (xSym (car X))) )
            (when (lt0 (pipe Pfd))
               (pipeErr Exe) )
            (set Av (pathString Cmd (b8 (pathSize Cmd))))
            (let A Av
               (while (pair (shift X))
                  (let Nm (xName Exe (xSym (car X)))
                     (set (inc 'A)
                        (bufString Nm (b8 (bufSize Nm))) ) ) )
               (set (inc 'A) null) )
            (cond
               ((lt0 (fork)) (forkErr Exe))
               ((=0 @)  # In child
                  (setpgid 0 0)  # Set process group
                  (close (val Pfd))  # Close read pipe
                  (unless (== (val 2 Pfd) 1)
                     (dup2 @ 1)  # Dup write pipe to STDOUT_FILENO
                     (close @) )
                  (signal (val SIGPIPE Sig) (val SigDfl))  # Default SIGPIPE
                  (execvp (val Av) Av)  # Execute program
                  (execErr (val Av)) ) )  # Error if failed
            # In parent
            (let (Pid @  Fd (val Pfd))
               (setpgid Pid 0)  # Set process group
               (close (val 2 Pfd))  # Close write pipe
               (closeOnExec Exe Fd)
               (pushInFile Io (initInFile Fd null) Pid) ) ) ) ) )

(de void wrOpen (Exe X (i8* . Io))
   (cond
      ((nil? X)
         (pushOutFile Io (val 2 (val $OutFiles)) 0) )  # Stdout
      ((num? X)
         (let N (i32 (int X))
            (pushOutFile Io
               (cond
                  ((sign? X)
                     (let Out (val $OutFrames)
                        (loop
                           (unless (setq Out ((ioFrame Out) link))
                              (badFd Exe X) )
                           (? (=0 (dec 'N))) )
                        ((ioFrame Out) file) ) )
                  ((>= N (val $OutFDs))
                     (badFd Exe X) )
                  ((=0 (val (ofs (val $OutFiles) N)))
                     (badFd Exe X) )
                  (T @) )
               0 ) ) )
      ((sym? X)
         (let
            (Nm (xName Exe X)
               S (pathString Nm (b8 (pathSize Nm)))
               Flg (== (val S) (char "+"))
               Fd T )
            (when Flg
               (setq S (ofs S 1)) )
            (while (lt0 (setq Fd (if Flg (openWrAppend S) (openWr S))))
               (unless (== (gErrno) EINTR)
                  (openErr Exe X) )
               (sigChk Exe) )
            (closeOnExec Exe Fd)
            (pushOutFile Io (initOutFile Fd) 1) ) )
      (T  # Pipe
         (let
            (Pfd (b32 2)
               Av (b8* (inc (length X)))
               Cmd (xName Exe (xSym (car X))) )
            (when (lt0 (pipe Pfd))
               (pipeErr Exe) )
            (set Av (pathString Cmd (b8 (pathSize Cmd))))
            (let A Av
               (while (pair (shift X))
                  (let Nm (xName Exe (xSym (car X)))
                     (set (inc 'A)
                        (bufString Nm (b8 (bufSize Nm))) ) ) )
               (set (inc 'A) null) )
            (cond
               ((lt0 (fork)) (forkErr Exe))
               ((=0 @)  # In child
                  (setpgid 0 0)  # Set process group
                  (close (val 2 Pfd))  # Close write pipe
                  (when (val Pfd)  # STDIN_FILENO
                     (dup2 @ 0)  # Dup read pipe to STDIN_FILENO
                     (close @) )
                  (execvp (val Av) Av)  # Execute program
                  (execErr (val Av)) ) )  # Error if failed
            # In parent
            (let (Pid @  Fd (val 2 Pfd))
               (setpgid Pid 0)  # Set process group
               (close (val Pfd))  # Close read pipe
               (closeOnExec Exe Fd)
               (pushOutFile Io (initOutFile Fd) Pid) ) ) ) ) )

(de void erOpen (Exe X (i8* . Ct))
   (let Ct: (ctFrame Ct)
      (Ct: fd (dup 2))  # Stderr
      (let Fd
         (if (nil? (needSymb Exe X))
            (dup ((outFile (val $OutFile)) fd))
            (let
               (Nm (xName Exe X)
                  S (pathString Nm (b8 (pathSize Nm)))
                  Flg (== (val S) (char "+")) )
               (when Flg
                  (setq S (ofs S 1)) )
               (while (lt0 (if Flg (openWrAppend S) (openWr S)))
                  (unless (== (gErrno) EINTR)
                     (openErr Exe X) )
                  (sigChk Exe) )
               (closeOnExec Exe @)
               @ ) )
         (dup2 Fd 2)
         (close Fd) )
      (pushErrFile Ct) ) )

(de void ctOpen (Exe X (i8* . Ct))
   (let Ct: (ctFrame Ct)
      (cond
         ((nil? (needSymb Exe X))
            (Ct: fd -1)
            (rdLockWait (currFd Exe) 0) )
         ((t? X)
            (Ct: fd -1)
            (wrLockWait (currFd Exe) 0) )
         (T
            (let
               (Nm (xName Exe X)
                  S (pathString Nm (b8 (pathSize Nm)))
                  Flg (== (val S) (char "+")) )
               (when Flg
                  (setq S (ofs S 1)) )
               (while (lt0 (openRdWrCreate S))
                  (unless (== (gErrno) EINTR)
                     (openErr Exe X) )
                  (sigChk Exe) )
               (let Fd (Ct: fd @)
                  (if Flg
                     (rdLockWait Fd 0)
                     (wrLockWait Fd 0) )
                  (closeOnExec Exe Fd) ) ) ) )
      (pushCtlFile Ct) ) )

(local) (read0 getChar skipc comment skip testEsc anonymous rdAtom rdl rdList)

(de read0 (i1))

(de i32 rlGetc ((i8* . F))
   (if (waitFd 0 0 292MY)
      (stdinByte)
      -1 ) )

(de i32 rlAvail ()
   (i32 (waitFd 0 0 60)) )

(de i32 _getStdin ()
   (let In: (inFile (val $InFile))
      (set $Chr
         (cond
            ((lt0 (In: fd)) -1)  # EOF
            ((or (In: fd) (not (In: tty)))  # Not stdin
               (if
                  (and
                     (== (In: ix) (In: cnt))
                     (or (lt0 (In: ix)) (=0 (slow (In:)))) )
                  -1
                  (let I (In: ix)
                     (prog1
                        (i32 (val (ofs (In: (buf)) I)))
                        (when (== @ (char "\n"))
                           (In: line (+ (In: line) 1)) )
                        (In: ix (+ I 1)) ) ) ) )
            (T
               (let P (val $LinePtr)
                  (unless P
                     (when (val $LineBuf)
                        (free @)
                        (set $LineBuf null) )
                     (flushAll)
                     (unless (setq P (set $LineBuf (gReadline (val $LinePrmt))))
                        (wrnl)
                        (when (or (val $Bind) (== (val $LinePrmt) (val $ContPrmt)))
                           (err 0 0 $Empty null) )  # quit
                        (bye 0) )
                     (set $LinePrmt (val $ContPrmt))
                     (unless
                        (or
                           (=0 (val P))
                           (== @ 32)
                           (and
                              (== @ (char "."))
                              (=0 (val (inc P))) )
                           (and (currentLine) (=0 (strcmp @ P))) )
                        (add_history P) ) )
                  (nond
                     ((val P)
                        (set $LinePtr null)
                        (char "\n") )
                     (NIL
                        (set $LinePtr (inc P))
                        (i32 @) ) ) ) ) ) ) ) )

(de i32 getChar ((i32 . C))
   (cond
      ((>= 127 C) C)  # Single byte
      ((== C (hex "FF")) (i32 TOP))  # Infinite
      (T
         (let B
            (ifn (& C (hex "20"))  # Two bytes
               (& C (hex "1F"))  # First byte 110xxxxx
               (let A
                  (ifn (& C (hex "10"))  # Three bytes
                     (& C (hex "0F"))  # First byte 1110xxxx
                     (|  # Four bytes
                        (shl (& C 7) 6)  # First byte 11110xxx
                        (& (call $Get) (hex "3F")) ) )  # 10xxxxxx
                  (| (shl A 6) (& (call $Get) (hex "3F"))) ) )
            (| (shl B 6) (& (call $Get) (hex "3F"))) ) ) ) )

# Skip White Space and Comments
(de i32 skipc ((i32 . C))
   (let Chr (val $Chr)
      (loop
         (while (>= 32 Chr)  # White space
            (when (lt0 (setq Chr (call $Get)))
               (ret Chr) ) )
         (unless (== Chr C)
            (ret Chr) )
         (until (== (setq Chr (call $Get)) (char "\n"))
            (when (lt0 Chr)
               (ret Chr) ) )
         (setq Chr (call $Get)) ) ) )

(de void comment ()
   (let Chr (call $Get)
      (if (== Chr (char "{"))
         (let N 0
            (loop
               (? (lt0 (setq Chr (call $Get))))
               (if
                  (and
                     (== Chr (char "#"))
                     (== (setq Chr (call $Get)) (char "{")) )
                  (inc 'N)
                  (?
                     (and
                        (== Chr (char "}"))
                        (== (setq Chr (call $Get)) (char "#"))
                        (lt0 (dec 'N)) ) ) ) ) )
         (until (== Chr (char "\n"))
            (? (lt0 Chr))
            (setq Chr (call $Get)) ) )
      (call $Get) ) )

(de i32 skip ()
   (loop
      (let Chr (val $Chr)
         (when (lt0 Chr)
            (ret Chr) )
         (while (>= (char " ") Chr)
            (when (lt0 (setq Chr (call $Get)))
               (ret Chr) ) )
         (unless (== Chr (char "#"))
            (ret Chr) )
         (comment) ) ) )

(de i1 testEsc ((i32 . Chr))
   (loop
      (? (lt0 Chr) NO)
      (? (== Chr (char "\^"))  # Control character
         (when (== (setq Chr (call $Get)) (char "@"))
            (badInput) )
         (set $Chr
            (if (== Chr (char "?"))
               127
               (& Chr (hex "1F")) ) )
         YES )
      (? (<> Chr (char "\\"))  # No Backslash
         (set $Chr (getChar Chr))
         YES )
      (? (<> (char "\n") (setq Chr (call $Get)))  # Backslash: Skip '\'
         (case Chr
            ((char "b") (set $Chr (char "\b")))
            ((char "e") (set $Chr (char "\e")))
            ((char "n") (set $Chr (char "\n")))
            ((char "r") (set $Chr (char "\r")))
            ((char "t") (set $Chr (char "\t")))
            (T
               (when (and (>= Chr (char "0")) (>= (char "9") Chr))
                  (dec 'Chr (char "0"))
                  (until (== (call $Get) (char "\\"))
                     (unless
                        (and
                           (>= (val $Chr) (char "0"))
                           (>= (char "9") (val $Chr)) )
                        (badInput) )
                     (setq Chr
                        (+ (* Chr 10) (- (val $Chr) (char "0"))) ) ) )
               (set $Chr Chr) ) )
         YES )
      (loop
         (setq Chr (call $Get))
         (?
            (and
               (<> Chr (char " "))
               (<> Chr (char "\t")) ) ) ) ) )

(de anonymous (Nm)
   (let P (push 0 Nm)  # [cnt name]
      (unless (== (symByte P) (char "$"))  # Starting with '$'
         (ret 0) )
      (let B (- (symByte P) (char "0"))
         (unless (>= 7 B)  # Octal Digit
            (ret 0) )
         (let N (i64 B)
            (loop
               (? (=0 (symByte P))
                  (sym (shl N 4)) )  # Make symbol pointer
               (? (> (- @ (char "0")) 7) 0)
               (setq N (| (i64 @) (shl N 3))) ) ) ) ) )

(de rdAtom ((i32 . Chr))
   (let
      (Int (save (val $Intern))  # Current symbol namespaces
         P (push 4 NIL ZERO NIL)  # [cnt last name link]
         C (val $Chr) )
      (when
         (and
            (== Chr (char "%"))
            (== C (char "~")) )
         (when (nil? (cdr Int))
            (symNspErr 0 $rem) )
         (set $Intern @)
         (setq Chr (call $Get)  C (call $Get)) )
      (link (ofs P 2))
      (byteSym (i8 Chr) P)  # Pack first byte
      (setq Chr C)
      (while (ge0 Chr)
         (if (== Chr (char "~"))  # Namespace
            (let S (requestSym (val 3 P))  # Find or create symbol
               (needNsp 0 S)
               (set (set $Intern (any $Cell)) S)  # Switch symbol namespace
               (set P 4  3 P ZERO) )  # Build new name
            (? (strchr $Delim Chr))
            (when (== Chr (char "\\"))
               (setq Chr (call $Get)) )
            (byteSym (i8 Chr) P) )
         (setq Chr (call $Get)) )
      (prog1
         (let (Nm (val 3 P)  L (val $Intern))
            (cond
               ((== Nm ZERO) (badInput))
               ((== L (any $Cell))
                  (intern 0 $Nil Nm (cdar (car @)) $Nil NO) )
               ((symToNum Nm (int (val $Scl)) (char ".") 0) @)
               ((anonymous Nm) @)
               ((and (== (car L) $priv) (nil? (cdr L)))
                  (intern (consSym Nm $Nil) 0 Nm $PrivT $Nil YES) )
               (T (requestSym Nm)) ) )
         (set $Intern Int) ) ) )

(de void rdl (R P)
   (loop
      (? (== (skip) (char ")"))
         (call $Get) )
      (? (== @ (char "]")))
      (cond
         ((== @ (char "."))
            (? (strchr $Delim (call $Get))
               (setq P
                  (set 2 P
                     (if
                        (or
                           (== (skip) (char ")"))
                           (== @ (char "]")) )
                        R
                        (read0 NO) ) ) )
               (cond
                  ((== (skip) (char ")"))
                     (call $Get) )
                  ((<> (val $Chr) (char "]"))
                     (err 0 P ($ "Bad dotted pair") null) ) ) )
            (setq P
               (set 2 P (cons (rdAtom (char ".")) $Nil)) ) )
         ((== @ (char "~"))
            (call $Get)
            (let (X (save (read0 NO))  R (eval X))
               (cond
                  ((nil? R))
                  ((atom R)
                     (set 2 P (cons R $Nil))
                     (shift P) )
                  (T
                     (set 2 P R)
                     (while (pair (cdr P))
                        (shift P) ) ) ) ) )
         (T
            (setq P
               (set 2 P (cons (read0 NO) $Nil)) ) ) ) ) )

(de rdList ()
   (stkChk 0)
   (call $Get)
   (loop
      (? (== (skip) (char ")"))  # Empty list
         (call $Get)
         $Nil )
      (? (== @ (char "]")) $Nil)  # Empty list
      (? (<> @ (char "~"))  # Read macro
         (let R (save (cons (read0 NO) $Nil))
            (rdl R R)
            R ) )
      (call $Get)
      (let (X (save (read0 NO))  R (eval X))
         (? (not (nil? R))
            (if (atom (safe R))
               (rdl (safe (setq R (cons R $Nil))) R)
               (let L R
                  (while (pair (cdr L))
                     (setq L @) )
                  (rdl R L) ) )
            R ) ) ) )

(de read0 ((i1 . Top))
   (let C (skip)
      (when Top
         (let In: (inFile (val $InFile))
            (In: src (In: line)) ) )
      (cond
         ((lt0 C)
            (unless Top (eofErr))
            $Nil )
         ((== C (char "("))
            (prog1
               (rdList)
               (and
                  Top
                  (== (val $Chr) (char "]"))
                  (call $Get) ) ) )
         ((== C (char "["))
            (let X (rdList)
               (unless (== (val $Chr) (char "]"))
                  (err 0 X ($ "Super parentheses mismatch") null) )
               (call $Get)
               X ) )
         ((== C (char "'"))
            (call $Get)
            (cons $Quote (read0 Top)) )
         ((== C (char ","))
            (call $Get)
            (let
               (Tr1 (save (val $Transient))
                  Tr2 (save (val 2 $Transient)) )
               (set $Transient (set 2 $Transient $Nil))
               (prog1
                  (let X (read0 Top)
                     (if (t? (val $Uni))
                        X
                        (save X
                           (if (pair (idxPut $Uni X))
                              (car @)
                              X ) ) ) )
                  (set 2 $Transient Tr2)
                  (set $Transient Tr1) ) ) )
         ((== C (char "`"))
            (call $Get)
            (let E (read0 Top)
               (save E
                  (eval E) ) ) )
         ((== C (char "\""))
            (if (== (setq C (call $Get)) (char "\""))
               (prog (call $Get) $Nil)  # Empty string
               (unless (testEsc C) (eofErr))
               (let
                  (P (push 4 NIL ZERO NIL)  # [cnt last name link]
                     Q (link (ofs P 2)) )
                  (loop
                     (charSym (val $Chr) P)
                     (? (== (setq C (call $Get)) (char "\"")))
                     (unless (testEsc C) (eofErr)) )
                  (call $Get)  # Skip "\""
                  (drop Q
                     (intern 0 0 (val Q) $Transient $Nil NO) ) ) ) )
         ((== C (char "{"))
            (prog1
               (if (== (setq C (call $Get)) (char "}"))
                  (consSym ZERO $Nil)  # Empty: New anonymous symbol
                  (let F (i32 0)  # File number
                     (while (>= C (char "@"))
                        (when (> C (char "O"))  # A-O range
                           (badInput) )
                        (setq
                           F (| (shl F 4) (- C (char "@")))
                           C (call $Get) ) )
                     (let N 0  # Id
                        (loop
                           (unless (and (>= C (char "0")) (>= (char "7") C))
                              (badInput) )
                           (setq N
                              (|
                                 (shl N 3)
                                 (i64 (- C (char "0"))) ) )
                           (? (== (setq C (call $Get)) (char "}"))) )
                        (extern (extNm F N)) ) ) )
               (call $Get) ) )  # Skip "}"
         ((or (== C (char ")")) (== C (char "]")) (== C (char "~")))
            (badInput) )
         (T
            (when (== C (char "\\"))
               (call $Get) )
            (setq C (val $Chr))
            (call $Get)
            (rdAtom C) ) ) ) )

(local) (read1 noToken token)

(de read1 ((i32 . End))
   (unless (val $Chr)
      (call $Get) )
   (if (== End (val $Chr))
      $Nil
      (read0 YES) ) )

(inline noToken (C Set)
   (not
      (or
         (== C (char "\\"))
         (and (>= (char "z") C) (>= C (char "a")))
         (and (>= (char "Z") C) (>= C (char "A")))
         (strchr Set C) ) ) )

(de token (Set (i32 . Cmt))
   (let C (val $Chr)
      (unless C
         (setq C (call $Get)) )
      (cond
         ((lt0 (skipc Cmt)) 0)  # Skip white space and comments
         ((== (setq C @) (char "\""))
            (cond
               ((== (setq C (call $Get)) (char "\""))  # Empty string
                  (call $Get)
                  $Nil )
               ((not (testEsc C)) $Nil)
               (T
                  (let
                     (Y (cons (mkChar (val $Chr)) $Nil)
                        R (save Y) )
                     (loop
                        (? (== (setq C (call $Get)) (char "\""))
                           (call $Get) )  # Skip "\""
                        (? (not (testEsc C)))
                        (setq Y
                           (set 2 Y (cons (mkChar (val $Chr)) $Nil)) ) )
                     R ) ) ) )
         ((and (>= (char "9") C) (>= C (char "0")))
            (let P (push 4 NIL ZERO NIL)  # [cnt last name link]
               (link (ofs P 2) T)
               (loop
                  (byteSym (i8 C) P)
                  (?
                     (and
                        (<> (setq C (call $Get)) (char "."))
                        (or (> (char "0") C) (> C (char "9"))) ) ) )
               (symToNum
                  (val 3 P)
                  (int (val $Scl))
                  (char ".")
                  0 ) ) )
         (T
            (let
               (Nm (xName 0 Set)
                  S (bufString Nm (b8 (bufSize Nm))) )
               (if
                  (or
                     (== C (char "+"))
                     (== C (char "-"))
                     (noToken C S) )
                  (prog1
                     (mkChar (getChar C))
                     (call $Get) )
                  (when (== C (char "\\"))
                     (call $Get) )
                  (let P (push 4 NIL ZERO NIL)  # [cnt last name link]
                     (link (ofs P 2) T)
                     (loop
                        (byteSym (i8 C) P)
                        (?
                           (and
                              (noToken (setq C (call $Get)) S)
                              (or (> (char "0") C) (> C (char "9"))) ) )
                        (when (== C (char "\\"))
                           (call $Get) ) )
                     (requestSym (val 3 P)) ) ) ) ) ) ) )

# (read ['sym1 ['sym2]]) -> any
(de _read (Exe)
   (let X (cdr Exe)
      (prog1
         (if (atom X)
            (read1 0)
            (let Y (save (needSymb Exe (eval (++ X))))
               (if (token Y (firstChar (needSymb Exe (eval (car X)))))
                  @
                  $Nil ) ) )
         (and
            (== (val $Chr) (char "\n"))
            (== (val $InFile) (val (val $InFiles)))  # Stdin
            (set $Chr 0) ) ) ) )

# (key ['cnt]) -> sym
(de _key (Exe)
   (flushAll)
   (let Raw (val Termio)
      (prog2
         (setRaw)
         (if
            (waitFd Exe 0
               (if (nil? (eval (cadr Exe)))
                  292MY
                  (xCnt Exe @) ) )
            (let C (stdinByte)
               (mkChar
                  (cond
                     ((>= 127 C) C)  # Single byte
                     ((== C (hex "FF")) (i32 TOP))  # Infinite
                     (T
                        (let B
                           (ifn (& C (hex "20"))  # Two bytes
                              (& C (hex "1F"))  # First byte 110xxxxx
                              (let A
                                 (ifn (& C (hex "10"))  # Three bytes
                                    (& C (hex "0F"))  # First byte 1110xxxx
                                    (|  # Four bytes
                                       (shl (& C 7) 6)  # First byte 11110xxx
                                       (& (stdinByte) (hex "3F")) ) )  # 10xxxxxx
                                 (| (shl A 6) (& (stdinByte) (hex "3F"))) ) )
                           (| (shl B 6) (& (stdinByte) (hex "3F"))) ) ) ) ) )
            $Nil )
         (unless Raw
            (setCooked) ) ) ) )

# (peek) -> sym
(de _peek (Exe)
   (let Chr (val $Chr)
      (unless Chr
         (setq Chr (call $Get)) )
      (if (lt0 Chr) $Nil (mkChar Chr)) ) )

# (char) -> sym
# (char 'cnt) -> sym
# (char T) -> sym
# (char 'sym) -> cnt
(de _char (Exe)
   (let X (cdr Exe)
      (cond
         ((atom X)
            (let Chr (val $Chr)
               (unless Chr
                  (setq Chr (call $Get)) )
               (prog1
                  (if (lt0 Chr)
                     $Nil
                     (mkChar (getChar Chr)) )
                  (call $Get) ) ) )
         ((cnt? (eval (car X)))
            (if (int @)
               (mkChar (i32 @))
               $Nil ) )
         ((t? @) (mkChar TOP))
         ((symb? @) (cnt (i64 (firstChar @))))
         (T (atomErr Exe @)) ) ) )

# (skip ['any]) -> sym
(de _skip (Exe)
   (if (lt0 (skipc (firstChar (evSym (cdr Exe)))))
      $Nil
      (mkChar @) ) )

# (eol) -> flg
(de _eol (Exe)
   (let C (if (val $Chr) @ (call $Get))
      (if (or (le0 C) (== C (char "\n")))
         $T
         $Nil ) ) )

# (eof ['flg]) -> flg
(de _eof (Exe)
   (nond
      ((nil? (eval (cadr Exe)))
         (set $Chr -1)
         $T )
      ((=0 (val $Chr))
         (if (lt0 @) $T $Nil) )
      (NIL
         (if (lt0 (call $Get)) $T $Nil) ) ) )

# (from 'any ..) -> sym
(de _from (Exe)
   (let
      (X (cdr Exe)
         N 1
         Y (evSym X)
         Nm (xName Exe Y)
         L
         (link
            (push Y NIL 0  # [sym link ix str]
               (any (bufString Nm (b8 (bufSize Nm)))) ) )
         P L )
      (while (pair (shift X))
         (setq
            Y (evSym X)
            Nm (xName Exe Y)
            L
            (link
               (push Y NIL 0  # [sym link ix str]
                  (any (bufString Nm (b8 (bufSize Nm)))) ) ) )
         (inc 'N) )
      (unless (val $Chr)
         (call $Get) )
      (while (ge0 (val $Chr))
         (let (B (i8 @)  Q (i64* L)  I N)
            (loop
               (loop
                  (let S (ofs (i8* (val 4 Q)) (val 3 Q))
                     (when (== B (val S))  # Bytes match
                        (set 3 Q (inc (val 3 Q)))  # Increment index
                        (? (val 2 S))  # Not end of string
                        (call $Get) # Skip next input byte
                        (drop P)
                        (ret (val Q)) ) )  # Return matched symbol
                  (? (=0 (val 3 Q)))  # Still at beginning of string
                  (let S (ofs (i8* (val 4 Q)) 1)  # Pointer to second byte
                     (while (set 3 Q (dec (val 3 Q)))  # Decrement index
                        (? (=0 (memcmp (i8* (val 4 Q)) S @)))
                        (inc 'S) ) ) )
               (? (=0 (dec 'I)))
               (setq Q (i64* (val 2 Q))) ) )
         (call $Get) )
      (drop P)
      $Nil ) )

# (till 'any ['flg]) -> lst|sym
(de _till (Exe)
   (let
      (X (cdr Exe)
         Nm (xName Exe (evSym X))
         S (bufString Nm (b8 (bufSize Nm))) )
      (let C (if (val $Chr) @ (call $Get))
         (cond
            ((or (lt0 C) (strchr S C))
               $Nil )
            ((nil? (eval (cadr X)))
               (let
                  (Y (cons (mkChar (getChar C)) $Nil)
                     R (save Y) )
                  (until
                     (or
                        (le0 (setq C (call $Get)))
                        (strchr S C) )
                     (setq Y
                        (set 2 Y (cons (mkChar (getChar C)) $Nil)) ) )
                  R ) )
            (T
               (let
                  (P (push 4 NIL ZERO NIL)  # [cnt last name link]
                     Q (link (ofs P 2)) )
                  (loop
                     (charSym (getChar C) P)
                     (? (le0 (setq C (call $Get))))
                     (? (strchr S C)) )
                  (drop Q
                     (consStr (val 3 P)) ) ) ) ) ) ) )

(local) eol

(de i1 eol ((i32 . C))
   (cond
      ((lt0 C) YES)
      ((== C (char "\n"))
         (set $Chr 0)
         YES )
      ((== C (char "\r"))
         (when (== (call $Get) (char "\n"))
            (set $Chr 0) )
         YES )
      (T NO) ) )

# (line 'flg ['cnt ..]) -> lst|sym
(de _line (Exe)
   (let C (val $Chr)
      (unless C
         (setq C (call $Get)) )
      (if (eol C)
         $Nil
         (let X (cdr Exe)
            (cond
               ((nil? (eval (++ X)))
                  (let  # List of characters
                     (Y (cons (mkChar (getChar C)) $Nil)
                        R (save Y) )
                     (when (pair X)
                        (let Z (set Y (cons (car Y) $Nil))
                           (loop
                              (let N (evCnt Exe X)
                                 (while (gt0 (dec 'N))
                                    (when (eol (setq C (call $Get)))
                                       (ret R) )
                                    (setq Z
                                       (set 2 Z (cons (mkChar (getChar C)) $Nil)) ) ) )
                              (? (atom (shift X)))
                              (when (eol (setq C (call $Get)))
                                 (ret R) )
                              (setq Y
                                 (set 2 Y
                                    (cons
                                       (setq Z (cons (mkChar (getChar C)) $Nil))
                                       $Nil ) ) ) ) ) )
                     (until (eol (setq C (call $Get)))
                        (setq Y
                           (set 2 Y (cons (mkChar (getChar C)) $Nil)) ) )
                     R ) )
               ((atom X)  # Pack single string
                  (let
                     (P (push 4 NIL ZERO NIL)  # [cnt last name link]
                        Q (link (ofs P 2)) )
                     (loop
                        (charSym (getChar C) P)
                        (? (eol (setq C (call $Get)))) )
                     (drop Q
                        (consStr (val 3 P)) ) ) )
               (T
                  (let
                     (N (evCnt Exe X)
                        P (push 4 NIL ZERO NIL)  # [cnt last name link]
                        Q (link (ofs P 2) T) )
                     (loop
                        (charSym (getChar C) P)
                        (when (eol (setq C (call $Get)))
                           (ret (cons (consStr (val Q)) $Nil)) )
                        (? (=0 (dec 'N))) )
                     (let
                        (Y (cons (consStr (val Q)) $Nil)
                           R (save Y) )
                        (while (pair (shift X))
                           (setq N (evCnt Exe X))
                           (set P 4  3 P ZERO)
                           (loop
                              (charSym (getChar C) P)
                              (when (eol (setq C (call $Get)))
                                 (set 2 Y (cons (consStr (val Q)) $Nil))
                                 (ret R) )
                              (? (=0 (dec 'N))) )
                           (setq Y
                              (set 2 Y (cons (consStr (val Q)) $Nil)) ) )
                        (loop
                           (setq Y
                              (set 2 Y (cons (mkChar (getChar C)) $Nil)) )
                           (? (eol (setq C (call $Get)))) )
                        R ) ) ) ) ) ) ) )

# (in 'any . prg) -> any
(de _in (Exe)
   (let X (cdr Exe)
      (rdOpen Exe (eval (++ X)) (b8 (ioFrame T)))
      (prog1
         (run X)
         (popInFiles)
         (tosInFile) ) ) )

# (out 'any . prg) -> any
(de _out (Exe)
   (let X (cdr Exe)
      (wrOpen Exe (eval (++ X)) (b8 (ioFrame T)))
      (prog1
         (run X)
         (popOutFiles)
         (tosOutFile) ) ) )

# (err 'sym . prg) -> any
(de _err (Exe)
   (let X (cdr Exe)
      (erOpen Exe (eval (++ X)) (b8 (ctFrame T)))
      (prog1
         (run X)
         (popErrFiles) ) ) )

# (ctl 'sym . prg) -> any
(de _ctl (Exe)
   (let X (cdr Exe)
      (ctOpen Exe (eval (++ X)) (b8 (ctFrame T)))
      (prog1
         (run X)
         (popCtlFiles) ) ) )

(local) (getIn put1 putOut)

(de i32 getIn ()
   (set $Chr
      (cond
         ((val $IoChar)
            (set $IoChar (shr @ 8))
            (i32 (i8 @)) )
         ((nil?
               (let Get: (getFrame (val $Input))
                  (prog2
                     (set
                        $Chr (Get: chr)
                        (i8** $Get) (Get: fun)
                        $Input (Get: link) )
                     (eval (Get: exe))
                     (set
                        $Input (Get:)
                        $Get (fun (i32) getIn) )
                     (Get: chr (val $Chr)) ) ) )
            -1 )
         ((sym? @)
            (let (S @  V (val (tail @)))
               (if
                  (or
                     (sym? V)
                     (not (cnt? (setq V (name V)))) )
                  (charErr 0 S)
                  (let C (int V)
                     (set $IoChar (shr C 8))
                     (i32 (i8 C)) ) ) ) )
         (T (symErr 0 @)) ) ) )

# (input exe . prg) -> any
(de _input (Exe)
   (let (X (cdr Exe)  Get: (getFrame (b8 (getFrame T))))
      (Get: link (val $Input))
      (Get: exe (++ X))
      (Get: fun (val (i8** $Get)))
      (Get: chr (val $Chr))
      (set
         $Input (Get:)
         $Get (fun (i32) getIn)
         $IoChar 0
         $Chr 0 )
      (prog1
         (run X)
         (set
            (i8** $Get) (Get: fun)
            $Input (Get: link)
            $Chr 0 ) ) ) )

(de void put1 ((i8* . Put) C D)
   (let
      (Put: (putFrame Put)
         At2 (save (val $At2))
         At3 (save (val $At3)) )
      (set
         (i8** $Put) (Put: fun)
         $Output (Put: link)
         $At2 C
         $At3 D )
      (eval (Put: exe))
      (set
         $At3 At3
         $At2 At2
         $Output (Put:)
         $Put (fun (void i8) putOut) ) ) )

(de void putOut ((i8 . B))
   (nond
      ((& B (hex "80"))  # Single byte
         (set $IoChar (i64 B)) )
      ((& B (hex "40"))  # Following byte
         (set $IoChar
            (|
               (val $IoChar)
               (shl
                  (i64 B)
                  (set $IoIx (+ (val $IoIx) 8)) ) ) )
         (when (set $IoCnt (dec (val $IoCnt)))
            (ret) ) )
      ((& B (hex "20"))
         (set $IoCnt 1  $IoIx 0  $IoChar (i64 B))
         (ret) )
      ((& B (hex "10"))
         (set $IoCnt 2  $IoIx 0  $IoChar (i64 B))
         (ret) )
      (NIL
         (set $IoCnt 3  $IoIx 0  $IoChar (i64 B))
         (ret) ) )
   (let
      (Put: (putFrame (val $Output))
         C (consStr (cnt (val $IoChar))) )
      (unless (nil? (Put: char))
         (put1 (Put:) @ C) )
      (Put: char C) ) )

# (output exe . prg) -> any
(de _output (Exe)
   (let (X (cdr Exe)  Put: (putFrame (b8 (putFrame T))))
      (Put: link (val $Output))
      (Put: exe (++ X))
      (Put: fun (val (i8** $Put)))
      (Put: char $Nil)
      (set
         $Output (Put:)
         $Put (fun (void i8) putOut) )
      (prog1
         (run X)
         (unless (nil? (Put: char))
            (put1 (Put:) @ $Nil) )
         (set
            (i8** $Put) (Put: fun)
            $Output (Put: link) ) ) ) )

# (fd ['cnt]) -> cnt
(de _fd (Exe)
   (let (X (eval (cadr Exe))  Fd (currFd Exe))
      (unless (nil? X)
         (dup2 Fd (i32 (xCnt Exe X))) )
      (cnt (i64 Fd)) ) )

(local) forkLisp

(de i32 forkLisp (Exe)
   (flushAll)
   (unless (val $Spkr)  # Not listening for children yet
      (when (lt0 (pipe $SpMiPipe))  # Open speaker/microphone pipe
         (pipeErr Exe) )
      (closeOnExec Exe (set $Spkr (val $SpMiPipe)))
      (closeOnExec Exe (val 2 $SpMiPipe)) )
   (let (Hear (b32 2)  Tell (b32 2))
      (when (or (lt0 (pipe Hear)) (lt0 (pipe Tell)))
         (pipeErr Exe) )
      (closeOnExec Exe (val Hear))  # Read end of 'hear'
      (closeOnExec Exe (val 2 Hear))  # Write end
      (closeOnExec Exe (val Tell))  # Read end of 'tell'
      (closeOnExec Exe (val 2 Tell))  # Write end
      (let (I (i32 0)  N (val $Children))
         (let Cld (val $Child)
            (while (> N I)  # Find a free child slot
               (? (=0 ((child Cld) pid)))
               (inc 'I)
               (setq Cld (ofs Cld (child T))) ) )
         (cond
            ((lt0 (fork)) (forkErr Exe))
            ((=0 @)  # In child
               (set
                  $Slot I  # Set child index
                  $Spkr 0  # No children yet
                  $Mic (val 2 $SpMiPipe) )  # Set microphone to write end
               (close (val 2 Hear))  # Close write end of 'hear'
               (close (val Tell))  # Close read end of 'tell'
               (close (val $SpMiPipe))  # Close read end
               (when (val $Hear)
                  (close @)
                  (closeInFile @)
                  (closeOutFile @) )
               (initInFile (set $Hear (val Hear)) null)  # Read end of 'hear'
               (when (val $Tell)  # Telling
                  (close @) )
               (set $Tell (val 2 Tell))  # Write end of 'tell'
               (set $Nfds 0)   # Clear poll entries
               (free (i8* (val $Poll)))
               (set $Poll (i64* null))
               (let Cld (val $Child)
                  (while (ge0 (dec 'N))  # Close children
                     (let Cld: (child Cld)
                        (when (Cld: pid)
                           (free (Cld: buf))
                           (close (Cld: hear))
                           (close (Cld: tell)) ) )
                     (setq Cld (ofs Cld (child T))) ) )
               (set $Children 0)  # No children
               (free (val $Child))
               (set $Child null)
               (let In (val $InFrames)  # Clear pids in InFrames
                  (while In
                     (let In: (ioFrame In)
                        (In: pid 0)
                        (setq In (In: link)) ) ) )
               (let Out (val $OutFrames)  # Clear pids in OutFrames
                  (while Out
                     (let Out: (ioFrame Out)
                        (Out: pid 0)
                        (setq Out (Out: link)) ) ) )
               (let Ca (val $Catch)  # Clear 'finally' expressions in Catch frames
                  (while Ca
                     (let Ca: (caFrame Ca)
                        (Ca: fin ZERO)
                        (setq Ca (Ca: link)) ) ) )
               (let R (val $Run)  # Switch off all tasks
                  (while (pair R)
                     (let X (++ R)
                        (unless (sign? (car X))
                           (let Fd (i32 (int @))
                              (close Fd)
                              (closeInFile Fd)
                              (closeOutFile Fd) ) ) ) ) )
               (set $Bye $Nil)
               (set $Run $Nil)
               (free (val Termio))  # Give up terminal control
               (set Termio null)
               (set
                  $PRepl (val $Repl)  # Set parent REPL flag
                  $PPid (val $Pid) )  # Set parent process ID
               (set $Pid (cnt (i64 (getpid))))  # Set new process ID
               (execAt (val $Fork))  # Run '*Fork'
               (set $Fork $Nil)
               0 )
            (T  # In parent
               (let Pid @
                  (when (== I N)  # Children table full
                     (set $Children (inc 'N 8))  # Eight more slots
                     (let P
                        (set $Child
                           (alloc (val $Child) (i64 (* N (child T)))) )
                        (let Cld (ofs P (* I (child T)))
                           (loop
                              ((child Cld) pid 0)  # Clear 'pid'
                              (? (== I (dec 'N)))
                              (setq Cld (ofs Cld (child T))) ) ) ) )
                  (close (val Hear))  # Close read end of 'hear'
                  (close (val 2 Tell))  # Close write end of 'tell'
                  (let Cld: (child (ofs (val $Child) (* I (child T))))  # Free 'child' entry
                     (Cld: buf null)  # No buffer yet
                     (Cld: ofs (Cld: cnt 0))  # Init buffer offset and count
                     (Cld: pid Pid)  # Set 'pid'
                     (Cld: hear (val Tell))  # Read end of 'tell'
                     (nonBlocking (Cld: tell (val 2 Hear))) )  # Write end of 'hear'
                  Pid ) ) ) ) ) )

# (pipe exe) -> cnt
# (pipe exe . prg) -> any
(de _pipe (Exe)
   (let
      (X (cdr Exe)
         E (++ X)
         Pfd (b32 2)
         Io: (ioFrame (b8 (ioFrame T))) )
      (when (lt0 (if (pair X) (pipe Pfd) (socketPair Pfd)))
         (pipeErr Exe) )
      (when (< (val 2 Pfd) 2)  # pfd[1]
         (pipeErr Exe) )
      (if (forkLisp Exe)
         (let Pid @  # In parent
            (close (val 2 Pfd))  # Close write end
            (let Fd (val Pfd)  # Read end
               (closeOnExec Exe Fd)
               (cond
                  ((atom X)  # No 'prg'
                     (initInFile Fd null)
                     (initOutFile Fd)
                     (cnt (i64 Fd)) )
                  (T
                     (setpgid Pid 0)  # Set process group
                     (pushInFile (Io:) (initInFile Fd null) Pid)
                     (prog1
                        (run X)
                        (popInFiles)
                        (tosInFile) ) ) ) ) )
         # In child
         (close (val Pfd))  # Close read end
         (let Fd (val 2 Pfd)  # Write end
            (if (pair X)  # 'prg'
               (setpgid 0 0)  # Set process group
               (dup2 Fd 0)  # Dup write pipe to STDIN_FILENO
               ((inFile (val (val $InFiles))) tty NO) )  # Clear 'tty' in stdin
            (dup2 Fd 1)  # Dup write pipe to STDOUT_FILENO
            (close Fd) )
         (signal (val SIGPIPE Sig) (val SigDfl))  # Default SIGPIPE
         ((outFile (val $OutFile)) tty NO)  # Clear 'tty'
         (pushOutFile (Io:) (val 2 (val $OutFiles)) 0)  # Stdout
         (set $LinePtr null)  # Switch off line editor
         (when (pair E)  # Evaluate 'exe'
            (evList E) )
         (bye 0) ) ) )

# (open 'any ['flg]) -> cnt | NIL
(de _open (Exe)
   (let
      (X (cdr Exe)
         Nm (xName Exe (evSym X))
         S (pathString Nm (b8 (pathSize Nm)))
         Flg (nil? (eval (cadr X))) )
      (loop
         (? (ge0 (if Flg (openRdWrCreate S) (openRd S)))
            (closeOnExec Exe @)
            (initInFile @ (strdup S))
            (initOutFile @)
            (cnt (i64 @)) )
         (? (<> (gErrno) EINTR) $Nil)
         (sigChk Exe) ) ) )

# (close 'cnt) -> cnt | NIL
(de _close (Exe)
   (let
      (X (eval (cadr Exe))
         Fd (i32 (xCnt Exe X)) )
      (loop
         (? (=0 (close Fd))
            (closeInFile Fd)
            (closeOutFile Fd)
            X )
         (? (<> (gErrno) EINTR) $Nil)
         (sigChk Exe) ) ) )

# (echo ['cnt ['cnt]] | ['sym ..]) -> sym
(de _echo (Exe)
   (let (X (cdr Exe)  Y (eval (++ X)))
      (cond
         ((and (nil? Y) (atom X))
            (let C (if (val $Chr) @ (call $Get))
               (until (lt0 C)
                  (call $Put (i8 C))
                  (setq C (call $Get)) ) )
            $T )
         ((num? Y)
            (let N (xCnt Exe Y)
               (when (pair X)
                  (let C (evCnt Exe X)
                     (while (ge0 (dec 'N))
                        (when (lt0 (call $Get))
                           (ret $Nil) ) )
                     (setq N C) ) )
               (while (ge0 (dec 'N))
                  (when (lt0 (call $Get))
                     (ret $Nil) )
                  (call $Put (i8 @)) )
               (set $Chr 0)
               $T ) )
         ((pair Y) (argErr Exe Y))
         (T  # sym
            (let
               (M (i64* null)
                  N 1
                  Nm (xName Exe Y)
                  L
                  (link
                     (push Y NIL 0  # [sym link ix str]
                        (any (bufString Nm (b8 (bufSize Nm)))) ) )
                  P L )
               (while (pair X)
                  (setq
                     Y (evSym (++ X))
                     Nm (xName Exe Y)
                     L
                     (link
                        (push Y NIL 0  # [sym link ix str]
                           (any (bufString Nm (b8 (bufSize Nm)))) ) ) )
                  (inc 'N) )
               (unless (val $Chr)
                  (call $Get) )
               (while (ge0 (val $Chr))
                  (let
                     (B (i8 @)
                        Q (i64* L)
                        I N
                        OutM M
                        OutC (if M (val 3 M) 0) )
                     (loop
                        (loop
                           (let S (ofs (i8* (val 4 Q)) (val 3 Q))
                              (when (== B (val S))  # Bytes match
                                 (set 3 Q (inc (val 3 Q)))  # Increment index
                                 (? (val 2 S)  # Not end of string
                                    (unless (and M (>= (val 3 M) (val 3 Q)))
                                       (setq M Q) ) )
                                 (when OutM
                                    (setq S (i8* (val 4 OutM)))
                                    (dec 'OutC (val 3 Q))
                                    (until (lt0 OutC)
                                       (call $Put (val S))
                                       (inc 'S)
                                       (dec 'OutC) ) )
                                 (set $Chr 0)  # Clear look ahead
                                 (drop P)
                                 (ret (val Q)) ) )  # Return matched symbol
                           (? (=0 (val 3 Q)))  # Still at beginning of string
                           (let S (ofs (i8* (val 4 Q)) 1)  # Pointer to second byte
                              (while (set 3 Q (dec (val 3 Q)))  # Decrement index
                                 (? (=0 (memcmp (i8* (val 4 Q)) S @)))
                                 (inc 'S) ) )
                           (when (== Q M)  # On current max
                              (setq M (i64* null))
                              (let (Z (i64* L)  J N)
                                 (loop
                                    (when (val 3 Z)
                                       (unless (and M (>= (val 3 M) (val 3 Z)))
                                          (setq M Z) ) )
                                    (? (=0 (dec 'J)))
                                    (setq Z (i64* (val 2 Z))) ) ) ) )
                        (? (=0 (dec 'I)))
                        (setq Q (i64* (val 2 Q))) )
                     (cond
                        ((=0 M)
                           (when OutM
                              (let (S (i8* (val 4 OutM))  C OutC)
                                 (loop
                                    (call $Put (val S))
                                    (inc 'S)
                                    (? (=0 (dec 'C))) ) ) )
                           (call $Put B) )
                        (OutM
                           (let S (i8* (val 4 OutM))
                              (dec 'OutC (val 3 M))
                              (until (lt0 OutC)
                                 (call $Put (val S))
                                 (inc 'S)
                                 (dec 'OutC) ) ) ) ) )
                  (call $Get) )
               (drop P)
               $Nil ) ) ) ) )

(de void _putStdout ((i8 . B))
   (let Out: (outFile (val $OutFile))
      (when (Out:)
         (let I (Out: ix)
            (when (== I BUFSIZ)
               (Out: ix (setq I 0))
               (wrBytes (Out: fd) (Out: (buf)) BUFSIZ) )
            (set (ofs (Out: (buf)) I) B)
            (Out: ix (inc 'I))
            (when (and (== B (char "\n")) (Out: tty))
               (Out: ix 0)
               (wrBytes (Out: fd) (Out: (buf)) I) ) ) ) ) )

(local) (newline space)

(de void newline ()
   (call $Put (char "\n")) )

(de void space ()
   (call $Put (char " ")) )

(local) (outWord outNum outOct outAo bufAo prExt)

# Output decimal number
(de void outWord ((i64 . N))
   (when (> N 9)
      (outWord (/ N 10))
      (setq N (% N 10)) )
   (call $Put (+ (i8 N) (char "0"))) )

(de void outNum (X)
   (when (sign? X)
      (call $Put (char "-")) )
   (outWord (shr (i64 X) 4)) )

# Output octal number
(de void outOct ((i64 . N))
   (when (> N 7)
      (outOct (shr N 3))
      (setq N (& N 7)) )
   (call $Put (+ (i8 N) (char "0"))) )

# Output A-O encoding
(de void outAo ((i32 . N))
   (when (> N 15)
      (outAo (shr N 4))
      (setq N (& N 15)) )
   (call $Put (+ (i8 N) (char "@"))) )

# Append A-O encoding to buffer
(de i8* bufAo ((i8* . P) (i32 . N))
   (when (> N 15)
      (setq
         P (bufAo P (shr N 4))
         N (& N 15) ) )
   (set P (+ (i8 N) (char "@")))
   (inc P) )

# Output external symbol name
(de void prExt (Nm)
   (when (objFile Nm)
      (outAo @) )
   (outOct (objId Nm)) )

(local) (outString prName prSym printName printSym)

# Output string
(de void outString ((i8* . S))
   (while (val S)
      (call $Put @)
      (inc 'S) ) )

(de void prName (Nm)
   (let P (push 0 Nm)  # [cnt name]
      (while (symByte P)
         (call $Put @) ) ) )

(de void prSym (Sym)
   (prName (name (val (tail Sym)))) )

(de void printName (Nm)
   (ifn (== Nm (hex "2E2"))  # Dot
      (let (P (push 0 Nm)  B (symByte P))  # [cnt name]
         (when (== B (char "#"))
            (call $Put (char "\\")) )  # Escape leading hash
         (loop
            (when
               (or
                  (== B (char "\\"))
                  (strchr $Delim (i32 B)) )
               (call $Put (char "\\")) )  # Escape backslash and delimiters
            (call $Put B)
            (? (=0 (setq B (symByte P))) ) ) )
      (call $Put (char "\\"))
      (call $Put (char ".")) ) )

(de void printSym (Sym)
   (printName (name (val (tail Sym)))) )

(local) (print prin)

(de void print (X)
   (sigChk 0)
   (cond
      ((cnt? X) (outNum X))
      ((big? X) (fmtNum X -1 0 0 null))
      ((sym? X)
         (cond
            ((sym? (val (tail X)))  # External
               (call $Put (char "{"))
               (prExt (name (& @ -9)))
               (call $Put (char "}")) )
            ((== (name @) ZERO)  # Anonymous
               (call $Put (char "$"))
               (outOct (int X)) )
            (T
               (let Nm @
                  (ifn (== X (isIntern Nm $PrivT))
                     (let (Lst (val $Intern)  F NO)  # Search namespaces
                        (loop
                           (? (atom Lst) # Transient
                              (call $Put (char "\""))
                              (let (P (push 0 Nm)  B (symByte P))  # [cnt name]
                                 (loop
                                    (cond
                                       ((or
                                             (== B (char "\\"))
                                             (== B (char "\^"))
                                             (== B (char "\"")) )
                                          (call $Put (char "\\")) )
                                       ((== B 127)  # DEL
                                          (call $Put (char "\^"))  # Print ^?
                                          (setq B (char "?")) )
                                       ((> 32 B)  # White space
                                          (call $Put (char "\^"))  # Escape with caret
                                          (setq B (| B 64)) ) )
                                    (call $Put B)
                                    (? (=0 (setq B (symByte P))) ) ) )
                              (call $Put (char "\"")) )
                           (let Nsp (car Lst)
                              (when (isIntern Nm (cdar Nsp))
                                 (? (== @ X)  # Internal
                                    (when F  # Found in other namespace
                                       (printSym Nsp)
                                       (call $Put (char "~")) )
                                    (printName Nm) )
                                 (setq F YES) ) )
                           (shift Lst) ) )
                     (outString ($ "priv~"))  # Found in 'priv'
                     (printName Nm) ) ) ) ) )
      ((and (== (car X) $Quote) (<> X (cdr X)))
         (call $Put (char "'"))
         (print (cdr X)) )
      (T
         (stkChk 0)
         (call $Put (char "("))
         (let P (circ X)
            (ifn P
               (loop  # Non-circular
                  (print (car X))
                  (? (nil? (shift X)))
                  (? (atom X)
                     (outString ($ " . "))
                     (print X) )
                  (space) )
               (let Flg (== P X)  # Fully circular
                  (loop  # Non-circular part
                     (print (car X))
                     (space)
                     (? (== P (shift X))) )
                  (call $Put (char "."))
                  (unless Flg
                     (space)
                     (call $Put (char "("))
                     (loop  # Circular part
                        (print (car X))
                        (space)
                        (? (== P (shift X))) )
                     (call $Put (char "."))
                     (call $Put (char ")")) ) ) ) )
         (call $Put (char ")")) ) ) )

(de void prin (X)
   (sigChk 0)
   (unless (nil? X)
      (cond
         ((cnt? X) (outNum X))
         ((big? X) (fmtNum X -1 0 0 null))
         ((pair X)
            (stkChk 0)
            (loop
               (prin (car X))
               (? (nil? (shift X)))
               (? (atom X) (prin X)) ) )
         ((sym? (val (tail X)))
            (call $Put (char "{"))
            (prExt (name (& @ -9)))
            (call $Put (char "}")) )
         (T (prName (name @))) ) ) )

# (prin 'any ..) -> any
(de _prin (Exe)
   (let X (cdr Exe)
      (loop
         (let Y (eval (++ X))
            (prin Y)
            (? (atom X) Y) ) ) ) )

# (prinl 'any ..) -> any
(de _prinl (Exe)
   (prog1 (_prin Exe) (newline)) )

# (space ['cnt]) -> cnt
(de _space (Exe)
   (let X (eval (cadr Exe))
      (ifn (nil? X)
         (let N (xCnt Exe X)
            (while (ge0 (dec 'N))
               (space) )
            X )
         (space)
         ONE ) ) )

# (print 'any ..) -> any
(de _print (Exe)
   (let X (cdr Exe)
      (loop
         (let Y (eval (++ X))
            (print Y)
            (? (atom X) Y)
            (space) ) ) ) )

# (printsp 'any ..) -> any
(de _printsp (Exe)
   (prog1 (_print Exe) (space)) )

# (println 'any ..) -> any
(de _println (Exe)
   (prog1 (_print Exe) (newline)) )

# (flush) -> flg
(de _flush (Exe)
   (if (flush (val $OutFile)) $T $Nil) )

# (rewind) -> flg
(de _rewind (Exe)
   (let Out: (outFile (val $OutFile))
      (if
         (and
            (Out:)
            (let Fd (Out: fd)
               (Out: ix 0)
               (and (seek0 Fd) (truncate0 Fd)) ) )
         $T
         $Nil ) ) )

# (ext 'cnt . prg) -> any
(de _ext (Exe)
   (let (X (cdr Exe)  N (evCnt Exe X)  Old (val $ExtN))
      (set $ExtN (i32 N))
      (prog1
         (run (cdr X))
         (set $ExtN Old) ) ) )

(local) (getPlio putPlio)

(de i32 getPlio ()
   (let P (val $Ptr)
      (set $Ptr (inc P))
      (i32 (val P)) ) )

(de void putPlio ((i8 . B))
   (let P (val $Ptr)
      (set P B)
      (when (== (set $Ptr (inc P)) (val $End))
         (sizeErr 0) ) ) )

# (plio 'num) -> any
# (plio 'num 'cnt 'any) -> cnt
(de _plio (Exe)
   (let
      (X (cdr Exe)
         P
         (i8*
            (if (cnt? (needNum Exe (eval (++ X))))
               (int @)
               (val (dig @)) ) ) )
      (let (Ptr (val $Ptr)  End (val $End))
         (set
            $Extn (val $ExtN)  # Set external symbol offset
            $Ptr P )
         (prog1
            (if (pair X)
               (let (N (evCnt Exe X)  Y (eval (car (shift X))))
                  (set
                     $PutBin (fun (void i8) putPlio)
                     $End (ofs P N) )
                  (binPrint Y)
                  (cnt (- (val $Ptr) P)) )
               (set $GetBin (fun (i32) getPlio))
               (if (binRead) @ $Nil) )
            (set $Ptr Ptr  $End End) ) ) ) )

# (rd ['sym]) -> any
# (rd 'cnt) -> num | NIL
(de _rd (Exe)
   (let X (save (eval (cadr Exe)))
      (cond
         ((lt0 ((inFile (val $InFile)) fd)) $Nil)
         ((num? X)
            (let
               (P (push 3 NIL ZERO NIL)  # [cnt last name link]
                  Q (link (ofs P 2))
                  Cnt (int X) )
               (cond
                  ((=0 Cnt) $Nil)
                  ((sign? X)  # Little endian
                     (loop
                        (when (lt0 (getBinary))
                           (: 1 (ret $Nil)) )
                        (byteNum (i8 @) P)
                        (? (=0 (dec 'Cnt))) )
                     (if (cnt? (val Q))
                        (twice @)
                        (zapZero @) ) )
                  (T
                     (loop
                        (when (lt0 (getBinary))
                           (goto 1) )
                        (set Q
                           (addu
                              (cnt (i64 @))
                              (set Q (mulu (val Q) (hex "1002"))) ) )  # Multiply number by 256
                        (? (=0 (dec 'Cnt))) )
                     (if (cnt? (val Q))
                        @
                        (zapZero @) ) ) ) ) )
         (T
            (set
               $GetBin (fun (i32) getBinary)
               $Extn (val $ExtN) )
            (if (binRead) @ X) ) ) ) )

# (pr 'any ..) -> any
(de _pr (Exe)
   (let X (cdr Exe)
      (loop
         (let Y (eval (++ X))
            (set $Extn (val $ExtN))  # Set external symbol offset
            (pr Y)  # Print binary
            (? (atom X) Y) ) ) ) )

# (wr 'cnt ..) -> cnt
(de _wr (Exe)
   (let X (cdr Exe)
      (loop
         (let N (eval (++ X))
            (_putStdout (i8 (int N)))
            (? (atom X) N) ) ) ) )

(local) (getParse parse)

(de i32 getParse ()
   (let P (val $Parser)
      (set $Chr
         (if (i32 (symByte P))
            @
            (let C (val 3 P)
               (set 3 P (shr C 8))
               (if C (i32 (i8 C)) -1) ) ) ) ) )

(de parse (Nm (i1 . Skip) Eof Set)
   (let
      (Chr (val $Chr)
         Get (val (i8** $Get))
         Pars (val $Parser) )
      (set
         $Chr 0
         $Get (fun (i32) getParse)
         $Parser (push 0 (save Nm) Eof) )
      (when Skip
         (getParse) )
      (prog1
         (cond
            ((=0 Set) (rdList))
            ((== 1 Set) (read0 YES))
            ((=0 (token Set 0)) $Nil)
            (T
               (let (R (save (cons @ $Nil))  P R)
                  (while (token Set 0)
                     (setq P (set 2 P (cons @ $Nil))) )
                  R ) ) )
         (set
            $Parser Pars
            (i8** $Get) Get
            $Chr Chr ) ) ) )

(local) (putString begString tglString endString)

(de void putString ((i8 . B))
   (byteSym B (val $StrP)) )

(de void begString ((i64* . P))  # [cnt last name link fun ptr]
   (set 6 P (i64 (val $StrP)))
   (link (ofs (set $StrP P) 2))
   (set
      5 P (val (i64* $Put))
      $Put (fun (void i8) putString) ) )

(de void tglString ((i64* . P))
   (xchg (any (ofs P 4)) (any (i64* $Put))) )

(de endString ()
   (let (P (val $StrP)  Q (ofs P 2))
      (set
         (i64* $Put) (val 5 P)
         $StrP (i64* (val 6 P)) )
      (drop Q
         (consStr (val Q)) ) ) )

# (any 'sym) -> any
(de _any (Exe)
   (if (sym? (val (tail (save (evSym (cdr Exe))))))
      $Nil
      (parse (name @) YES (hex "20") 1) ) )  # Blank, EOF

# (sym 'any) -> sym
(de _sym (Exe)
   (let X (eval (cadr Exe))
      (begString (push 4 NIL ZERO NIL NIL NIL))  # [cnt last name link fun ptr]
      (print X)
      (endString) ) )

# (str 'sym ['sym1]) -> lst
# (str 'lst) -> sym
(de _str (Exe)
   (let (X (cdr Exe)  Y (eval (car X)))
      (cond
         ((nil? Y) Y)
         ((num? Y) (argErr Exe Y))
         ((pair Y)
            (begString (push 4 NIL ZERO NIL NIL NIL))  # [cnt last name link fun ptr]
            (loop
               (print (++ Y))
               (? (atom Y))
               (space) )
            (endString) )
         ((sym? (setq Y (val (tail @)))) $Nil)
         ((atom (shift X))
            (parse (name Y) NO (hex "5D0A") 0) )  # '\n', ']', EOF
         (T
            (save Y
               (parse (name Y) NO 0 (save (evSym X))) ) ) ) ) )

(local) (stdRead stdEval repl loadAll)

(de stdRead ((i8* . Prmt))
   (prog2
      (set
         $LinePrmt
         (if
            (or
               (nil? (runAt (val $Prompt)))
               (not (symb? @)) )
            Prmt
            (let
               (Nm (name (val (tail @)))
                  N (bufSize Nm)
                  P
                  (set $ReplPrmt
                     (alloc (val $ReplPrmt) (+ N (strlen Prmt))) ) )
               (bufString Nm P)
               (strcpy (ofs P (dec N)) Prmt)
               P ) )
         $ContPrmt ($ "   ") )
      (read1
         (if ((inFile (val $InFile)) tty)
            (char "\n")
            (i32 0) ) )
      (set $LinePrmt (set $ContPrmt null))
      (while (gt0 (val $Chr))
         (? (== (val $Chr) (char "\n"))
            (set $Chr 0) )
         (if (== (val $Chr) (char "#"))
            (comment)
            (? (> (val $Chr) (char " ")))
            (call $Get) ) ) ) )

(de stdEval (Exe)
   (flushAll)
   (let (At (save (val $At))  X (eval Exe))
      (set $At3 (val $At2)  $At2 At  $At X)
      (outString ($ "-> "))
      (flushAll)
      (print X)
      (newline)
      X ) )

(de repl (Exe (i8* . Prmt) X)
   (when (num? X)
      (argErr Exe X) )
   (if (and (sym? X) (== (firstByte X) (char "-")))
      (let E (save (parse (xName Exe X) YES (hex "5D0A") 0))  # '\n', ']', EOF
         (evList E) )
      (let
         (Int (save (val $Intern))
            Tr1 (save (val $Transient))
            Tr2 (save (val 2 $Transient))
            Pr1 (save (val $PrivT))
            Pr2 (save (val 2 $PrivT))
            V (link (push -ZERO NIL))
            Raw (val Termio) )
         (when (nil? X)
            (setCooked)
            (unless (val $Repl)
               (set $Repl YES)
               (iSignal (val SIGINT Sig) (fun sig)) ) )
         (rdOpen Exe X (b8 (ioFrame T)))
         (set $PrivT (set 2 $PrivT $Nil))
         (set $Rule (set $Transient (set 2 $Transient $Nil)))
         (setq X $Nil)
         (if (== (val $InFile) (val (val $InFiles)))  # Stdin
            (until (nil? (stdRead Prmt))
               (let Y (set V @)
                  (setq X
                     (if (and (=0 (val $Chr)) Prmt)
                        (stdEval Y)
                        (eval Y) ) ) ) )
            (until (nil? (read1 0))
               (setq X (eval (set V @))) ) )
         (popInFiles)
         (tosInFile)
         (when Raw
            (setRaw) )
         (set 2 $PrivT Pr2)
         (set $PrivT Pr1)
         (set 2 $Transient Tr2)
         (set $Transient Tr1)
         (set $Intern Int)
         X ) ) )

(de loadAll (Exe)
   (let X $Nil
      (loop
         (let (A (val $AV)  P (val A))
            (?
               (or
                  (=0 P)
                  (and
                     (== (val P) (char "-"))
                     (=0 (val 2 P)) ) ) )
            (set $AV (inc A))
            (setq X (repl Exe null (mkStr P))) ) )
      X ) )

# (load 'any ..) -> any
(de _load (Exe)
   (let X (cdr Exe)
      (loop
         (let Y
            (if (t? (eval (++ X)))
               (loadAll Exe)
               (repl Exe ($ "> ") @) )
            (? (atom X) Y) ) ) ) )
