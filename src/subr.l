# 09may20 Software Lab. Alexander Burger

(symbols '(llvm))

(local) (chkA chkD makeErr)

(inline (Exe) chkA (X)
   (car (needVar Exe X)) )

(inline (Exe) chkD (X)
   (cdr (needLst Exe X)) )

(de NIL makeErr (Exe)
   (err Exe 0 ($ "Not making") null) )

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

# (make .. [(made 'lst ..)] .. [(link 'any ..)] ..) -> any
(de _make (Exe)
   (let
      (Make (val $Make)
         Yoke (val $Yoke)
         R (link (push $Nil NIL)) )
      (set $Make (set $Yoke R))
      (exec (cdr Exe))
      (set $Make Make  $Yoke Yoke)
      (pop R) ) )

# (made ['lst1 ['lst2]]) -> lst
(de _made (Exe)
   (let X (cdr Exe)
      (when (=0 (val $Make))
         (makeErr Exe) )
      (when (pair X)
         (set (val $Yoke) (eval (++ X)))
         (let Y (eval (car X))
            (when (atom Y)
               (setq Y (val (val $Yoke)))
               (while (pair (cdr Y))
                  (setq Y @) ) )
            (set $Make (ofs Y 1)) ) )
      (val (val $Yoke)) ) )

# (chain 'lst ..) -> lst
(de _chain (Exe)
   (let X (cdr Exe)
      (when (=0 (val $Make))
         (makeErr Exe) )
      (loop
         (let Y (eval (++ X))
            (when (pair Y)
               (set (val $Make) Y)
               (let Z Y
                  (while (pair (cdr Z))
                     (setq Z @) )
                  (set $Make (ofs Z 1)) ) ) )
         (? (atom X) Y) ) ) )

# (link 'any ..) -> any
(de _link (Exe)
   (let X (cdr Exe)
      (when (=0 (val $Make))
         (makeErr Exe) )
      (loop
         (let Y (eval (++ X))
            (set $Make
               (ofs
                  (set (val $Make) (cons Y $Nil))
                  1 ) )
            (? (atom X) Y) ) ) ) )

# (yoke 'any ..) -> any
(de _yoke (Exe)
   (let X (cdr Exe)
      (when (=0 (val $Make))
         (makeErr Exe) )
      (loop
         (let Y (eval (++ X))
            (let P (val $Yoke)
               (set P (cons Y (val P))) )
            (? (atom X)
               (let Z (val $Make)
                  (while (pair (val Z))
                     (setq Z (ofs @ 1)) )
                  (set $Make Z) )
               Y ) ) ) ) )

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

# (atom 'any) -> flg
(de _atom (Exe)
   (if (atom (eval (cadr Exe))) $T $Nil) )

# (pair 'any) -> any
(de _pair (Exe)
   (if (pair (eval (cadr Exe))) @ $Nil) )

# (circ? 'any) -> any
(de _circQ (Exe)
   (if (=0 (circ (eval (cadr Exe)))) $Nil @) )

# (lst? 'any) -> flg
(de _lstQ (Exe)
   (if (or (pair (eval (cadr Exe))) (nil? @))
      $T
      $Nil ) )

# (num? 'any) -> num | NIL
(de _numQ (Exe)
   (if (num? (eval (cadr Exe))) @ $Nil) )

# (sym? 'any) -> flg
(de _symQ (Exe)
   (if (or (num? (eval (cadr Exe))) (pair @))
      $Nil
      $T ) )

# (flg? 'any) -> flg
(de _flgQ (Exe)
   (if (or (t? (eval (cadr Exe))) (nil? @))
      $T
      $Nil ) )

# (member 'any 'lst) -> any
(de _member (Exe)
   (let
      (X (cdr Exe)
         Y (save (eval (++ X)))
         Z (eval (car X)) )
      (loop
         (? (atom Z) $Nil)
         (? (equal Y (car Z)) Z)
         (shift Z) ) ) )

# (memq 'any 'lst) -> any
(de _memq (Exe)
   (let
      (X (cdr Exe)
         Y (save (eval (++ X)))
         Z (eval (car X)) )
      (loop
         (? (atom Z) $Nil)
         (? (== Y (car Z)) Z)
         (shift Z) ) ) )

# (mmeq 'lst 'lst) -> any
(de _mmeq (Exe)
   (let
      (X (cdr Exe)
         Y (save (eval (++ X)))
         Z (eval (car X)) )
      (while (pair Y)
         (let (U (++ Y)  V Z)
            (while (pair V)
               (when (== U (car V))
                  (ret V) )
               (when (== Z (shift V))  # Hit head
                  (ret $Nil) ) )
            (? (== U V) V) ) )
      $Nil ) )

# (sect 'lst 'lst) -> lst
(de _sect (Exe)
   (let
      (X (cdr Exe)
         Y (save (eval (++ X)))
         Z (eval (car X))
         P 0
         R (link (push $Nil NIL)) )
      (while (pair Y)
         (let U (++ Y)
            (when (member U Z)
               (let V (cons U $Nil)
                  (setq P
                     (if (=0 P)
                        (set R V)
                        (set 2 P V) ) ) ) ) ) )
      (val R) ) )

# (diff 'lst 'lst) -> lst
(de _diff (Exe)
   (let
      (X (cdr Exe)
         Y (save (eval (++ X)))
         Z (eval (car X))
         P 0
         R (link (push $Nil NIL)) )
      (while (pair Y)
         (let U (++ Y)
            (unless (member U Z)
               (let V (cons U $Nil)
                  (setq P
                     (if (=0 P)
                        (set R V)
                        (set 2 P V) ) ) ) ) ) )
      (val R) ) )

# (index 'any 'lst) -> cnt | NIL
(de _index (Exe)
   (let
      (X (cdr Exe)
         Y (save (eval (++ X)))
         Z (eval (car X))
         Cnt 1
         U Z )
      (loop
         (? (atom Z) $Nil)
         (? (equal Y (car Z)) (cnt Cnt))
         (inc 'Cnt)
         (? (== U (shift Z)) $Nil) ) ) )

# (offset 'lst1 'lst2) -> cnt | NIL
(de _offset (Exe)
   (let
      (X (cdr Exe)
         Y (save (eval (++ X)))
         Z (eval (car X))
         Cnt 1 )
      (loop
         (? (atom Z) $Nil)
         (? (equal Y Z) (cnt Cnt))
         (inc 'Cnt)
         (shift Z) ) ) )

# (prior 'lst1 'lst2) -> lst | NIL
(de _prior (Exe)
   (let
      (X (cdr Exe)
         Y (save (eval (++ X)))
         Z (eval (car X)) )
      (when (and (pair Y) (<> Y Z))
         (while (pair Z)
            (when (== (cdr Z) Y)
               (ret Z) )
            (setq Z @) ) )
      $Nil ) )

# (length 'any) -> cnt | T
(de _length (Exe)
   (let X (eval (cadr Exe))
      (cond
         ((num? X) (fmtNum X -2 0 0 null))
         ((pair X)
            (let (C ONE  Y X)
               (loop
                  (set X (| (car X) 1))
                  (? (atom (shift X))  # Normal list
                     (loop
                        (set Y (& (car Y) -2))
                        (? (== X (shift Y))) )
                     C )
                  (? (n0 (& (car X) 1))
                     (until (== X Y)
                        (set Y (& (car Y) -2))
                        (shift Y) )
                     (loop
                        (set Y (& (car Y) -2))
                        (? (== X (shift Y))) )
                     $T )  # Infinite
                  (setq C (+ C (hex "10"))) ) ) )
         ((nil? X) ZERO)
         ((sym? (val (tail X))) ZERO)
         (T
            (let (C ZERO  P (push 0 (name @)))
               (until (=0 (symChar P))
                  (setq C (+ C (hex "10"))) )
               C ) ) ) ) )

(local) (size binSize)

(de size (L)
   (let (C 1  X L  Y (car X))
      (loop
         (when (pair Y)
            (stkChk 0)
            (setq C (+ C (size Y))) )
         (set X (| Y 1))
         (? (atom (shift X))
            (loop
               (set L (& (car L) -2))
               (? (== X (shift L))) )
            C )
         (? (n0 (& (setq Y (car X)) 1))
            (until (== X L)
               (set L (& (car L) -2))
               (shift L) )
            (loop
               (set L (& (car L) -2))
               (? (== X (shift L))) )
            C )
         (inc 'C) ) ) )

(de binSize (X)
   (cond
      ((cnt? X)
         (setq X (shr X 3))  # Normalize short, keep sign bit
         (: 1
            (let C 2  # Count significant bytes plus 1
               (until (=0 (setq X (shr X 8)))
                  (inc 'C) )
               C ) ) )
      ((big? X)
         (setq X (pos X))
         (let C 9  # Count 8 significant bytes plus 1
            (loop
               (setq D (val (dig X)))
               (? (cnt? (setq X (val (big X)))))
               (setq C (+ C 8)) )  # Increment count by 8
            (setq X (int X))
            (add D D)  # Get most significant bit of last digit
            (setq X (+ X X @@))
            (: 2
               (unless (=0 X)
                  (loop
                     (inc 'C)
                     (? (=0 (setq X (shr X 8)))) ) )
               (if (>= C (+ 63 1))  # More than one chunk
                  (+ C (/ (- C 64) 255) 1)
                  C ) ) ) )
      ((sym? X)
         (cond
            ((nil? X) 1)
            ((== (name (& (val (tail X)) -9)) ZERO) 1)
            ((cnt? @)
               (setq X (shr (shl Nm 2) 6))  # Strip status bits
               (goto 1) )
            (T
               (let C 9  # Count 8 significant bytes plus 1
                  (until (cnt? (setq X (val (big X))))
                     (setq C (+ C 8)) )  # Increment count by 8
                  (setq X (int X))
                  (goto 2) ) ) ) )
      (T
         (let (C 2  Y X)
            (loop
               (setq C (+ C (binSize (++ X))))
               (? (nil? X) C)
               (? (== Y X) (inc C))  # Circular
               (? (atom X) (+ C (binSize X))) ) ) ) ) )

# (size 'any) -> cnt
(de _size (Exe)
   (let X (eval (cadr Exe))
      (cond
         ((cnt? X)
            (setq X (shr X 3))  # Normalize short, keep sign bit
            (let C ONE
               (until (=0 (setq X (shr X 8)))
                  (setq C (+ C (hex "10"))) )
               C ) )
         ((big? X)
            (setq X (pos X))
            (let (C (hex "82")  D NIL)  # Count '8' significant bytes
               (loop
                  (setq D (val (dig X)))
                  (? (cnt? (setq X (val (big X)))))
                  (setq C (+ C (hex "80"))) )  # Increment count by '8'
               (setq X (int X))
               (add D D)  # Get most significant bit of last digit
               (unless (=0 (setq X (+ X X @@)))
                  (loop
                     (setq C (+ C (hex "10")))
                     (? (=0 (setq X (shr X 8)))) ) )
               C ) )
         ((pair X) (cnt (size X)))
         ((nil? X) ZERO)
         ((sym? (val (tail X)))
            (let Y (& @ -9)  # Properties
               (dbFetch Exe X)
               (let C (+ (binSize (val X)) (inc BLK))
                  (while (pair Y)
                     (let Z (++ Y)
                        (setq C
                           (+ C
                              (if (atom Z)
                                 (+ (binSize Z) 2)
                                 (+
                                    (binSize (car Z))
                                    (binSize (cdr Z)) ) ) ) ) ) )
                  (cnt C) ) ) )
         ((== (name @) ZERO) @)
         ((cnt? @)
            (let (C ONE  Z (int @))
               (until (=0 (setq Z (shr Z 8)))
                  (setq C (+ C (hex "10"))) )
               C ) )
         (T
            (let (C (hex "82")  Z @)  # Count '8' significant bytes
               (until (cnt? (setq Z (val (big Z))))
                  (setq C (+ C (hex "80"))) )  # Increment count by '8'
               (unless (=0 (setq Z (int Z)))
                  (loop
                     (setq C (+ C (hex "10")))
                     (? (=0 (setq Z (shr Z 8)))) ) )
               C ) ) ) ) )

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
