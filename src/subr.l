# 08mar20 Software Lab. Alexander Burger

(symbols '(llvm))

# (car 'var) -> any
(de _car (Exe)
   (car (eval (cadr Exe))) )

# (cdr 'lst) -> any
(de _cdr (Exe)
   (cdr (eval (cadr Exe))) )

# (cons 'any ['any ..]) -> lst
(de _cons (Exe)
   (let (X (cdr Exe)  Y (cons (eval (++ X)) $Nil)  R (save Y))
      (while (pair (cdr X))
         (setq Y
            (set 2 Y (cons (eval (++ X)) $Nil)) ) )
      (set 2 Y (eval (car X)))
      R ) )

# (list 'any ['any ..]) -> lst
(de _list (Exe)
   (let (X (cdr Exe)  Y (cons (eval (++ X)) $Nil)  R (save Y))
      (while (pair X)
         (setq Y
            (set 2 Y (cons (eval (++ X)) $Nil)) ) )
      R ) )

# (= 'any ..) -> flg
(de _equal (Exe)
   (let (X (cdr Exe)  A (save (eval (++ X))))
      (while (pair X)
         (unless (equal A (eval (++ X)))
            (ret $Nil) ) )
      $T ) )

# (>= 'any ..) -> flg
(de _ge (Exe)
   (let (X (cdr Exe)  A (eval (++ X))  P (link (push A NIL)))
      (while (pair X)
         (let B (eval (++ X))
            (when (lt0 (compare A B))
               (drop P)
               (ret $Nil) )
            (setq A (set P B)) ) )
      (drop P)
      $T ) )
