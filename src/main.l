# 08mar20 Software Lab. Alexander Burger

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
(local) (finish giveup bye)

(de NIL finish ((i32 . N))
   #(setCooked)
   (exit N) )

(de NIL giveup ((i8* . Msg))
   (stderrMsg Msg 0)
   (finish 1) )

(de NIL bye ((i32 . N))
   (unwind null)
   (finish N) )

# Memory
(local) (alloc heapAlloc)

(de i8* alloc ((i8* . Ptr) (i64 . Siz))
   (let P (realloc Ptr Siz)  # Reallocate pointer
      (when (=0 P)
         (giveup ($ "No memory")) )
      P ) )

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
(local) (sig sighandler)

(de void sig ((i32 . N))
   (let I (val $TtyPid)
      (ifn (=0 I)
         (kill I N)
         (set $Signal (+ (val $Signal) 1))
         (let P (ofs $Signal (xSignal N))
            (set P (+ (val P) 1)) ) ) ) )

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
atomErr pairErr varErr protErr lockErr)

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
               (outWord (In: src))
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
         (set $Put (fun (void i32) _putStdout))
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

(de NIL protErr (Exe X)
   (err Exe X ($ "Protected symbol") null) )

(de NIL lockErr ()
   (err 0 0 ($ "File lock: %s") (strErrno)) )

# Stack check
(local) stkChk

(inline stkChk (Exe)
   (when (> (val $StkLimit) (stack))
      (stkErr Exe) ) )

# Argument checks
(local) (needCnt needNum needSym chkVar needVar)

(inline needCnt (Exe X)
   (unless (cnt? X)
      (cntErr Exe X) )
   X )

(inline needNum (Exe X)
   (unless (num? X)
      (numErr Exe X) )
   X )

(inline needSym (Exe X)
   (when (or (num? X) (pair X))
      (symErr Exe X) )
   X )

(inline chkVar (Exe X)
   (and
      (>= X $Nil)
      (>= $T X)
      (protErr Exe X) )
   X )

(inline needVar (Exe X)
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
      (let (P (push 4 ZERO NIL)  Q (link (ofs P 1)))  # [cnt name link]
         (pack X P)
         (prog1
            (consStr (val Q))
            (drop Q) ) )
      X ) )

(de evSym (Exe)
   (xSym (eval (car Exe))) )

# Structure checks
(local) (circ funq sharedLib)

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
                           (let Z (++ Y)
                              (?
                                 (or
                                    (num? Z)
                                    (pair Z)
                                    (nil? Z)
                                    (== $T Z) )
                                 0 ) ) ) ) ) )
               (let Z (++ Y)
                  (if (pair Z)
                     (if (num? (car Z))
                        (? (pair Y) 0)
                        (? (or (nil? (car Z)) (== $T (car Z)))
                           0 ) )
                     (? (not (nil? Y)) 0) ) ) ) ) ) ) )

(de i1 sharedLib (Sym)
   (let (Nm (bufString Sym (b8 (bufSize Sym)))  P (strchr Nm (char ":")))
      (and
         (n0 P)
         (<> P Nm)
         (n0 (val 2 P))
         (let N (if (=0 (val $Home)) 0 (strlen (val $Home)))
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
               (let H (dlOpen Q)
                  (and
                     (n0 H)
                     (n0 (setq H (dlsym H (inc P))))
                     (prog
                        (set Sym (| (i64 H) 2))
                        YES ) ) ) ) ) ) ) )

(load "gc.l" "big.l" "sym.l")

# Comparisons
(local) (equal compare)

(de i1 equal (X Y)
   (: 1
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
               (loop
                  (? (<> (val (dig X)) (val (dig Y))) NO)
                  (?
                     (==
                        (setq X (val (big X)))
                        (setq Y (val (big Y))) )
                     YES )
                  (? (cnt? X) NO)
                  (? (cnt? Y) NO) ) ) )
         ((sym? X)
            (cond
               ((num? Y) NO)
               ((pair Y) NO)
               ((== ZERO (setq X (name (val (tail X))))) NO)
               ((== ZERO (setq Y (name (val (tail Y))))) NO)
               (T (goto 1)) ) )
         ((atom Y) NO)
         (T NO) ) ) )

(de i32 compare (X Y)
   (cond
      ((== X Y) (i32 0))
      ((nil? X) (i32 -1))
      ((== X $T) (i32 +1))
      ((num? X)
         (cond
            ((num? Y) (cmpNum X Y))
            ((nil? Y) (i32 +1))
            (T (i32 -1)) ) )
      ((sym? X)
         (cond
            ((or (num? Y) (nil? Y))
               (i32 +1) )
            ((or (pair Y) (== Y $T))
               (i32 -1) )
            (T
               (let (A (name (val (tail X)))  B (name (val (tail X))))
                  (i32 0) ) ) ) )
      ((atom Y)
         (if (== Y $T) (i32 -1) (i32 +1)) )
      (T
         (let (A X  B Y)
            (loop
               (let N (compare (car X) (car Y))
                  (? (n0 N) N) )
               (? (atom (shift X))
                  (compare X (cdr Y)) )
               (? (atom (shift Y))
                  (if (== Y $T) (i32 -1) (i32 +1)) )
               (? (and (== X A) (== Y B))
                  (i32 0) ) ) ) ) ) )

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
         Q (link (push (val $At) NIL $At (val $Bind) Lst)) )  # [[@] LINK @ Bind Exe]
      (while (pair Y)
         (link
            (push  # [val LINK sym]
               (eval (++ X))  # Evaluate next argument
               NIL
               (++ Y) ) ) )  # Next parameter
      (prog1
         (let P (val $Link)
            (if (== Y $At)  # VarArgs
               (let Next (push (val $Next))
                  (if (atom X)
                     (set $Next $Nil)
                     (let L (link (push -ZERO NIL))  # [lst LINK]
                        (set $Next
                           (set L (push (eval (car X)) $Nil)) )  # [arg1 next]
                        (while (pair (shift X))
                           (setq L  # [argN next]
                              (set 2 L (push (eval (car X)) $Nil)) ) ) ) )
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
               (run (cdr Exe)) ) )  # Run body
         (let P (val $Link)
            (loop
               (set (val 3 P) (val P))  # Restore values
               (? (== Q P))
               (shift P) )
            (drop P) )
         (set $Bind (val 4 Q)) ) ) )

(de evList (Exe)
   (let Fun (car Exe)
      (cond
         ((num? Fun) Exe)  # Number: Return list
         ((sym? Fun)  # Symbol: Find function
            (loop
               (unless (=0 (val $Signal))
                  (sighandler Exe) )
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
                  (unless (=0 (val $Signal))
                     (sighandler Exe) )
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
         Args (link (push (eval (++ X)) NIL))
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
         (drop Args) ) ) )

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
         (let (Y (cons (++ X) $Nil)  P (link (push Y NIL)))
            (while (pair X)
               (setq Y
                  (set 2 Y (cons (++ X) $Nil)) ) )
            (pop P) ) ) ) )

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
                  (set $Home H)
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
               (intern P 0 Nm $Pico $Nil)
               (? (== P $LastSym)) ) )
         (setq P (ofs P 2)) ) )
   (set
      (tail $Db1) DB1  # Name of external root symbol '{1}'
      $Extern (cons $Db1 $Nil) )  # External symbol tree root node
   (initOutFile 2)  # Standard error
   (set $OutFile (initOutFile 1))  # Standard output
   (set $InFile (initInFile 0 null))  # Standard input
   (when (=0 (catchQuit))
      (loadAll 0)  # Load arguments
      )
   (loop
      (repl 0 (char ":") $Nil) ) )

(end)
