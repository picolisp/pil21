# 03apr20 Software Lab. Alexander Burger

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
         P (push (val $At) NIL $At (val $Bind) Lst)  # [[@] LINK @ Bind Exe]
         Q (link P) )  # [[@] LINK @ Bind Exe]
      (link (setq P (push Obj NIL $This)))
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
               (let (C (val $Cls)  K (val $Key))
                  (prog1
                     (run (cdr Exe))  # Run body
                     (set
                        $Key K
                        $Cls C
                        $Next (val Next)
                        $Link (val $Bind) ) ) ) )
            (unless (== Y $Nil)
               (link (push (val Y) NIL Y))  # Last parameter
               (set Y X) )  # Set to unevaluated argument(s)
            (set $Bind (val $Link))
            (loop
               (let (S (val 3 P)  V (val S))  # Symbol, old value
                  (set S (val P))  # Set new value
                  (set P V)  # Save old value
                  (? (== Q P))
                  (shift P) ) )
            (let (C (val $Cls)  K (val $Key))
               (set $Cls Cls)
               (set $Key Key)
               (run (cdr Exe))  # Run body
               (set $Key K  $Cls C) ) )
         (setq P (val $Link))
         (loop
            (set (val 3 P) (val P))  # Restore values
            (? (== Q P))
            (shift P) )
         (drop P)
         (set $Bind (val 4 Q)) ) ) )

# (meth 'obj ['any ..]) -> any
(de _meth (Exe)
   Exe )

# (and 'any ..) -> any
(de _and (Exe)
   (let X (cdr Exe)
      (loop
         (let A (eval (++ X))
            (? (nil? A) A)
            (set $At A)
            (? (atom X) A) ) ) ) )

# (if 'any1 any2 . prg) -> any
(de _if (Exe)
   (let X (cdr Exe)
      (let A (eval (++ X))
         (if (nil? A)
            (run (cdr X))
            (set $At A)
            (eval (car X)) ) ) ) )

# (with 'var . prg) -> any
(de _with (Exe)
   (let (X (cdr Exe)  Y (needVar Exe (eval (++ X))))
      (if (nil? Y)
         Y
         (let P (link (push (val $This) NIL $This (val $Bind)))  # [[This] LINK This Bind]
            (set $Bind P)
            (set $This Y)
            (prog1
               (run X)
               (set $This (val P)  $Bind (val 4 P))
               (drop P) ) ) ) ) )

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
   (let N (eval (cadr Exe))
      (bye
         (if (nil? N)
            0
            (i32 (int N)) ) ) ) )
