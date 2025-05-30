# 30may25 Software Lab. Alexander Burger

(private) (CL Q R L Prg)

(de be CL
   (clause CL) )

(de clause (CL)
   (with (++ CL)
      (if (== *Rule This)
         (queue (:: T) CL)
         (=: T (list CL))
         (setq *Rule This) )
      (def This T (: T)) ) )

(de repeat ()
   (conc (get *Rule T) (get *Rule T)) )

(de asserta (CL)
   (push (prop CL 1 T) (cdr CL)) )

(de assertz (CL)
   (queue (prop CL 1 T) (cdr CL)) )

(de retract (X)
   (if (sym? X)
      (put X T)
      (put (car X) T
         (delete (cdr X) (get (car X) T)) ) ) )

(de rules @
   (while (args)
      (let S (next)
         (for ((N . L) (get S T) L)
            (prin N " (be ")
            (print S)
            (for X (++ L)
               (space)
               (print X) )
            (prinl ")")
            (T (== L (get S T))
               (println '(repeat)) ) )
         S ) ) )

### Pilog Interpreter ###
(private) (Env Dbg *R)

(de goal (CL . @)
   (let Env '(T)
      (while (args)
         (push 'Env
            (cons (cons 0 (next)) 1 (next)) ) )
      (while (and CL (pat? (car CL)))
         (push 'Env
            (cons
               (cons 0 (++ CL))
               (cons 1 (eval (++ CL))) ) ) )
      (cons
         (cons
            (conc (list 1 (0) NIL CL NIL) Env) ) ) ) )

(de fail ()
   (goal '((NIL))) )

(de pilog (CL . Prg)
   (for (Q (goal CL) (prove Q))
      (bind @ (run Prg)) ) )

(de solve (CL . Prg)
   (make
      (if Prg
         (for (Q (goal CL) (prove Q))
            (link (bind @ (run Prg))) )
         (for (Q (goal CL) (prove Q))
            (link @) ) ) ) )

(de query (Q Dbg)
   (use R
      (loop
         (NIL (prove Q Dbg))
         (T (=T (setq R @)) T)
         (for X R
            (space)
            (print (car X))
            (print '=)
            (print (cdr X)) )
         (prinl)
         (T (= "\e" (key)) T) ) ) )

(de ? CL
   (let L
      (make
         (while (nor (pat? (car CL)) (lst? (car CL)))
            (link (++ CL)) ) )
      (query (goal CL) L) ) )

### Basic Rules ###
(private) (_or _for)

(be repeat)
(repeat)

(be true)

(be not @P (1 @P) T (fail))
(be not @P)

(be call @P (2 (cons @P)))

(be or @L (^ @C (box @L)) (_or @C))

(be _or (@C) (3 (pop @C)))
(be _or (@C) (^ @ (not (val @C))) T (fail))
(repeat)

(be nil (@X) (^ @ (not @X)))


(be equal (@X @X))

(be different (@X @X) T (fail))
(be different (@ @))

(be append (NIL @X @X))
(be append ((@A . @X) @Y (@A . @Z)) (append @X @Y @Z))

(be member (@X (@X . @)))
(be member (@X (@ . @Y)) (member @X @Y))

(be delete (@A (@A . @Z) @Z))
(be delete (@A (@X . @Y) (@X . @Z))
   (delete @A @Y @Z) )

(be permute ((@X) (@X)))
(be permute (@L (@X . @Y))
   (delete @X @L @D)
   (permute @D @Y) )

(be uniq (@B @X)
   (^ @
      (not (idx @B (cons (hash @X) @X) T)) ) )


(be asserta (@C) (^ @ (asserta @C)))
(be assertz (@C) (^ @ (assertz @C)))

(be retract (@C)
   (2 (cons @C))
   (^ @ (retract (list (car @C) (cdr @C)))) )

(be clause (@H @B)
   (^ @A (get @H T))
   (member @B @A) )

(be show (@X) (^ @ (show @X)))

(be for (@N @End) (for @N 1 @End 1))
(be for (@N @Beg @End) (for @N @Beg @End 1))
(be for (@N @Beg @End @Step) (equal @N @Beg))
(be for (@N @Beg @End @Step)
   (^ @I (box @Beg))
   (_for @N @I @End @Step) )

(be _for (@N @I @End @Step)
   (^ @
      (if (>= @End (val @I))
         (> (inc @I @Step) @End)
         (> @End (dec @I @Step)) ) )
   T
   (fail) )

(be _for (@N @I @End @Step)
   (^ @N (val @I)) )

(repeat)


(private) (_lst _map)

(be val (@V . @L)
   (^ @V (apply get @L))
   T )

(be lst (@V . @L)
   (^ @Lst (box (apply get @L)))
   (_lst @V @Lst) )

(be _lst (@Val @Lst) (^ @ (not (val @Lst))) T (fail))
(be _lst (@Val @Lst) (^ @Val (pop @Lst)))
(repeat)

(be map (@V . @L)
   (^ @Lst (box (apply get @L)))
   (_map @V @Lst) )

(be _map (@Val @Lst) (^ @ (not (val @Lst))) T (fail))
(be _map (@Val @Lst) (^ @Val (prog1 (val @Lst) (pop @Lst))))
(repeat)
