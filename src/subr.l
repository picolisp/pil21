# 28mar20 Software Lab. Alexander Burger

(symbols '(llvm))

# (car 'var) -> any
(de _car (Exe)
   (car (eval (cadr Exe))) )

# (cdr 'lst) -> any
(de _cdr (Exe)
   (cdr (eval (cadr Exe))) )

# (cons 'any ['any ..]) -> lst
(de _cons (Exe)
   (let (X (cdr Exe)  Y (cons (eval (car X)) $Nil)  R (save Y))
      (while (pair (cdr (shift X)))
         (setq Y
            (set 2 Y (cons (eval (car X)) $Nil)) ) )
      (set 2 Y (eval (car X)))
      R ) )

# (list 'any ['any ..]) -> lst
(de _list (Exe)
   (let (X (cdr Exe)  Y (cons (eval (car X)) $Nil)  R (save Y))
      (while (pair (shift X))
         (setq Y
            (set 2 Y (cons (eval (car X)) $Nil)) ) )
      R ) )

# (= 'any ..) -> flg
(de _equal (Exe)
   (let (X (cdr Exe)  A (save (eval (car X))))
      (while (pair (shift X))
         (unless (equal A (eval (car X)))
            (ret $Nil) ) )
      $T ) )

# (>= 'any ..) -> flg
(de _ge (Exe)
   (let (X (cdr Exe)  A (eval (car X))  Safe (link (push A NIL)))
      (while (pair (shift X))
         (let B (eval (car X))
            (when (lt0 (compare A B))
               (drop Safe)
               (ret $Nil) )
            (setq A (set Safe B)) ) )
      (drop Safe)
      $T ) )
