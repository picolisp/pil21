# 24apr20 Software Lab. Alexander Burger

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
      (loop
         (? (atom (shift X)) $T)
         (? (<> Y (eval (car X))) $Nil) ) ) )

# (= 'any ..) -> flg
(de _equal (Exe)
   (let (X (cdr Exe)  Y (save (eval (car X))))
      (loop
         (? (atom (shift X)) $T)
         (? (not (equal Y (eval (car X)))) $Nil) ) ) )

# (> 'any ..) -> flg
(de _gt (Exe)
   (let (X (cdr Exe)  Y (save (eval (car X))))
      (loop
         (? (atom (shift X)) $T)
         (let Z (eval (car X))
            (? (le0 (compare Y Z)) $Nil)
            (setq Y (safe Z)) ) ) ) )

# (>= 'any ..) -> flg
(de _ge (Exe)
   (let (X (cdr Exe)  Y (save (eval (car X))))
      (loop
         (? (atom (shift X)) $T)
         (let Z (eval (car X))
            (? (lt0 (compare Y Z)) $Nil)
            (setq Y (safe Z)) ) ) ) )

# (num? 'any) -> num | NIL
(de _numQ (Exe)
   (if (num? (eval (cadr Exe))) @ $Nil) )
