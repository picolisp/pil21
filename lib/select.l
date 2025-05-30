# 30may25 Software Lab. Alexander Burger

# Deprecated Pilog DB Predicates
# Use 'search' instead

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


(private) _db

# (db var cls obj)
(be db (@Var @Cls @Obj)
   (^ @C (box))  # (obj ..)
   (^ @Q
      (box
         (with (or (get @Cls @Var) (meta @Cls @Var))
            (initQuery (: var) (: cls) NIL '(NIL . T)) ) ) )
   (_db @Obj) )

# (db var cls hook|val obj)
(be db (@Var @Cls @X @Obj)
   (^ @C (box))  # (obj ..)
   (^ @Q
      (box
         (with (or (get @Cls @Var) (meta @Cls @Var))
            (if (: hook)
               (initQuery (: var) (: cls) @X '(NIL . T))
               (initQuery (: var) (: cls) NIL @X) ) ) ) )
   (_db @Obj) )

# (db var cls hook val obj)
(be db (@Var @Cls @Hook @Val @Obj)
   (^ @C (box))  # (obj ..)
   (^ @Q
      (box
         (with (or (get @Cls @Var) (meta @Cls @Var))
            (initQuery (: var) (: cls) @Hook @Val) ) ) )
   (_db @Obj) )

(be _db (@Obj)
   (^ @
      (let (Q (val (-> @Q 2))  Cls (-> @Cls 2))
         (loop
            (NIL (step Q (= '(NIL) (caaar Q))) T)
            (T
               (and
                  (isa Cls (setq *R @))
                  (not (idx (-> @C 2) *R T)) ) ) ) ) )
   T
   (fail) )

(be _db (@Obj) (^ @Obj *R))

(repeat)

(private) (_same _range _head _hold _fold _part _tolr)

(be isa (@Typ . @L)
   (^ @
      (or
         (not @Typ)
         (isa @Typ (apply get @L)) ) ) )

(be same (@V . @L)
   (^ @
      (or (not @V) (_same (car @L) (cdr @L))) ) )

(de _same (X L)
   (cond
      ((not L)
         (if (atom X)
            (= @V X)
            (member @V X) ) )
      ((atom X)
         (_same (get X (car L)) (cdr L)) )
      ((atom (car L))
         (pick
            '((Y) (_same (get Y (car L)) (cdr L)))
            X ) )
      (T (_same (apply get (car L) X) (cdr L))) ) )

(be bool (@F . @L)
   (^ @
      (or (not @F) (bool (apply get @L))) ) )

(be ub (@A @R . @L)
   (^ @
      (or
         (not @R)
         (let X (apply get @L)
            (fully
               '((K V1 V2)
                  (>= V2 (get X K) V1) )
               @A
               (car @R)
               (cdr @R) ) ) ) ) )

(be range (@R . @L)
   (^ @
      (or (not @R) (_range (car @L) (cdr @L))) ) )

(de _range (X L)
   (cond
      ((not L)
         (if (atom X)
            (or
               (<= (car @R) X (cdr @R))
               (>= (car @R) X (cdr @R)) )
            (find
               '((Y)
                  (or
                     (<= (car @R) Y (cdr @R))
                     (>= (car @R) Y (cdr @R)) ) )
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
      (or (not @S) (_head (car @L) (cdr @L))) ) )

(de _head (X L)
   (cond
      ((not L)
         (if (atom X)
            (pre? @S X)
            (find '((Y) (pre? @S Y)) X) ) )
      ((atom X)
         (_head (get X (car L)) (cdr L)) )
      ((atom (car L))
         (pick
            '((Y) (_head (get Y (car L)) (cdr L)))
            X ) )
      (T (_head (apply get (car L) X) (cdr L))) ) )

(be hold (@S . @L)
   (^ @
      (or (not @S) (_hold (car @L) (cdr @L))) ) )

(de _hold (X L)
   (cond
      ((not L)
         (if (atom X)
            (sub? @S X)
            (find '((Y) (sub? @S Y)) X) ) )
      ((atom X)
         (_hold (get X (car L)) (cdr L)) )
      ((atom (car L))
         (pick
            '((Y) (_hold (get Y (car L)) (cdr L)))
            X ) )
      (T (_hold (apply get (car L) X) (cdr L))) ) )

(be fold (@S . @L)
   (^ @
      (or
         (not (setq @S (fold @S)))
         (_fold (car @L) (cdr @L)) ) ) )

(de _fold (X L)
   (cond
      ((not L)
         (if (atom X)
            (pre? @S (fold X))
            (find '((Y) (pre? @S (fold Y))) X) ) )
      ((atom X)
         (_fold (get X (car L)) (cdr L)) )
      ((atom (car L))
         (pick
            '((Y) (_fold (get Y (car L)) (cdr L)))
            X ) )
      (T (_fold (apply get (car L) X) (cdr L))) ) )

(be part (@S . @L)
   (^ @
      (or
         (not (setq @S (fold @S)))
         (_part (car @L) (cdr @L)) ) ) )

(de _part (X L)
   (cond
      ((not L)
         (if (atom X)
            (sub? @S (fold X))
            (find '((Y) (sub? @S (fold Y))) X) ) )
      ((atom X)
         (_part (get X (car L)) (cdr L)) )
      ((atom (car L))
         (pick
            '((Y) (_part (get Y (car L)) (cdr L)))
            X ) )
      (T (_part (apply get (car L) X) (cdr L))) ) )

(be tolr (@S . @L)
   (^ @
      (or
         (not (setq @S (fold @S)))
         (_tolr (car @L) (cdr @L)) ) ) )

(de _tolr (X L)
   (cond
      ((not L)
         (if (atom X)
            (or (sub? @S (fold X)) (pre? (ext:Snx @S) (ext:Snx X)))
            (let P (ext:Snx @S)
               (find
                  '((Y)
                     (or (sub? @S (fold Y)) (pre? P (ext:Snx Y))) )
                  X ) ) ) )
      ((atom X)
         (_tolr (get X (car L)) (cdr L)) )
      ((atom (car L))
         (pick
            '((Y) (_tolr (get Y (car L)) (cdr L)))
            X ) )
      (T (_tolr (apply get (car L) X) (cdr L))) ) )


(private) (_select _initSel _gen _sel)

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

(private) (@Obj @X @Lst @P @C)

(be select ((@Obj . @X) . @Lst)
   (^ @ (unify @X))
   (^ @P (box (cdr @Lst)))
   (^ @C
      (box  # ((obj ..) curr . lst)
         (let L
            (or
               (mapcan _select (car @Lst))
               (_select (caar @Lst) T) )
            (cons NIL L L) ) ) )
   (_gen @Obj)
   (^ @ (unify 2))
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
(de rqry Args
   (for (Q (goal (cdr Args)) (prove Q))
      (pr (get @ (car Args)))
      (NIL (flush)) )
   (bye) )

(be remote (@Lst . @CL)
   (^ @Sockets
      (box
         (prog1
            (cdr @Lst)
            (for X @  # (out . in)
               ((car X)
                  (cons 'rqry (car @Lst) @CL) ) ) ) ) )
   (^ @ (unify (car @Lst)))
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
      (prog1 (box)
         (for X (cddr @Lst)
            (push @
               (goal
                  (cons (cadr @Lst) (lit X) @CL) ) ) )
         (push @ (car @Lst)) ) )
   (^ @ (unify (car @Lst)))
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

### GUI ###
(de queryHint (Var CL Str)
   (make
      (for (Q (goal CL) (prove Q))
         (for V
            (fish
               '((S) (and (atom S) (sub? (fold Str) (fold S))))
               (get @ '@@ Var) )
            (unless (member V (made))
               (link V) ) )
         (T (nth (made) 24)) ) ) )
