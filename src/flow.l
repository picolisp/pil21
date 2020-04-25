# 25apr20 Software Lab. Alexander Burger

(symbols '(llvm))

(local) redefine

(de redefine (Exe S X)
   (set S X)
   )

# (quote . any) -> any
(de _quote (Exe)
   (cdr Exe) )

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
                  (== Z $T)
                  (if (atom Z) (equal Z A) (member A Z)) )
               (run (cdr Y)) ) ) ) ) )

# (casq 'any (any1 . prg1) (any2 . prg2) ..) -> any
(de _casq (Exe)
   (let (X (cdr Exe)  A (set $At (eval (car X))))
      (loop
         (? (atom (shift X)) $Nil)
         (let (Y (car X)  Z (car Y))
            (? (or (== Z $T) (== Z A) (memq A Z))
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
                  (== Z $T)
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
