# 20apr20 Software Lab. Alexander Burger

(symbols '(llvm))

# (car 'var) -> any
(de _car (Exe)
   (car (needVar Exe (eval (cadr Exe)))) )

# (cdr 'lst) -> any
(de _cdr (Exe)
   (cdr (needLst Exe (eval (cadr Exe)))) )

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

# (== 'any ..) -> flg
(de _eq (Exe)
   (let (X (cdr Exe)  Y (save (eval (car X))))
      (while (pair (shift X))
         (unless (== Y (eval (car X)))
            (ret $Nil) ) )
      $T ) )

# (= 'any ..) -> flg
(de _equal (Exe)
   (let (X (cdr Exe)  Y (save (eval (car X))))
      (while (pair (shift X))
         (unless (equal Y (eval (car X)))
            (ret $Nil) ) )
      $T ) )

# (>= 'any ..) -> flg
(de _ge (Exe)
   (let (X (cdr Exe)  Y (eval (car X))  Safe (link (push Y NIL)))
      (while (pair (shift X))
         (let Z (eval (car X))
            (when (lt0 (compare Y Z))
               (drop Safe)
               (ret $Nil) )
            (setq Y (set Safe Z)) ) )
      (drop Safe)
      $T ) )


# (num? 'any) -> num | NIL
(de _numQ (Exe)
   (if (num? (eval (cadr Exe))) @ $Nil) )
