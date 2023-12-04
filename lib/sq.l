# 04dec23 Software Lab. Alexander Burger

# (select [var ..] cls [hook] [var val ..])
(de select Lst
   (let
      (Vars
         (make
            (until (pre? "+" (car Lst))
               (unless Lst
                  (quit "Missing class") )
               (link (++ Lst)) ) )
         Cls (++ Lst)
         Hook (and (ext? (car Lst)) (++ Lst)) )
      (default Lst
         (list
            (or
               (and (sym? (car Vars)) (car Vars))
               (recur (Cls)
                  (or
                     (and
                        (find
                           '((X)
                              (isa '(+Need +index) (car (pair X))) )
                           (getl Cls) )
                        (; @ 1 var) )
                     (cdr
                        (maxi caar
                           (getl (get (or Hook *DB) Cls)) ) )
                     (pick recurse (type Cls)) ) ) ) ) )
      (for
         (Q
            (apply search
               (make
                  (loop
                     (prog1 (++ Lst)
                        (link
                           (++ Lst)
                           (list
                              (make (link @ Cls) (and Hook (link Hook))) ) ) )
                     (NIL Lst) ) ) )
            (search Q) )
         (T
            (when (setq This (isa Cls @))
               (ifn Vars
                  (show This)
                  (for X Vars
                     (cond
                        ((pair X)
                           (printsp (eval X)) )
                        ((meta This X)
                           (print> @ (get This X))
                           (space) )
                        (T (printsp (get This X))) ) )
                  (println This) )
               (= "\e" (key)) )
            This ) ) ) )

(dm (print> . +relation) (Val)
   (print Val) )

(dm (print> . +Number) (Val)
   (if (num? Val)
      (prin (format Val (: scl)))
      (print Val) ) )

(dm (print> . +Date) (Val)
   (print (if (num? Val) (datStr Val) Val)) )
