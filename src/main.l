# 22may22 Software Lab. Alexander Burger

(symbols '(llvm))

(begin "base" NIL
   "vers.l" "defs.l" "glob.l" "dec.l" )

(local) (execAt runAt wrnl dbg)

(de execAt (Prg)
   (let At (save (val $At))
      (exec Prg)
      (set $At At) ) )

(de runAt (Prg)
   (let At (save (val $At))
      (prog1
         (run Prg)
         (set $At At) ) ) )

(de wrnl ()
   (write 1 ($ "\n") 1) )

(de dbg ((i64 . N) X)
   (let (Out (val $OutFile)  Put (val (i8** $Put)))
      (set
         $OutFile (val 3 (val $OutFiles))  # Stderr
         $Put (fun (void i8) _putStdout) )
      (outWord N)
      (when X
         (space)
         (print X) )
      (newline)
      (set (i8** $Put) Put  $OutFile Out) )
   X )


(local) (tosInFile popInFiles tosOutFile popOutFiles popErrFiles popCtlFiles)

(de void tosInFile ())
(de void popInFiles ())
(de void tosOutFile ())
(de void popOutFiles ())
(de void popErrFiles ())
(de void popCtlFiles ())

(local) (stop unwind)

# Stop coroutine
(de void stop ((i8* . Crt))
   ((coroutine Crt) tag 0)  # Set unused
   (while ((coroutine Crt) nxt)  # Find bottom
      (setq Crt @) )
   (until ((coroutine Crt) tag)  # Free stack space
      (setq Crt ((coroutine Crt) prv))
      ((coroutine Crt) nxt null) ) )

# Unwind stack
(de void unwind ((i8* . Catch))
   (let (Ca (val $Catch)  Bnd (val $Bind))
      (while Ca
         (let Ca: (caFrame Ca)
            (while (and Bnd (<> Bnd (Ca: (env $Bind any))))
               (set (val 2 Bnd) (val Bnd))  # Restore values
               (setq Bnd (val 3 Bnd)) )
            (until (== (val $CtlFrames) (Ca: (env $CtlFrames i8*)))
               (popCtlFiles) )
            (until (== (val $ErrFrames) (Ca: (env $ErrFrames i8*)))
               (popErrFiles) )
            (unless (== (val $OutFrames) (Ca: (env $OutFrames i8*)))
               (loop
                  (popOutFiles)
                  (? (== (val $OutFrames) (Ca: (env $OutFrames i8*)))) )
               (tosOutFile) )
            (unless (== (val $InFrames) (Ca: (env $InFrames i8*)))
               (loop
                  (popInFiles)
                  (? (== (val $InFrames) (Ca: (env $InFrames i8*)))) )
               (tosInFile) )
            (let (Src (val $Current)  Dst (Ca: co))
               (unless Dst
                  (setq Dst (val $Coroutines)) )
               (unless (== Src Dst)
                  (stop Src)
                  (let Crt: (coroutine (set $Current Dst))
                     (set $StkLimit (+ (Crt: lim) 4096))
                     (set $At (Crt: at)) ) ) )
            (getCaEnv (Ca:))
            (eval (Ca: fin))  # Evaluate 'finally' expression
            (set $Catch (Ca: link))
            (when (== Ca Catch)
               (ret) )
            (setq Ca (Ca: link)) ) )
      (while Bnd
         (set (val 2 Bnd) (val Bnd))  # Restore values
         (setq Bnd (val 3 Bnd)) )
      (set $Bind 0)
      (while (val $CtlFrames)
         (popCtlFiles) )
      (while (val $ErrFrames)
         (popErrFiles) )
      (unless (== (val $OutFrames) (val $Stdout))
         (loop
            (popOutFiles)
            (? (== (val $OutFrames) (val $Stdout))) )
         (tosOutFile) )
      (unless (== (val $InFrames) (val $Stdin))
         (loop
            (popInFiles)
            (? (== (val $InFrames) (val $Stdin))) )
         (tosInFile) ) ) )

# Exit
(local) (finish giveup bye execErr)

(de NIL finish ((i32 . N))
   (setCooked)
   (exit N) )

(de NIL giveup ((i8* . Fmt) (i8* . Msg))
   (stderrMsg Fmt Msg)
   (finish 1) )

(de NIL bye ((i32 . N))
   (unless (val $InBye)
      (set $InBye YES)
      (unwind null)
      (exec (val $Bye)) )
   (flushAll)
   (finish N) )

(de NIL execErr ((i8* . Cmd))
   (stderrMsg ($ "%s: Can't exec\n") Cmd)
   (exit 127) )

# Memory
(local) (alloc heapAlloc)

(de i8* alloc ((i8* . Ptr) (i64 . Siz))
   (unless (realloc Ptr Siz)   # Reallocate pointer
      (giveup ($ "No memory") null) )
   @ )

(de void heapAlloc ()
   (let
      (H (any (alloc null (* 8 (inc HEAP))))
         P (ofs H HEAP)
         A (val $Avail) )
      (set P (val $Heaps)  $Heaps H)
      (loop
         (set (setq P (ofs P -2)) A)  # Link avail
         (? (== (setq A P) H)) )
      (set $Avail A) ) )

# Signals
(local) (sig sigTerm sighandler)

(de void sig ((i32 . N))
   (if (val $TtyPid)
      (kill @ N)
      (set $Signal (+ (val $Signal) 1))
      (let P (ofs $Signal (gSignal N))
         (set P (+ (val P) 1)) ) ) )

(de void sigTerm ((i32 . N))
   (if (val $TtyPid)
      (kill @ N)
      (set $Signal (+ (val $Signal) 1))
      (let P (ofs $Signal (gSignal (val SIGTERM Sig)))
         (set P (+ (val P) 1)) ) ) )

(de void sighandler (Exe)
   (unless (val $Protect)
      (set $Protect 1)
      (let P T
         (loop
            (cond
               ((val (setq P (ofs $Signal SIGIO)))
                  (set P (dec @))
                  (set $Signal (dec (val $Signal)))
                  (execAt (val $Sigio)) )
               ((val (setq P (ofs $Signal SIGUSR1)))
                  (set P (dec @))
                  (set $Signal (dec (val $Signal)))
                  (execAt (val $Sig1)) )
               ((val (setq P (ofs $Signal SIGUSR2)))
                  (set P (dec @))
                  (set $Signal (dec (val $Signal)))
                  (execAt (val $Sig2)) )
               ((val (setq P (ofs $Signal SIGALRM)))
                  (set P (dec @))
                  (set $Signal (dec (val $Signal)))
                  (execAt (val $Alarm)) )
               ((val (setq P (ofs $Signal SIGHUP)))
                  (set P (dec @))
                  (set $Signal (dec (val $Signal)))
                  (execAt (val $Hup)) )
               ((val (setq P (ofs $Signal SIGINT)))
                  (set P (dec @))
                  (set $Signal (dec (val $Signal)))
                  (unless (val $PRepl)  # Not child of REPL process?
                     (wrnl)
                     (rlSigBeg)
                     (brkLoad (if Exe @ $Nil))
                     (rlSigEnd) ) )
               ((val (setq P (ofs $Signal SIGWINCH)))
                  (set P (dec @))
                  (set $Signal (dec (val $Signal)))
                  (execAt (val $Winch)) )
               ((val (setq P (ofs $Signal SIGTSTP)))
                  (set P (dec @))
                  (set $Signal (dec (val $Signal)))
                  (rlSigBeg)
                  (execAt (val $TStp1))  # Run 'TStp1'
                  (stopTerm)  # Stop
                  (iSignal (val SIGTSTP Sig) (fun sig))  # Set signal again
                  (execAt (val $TStp2))  # Run 'TStp2'
                  (rlSigEnd) )
               ((val (setq P (ofs $Signal SIGTERM)))
                  (if (nil? (run (val $Term)))
                     (let
                        (Cld (val $Child)  # Iterate children
                           <Cld (ofs Cld (* (val $Children) (child T)))
                           Flg NO )
                        (until (== Cld <Cld)
                           (let Cld: (child Cld)
                              (when
                                 (and
                                    (Cld: pid)
                                    (=0 (kill @ (val SIGTERM Sig))) )
                                 (setq Flg YES) ) )
                           (setq Cld (ofs Cld (child T))) )
                        (? Flg)
                        (set $Signal 0)
                        (rlSigBeg)
                        (bye 0) )
                     (set P (dec (val P)))
                     (set $Signal (dec (val $Signal))) ) ) )
            (? (=0 (val $Signal))) ) )
      (set $Protect 0) ) )

# Error handling
(local) (pushOutFile err stkErr argErr cntErr numErr symErr charErr extErr
nameErr atomErr pairErr lstErr varErr itemErr protErr lockErr forkErr symNspErr)

(de void pushOutFile (i8* i8* i32))

(de NIL err (Exe X (i8* . Fmt) (i8* . Arg))
   (set $Up (if Exe @ $Nil))
   (when X
      (link (push X NIL)) )  # Save
   (let Msg (b8 240)
      (gPrintf Msg 240 Fmt Arg)
      (when (val Msg)
         (set $Msg (mkStr Msg))
         (let Ca (val $Catch)
            (while Ca
               (let Ca: (caFrame Ca)
                  (let Tag (Ca: tag)
                     (when Tag
                        (while (pair Tag)
                           (when (subStr (car Tag) (val $Msg))
                              (unwind (Ca:))
                              (set $Ret
                                 (if (nil? (car Tag))
                                    (val $Msg)
                                    @ ) )
                              (longjmp (Ca: (rst)) 1) )
                           (shift Tag) ) ) )
                  (setq Ca (Ca: link)) ) ) ) )
      (flushAll)
      (set $Chr (set $ExtN 0))
      (set $Break 0)
      (set $LinePtr null)
      (set $Alarm (set $Sigio $Nil))
      (pushOutFile (b8 (ioFrame T)) (val 3 (val $OutFiles)) 0)  # Stderr
      (let In: (inFile (val $InFile))
         (when (and (In:) (In: name))
            (call $Put (char "["))
            (outString (In: name))
            (call $Put (char ":"))
            (outWord (i64 (In: src)))
            (call $Put (char "]"))
            (space) ) )
      (when Exe
         (outString ($ "!? "))
         (print Exe)
         (newline) )
      (when X
         (print X)
         (outString ($ " -- ")) )
      (when (val Msg)
         (outString Msg)
         (newline)
         (unless (or (nil? (val $Err)) (val $Jam))
            (set $Jam YES)
            (execAt (val $Err))
            (set $Jam NO) )
         (unless
            (and
               ((inFile (val (val $InFiles))) tty)
               ((outFile (val 2 (val $OutFiles))) tty) )
            (bye 1) )
         (repl 0 ($ "? ") $Nil) )
      (unwind null)
      (unless (val $StkLimit)
         (set $StkLimit (val $StkBrk)) )
      (set
         $Link 0
         $Protect 0
         $Next $Nil
         $Make 0
         $Yoke 0
         $Trace 0
         $Put (fun (void i8) _putStdout)
         $Get (fun (i32) _getStdin) )
      (longjmp QuitRst 1) ) )

(de NIL stkErr (Exe)
   (set $StkLimit null)
   (err Exe 0 ($ "Stack overflow") null) )

(de NIL argErr (Exe X)
   (err Exe X ($ "Bad argument") null) )

(de NIL cntErr (Exe X)
   (err Exe X ($ "Small number expected") null) )

(de NIL numErr (Exe X)
   (err Exe X ($ "Number expected") null) )

(de NIL symErr (Exe X)
   (err Exe X ($ "Symbol expected") null) )

(de NIL charErr (Exe X)
   (err Exe X ($ "Char expected") null) )

(de NIL extErr (Exe X)
   (err Exe X ($ "External symbol expected") null) )

(de NIL nameErr (Exe X)
   (err Exe X ($ "Name expected") null) )

(de NIL atomErr (Exe X)
   (err Exe X ($ "Atom expected") null) )

(de NIL pairErr (Exe X)
   (err Exe X ($ "Cons pair expected") null) )

(de NIL lstErr (Exe X)
   (err Exe X ($ "List expected") null) )

(de NIL varErr (Exe X)
   (err Exe X ($ "Variable expected") null) )

(de NIL itemErr (Exe X)
   (err Exe X ($ "Item not found") null) )

(de NIL protErr (Exe X)
   (err Exe X ($ "Protected") null) )

(de NIL lockErr ()
   (err 0 0 ($ "File lock: %s") (strErrno)) )

(de NIL forkErr (Exe)
   (err Exe 0 ($ "Can't fork") null) )

(de NIL symNspErr (Exe X)
   (err Exe X ($ "Bad symbol namespace") null) )

# Value access
(local) (xCnt evCnt evLst xSym evSym xName)

(de i64 xCnt (Exe X)
   (let N (int (needCnt Exe X))
      (if (sign? X) (- N) N) ) )

(de i64 evCnt (Exe X)
   (xCnt Exe (eval (car X))) )

(de evLst (Exe)
   (let X (eval (car Exe))
      (unless (or (pair X) (nil? X))
         (lstErr Exe X) )
      X ) )

(de xSym (X)
   (if (symb? X)
      X
      (let P (push 4 NIL ZERO NIL)  # [cnt last name link]
         (link (ofs P 2) T)
         (pack X P)
         (consStr (val 3 P)) ) ) )

(de evSym (Exe)
   (xSym (eval (car Exe))) )

(de xName (Exe Sym)
   (cond
      ((nil? Sym) ZERO)
      ((sym? (val (tail Sym))) (nameErr Exe Sym))
      (T (name @)) ) )

# Structure checks
(local) (circ funq)

(de circ (X)
   (if (atom X)
      0
      (let Y X
         (loop
            (set Y (| (val Y) 1))  # Mark
            (? (atom (shift Y))  # No circularity found
               (loop
                  (set X (& (val X) -2))  # Unmark
                  (? (atom (shift X))) )
               0 )
            (? (& (val Y) 1)  # Detected circularity
               (until (== X Y)  # Skip non-circular part
                  (set X (& (val X) -2))  # Unmark
                  (shift X) )
               (loop
                  (set X (& (val X) -2))  # Unmark
                  (? (== Y (shift X))) )
               Y ) ) ) ) )

(de funq (X)
   (cond
      ((cnt? X) X)
      ((or (big? X) (sym? X)) 0)
      ((circ X) 0)
      (T
         (let Y (cdr X)
            (loop
               (? (atom Y)
                  (cond
                     ((not (nil? Y)) 0)
                     ((nil? (setq X (car X))) $T)
                     ((== X $Tilde) 0)
                     ((circ (setq Y X)) 0)
                     (T
                        (loop
                           (? (atom Y)
                              (if (or (num? Y) (t? Y))
                                 0
                                 X ) )
                           (?
                              (or
                                 (not (symb? (++ Y)))
                                 (nil? @)
                                 (t? @) )
                              0 ) ) ) ) )
               (let Z (++ Y)
                  (if (pair Z)
                     (if (num? (car Z))
                        (? (pair Y) 0)
                        (? (or (nil? (car Z)) (t? (car Z)))
                           0 ) )
                     (? (not (nil? Y)) 0) ) ) ) ) ) ) )

# (tty . prg) -> any
(de _tty (Exe)
   (let (Out (val $OutFile)  Put (val (i8** $Put)))
      (set
         $OutFile (val 3 (val $OutFiles))  # Stderr
         $Put (fun (void i8) _putStdout) )
      (rlHide)
      (prog1
         (run (cdr Exe))
         (flush (val $OutFile))
         (rlShow)
         (set (i8** $Put) Put  $OutFile Out) ) ) )

# (raw ['flg]) -> flg
(de _raw (Exe)
   (let X (cdr Exe)
      (cond
         ((atom X)
            (if (val Termio) $T $Nil) )
         ((nil? (eval (car X))) (setCooked) @)
         (T (setRaw) @) ) ) )

# (alarm 'cnt . prg) -> cnt
(de _alarm (Exe)
   (let X (cdr Exe)
      (prog1
         (cnt (i64 (alarm (i32 (evCnt Exe X)))))
         (set $Alarm (cdr X)) ) ) )

# (sigio 'cnt . prg) -> cnt
(de _sigio (Exe)
   (let (X (cdr Exe)  Fd (evCnt Exe X))
      (set $Sigio (cdr X))
      (fcntlSetOwn (i32 Fd) (i32 (int (val $Pid))))
      (cnt Fd) ) )

# (kids) -> lst
(de _kids (Exe)
   (let
      (X $Nil
         Cld (val $Child)  # Iterate children
         <Cld (ofs Cld (* (val $Children) (child T))) )
      (until (== Cld <Cld)
         (when ((child Cld) pid)
            (setq X (cons (cnt (i64 @)) X)) )
         (setq Cld (ofs Cld (child T))) )
      X ) )

# (protect . prg) -> any
(de _protect (Exe)
   (let X (cdr Exe)
      (prog2
         (set $Protect (+ (val $Protect) 1))
         (run X)
         (set $Protect (- (val $Protect) 1)) ) ) )

# (heap 'flg) -> cnt
(de _heap (Exe)
   (if (nil? (eval (cadr Exe)))
      (let (N 1  P (val $Heaps))
         (while (setq P (val (ofs P HEAP)))
            (inc 'N) )
         (cnt N) )
      (let (N 0  P (val $Avail))
         (while P
            (inc 'N)
            (setq P (car P)) )
         (cnt (shr N (- 20 4))) ) ) )  # Divide by CELLS (1M/16)

# (stack ['cnt ['cnt]]) -> cnt | (.. (any . cnt) . cnt)
(de _stack (Exe)
   (let (X (cdr Exe)  Crt (val $Coroutines))
      (if (or (atom X) (and Crt ((coroutine Crt) nxt)))
         (let R (cnt (shr (val $StkSize) 10))
            (while Crt
               (let Crt: (coroutine Crt)
                  (when (Crt: tag)  # In use
                     (let P (Crt: lim)
                        (while (== 7 (val P))
                           (inc 'P) )
                        (setq R
                           (cons2
                              (Crt: tag)
                              (cnt (shr (- P (Crt: lim)) 10))
                              R ) ) ) )
                  (setq Crt (Crt: nxt)) ) )
            R )
         (let N (evCnt Exe X)
            (set $StkSize (shl N 10))
            (when (pair (shift X))
               (set $StkSizeT (shl (evCnt Exe X) 10)) )
            (when Crt
               (let (Siz (val $StkSizeT)  Stk (stack))
                  (memset
                     ((coroutine Crt) lim (stack (ofs Stk (- Siz))))
                     7 (- Siz 256) T )
                  (stack Stk) ) )
            (cnt N) ) ) ) )

# Date and time
(local) (tmDate tmTime)

(de tmDate ((i64 . Y) (i64 . M) (i64 . D))
   (if
      (and
         (gt0 Y)
         (gt0 M)
         (>= 12 M)
         (gt0 D)
         (or
            (>= (i64 (val (ofs $Month M))) D)
            (and
               (== D 29)
               (== M 2)
               (=0 (% Y 4))
               (or (% Y 100) (=0 (% Y 400))) ) ) )
      (let N (/ (+ (* Y 12) M -3) 12)
         (cnt
            (-
               (+
                  (/
                     (+ (* Y 4404) (* M 367) -1094)
                     12 )
                  (/ N 4)
                  (/ N 400)
                  D )
               (* 2 N)
               (/ N 100) ) ) )
      $Nil ) )

(de tmTime ((i64 . H) (i64 . M) (i64 . S))
   (if
      (and
         (ge0 H)
         (ge0 M)
         (> 60 M)
         (ge0 S)
         (> 60 S) )
      (cnt (+ (* H 3600) (* M 60) S))
      $Nil ) )

# (date ['T]) -> dat
# (date 'dat) -> (y m d)
# (date 'y 'm 'd) -> dat | NIL
# (date '(y m d)) -> dat | NIL
(de _date (Exe)
   (let X (cdr Exe)
      (cond
         ((atom X)
            (let N (getDate)
               (tmDate
                  (& N (hex "FFFF"))
                  (& (shr N 16) (hex "FF"))
                  (& (shr N 24) (hex "FF")) ) ) )
         ((t? (eval (car X)))
            (let N (getGmDate)
               (tmDate
                  (& N (hex "FFFF"))
                  (& (shr N 16) (hex "FF"))
                  (& (shr N 24) (hex "FF")) ) ) )
         ((nil? @) @)
         ((pair @)
            (let L @
               (tmDate
                  (xCnt Exe (++ L))
                  (xCnt Exe (++ L))
                  (xCnt Exe (car L)) ) ) )
         (T
            (let N @
               (cond
                  ((pair (shift X))
                     (tmDate
                        (xCnt Exe N)
                        (evCnt Exe X)
                        (evCnt Exe (cdr X)) ) )
                  ((lt0 (setq N (xCnt Exe N))) $Nil)
                  (T
                     (let Y (/ (- (* N 100) 20) 3652425)
                        (setq
                           N (+ N (- Y (/ Y 4)))
                           Y (/ (- (* N 100) 20) 36525)
                           N (* (- N (/ (* Y 36525) 100)) 10) )
                        (let
                           (M (/ (- N 5) 306)
                              D (/ (+ N (* M -306) 5) 10) )
                           (if (> 10 M)
                              (inc 'M 3)
                              (inc 'Y)
                              (dec 'M 9) )
                           (cons (cnt Y)
                              (cons (cnt M)
                                 (cons (cnt D) $Nil) ) ) ) ) ) ) ) ) ) ) )

# (time ['T]) -> tim
# (time 'tim) -> (h m s)
# (time 'h 'm ['s]) -> tim | NIL
# (time '(h m [s])) -> tim | NIL
(de _time (Exe)
   (let X (cdr Exe)
      (cond
         ((atom X) (cnt (getTime)))
         ((t? (eval (car X)))
            (if (lt0 (getGmTime)) $Nil (cnt @)) )
         ((nil? @) @)
         ((pair @)
            (let L @
               (tmTime
                  (xCnt Exe (++ L))
                  (xCnt Exe (++ L))
                  (if (pair L)
                     (xCnt Exe (car L))
                     0 ) ) ) )
         (T
            (let N @
               (cond
                  ((pair (shift X))
                     (tmTime
                        (xCnt Exe N)
                        (evCnt Exe X)
                        (if (pair (shift X)) (evCnt Exe X) 0) ) )
                  ((lt0 (setq N (xCnt Exe N))) $Nil)
                  (T
                     (cons (cnt (/ N 3600))
                        (cons (cnt (% (/ N 60) 60))
                           (cons (cnt (% N 60)) $Nil) ) ) ) ) ) ) ) ) )

# (usec ['flg]) -> num
(de _usec (Exe)
   (cnt
      (if (nil? (eval (cadr Exe)))
         (- (getUsec YES) (val $USec))
         (getUsec NO) ) ) )

# Try to load dynamic library
(local) sharedLib

(de i1 sharedLib (Sym)
   (let
      (Nm (xName 0 Sym)
         S (bufString Nm (b8 (bufSize Nm)))
         P (strchr S (char ":")) )
      (and
         P
         (<> P S)
         (val 2 P)
         (let N (val $PilLen)
            (set P 0)
            (let (Len (strlen S)  Q (b8 (+ N Len (+ 4 3 1))))
               (if (strchr S (char "/"))
                  (strcpy Q S)
                  (when N
                     (memcpy Q (val $PilHome) N) )
                  (strcpy (ofs Q N) ($ "lib/"))
                  (strcpy (ofs Q (+ N 4)) S)
                  (setq Len (+ Len N 4)) )
               (strcpy (ofs Q Len) ($ ".so"))
               (and
                  (dlOpen Q)
                  (dlsym @ (inc P))
                  (prog
                     (set Sym (| (i64 @) 2))
                     YES ) ) ) ) ) ) )

(load "gc.l" "big.l" "sym.l")

# Comparisons
(local) (equalBig equal compare)

(inline equalBig (X Y)
   (loop
      (? (<> (val (dig X)) (val (dig Y))) NO)
      (?
         (==
            (setq X (val (big X)))
            (setq Y (val (big Y))) )
         YES )
      (? (cnt? X) NO)
      (? (cnt? Y) NO) ) )

(de i1 equal (X Y)
   (cond
      ((== X Y) YES)
      ((cnt? X) NO)
      ((big? X)
         (if (cnt? Y)
            NO
            (when (sign? X)
               (unless (sign? Y)
                  (ret NO) )
               (setq X (pos X)  Y (pos Y)) )
            (equalBig X Y) ) )
      ((sym? X)
         (cond
            ((num? Y) NO)
            ((pair Y) NO)
            ((sym? (val (tail X))) NO)
            ((== ZERO (setq X (name @))) NO)
            ((sym? (val (tail Y))) NO)
            ((== ZERO (setq Y (name @))) NO)
            ((== X Y) YES)
            ((cnt? X) NO)
            ((cnt? Y) NO)
            (T (equalBig X Y)) ) )
      ((atom Y) NO)
      (T
         (stkChk 0)
         (let (A X  B Y)
            (prog1
               (loop
                  (? (not (equal (car X) (& (car Y) -2)))
                     NO)
                  (? (atom (cdr X))
                     (equal (cdr X) (cdr Y)) )
                  (? (atom (cdr Y)) NO)
                  (set X (| (val X) 1))  # Mark
                  (shift X)
                  (shift Y)
                  (? (& (val X) 1)  # Detected circularity
                     (prog1
                        (loop
                           (? (== A X)
                              (if (== B Y)
                                 (loop
                                    (shift A)
                                    (? (== (shift B) Y) (== A X))
                                    (? (== A X) YES) )
                                 NO ) )
                           (? (== B Y) NO)
                           (set A (& (val A) -2))  # Unmark
                           (shift A)
                           (shift B) )
                        (set A (& (val A) -2))  # Unmark
                        (shift A) ) ) )
               (until (== A X)
                  (set A (& (val A) -2))  # Unmark
                  (shift A) ) ) ) ) ) )

(de i64 compare (X Y)
   (cond
      ((== X Y) 0)
      ((nil? X) -1)
      ((t? X) +1)
      ((num? X)
         (cond
            ((num? Y) (cmpNum X Y))
            ((nil? Y) +1)
            (T -1) ) )
      ((sym? X)
         (cond
            ((or (num? Y) (nil? Y)) +1)
            ((or (pair Y) (t? Y)) -1)
            (T
               (let
                  (NmX (name (& (val (tail X)) -9))
                     NmY (name (& (val (tail Y)) -9)) )
                  (cond
                     ((== ZERO NmX)
                        (nond
                           ((== ZERO NmY) -1)
                           ((== X Y) 0)
                           ((> X Y) +1)
                           (NIL -1) ) )
                     ((== ZERO NmY) +1)
                     (T
                        (loop
                           (let
                              (A
                                 (if (cnt? NmX)
                                    (prog1
                                       (shr (shl (name NmX) 2) 6)  # Clear status bits
                                       (setq NmX 0) )
                                    (prog1
                                       (val (dig NmX))  # Next digit
                                       (setq NmX (val (big NmX))) ) )
                                 B
                                 (if (cnt? NmY)
                                    (prog1
                                       (shr (shl (name NmY) 2) 6)  # Clear status bits
                                       (setq NmY 0) )
                                    (prog1
                                       (val (dig NmY))  # Next digit
                                       (setq NmY (val (big NmY))) ) ) )
                              (loop
                                 (when (- (& A 255) (& B 255))
                                    (ret (if (gt0 @) +1 -1)) )
                                 (? (=0 (setq A (shr A 8)))
                                    (when (setq B (shr B 8))
                                       (ret -1) )
                                    (unless NmX
                                       (ret (if NmY -1 0)) )
                                    (unless NmY
                                       (ret +1) ) )
                                 (unless (setq B (shr B 8))
                                    (ret +1) ) ) ) ) ) ) ) ) ) )
      ((atom Y) (if (t? Y) -1 +1))
      (T
         (stkChk 0)
         (let (A X  B Y)
            (loop
               (? (compare (car X) (car Y)) @)
               (? (atom (shift X))
                  (compare X (cdr Y)) )
               (? (atom (shift Y))
                  (if (t? Y) -1 +1) )
               (? (and (== X A) (== Y B)) 0)
               (sigChk 0) ) ) ) ) )

# Evaluation
(local) (undefined evExpr evList)

(de NIL undefined (Fun Exe)
   (err Exe Fun ($ "Undefined") null) )

# Apply EXPR to CDR of list
(de evExpr (Exe Lst)
   (stkChk Exe)
   (let
      (X (cdr Lst)  # Arguments
         Y (car Exe)  # Parameters
         P (set $Bind (push (val $At) $At (val $Bind) Lst)) )  # [[@] @ LINK Expr]
      (while (pair Y)
         (let (V (eval (++ X))  Z (++ Y))  # Evaluate next argument
            (if (atom Z)
               (set $Bind
                  (setq P (push V (needChkVar Exe Z) P)) )  # [val sym LINK]
               (loop
                  (set $Bind
                     (setq P
                        (push  # [val sym LINK]
                           (if (pair V) (++ V) $Nil)
                           (needChkVar Exe (++ Z))
                           P ) ) )
                  (? (atom Z)) )
               (unless (nil? Z)
                  (set $Bind
                     (setq P (push V (needChkVar Exe Z) P)) ) ) ) ) )  # [val sym LINK]
      (prog1
         (if (== Y $At)  # VarArgs
            (if (pair X)
               (let (L (push NIL (eval (car X)) NIL)  Q L)
                  (link (ofs L 1))
                  (while (pair (shift X))
                     (setq L
                        (set L (push NIL (eval (car X)) NIL)) )
                     (link (ofs L 1)) )
                  (let Next (val $Next)
                     (set L $Nil  $Next Q)
                     (loop
                        (let Sym (val 2 P)
                           (xchg Sym P)  # Exchange symbol value
                           (? (== $At Sym))
                           (setq P (val 3 P)) ) )
                     (prog1
                        (run (cdr Exe))  # Run body
                        (set $Next Next)
                        (drop (ofs Q 1)) ) ) )
               (let Next (val $Next)
                  (set $Next $Nil)
                  (loop
                     (let Sym (val 2 P)
                        (xchg Sym P)  # Exchange symbol value
                        (? (== $At Sym))
                        (setq P (val 3 P)) ) )
                  (prog1
                     (run (cdr Exe))  # Run body
                     (set $Next Next) ) ) )
            (unless (nil? Y)
               (needChkVar Exe Y)
               (set
                  $Bind (push (val Y) Y P)  # Last parameter
                  Y X ) )  # Set to unevaluated argument(s)
            (loop
               (let Sym (val 2 P)
                  (xchg Sym P)  # Exchange symbol value
                  (? (== $At Sym))
                  (setq P (val 3 P)) ) )
            (run (cdr Exe)) )  # Run body
         (setq P (val $Bind))
         (loop
            (let Sym (val 2 P)
               (set Sym (val P))  # Restore values
               (? (== $At Sym))
               (setq P (val 3 P)) ) )
         (set $Bind (val 3 P)) ) ) )

(de evList (Exe)
   (let Fun (car Exe)
      (cond
         ((num? Fun) Exe)  # Number: Return list
         ((sym? Fun)  # Symbol: Find function
            (loop
               (sigChk Exe)
               (let V (val Fun)  # Get VAL
                  (? (num? V) (subr V Exe Fun))
                  (? (pair V) (evExpr V Exe))
                  (? (== V (val V))
                     (if (sharedLib Fun)
                        (subr (val Fun) Exe Fun)
                        (undefined Fun Exe) ) )
                  (setq Fun V) ) ) )
         (T  # List: Evaluate
            (stkChk Exe)
            (let F (save (evList Fun))  # Save computed function
               (loop
                  (sigChk Exe)
                  (? (num? F) (subr F Exe Fun))
                  (? (pair F) (evExpr F Exe))
                  (let V (val F)
                     (? (== V (val V))
                        (if (sharedLib F)
                           (subr (val F) Exe F)
                           (undefined F Exe) ) )
                     (setq Fun F  F V) ) ) ) ) ) ) )

(load "io.l" "db.l" "apply.l" "flow.l" "subr.l")

# (quit ['any ['any]])
(de _quit (Exe)
   (let
      (X (cdr Exe)
         Nm (xName Exe (evSym X))
         Msg (bufString Nm (b8 (bufSize Nm))) )
      (err 0
         (if (atom (shift X))
            0
            (eval (car X)) )
         ($ "%s")
         Msg ) ) )

# (sys 'any ['any]) -> sym
(de _sys (Exe)
   (let
      (X (cdr Exe)
         Nm (xName Exe (evSym X))
         S (bufString Nm (b8 (bufSize Nm))) )
      (if (atom (shift X))
         (mkStr (getenv S))
         (let (Y (evSym X)  Nm2 (xName Exe Y))
            (if
               (setenv S
                  (bufString Nm2 (b8 (bufSize Nm2)))
                  1 )
               $Nil
               Y ) ) ) ) )

# (pwd) -> sym
(de _pwd (Exe)
   (let P (getcwd null 0)
      (if P
         (prog1 (mkStr P) (free P))
         $Nil ) ) )

# (cd 'any) -> sym
(de _cd (Exe)
   (let
      (Nm (xName Exe (evSym (cdr Exe)))
         P (getcwd null 0) )
      (if P
         (prog1
            (if (lt0 (chdir (pathString Nm (b8 (pathSize Nm)))))
               $Nil
               (mkStr P) )
            (free P) )
         $Nil ) ) )

# (ctty 'pid) -> pid
# (ctty 'any) -> any | NIL
(de _ctty (Exe)
   (let X (eval (cadr Exe))
      (cond
         ((cnt? X)
            (set $TtyPid (i32 (int @)))
            X )
         ((nil? X)
            (let Pty (b32 2)  # Master + Slave
               (when (lt0 (openpty Pty (ofs Pty 1) null null null))
                  (err Exe 0 ($ "Can't open PTY: %s") (strErrno)) )
               (cond
                  ((lt0 (fork)) (forkErr Exe))
                  ((=0 @)  # Master in child
                     (close (val 2 Pty))
                     (let (Fd (val Pty)  Poll (b64 2)  Buf (b8 BUFSIZ))
                        (loop
                           (pollIn 0 Poll)
                           (pollIn Fd (ofs Poll 1))
                           (if (lt0 (poll Poll 2 -1))
                              (? (<> (gErrno) EINTR))
                              (when (readyIn Poll)
                                 (let N (read 0 Buf BUFSIZ)
                                    (? (le0 N))
                                    (write Fd Buf N) ) )
                              (when (readyIn (ofs Poll 1))
                                 (let N (read Fd Buf BUFSIZ)
                                    (? (le0 N))
                                    (write 1 Buf N) ) ) ) )
                        (exit 0) ) ) )
               # Slave in parent
               (close (val Pty))
               (login_tty (val 2 Pty)) )
            (signal (val SIGINT Sig) (val SigIgn))
            ((inFile (val (val $InFiles))) tty YES)
            ((outFile (val 2 (val $OutFiles))) tty YES)
            ((outFile (val 3 (val $OutFiles))) tty YES)
            (set Tio (=0 (tcgetattr 0 OrgTermio)))  # Init terminal I/O
            $T )
         (T
            (let Nm (xName Exe (xSym X))
               (if (reopenTty (bufString Nm (b8 (bufSize Nm))))
                  (let
                     (In: (inFile (val (val $InFiles)))  # Stdin
                        Out: (outFile (val 2 (val $OutFiles))) )  # Stdout
                     (In: chr 0)
                     (In: ix (In: cnt 0))
                     (In: tty YES)
                     (set Tio (=0 (tcgetattr 0 OrgTermio)))  # Save terminal I/O
                     (Out: ix 0)
                     (Out: tty YES)
                     ((outFile (val 3 (val $OutFiles))) tty YES)  # Stderr
                     X )
                  $Nil ) ) ) ) ) )

# (cmd ['any]) -> sym
(de _cmd (Exe)
   (if (nil? (evSym (cdr Exe)))
      (mkStr (val $AV0))
      (bufString (xName Exe @) (val $AV0))
      @ ) )

# (dir ['any] ['flg]) -> lst
(de _dir (Exe)
   (let X (cdr Exe)
      (if
         (getDir
            (if (nil? (evSym X))
               ($ ".")
               (let Nm (xName Exe @)
                  (pathString Nm (b8 (pathSize Nm))) ) ) )
         (let (P @  F (eval (car (shift X))))
            (when (nil? F)
               (while (== (val P) (char "."))
                  (unless (setq P (getDir null))
                     (ret $Nil) ) ) )
            (let (Y (cons (mkStr P) $Nil)  R (save Y))
               (while (setq P (getDir null))
                  (unless (and (nil? F) (== (val P) (char ".")))
                     (setq Y (set 2 Y (cons (mkStr P) $Nil))) ) )
               R ) )
         $Nil ) ) )

# (info 'any ['flg]) -> (cnt|flg dat . tim)
(de _info (Exe)
   (let
      (X (cdr Exe)
         Nm (xName Exe (set $At2 (evSym X)))
         Size (b64 1) )
      (if
         (lt0
            (fileInfo
               (nil? (eval (car (shift X))))
               (pathString Nm (b8 (pathSize Nm)))
               Size ) )
         $Nil
         (let N @
            (cons
               (case (& N 3)
                  (1 $T)
                  (2 $Nil)
                  (T (box64 (val Size))) )
               (cons
                  (tmDate
                     (& (setq N (shr N 2)) (hex "FFFF"))
                     (& (setq N (shr N 16)) (hex "FF"))
                     (& (setq N (shr N 8)) (hex "FF")) )
                  (cnt (shr N 8)) ) ) ) ) ) )

# (file) -> (sym1 sym2 . num) | NIL
(de _file (Exe)
   (let In: (inFile (val $InFile))
      (ifn (and (In:) (In: name))
         $Nil
         (let
            (N (cnt (i64 (In: src)))
               S (In: name)
               P (strrchr S (char "/")) )
            (if P
               (let X (save (mkStrE S (inc 'P)))
                  (cons X (cons (mkStr P) N)) )
               (cons $Nil (cons (mkStr S) N)) ) ) ) ) )

# (argv [var ..] [. sym]) -> lst|sym
(de _argv (Exe)
   (let (X (cdr Exe)  A (val $AV)  P (val A))
      (when
         (and
            P
            (== (val P) (char "-"))
            (=0 (val 2 P)) )  # Single-dash argument
         (inc 'A) )  # Skip "-"
      (if (nil? X)  # No args
         (if (setq P (val A))
            (let (Y (cons (mkStr P) $Nil)  R (save Y))
               (while (setq P (val (inc 'A)))
                  (setq Y (set 2 Y (cons (mkStr P) $Nil))) )
               R )
            $Nil )
         (loop
            (? (atom X)
               (set (needChkVar Exe X)
                  (if (setq P (val A))
                     (let (Y (cons (mkStr P) $Nil)  R Y)
                        (save R
                           (while (setq P (val (inc 'A)))
                              (setq Y (set 2 Y (cons (mkStr P) $Nil))) ) )
                        R )
                     $Nil ) ) )
            (let Y
               (ifn (setq P (val A))
                  $Nil
                  (inc 'A)
                  (mkStr P) )
               (set (needChkVar Exe (++ X)) Y)
               (? (nil? X) Y) ) ) ) ) )

# (opt) -> sym
(de _opt (Exe)
   (let (A (val $AV)  P (val A))
      (if
         (or
            (=0 P)
            (and
               (== (val P) (char "-"))
               (=0 (val 2 P)) ) )
         $Nil
         (set $AV (inc A))
         (mkStr P) ) ) )

# (errno) -> cnt
(de _errno (Exe)
   (cnt (i64 (nErrno))) )

# Native calls
(local) (fetchChar natBuf natErr natRetFloat natRetDouble natRetBuf ffi)

(de i32 fetchChar ((i8** . Ptr))
   (let (P (val Ptr)  C (i32 (val P)))
      (prog2
         (inc 'P)
         (cond
            ((>= 127 C) C)  # Single byte
            ((== C (hex "FF")) (i32 TOP))  # Infinite
            (T
               (|
                  (shl
                     (ifn (& C (hex "20"))
                        (& C (hex "1F"))
                        (|
                           (shl
                              (ifn (& C (hex "10"))
                                 (& C (hex "0F"))
                                 (|
                                    (shl (& C (hex "7")) 6)
                                    (&
                                       (i32 (prog1 (val P) (inc 'P)))
                                       (hex "3F") ) ) )
                              6 )
                           (&
                              (i32 (prog1 (val P) (inc 'P)))
                              (hex "3F") ) ) )
                     6 )
                  (&
                     (i32 (prog1 (val P) (inc 'P)))
                     (hex "3F") ) ) ) )
         (set Ptr P) ) ) )

(de i64 natBuf (Val (i8* . Ptr))
   (if (atom Val)  # Byte or unsigned
      (if (sign? Val)  # Unsigned 32 bit
         (let P (i32* Ptr)
            (set P (i32 (int Val)))
            4 )
         (set Ptr (i8 (int Val)))
         1 )
      (let X (++ Val)  # 'num', 'sym' or [-]1.0
         (if (cnt? Val)  # 'cnt' or 'lst'
            (let Siz (int Val)
               (cond
                  ((num? X)  # (num . cnt)
                     (let N
                        (if (cnt? X)
                           (int @)
                           (val (dig @)) )
                        (when (sign? X)
                           (setq N (- N)) )
                        (case Siz
                           (1 (set Ptr (i8 N)))
                           (2 (set (i16* Ptr) (i16 N)))
                           (4 (set (i32* Ptr) (i32 N)))
                           (T (set (i64* Ptr) N)) ) ) )
                  ((nil? X) (set Ptr (i8 0)))
                  ((sym? X)  # (sym . cnt)
                     (setq X (name (val (tail X))))
                     (bufString X Ptr) ) )
               Siz )
            (let (N 0  Scl (int X))
               (if (sign? X)  # ([-]1.0 . lst)
                  (while (pair Val)
                     (bufFloat (++ Val) Scl Ptr)
                     (inc 'N 4)
                     (setq Ptr (ofs Ptr 4)) )
                  (while (pair Val)
                     (bufDouble (++ Val) Scl Ptr)
                     (inc 'N 8)
                     (setq Ptr (ofs Ptr 8)) ) )
               N ) ) ) ) )

(de NIL natErr (Spec)
   (err 0 Spec ($ "Bad result spec") null) )

(de natRetFloat ((i32 . Val) (i64 . Scl))
   (let R (boxFloat Val Scl)
      (unless R
         (let X (setq R (save (boxNum (val Fdigit))))
            (until (boxFlt)
               (setq X (set (big X) (boxNum (val Fdigit)))) )
            (set (big X) @) ) )
      (if (val Fsign) (neg R) R) ) )

(de natRetDouble ((i64 . Val) (i64 . Scl))
   (let R (boxDouble Val Scl)
      (unless R
         (let X (setq R (save (boxNum (val Fdigit))))
            (until (boxDbl)
               (setq X (set (big X) (boxNum (val Fdigit)))) )
            (set (big X) @) ) )
      (if (val Fsign) (neg R) R) ) )

(de natRetBuf (Spec (i8** . Ptr))
   (cond
      ((t? Spec)  # 'T' Direct Lisp value
         (let P (i64* (val Ptr))
            (set Ptr (i8* (inc P)))
            (val P) ) )
      ((== Spec $N)  # 'N' Number (signed 64 bit)
         (let P (i64* (val Ptr))
            (set Ptr (i8* (inc P)))
            (box (val P)) ) )
      ((== Spec $P)  # 'P' Pointer (unsigned 64 bit)
         (let P (i64* (val Ptr))
            (set Ptr (i8* (inc P)))
            (box64 (val P)) ) )
      ((== Spec $I)  # 'I' Integer (signed 32 bit)
         (if
            (ge0
               (let P (i32* (val Ptr))
                  (set Ptr (i8* (inc P)))
                  (val P) ) )
            (cnt (i64 @))
            (sign (cnt (i64 (- @)))) ) )
      ((== Spec $C)  # 'C' Character (UTF-8, 1-4 bytes)
         (if (fetchChar Ptr) (mkChar @) $Nil) )
      ((== Spec $W)  # 'W' Word (signed 16 bit)
         (if
            (ge0
               (let P (i16* (val Ptr))
                  (set Ptr (i8* (inc P)))
                  (val P) ) )
            (cnt (i64 @))
            (sign (cnt (i64 (- @)))) ) )
      ((== Spec $B)  # 'B' Byte (unsigned 8 bit)
         (let P (val Ptr)
            (set Ptr (inc P))
            (cnt (i64 (val P))) ) )
      ((== Spec $S)  # 'S' String (UTF-8)
         (let P (i8** (val Ptr))
            (set Ptr (i8* (inc P)))
            (mkStr (val P)) ) )
      ((cnt? Spec)  # [+-]1.0 Scaled fixpoint number
         (if (sign? Spec)
            (natRetFloat
               (let P (i32* (val Ptr))
                  (set Ptr (i8* (inc P)))
                  (val P) )
               (int Spec) )
            (natRetDouble
               (let P (i64* (val Ptr))
                  (set Ptr (i8* (inc P)))
                  (val P) )
               (int Spec) ) ) )
      ((pair Spec)  # Arrary or structure
         (let (S (++ Spec)  R (natRetBuf S Ptr))
            (unless (and (nil? R) (== S $C))
               (let X (setq R (save (cons R $Nil)))
                  (loop
                     (? (cnt? Spec)  # (sym . cnt)
                        (let C (int Spec)
                           (while (dec 'C)
                              (let Y (natRetBuf S Ptr)
                                 (? (and (nil? Y) (== S $C)))
                                 (setq X (set 2 X (cons Y $Nil))) ) ) ) )
                     (? (atom Spec))
                     (let Y (natRetBuf (setq S (++ Spec)) Ptr)
                        (? (and (nil? Y) (== S $C)))
                        (setq X (set 2 X (cons Y $Nil))) ) ) ) )
            R ) )
      (T (natErr Spec)) ) )

(de ffi (Exe (i8* . Lib) Fun Args)
   (let
      (Spec (car Args)
         Val
         (ffiCall
            (cond
               ((cnt? Fun) (i8* (int Fun)))
               ((big? Fun) (i8* (val (dig Fun))))
               ((pair Fun) (argErr Exe Fun))
               (T
                  (let Nm (xName Exe Fun)
                     (unless (ffiPrep Lib (bufString Nm (b8 (bufSize Nm))) Args)
                        (err Exe 0 ($ "Bad ffi") null) )
                     (set Fun (box64 (i64 @)))
                     @ ) ) )
            (cdr Args) ) )
      (cond
         ((nil? Spec) $Nil)
         ((== Spec $T) Val)  # 'T' Direct Lisp value
         ((== Spec $N) (box Val))  # 'N' Number (signed 64 bit)
         ((== Spec $P) (box64 Val))  # 'P' Pointer (unsigned 64 bit)
         ((== Spec $I)  # 'I' Integer (signed 32 bit)
            (if (ge0 (i32 Val))
               (cnt (i64 @))
               (sign (cnt (i64 (- @)))) ) )
         ((== Spec $C)  # 'C' Character (UTF-8, 1-4 bytes)
            (if (i32 Val) (mkChar @) $Nil) )
         ((== Spec $W)  # 'W' Word (signed 16 bit)
            (if (ge0 (i16 Val))
               (cnt (i64 @))
               (sign (cnt (i64 (- @)))) ) )
         ((== Spec $B)  # 'B' Byte (unsigned 8 bit)
            (cnt (i64 (i8 Val))) )
         ((== Spec $S)  # 'S' String (UTF-8)
            (mkStr (i8* Val)) )
         ((cnt? Spec)  # [+-]1.0 Scaled fixpoint number
            (if (sign? Spec)
               (natRetFloat (i32 Val) (int Spec))
               (natRetDouble Val (int Spec)) ) )
         ((and (pair Spec) Val)  # Arrary or structure
            (let
               (Ptr (i8** (push Val))
                  S (++ Spec)
                  R (natRetBuf S Ptr) )
               (unless (and (nil? R) (== S $C))
                  (let X (setq R (save (cons R $Nil)))
                     (loop
                        (? (cnt? Spec)  # (sym . cnt)
                           (let C (int Spec)
                              (while (dec 'C)
                                 (let Y (natRetBuf S Ptr)
                                    (? (and (nil? Y) (== S $C)))
                                    (setq X (set 2 X (cons Y $Nil))) ) ) ) )
                        (? (atom Spec))
                        (let Y (natRetBuf (setq S (++ Spec)) Ptr)
                           (? (and (nil? Y) (== S $C)))
                           (setq X (set 2 X (cons Y $Nil))) ) ) ) )
               R ) )
         (T (natErr Spec)) ) ) )

# (%@ 'cnt2|sym2 'any 'any ..) -> any
(de _nat (Exe)
   (let
      (X (cdr Exe)
         Fun (save (eval (++ X)))  # Eval function 'cnt2|sym2'
         Args (save (cons (eval (++ X)) $Nil))
         L Args )  # [ret args]
      (while (pair X)
         (let Z (push (save (eval (++ X))) $Nil)  # [argN next]
            (set 2 L Z)
            (setq L Z) ) )
      (tailcall (ffi Exe null Fun Args)) ) )

# (native 'cnt1|sym1 'cnt2|sym2 'any 'any ..) -> any
(de _native (Exe)
   (let
      (X (cdr Exe)
         Y (eval (++ X))  # Eval library 'cnt1|sym1'
         Lib
         (cond
            ((cnt? Y) (i8* (int Y)))
            ((big? Y) (i8* (val (dig Y))))
            ((pair Y) (argErr Exe Y))
            ((== (xName Exe Y) (| 2 (>> -4 (char "@"))))
               (set Y ZERO)
               null )  # RTLD_DEFAULT
            (T
               (unless (dlOpen (pathString @ (b8 (pathSize @))))
                  (err Exe Y ($ "[DLL] %s") (dlerror)) )
               (set Y (box64 (i64 @)))
               @ ) )
         Fun (save (eval (++ X)))  # Eval function 'cnt2|sym2'
         Args (save (cons (eval (++ X)) $Nil))
         L Args )  # [ret args]
      (while (pair X)
         (let Z (push (save (eval (++ X))) $Nil)  # [argN next]
            (set 2 L Z)
            (setq L Z) ) )
      (tailcall (ffi Exe Lib Fun Args)) ) )

# (struct 'num 'any 'any ..) -> any
(de _struct (Exe)
   (let
      (X (cdr Exe)
         N  # Native value (pointer or scalar)
         (if (cnt? (needNum Exe (eval (++ X))))
            (int @)
            (val (dig @)) )
         P (i8* N)
         Y (save (eval (car X))) )  # Result specification
      (while (pair (shift X))
         (setq P
            (ofs P (natBuf (eval (car X)) P)) ) )
      (cond
         ((nil? Y) @)
         ((== Y $S) (mkStr (i8* N)))
         (T (natRetBuf Y (i8** (push N)))) ) ) )

# Lisp callbacks
(local) cbl

(de cbl (Fun A B C D E)
   (let Exe (push NIL NIL ZERO Fun)  # [car cdr name fun]
      (set Exe (ofs Exe 3))
      (let P (set 2 Exe (push NIL NIL ZERO (box A)))
         (set P (ofs P 3))
         (setq P
            (set 2 P (push NIL NIL ZERO (box B))) )
         (set P (ofs P 3))
         (setq P
            (set 2 P (push NIL NIL ZERO (box C))) )
         (set P (ofs P 3))
         (setq P
            (set 2 P (push NIL NIL ZERO (box D))) )
         (set P (ofs P 3))
         (setq P
            (set 2 P (push NIL $Nil ZERO (box E))) )
         (set P (ofs P 3)) )
      (xCnt 0 (evList Exe)) ) )

(de _cb1 (A B C D E)
   (cbl (val 2 $Lisp) A B C D E) )

(de _cb2 (A B C D E)
   (cbl (val 4 $Lisp) A B C D E) )

(de _cb3 (A B C D E)
   (cbl (val 6 $Lisp) A B C D E) )

(de _cb4 (A B C D E)
   (cbl (val 8 $Lisp) A B C D E) )

(de _cb5 (A B C D E)
   (cbl (val 10 $Lisp) A B C D E) )

(de _cb6 (A B C D E)
   (cbl (val 12 $Lisp) A B C D E) )

(de _cb7 (A B C D E)
   (cbl (val 14 $Lisp) A B C D E) )

(de _cb8 (A B C D E)
   (cbl (val 16 $Lisp) A B C D E) )

(de _cb9 (A B C D E)
   (cbl (val 18 $Lisp) A B C D E) )

(de _cb10 (A B C D E)
   (cbl (val 20 $Lisp) A B C D E) )

(de _cb11 (A B C D E)
   (cbl (val 22 $Lisp) A B C D E) )

(de _cb12 (A B C D E)
   (cbl (val 24 $Lisp) A B C D E) )

(de _cb13 (A B C D E)
   (cbl (val 26 $Lisp) A B C D E) )

(de _cb14 (A B C D E)
   (cbl (val 28 $Lisp) A B C D E) )

(de _cb15 (A B C D E)
   (cbl (val 30 $Lisp) A B C D E) )

(de _cb16 (A B C D E)
   (cbl (val 32 $Lisp) A B C D E) )

(de _cb17 (A B C D E)
   (cbl (val 34 $Lisp) A B C D E) )

(de _cb18 (A B C D E)
   (cbl (val 36 $Lisp) A B C D E) )

(de _cb19 (A B C D E)
   (cbl (val 38 $Lisp) A B C D E) )

(de _cb20 (A B C D E)
   (cbl (val 40 $Lisp) A B C D E) )

(de _cb21 (A B C D E)
   (cbl (val 42 $Lisp) A B C D E) )

(de _cb22 (A B C D E)
   (cbl (val 44 $Lisp) A B C D E) )

(de _cb23 (A B C D E)
   (cbl (val 46 $Lisp) A B C D E) )

(de _cb24 (A B C D E)
   (cbl (val 48 $Lisp) A B C D E) )

# (lisp 'sym ['fun]) -> num
(de _lisp (Exe)
   (let (X (cdr Exe)  Y (evSym X))
      (let (P $Lisp  Q (i8** (cbFuns)))
         (loop  # Search for tag 'sym'
            (? (== Y (val P)))  # Found
            (setq P (ofs P 2)  Q (ofs Q 1))
            (? (> P $LispEnd)  # Not found
               (setq P $Lisp  Q (i8** (cbFuns)))
               (until (nil? (val 2 P))  # Search for empty slot
                  (setq P (ofs P 2)  Q (ofs Q 1))
                  (when (> P $LispEnd)
                     (err Exe 0 ($ "Too many callbacks") null) ) )
               (set P Y) ) )
         (set 2 P (eval (cadr X)))  # Eval 'fun'
         (box64 (i64 (val Q))) ) ) )

# (args) -> flg
(de _args (Exe)
   (if (pair (val $Next)) $T $Nil) )

# (next) -> any
(de _next (Exe)
   (let X (val $Next)
      (set $Next (car X))
      (cdr X) ) )

# (arg 'cnt) -> any
(de _arg (Exe)
   (if (le0 (evCnt Exe (cdr Exe)))
      $Nil
      (let (N @  X (val $Next))
         (while (gt0 (dec 'N))
            (setq X (car X)) )
         (cdr X) ) ) )

# (rest) -> lst
(de _rest (Exe)
   (let X (val $Next)
      (if (atom X)
         X
         (let (Y (cons (cdr X) $Nil)  R (save Y))
            (while (pair (setq X (car X)))
               (setq Y (set 2 Y (cons (cdr X) $Nil))) )
            R ) ) ) )

# (adr 'var) -> num
# (adr 'num) -> var
(de _adr (Exe)
   (cond
      ((cnt? (eval (cadr Exe))) (int @))  # Make 'var'
      ((big? @) (val (dig @)))
      (T (box64 @)) ) )  # Make 'num'

# (byte 'num ['cnt]) -> cnt
(de _byte (Exe)
   (let
      (X (cdr Exe)
         P
         (i8*
            (if (cnt? (needNum Exe (eval (++ X))))
               (int @)
               (val (dig @)) ) ) )
      (if (atom X)
         (cnt (i64 (val P)))
         (let
            (Y (needCnt Exe (eval (car X)))
               N (int @) )
            (set P
               (i8 (if (sign? Y) (- N) N)) )
            Y ) ) ) )

# (env ['lst] | ['sym 'val] ..) -> lst
(de _env (Exe)
   (let (X (cdr Exe)  R (save $Nil))
      (if (atom X)
         (let Bnd (val $Bind)
            (while Bnd
               (let (S (val 2 Bnd)  Y R)
                  (loop
                     (? (atom Y)
                        (setq R
                           (safe (cons (cons S (val S)) R)) ) )  # (sym . val)
                     (? (== S (caar Y)))
                     (shift Y) ) )
               (setq Bnd (val 3 Bnd)) ) )
         (let Y (link (push $Nil NIL))
            (loop
               (let Z (set Y (eval (++ X)))  # Eval 'lst' or 'sym'
                  (nond
                     ((atom Z)
                        (loop
                           (let V (++ Z)
                              (setq R
                                 (safe
                                    (cons
                                       (if (pair V)
                                          (cons (car V) (cdr V))
                                          (cons V (val V)) )
                                       R ) ) ) )
                           (? (atom Z)) ) )
                     ((nil? Z)
                        (setq R
                           (safe (cons (cons Z (eval (++ X))) R)) ) ) ) )
                  (? (atom X)) ) ) )
      R ) )

# (trail ['flg]) -> lst
(de _trail (Exe)
   (let
      (F (not (nil? (eval (cadr Exe))))
         Bnd (val $Bind)
         R $Nil )
      (while Bnd
         (let S (val 2 Bnd)
            (cond
               ((== S $At)
                  (when (val 4 Bnd)
                     (setq R (cons @ R)) ) )  # Expr
               (F
                  (setq R (cons S (cons (val S) R)))
                  (set S (val Bnd)) ) ) )
         (setq Bnd (val 3 Bnd)) )
      (let X R
         (until (atom X)
            (when (atom (++ X))
               (set @ (++ X)) ) ) )
      R ) )

# (up [cnt] sym ['val]) -> any
(de _up (Exe)
   (let
      (X (cdr Exe)
         Y (car X)
         N 1
         Bnd (val $Bind) )
      (when (num? Y)
         (setq N (int Y)  Y (car (shift X))) )
      (if (nil? Y)
         (if N
            (loop
               (? (=0 Bnd) $Nil)
               (?
                  (and
                     (== $At (val 2 Bnd))
                     (=0 (dec 'N)) )
                  (if (val 4 Bnd) @ $Nil) )
               (setq Bnd (val 3 Bnd)) )
            $Nil )
         (let Z Y
            (when N
               (loop
                  (? (=0 Bnd))
                  (?
                     (and
                        (== Y (val 2 Bnd))
                        (prog
                           (setq Z Bnd)
                           (=0 (dec 'N)) ) ) )
                  (setq Bnd (val 3 Bnd)) ) )
            (if (atom (shift X))
               (val Z)
               (set Z (eval (car X))) ) ) ) ) )

# (history ['lst]) -> lst
(de _history (Exe)
   (let X (cdr Exe)
      (if (atom X)
         (let P (history_list)
            (if (and P (val P))
               (let
                  (Y (cons (mkStr (val (val P))) $Nil)
                     R (save Y)
                     I 0 )
                  (while (val (ofs P (inc 'I)))
                     (setq Y
                        (set 2 Y (cons (mkStr (val @)) $Nil)) ) )
                  R )
               $Nil ) )
         (let (Y (needLst Exe (eval (car X)))  Z Y)
            (clear_history)
            (while (pair Z)
               (let (Nm (xName Exe (xSym (++ Z)))  Stk (stack))
                  (add_history (bufString Nm (b8 (bufSize Nm))) )
                  (stack Stk) ) )
            Y ) ) ) )

# (version ['flg]) -> lst
(de _version (Exe)
   (when (nil? (eval (cadr Exe)))
      (outWord (int (val $Y)))
      (call $Put (char "."))
      (outWord (int (val $M)))
      (call $Put (char "."))
      (outWord (int (val $D)))
      (newline) )
   (cons (val $Y)
      (cons (val $M)
         (cons (val $D) $Nil) ) ) )

# Main entry point
(local) (main sigChld)

(de i32 main ((i32 . Ac) (i8** . Av))
   (set
      $AV0 (val Av)  # Save command
      $AV (setq Av (ofs Av 1))  # and argument vector
      $StkLimit (set $StkBrk (ulimStk)) )
   # Check debug mode
   (let P (ofs Av (- Ac 2))
      (unless (strcmp (val P) ($ "+"))
         (set $Dbg $T  P null) ) )
   # Locate home directory
   (let P (val Av)  # First argument
      (when (and P (<> (val P) (char "-")))
         (let Q (strrchr P (char "/"))
            (unless
               (or
                  (=0 Q)
                  (and
                     (== Q (+ P 1))
                     (== (val P) (char ".")) ) )
               (let (N (+ (- Q P) 1)  H (malloc (+ N 1)))
                  (set $PilHome H  $PilLen N)
                  (memcpy H P N)
                  (set (ofs H N) 0) ) ) ) ) )
   (when (getenv ($ "HOME"))
      (set $UsrHome @  $UsrLen (strlen @)) )
   (heapAlloc)
   (let P $Nil  # Init internal symbols
      (loop
         (let Nm (val (tail P))
            (when (num? Nm)
               (intern P 0 @ (cdr $Pico) $Nil NO)
               (? (== P $LastSym))
               (when (big? Nm)  # Max 15 chars
                  (setq P (ofs P 2)) ) ) )
         (setq P (ofs P 2)) ) )
   # Initialize globals
   (set
      $OS (mkStr TgOS)
      $CPU (mkStr TgCPU)
      $Pid (cnt (i64 (getpid)))
      $DB $Db1  # Database root constant
      (tail $Db1) DB1  # Name of external root symbol '{1}'
      $Extern (cons $Db1 $Nil) )  # External symbol tree root node
   (pushOutFile (b8 (ioFrame T)) (initOutFile 2) 0)  # Standard error
   (pushOutFile
      (set $Stdout (b8 (ioFrame T)))
      (initOutFile 1)  # Standard output
      0 )
   (pushInFile
      (set $Stdin (b8 (ioFrame T)))
      (initInFile 0 null)  # Standard input
      0 )
   (set Tio (=0 (tcgetattr 0 OrgTermio)))  # Save terminal I/O
   (sigUnblock 0)  # Set all signals to unblocked
   (iSignal (val SIGHUP Sig) (fun sig))
   (iSignal (val SIGUSR1 Sig) (fun sig))
   (iSignal (val SIGUSR2 Sig) (fun sig))
   (iSignal (val SIGALRM Sig) (fun sig))
   (iSignal (val SIGTERM Sig) (fun sig))
   (iSignal (val SIGWINCH Sig) (fun sig))
   (iSignal (val SIGIO Sig) (fun sig))
   (when (== (signal (val SIGTSTP Sig) (val SigIgn)) (val SigDfl))
      (iSignal (val SIGTSTP Sig) (fun sig)) )
   (iSignal (val SIGINT Sig) (fun sigTerm))
   (signal (val SIGCHLD Sig) (fun sigChld))
   (signal (val SIGPIPE Sig) (val SigIgn))
   (signal (val SIGTTIN Sig) (val SigIgn))
   (signal (val SIGTTOU Sig) (val SigIgn))
   (initReadline)
   (set $USec (getUsec YES))
   (unless (setjmp QuitRst)
      (loadAll 0) )  # Load arguments
   (setCooked)
   (unless (val $Repl)
      (set $Repl YES)
      (iSignal (val SIGINT Sig) (fun sig)) )
   (loop
      (let X (save (stdRead ($ ": ")))
         (cond
            ((lt0 (val $Chr)) (bye 0))
            ((=0 (val $Chr))
               (unless (nil? X)
                  (stdEval X) ) )
            (T (eval X)) ) ) ) )

(end "base.map" "lib.c")
