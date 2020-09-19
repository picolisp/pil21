# 24nov16 Software Lab. Alexander Burger

# (select [var ..] cls [hook|T] [var val ..])
(de select Lst
   (let
      (Vars
         (make
            (until
               (or
                  (atom Lst)
                  (and
                     (sym? (car Lst))
                     (= `(char "+") (char (car Lst))) ) )
               (link (++ Lst)) ) )
         Cls (++ Lst)
         Hook (cond
            ((ext? (car Lst)) (++ Lst))
            ((=T (car Lst)) (++ Lst) *DB) ) )
      (default Lst
         (cons
            (or
               (car Vars)
               (and
                  (find
                     '((X) (isa '(+Need +index) (car X)))
                     (getl Cls) )
                  (get (car @) 'var) )
               (cdr
                  (maxi caar
                     (getl (get (or Hook *DB) Cls)) ) ) ) ) )
      (let Q
         (goal
            (cons
               (make
                  (link
                     'select
                     '(@@)
                     (make
                        (for (L Lst L)
                           (link
                              (make
                                 (link (++ L) Cls)
                                 (and Hook (link Hook))
                                 (link (if L (++ L) '(NIL . T))) ) ) ) ) )
                  (link (list 'isa Cls '@@))
                  (while Lst
                     (let (Var (++ Lst)  Val (if Lst (++ Lst) '(NIL . T)))
                        (link
                           (list
                              (cond
                                 ((pair Val) 'range)
                                 ((or (num? Val) (ext? Val)) 'same)
                                 ((=T Val) 'bool)
                                 ((isa '+Sn (get Cls Var)) 'tolr)
                                 ((isa '(+IdxFold) (get Cls Var)) 'part)
                                 ((isa '(+Fold +Idx) (get Cls Var)) 'part)
                                 ((isa '+Fold (get Cls Var)) 'fold)
                                 ((isa '+Idx (get Cls Var)) 'hold)
                                 (T 'head) )
                              Val '@@ Var ) ) ) ) ) ) )
         (use Obj
            (loop
               (NIL (setq Obj (cdr (asoq '@@ (prove Q)))))
               (ifn Vars
                  (show Obj)
                  (for Var Vars
                     (cond
                        ((pair Var)
                           (print (apply get Var Obj)) )
                        ((meta Obj Var)
                           (print> @ (get Obj Var)) )
                        (T (print (get Obj Var))) )
                     (space) )
                  (print Obj) )
               (T (line) Obj) ) ) ) ) )

(dm (print> . +relation) (Val)
   (print Val) )

(dm (print> . +Number) (Val)
   (prin (format Val (: scl))) )

(dm (print> . +Date) (Val)
   (print (datStr Val)) )


# (update 'obj ['var])
(de update (Obj Var)
   (let *Dbg NIL
      (printsp Obj)
      (if Var
         (_update (get Obj Var) Var)
         (set!> Obj
            (any (revise (sym (val Obj)))) )
         (for X (getl Obj)
            (_update (or (atom X) (++ X)) X) ) )
      Obj ) )

(de _update (Val Var)
   (printsp Var)
   (let New
      (if (meta Obj Var)
         (revise> @ Val)
         (any (revise (sym Val))) )
      (unless (= New Val)
         (if (mis> Obj Var New)
            (quit "mismatch" @)
            (put!> Obj Var New) ) ) ) )


(dm (revise> . +relation) (Val)
   (any (revise (sym Val))) )

(dm (revise> . +Bag) (Lst)
   (mapcar
      '((V B) (space 6) (revise> B V))
      (any (revise (sym Lst)))
      (: bag) ) )

(dm (revise> . +Number) (Val)
   (format
      (revise (format Val (: scl)))
      (: scl) ) )

(dm (revise> . +Date) (Val)
   (expDat
      (revise
         (datStr Val)
         '((S) (list (datStr (expDat S)))) ) ) )

(dm (revise> . +List) (Val)
   (mapcar
      '((X) (space 3) (extra X))
      (any (revise (sym Val))) ) )
