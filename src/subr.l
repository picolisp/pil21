# 06may20 Software Lab. Alexander Burger

(symbols '(llvm))

(inline (Exe) chkA (X)
   (car (needVar Exe X)) )

(inline (Exe) chkD (X)
   (cdr (needLst Exe X)) )

# (car 'var) -> any
(de _car (Exe)
   (chkA (eval (cadr Exe))) )

# (cdr 'lst) -> any
(de _cdr (Exe)
   (chkD (eval (cadr Exe))) )

(de _caar (Exe)
   (chkA (chkA (eval (cadr Exe)))) )

(de _cadr (Exe)
   (chkA (chkD (eval (cadr Exe)))) )

(de _cdar (Exe)
   (chkD (chkA (eval (cadr Exe)))) )

(de _cddr (Exe)
   (chkD (chkD (eval (cadr Exe)))) )

(de _caaar (Exe)
   (chkA (chkA (chkA (eval (cadr Exe))))) )

(de _caadr (Exe)
   (chkA (chkA (chkD (eval (cadr Exe))))) )

(de _cadar (Exe)
   (chkA (chkD (chkA (eval (cadr Exe))))) )

(de _caddr (Exe)
   (chkA (chkD (chkD (eval (cadr Exe))))) )

(de _cdaar (Exe)
   (chkD (chkA (chkA (eval (cadr Exe))))) )

(de _cdadr (Exe)
   (chkD (chkA (chkD (eval (cadr Exe))))) )

(de _cddar (Exe)
   (chkD (chkD (chkA (eval (cadr Exe))))) )

(de _cdddr (Exe)
   (chkD (chkD (chkD (eval (cadr Exe))))) )

(de _caaaar (Exe)
   (chkA (chkA (chkA (chkA (eval (cadr Exe)))))) )

(de _caaadr (Exe)
   (chkA (chkA (chkA (chkD (eval (cadr Exe)))))) )

(de _caadar (Exe)
   (chkA (chkA (chkD (chkA (eval (cadr Exe)))))) )

(de _caaddr (Exe)
   (chkA (chkA (chkD (chkD (eval (cadr Exe)))))) )

(de _cadaar (Exe)
   (chkA (chkD (chkA (chkA (eval (cadr Exe)))))) )

(de _cadadr (Exe)
   (chkA (chkD (chkA (chkD (eval (cadr Exe)))))) )

(de _caddar (Exe)
   (chkA (chkD (chkD (chkA (eval (cadr Exe)))))) )

(de _cadddr (Exe)
   (chkA (chkD (chkD (chkD (eval (cadr Exe)))))) )

(de _cdaaar (Exe)
   (chkD (chkA (chkA (chkA (eval (cadr Exe)))))) )

(de _cdaadr (Exe)
   (chkD (chkA (chkA (chkD (eval (cadr Exe)))))) )

(de _cdadar (Exe)
   (chkD (chkA (chkD (chkA (eval (cadr Exe)))))) )

(de _cdaddr (Exe)
   (chkD (chkA (chkD (chkD (eval (cadr Exe)))))) )

(de _cddaar (Exe)
   (chkD (chkD (chkA (chkA (eval (cadr Exe)))))) )

(de _cddadr (Exe)
   (chkD (chkD (chkA (chkD (eval (cadr Exe)))))) )

(de _cdddar (Exe)
   (chkD (chkD (chkD (chkA (eval (cadr Exe)))))) )

(de _cddddr (Exe)
   (chkD (chkD (chkD (chkD (eval (cadr Exe)))))) )

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

# (n== 'any ..) -> flg
(de _neq (Exe)
   (let (X (cdr Exe)  Y (save (eval (car X))))
      (loop
         (? (atom (shift X)) $Nil)
         (? (<> Y (eval (car X))) $T) ) ) )

# (= 'any ..) -> flg
(de _equal (Exe)
   (let (X (cdr Exe)  Y (save (eval (car X))))
      (loop
         (? (atom (shift X)) $T)
         (? (not (equal Y (eval (car X)))) $Nil) ) ) )

# (<> 'any ..) -> flg
(de _nequal (Exe)
   (let (X (cdr Exe)  Y (save (eval (car X))))
      (loop
         (? (atom (shift X)) $Nil)
         (? (not (equal Y (eval (car X)))) $T) ) ) )

# (=0 'any) -> 0 | NIL
(de _eq0 (Exe)
   (if (== (eval (cadr Exe)) ZERO) @ $Nil) )

# (=1 'any) -> 1 | NIL
(de _eq1 (Exe)
   (if (== (eval (cadr Exe)) ONE) @ $Nil) )

# (=T 'any) -> flg
(de _eqT (Exe)
   (if (== (eval (cadr Exe)) $T) @ $Nil) )

# (n0 'any) -> flg
(de _neq0 (Exe)
   (if (== (eval (cadr Exe)) ZERO) $Nil $T) )

# (nT 'any) -> flg
(de _neqT (Exe)
   (if (== (eval (cadr Exe)) $T) $Nil $T) )

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

(local) fill

(de fill (X Y)
   (cond
      ((num? X) 0)
      ((sym? X)
         (let V (val X)
            (cond
               ((== X V) 0)  # Auto-quoting
               ((nil? Y)
                  (cond
                     ((== X $At) 0)
                     ((== (firstByte X) (char "@")) V)
                     (T 0) ) )
               ((memq X Y) V)
               (T 0) ) ) )
      (T
         (stkChk 0)
         (let Z (++ X)
            (if (== Z $Up)  # Expand expression
               (let V (eval (++ X))
                  (if (atom V)
                     (if (=0 (fill X Y)) X @)
                     (save V
                        (while (pair (cdr V))
                           (setq V @) )
                        (set 2 V
                           (if (=0 (fill X Y)) X @) )
                        V ) ) )
               (let V (fill Z Y)
                  (cond
                     ((n0 V)
                        (save V
                           (cons V
                              (if (=0 (fill X Y)) X @) ) ) )
                     ((n0 (fill X Y))
                        (cons Z @) )
                     (T 0) ) ) ) ) ) ) )

# (fill 'any ['sym|lst]) -> any
(de _fill (Exe)
   (let (X (cdr Exe)  Y (save (eval (++ X))))
      (if (=0 (fill Y (save (eval (car X)))))
         Y
         @ ) ) )
