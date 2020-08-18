# 18aug20 Software Lab. Alexander Burger

(symbols '(llvm))

(local) (redefMsg putSrc redefine)

(de void redefMsg (Sym Sym2)
   (let (Out (val $OutFile)  Put (val (i8** $Put)))
      (set
         $OutFile (val 3 (val $OutFiles))  # Stderr
         $Put (fun (void i8) _putStdout) )
      (outString ($ "# "))
      (print Sym)
      (when Sym2
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
         (when (and (In:) (In: name))
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

# (as 'any1 . any2) -> any2 | NIL
(de _as (Exe)
   (let X (cdr Exe)
      (if (nil? (eval (car X)))
         @
         (cdr X) ) ) )

# (lit 'any) -> any
(de _lit (Exe)
   (let X (eval (cadr Exe))
      (if
         (or
            (num? X)
            (nil? X)
            (t? X)
            (and (pair X) (num? (car X))) )
         X
         (cons $Quote X) ) ) )

# (eval 'any ['cnt]) -> any
(de _eval (Exe)
   (let (X (cdr Exe)  E (eval (car X)))
      (cond
         ((num? E) E)
         ((sym? E) (val E))
         ((atom (shift X)) (evList E))
         (T
            (save E
               (let N (needCnt Exe (eval (car X)))
                  (when (setq N (int N))
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

# (run 'any ['cnt]) -> any
(de _run (Exe)
   (let (X (cdr Exe)  E (eval (car X)))
      (cond
         ((num? E) E)
         ((sym? E) (val E))
         ((atom (shift X)) (runAt E))
         (T
            (save E
               (let N (needCnt Exe (eval (car X)))
                  (when (setq N (int N))
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
               (runAt E) ) ) ) ) )

# (def 'sym 'any) -> sym
# (def 'sym 'sym 'any) -> sym
(de _def (Exe)
   (let
      (X (cdr Exe)
         Sym (save (needSymb Exe (eval (++ X))))
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
         P (set $Bind (push (val $At) $At (val $Bind) Lst)) )  # [[@] @ LINK Expr]
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
               (let (C (val $Cls)  K (val $Key))
                  (prog1
                     (run (cdr Exe))  # Run body
                     (set $Key K  $Cls C  $Next Next  $Link Link) ) ) )
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
               (prog1
                  (run (cdr Exe))  # Run body
                  (set $Key K  $Cls C) ) ) )
         (setq P (val $Bind))
         (loop
            (let Sym (val 2 P)
               (set Sym (val P))  # Restore values
               (? (== $At Sym))
               (setq P (val 3 P)) ) )
         (set $Bind (val 3 P)) ) ) )

# (meth 'obj ['any ..]) -> any
(de _meth (Exe)
   #!
   Exe )

# (box 'any) -> sym
(de _box (Exe)
   (consSym ZERO (eval (cadr Exe))) )

# (new ['flg|num] ['typ ['any ..]]) -> obj
(de _new (Exe)
   #!
   Exe )

# (type 'any) -> lst
(de _type (Exe)
   #!
   Exe )

# (isa 'cls|typ 'any) -> obj | NIL
(de _isa (Exe)
   #!
   Exe )

# (method 'msg 'obj) -> fun
(de _method (Exe)
   #!
   Exe )

# (send 'msg 'obj ['any ..]) -> any
(de _send (Exe)
   #!
   Exe )

# (try 'msg 'obj ['any ..]) -> any
(de _try (Exe)
   #!
   Exe )

# (super ['any ..]) -> any
(de _super (Exe)
   #!
   Exe )

# (extra ['any ..]) -> any
(de _extra (Exe)
   #!
   Exe )

# (and 'any ..) -> any
(de _and (Exe)
   (let X (cdr Exe)
      (loop
         (let Y (eval (car X))
            (? (nil? Y) Y)
            (set $At Y)
            (? (atom (shift X)) Y) ) ) ) )

# (or 'any ..) -> any
(de _or (Exe)
   (let X (cdr Exe)
      (loop
         (let Y (eval (car X))
            (? (not (nil? Y))
               (set $At Y) )
            (? (atom (shift X)) Y) ) ) ) )

# (nand 'any ..) -> flg
(de _nand (Exe)
   (let X (cdr Exe)
      (loop
         (let Y (eval (car X))
            (? (nil? Y) $T)
            (set $At Y)
            (? (atom (shift X)) $Nil) ) ) ) )

# (nor 'any ..) -> flg
(de _nor (Exe)
   (let X (cdr Exe)
      (loop
         (let Y (eval (car X))
            (? (not (nil? Y))
               (set $At Y)
               $Nil )
            (? (atom (shift X)) $T) ) ) ) )

# (xor 'any 'any) -> flg
(de _xor (Exe)
   (let X (cdr Exe)
      (if (nil? (eval (++ X)))
         (if (nil? (eval (car X))) @ $T)
         (if (nil? (eval (car X))) $T $Nil) ) ) )

# (bool 'any) -> flg
(de _bool (Exe)
   (if (nil? (eval (cadr Exe))) @ $T) )

# (not 'any) -> flg
(de _not (Exe)
   (if (nil? (eval (cadr Exe)))
      $T
      (set $At @)
      $Nil ) )

# (nil . prg) -> NIL
(de _nil (Exe)
   (exec (cdr Exe))
   $Nil )

# (t . prg) -> T
(de _t (Exe)
   (exec (cdr Exe))
   $T )

# (prog . prg) -> any
(de _prog (Exe)
   (run (cdr Exe)) )

# (prog1 'any1 . prg) -> any1
(de _prog1 (Exe)
   (let X (cdr Exe)
      (prog1
         (set $At (save (eval (++ X))))
         (exec X) ) ) )

# (prog2 'any1 'any2 . prg) -> any2
(de _prog2 (Exe)
   (let X (cdr Exe)
      (prog2
         (eval (++ X))
         (set $At (save (eval (++ X))))
         (exec X) ) ) )

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
      (if (nil? (eval (++ X)))
         (eval (car X))
         (set $At @)
         (run (cdr X)) ) ) )

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
                     (? (nil? (eval (car Z))))
                     (set $At @)
                     (? (=0 (& (setq R (loop1 X)) 1)))
                     (safe (setq R (& R -2)))
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
                        (? (nil? (eval (car Z))))
                        (set $At @)
                        (? (=0 (& (setq R (loop1 X)) 1)))
                        (safe (setq R (& R -2)))
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

# (job 'lst . prg) -> any
(de _job (Exe)
   (let
      (X (cdr Exe)
         Y (save (eval (++ X)))
         P (val $Bind)
         Q P )
      (while (pair Y)
         (let (Z (++ Y)  S (car Z))
            (set
               $Bind (setq P (push (val S) S P Z))  # [[sym] sym LINK (sym . val)]
               S (cdr Z) ) ) )
      (prog1
         (run X)
         (until (== Q P)
            (let S (val 2 P)
               (set 2 (val 4 P) (val S))
               (set S (val P)) )  # Restore values
            (setq P (val 3 P)) )
         (set $Bind P) ) ) )

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
   (let (X (cdr Exe)  Y (++ X))
      (if (atom Y)
         (let P (set $Bind (push (val Y) Y (val $Bind)))  # [[sym] sym LINK]
            (set Y (eval (++ X)))
            (prog1
               (run X)
               (set Y (val P)  $Bind (val 3 P)) ) )
         (let (P (val $Bind)  Q P)
            (loop
               (let Z (car Y)
                  (if (atom Z)  # Single symbol
                     (set
                        $Bind (setq P (push (val Z) Z P))
                        Z (eval (car (shift Y))) )
                     (let Tos 0  # List structure
                        (loop
                           (loop
                              (? (atom (car Z)))  # Left?
                              (let U Z  # Go left
                                 (setq Z @)  # Invert tree
                                 (set U Tos)
                                 (setq Tos U) ) )
                           (let S (car Z)
                              (unless (nil? S)  # Skip NIL
                                 (set $Bind (setq P (push (val S) S P))) ) )
                           (loop
                              (? (pair (cdr Z))  # Right subtree
                                 (let U Z  # Go right
                                    (setq Z @)  # Invert tree
                                    (set 2 U Tos)
                                    (setq Tos (| U 8)) ) )
                              (let S @
                                 (unless (nil? S)  # Dotted structure symbol
                                    (set $Bind (setq P (push (val S) S P))) ) )
                              (loop
                                 (unless Tos
                                    (goto 1) )
                                 (? (=0 (& Tos 8))  # Second visit
                                    (let U Tos
                                       (setq Tos (car U))  # TOS on up link
                                       (set U Z)
                                       (setq Z U) ) )
                                 (let U (& Tos -9)  # Set second visit
                                    (setq Tos (cdr U))
                                    (set 2 U Z)
                                    (setq Z U) ) ) ) ) )
                     (: 1
                        (setDestruct (++ Y) (eval (car Y))) ) ) )
               (? (atom (shift Y))) )
            (prog1
               (run X)
               (loop
                  (set (val 2 P) (val P))  # Restore values
                  (? (== Q (setq P (val 3 P)) ) ) )
               (set $Bind P) ) ) ) ) )

# (let? sym 'any . prg) -> any
(de _letQ (Exe)
   (let (X (cdr Exe)  Y (++ X))
      (if (nil? (eval (car X)))
         @
         (let P (set $Bind (push (val Y) Y (val $Bind)))  # [[sym] sym LINK]
            (set Y @)
            (prog1
               (run (cdr X))
               (set Y (val P)  $Bind (val 3 P)) ) ) ) ) )

# (use sym . prg) -> any
# (use (sym ..) . prg) -> any
(de _use (Exe)
   (let (X (cdr Exe)  Y (++ X))
      (if (atom Y)
         (let P (set $Bind (push (val Y) Y (val $Bind)))  # [[sym] sym LINK]
            (prog1
               (run X)
               (set Y (val P)  $Bind (val 3 P)) ) )
         (let (P (val $Bind)  Q P)
            (loop
               (let Z (car Y)
                  (set $Bind (setq P (push (val Z) Z P))) )
               (? (atom (shift Y))) )
            (prog1
               (run X)
               (loop
                  (set (val 2 P) (val P))  # Restore values
                  (? (== Q (setq P (val 3 P)) ) ) )
               (set $Bind P) ) ) ) ) )

# (buf sym 'cnt . prg)
(de _buf (Exe)
   (let
      (X (cdr Exe)
         Y (++ X)
         Z (needCnt Exe (eval (++ X)))
         P (set $Bind (push (val Y) Y (val $Bind))) )  # [[sym] sym LINK]
      (set Y (box64 (i64 (b8 (int Z)))))
      (prog1
         (run X)
         (set Y (val P)  $Bind (val 3 P)) ) ) )

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
         (if (setjmp (Ca: (rst)))
            (val $Ret)
            (run X) )
         (set $Catch (Ca: link)) ) ) )

# (throw 'sym 'any)
(de _throw (Exe)
   (let (X (cdr Exe)  Tag (eval (++ X)))
      (set $Ret (eval (car X)))
      (let Ca (val $Catch)
         (while Ca
            (let Ca: (caFrame Ca)
               (when (or (== $T (Ca: tag)) (== Tag (Ca: tag)))
                  (unwind Ca)
                  (longjmp (Ca: (rst)) 1) )
               (setq Ca (Ca: link)) ) ) )
      (err Exe Tag ($ "Tag not found") null) ) )

# (finally exe . prg) -> any
(de _finally (Exe)
   (let
      (X (cdr Exe)
         Ca: (caFrame (b8 (+ (val JmpBufSize) (caFrame T)))) )
      (Ca: tag 0)
      (Ca: link (val $Catch))
      (set $Catch (Ca:))
      (Ca: fin (++ X))
      (memcpy (Ca: (env)) (env) (env T))
      (prog1
         (save (run X))
         (eval (Ca: fin))
         (set $Catch (Ca: link)) ) ) )

# Coroutines
(local) (reentErr saveCoEnv loadCoEnv)

(de NIL reentErr (Exe Tag)
   (err Exe Tag ($ "Reentrant coroutine") null) )

(de void saveCoEnv ((i8* . Src))
   (let Src: (coroutine Src)
      (Src: at (val $At))
      (memcpy (Src: (env)) (env) (env T)) ) )

(de loadCoEnv ((i8* . Src))
   (let Src: (coroutine (set $Current Src))
      (set $StkLimit (+ (Src: lim) 4096))
      (memcpy (env) (Src: (env)) (env T))
      (set $At (Src: at))
      (Src: at 0)
      (val $Ret) ) )

# (co 'sym [. prg]) -> any
(de _co (Exe)
   (let (X (cdr Exe)  Tag (eval (++ X)))
      (unless (val $Coroutines)  # First call
         (let Main: (coroutine (alloc null (+ (val JmpBufSize) (coroutine T))))
            (Main: tag $T)  # Tag 'T'
            (Main: prv null)
            (Main: nxt null)
            (Main: org null)
            (Main: prg $Nil)
            (Main: lim (ofs (Main:) (* -4 (val $StkSize))))
            (Main: at 0)
            (Main: bnd 0)
            (set $Coroutines (set $Current (Main:))) ) )
      (if (atom X)  # No 'prg'
         (let Crt (val $Coroutines)  # Stop coroutine
            (loop
               (let Crt: (coroutine Crt)
                  (? (== Tag (Crt: tag))  # Found coroutine
                     (Crt: tag 0) )  # Set unused
                  (? (=0 (setq Crt (Crt: nxt)))) ) )
            $Nil )
         (let
            (Src: (coroutine (val $Current))
               Crt (val $Coroutines)
               P (i8* null) )
            (saveCoEnv (Src:))
            (loop
               (let Crt: (coroutine Crt)
                  (when (== Tag (Crt: tag))  # Found running coroutine
                     (unless (Crt: at)
                        (reentErr Exe Tag) )
                     (when (setjmp (Src: (rst)))
                        (ret (loadCoEnv (Src:))) )
                     (set $Ret $Nil)
                     (longjmp (Crt: (rst)) 1) )
                  (unless (Crt: tag)  # Unused
                     (setq P Crt) )  # Remember possible free slot
                  (? (=0 (Crt: nxt)))
                  (setq Crt @) ) )
            # Start new coroutine
            (when (setjmp (Src: (rst)))
               (ret (loadCoEnv (Src:))) )
            (if P
               (stack P)  # Use free slot
               (stack ((coroutine Crt) lim)) # Found no free slot
               (setq P (b8 (+ (val JmpBufSize) (coroutine T))))
               ((coroutine Crt) nxt P)
               ((coroutine P) prv Crt)
               ((coroutine P) nxt null) )
            (let Dst: (coroutine P)
               (Dst: tag Tag)
               (Dst: org (val $Current))
               (Dst: prg X)
               (Dst: lim (ofs P (- (val $StkSize))))
               (Dst: at 0)
               (Dst: bnd (val $Bind))
               (memcpy (Dst: (env)) (env) (env T))
               (set  # Init local env
                  $Make 0
                  $Yoke 0
                  $Current (Dst:)
                  $StkLimit (+ (Dst: lim) 4096) )
               (set $Ret (run X))
               (Dst: tag 0)  # Mark as unused
               (longjmp ((coroutine (Dst: org)) (rst)) 1) ) ) ) ) )

# (yield 'any ['sym]) -> any
(de _yield (Exe)
   (let
      (X (cdr Exe)
         Val (save (eval (++ X)))
         Tag (eval (++ X))
         Crt (val $Coroutines) )
      (unless Crt
         (err Exe 0 ($ "No coroutines") null) )
      (let
         (Src: (coroutine (val $Current))
            Dst:
            (coroutine
               (cond
                  ((not (nil? Tag))
                     (loop
                        (let Crt: (coroutine Crt)
                           (? (== Tag (Crt: tag))
                              (unless (Crt: at)
                                 (reentErr Exe Tag) )
                              Crt )
                           (unless (setq Crt (Crt: nxt))
                              (err Exe Tag ($ "Coroutine not found") null) ) ) ) )
                  ((Src: org) @)
                  (T (err Exe 0 ($ "Tag expected") null)) ) ) )
         (let B (any 0)
            (when (Src: org)
               (let (Bnd (val $Bind)  Q (Src: bnd))  # Reverse bindings
                  (until (== Bnd Q)
                     (let P Bnd
                        (xchg (val 2 P) P)
                        (setq Bnd (val 3 P))
                        (set 3 P B)
                        (setq B P) ) ) )
               (set $Bind B) )
            (saveCoEnv (Src:))
            (unless (setjmp (Src: (rst)))
               (set $Ret Val)
               (longjmp (Dst: (rst)) 1) )
            (when (Src: org)
               (let Bnd (val $Bind)
                  (Src: bnd Bnd)
                  (while B  # Restore bindings
                     (let P B
                        (xchg (val 2 P) P)
                        (setq B (val 3 P))
                        (set 3 P Bnd)
                        (setq Bnd P) ) )
                  (Src: (env $Bind any) Bnd) ) ) )
         (loadCoEnv (Src:)) ) ) )

(de brkLoad (Exe)
   (when (and (isatty 0) (isatty 1) (=0 (val $Break)))
      (let P (val $Bind)
         (setq P (push (val $At) $At P 0))  # [[@] @ LINK Expr]
         (setq P (push (val $Up) $Up P))
         (set $Up Exe)
         (set $Break (set $Bind (push (val $Run) $Run P)))
         (set $Run $Nil) )
      (let (Out (b8 (ioFrame T))  Io: (ioFrame Out))
         (Io: fd 1)  # Stdout
         (Io: pid 0)
         (pushOutFiles Out)
         (print Exe)
         (newline)
         (repl 0 ($ "! ") $Nil)
         (popOutFiles) )
      (setq Exe (val $Up))
      (let P (val $Bind)
         (set $Run (val P))
         (setq P (val 3 P))
         (set $Up (val P))
         (setq P (val 3 P))
         (set $At (val P))
         (set $Bind (val 3 P)) )
      (set $Break 0) )
   Exe )

# (! . exe) -> any
(de _break (Exe)
   (let X (cdr Exe)
      (unless (nil? (val $Dbg))
         (setq X (brkLoad X)) )
      (eval X) ) )

# (e . prg) -> any
(de _e (Exe)
   (let P (val $Break)
      (unless P
         (err Exe 0 ($ "No Break")  null) )
      (let
         (Dbg (save (val $Dbg))
            At (save (val $At))
            Run (save (val $Run)) )
         (set
            $Dbg $Nil
            $At (val P)
            $Run (val (val 3 P)) )
         (let (In (val $InFrames)  Out (val $OutFrames))
            (popInFiles)
            (popOutFiles)
            (prog1
               (if (pair (cdr Exe))
                  (run @)
                  (eval (val $Up)) )
               (pushOutFiles Out)
               (pushInFiles In)
               (set $Run Run  $At At  $Dbg Dbg) ) ) ) ) )

(local) trace

(de void trace ((i32 . C) X)
   (when (> C 64)
      (setq C 64) )
   (while (ge0 (dec 'C))
      (space) )
   (if (atom X)  # Symbol
      (print @)
      (print (car X))  # Method
      (space)
      (print (cdr X))  # Class
      (space)
      (print (val $This)) ) )  # 'This'

# ($ sym|lst lst . prg) -> any
(de _trace (Exe)
   (let X (cdr Exe)
      (if (nil? (val $Dbg))
         (run (cddr X))
         (let (Out (val $OutFile)  Put (val (i8** $Put)))
            (set
               $OutFile (val 3 (val $OutFiles))  # Stderr
               $Put (fun (void i8) _putStdout) )
            (let (Y (++ X)  Z (++ X))
               (trace (set $Trace (inc (val $Trace))) Y)
               (outString ($ " :"))
               (while (pair Z)
                  (space)
                  (print (val (++ Z))) )
               (cond
                  ((== Z $At)
                     (setq Z (val $Next))
                     (while (pair Z)
                        (space)
                        (print (cdr Z))
                        (setq Z (car Z)) ) )
                  ((not (nil? Z))
                     (space)
                     (print (val Z)) ) )
               (newline)
               (set (i8** $Put) Put  $OutFile Out)
               (prog1
                  (run X)
                  (set
                     $OutFile (val 3 (val $OutFiles))  # Stderr
                     $Put (fun (void i8) _putStdout) )
                  (let I (val $Trace)
                     (trace I Y)
                     (set $Trace (dec I)) )
                  (outString ($ " = "))
                  (print @)
                  (newline)
                  (set (i8** $Put) Put  $OutFile Out) ) ) ) ) ) )

# (exec 'any ..)
(de _exec (Exe)
   (let
      (X (cdr Exe)
         Av (b8* (inc (length X)))
         Cmd (xName Exe (evSym X)) )
      (set Av (pathString Cmd (b8 (pathSize Cmd))))
      (let A Av
         (while (pair (shift X))
            (let Nm (xName Exe (evSym X))
               (set (inc 'A)
                  (bufString Nm (b8 (bufSize Nm))) ) ) )
         (set (inc 'A) null) )
      (flushAll)
      (execvp (val Av) Av)  # Execute program
      (execErr (val Av)) ) )  # Error if failed

# (call 'any ..) -> flg
(de _call (Exe)
   (let
      (X (cdr Exe)
         Av (b8* (inc (length X)))
         Cmd (xName Exe (evSym X)) )
      (set Av (pathString Cmd (b8 (pathSize Cmd))))
      (let A Av
         (while (pair (shift X))
            (let Nm (xName Exe (evSym X))
               (set (inc 'A)
                  (bufString Nm (b8 (bufSize Nm))) ) ) )
         (set (inc 'A) null) )
      (flushAll)
      (cond
         ((lt0 (fork)) (forkErr Exe))
         ((=0 @)  # In child
            (setpgid 0 0)  # Set process group
            (execvp (val Av) Av)  # Execute program
            (execErr (val Av)) ) )  # Error if failed
      # In parent
      (let (Pid @  Res (b32 1))
         (setpgid Pid 0)  # Set process group
         (when Termio  # Raw mode
            (tcsetpgrp 0 Pid) )
         (loop
            (while (lt0 (waitWuntraced Pid Res))
               (unless (== (gErrno) EINTR)
                  (err Exe 0 ($ "wait pid") null) )
               (sigChk Exe) )
         (when Termio
            (tcsetpgrp 0 (getpgrp)) )
         (? (=0 (wifStopped Res))
            (set $At2 (cnt (i64 (val Res))))
            (if (val Res) $Nil $T) )
         (repl 0 ($ "+ ") $Nil)
         (when Termio
            (tcsetpgrp 0 Pid) )
         (kill Pid (val SIGCONT Sig)) ) ) ) )

# (ipid) -> pid | NIL
(de _ipid (Exe)
   (let Io: (ioFrame (val $InFrames))
      (if (and (Io:) (> (Io: pid) 1))
         (cnt (i64 (Io: pid)))
         $Nil ) ) )

# (opid) -> pid | NIL
(de _opid (Exe)
   (let Io: (ioFrame (val $OutFrames))
      (if (and (Io:) (> (Io: pid) 1))
         (cnt (i64 (Io: pid)))
         $Nil ) ) )

# (kill 'pid ['cnt]) -> flg
(de _kill (Exe)
   (let (X (cdr Exe)  Pid (i32 (evCnt Exe X)))
      (if
         (kill
            Pid
            (if (atom (shift X))
               (val SIGTERM Sig)
               (i32 (evCnt Exe X)) ) )
         $Nil
         $T ) ) )

# (fork) -> pid | NIL
(de _fork (Exe)
   (if (forkLisp Exe)
      (cnt (i64 @))
      $Nil ) )

# (detach) -> pid | NIL
(de _detach (Exe)
   (prog1
      (val $PPid)
      (unless (nil? @)
         (set $PPid $Nil)
         (close (val $Tell))
         (set $Tell 0)
         (let H (val $Hear)
            (close H)
            (closeInFile H)
            (closeOutFile H) )
         (set $Hear 0)
         (close (val $Mic))
         (set $Mic 0)
         (set $Slot 0)
         (setsid) ) ) )

# (bye ['cnt])
(de _bye (Exe)
   (bye
      (if (nil? (eval (cadr Exe)))
         0
         (i32 (xCnt Exe @)) ) ) )
