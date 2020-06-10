# 10jun20 Software Lab. Alexander Burger

(symbols '(llvm))

(begin "base" NIL
   "vers.l" "defs.l" "glob.l" "dec.l" )

(local) execAt

(de execAt (Prg)
   (let At (save (val $At))
      (exec Prg)
      (set $At At) ) )

# Unwind stack
(local) (popInFiles popOutFiles unwind)

(de void popInFiles ())
(de void popOutFiles ())

(de void unwind ((i8* . Catch))
   (let (Ca (val $Catch)  Bnd (val $Bind))
      (until (=0 Ca)
         (let Ca: (caFrame Ca)
            (until (or (=0 Bnd) (== Bnd (Ca: (env $Bind any))))
               (loop
                  (let Sym (val 2 Bnd)
                     (set Sym (val Bnd))  # Restore values
                     (? (== $At Sym))
                     (setq Bnd (val 3 Bnd)) ) ) )
            # ...
            (memcpy (env) (Ca: (env)) (env T))
            (eval (Ca: fin))  # Evaluate 'finally' expression
            (set $Catch (Ca: link))
            (and (== Ca Catch) (ret))
            (setq Ca (Ca: link)) ) )
      (until (=0 Bnd)
         (let Sym (val 2 Bnd)
            (set Sym (val Bnd))  # Restore values
            (setq Bnd (val 3 Bnd)) ) )
      (set $Bind 0)
      (until (=0 (val $InFrames))
         (popInFiles) )
      (until (=0 (val $OutFrames))
         (popOutFiles) )
      # ...
      ) )

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
   (when (=0 (realloc Ptr Siz)@)   # Reallocate pointer
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

# (raw ['flg]) -> flg
(de _raw (Exe)
   (let X (cdr Exe)
      (cond
         ((atom X)
            (if (=0 (val Termio)) $Nil $T) )
         ((nil? (eval (car X))) (setCooked) @)
         (T (setRaw) @) ) ) )

# Signals
(local) (sig sigTerm sigChld sighandler)

(de void sig ((i32 . N))
   (ifn (=0 (val $TtyPid))
      (kill @ N)
      (set $Signal (+ (val $Signal) 1))
      (let P (ofs $Signal (gSignal N))
         (set P (+ (val P) 1)) ) ) )

(de void sigTerm ((i32 . N))
   (ifn (=0 (val $TtyPid))
      (kill @ N)
      (set $Signal (+ (val $Signal) 1))
      (let P (ofs $Signal (gSignal (val SIGTERM Sig)))
         (set P (+ (val P) 1)) ) ) )

(de void sigChld ((i32 . N))
   (waitNohang) )

(de void sighandler (Exe)
   (when (=0 (val $Protect))
      (set $Protect 1)
      (let P T
         (loop
            (nond
               ((=0 (val (setq P (ofs $Signal SIGIO))))
                  (set P (dec @))
                  (set $Signal (dec (val $Signal)))
                  (execAt (val $Sigio)) )
               ((=0 (val (setq P (ofs $Signal SIGUSR1))))
                  (set P (dec @))
                  (set $Signal (dec (val $Signal)))
                  (execAt (val $Sig1)) )
               ((=0 (val (setq P (ofs $Signal SIGUSR2))))
                  (set P (dec @))
                  (set $Signal (dec (val $Signal)))
                  (execAt (val $Sig2)) )
               ((=0 (val (setq P (ofs $Signal SIGALRM))))
                  (set P (dec @))
                  (set $Signal (dec (val $Signal)))
                  (execAt (val $Alarm)) )
               ((=0 (val (setq P (ofs $Signal SIGHUP))))
                  (set P (dec @))
                  (set $Signal (dec (val $Signal)))
                  (execAt (val $Hup)) )
               ((=0 (val (setq P (ofs $Signal SIGINT))))
                  (set P (dec @))
                  (set $Signal (dec (val $Signal)))
                  (unless (val $PRepl)  # Not child of REPL process?
                     (brkLoad (if (=0 Exe) $Nil Exe)) ) )
               ((=0 (val (setq P (ofs $Signal SIGTSTP))))
                  (set P (dec @))
                  (set $Signal (dec (val $Signal)))
                  (execAt (val $TStp1))  # Run 'TStp1'
                  (stopTerm)  # Stop
                  (iSignal (val SIGTSTP Sig) (fun sig))  # Set signal again
                  (execAt (val $TStp2)) )  # Run 'TStp2'
               ((=0 (val (setq P (ofs $Signal SIGTERM))))
                  (set P (dec @))
                  (set $Signal (dec (val $Signal)))
                  (let
                     (Cld (val $Child)  # Iterate children
                        <Cld (ofs Cld (* (val $Children) (child T)))
                        Flg NO )
                     (until (== Cld <Cld)
                        (let Cld: (child Cld)
                           (and
                              (Cld: pid)
                              (=0 (kill @ (val SIGTERM Sig)))
                              (setq Flg YES) ) )
                        (setq Cld (ofs Cld (child T))) )
                     (? Flg)
                     (set $Signal 0)
                     (bye 0) ) ) )
            (? (=0 (val $Signal))) ) )
      (set $Protect 0) ) )

# Error handling
(local) (pushOutFiles err stkErr argErr cntErr numErr symErr extErr nameErr
atomErr pairErr lstErr varErr itemErr protErr lockErr forkErr symNspErr)

(de void pushOutFiles (i8*))

(de NIL err (Exe X (i8* . Fmt) (i8* . Arg))
   (set $Up (if (=0 Exe) $Nil Exe))
   (unless (=0 X)
      (link (push X NIL)) )  # Save
   (let Msg (b8 240)
      (gPrintf Msg 240 Fmt Arg)
      (unless (=0 (val Msg))
         (set $Msg (mkStr Msg))
         (let Ca (val $Catch)
            (until (=0 Ca)
               (let Ca: (caFrame Ca)
                  (let Tag (Ca: tag)
                     (unless (=0 Tag)
                        (while (pair Tag)
                           (when (subStr (car Tag) (val $Msg))
                              (set $Ret
                                 (if (nil? (car Tag))
                                    (val $Msg)
                                    (car Tag) ) )
                              (unwind (Ca:))
                              (longjmp (Ca: (rst)) 1) )
                           (shift Tag) ) ) )
                  (setq Ca (Ca: link)) ) ) ) )
      (set $Chr (set $ExtN 0))
      (set $Break NO)
      (set $LinePtr null)
      (set $Alarm (set $Sigio $Nil))
      (let Io: (ioFrame (b8 (ioFrame T)))
         (Io: fd 2)  # Stderr
         (Io: pid 0)
         (pushOutFiles (Io:))
         (let In: (inFile (val $InFile))
            (unless (or (=0 (In:)) (=0 (In: name)))
               (call $Put (char "["))
               (outString (In: name))
               (call $Put (char ":"))
               (outWord (i64 (In: src)))
               (call $Put (char "]"))
               (space) ) )
         (unless (=0 Exe)
            (outString ($ "!? "))
            (print Exe)
            (newline) )
         (unless (=0 X)
            (print X)
            (outString ($ " -- ")) )
         (unless (=0 (val Msg))
            (outString Msg)
            (newline)
            (unless (or (nil? (val $Err)) $Jam)
               (set $Jam YES)
               (execAt (val $Err))
               (set $Jam NO) )
            (when (or (=0 (isatty 0)) (=0 (isatty 1)))
               (bye 1) )
            (repl 0 ($ "? ") $Nil) )
         (unwind null)
         (set
            $Link 0
            $Protect 0
            $Task $Nil )
         (set $Put (fun (void i8) _putStdout))
         (set $Get (fun (i32) _getStdin))
         (longjmp QuitRst 1) ) ) )

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
   (err Exe X ($ "Protected symbol") null) )

(de NIL lockErr ()
   (err 0 0 ($ "File lock: %s") (strErrno)) )

(de NIL forkErr (Exe)
   (err Exe 0 ($ "Can't fork") null) )

(de NIL symNspErr (Exe X)
   (err Exe X ($ "Bad symbol namespace") null) )

# Runtime checks
(local) (stkChk sigChk)

(inline stkChk (Exe)
   (when (> (val $StkLimit) (stack))
      (stkErr Exe) ) )

(inline sigChk (Exe)
   (unless (=0 (val $Signal))
      (sighandler Exe) ) )

# Argument checks
(local) (needCnt needNum needSymb needPair needLst needVar chkVar needChkVar needNsp)

(inline needCnt (Exe X)
   (unless (cnt? X)
      (cntErr Exe X) )
   X )

(inline needNum (Exe X)
   (unless (num? X)
      (numErr Exe X) )
   X )

(inline needSymb (Exe X)
   (unless (symb? X)
      (symErr Exe X) )
   X )

(inline needPair (Exe X)
   (when (atom X)
      (pairErr Exe X) )
   X )

(inline needLst (Exe X)
   (unless (or (pair X) (nil? X))
      (lstErr Exe X) )
   X )

(inline needVar (Exe X)
   (when (num? X)
      (varErr Exe X) )
   X )

(inline chkVar (Exe X)
   (and
      (>= X $Nil)
      (>= $T X)
      (protErr Exe X) )
   X )

(inline needChkVar (Exe X)
   (and (num? X) (varErr Exe X))
   (chkVar Exe X)
   X )

(inline needNsp (Exe X)
   (unless (and (pair (val X)) (== $Tilde (car @)))
      (symNspErr 0 X) )
   X )

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
      (let
         (P (push 4 NIL ZERO NIL)
            Q (link (ofs P 2) T) )  # [cnt last name link]
         (pack X P)
         (consStr (val Q)) ) ) )

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
                        (? (or (nil? (car Z)) (== $T (car Z)))
                           0 ) )
                     (? (not (nil? Y)) 0) ) ) ) ) ) ) )

# Date and time
(local) (date time)

(de date ((i64 . Y) (i64 . M) (i64 . D))
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

(de time ((i64 . H) (i64 . M) (i64 . S))
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
               (date
                  (& N (hex "FFFF"))
                  (& (shr N 16) (hex "FF"))
                  (& (shr N 24) (hex "FF")) ) ) )
         ((t? (eval (car X)))
            (let N (getGmDate)
               (date
                  (& N (hex "FFFF"))
                  (& (shr N 16) (hex "FF"))
                  (& (shr N 24) (hex "FF")) ) ) )
         ((nil? @) @)
         ((pair @)
            (let L @
               (date
                  (xCnt Exe (++ L))
                  (xCnt Exe (++ L))
                  (xCnt Exe (car L)) ) ) )
         (T
            (let N @
               (cond
                  ((pair (shift X))
                     (date
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
                              (setq M (+ M 3))
                              (inc 'Y)
                              (setq M (- M 9)) )
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
               (time
                  (xCnt Exe (++ L))
                  (xCnt Exe (++ L))
                  (xCnt Exe (car L)) ) ) )
         (T
            (let N @
               (cond
                  ((pair (shift X))
                     (time
                        (xCnt Exe N)
                        (evCnt Exe X)
                        (if (pair (shift X)) (evCnt Exe X) 0) ) )
                  ((lt0 (setq N (xCnt Exe N))) $Nil)
                  (T
                     (cons (cnt (/ N 3600))
                        (cons (cnt (% (/ N 60) 60))
                           (cons (cnt (% N 60)) $Nil) ) ) ) ) ) ) ) ) )

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
         (let N (val $HomeLen)
            (set P 0)
            (let (Len (strlen S)  Q (b8 (+ N Len (+ 4 3 1))))
               (ifn (=0 (strchr S (char "/")))
                  (strcpy Q S)
                  (unless (=0 N)
                     (memcpy Q (val $Home) N) )
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
                                       (& (int NmX) (hex "3FFFFFFFFFFFFFF"))  # Mask status bits
                                       (setq NmX 0) )
                                    (prog1
                                       (val (dig NmX))  # Next digit
                                       (setq NmX (val (big NmX))) ) )
                                 B
                                 (if (cnt? NmY)
                                    (prog1
                                       (& (int NmY) (hex "3FFFFFFFFFFFFFF"))  # Mask status bits
                                       (setq NmY 0) )
                                    (prog1
                                       (val (dig NmY))  # Next digit
                                       (setq NmY (val (big NmY))) ) ) )
                              (loop
                                 (unless (=0 (- (& A 255) (& B 255)))
                                    (ret (if (gt0 @) +1 -1)) )
                                 (? (=0 (setq A (shr A 8)))
                                    (unless (=0 (setq B (shr B 8)))
                                       (ret -1) )
                                    (when (=0 NmX)
                                       (ret (if (=0 NmY) 0 -1)) )
                                    (when (=0 NmY)
                                       (ret +1) ) )
                                 (when (=0 (setq B (shr B 8)))
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

(load "io.l" "db.l" "apply.l" "flow.l" "subr.l" "net.l")

# Evaluation
(local) (undefined evExpr evList)

(de NIL undefined (Fun Exe)
   (err Exe Fun ($ "Undefined") null) )

# Apply EXPR to CDR of list
(de evExpr (Exe Lst)
   (let
      (X (cdr Lst)  # Arguments
         Y (car Exe)  # Parameters
         P (set $Bind (push (val $At) $At (val $Bind) Lst)) )  # [[@] @ LINK Exe]
      (while (pair Y)
         (set $Bind
            (setq P
               (push  # [val sym LINK]
                  (eval (++ X))  # Evaluate next argument
                  (++ Y)  # Next parameter
                  P ) ) ) )
      (prog1
         (if (== Y $At)  # VarArgs
            (let (Link (val $Link)  Next (val $Next))
               (if (atom X)
                  (set $Next $Nil)
                  (let (L (push NIL (eval (++ X)) NIL)  Q L)
                     (link (ofs L 1))
                     (while (pair X)
                        (setq L
                           (set L (push NIL (eval (++ X)) NIL)) )
                        (link (ofs L 1)) )
                     (set L $Nil  $Next Q) ) )
               (loop
                  (let Sym (val 2 P)
                     (xchg Sym P)  # Exchange symbol value
                     (? (== $At Sym))
                     (setq P (val 3 P)) ) )
               (prog1
                  (run (cdr Exe))  # Run body
                  (set $Next Next  $Link Link) ) )
            (unless (== Y $Nil)
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
                  (? (num? V) (subr V Exe))
                  (? (pair V) (evExpr V Exe))
                  (? (== V (val V))
                     (if (sharedLib Fun)
                        (subr (val Fun) Exe)
                        (undefined Fun Exe) ) )
                  (setq Fun V) ) ) )
         (T  # List: Evaluate
            (stkChk Exe)
            (let F (save (evList Fun))  # Save computed function
               (loop
                  (sigChk Exe)
                  (? (num? F) (subr F Exe))
                  (? (pair F) (evExpr F Exe))
                  (let V (val F)
                     (? (== V (val V))
                        (if (sharedLib F)
                           (subr (val F) Exe)
                           (undefined F Exe) ) )
                     (setq F V) ) ) ) ) ) ) )

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
               (=0
                  (setenv S
                     (bufString Nm2 (b8 (bufSize Nm2)))
                     1 ) )
               Y
               $Nil ) ) ) ) )

# (pwd) -> sym
(de _pwd (Exe)
   (let P (getcwd null 0)
      (if (=0 P)
         $Nil
         (prog1 (mkStr P) (free P)) ) ) )

# (cd 'any) -> sym
(de _cd (Exe)
   (let
      (Nm (xName Exe (evSym (cdr Exe)))
         P (getcwd null 0) )
      (if (=0 P)
         $Nil
         (prog1
            (if (lt0 (chdir (pathString Nm (b8 (pathSize Nm)))))
               $Nil
               (mkStr P) )
            (free P) ) ) ) )

# (dir ['any] ['flg]) -> lst
(de _dir (Exe)
   (let X (cdr Exe)
      (if
         (=0
            (getDir
               (if (nil? (evSym X))
                  ($ ".")
                  (let Nm (xName Exe @)
                     (pathString Nm (b8 (pathSize Nm))) ) ) ) )
         $Nil
         (let (P @  F (eval (car (shift X))))
            (when (nil? F)
               (while (== (val P) (char "."))
                  (when (=0 (setq P (getDir null)))
                     (ret $Nil) ) ) )
            (let (Y (cons (mkStr P) $Nil)  R (save Y))
               (until (=0 (setq P (getDir null)))
                  (unless (and (nil? F) (== (val P) (char ".")))
                     (setq Y (set 2 Y (cons (mkStr P) $Nil))) ) )
               R ) ) ) ) )

# (info 'any ['flg]) -> (cnt|flg dat . tim)
(de _info (Exe)
   (let
      (X (cdr Exe)
         Nm (xName Exe (evSym X))
         Size (i64* (push NIL)) )
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
                  (date
                     (& (setq N (shr N 2)) (hex "FFFF"))
                     (& (setq N (shr N 16)) (hex "FF"))
                     (& (setq N (shr N 8)) (hex "FF")) )
                  (cnt (shr N 8)) ) ) ) ) ) )

# (argv [var ..] [. sym]) -> lst|sym
(de _argv (Exe)
   (let (X (cdr Exe)  A (val $AV)  P (val A))
      (and
         P
         (== (val P) (char "-"))
         (=0 (val 2 P))  # Single-dash argument
         (inc 'A) )  # Skip "-"
      (if (nil? X)  # No args
         (if (=0 (setq P (val A)))
            $Nil
            (let (Y (cons (mkStr P) $Nil)  R (save Y))
               (until (=0 (setq P (val (inc 'A))))
                  (setq Y (set 2 Y (cons (mkStr P) $Nil))) )
               R ) )
         (loop
            (? (atom X)
               (set (needChkVar Exe X)
                  (if (=0 (setq P (val A)))
                     $Nil
                     (let (Y (cons (mkStr P) $Nil)  R Y)
                        (save R
                           (until (=0 (setq P (val (inc 'A))))
                              (setq Y (set 2 Y (cons (mkStr P) $Nil))) ) )
                        R ) ) ) )
            (let Y
               (if (=0 (setq P (val A)))
                  $Nil
                  (inc 'A)
                  (mkStr P) )
               (set (needChkVar Exe (++ X)) Y)
               (? (nil? X) Y) ) ) ) ) )

# Native calls
(local) natRet

(de natRet (Spec Val)
   (cond
      ((== Spec $I) (cnt Val))
      ((== Spec $N) (box64 Val))
      ((== Spec $S) (mkStr (i8* Val)))
      (T $Nil) ) )

# (native 'cnt1|sym1 'cnt2|sym2 'any 'any ..) -> any
(de _native (Exe)
   (let
      (X (cdr Exe)
         Y (eval (++ X))  # Eval library 'cnt1|sym1'
         Lib
         (cond
            ((cnt? Y) (i8* (int Y)))
            ((big? Y) (i8* (val (dig Y))))
            (T
               (let Nm (xName Exe Y)
                  (when
                     (=0
                        (dlOpen
                           (if (== Nm (| 2 (>> -4 (char "@"))))
                              null
                              (pathString Nm (b8 (pathSize Nm))) ) ) )
                     (err Exe Y ($ "[DLL] %s") (dlerror)) )
                  (set Y (box64 (i64 @)))
                  @ ) ) )
         Fun (eval (++ X))  # Eval function 'cnt2|sym2'
         Args (save (cons (eval (++ X)) $Nil))
         L Args )  # [ret args]
      (while (pair X)
         (let Z (push (eval (++ X)) $Nil NIL)  # [argN next]
            (set 2 L Z)
            (setq L Z) ) )
      (natRet
         (car Args)
         (ffiCall
            (cond
               ((cnt? Fun) (i8* (int Fun)))
               ((big? Fun) (i8* (val (dig Fun))))
               (T
                  (let Nm (xName Exe Fun)
                     (when
                        (=0
                           (ffiPrep Lib (bufString Nm (b8 (bufSize Nm))) Args) )
                        (err Exe 0 ($ "Bad ffi") null) )
                     (set Fun (box64 (i64 @)))
                     @ ) ) )
            Args ) ) ) )

# (args) -> flg
(de _args (Exe)
   (if (pair (val $Next)) $T $Nil) )

# (next) -> any
(de _next (Exe)
   (let X (val $Next)
      (set $Next (car X))
      (cdr X) ) )

# (rest) -> lst
(de _rest (Exe)
   (let X (val $Next)
      (if (atom X)
         X
         (let (Y (cons (cdr X) $Nil)  R (save Y))
            (while (pair (setq X (car X)))
               (setq Y (set 2 Y (cons (cdr X) $Nil))) )
            R ) ) ) )

# (adr 'var) -> cnt
# (adr 'cnt) -> var
(de _adr (Exe)
   (cond
      ((cnt? (eval (cadr Exe)))
         (& @ -3) )  # Make 'var' (pos -> cell, neg -> symbol)
      ((big? @) (argErr Exe @))
      (T (| @ 2)) ) )  # Make 'cnt'

# (trail ['flg]) -> lst
(de _trail (Exe)
   (let (F (eval (cadr Exe))  Bnd (val $Bind)  R $Nil)
      (until (=0 Bnd)
         (let S (val 2 Bnd)
            (if (== S $At)
               (setq R (cons (val 4 Bnd) R))
               (setq R (cons S (cons (val S) R)))
               (set S (val Bnd)) ) )
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
         (if (=0 N)
            $Nil
            (loop
               (? (=0 Bnd) $Nil)
               (?
                  (and
                     (== $At (val 2 Bnd))
                     (=0 (dec 'N)) )
                  (val 4 Bnd) )
               (setq Bnd (val 3 Bnd)) ) )
         (let Z Y
            (unless (=0 N)
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
            (if (or (=0 P) (=0 (val P)))
               $Nil
               (let
                  (Y (cons (mkStr (val (val P))) $Nil)
                     R (save Y)
                     I 0 )
                  (until (=0 (val (ofs P (inc 'I))))
                     (setq Y
                        (set 2 Y (cons (mkStr (val @)) $Nil)) ) )
                  R ) ) )
         (clear_history)
         (let (Y (needLst Exe (eval (car X)))  Z Y)
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
(local) main

(de i32 main ((i32 . Ac) (i8** . Av))
   (set $AV0 (val Av))  # Save command
   (set $AV (setq Av (ofs Av 1)))  # and argument vector
   # Check debug mode
   (let P (ofs Av (- Ac 2))
      (when (=0 (strcmp (val P) ($ "+")))
         (set $Dbg $T  P null) ) )
   # Locate home directory
   (let P (val Av)  # First argument
      (unless (or (=0 P) (== (val P) (char "-")))
         (let Q (strrchr P (char "/"))
            (unless
               (or
                  (=0 Q)
                  (and
                     (== Q (+ P 1))
                     (== (val P) (char ".")) ) )
               (let (N (+ (- Q P) 1)  H (malloc (+ N 1)))
                  (set $Home H  $HomeLen N)
                  (memcpy H P N)
                  (set (ofs H N) 0) ) ) ) ) )
   # Initialize globals
   (set $Pid (cnt (i64 (getpid))))
   #! Stack0, Stack1, StkLimit
   (heapAlloc)
   (let P $Nil  # Init internal symbols
      (loop
         (let Nm (val (tail P))
            (when (num? Nm)
               (intern P 0 @ (cdr $Pico) $Nil)
               (? (== P $LastSym))
               (when (big? Nm)  # Max 15 chars
                  (setq P (ofs P 2)) ) ) )
         (setq P (ofs P 2)) ) )
   (set
      (tail $Db1) DB1  # Name of external root symbol '{1}'
      $Extern (cons $Db1 $Nil) )  # External symbol tree root node
   (initOutFile 2)  # Standard error
   (set $OutFile (initOutFile 1))  # Standard output
   (set $InFile (initInFile 0 null))  # Standard input
   (set Tio (=0 (tcgetattr 0 OrgTermio)))  # Save terminal I/O
   (sigUnblock 0)  # Set all signals to unblocked
   (iSignal (val SIGHUP Sig) (fun sig))
   (iSignal (val SIGUSR1 Sig) (fun sig))
   (iSignal (val SIGUSR2 Sig) (fun sig))
   (iSignal (val SIGALRM Sig) (fun sig))
   (iSignal (val SIGTERM Sig) (fun sig))
   (iSignal (val SIGIO Sig) (fun sig))
   (when (== (signal (val SIGTSTP Sig) (val SigIgn)) (val SigDfl))
      (iSignal (val SIGTSTP Sig) (fun sig)) )
   (iSignal (val SIGINT Sig) (fun sigTerm))
   (signal (val SIGCHLD Sig) (fun sigChld))
   (signal (val SIGPIPE Sig) (val SigIgn))
   (signal (val SIGTTIN Sig) (val SigIgn))
   (signal (val SIGTTOU Sig) (val SigIgn))
   (set $USec (getUsec))
   (when (=0 (setjmp QuitRst))
      (loadAll 0)  # Load arguments
      (set $Repl YES)
      (iSignal (val SIGINT Sig) (fun sig)) )
   (loop
      (repl 0 ($ ": ") $Nil) ) )

(end)
