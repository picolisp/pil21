# 21jun20 Software Lab. Alexander Burger

(symbols "priv" 'pico)

(export) (be clause repeat asserta assertz retract rules)

(de be CL
   (clause CL) )

(de clause (CL)
   (with (car CL)
      (if (== *Rule This)
         (queue (:: T) (cdr CL))
         (=: T (cons (cdr CL)))
         (setq *Rule This) )
      This ) )

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
(export) (goal fail pilog solve query ?)
(local) (CL Env Prg Q Dbg R L @H @A @B @Obj @X @Lst @CL @P @C *R)

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
            (print (cdr X))
            (flush) )
         (T (line)) ) ) )

(de ? CL
   (let L
      (make
         (while (nor (pat? (car CL)) (lst? (car CL)))
            (link (++ CL)) ) )
      (query (goal CL) L) ) )

### Basic Rules ###
(export) (repeat true not call or nil)
(local) (_or _for)

(be repeat)
(repeat)

(be true)

(be not @P (1 (-> @P)) T (fail))
(be not @P)

(be call @P
   (2 (cons (-> @P))) )

(be or @L (^ @C (box (-> @L))) (_or @C))

(be _or (@C) (3 (pop (-> @C))))
(be _or (@C) (^ @ (not (val (-> @C)))) T (fail))
(repeat)

(be nil (@X) (^ @ (not (-> @X))))


(export) (equal different append member delete permute uniq)

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
      (let X (-> @X)
         (not (idx (-> @B) (cons (hash X) X) T)) ) ) )


(export) (asserta assertz retract clause show for)

(be asserta (@C) (^ @ (asserta (-> @C))))

(be assertz (@C) (^ @ (assertz (-> @C))))

(be retract (@C)
   (2 (cons (-> @C)))
   (^ @ (retract (list (car (-> @C)) (cdr (-> @C))))) )

(be clause (@H @B)
   (^ @A (get (-> @H) T))
   (member @B @A) )

(be show (@X) (^ @ (show (-> @X))))

(be for (@N @End) (for @N 1 @End 1))
(be for (@N @Beg @End) (for @N @Beg @End 1))
(be for (@N @Beg @End @Step) (equal @N @Beg))
(be for (@N @Beg @End @Step)
   (^ @I (box (-> @Beg)))
   (_for @N @I @End @Step) )

(be _for (@N @I @End @Step)
   (^ @
      (if (>= (-> @End) (val (-> @I)))
         (> (inc (-> @I) (-> @Step)) (-> @End))
         (> (-> @End) (dec (-> @I) (-> @Step))) ) )
   T
   (fail) )

(be _for (@N @I @End @Step)
   (^ @N (val (-> @I))) )

(repeat)


### DB ###
(export) initQuery

(de initQuery (Var Cls Hook Val)
   (let (Tree (tree Var Cls Hook)  Rel (get Cls Var))
      (when (find '((B) (isa '+index B)) (get Rel 'bag))
         (setq Rel @) )
      (when (or (isa '+Fold Rel) (isa '+IdxFold Rel))
         (setq Val (fold Val)) )
      (cond
         ((pair Val)
            (cond
               ((and (pair (cdr Val)) (; Rel aux))
                  (cond
                     ((atom (car Val))
                        (and (; Rel ub) (setq Val (ubZval Val)))
                        (init Tree Val (append Val T)) )
                     ((; Rel ub)
                        (init Tree
                           (ubZval (car Val))
                           (ubZval (cdr Val) T) ) )
                     ((>= (cdr Val) (car Val))
                        (init Tree (car Val) (append (cdr Val) T)) )
                     (T (init Tree (append (car Val) T) (cdr Val))) ) )
               ((isa '+Key Rel)
                  (init Tree (car Val) (cdr Val)) )
               ((>= (cdr Val) (car Val))
                  (init Tree
                     (cons (car Val))
                     (cons (cdr Val) T) ) )
               (T
                  (init Tree
                     (cons (car Val) T)
                     (cons (cdr Val)) ) ) ) )
         ((or (num? Val) (ext? Val))
            (if (isa '+Key Rel)
               (init Tree Val Val)
               (init Tree (cons Val) (cons Val T)) ) )
         ((=T Val) (init Tree))
         ((isa '+Key Rel)
            (init Tree Val (pack Val `(char T))) )
         ((isa '+Idx Rel)
            (let Q (init Tree (cons Val) (cons (pack Val `(char T)) T))
               (if (cdr Q)
                  Q
                  (setq Val (pack (car (split (chop Val) " "))))
                  (init Tree (cons Val) (cons (pack Val `(char T)) T)) ) ) )
         (T (init Tree (cons Val) (cons (pack Val `(char T)) T))) ) ) )


(export) db
(local) _db

# (db var cls obj)
(be db (@Var @Cls @Obj)
   (^ @Q
      (box
         (with (or (get (-> @Cls) (-> @Var)) (meta (-> @Cls) (-> @Var)))
            (initQuery (: var) (: cls) NIL '(NIL . T)) ) ) )
   (_db @Obj) )

# (db var cls hook|val obj)
(be db (@Var @Cls @X @Obj)
   (^ @Q
      (box
         (with (or (get (-> @Cls) (-> @Var)) (meta (-> @Cls) (-> @Var)))
            (if (: hook)
               (initQuery (: var) (: cls) (-> @X) '(NIL . T))
               (initQuery (: var) (: cls) NIL (-> @X)) ) ) ) )
   (_db @Obj) )

# (db var cls hook val obj)
(be db (@Var @Cls @Hook @Val @Obj)
   (^ @Q
      (box
         (with (or (get (-> @Cls) (-> @Var)) (meta (-> @Cls) (-> @Var)))
            (initQuery (: var) (: cls) (-> @Hook) (-> @Val)) ) ) )
   (_db @Obj) )

(be _db (@Obj)
   (^ @
      (let (Q (val (-> @Q 2))  Cls (-> @Cls 2))
         (loop
            (NIL (step Q (= '(NIL) (caaar Q))) T)
            (T (isa Cls (setq R @))) ) ) )
   T
   (fail) )

(be _db (@Obj) (^ @Obj R))

(repeat)


(export) (val lst map)
(local) (_lst _map)

(be val (@V . @L)
   (^ @V (apply get (-> @L)))
   T )

(be lst (@V . @L)
   (^ @Lst (box (apply get (-> @L))))
   (_lst @V @Lst) )

(be _lst (@Val @Lst) (^ @ (not (val (-> @Lst)))) T (fail))
(be _lst (@Val @Lst) (^ @Val (pop (-> @Lst))))
(repeat)

(be map (@V . @L)
   (^ @Lst (box (apply get (-> @L))))
   (_map @V @Lst) )

(be _map (@Val @Lst) (^ @ (not (val (-> @Lst)))) T (fail))
(be _map (@Val @Lst) (^ @Val (prog1 (val (-> @Lst)) (pop (-> @Lst)))))
(repeat)


(export) (isa same bool ub range head hold fold part tolr)
(local) (_same _range _head _hold _fold _part _tolr)

(be isa (@Typ . @L)
   (^ @
      (or
         (not (-> @Typ))
         (isa (-> @Typ) (apply get (-> @L))) ) ) )

(be same (@V . @L)
   (^ @
      (let V (-> @V)
         (or
            (not V)
            (let L (-> @L)
               (_same (car L) (cdr L)) ) ) ) ) )

(de _same (X L)
   (cond
      ((not L)
         (if (atom X)
            (= V X)
            (member V X) ) )
      ((atom X)
         (_same (get X (car L)) (cdr L)) )
      ((atom (car L))
         (pick
            '((Y) (_same (get Y (car L)) (cdr L)))
            X ) )
      (T (_same (apply get (car L) X) (cdr L))) ) )

(be bool (@F . @L)
   (^ @
      (or
         (not (-> @F))
         (bool (apply get (-> @L))) ) ) )

(be ub (@A @R . @L)
   (^ @
      (let R (-> @R)
         (or
            (not R)
            (let X (apply get (-> @L))
               (fully
                  '((K V1 V2)
                     (>= V2 (get X K) V1) )
                  (-> @A)
                  (car R)
                  (cdr R) ) ) ) ) ) )

(be range (@R . @L)
   (^ @
      (let R (-> @R)
         (or
            (not R)
            (let L (-> @L)
               (_range (car L) (cdr L)) ) ) ) ) )

(de _range (X L)
   (cond
      ((not L)
         (if (atom X)
            (or
               (<= (car R) X (cdr R))
               (>= (car R) X (cdr R)) )
            (find
               '((Y)
                  (or
                     (<= (car R) Y (cdr R))
                     (>= (car R) Y (cdr R)) ) )
               X ) ) )
      ((atom X)
         (_range (get X (car L)) (cdr L)) )
      ((atom (car L))
         (pick
            '((Y) (_range (get Y (car L)) (cdr L)))
            X ) )
      (T (_range (apply get (car L) X) (cdr L))) ) )

(be head (@S . @L)
   (^ @
      (let S (-> @S)
         (or
            (not S)
            (let L (-> @L)
               (_head (car L) (cdr L)) ) ) ) ) )

(de _head (X L)
   (cond
      ((not L)
         (if (atom X)
            (pre? S X)
            (find '((Y) (pre? S Y)) X) ) )
      ((atom X)
         (_head (get X (car L)) (cdr L)) )
      ((atom (car L))
         (pick
            '((Y) (_head (get Y (car L)) (cdr L)))
            X ) )
      (T (_head (apply get (car L) X) (cdr L))) ) )

(be hold (@S . @L)
   (^ @
      (let S (-> @S)
         (or
            (not S)
            (let L (-> @L)
               (_hold (car L) (cdr L)) ) ) ) ) )

(de _hold (X L)
   (cond
      ((not L)
         (if (atom X)
            (sub? S X)
            (find '((Y) (sub? S Y)) X) ) )
      ((atom X)
         (_hold (get X (car L)) (cdr L)) )
      ((atom (car L))
         (pick
            '((Y) (_hold (get Y (car L)) (cdr L)))
            X ) )
      (T (_hold (apply get (car L) X) (cdr L))) ) )

(be fold (@S . @L)
   (^ @
      (let S (fold (-> @S))
         (or
            (not S)
            (let L (-> @L)
               (_fold (car L) (cdr L)) ) ) ) ) )

(de _fold (X L)
   (cond
      ((not L)
         (if (atom X)
            (pre? S (fold X))
            (find '((Y) (pre? S (fold Y))) X) ) )
      ((atom X)
         (_fold (get X (car L)) (cdr L)) )
      ((atom (car L))
         (pick
            '((Y) (_fold (get Y (car L)) (cdr L)))
            X ) )
      (T (_fold (apply get (car L) X) (cdr L))) ) )

(be part (@S . @L)
   (^ @
      (let S (fold (-> @S))
         (or
            (not S)
            (let L (-> @L)
               (_part (car L) (cdr L)) ) ) ) ) )

(de _part (X L)
   (cond
      ((not L)
         (if (atom X)
            (sub? S (fold X))
            (find '((Y) (sub? S (fold Y))) X) ) )
      ((atom X)
         (_part (get X (car L)) (cdr L)) )
      ((atom (car L))
         (pick
            '((Y) (_part (get Y (car L)) (cdr L)))
            X ) )
      (T (_part (apply get (car L) X) (cdr L))) ) )

(be tolr (@S . @L)
   (^ @
      (let S (fold (-> @S))
         (or
            (not S)
            (let L (-> @L)
               (_tolr (car L) (cdr L)) ) ) ) ) )

(de _tolr (X L)
   (cond
      ((not L)
         (if (atom X)
            (or (sub? S (fold X)) (pre? (ext:Snx S) (ext:Snx X)))
            (let P (ext:Snx S)
               (find
                  '((Y)
                     (or (sub? S (fold Y)) (pre? P (ext:Snx Y))) )
                  X ) ) ) )
      ((atom X)
         (_tolr (get X (car L)) (cdr L)) )
      ((atom (car L))
         (pick
            '((Y) (_tolr (get Y (car L)) (cdr L)))
            X ) )
      (T (_tolr (apply get (car L) X) (cdr L))) ) )


(export) select
(local) (_select _initSel _gen _sel)

(de _select (Lst Flg)
   (let? X
      (nond
         ((atom (car Lst))
            (make
               (for (L (++ Lst) L)
                  (let
                     (Var (++ L)
                        Cls (++ L)
                        Hook (and (get Cls Var 'hook) (++ L))
                        Val (++ L) )
                     (and (or Val Flg) (chain (_initSel))) ) ) ) )
         ((pat? (car Lst))
            (let
               (Var (++ Lst)
                  Cls (++ Lst)
                  Hook (and (get Cls Var 'hook) (++ Lst))
                  Val (++ Lst) )
               (and (or Val Flg) (_initSel)) ) )
         (NIL
            (let (Var (++ Lst) Val (++ Lst))
               (and
                  (or Flg (apply or Val))
                  (cons Var (goal (++ Lst))) ) ) ) )
      (cons
         (cons
            (for (L NIL Lst)
               (push 'L (++ Lst) NIL)
               L )
            X ) ) ) )

(de _initSel ()
   (with (treeRel Var Cls)
      (let Tree (tree Var (: cls) Hook)
         (conc
            (and
               (isa '+IdxFold This)
               (<> Val (fold Val))
               (init Tree (cons Val) (cons (pack Val `(char T)) T)) )
            (initQuery Var (: cls) Hook Val)
            (and
               (isa '+Sn This)
               (init Tree
                  (cons (setq Val (ext:Snx Val)))
                  (cons (pack Val `(char T)) T) ) ) ) ) ) )

(de _gen (Lst Q)
   (cond
      (Lst
         (use X
            (loop
               (T
                  (cond
                     ((atom (car Lst))
                        (prog1 (car Lst) (set Lst)) )
                     ((atom (caar Lst)) (pop Lst))
                     (T
                        (prog1
                           (step (car Lst) (= '(NIL) (caar (caar Lst))))
                           (or (cdaar Lst) (set Lst)) ) ) )
                  @ )
               (NIL (setq X (_gen (cddr Lst) Q)))
               (set Lst
                  (let Y (cadr Lst)
                     (cond
                        ((atom Y) (get X Y))
                        ((=T (caddr Y))
                           (initQuery (car Y) (cadr Y) X (cadddr Y)) )  # X = Hook
                        (T
                           (initQuery
                              (car Y)
                              (cadr Y)
                              (caddr Y)
                              (if (cadddr Y)
                                 (cons
                                    (cons X (car @))
                                    (cons X (cdr @)) )
                                 X ) ) ) ) ) ) ) ) )
      ((pat? (car Q)) (get (prove (cdr Q)) @))
      (T (step Q (= '(NIL) (caaar Q)))) ) )

(be select ((@Obj . @X) . @Lst)
   (^ @ (unify (-> @X)))
   (^ @P (box (cdr (-> @Lst))))
   (^ @C
      (box  # ((obj ..) curr . lst)
         (let L (car (-> @Lst))
            (setq L
               (or
                  (mapcan _select L)
                  (_select (car L) T) ) )
            (cons NIL L L) ) ) )
   (_gen @Obj)
   (_sel) )

(be _gen (@Obj)
   (^ @
      (let C (caadr (val (-> @C 2)))
         (not (setq *R (_gen (car C) (cdr C)))) ) )
   T
   (fail) )

(be _gen (@Obj) (^ @Obj *R))

(repeat)

(be _sel ()
   (2 (val (-> @P 2)))
   (^ @
      (let C (val (-> @C 2))
         (unless (idx C *R T)
            (rot (cddr C) (offset (cadr C) (cddr C)))
            (set (cdr C) (cddr C)) ) ) )
   T )

(be _sel ()
   (^ @
      (let C (cdr (val (-> @C 2)))
         (set C (or (cdar C) (cdr C))) ) )
   (fail) )

### Remote queries ###
(export) (rqry remote revolve)

(de rqry Args
   (for (Q (goal (cdr Args)) (prove Q))
      (pr (get @ (car Args)))
      (NIL (flush)) )
   (bye) )

(be remote (@Lst . @CL)
   (^ @Sockets
      (box
         (prog1
            (cdr (-> @Lst))
            (for X @  # (out . in)
               ((car X)
                  (cons 'rqry (car (-> @Lst)) (-> @CL)) ) ) ) ) )
   (^ @ (unify (car (-> @Lst))))
   (_remote @Lst) )

(be _remote ((@Obj . @))
   (^ @ (not (val (-> @Sockets 2))))
   T
   (fail) )

(be _remote ((@Obj . @))
   (^ @Obj
      (let (Box (-> @Sockets 2)  Lst (val Box))
         (rot Lst)
         (loop
            (T ((cdr (++ Lst))) @)
            (NIL (set Box Lst)) ) ) ) )

(repeat)

(be revolve (@Lst . @CL)
   (^ @Gen
      (let L (-> @Lst)
         (prog1 (box)
            (for X (cddr L)
               (push @
                  (goal
                     (cons (cadr L) (lit X) (-> @CL)) ) ) )
            (push @ (car L)) ) ) )
   (^ @ (unify (car (-> @Lst))))
   (_revolve @Lst) )

(be _revolve ((@Val . @))
   (^ @ (not (cdar (-> @Gen 2))))
   T
   (fail) )

(be _revolve ((@Val . @))
   (^ @Val
      (let L (val (-> @Gen 2))
         (rot (cdr L))
         (loop
            (T (prove (cadr L))
               (get @ (car L)) )
            (NIL (con L (cddr L))) ) ) ) )

(repeat)

### Debug ###
`*Dbg

#{
(load "@lib/sq.l")

(docs "@doc/")
}#
