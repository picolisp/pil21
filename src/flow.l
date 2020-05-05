# 05may20 Software Lab. Alexander Burger

(symbols '(llvm))

(local) (redefMsg putSrc redefine)

(de void redefMsg (Sym Sym2)
   (let (Out (val $OutFile)  Put (val (i8** $Put)))
      (set
         $OutFile (val (ofs (val $OutFiles) 2))  # Stderr
         $Put (fun (void i8) _putStdout) )
      (outString ($ "# "))
      (print Sym)
      (unless (=0 Sym2)
         (space)
         (print @) )
      (outString ($ " redefined\n"))
      (set (i8** $Put) Put  $OutFile Out) ) )

(de void putSrc (Sym Key)
   (unless
      (or
         (nil? (val $Dbg))
         (sym? (val (tail Sym))) )
      (let In: (inFile (val $InFile))
         (unless (or (=0 (In:)) (=0 (In: name)))
            (let
               (Dbg (get Sym $Dbg)
                  Src
                  (cons
                     (cnt (i64 (In: src)))
                     (mkStr (In: name)) ) )
               (cond
                  ((=0 Key)
                     (if (nil? Dbg)
                        (put Sym $Dbg (cons Src $Nil))  # Put initial '*Dbg' properties
                        (set Dbg Src) ) )  # Set first '*Dbg' property
                  ((nil? Dbg)
                     (put Sym $Dbg (cons $Nil (cons Src $Nil))) )
                  (T
                     (let X Dbg
                        (loop
                           (? (atom (shift X))
                              (set 2 Dbg (cons (cons Key Src) (cdr Dbg))) )
                           (? (== (caar X) Key)
                              (set 2 (car X) Src) ) ) ) ) ) ) ) ) ) )

(de void redefine (Exe Sym Val)
   (needChkVar Exe Sym)
   (let V (val Sym)
      (unless (or (nil? V) (== V Sym) (equal V Val))
         (redefMsg Sym 0) ) )
   (set Sym Val)
   (putSrc Sym 0) )

# (quote . any) -> any
(de _quote (Exe)
   (cdr Exe) )

# (eval 'any ['cnt ['lst]]) -> any
(de _eval (Exe)
   (let (X (cdr Exe)  E (eval (car X)))
      (cond
         ((num? E) E)
         ((sym? E) (val E))
         ((atom (shift X)) (evList E))
         (T
            (save E
               (let N (needCnt Exe (eval (car X)))
                  (unless (or (sign? N) (=0 (setq N (int N))))
                     (let Bnd (val $Bind)
                        (loop
                           (? (=0 Bnd))
                           (?
                              (and
                                 (== $At (val 2 Bnd))
                                 (prog
                                    (set $At (val Bnd))
                                    (=0 (dec 'N)) ) ) )
                           (setq Bnd (val 3 Bnd)) ) ) ) )
               (evList E) ) ) ) ) )

# (run 'any ['cnt ['lst]]) -> any
(de _run (Exe)
   (let (X (cdr Exe)  E (eval (car X)))
      (cond
         ((num? E) E)
         ((sym? E) (val E))
         ((atom (shift X)) (run E))
         (T
            (save E
               (let N (needCnt Exe (eval (car X)))
                  (unless (or (sign? N) (=0 (setq N (int N))))
                     (let Bnd (val $Bind)
                        (loop
                           (? (=0 Bnd))
                           (?
                              (and
                                 (== $At (val 2 Bnd))
                                 (prog
                                    (set $At (val Bnd))
                                    (=0 (dec 'N)) ) ) )
                           (setq Bnd (val 3 Bnd)) ) ) ) )
               (run E) ) ) ) ) )

# (def 'sym 'any) -> sym
# (def 'sym 'sym 'any) -> sym
(de _def (Exe)
   (let
      (X (cdr Exe)
         Sym (save (needSym Exe (eval (++ X))))
         Y (save (eval (++ X))) )
      (if (pair X)
         (let Val (save (eval (car X)))
            (when (sym? (val (tail Sym)))
               (if (nil? Y)
                  (dbFetch Exe Sym)  # Volatile property
                  (dbTouch Exe Sym) ) )
            (let V (get Sym Y)
               (unless (or (nil? V) (equal V Val))
                  (redefMsg Sym Y) ) )
            (put Sym Y Val)
            (putSrc Sym Y) )
         (chkVar Exe Sym)
         (when (sym? (val (tail Sym)))
            (dbTouch Exe Sym) )
         (let V (val Sym)
            (unless (or (nil? V) (== V Sym) (equal V Y))
               (redefMsg Sym 0) ) )
         (set Sym Y)
         (putSrc Sym 0) )
      Sym ) )

# (de sym . any) -> sym
(de _de (Exe)
   (let S (cadr Exe)
      (redefine Exe S (cddr Exe))
      S ) )

# (dm sym . fun|cls2) -> sym
# (dm (sym . cls) . fun|cls2) -> sym
# (dm (sym sym2 [. cls]) . fun|cls2) -> sym
(de _dm (Exe)
   $Nil )

# Apply METH to CDR of list
(local) evMethod

(de evMethod (Obj Cls Key Exe Lst)
   (let
      (X (cdr Lst)  # Arguments
         Y (car Exe)  # Parameters
         P (set $Bind (push (val $At) $At (val $Bind) Lst)) )  # [[@] @ LINK Exe]
      (set $Bind (setq P (push $This Obj P)))
      (while (pair Y)
         (set $Bind
            (setq P
               (push  # [val sym LINK]
                  (eval (++ X))  # Evaluate next argument
                  (++ Y)  # Next parameter
                  P ) ) ) )
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
               (loop
                  (let Sym (val 2 P)
                     (xchg Sym P)  # Exchange symbol value
                     (? (== $At Sym))
                     (setq P (val 3 P)) ) )
               (let (C (val $Cls)  K (val $Key))
                  (prog1
                     (run (cdr Exe))  # Run body
                     (set
                        $Key K
                        $Cls C
                        $Next (val Next)
                        $Link (val $Link) ) ) ) )
            (unless (== Y $Nil)
               (set
                  $Bind (push (val Y) Y P)  # Last parameter
                  Y X ) )  # Set to unevaluated argument(s)
            (loop
               (let Sym (val 2 P)
                  (xchg Sym P)  # Exchange symbol value
                  (? (== $At Sym))
                  (setq P (val 3 P)) ) )
            (let (C (val $Cls)  K (val $Key))
               (set $Cls Cls)
               (set $Key Key)
               (run (cdr Exe))  # Run body
               (set $Key K  $Cls C) ) )
         (setq P (val $Bind))
         (loop
            (let Sym (val 2 P)
               (set Sym (val P))  # Restore values
               (? (== $At Sym))
               (setq P (val 3 P)) ) )
         (set $Bind (val 3 P)) ) ) )

# (meth 'obj ['any ..]) -> any
(de _meth (Exe)
   Exe )

# (box 'any) -> sym
(de _box (Exe)
   (consSym ZERO (eval (cadr Exe))) )

# (and 'any ..) -> any
(de _and (Exe)
   (let X (cdr Exe)
      (loop
         (let Y (eval (++ X))
            (? (nil? Y) Y)
            (set $At Y)
            (? (atom X) Y) ) ) ) )

# (or 'any ..) -> any
(de _or (Exe)
   (let X (cdr Exe)
      (loop
         (let Y (eval (++ X))
            (? (not (nil? Y))
               (set $At Y)
               Y )
            (? (atom X) Y) ) ) ) )

# (not 'any) -> flg
(de _not (Exe)
   (if (nil? (eval (cadr Exe)))
      $T
      (set $At @)
      $Nil ) )

# (nil . prg) -> NIL
(de _nil (Exe)
   (run (cdr Exe))
   $Nil )

# (t . prg) -> T
(de _t (Exe)
   (run (cdr Exe))
   $T )

# (prog . prg) -> any
(de _prog (Exe)
   (run (cdr Exe)) )

# (prog1 'any1 . prg) -> any1
(de _prog1 (Exe)
   (let X (cdr Exe)
      (prog1
         (eval (++ X))
         (set $At @)
         (run X) ) ) )

# (prog2 'any1 'any2 . prg) -> any2
(de _prog2 (Exe)
   (let X (cdr Exe)
      (prog2
         (eval (++ X))
         (eval (++ X))
         (set $At @)
         (run X) ) ) )

# (if 'any1 any2 . prg) -> any
(de _if (Exe)
   (let X (cdr Exe)
      (if (nil? (eval (++ X)))
         (run (cdr X))
         (set $At @)
         (eval (car X)) ) ) )

# (ifn 'any1 any2 . prg) -> any
(de _ifn (Exe)
   (let X (cdr Exe)
      (ifn (nil? (eval (++ X)))
         (run (cdr X))
         (set $At @)
         (eval (car X)) ) ) )

# (if2 'any1 'any2 any3 any4 any5 . prg) -> any
(de _if2 (Exe)
   (let X (cdr Exe)
      (if (nil? (eval (++ X)))
         (if (nil? (eval (++ X)))
            (run (cdr (cddr X)))
            (set $At @)
            (eval (car (cddr X))) )
         (set $At @)
         (if (nil? (eval (++ X)))
            (eval (cadr X))
            (set $At @)
            (eval (car X)) ) ) ) )

# (when 'any . prg) -> any
(de _when (Exe)
   (let X (cdr Exe)
      (if (nil? (eval (++ X)))
         @
         (set $At @)
         (run X) ) ) )

# (unless 'any . prg) -> any
(de _unless (Exe)
   (let X (cdr Exe)
      (if (nil? (eval (++ X)))
         (run X)
         (set $At @)
         $Nil ) ) )

# (cond ('any1 . prg1) ('any2 . prg2) ..) -> any
(de _cond (Exe)
   (let X Exe
      (loop
         (? (atom (shift X)) $Nil)
         (let Y (car X)
            (? (not (nil? (eval (car Y))))
               (set $At @)
               (run (cdr Y)) ) ) ) ) )

# (nond ('any1 . prg1) ('any2 . prg2) ..) -> any
(de _nond (Exe)
   (let X Exe
      (loop
         (? (atom (shift X)) $Nil)
         (let Y (car X)
            (? (nil? (eval (car Y)))
               (run (cdr Y)) ) )
         (set $At @) ) ) )

# (case 'any (any1 . prg1) (any2 . prg2) ..) -> any
(de _case (Exe)
   (let (X (cdr Exe)  A (set $At (eval (car X))))
      (loop
         (? (atom (shift X)) $Nil)
         (let (Y (car X)  Z (car Y))
            (?
               (or
                  (t? Z)
                  (if (atom Z) (equal Z A) (member A Z)) )
               (run (cdr Y)) ) ) ) ) )

# (casq 'any (any1 . prg1) (any2 . prg2) ..) -> any
(de _casq (Exe)
   (let (X (cdr Exe)  A (set $At (eval (car X))))
      (loop
         (? (atom (shift X)) $Nil)
         (let (Y (car X)  Z (car Y))
            (? (or (t? Z) (== Z A) (memq A Z))
               (run (cdr Y)) ) ) ) ) )

# (state 'var (sym|lst exe [. prg]) ..) -> any
(de _state (Exe)
   (let
      (X (cdr Exe)
         Var (save (needChkVar Exe (eval (car X)))) )
      (loop
         (? (atom (shift X)) $Nil)
         (let (Y (car X)  Z (car Y))
            (when
               (or
                  (t? Z)
                  (let V (val Var)
                     (or (== Z V) (memq V Z)) ) )
               (? (not (nil? (eval (car (shift Y)))))
                  (set Var (set $At @))
                  (run (cdr Y)) ) ) ) ) ) )

# (while 'any . prg) -> any
(de _while (Exe)
   (let (X (cdr Exe)  E (++ X)  R (save $Nil))
      (until (nil? (eval E))
         (set $At @)
         (setq R (safe (run X))) )
      R ) )

# (until 'any . prg) -> any
(de _until (Exe)
   (let (X (cdr Exe)  E (++ X)  R (save $Nil))
      (while (nil? (eval E))
         (setq R (safe (run X))) )
      (set $At @)
      R ) )

# (at '(cnt1 . cnt2|NIL) . prg) -> any
(de _at (Exe)
   (let
      (X (cdr Exe)
         Y (needPair Exe (eval (car X)))
         Z (cdr Y) )
      (cond
         ((nil? Z) @)
         ((< (+ (car Y) (hex "10")) Z)  # Increment
            (set Y @)
            $Nil )
         (T
            (set Y ZERO)
            (run (cdr X)) ) ) ) )

(local) (loop1 loop2)

(de loop1 (X)
   (loop
      (let E (car X)
         (unless (num? E)
            (setq E
               (cond
                  ((sym? E) (val E))
                  ((nil? (car E))
                     (? (nil? (eval (car (shift E))))
                        (run (cdr E)) )
                     (set $At @)
                     $Nil )
                  ((t? (car E))
                     (? (not (nil? (eval (car (shift E)))))
                        (set $At @)
                        (run (cdr E)) )
                     @ )  # NIL
                  (T (evList E)) ) ) )
         (? (atom (shift X)) (| E 1)) ) ) )

(de loop2 (Y)
   (loop
      (let X Y
         (loop
            (let E (car X)
               (when (pair E)
                  (cond
                     ((nil? (car E))
                        (when (nil? (eval (car (shift E))))
                           (ret (run (cdr E))) )
                        (set $At @) )
                     ((t? (car E))
                        (unless (nil? (eval (car (shift E))))
                           (set $At @)
                           (ret (run (cdr E))) ) )
                     (T (evList E)) ) ) )
            (? (atom (shift X))) ) ) ) )

# (do 'flg|cnt ['any | (NIL 'any . prg) | (T 'any . prg) ..]) -> any
(de _do (Exe)
   (let (X (cdr Exe)  Y (eval (++ X)))
      (cond
         ((nil? Y) Y)
         ((cnt? Y)
            (let N (int Y)
               (if (or (sign? Y) (=0 N))
                  $Nil
                  (loop
                     (let R (loop1 X)
                        (? (=0 (& R 1)) R)
                        (? (=0 (dec 'N)) (& R -2)) ) ) ) ) )
         (T (loop2 X)) ) ) )  # Non-NIL 'flg'

# (loop ['any | (NIL 'any . prg) | (T 'any . prg) ..]) -> any
(de _loop (Exe)
   (tailcall
      (loop2 (cdr Exe)) ) )

# (for sym 'cnt ['any | (NIL 'any . prg) | (T 'any . prg) ..]) -> any
# (for sym|(sym2 . sym) 'lst ['any | (NIL 'any . prg) | (T 'any . prg) ..]) -> any
# (for (sym|(sym2 . sym) 'any1 'any2 [. prg]) ['any | (NIL 'any . prg) | (T 'any . prg) ..]) -> any
(de _for (Exe)
   (let
      (X (cdr Exe)
         Y (++ X)
         P (set $Bind (push NIL NIL (val $Bind)))  # [[sym] sym LINK]
         R $Nil )
      (cond
         ((atom Y)  # (for sym 'cnt|lst ..)
            (set P (val Y)  2 P Y)
            (let V (eval (++ X))
               (if (num? V)  # (for sym 'cnt ..)
                  (unless (sign? V)
                     (set Y ZERO)
                     (loop
                        (? (> (+ (val Y) (hex "10")) V)  # Increment
                           (setq R (& R -2)) )
                        (set Y @)
                        (? (=0 (& (setq R (loop1 X)) 1))) ) )
                  (save V
                     (loop  # (for sym 'lst ..)
                        (? (atom V) (setq R (& R -2)))
                        (set Y (++ V))
                        (? (=0 (& (setq R (loop1 X)) 1))) ) ) ) ) )
         ((atom (cdr Y))  # (for (sym2 . sym) 'lst ..)
            (let Sym2 @
               (set P (val (setq Y (car Y)))  2 P Y)
               (let
                  (Q (set $Bind (push (val Sym2) Sym2 (val $Bind)))  # [[sym] sym LINK]
                     V (save (eval (++ X))) )
                  (set Y ONE)
                  (loop
                     (? (atom V) (setq R (& R -2)))
                     (set Sym2 (++ V))
                     (? (=0 (& (setq R (loop1 X)) 1)))
                     (set Y (+ (val Y) (hex "10"))) )
                  (set Sym2 (val Q)) ) ) )
         ((atom (car Y))  # (for (sym ..) ..)
            (let Z (cdr Y)
               (set
                  P (val (setq Y @))
                  2 P Y
                  Y (eval (++ Z)) )
               (save R
                  (loop  # (any2 . prg)
                     (? (nil? (eval (car Z)))
                        (setq R (& R -2)) )
                     (set $At @)
                     (? (=0 (& (setq R (loop1 X)) 1)))
                     (safe R)
                     (when (pair (cdr Z))
                        (set Y (run @)) ) ) ) ) )
         (T  # (for ((sym2 . sym) ..) ..)
            (let (Sym2 (cdr @)  Z (cdr Y))
               (set P (val (setq Y (car @)))  2 P Y)
               (save R
                  (let Q (set $Bind (push (val Sym2) Sym2 (val $Bind)))  # [[sym] sym LINK]
                     (set
                        Sym2 (save (eval (++ Z)))
                        Y ONE )
                     (loop
                        (? (nil? (eval (car Z)))
                           (setq R (& R -2)) )
                        (set $At @)
                        (? (=0 (& (setq R (loop1 X)) 1)))
                        (safe R)
                        (when (pair (cdr Z))
                           (set Sym2 (run @)) )
                        (set Y (+ (val Y) (hex "10"))) )
                     (set Sym2 (val Q)) ) ) ) ) )
      (set Y (val P)  $Bind (val 3 P))
      R ) )

# (with 'var . prg) -> any
(de _with (Exe)
   (let (X (cdr Exe)  Y (needVar Exe (eval (++ X))))
      (if (nil? Y)
         Y
         (let P (set $Bind (push (val $This) $This (val $Bind)))  # [[This] This LINK]
            (set $This Y)
            (prog1
               (run X)
               (set $This (val P)  $Bind (val 3 P)) ) ) ) ) )

# (bind 'sym|lst . prg) -> any
(de _bind (Exe)
   (let (X (cdr Exe)  Y (eval (++ X)))
      (cond
         ((num? Y) (argErr Exe Y))
         ((nil? Y) (run X))
         ((sym? Y)  # Single symbol
            (let P (set $Bind (push (val Y) Y (val $Bind)))  # [[sym] sym LINK]
               (prog1
                  (run X)
                  (set Y (val P)  $Bind (val 3 P)) ) ) )
         (T
            (let (P (val $Bind)  Q P)
               (loop
                  (let Z (++ Y)
                     (when (num? Z)
                        (argErr Exe Y) )
                     (if (sym? Z)
                        (set $Bind (setq P (push (val Z) Z P)))
                        (let S (car Z)
                           (set
                              $Bind (setq P (push (val S) S P))
                              S (cdr Z) ) ) ) )
                  (? (atom Y)) )
               (prog1
                  (run X)
                  (loop
                     (set (val 2 P) (val P))  # Restore values
                     (? (== Q (setq P (val 3 P)) ) ) )
                  (set $Bind P) ) ) ) ) ) )

(local) setDestruct

(de void setDestruct (Pat Val)
   (loop
      (when (atom Val)  # Default non-list to NIL
         (setq Val $Nil) )
      (let (P (++ Pat)  V (++ Val))
         (if (atom P)
            (unless (nil? P)
               (set P V) )
            (setDestruct P V) ) )
      (? (atom Pat)
         (unless (nil? Pat)
            (set Pat Val) ) ) ) )

# (let sym 'any . prg) -> any
# (let (sym|lst 'any ..) . prg) -> any
(de _let (Exe)
   (shift Exe)
   (let X (++ Exe)
      (if (atom X)
         (let P (set $Bind (push (val X) X (val $Bind)))  # [[sym] sym LINK]
            (set X (eval (++ Exe)))
            (prog1
               (run Exe)
               (set X (val P)  $Bind (val 3 P)) ) )
         (let (P (val $Bind)  Q P)
            (loop
               (let Y (car X)
                  (if (atom Y)  # Single symbol
                     (set
                        $Bind (setq P (push (val Y) Y P))
                        Y (eval (car (shift X))) )
                     (let Tos 0  # List structure
                        (loop
                           (loop
                              (? (atom (car Y)))  # Left?
                              (let Z Y  # Go left
                                 (setq Y @)  # Invert tree
                                 (set Z Tos)
                                 (setq Tos Z) ) )
                           (let S (car Y)
                              (unless (nil? S)  # Skip NIL
                                 (set $Bind (setq P (push (val S) S P))) ) )
                           (loop
                              (? (pair (cdr Y))  # Right subtree
                                 (let Z Y  # Go right
                                    (setq Y @)  # Invert tree
                                    (set 2 Z Tos)
                                    (setq Tos (| Z 8)) ) )
                              (let S @
                                 (unless (nil? S)  # Dotted structure symbol
                                    (set $Bind (setq P (push (val S) S P))) ) )
                              (loop
                                 (and (=0 Tos) (goto 1))
                                 (? (=0 (& Tos 8))  # Second visit
                                    (let Z Tos
                                       (setq Tos (car Z))  # TOS on up link
                                       (set Z Y)
                                       (setq Y Z) ) )
                                 (let Z (& Tos -9)  # Set second visit
                                    (setq Tos (cdr Z))
                                    (set 2 Z Y)
                                    (setq Y Z) ) ) ) ) )
                     (: 1
                        (setDestruct (++ X) (eval (car X))) ) ) )
               (? (atom (shift X))) )
            (prog1
               (run Exe)
               (loop
                  (set (val 2 P) (val P))  # Restore values
                  (? (== Q (setq P (val 3 P)) ) ) )
               (set $Bind P) ) ) ) ) )

# (catch 'any . prg) -> any
(de _catch (Exe)
   (let
      (X (cdr Exe)
         Ca: (caFrame (b8 (+ (val JmpBufSize) (caFrame T)))) )
      (Ca: tag (eval (++ X)))
      (Ca: link (val $Catch))
      (set $Catch (Ca:))
      (Ca: fin ZERO)
      (memcpy (Ca: (env)) (env) (env T))
      (prog1
         (if (=0 (setjmp (Ca: (rst))))
            (run X)
            (val $Ret) )
         (set $Catch (Ca: link)) ) ) )

# (throw 'sym 'any)
(de _throw (Exe)
   (let (X (cdr Exe)  Tag (eval (++ X)))
      (set $Ret (eval (car X)))
      (let Ca (val $Catch)
         (until (=0 Ca)
            (let Ca: (caFrame Ca)
               (when (or (== $T (Ca: tag)) (== Tag (Ca: tag)))
                  (unwind Ca)
                  (longjmp (Ca: (rst)) 1) )
               (setq Ca (Ca: link)) ) ) )
      (err Exe Tag ($ "Tag not found") null) ) )

# (finally exe . prg) -> any
(de _finally (Exe)
   $Nil )

# Coroutines
(local) (saveCoEnv loadCoEnv)

(de void saveCoEnv ((i8* . Src))
   (let Src: (coroutine Src)
      (Src: at (val $At))
      (memcpy (Src: (env)) (env) (env T)) ) )

(de loadCoEnv ((i8* . Src))
   (let Src: (coroutine Src)
      (memcpy (env) (Src: (env)) (env T))
      (set $At (Src: at))
      (Src: at 0)
      (val $Ret) ) )

# (co 'sym [. prg]) -> any
(de _co (Exe)
   (let (X (cdr Exe)  Tag (eval (++ X)))
      (when (=0 (val $Coroutines))  # First call
         (let Main: (coroutine (alloc null (+ (val JmpBufSize) (coroutine T))))
            (Main: tag $T)  # Tag 'T'
            (Main: next null)
            (Main: prg $Nil)
            (Main: lim null)
            (Main: at 0)
            (set $Coroutines (Main:))
            (let Co: (coFrame (alloc null (coFrame T)))
               (Co: link null)
               (Co: crt (Main:))
               (set $CoFrames (Co:)) ) ) )
      (if (atom X)
         (let Crt (val $Coroutines)  # Stop coroutine
            (loop
               (let Crt: (coroutine Crt)
                  (? (== Tag (Crt: tag))  # Found coroutine
                     (Crt: tag 0) )
                  (? (=0 (setq Crt (Crt: next)))) ) )
            $Nil )
         (let
            (Src ((coFrame (val $CoFrames)) crt)
               Crt (val $Coroutines)
               P (i8* null) )
            (saveCoEnv Src)
            (loop
               (let Crt: (coroutine Crt)
                  (when (== Tag (Crt: tag))  # Found running coroutine
                     (when (=0 ((coroutine Crt) at))
                        (err Exe Tag ($ "Reentrant coroutine") null) )
                     (unless (=0 (setjmp ((coroutine Src) (rst))))
                        (ret
                           (loadCoEnv
                              ((coFrame (val (i8** (val $CoFrames)))) crt) ) ) )
                     (set $Ret $Nil)
                     (longjmp (Crt: (rst)) 1) )
                  (when (=0 (Crt: tag))
                     (setq P Crt) )  # Remember possible free slot
                  (? (=0 (Crt: next)))
                  (setq Crt (Crt: next)) ) )
            (unless (=0 (setjmp ((coroutine Src) (rst))))
               (ret
                  (loadCoEnv
                     ((coFrame (val (i8** (val $CoFrames)))) crt) ) ) )
            (ifn (=0 P)  # Start new coroutine
               (stack P)  # Use free slot
               (stack  # Found no free slot
                  (if (== Crt (val $Coroutines))
                     (ofs (stack) (* 4 (val $StkSize)))  # First coroutine
                     (ofs Crt (val $StkSize)) ) )  # Allocate below last
               (setq P (b8 (+ (val JmpBufSize) (coroutine T))))
               ((coroutine Crt) next P)
               ((coroutine P) next null) )
            (let (Co: (coFrame (b8 (coFrame T)))  Dst: (coroutine P))
               (Co: link (val $CoFrames))
               (Co: crt P)
               (set $CoFrames (Co:))
               (Dst: tag Tag)
               (Dst: prg X)
               (Dst: lim null)
               (Dst: at 0)
               (set  # Init local env
                  $Make 0
                  $Yoke 0
                  #{$StkLimit (- .. 4096 (val $StkSize)))}# )
               (set $Ret (run X))
               (Dst: tag 0) )  # Mark as unused
            (longjmp
               ((coroutine
                     ((coFrame (val (i8** (val $CoFrames)))) crt) )
                  (rst) )
               1 ) ) ) ) )

# (yield 'any ['sym]) -> any
(de _yield (Exe)
   (let
      (X (cdr Exe)
         Val (save (eval (++ X)))
         Tag (eval (++ X))
         Crt (val $Coroutines) )
      (when (=0 Crt)
         (err Exe 0 ($ "No coroutines") null) )
      (let
         (Co: (coFrame (val $CoFrames))
            Dst:
            (coroutine
               (if (nil? Tag)
                  (if (=0 (Co: link))
                     (err Exe 0 ($ "Tag expected") null)
                     ((coFrame (Co: link)) crt) )
                  (until (== Tag ((coroutine Crt) tag))
                     (when (=0 (setq Crt ((coroutine Crt) next)))
                        (err Exe Tag ($ "Coroutine not found") null) ) )
                  (when (=0 ((coroutine Crt) at))
                     (err Exe Tag ($ "Reentrant coroutine") null) )
                  Crt ) )
            Src (Co: crt) )
         (saveCoEnv Src)
         (when (=0 (setjmp ((coroutine Src) (rst))))
            (set $Ret Val)
            (longjmp (Dst: (rst)) 1) )
         (loadCoEnv Src) ) ) )

# (bye ['cnt])
(de _bye (Exe)
   (bye
      (if (nil? (eval (cadr Exe)))
         0
         (i32 (xCnt Exe @)) ) ) )
