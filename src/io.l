# 11apr20 Software Lab. Alexander Burger

(symbols '(llvm))

(local) (openErr closeErr eofErr badInput writeErr selectErr)

(de NIL openErr (Exe X)
   (err Exe X ($ "Open error: %s") (strErrno)) )

(de NIL closeErr ()
   (err 0 0 ($ "Close error: %s") (strErrno)) )

(de NIL eofErr ()
   (err 0 0 ($ "EOF Overrun") null) )

(de NIL badInput ()
   (let S (b8 2)
      (set S (i8 (val $Chr)))
      (set 2 S 0)
      (err 0 0 ($ "Bad input '%c'") S) ) )

(de NIL writeErr ((i8* . Fmt))
   (err 0 0 Fmt (strErrno)) )

(de NIL selectErr (Exe)
   (err Exe 0 ($ "Select error: %s") (strErrno)) )

(local) (closeOnExec initInFile initOutFile closeInFile closeOutFile)

(de void closeOnExec (Exe (i32 . Fd))
   (when (lt0 (fcntlCloExec Fd))
      (err Exe 0 ($ "SETFD %s") (strErrno)) ) )

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
   (let
      (P (ofs (val $InFiles) Fd)
         V (set P (alloc (val P) (inFile T)))
         In: (inFile V) )
      (In: ix (In: cnt 0))
      (In: fd Fd)
      (In: next 0)
      (In: line (In: src 1))
      (In: name Nm)
      V ) )

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
   (let
      (P (ofs (val $OutFiles) Fd)
         V (set P (alloc (val P) (outFile T)))
         Out: (outFile V) )
      (Out: tty (n0 (isatty (Out: fd Fd))))
      (Out: ix 0)
      V ) )

(de void closeInFile ((i32 . Fd))
   (when (> (val $InFDs) Fd)
      (let (P (ofs (val $InFiles) Fd)  V (val P))
         (unless (=0 V)
            (when (== V (val $InFile))
               (set $InFile null) )
            (free ((inFile V) name))
            (free V)
            (set P null) ) ) ) )

(de void closeOutFile ((i32 . Fd))
   (when (> (val $OutFDs) Fd)
      (let (P (ofs (val $OutFiles) Fd)  V (val P))
         (unless (=0 V)
            (when (== V (val $OutFile))
               (set $OutFile null) )
            (free V)
            (set P null) ) ) ) )

(local) (slow slowNb rdBytes rdBytesNb wrBytes clsChild wrChild flush flushAll)

(de i64 slow ((i8* . In))
   (let In: (inFile In)
      (In: ix (In: cnt 0))
      (loop
         (? (ge0 (read (In: fd) (In: (buf)) BUFSIZ))
            (In: cnt @) )
         (? (<> (xErrno) EINTR) 0)
         (sigChk 0) ) ) )

(de i64 slowNb ((i8* . In))
   (let In: (inFile In)
      (In: ix (In: cnt 0))
      (loop
         (let
            (Flg (nonBlocking (In: fd))
               N (read (In: fd) (In: (buf)) BUFSIZ) )
            (fcntlSetFl (In: fd) Flg)
            (? (gt0 N) (In: cnt N))
            (? (=0 N)
               (In: ix (In: cnt -1))
               0 ) )
         (? (== (xErrno) EAGAIN) -1)
         (? (<> @ EINTR) 0)
         (sigChk 0) ) ) )

(de i1 rdBytes ((i32 . Fd) (i8* . P) (i64 . Cnt))
   (loop
      (loop
         (? (gt0 (read Fd P Cnt))
            (setq P (ofs P @)  Cnt (- Cnt @)) )
         (when (or (=0 @) (<> (xErrno) EINTR))
            (ret NO) )
         (sigChk 0) )
      (? (=0 Cnt) YES) ) )

(de i64 rdBytesNb ((i32 . Fd) (i8* . P) (i64 . Cnt))
   (loop
      (let (Flg (nonBlocking Fd)  N (read Fd P Cnt))
         (fcntlSetFl Fd Flg)
         (when (gt0 N)
            (loop
               (when (=0 (setq Cnt (- Cnt N)))
                  (ret 1) )
               (setq P (ofs P N))
               (while (le0 (setq N (read Fd P Cnt)))
                  (when (or (=0 N) (<> (xErrno) EINTR))
                     (ret 0) )
                  (sigChk 0) ) ) )
         (? (=0 N) 0) )
      (? (== (xErrno) EAGAIN) -1)
      (? (<> @ EINTR) 0)
      (sigChk 0) ) )

(de i1 wrBytes ((i32 . Fd) (i8* . P) (i64 . Cnt))
   (loop
      (let N (write Fd P Cnt)
         (if (lt0 N)
            (let E (xErrno)
               (? (== E EBADF) NO)
               (? (== E EPIPE) NO)
               (? (== E ECONNRESET) NO)
               (unless (== E EINTR)
                  (when (== Fd 2)  # Stderr
                     (bye 2) )
                  (writeErr ($ "bytes write: %s")) )
               (sigChk 0) )
            (? (=0 (setq Cnt (- Cnt N))) YES)
            (setq P (ofs P N)) ) ) ) )

(de void clsChild ((i8* . Cld))
   (let Cld: (child Cld)
      (when (== (Cld: pid) (val $Talking))
         (set $Talking 0) )
      (Cld: pid 0)
      (close (Cld: hear))
      (free (Cld: buf)) ) )

(de void wrChild ((i8* . Cld)  (i8* . P) (i64 . Cnt))
   (let (Cld: (child Cld)  C (Cld: cnt))
      (when (=0 C)
         (loop
            (let N (write (Cld: tell) P Cnt)
               (if (lt0 N)
                  (let E (xErrno)
                     (? (== E EAGAIN))
                     (when (or (== E EPIPE) (== E ECONNRESET))
                        (clsChild Cld)
                        (ret) )
                     (unless (== E EINTR)
                        (writeErr ($ "child write: %s")) ) )
                  (when (=0 (setq Cnt (- Cnt N)))
                     (ret) )
                  (setq P (ofs P N)) ) ) ) )
      (setq N (+ C Cnt 8))  # New buffer size
      (let Q (ofs (Cld: buf (alloc (Cld: buf) N)) C)
         (set (i64* Q) Cnt)
         (memcpy (ofs Q 8) P Cnt)
         (Cld: cnt N) ) ) )

(de i1 flush ((i8* . Out))
   (if (=0 Out)
      YES
      (let Out: (outFile Out)
         (if (=0 (Out: ix))
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
      (unless (=0 (In:))
         (when
            (or
               (<> (In: ix) (In: cnt))
               (and (ge0 @) (n0 (slow (In:)))) )
            (let I (In: ix)
               (In: ix (+ I 1))
               (ret (i32 (val (ofs (In: (buf)) I)))) ) ) )
      (unless (=0 (isatty 0))
         (bye 0) )
      -1 ) )

(de i32 getBinary ()
   (let (In: (inFile (val $InFile))  I (In: ix))
      (when (== I (In: cnt))
         (and (lt0 I) (ret -1))  # Closed
         (and (=0 (slow (In:))) (ret -1))  # EOF
         (setq I 0) )
      (In: ix (+ I 1))
      (i32 (val (ofs (In: (buf)) I))) ) )

# Read binary PLIO expression
(de binRead ()
   (let B (call $GetBin)
      (cond
         ((lt0 B) 0)  # EOF
         ((== B NIX) $Nil)  # NIL
         ((=0 (& B -4))  # Pair
            (if (<> BEG B)
               (any (i64 B))  # DOT or END
               (let X (binRead)
                  (if (=0 X)
                     0
                     (let (Y (cons X $Nil)  R (save Y))
                        (loop
                           (? (=0 (setq X (binRead))) 0)
                           (? (== X END) R)
                           (? (== X DOT)
                              (if (=0 (setq X (binRead)))
                                 0
                                 (set 2 Y (if (== X END) R X))
                                 R ) )
                           (setq Y (set 2 Y (cons X $Nil))) ) ) ) ) ) )
         (T
            (let
               (P (i64* (push NIL NIL ZERO NIL))  # [cnt last name link]
                  Q (link (ofs P 2))
                  Cnt (shr B 2)
                  Tag (& B 3) )
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
                        (when (=0 Cnt)
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
                              (| (half @) (shl (& @ 1) 3)) ) ) ) )
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
                        (when (=0 Cnt)
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
                                    (unless (=0 (val $Extn))
                                       (let N
                                          (shl
                                             (& (i64 (+ @ (objFile Nm))) (hex "FFFF"))
                                             24 )  # Mask overflow
                                          (setq Nm
                                             (|
                                                (& Nm (hex "FFF00FFF00FFFFFF"))  # Mask object ID
                                                (&
                                                   (| N (shl N 12))
                                                   (hex "000FF000FF000000") ) ) ) ) )  # Mask file number
                                    (extern Nm) ) ) ) ) ) ) ) ) ) ) ) )

(local) (waitFile pushInFiles pushOutFiles popInFiles popOutFiles)

# Wait for pipe process if necessary
(de void waitFile ((i32 . Pid))
   (when (> Pid 1)
      (let Res (b32 1)
         (while (lt0 (waitpid Pid Res 0))
            (unless (== (xErrno) EINTR)
               (closeErr) )
            (sigChk 0) )
         (set $At2 (cnt (i64 (val Res)))) ) ) )

(de void pushInFiles ((i8* . P))
   (let (Io: (ioFrame P)  In: (inFile (val $InFile)))
      (unless (=0 (In:))
         (In: next (val $Chr)) )
      (set $Chr
         (if (=0 (set $InFile (val (ofs (val $InFiles) (Io: fd)))))
            -1
            (In: next) ) )
      (Io: fun (val (i8** $Get)))
      (set $Get (fun (i32) _getStdin))
      (Io: link (val $InFrames))
      (set $InFrames (Io:)) ) )

(de void pushOutFiles ((i8* . P))
   (let Io: (ioFrame P)
      (set $OutFile (val (ofs (val $OutFiles) (Io: fd))))
      (Io: fun (val (i8** $Put)))
      (set $Put (fun (void i32) _putStdout))
      (Io: link (val $OutFrames))
      (set $OutFrames (Io:)) ) )

(de void popInFiles ()
   (let Io: (ioFrame (val $InFrames))
      (nond
         ((=0 (Io: pid))
            (close (Io: fd))
            (closeInFile (Io: fd))
            (waitFile (Io: pid)) )
         ((=0 (val $InFile))
            ((inFile (val $InFile)) next (val $Chr)) ) )
      (set (i8** $Get) (Io: fun))
      (setq Io: (ioFrame (set $InFrames (Io: link))))
      (set $Chr
         (if
            (=0
               (set $InFile
                  (val
                     (if (=0 (Io:))
                        (val $InFiles)  # Stdin
                        (ofs (val $InFiles) (Io: fd)) ) ) ) )
            -1
            ((inFile (val $InFile)) next) ) ) ) )

(de void popOutFiles ()
   (flush (val $OutFile))
   (let Io: (ioFrame (val $OutFrames))
      (unless (=0 (Io: pid))
         (close (Io: fd))
         (closeOutFile (Io: fd))
         (waitFile (Io: pid)) )
      (set (i8** $Put) (Io: fun))
      (set $OutFile
         (val
            (if (=0 (Io:))
               (val $OutFiles)  # Stdout
               (ofs (val $OutFiles) (Io: fd)) ) ) ) ) )

# (path 'any) -> sym
(de _path (Exe)
   (let (X (cdr Exe)  Y (evSym X))
      (mkStr (pathString Y (b8 (pathSize Y)))) ) )

(local) (hasData waitFd)

(de i1 hasData ((i32 . Fd))
   (and
      (> (val $InFDs) Fd)
      (let In: (inFile (val (ofs (val $InFiles) Fd)))
         (and (n0 (In:)) (> (In: cnt) (In: ix))) ) ) )

(de i64 waitFd (Exe (i32 . Fd) (i64 . Ms))
   (let
      (Task (val $Task)
         P (link (push (val $At) NIL))
         Tim (getTime) )
      (loop
         (let
            (Stk (stack)
               Poll (b64 (+ (length (val $Run)) (val $Children) 3))
               I 0
               M Ms )
            (when (ge0 Fd)
               (if (hasData Fd)
                  (setq M 0)
                  (pollIn Fd Poll)  # First 'pollfd' struct
                  (inc 'I) ) )
            #! ...
            (while (lt0 (xPoll Poll I M))
               (unless (== (xErrno) EINTR)
                  (set $Run $Nil)
                  (selectErr Exe) )
               (sigChk Exe) )
            #! ...
            (let (T2 (getTime)  D (- T2 Tim))
               (setq Tim T2)
               #! ...
               (when (lt0 (setq Ms (- Ms D)))
                  (setq Ms 0) ) )
            (sigChk Exe)
            (? (or (=0 Ms) (lt0 Fd) (n0 (readyIn Poll))))
            (stack Stk) ) )
      (set $At (pop P)  $Task Task)
      Ms ) )

(local) (rdOpen wrOpen erOpen ctOpen)

(de void rdOpen (Exe X (i8* . P))
   (let Io: (ioFrame P)
      (cond
         ((nil? X)
            (Io: fd 0)  # Stdin
            (Io: pid 0) )
         #! ((num? X)
         #!    )
         ((sym? X)
            (let (Nm (pathString X (b8 (pathSize X)))  Flg (== (val Nm) (char "+")))
               (when Flg
                  (setq Nm (ofs Nm 1)) )
               (while (lt0 (Io: fd (if Flg (openAppend Nm) (openRdonly Nm))))
                  (unless (== (xErrno) EINTR)
                     (openErr Exe X) )
                  (sigChk Exe) )
               (Io: pid 1)
               (initInFile (Io: fd) (strdup Nm)) )
            (closeOnExec Exe (Io: fd)) )
         #! (T
         #!    )
         ) ) )

(de void wrOpen (Exe X (i8* . Out))
   )

(de void erOpen (Exe X (i8* . Err))
   )

(de void ctOpen (Exe X (i8* . Ctl))
   )

(local) (getChar skipC comment skip testEsc anonymous rdAtom rdList read0)

(de read0 (i1))

(de i32 _getStdin ()
   (let In: (inFile (val $InFile))
      (set $Chr
         (cond
            ((=0 (In:)) -1)  # EOF
            ((n0 (In: fd))  # Not stdin
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
            ((atom (val $Led))  # No line editor
               (waitFd 0 0 -1)
               (stdinByte) )
            (T
               (when (=0 (val 2 $Line))  # First call
                  (let S (run (val $Led))
                     (set $Line 0)
                     (set 2 $Line
                        (if (nil? S)
                           ZERO
                           (name S) ) ) ) )
               (if (=0 (symByte $Line))  # Extract next byte
                  (char "\n")
                  (i32 @) ) ) ) ) ) )

(de i32 getChar ((i32 . C))
   (cond
      ((>= 127 C) C)  # Single byte
      ((== C (hex "FF")) (i32 TOP))  # Infinite
      (T
         (let B
            (if (=0 (& C (hex "20")))  # Two bytes
               (& C (hex "1F"))  # First byte 110xxxxx
               (let A
                  (if (=0 (& C (hex "10")))  # Three bytes
                     (& C (hex "0F"))  # First byte 1110xxxx
                     (|  # Four bytes
                        (shl (& C 7) 6)  # First byte 11110xxx
                        (& (call $Get) (hex "3F")) ) )  # 10xxxxxx
                  (| (shl A 6) (& (call $Get) (hex "3F"))) ) )
            (| (shl B 6) (& (call $Get) (hex "3F"))) ) ) ) )

(de i32 skipC ((i32 . C))
   0 )

(de i32 comment ()
   (call $Get) )

(de i32 skip ()
   (let C (val $Chr)
      (loop
         (when (lt0 C)
            (ret C) )
         (loop
            (? (> C (char " ")))
            (when (lt0 (setq C (call $Get)))
               (ret C) ) )
         (when (<> C (char "#"))
            (ret C) )
         (setq C (comment)) ) ) )

(de i1 testEsc ((i32 . C))
   (loop
      (? (lt0 C) NO)
      (? (== C (char "\^"))  # Control character
         (setq C (call $Get))
         (when (== C (char "@"))
            (badInput) )
         (set $Chr
            (if (== C (char "?"))
               127
               (& C (hex "1F")) ) )
         YES )
      (? (<> C (char "\\"))  # No Backslash
         (set $Chr (getChar C))
         YES )
      (? (<> 10 (setq C (call $Get)))  # Backslash: Skip '\'
         (case C
            ((char "n") (set $Chr (char "\n")))
            ((char "r") (set $Chr (char "\r")))
            ((char "t") (set $Chr (char "\t")))
            (T
               (when (and (>= C (char "0")) (>= (char "9") C))
                  (setq C (- C (char "0")))
                  (until (== (call $Get) (char "\\"))
                     (unless
                        (and
                           (>= (val $Chr) (char "0"))
                           (>= (char "9") (val $Chr)) )
                        (badInput) )
                     (setq C
                        (+ (* C 10) (- (val $Chr) (char "0"))) ) ) )
               (set $Chr C) ) )
         YES )
      (loop
         (? (== (setq C (call $Get)) (char " ")))
         (? (== C (char "\t"))) ) ) )

(de anonymous ()
   $Nil )

(de rdAtom ((i32 . C))
   (let (P (push 4 NIL ZERO NIL)  Q (link (ofs P 2)))  # [cnt last name link]
      (charSym C P)
      (setq C (val $Chr))
      (while (and (gt0 C) (=0 (strchr $Delim C)))
         (when (== C (char "\\"))
            (setq C (call $Get)) )
         (charSym C P)
         (setq C (call $Get)) )
      (drop Q
         (let Nm (val Q)
            (if (n0 (symToNum Nm 0 (char ".") 0))
               @
               (requestSym Nm) ) ) ) ) )

(de rdList ()
   (call $Get)
   (let
      (P (push -ZERO NIL)
         X
         (loop
            (let C (skip)
               (when (== C (char ")"))  # Empty list
                  (call $Get)
                  (ret $Nil) )
               (when (== C (char "]"))  # Empty list
                  (ret $Nil) )
               (? (<> C (char "~"))  # Read macro
                  (set (link P) (cons (read0 NO) $Nil)) )
               (call $Get)
               (let Y (set (link P) (read0 NO))
                  (? (pair (setq Y (eval (val P))))
                     (while (pair (cdr Y))
                        (shift Y) )
                     Y ) )
               (drop P) ) ) )
      (loop
         (let C (skip)
            (? (== C (char ")"))
               (call $Get) )
            (? (== C (char "]")))
            (cond
               ((== C (char "."))
                  (? (n0 (strchr $Delim (call $Get)))
                     (setq X
                        (set 2 X
                           (if
                              (or
                                 (== (setq C (skip)) (char ")"))
                                 (== C (char "]")) )
                              (val P)
                              (read0 NO) ) ) )
                     (cond
                        ((== (skip) (char ")"))
                           (call $Get) )
                        ((<> (val $Chr) (char "]"))
                           (err 0 X ($ "Bad dotted pair") null) ) ) )
                  (setq X
                     (set 2 X (cons (rdAtom (char ".")) $Nil)) ) )
               ((== C (char "~"))
                  (call $Get)
                  (set 2 X
                     (eval
                        (set 2 X (read0 NO)) ) )
                  (while (pair (cdr X))
                     (shift X) ) )
               (T
                  (setq X
                     (set 2 X (cons (read0 NO) $Nil)) ) ) ) ) )
      (pop P) ) )

(de read0 ((i1 . Top))
   (let C (skip)
      (cond
         ((lt0 C)
            (unless Top (eofErr))
            $Nil )
         #((and Top ..)
         #   .. )
         ((== C (char "("))
            (prog1
               (rdList)
               (and
                  Top
                  (== (val $Chr) (char "]"))
                  (call $Get) ) ) )
         ((== C (char "["))
            (let X (rdList)
               (when (== (val $Chr) (char "]"))
                  (err 0 X ($ "Super parentheses mismatch") null) )
               (call $Get)
               X ) )
         ((== C (char "'"))
            (call $Get)
            (cons $Quote (read0 Top)) )
         #((== C (char ","))
         #   )
         ((== C (char "`"))
            (call $Get)
            (let E (save (read0 Top))
               (eval E) ) )
         ((== C (char "\""))
            (if (== (setq C (call $Get)) (char "\""))
               (prog (call $Get) $Nil)  # Empty string
               (unless (testEsc C) (eofErr))
               (let (P (push 4 NIL ZERO NIL)  Q (link (ofs P 2)))  # [cnt last name link]
                  (loop
                     (charSym (val $Chr) P)
                     (? (== (setq C (call $Get)) (char "\"")))
                     (unless (testEsc C) (eofErr)) )
                  (call $Get)  # Skip "\""
                  (drop Q
                     (intern 0 0 (val Q) $Transient $Nil) ) ) ) )
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

(local) (read1 token)

(de read1 ((i32 . End))
   (when (=0 (val $Chr))
      (call $Get) )
   (if (== End (val $Chr))
      $Nil
      (read0 YES) ) )

(de token (X (i32 . C))
   )

# (read ['sym1 ['sym2]]) -> any
(de _read (Exe)
   (let X (cdr Exe)
      (prog1
         (if (atom X)
            (read1 0)
            # (token)
            $Nil )
         (and
            (== (val $Chr) (char "\n"))
            (== (val $InFile) (val (val $InFiles)))  # Stdin
            (set $Chr 0) ) ) ) )

# (in 'any . prg) -> any
(de _in (Exe)
   (let (X (cdr Exe)  P (b8 (ioFrame T)))
      (rdOpen Exe (eval (++ X)) P)
      (pushInFiles P)
      (prog1
         (run X)
         (popInFiles) ) ) )

# (out 'any . prg) -> any
(de _out (Exe)
   $Nil )

(de void _putStdout ((i32 . C))
   (let Out: (outFile (val $OutFile))
      (unless (=0 (Out:))
         (let I (Out: ix)
            (when (== I BUFSIZ)
               (Out: ix (setq I 0))
               (wrBytes (Out: fd) (Out: (buf)) BUFSIZ) )
            (set (ofs (Out: (buf)) I) (i8 C))
            (Out: ix (inc 'I))
            (when (and (== C (char "\n")) (Out: tty))
               (Out: ix 0)
               (wrBytes (Out: fd) (Out: (buf)) I) ) ) ) ) )

(local) (newline space)

(de void newline ()
   (call $Put (char "\n")) )

(de void space ()
   (call $Put (char " ")) )

(local) (outWord outNum outOct outAo prExt outString)

# Output decimal number
(de void outWord ((i64 . N))
   (when (> N 9)
      (outWord (/ N 10))
      (setq N (% N 10)) )
   (call $Put (+ (i32 N) (char "0"))) )

(de void outNum (X)
   (when (sign? X)
      (call $Put (char "-")) )
   (outWord (shr (i64 X) 4)) )

# Output octal number
(de void outOct ((i64 . N))
   (when (> N 7)
      (outOct (shr N 3))
      (setq N (& N 7)) )
   (call $Put (+ (i32 N) (char "0"))) )

# Output A-O encoding
(de void outAo ((i32 . N))
   (when (> N 15)
      (outAo (shr N 4))
      (setq N (& N 15)) )
   (call $Put (+ N (char "@"))) )

# Output external symbol name
(de void prExt (Nm)
   (unless (=0 (objFile Nm))
      (outAo @) )
   (outOct (objId Nm)) )

# Output string
(de void outString ((i8* . S))
   (while (n0 (val S))
      (call $Put (i32 @))
      (inc 'S) ) )

(local) (print prin prin1)

(de void print (X)
   (sigChk 0)
   (cond
      ((cnt? X) (outNum X))
      ((big? X) (fmtNum X -1 0 0 null))
      ((sym? X)
         (let Nm (name (val (tail X)))
            (cond
               ((== Nm ZERO)  # Anonymous
                  (call $Put (char "$"))
                  (outOct (int X)) )
               ((sym? (val (tail X)))  # External
                  (call $Put (char "{"))
                  (prExt Nm)
                  (call $Put (char "}")) )
               ((isLstIntern X Nm (val $Intern))
                  (let (P (push 0 (i64 Nm))  B T)  # [cnt name]
                     (until (=0 (setq B (symByte P)))
                        (call $Put (i32 B)) ) ) )
               (T  # Transient
                  (call $Put (char "\""))
                  (let (P (push 0 (i64 Nm))  B T)  # [cnt name]
                     (until (=0 (setq B (symByte P)))
                        (call $Put (i32 B)) ) )
                  (call $Put (char "\"")) ) ) ) )
      ((and (== (car X) $Quote) (<> X (cdr X)))
         (call $Put (char "'"))
         (print (cdr X)) )
      (T
         (call $Put (char "("))
         (let P (circ X)
            (if (=0 P)
               (loop  # Non-circular
                  (print (car X))
                  (? (== $Nil (shift X)))
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
   $Nil )

(de void prin1 (X)
   $Nil )

# (prin 'any ..) -> any
(de _prin (Exe)
   $Nil )

# (prinl 'any ..) -> any
(de _prinl (Exe)
   $Nil )

# (space ['cnt]) -> cnt
(de _space (Exe)
   $Nil )

# (print 'any ..) -> any
(de _print (Exe)
   (let (X (cdr Exe)  Y T)
      (loop
         (print (setq Y (eval (++ X))))
         (? (atom X))
         (space) )
      Y ) )

# (printsp 'any ..) -> any
(de _printsp (Exe)
   (prog1 (_print Exe) (space)) )

# (println 'any ..) -> any
(de _println (X)
   (prog1 (_print Exe) (newline)) )

# (flush) -> flg
(de _flush (Exe)
   $Nil )

# (rewind) -> flg
(de _rewind (Exe)
   $Nil )

# (ext 'cnt . prg) -> any
(de _ext (Exe)
   (let (X (cdr Exe)  N (evCnt Exe X)  Old (val $ExtN))
      (set $ExtN (i32 N))
      (prog1
         (run (cdr X))
         (set $ExtN Old) ) ) )

# (rd ['sym]) -> any
# (rd 'cnt) -> num | NIL
(de _rd (Exe)
   (let X (save (eval (cadr Exe)))
      (cond
         ((=0 (val $InFile)) $Nil)
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
            (if (=0 (binRead)) X @) ) ) ) )

(local) (repl loadAll)

(de repl (Exe (i32 . Pr) X)
   (let (Safe (link (push -ZERO NIL))  P (b8 (ioFrame T)))
      (rdOpen Exe X P)
      (pushInFiles P)
      (setq X $Nil)
      (loop
         (let Y
            (ifn (== (val $InFile) (val (val $InFiles)))
               (read1 0)
               (prog2
                  (when (and (n0 Pr) (=0 (val $Chr)))
                     (call $Put Pr)
                     (space)
                     (flushAll) )
                  (read1
                     (if (=0 (isatty 0))
                        (i32 0)
                        (char "\n") ) )
                  (while (gt0 (val $Chr))
                     (? (== (val $Chr) (char "\n"))
                        (set $Chr 0) )
                     (if (== (val $Chr) (char "#"))
                        (comment)
                        (? (> (val $Chr) (char " ")))
                        (call $Get) ) ) ) )
            (? (nil? Y))
            (set Safe Y)
            (if
               (or
                  (<> (val $InFile) (val (val $InFiles)))
                  (n0 (val $Chr))
                  (=0 Pr) )
               (setq X (eval Y))
               (flushAll)
               (let A (val $At)
                  (set Safe A)
                  (setq X (set $At (eval Y)))
                  (set $At3 (val $At2))
                  (set $At2 A) )
               (outString ($ "-> "))
               (flushAll)
               (print X)
               (newline) ) ) )
      (popInFiles)
      (drop Safe)
      X ) )

(de loadAll (Exe)
   (let (X $Nil  P (val $AV))
      (loop
         (let Q (val P)
            (? (=0 Q))
            (?
               (and
                  (== (val Q) (char "-"))
                  (=0 (val 2 Q)) ) )
            (setq
               P (set $AV (ofs P 1))
               X (repl Exe 0 (mkStr Q)) ) ) )
      X ) )

# (load 'any ..) -> any
(de _load (Exe)
   (let X (cdr Exe)
      (loop
         (let Y
            (if (== (eval (++ X)) $T)
               (loadAll Exe)
               (repl Exe (char ">") @) )
            (? (atom X) Y) ) ) ) )
