# 16apr20 Software Lab. Alexander Burger

(symbols '(llvm))

(begin "base" NIL
   "vers.l" "defs.l" "glob.l" "dec.l" )

# Unwind stack
(local) unwind

(de void unwind ((i8* . Catch))
   (let (Ca (val $Catch)  P (val $Bind))
      (until (=0 Ca)
         (let Ca: (caFrame Ca)
            (until (or (=0 P) (== P (Ca: (env $Bind any))))
               (loop
                  (set (val P) (val 2 P))  # Restore values
                  (? (== $At (val P)))
                  (setq P (val 3 P)) )
               (setq P (val 3 P)) )
            # ...
            (memcpy (env) (Ca: (env)) (env T))
            (eval (Ca: fin))  # Evaluate 'finally' expression
            (set $Catch (Ca: link))
            (and (== Ca Catch) (ret))
            (setq Ca (Ca: link)) ) )
      (until (=0 P)
         (loop
            (set (val P) (val 2 P))  # Restore values
            (? (== $At (val P)))
            (setq P (val 3 P)) )
         (setq P (val 3 P)) )
      (set $Bind 0)
      # ...
      ) )

# Exit
(local) (finish giveup bye execErr)

(de NIL finish ((i32 . N))
   #(setCooked)
   (exit N) )

(de NIL giveup ((i8* . Fmt) (i8* . Msg))
   (stderrMsg Fmt Msg)
   (finish 1) )

(de NIL bye ((i32 . N))
   (unless (val $InBye)
      (set $InBye YES)
      (unwind null)
      (run (val $Bye)) )
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
   (let H (any (alloc null (* 8 (inc HEAP))))
      (set
         (ofs H HEAP) (val $Heaps)
         $Heaps H )
      (let (P (ofs H (- HEAP 2))  A (val $Avail))
         (loop
            (set P A)  # Link avail
            (setq
               A P
               P (ofs P -2) )  # Back one cell
            (? (== P H)) )
         (set $Avail A) ) ) )

# Signals
(local) (sig sigChld sighandler)

(de void sig ((i32 . N))
   (ifn (=0 (val $TtyPid))
      (kill @ N)
      (set $Signal (+ (val $Signal) 1))
      (let P (ofs $Signal (xSignal N))
         (set P (+ (val P) 1)) ) ) )

(de void sigChld ((i32 . N))
   (waitNohang) )

(de void sighandler (Exe)
   (when (=0 (val $Protect))
      (set $Protect 1)
      (loop
         (let P (ofs $Signal SIGIO)
            (unless (=0 (val P))
               (set $Signal (- (val $Signal) 1))
               (set P (- (val P) 1))
               (run (val $Sigio)) ) )
         (let P (ofs $Signal SIGUSR1)
            (unless (=0 (val P))
               (set $Signal (- (val $Signal) 1))
               (set P (- (val P) 1))
               (run (val $Sig1)) ) )
         (let P (ofs $Signal SIGUSR2)
            (unless (=0 (val P))
               (set $Signal (- (val $Signal) 1))
               (set P (- (val P) 1))
               (run (val $Sig2)) ) )
         (let P (ofs $Signal SIGALRM)
            (unless (=0 (val P))
               (set $Signal (- (val $Signal) 1))
               (set P (- (val P) 1))
               (run (val $Alarm)) ) )
         #! ...
         (? (=0 (val $Signal))) )
      (set $Protect 0) ) )

# Error handling
(local) (pushOutFiles err stkErr argErr cntErr numErr lstErr symErr extErr
atomErr pairErr varErr itemErr protErr lockErr forkErr)

(de void pushOutFiles (i8*))

(de NIL err (Exe X (i8* . Fmt) (i8* . Arg))
   (set $Up (if (=0 Exe) $Nil Exe))
   (unless (=0 X)
      (link (push X NIL)) )  # Save
   (let Msg (b8 240)
      (xprintf Msg 240 Fmt Arg)
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
      (set $Alarm (set $Sigio $Nil))
      (set $Line (set 2 $Line 0))
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
               (run (val $Err))
               (set $Jam NO) )
            (when (or (=0 (isatty 0)) (=0 (isatty 1)))
               (bye 1) )
            (repl 0 (char "?") $Nil) )
         (unwind null)
         (set
            $Link 0
            $Protect 0
            $Task $Nil )
         (set $Put (fun (void i8) _putStdout))
         (set $Get (fun (i32) _getStdin))
         (throwQuit) ) ) )

(de NIL stkErr (Exe)
   (set $StkLimit null)
   (err Exe 0 ($ "Stack overflow") null) )

(de NIL argErr (Exe X)
   (err Exe X ($ "Bad argument") null) )

(de NIL cntErr (Exe X)
   (err Exe X ($ "Small number expected") null) )

(de NIL numErr (Exe X)
   (err Exe X ($ "Number expected") null) )

(de NIL lstErr (Exe X)
   (err Exe X ($ "List expected") null) )

(de NIL symErr (Exe X)
   (err Exe X ($ "Symbol expected") null) )

(de NIL extErr (Exe X)
   (err Exe X ($ "External symbol expected") null) )

(de NIL atomErr (Exe X)
   (err Exe X ($ "Atom expected") null) )

(de NIL pairErr (Exe X)
   (err Exe X ($ "Cons pair expected") null) )

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

# Runtime checks
(local) (stkChk sigChk)

(inline stkChk (Exe)
   (when (> (val $StkLimit) (stack))
      (stkErr Exe) ) )

(inline sigChk (Exe)
   (unless (=0 (val $Signal))
      (sighandler Exe) ) )

# Argument checks
(local) (needCnt needNum needLst needSym needVar chkVar needChkVar)

(inline needCnt (Exe X)
   (unless (cnt? X)
      (cntErr Exe X) )
   X )

(inline needNum (Exe X)
   (unless (num? X)
      (numErr Exe X) )
   X )

(inline needLst (Exe X)
   (unless (or (pair X) (nil? X))
      (lstErr Exe X) )
   X )

(inline needSym (Exe X)
   (when (or (num? X) (pair X))
      (symErr Exe X) )
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

(local) (xCnt evCnt evLst xSym evSym)

(de i64 xCnt (Exe X)
   (let N (int (needCnt Exe X))
      (if (sign? X) (- N) N) ) )

(de evCnt (Exe X)
   (xCnt Exe (eval (car X))) )

(de evLst (Exe)
   (let X (eval (car Exe))
      (unless (or (pair X) (nil? X))
         (lstErr Exe X) )
      X ) )

(de xSym (X)
   (if (or (num? X) (pair X))
      (let (P (push 4 NIL ZERO NIL)  Q (link (ofs P 2)))  # [cnt last name link]
         (pack X P)
         (drop Q
            (consStr (val Q)) ) )
      X ) )

(de evSym (Exe)
   (xSym (eval (car Exe))) )

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
            (? (n0 (& (val Y) 1))  # Detected circularity
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
      ((n0 (circ X)) 0)
      (T
         (let Y (cdr X)
            (loop
               (? (atom Y)
                  (cond
                     ((not (nil? Y)) 0)
                     ((nil? (setq X (car X))) $T)
                     ((n0 (circ (setq Y X))) 0)
                     (T
                        (loop
                           (? (atom Y)
                              (if (or (num? Y) (== Y $T))
                                 0
                                 X ) )
                           (?
                              (or
                                 (num? (++ Y))
                                 (pair @)
                                 (nil? @)
                                 (== @ $T) )
                              0 ) ) ) ) )
               (let Z (++ Y)
                  (if (pair Z)
                     (if (num? (car Z))
                        (? (pair Y) 0)
                        (? (or (nil? (car Z)) (== $T (car Z)))
                           0 ) )
                     (? (not (nil? Y)) 0) ) ) ) ) ) ) )

# Try to load dynamic library
(local) sharedLib

(de i1 sharedLib (Sym)
   (let (Nm (bufString Sym (b8 (bufSize Sym)))  P (strchr Nm (char ":")))
      (and
         (n0 P)
         (<> P Nm)
         (n0 (val 2 P))
         (let N (val $HomeLen)
            (set P 0)
            (let (Len (strlen Nm)  Q (b8 (+ N Len (+ 4 3 1))))
               (ifn (=0 (strchr Nm (char "/")))
                  (strcpy Q Nm)
                  (unless (=0 N)
                     (memcpy Q (val $Home) N) )
                  (strcpy (ofs Q N) ($ "lib/"))
                  (strcpy (ofs Q (+ N 4)) Nm)
                  (setq Len (+ Len N 4)) )
               (strcpy (ofs Q Len) ($ ".so"))
               (and
                  (n0 (dlOpen Q))
                  (n0 (dlsym @ (inc P)))
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
            ((== ZERO
                  (setq X (name (val (tail X)))) )
               NO )
            ((== ZERO
                  (setq Y (name (val (tail Y)))) )
               NO )
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
                  (? (n0 (& (val X) 1))  # Detected circularity
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
      ((== X $T) +1)
      ((num? X)
         (cond
            ((num? Y) (cmpNum X Y))
            ((nil? Y) +1)
            (T -1) ) )
      ((sym? X)
         (cond
            ((or (num? Y) (nil? Y)) +1)
            ((or (pair Y) (== Y $T)) -1)
            (T
               (let
                  (NmX (name (val (tail X)))
                     NmY (name (val (tail Y))) )
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
      ((atom Y) (if (== Y $T) -1 +1))
      (T
         (stkChk 0)
         (let (A X  B Y)
            (loop
               (? (n0 (compare (car X) (car Y))) @)
               (? (atom (shift X))
                  (compare X (cdr Y)) )
               (? (atom (shift Y))
                  (if (== Y $T) -1 +1) )
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
         P (push (val $At) NIL $At (val $Bind) Lst)  # [[@] LINK @ Bind Exe]
         Q (link P) )
      (while (pair Y)
         (setq P
            (link
               (push  # [val LINK sym]
                  (eval (++ X))  # Evaluate next argument
                  NIL
                  (++ Y) ) ) ) )  # Next parameter
      (prog1
         (if (== Y $At)  # VarArgs
            (let Next (push (val $Next))
               (if (atom X)
                  (set $Next $Nil)
                  (let L (link (push -ZERO NIL))  # [lst LINK]
                     (set $Next
                        (setq L
                           (set L (push (eval (++ X)) $Nil)) ) )  # [arg1 next]
                     (while (pair X)
                        (setq L  # [argN next]
                           (set 2 L (push (eval (++ X)) $Nil)) ) ) ) )
               (set $Bind P)
               (loop
                  (xchg (val 3 P) P)  # Exchange symbol value
                  (? (== Q P))
                  (shift P) )
               (prog1
                  (run (cdr Exe))  # Run body
                  (set $Next (val Next)  $Link (val $Bind)) ) )
            (unless (== Y $Nil)
               (link (push (val Y) NIL Y))  # Last parameter
               (set Y X) )  # Set to unevaluated argument(s)
            (set $Bind (val $Link))
            (loop
               (xchg (val 3 P) P)  # Exchange symbol value
               (? (== Q P))
               (shift P) )
            (run (cdr Exe)) )  # Run body
         (setq P (val $Link))
         (loop
            (set (val 3 P) (val P))  # Restore values
            (? (== Q P))
            (shift P) )
         (drop P)
         (set $Bind (val 4 Q)) ) ) )

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
               (let P
                  (dlOpen
                     (if
                        (==
                           (| 2 (>> -4 (char "@")))  # "@"
                           (name (val (tail Y))) )
                        null
                        (pathString Y (b8 (pathSize Y))) ) )
                  (when (=0 P)
                     (err Exe Y ($ "[DLL] %s") (dlerror)) )
                  (set Y (box64 (i64 P)))
                  P ) ) )
         Fun (eval (++ X))  # Eval function 'cnt2|sym2'
         Args (save (eval (++ X)))
         L Args )  # [ret args]
      (while (pair X)
         (let Z (push (eval (++ X)) $Nil NIL)  # [argN next]
            (set 2 L Z)
            (setq L Z) ) )
      (prog1
         (natRet
            (car Args)
            (ffiCall
               (cond
                  ((cnt? Fun) (i8* (int Fun)))
                  ((big? Fun) (i8* (val (dig Fun))))
                  (T
                     (let P (ffiPrep Lib (bufString Fun (b8 (bufSize Fun))) Args)
                        (when (=0 P)
                           (err Exe 0 ($ "Bad ffi") null) )
                        (set Fun (box64 (i64 P)))
                        P ) ) )
               Args ) )
         Args ) ) )

# (args) -> flg
(de _args (Exe)
   (if (pair (val $Next)) $T $Nil) )

# (next) -> any
(de _next (Exe)
   (let X (val $Next)
      (set $Next (cdr X))
      (car X) ) )

# (rest) -> lst
(de _rest (Exe)
   (let X (val $Next)
      (if (atom X)
         X
         (let (Y (cons (++ X) $Nil)  R (save Y))
            (while (pair X)
               (setq Y
                  (set 2 Y (cons (++ X) $Nil)) ) )
            R ) ) ) )

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
         (when (num? (val (tail P)))
            (intern P 0 @ $Pico $Nil)
            (? (== P $LastSym)) )
         (setq P (ofs P 2)) ) )
   (set
      (tail $Db1) DB1  # Name of external root symbol '{1}'
      $Extern (cons $Db1 $Nil) )  # External symbol tree root node
   (initOutFile 2)  # Standard error
   (set $OutFile (initOutFile 1))  # Standard output
   (set $InFile (initInFile 0 null))  # Standard input
   (signal (val SIGCHLD Sig) (fun sigChld))
   (when (=0 (catchQuit))
      (loadAll 0)  # Load arguments
      )
   (loop
      (repl 0 (char ":") $Nil) ) )

(end)
