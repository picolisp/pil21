# 14nov20 Software Lab. Alexander Burger

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
               (T (line) Obj)
               (prinl) ) ) ) ) )

(dm (print> . +relation) (Val)
   (print Val) )

(dm (print> . +Number) (Val)
   (prin (format Val (: scl))) )

(dm (print> . +Date) (Val)
   (print (datStr Val)) )
