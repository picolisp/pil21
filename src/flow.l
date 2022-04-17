# 17apr22 Software Lab. Alexander Burger

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
                     (cons (mkStr (In: name)) (val $Intern)) ) )
               (cond
                  ((=0 Key)
                     (if (nil? Dbg)
                        (put Sym $Dbg (cons Src $Nil))  # Put initial '*Dbg' properties
                        (set Dbg Src) ) )  # Set first '*Dbg' property
                  ((nil? Dbg)
                     (put Sym $Dbg
                        (cons $Nil (cons (cons Key Src) $Nil)) ) )
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
   (let (X (cdr Exe)  E (save (eval (car X))))
      (when (pair (cdr X))
         (let N (needCnt Exe (eval (car @)))
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
                     (setq Bnd (val 3 Bnd)) ) ) ) ) )
      (eval E) ) )

# (run 'any ['cnt]) -> any
(de _run (Exe)
   (let (X (cdr Exe)  E (eval (car X)))
      (cond
         ((num? E) E)
         ((sym? E) (val E))
         (T
            (save E
               (when (pair (cdr X))
                  (let N (needCnt Exe (eval (car @)))
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
                              (setq Bnd (val 3 Bnd)) ) ) ) ) )
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
   (let
      (X (cdr Exe)
         Y (car X)
         Fun (cdr X)
         Msg (if (atom Y) Y (car Y))
         Cls
         (cond
            ((atom Y) (val $Class))
            ((atom (cdr Y)) @)
            (T
               (let Z @
                  (get
                     (if (nil? (cdr Z)) (val $Class) @)
                     (car Z) ) ) ) ) )
      (unless (t? Msg)
         (redefine Exe Msg (val $Meth)) )
      (when (symb? Fun)
         (let L (val Fun)
            (loop
               (when (or (atom L) (atom (car L)))
                  (err Exe Msg ($ "Bad message") null) )
               (? (== Msg (caar L))  # Found in 'cls2'
                  (setq
                     X (car L)
                     Fun (cdr X) ) )
               (shift L) ) ) )
      (let (V (val Cls)  L V)
         (loop
            (? (or (atom L) (atom (car L)))  # New method
               (set Cls
                  (cons
                     (if (atom (car X))
                        X
                        (cons Msg Fun) )
                     V ) ) )
            (? (== Msg (caar L))  # Redefine method
               (let Z (car L)
                  (unless (equal Fun (cdr Z))
                     (redefMsg Msg Cls) )
                  (set 2 Z Fun) ) )
            (shift L) ) )
      (putSrc Cls Msg)
      Msg ) )

# Apply METH to CDR of list
(local) (evMethod method)

(de evMethod (Obj Typ Key Exe X)
   (let
      (Y (car Exe)  # Parameters
         P (set $Bind (push (val $At) $At (val $Bind) Exe)) )  # [[@] @ LINK Expr]
      (set $Bind (setq P (push Obj $This P)))
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
                     (let (TypS (val $Typ)  KeyS (val $Key))
                        (prog2
                           (set $Typ Typ  $Key Key)
                           (run (cdr Exe))  # Run body
                           (set $Key KeyS  $Typ TypS  $Next Next)
                           (drop (ofs Q 1)) ) ) ) )
               (let Next (val $Next)
                  (set $Next $Nil)
                  (loop
                     (let Sym (val 2 P)
                        (xchg Sym P)  # Exchange symbol value
                        (? (== $At Sym))
                        (setq P (val 3 P)) ) )
                  (let (TypS (val $Typ)  KeyS (val $Key))
                     (prog2
                        (set $Typ Typ  $Key Key)
                        (run (cdr Exe))  # Run body
                        (set $Key KeyS  $Typ TypS  $Next Next) ) ) ) )
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
            (let (TypS (val $Typ)  KeyS (val $Key))
               (prog2
                  (set $Typ Typ  $Key Key)
                  (run (cdr Exe))  # Run body
                  (set $Key KeyS  $Typ TypS) ) ) )
         (setq P (val $Bind))
         (loop
            (let Sym (val 2 P)
               (set Sym (val P))  # Restore values
               (? (== $At Sym))
               (setq P (val 3 P)) ) )
         (set $Bind (val 3 P)) ) ) )

(de method (Obj Key)
   (when (pair (val Obj))  # Class definition (methods and superclasses)
      (let L @
         (while (pair (car L))  # Method definition
            (let Y @
               (when (== Key (car Y))  # Found
                  (ret (cdr Y)) ) )
            (when (atom (shift L))
               (ret 0) ) )
         (stkChk 0)
         (loop
            (when (method (car (set $Ret L)) Key)  # Set class list
               (ret @) )
            (? (atom (shift L))) ) ) )
   0 )

# (meth 'obj ['any ..]) -> any
(de __meth (Exe Key)
   (let (X (cdr Exe)  Obj (save (eval (car X))))
      (when (sym? (val (tail (needSymb Exe Obj))))
         (dbFetch Exe Obj) )
      (set $Ret 0)  # Preset to "No classes"
      (if (method Obj Key)
         (evMethod Obj (val $Ret) Key @ (cdr X))
         (err Exe Key ($ "Bad message") null) ) ) )

# (box 'any) -> sym
(de _box (Exe)
   (consSym ZERO (eval (cadr Exe))) )

# (new ['flg|num] ['typ ['any ..]]) -> obj
(de _new (Exe)
   (let
      (X (cdr Exe)
         Y (eval (++ X))
         Obj
         (save
            (cond
               ((pair Y) (consSym ZERO Y))  # Anonymous with type
               ((nil? Y) (consSym ZERO ZERO))  # Anonymous with placeholder
               (T
                  (let Nm
                     (newId Exe  # External
                        (if (cnt? Y) (i32 (int @)) 1) )
                     (prog1
                        (extern Nm)
                        (set (tail @)
                           (sign (shr 1 (add Nm Nm) 1)) ) ) ) ) ) ) )  # Set "dirty"
      (unless (pair Y)
         (set Obj (eval (++ X))) )
      (set $Ret 0)  # Preset to "No classes"
      (cond
         ((method Obj $T)
            (evMethod Obj (val $Ret) $T @ X) )
         ((pair X)
            (let K (link (push NIL NIL))
               (loop
                  (put Obj
                     (set K (eval (++ X)))
                     (eval (++ X)) )
                  (? (atom X)) ) ) ) )
      Obj ) )

# (type 'any) -> lst
(de _type (Exe)
   (let (X (cdr Exe)  Y (eval (car X)))
      (ifn (symb? Y)
         $Nil
         (when (sym? (val (tail Y)))
            (dbFetch Exe Y) )
         (let (V (val Y)  Z V)
            (loop
               (? (atom V) $Nil)
               (? (atom (car V))  # Class
                  (let R V
                     (loop
                        (? (not (symb? (car V))) $Nil)
                        (? (atom (shift V))
                           (if (nil? V) R $Nil) )
                        (? (== Z V) $Nil) ) ) )
               (? (== Z (shift V)) $Nil) ) ) ) ) )

(local) isa

(de i1 isa (Cls Obj)
   (let (V (val Obj)  Z V)
      (loop
         (? (atom V) NO)
         (? (atom (car V))  # Class
            (stkChk 0)
            (loop
               (? (not (symb? (car V))) NO)
               (? (== @ Cls) YES)
               (? (isa Cls @) YES)
               (? (atom (shift V)) NO)
               (? (== Z V) NO) ) )
         (? (== Z (shift V)) NO) ) ) )

# (isa 'cls|typ 'any) -> obj | NIL
(de _isa (Exe)
   (let
      (X (cdr Exe)
         Y (save (eval (++ X)))
         Z (eval (car X)) )
      (ifn (symb? Z)
         $Nil
         (when (sym? (val (tail Z)))
            (dbFetch Exe Z) )
         (cond
            ((pair Y)
               (loop
                  (? (not (isa (car Y) Z)) $Nil)
                  (? (atom (shift Y)) Z) ) )
            ((isa Y Z) Z)
            (T $Nil) ) ) ) )

# (method 'msg 'obj) -> fun
(de _method (Exe)
   (let
      (X (cdr Exe)
         Msg (save (eval (++ X)))
         Obj (needSymb Exe (eval (car X))) )
      (when (sym? (val (tail Obj)))
         (dbFetch Exe Obj) )
      (if (method Obj Msg) @ $Nil) ) )

# (send 'msg 'obj ['any ..]) -> any
(de _send (Exe)
   (let
      (X (cdr Exe)
         Msg (save (eval (++ X)))
         Obj (save (needSymb Exe (eval (car X)))) )
      (when (sym? (val (tail Obj)))
         (dbFetch Exe Obj) )
      (set $Ret 0)  # Preset to "No classes"
      (if (method Obj Msg)
         (evMethod Obj (val $Ret) Msg @ (cdr X))
         (err Exe Msg ($ "Bad message") null) ) ) )

# (try 'msg 'obj ['any ..]) -> any
(de _try (Exe)
   (let
      (X (cdr Exe)
         Msg (save (eval (++ X)))
         Obj (save (eval (car X))) )
      (ifn (symb? Obj)
         $Nil
         (when (sym? (val (tail Obj)))
            (unless (isLife Obj)
               (goto 1) )
            (dbFetch Exe Obj) )
         (set $Ret 0)  # Preset to "No classes"
         (if (method Obj Msg)
            (evMethod Obj (val $Ret) Msg @ (cdr X))
            (: 1 $Nil) ) ) ) )

# (super ['any ..]) -> any
(de _super (Exe)
   (let
      (Lst (val (if (val $Typ) (car @) (val $This)))
         Key (val $Key) )
      (while (pair (car Lst))  # Skip methods
         (shift Lst) )
      (loop
         (when (atom Lst)  # No classes
            (err Exe Key ($ "Bad super") null) )
         (? (method (car (set $Ret Lst)) Key)  # Found
            (let (TypS (val $Typ)  KeyS (val $Key))
               (set $Typ (val $Ret)  $Key Key)  # Set class and key
               (prog1
                  (evExpr @ Exe)  # Evaluate expression
                  (set $Key KeyS  $Typ TypS) ) ) )  # Restore class and key
         (shift Lst) ) ) )

(local) extra

(de extra (Obj Key)
   (let Lst (val Obj)
      (while (pair (car Lst))  # Skip methods
         (shift Lst) )
      (loop  # Classes
         (? (atom Lst) -1)  # Not found on this level
         (? (== Lst (val $Typ))  # Hit current class list
            (loop  # Locate method in extra classes
               (? (atom (shift Lst)) 0)  # Try further
               (? (method (car (set $Ret Lst)) Key) @) ) )  # Found in superclass
         (stkChk 0)
         (? (gt0 (extra (car Lst) Key)) @)  # Found on this level
         (? (=0 @)
            (loop
               (? (atom (shift Lst)) 0)
               (? (method (car (set $Ret Lst)) Key) @) ) )  # Found in superclass
         (shift Lst) ) ) )  # Try next in class list

# (extra ['any ..]) -> any
(de _extra (Exe)
   (let Key (val $Key)
      (when (le0 (extra (val $This) Key))
         (err Exe Key ($ "Bad extra") null) )
      (let (TypS (val $Typ)  KeyS (val $Key))
         (set $Typ (val $Ret)  $Key Key)  # Set class and key
         (prog1
            (evExpr @ Exe)  # Evaluate expression
            (set $Key KeyS  $Typ TypS) ) ) ) )  # Restore class and key

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
   (tailcall (loop2 (cdr Exe))) )

# (for sym 'cnt ['any | (NIL 'any . prg) | (T 'any . prg) ..]) -> any
# (for sym|(sym2 . sym) 'lst ['any | (NIL 'any . prg) | (T 'any . prg) ..]) -> any
# (for (sym|(sym2 . sym) 'any1 'any2 [. prg]) ['any | (NIL 'any . prg) | (T 'any . prg) ..]) -> any
(de _for (Exe)
   (let
      (X (cdr Exe)
         Y (++ X)
         R $Nil )
      (cond
         ((atom Y)  # (for sym 'cnt|lst ..)
            (needChkVar Exe Y)
            (let P (set $Bind (push NIL NIL (val $Bind)))  # [[sym] sym LINK]
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
                           (? (=0 (& (setq R (loop1 X)) 1))) ) ) ) )
               (set Y (val P)  $Bind (val 3 P)) ) )
         ((atom (cdr Y))  # (for (sym2 . sym) 'lst ..)
            (let Sym2 (needChkVar Exe @)
               (needChkVar Exe (setq Y (car Y)))
               (let P (set $Bind (push NIL NIL (val $Bind)))  # [[sym] sym LINK]
                  (set P (val Y)  2 P Y)
                  (let
                     (Q (set $Bind (push (val Sym2) Sym2 (val $Bind)))  # [[sym] sym LINK]
                        V (save (eval (++ X))) )
                     (set Y ONE)
                     (loop
                        (? (atom V) (setq R (& R -2)))
                        (set Sym2 (++ V))
                        (? (=0 (& (setq R (loop1 X)) 1)))
                        (set Y (+ (val Y) (hex "10"))) )
                     (set Sym2 (val Q)) )
                  (set Y (val P)  $Bind (val 3 P)) ) ) )
         ((atom (car Y))  # (for (sym ..) ..)
            (let Z (cdr Y)
               (needChkVar Exe (setq Y @))
               (let P (set $Bind (push NIL NIL (val $Bind)))  # [[sym] sym LINK]
                  (set
                     P (val Y)
                     2 P Y
                     Y (eval (++ Z)) )
                  (save R
                     (loop  # (any2 . prg)
                        (? (nil? (eval (car Z))))
                        (set $At @)
                        (? (=0 (& (setq R (loop1 X)) 1)))
                        (safe (setq R (& R -2)))
                        (when (pair (cdr Z))
                           (set Y (run @)) ) ) )
                  (set Y (val P)  $Bind (val 3 P)) ) ) )
         (T  # (for ((sym2 . sym) ..) ..)
            (let (Sym2 (cdr @)  Z (cdr Y))
               (setq Y (car @))
               (needChkVar Exe Y)
               (needChkVar Exe Sym2)
               (let P (set $Bind (push NIL NIL (val $Bind)))  # [[sym] sym LINK]
                  (set P (val Y)  2 P Y)
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
                        (set Sym2 (val Q)) ) )
                  (set Y (val P)  $Bind (val 3 P)) ) ) ) )
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
            (chkVar Exe Y)
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
                        (set $Bind
                           (setq P (push (val Z) (chkVar Exe Z) P)) )
                        (let S (car Z)
                           (needChkVar Exe S)
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
            (needChkVar Exe S)
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
         (let P
            (set $Bind
               (push (val (needChkVar Exe Y)) Y (val $Bind)) )  # [[sym] sym LINK]
            (set Y (eval (++ X)))
            (prog1
               (run X)
               (set Y (val P)  $Bind (val 3 P)) ) )
         (let (P (val $Bind)  Q P)
            (loop
               (let Z (++ Y)
                  (if (atom Z)  # Single symbol
                     (set
                        $Bind (setq P (push (val (needChkVar Exe Z)) Z P))
                        Z (eval (car Y)) )
                     (let Tos 0  # List structure
                        (loop
                           (until (atom (car Z))
                              (let U Z  # Go left
                                 (setq Z @)  # Invert tree
                                 (set U Tos)
                                 (setq Tos U) ) )
                           (unless (nil? (car Z))  # Skip NIL
                              (let S (needChkVar Exe @)
                                 (set $Bind (setq P (push (val S) S P))) ) )
                           (loop
                              (? (pair (cdr Z))  # Right subtree
                                 (let U Z  # Go right
                                    (setq Z @)  # Invert tree
                                    (set 2 U Tos)
                                    (setq Tos (| U 8)) ) )
                              (unless (nil? @)  # Dotted structure symbol
                                 (let S (needChkVar Exe @)
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
                        (setDestruct Z (eval (car Y))) ) ) )
               (? (atom (shift Y))) )
            (prog1
               (run X)
               (loop
                  (set (val 2 P) (val P))  # Restore values
                  (? (== Q (setq P (val 3 P)) ) ) )
               (set $Bind P) ) ) ) ) )

# (let? sym 'any . prg) -> any
(de _letQ (Exe)
   (let (X (cdr Exe)  Y (needChkVar Exe (++ X)))
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

# (buf sym 'cnt . prg) -> any
(de _buf (Exe)
   (let
      (X (cdr Exe)
         Y (needChkVar Exe (++ X))
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
      (Ca: co (val $Current))
      (putCaEnv (Ca:))
      (prog1
         (if (setjmp (Ca: (rst)))
            (val $Ret)
            (run X) )
         (set $Catch (Ca: link)) ) ) )

# (throw 'sym 'any)
(de _throw (Exe)
   (let
      (X (cdr Exe)
         Tag (save (eval (++ X)))
         R (save (eval (car X))) )
      (let Ca (val $Catch)
         (while Ca
            (let Ca: (caFrame Ca)
               (when (or (t? (Ca: tag)) (== Tag (Ca: tag)))
                  (unwind Ca)
                  (set $Ret R)
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
      (Ca: co (val $Current))
      (putCaEnv (Ca:))
      (prog1
         (save (run X))
         (eval (Ca: fin))
         (set $Catch (Ca: link)) ) ) )

# Coroutines
(local) (reentErr saveCoIO saveCoEnv loadCoEnv)

(de NIL reentErr (Exe Tag)
   (err Exe Tag ($ "Reentrant coroutine") null) )

# Switch coroutines
(de void saveCoIO ()
   ((ioFrame (val $OutFrames)) fun (val (i8** $Put)))
   (let Io: (ioFrame (val $InFrames))
      (Io: fun (val (i8** $Get)))
      ((inFile (Io: file)) chr (val $Chr)) ) )

(de void saveCoEnv ((i8* . Crt))
   (let Crt: (coroutine Crt)
      (Crt: at (val $At))  # Not running
      (putCrtEnv (Crt:)) ) )

(de loadCoEnv ((i8* . Crt))
   (let Crt: (coroutine (set $Current Crt))
      (set $StkLimit (+ (Crt: lim) 4096))
      (getCrtEnv (Crt:))
      (tosInFile)
      (tosOutFile)
      (set $At (Crt: at))
      (Crt: at 0)  # Running
      (val $Ret) ) )

# (co ['any [. prg]]) -> any
(de _co (Exe)
   (let X (cdr Exe)
      (if (atom X)
         (if (val $Current)
            ((coroutine @) tag)
            $Nil )
         (let Tag (eval (++ X))
            (cond
               ((pair X)  # 'prg'
                  (unless (val $Coroutines)  # First call
                     (let Main: (coroutine (alloc null (+ (val JmpBufSize) (coroutine T))))
                        (Main: tag $T)  # Tag 'T'
                        (Main: prv null)
                        (Main: nxt null)
                        (Main: org null)
                        (Main: prg $Nil)
                        (let (Siz (val $StkSizeT)  Stk (stack))
                           (memset
                              (Main: lim (stack (ofs Stk (- Siz))))
                              7 (- Siz 256) T )
                           (stack Stk) )
                        (Main: at 0)
                        (set $Coroutines (set $Current (Main:))) ) )
                  (let
                     (Src: (coroutine (val $Current))
                        Crt (val $Coroutines)
                        P (i8* null) )
                     (saveCoIO)
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
                           (or P
                              (Crt: tag)  # Unused
                              (setq P Crt) )  # Remember next free slot
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
                        (let (Siz (val $StkSize)  Stk (stack))
                           (memset
                              (Dst: lim (stack (ofs P (- Siz))))
                              7 (- Siz 256) T )
                           (stack Stk) )
                        (Dst: at 0)
                        (Dst: lnk (val $Link))
                        (Dst: bnd
                           (set $Bind (push ZERO $At (val $Bind) Exe)) )  # [0 @ LINK exe]
                        (Dst: ca (val $Catch))
                        (Dst: in (val $InFrames))
                        (Dst: out (val $OutFrames))
                        (putCrtEnv (Dst:))
                        (set  # Init local env
                           $Next $Nil
                           $Make 0
                           $Yoke 0
                           $Current (Dst:)
                           $StkLimit (+ (Dst: lim) 4096) )
                        (set $Ret (run X))
                        (stop (Dst:))  # Stop coroutine
                        (longjmp ((coroutine (Dst: org)) (rst)) 1) ) ) )
               ((t? Tag)
                  (err Exe 0 ($ "Can't stop main routine") null) )
               ((val $Coroutines)
                  (let Crt @  # Stop coroutine
                     (loop
                        (let Crt: (coroutine Crt)
                           (? (== Tag (Crt: tag))  # Found coroutine
                              (let P (Crt: out)
                                 (until (== P (val $Stdout))
                                    (let (Io: (ioFrame P)  Out: (outFile (Io: file)))
                                       (when (and (ge0 (Out: fd)) (Io: pid))
                                          (close (Out: fd))
                                          (closeOutFile (Out: fd))
                                          (when (> (Io: pid) 1)
                                             (waitFile @) )
                                          (setq P (Io: link)) ) ) ) )
                              (let P (Crt: in)
                                 (until (== P (val $Stdin))
                                    (let (Io: (ioFrame P)  In: (inFile (Io: file)))
                                       (when (and (ge0 (In: fd)) (Io: pid))
                                          (close (In: fd))
                                          (closeInFile (In: fd))
                                          (when (> (Io: pid) 1)
                                             (waitFile @) )
                                          (setq P (Io: link)) ) ) ) )
                              (stop (Crt:)) )  # Stop it
                           (? (=0 (setq Crt (Crt: nxt)))) ) )
                     Tag ) )
               (T $Nil) ) ) ) ) )

# (yield 'any ['any2]) -> any
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
                  (T (err Exe 0 ($ "Tag expected") null)) ) )
            Lnk (any 0)
            Bnd (any 0)
            Ca (i8* null)
            In (val $Stdin)
            Out (val $Stdout) )
         (saveCoIO)
         (unless (t? (Src: tag))
            (let P (val $Link)  # Reverse Stack(s)
               (until (== P (Src: lnk))
                  (let Q P
                     (setq P (val 2 Q))
                     (set 2 Q Lnk)
                     (setq Lnk Q) ) ) )
            (let P (val $Bind)  # Reverse bindings
               (until (== P (Src: bnd))
                  (let Q P
                     (xchg (val 2 Q) Q)
                     (setq P (val 3 Q))
                     (set 3 Q Bnd)
                     (setq Bnd Q) ) )
               (set 3 (Src: bnd) Bnd) )
            (let P (val $Catch)  # Reverse CaFrames
               (until (== P (Src: ca))
                  (let Ca: (caFrame P)
                     (setq P (Ca: link))
                     (Ca: link Ca)
                     (setq Ca (Ca:)) ) ) )
            (let P (val $InFrames)  # Reverse InFrames
               (until (== P (Src: in))
                  (let In: (ioFrame P)
                     (setq P (In: link))
                     (In: link In)
                     (setq In (In:)) ) )
               (Src: in In) )
            (let P (val $OutFrames)  # Reverse OutFrames
               (until (== P (Src: out))
                  (let Out: (ioFrame P)
                     (setq P (Out: link))
                     (Out: link Out)
                     (setq Out (Out:)) ) )
               (Src: out Out) ) )
         (saveCoEnv (Src:))
         (unless (setjmp (Src: (rst)))
            (set $Ret Val)
            (longjmp (Dst: (rst)) 1) )
         (unless (t? (Src: tag))
            (let P (val $OutFrames)  # Restore OutFrames
               (Src: out P)
               (until (== Out (val $Stdout))
                  (let Out: (ioFrame Out)
                     (setq Out (Out: link))
                     (Out: link P)
                     (setq P (Out:)) ) )
               (Src: (env $OutFrames i8*) P) )
            (let P (val $InFrames)  # Restore InFrames
               (Src: in P)
               (until (== In (val $Stdin))
                  (let In: (ioFrame In)
                     (setq In (In: link))
                     (In: link P)
                     (setq P (In:)) ) )
               (Src: (env $InFrames i8*) P) )
            (let P (val $Catch)  # Restore CaFrames
               (Src: ca P)
               (while Ca
                  (let Ca: (caFrame Ca)
                     (setq Ca (Ca: link))
                     (Ca: link P)
                     (setq P (Ca:)) ) )
               (Src: (env $Catch i8*) P) )
            (let P (val $Bind)  # Restore bindings
               (set 3 (Src: bnd) P)
               (setq P (Src: bnd))
               (Src: bnd P)
               (while Bnd
                  (let Q Bnd
                     (xchg (val 2 Q) Q)
                     (setq Bnd (val 3 Q))
                     (set 3 Q P)
                     (setq P Q) ) )
               (Src: (env $Bind any) P) )
            (let P (val $Link)  # Restore Stack(s)
               (Src: lnk P)
               (while Lnk
                  (let Q Lnk
                     (setq Lnk (val 2 Q))
                     (set 2 Q P)
                     (setq P Q) ) )
               (Src: (env $Link any) P) ) )
         (loadCoEnv (Src:)) ) ) )

(de brkLoad (Exe)
   (when
      (and
         ((inFile (val (val $InFiles))) tty)
         ((outFile (val 2 (val $OutFiles))) tty)
         (=0 (val $Break)) )
      (let P (val $Bind)
         (setq P (push (val $At) $At P 0))  # [[@] @ LINK Expr]
         (setq P (push (val $Up) $Up P))
         (set $Up Exe)
         (set $Break (set $Bind (push (val $Run) $Run P)))
         (set $Run $Nil) )
      (let Raw (val Termio)
         (setCooked)
         (pushOutFile (b8 (ioFrame T)) (val 2 (val $OutFiles)) 0)  # Stdout
         (print Exe)
         (newline)
         (repl 0 ($ "! ") $Nil)
         (popOutFiles)
         (tosOutFile)
         (when Raw
            (setRaw) ) )
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
            $Run (val P)
            $At (val (val 3 (val 3 P))) )
         (let (In: (ioFrame (val $InFrames))  Out: (ioFrame (val $OutFrames)))
            (popInFiles)
            (tosInFile)
            (popOutFiles)
            (tosOutFile)
            (prog1
               (if (pair (cdr Exe))
                  (run @)
                  (eval (val $Up)) )
               (pushOutFile (Out:) (Out: file) (Out: pid))
               (pushInFile (In:) (In: file) (In: pid))
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
      (let
         (Tc (tcgetpgrp 0)
            Fg (and (val Tio) (== Tc (getpgrp))) )
         (cond
            ((lt0 (fork)) (forkErr Exe))
            ((=0 @)  # In child
               (setpgid 0 0)  # Set process group
               (when Fg
                  (tcsetpgrp 0 (getpid)) )
               (execvp (val Av) Av)  # Execute program
               (execErr (val Av)) ) )  # Error if failed
         # In parent
         (let (Pid @  Res (b32 1))
            (setpgid Pid 0)  # Set process group
            (when Fg
               (tcsetpgrp 0 Pid) )
            (loop
               (while (lt0 (waitWuntraced Pid Res))
                  (unless (== (gErrno) EINTR)
                     (err Exe 0 ($ "wait pid") null) )
                  (sigChk Exe) )
               (when Fg
                  (tcsetpgrp 0 Tc) )
               (? (=0 (wifStopped Res))
                  (set $At2 (cnt (i64 (val Res))))
                  (if (val Res) $Nil $T) )
               (repl 0 ($ "+ ") $Nil)
               (when Fg
                  (tcsetpgrp 0 Pid) )
               (kill Pid (val SIGCONT Sig)) ) ) ) ) )

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
