# 24may20 Software Lab. Alexander Burger

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

# (nth 'lst 'cnt ..) -> lst
(de _nth (Exe)
   (let (X (cdr Exe)  Y (save (eval (++ X))))
      (loop
         (? (atom Y) Y)
         (let C (evCnt Exe X)
            (? (lt0 (dec 'C)) $Nil)
            (while (ge0 (dec 'C))
               (shift Y) ) )
         (? (atom (shift X)) Y)
         (setq Y (car Y)) ) ) )

# (con 'lst 'any) -> any
(de _con (Exe)
   (let X (cdr Exe)
      (set 2
         (save (needPair Exe (eval (++ X))))
         (eval (car X)) ) ) )

# (cons 'any ['any ..]) -> lst
(de _cons (Exe)
   (let
      (X (cdr Exe)
         Y (cons (eval (car X)) $Nil)
         R (save Y) )
      (while (pair (cdr (shift X)))
         (setq Y
            (set 2 Y (cons (eval (car X)) $Nil)) ) )
      (set 2 Y (eval (car X)))
      R ) )

# (conc 'lst ..) -> lst
(de _conc (Exe)
   (let
      (X (cdr Exe)
         Y (eval (car X))
         R (save Y) )
      (while (pair (shift X))
         (let Z (eval (car X))
            (if (atom Y)
               (setq Y (setq R (safe Z)))
               (while (pair (cdr Y))
                  (setq Y @) )
               (set 2 Y Z) ) ) )
      R ) )

# (circ 'any ..) -> lst
(de _circ (Exe)
   (let
      (X (cdr Exe)
         Y (cons (eval (car X)) $Nil)
         R (save Y) )
      (while (pair (shift X))
         (setq Y
            (set 2 Y (cons (eval (car X)) $Nil)) ) )
      (set 2 Y R) ) )

# (rot 'lst ['cnt]) -> lst
(de _rot (Exe)
   (let (X (cdr Exe)  R (eval (car X)))
      (when (pair R)
         (let (Y R  A (++ Y))
            (if (pair (shift X))
               (let N (save R (evCnt Exe X))
                  (while (and (pair Y) (gt0 (dec 'N)))
                     (let B (car Y)
                        (set Y A)
                        (setq A B) )
                     (? (== R (shift Y))) )
                  (set R A) )
               (while (pair Y)
                  (let B (car Y)
                     (set Y A)
                     (setq A B) )
                  (? (== R (shift Y))) )
               (set R A) ) ) )
         R ) )

# (list 'any ['any ..]) -> lst
(de _list (Exe)
   (let
      (X (cdr Exe)
         Y (cons (eval (car X)) $Nil)
         R (save Y) )
      (while (pair (shift X))
         (setq Y
            (set 2 Y (cons (eval (car X)) $Nil)) ) )
      R ) )

# (need 'cnt ['lst ['any]]) -> lst
# (need 'cnt ['num|sym]) -> lst
(de _need (Exe)
   (let
      (X (cdr Exe)
         C (evCnt Exe X)
         R (save (eval (car (shift X))))
         Y
         (save
            (if (or (pair R) (nil? R))
               (eval (cadr X))
               (setq R $Nil)
               R ) )
         Z R )
      (unless (=0 C)
         (cond
            ((gt0 C)
               (while (pair Z)
                  (dec 'C)
                  (shift Z) )
               (while (ge0 (dec 'C))
                  (setq R (safe (cons Y R))) ) )
            (T
               (if (atom R)
                  (setq Z (setq R (safe (cons Y $Nil))))
                  (while (pair (cdr Z))
                     (inc 'C)
                     (shift Z) ) )
               (while (lt0 (inc 'C))
                  (setq Z (set 2 Z (cons Y $Nil))) ) ) ) )
      R ) )

# (range 'num1 'num2 ['num3]) -> lst
(de _range (Exe)
   (let
      (X (cdr Exe)
         N (needNum Exe (eval (++ X)))
         R (save (cons N $Nil))
         Lim (save (needNum Exe (eval (++ X))))
         Inc
         (if (nil? (eval (car X)))
            ONE
            (save (needNum Exe @)) ) )
      (when (or (== Inc ZERO) (sign? Inc))
         (argErr Exe Inc) )
      (let P R
         (if (le0 (cmpNum N Lim))
            (while (le0 (cmpNum (setq N (adds N Inc)) Lim))
               (setq P (set 2 P (cons N $Nil))) )
            (while (ge0 (cmpNum (setq N (subs N Inc)) Lim))
               (setq P (set 2 P (cons N $Nil))) ) ) )
      R ) )

# (full 'any) -> bool
(de _full (Exe)
   (let X (eval (cadr Exe))
      (loop
         (? (atom X) $T)
         (? (nil? (car X)) $Nil)
         (shift X) ) ) )

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

# (replace 'lst 'any1 'any2 ..) -> lst
(de _replace (Exe)
   (let (X (cdr Exe)  L (save (eval (car X))))
      (if (atom L)
         @
         (let (A $Nil  N 0  R (push NIL NIL))
            (while (pair (shift X))
               (link (push (eval (++ X)) NIL))
               (setq A (link (push (eval (car X)) NIL)))
               (inc 'N) )
            (let (Y (++ L)  Z A  I N)
               (until (lt0 (dec 'I))
                  (let (V (++ Z)  K (++ Z))
                     (? (equal Y K)
                        (setq Y V) ) ) )
               (let P (set (link R) (cons Y $Nil))
                  (while (pair L)
                     (setq Y (++ L)  Z A  I N)
                     (until (lt0 (dec 'I))
                        (let (V (++ Z)  K (++ Z))
                           (? (equal Y K)
                              (setq Y V) ) ) )
                     (setq P (set 2 P (cons Y $Nil))) ) ) )
            (val R) ) ) ) )

# (split 'lst 'any ..) -> lst
(de _split (Exe)
   (let (X (cdr Exe)  L (save (eval (car X))))
      (if (atom L)
         @
         (let (A $Nil  N 0)
            (while (pair (shift X))
               (setq A (link (push (eval (car X)) NIL)))
               (inc 'N) )
            (let
               (P $Nil
                  R (link (push P NIL))
                  Q $Nil
                  S (link (push Q NIL)) )
               (loop
                  (let (Y (++ L)  Z A  I N)
                     (loop
                        (? (lt0 (dec 'I))  # Not a delimiter
                           (let C (cons Y $Nil)
                              (setq Q
                                 (if (nil? Q)
                                    (set S C)
                                    (set 2 Q C) ) ) ) )
                        (? (equal Y (++ Z))  # Delimiter
                           (let C (cons (val S) $Nil)
                              (setq P
                                 (if (nil? P)
                                    (set R C)
                                    (set 2 P C) ) ) )
                           (setq Q (set S $Nil)) ) ) )
                  (? (atom L)) )
               (let C (cons (val S) $Nil)
                  (if (nil? P)
                     C
                     (set 2 P C)
                     (val R) ) ) ) ) ) ) )

# (head 'cnt|lst 'lst) -> lst
(de _head (Exe)
   (let (X (cdr Exe)  Y (eval (++ X)))
      (cond
         ((nil? Y) Y)
         ((pair Y)
            (save Y
               (let (Z Y  L (eval (car X)))
                  (loop
                     (?
                        (or
                           (atom L)
                           (not (equal (car Z) (car L))) )
                        $Nil )
                     (? (atom (shift Z)) Y)
                     (shift L) ) ) ) )
         ((=0 (xCnt Exe Y)) $Nil)
         (T
            (let (N @  L (eval (car X)))
               (cond
                  ((atom L) L)
                  ((and
                        (lt0 N)
                        (le0 (setq N (+ N (length L)))) )
                     $Nil )
                  (T
                     (save L
                        (let (Z (cons (car L) $Nil)  R Z)
                           (until (or (=0 (dec 'N)) (atom (shift L)))
                              (setq Z
                                 (set 2 Z (cons (car L) $Nil)) ) )
                           R ) ) ) ) ) ) ) ) )

# (tail 'cnt|lst 'lst) -> lst
(de _tail (Exe)
   (let (X (cdr Exe)  Y (eval (++ X)))
      (cond
         ((nil? Y) Y)
         ((pair Y)
            (save Y
               (let L (eval (car X))
                  (loop
                     (? (atom L) $Nil)
                     (? (equal L Y) Y)
                     (? (atom (shift L)) $Nil) ) ) ) )
         ((=0 (xCnt Exe Y)) $Nil)
         (T
            (let (N @  L (eval (car X)))
               (cond
                  ((atom L) L)
                  ((lt0 N)
                     (loop
                        (shift L)
                        (? (=0 (inc 'N)) L) ) )
                  (T
                     (let Z L
                        (loop
                           (? (=0 (dec 'N)))
                           (? (atom (shift Z))) )
                        (while (pair (shift Z))
                           (shift L) )
                        L ) ) ) ) ) ) ) )

# (fin 'any) -> num|sym
(de _fin (Exe)
   (let X (eval (cadr Exe))
      (while (pair X)
         (shift X) )
      X ) )

# (last 'lst) -> any
(de _last (Exe)
   (let X (eval (cadr Exe))
      (if (atom X)
         X
         (while (pair (cdr X))
            (setq X @) )
         (car X) ) ) )

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
   (if (symb? (eval (cadr Exe)))
      $T
      $Nil ) )

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
               (setq X (shr (shl @ 2) 6))  # Strip status bits
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
            (let (C (hex "82")  D T)  # Count '8' significant bytes
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

# (bytes 'any) -> cnt
(de _bytes (Exe)
   (cnt (binSize (eval (cadr Exe)))) )

# (assoc 'any 'lst) -> lst
(de _assoc (Exe)
   (let
      (X (cdr Exe)
         Y (save (eval (++ X)))
         Z (eval (car X)) )
      (loop
         (? (atom Z) $Nil)
         (let C (car Z)
            (? (and (pair C) (equal Y (car C))) C) )
         (shift Z) ) ) )

# (rassoc 'any 'lst) -> lst
(de _rassoc (Exe)
   (let
      (X (cdr Exe)
         Y (save (eval (++ X)))
         Z (eval (car X)) )
      (loop
         (? (atom Z) $Nil)
         (let C (car Z)
            (? (and (pair C) (equal Y (cdr C))) C) )
         (shift Z) ) ) )

# (asoq 'any 'lst) -> lst
(de _asoq (Exe)
   (let
      (X (cdr Exe)
         Y (save (eval (++ X)))
         Z (eval (car X)) )
      (loop
         (? (atom Z) $Nil)
         (let C (car Z)
            (? (and (pair C) (== Y (car C))) C) )
         (shift Z) ) ) )

# (rank 'any 'lst ['flg]) -> lst
(de _rank (Exe)
   (let
      (X (cdr Exe)
         Y (save (eval (++ X)))
         Z (save (eval (++ X)))
         R $Nil )
      (if (nil? (eval (car X)))
         (until (gt0 (compare (caar Z) Y))
            (setq R Z)
            (? (atom (shift Z))) )
         (until (lt0 (compare (caar Z) Y))
            (setq R Z)
            (? (atom (shift Z))) ) )
      (car R) ) )

(local) match

(de i1 match (Pat Dat)
   (loop
      (? (atom Pat)
         (if (or (num? Pat) (<> (firstByte Pat) (char "@")))
            (equal Pat Dat)
            (set Pat Dat)
            YES ) )
      (stkChk 0)
      (let X (car Pat)
         (when (and (symb? X) (== (firstByte X) (char "@")))
            (? (atom Dat)
               (and
                  (equal (cdr Pat) Dat)
                  (prog (set X $Nil) YES) ) )
            (? (match (cdr Pat) (cdr Dat))
               (set X (cons (car Dat) $Nil))
               YES )
            (? (match (cdr Pat) Dat)
               (set X $Nil)
               YES )
            (? (match Pat (cdr Dat))
               (set X (cons (car Dat) (val X)))
               YES ) )
         (? (or (atom Dat) (not (match X (car Dat))))
            NO ) )
      (shift Pat)
      (shift Dat) ) )

# (match 'lst1 'lst2) -> flg
(de _match (Exe)
   (let X (cdr Exe)
      (if
         (match
            (save (eval (++ X)))
            (save (eval (car X))) )
         $T
         $Nil ) ) )

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

(local) ($Penv $Pnl unify lup lookup uniFill)

(var $Penv 0)
(var $Pnl 0)

(de i1 unify (N1 X1 N2 X2)
   (let Penv (val $Penv)
      (: 1
         (when (and (symb? X1) (== (firstByte X1) (char "@")))
            (let X (val Penv)
               (while (pair (car X))
                  (let (Y @  Z (car Y))
                     (when (and (== N1 (car Z)) (== X1 (cdr Z)))
                        (setq
                           Z (cdr Y)
                           N1 (car Z)
                           X1 (cdr Z) )
                        (goto 1) ) )
                  (shift X) ) ) ) )
      (: 2
         (when (and (symb? X2) (== (firstByte X2) (char "@")))
            (let X (val Penv)
               (while (pair (car X))
                  (let (Y @  Z (car Y))
                     (when (and (== N2 (car Z)) (== X2 (cdr Z)))
                        (setq
                           Z (cdr Y)
                           N2 (car Z)
                           X2 (cdr Z) )
                        (goto 2) ) )
                  (shift X) ) ) ) )
      (cond
         ((and (== N1 N2) (equal X1 X2)) YES)
         ((and (symb? X1) (== (firstByte X1) (char "@")))
            (unless (== X1 $At)
               (set Penv
                  (cons (cons3 N1 X1 N2 X2) (val Penv)) ) )
            YES )
         ((and (symb? X2) (== (firstByte X2) (char "@")))
            (unless (== X2 $At)
               (set Penv
                  (cons (cons3 N2 X2 N1 X1) (val Penv)) ) )
            YES )
         ((or (atom X1) (atom X2)) (equal X1 X2))
         (T
            (stkChk 0)
            (let Env (val Penv)
               (or
                  (and
                     (unify N1 (car X1) N2 (car X2))
                     (unify N1 (cdr X1) N2 (cdr X2)) )
                  (prog (set Penv Env) NO) ) ) ) ) ) )

(de lup (N X)
   (stkChk 0)
   (let Penv (val $Penv)
      (: 1
         (when (and (symb? X) (== (firstByte X) (char "@")))
            (let V (val Penv)
               (while (pair (car V))
                  (let (Y @  Z (car Y))
                     (when (and (== N (car Z)) (== X (cdr Z)))
                        (setq
                           Z (cdr Y)
                           N (car Z)
                           X (cdr Z) )
                        (goto 1) ) )
                  (shift V) ) ) ) ) )
   (if (atom X)
      X
      (let Z (save (lup N (car X)))
         (cons Z (lup N (cdr X))) ) ) )

(de lookup (N X)
   (if
      (and
         (symb? (setq X (lup N X)))
         (== (firstByte X) (char "@")) )
      $Nil
      X ) )

(de uniFill (X)
   (cond
      ((num? X) X)
      ((sym? X)
         (lup (car (val (val $Pnl))) X) )
      (T
         (stkChk 0)
         (let Y (save (uniFill (car X)))
            (cons Y (uniFill (cdr X))) ) ) ) )

# (prove 'lst ['lst]) -> lst
(de _prove (Exe)
   (let X (cdr Exe)
      (if (atom (eval (car X)))
         $Nil
         (let
            (Q (save @)
               Dbg (if (nil? (eval (cadr X))) 0 (save @))
               P (prog1 (caar Q) (set Q (cdar Q)))
               N (++ P)
               Nl (link (push (++ P) NIL))
               Alt (link (push (++ P) NIL))
               Tp1 (link (push (++ P) NIL))
               Tp2 (link (push (++ P) NIL))
               Env (link (push P NIL))
               E (link (push $Nil NIL))
               At (save (val $At))
               Penv (val $Penv)
               Pnl (val $Pnl) )
            (set $Penv Env  $Pnl Nl)
            (while (or (pair (val Tp1)) (pair (val Tp2)))
               (cond
                  ((pair (val Alt))
                     (set E (val Env))
                     (ifn
                        (unify
                           (car (val Nl))
                           (cdar (val Tp1))
                           N
                           (caar (val Alt)) )
                        (when (atom (set Alt (cdr (val Alt))))
                           (setq P (caar Q))
                           (set Q (cdar Q))
                           (setq N (++ P))
                           (set
                              Nl (++ P)
                              Alt (++ P)
                              Tp1 (++ P)
                              Tp2 (++ P)
                              Env P ) )
                        (unless (=0 Dbg)
                           (let Y (car (val Tp1))
                              (when (memq (car Y) Dbg)
                                 (let (L (get (car Y) $T)  I 1)
                                    (until (equal (car (val Alt)) (car L))
                                       (inc 'I)
                                       (shift L) )
                                    (outWord I) )
                                 (space)
                                 (print (uniFill Y))
                                 (newline) ) ) )
                        (when (pair (cdr (val Alt)))
                           (set Q
                              (cons
                                 (cons N
                                    (cons (val Nl)
                                       (cons @
                                          (cons (val Tp1) (cons (val Tp2) (val E))) ) ) )
                                 (car Q) ) ) )
                           (set
                              Nl (cons N (val Nl))
                              Tp2 (cons (cdr (val Tp1)) (val Tp2))
                              Tp1 (cdar (val Alt))
                              Alt $Nil )
                           (setq N (+ N (hex "10")) ) ) )  # Increment
                  ((atom (setq X (val Tp1)))
                     (set
                        Tp1 (car (val Tp2))
                        Tp2 (cdr (val Tp2))
                        Nl (cdr (val Nl)) ) )
                  ((t? (car X))
                     (while
                        (and
                           (pair (car Q))
                           (>= (caar @) (car (val Nl))) )
                        (set Q (cdar Q)) )
                     (set Tp1 (cdr X)) )
                  ((num? (car @))
                     (set E (run (cdar X)))
                     (let (I (int (caar X))  Y (val Nl))
                        (while (gt0 (dec 'I))
                           (shift Y) )
                        (set
                           Nl (cons (car X) (val Nl))
                           Tp2 (cons (cdr (val Tp1)) (val Tp2))
                           Tp1 (val E) ) ) )
                  ((== @ (val $Up))
                     (if
                        (and
                           (nil? (set E (run (cddr (car X)))))
                           (unify
                              (car (val Nl))
                              (cadr (car X))
                              (car (val Nl))
                              (val E) ) )
                        (set Tp1 (cdr X))
                        (setq P (caar Q))
                        (set Q (cdar Q))
                        (setq N (++ P))
                        (set
                           Nl (++ P)
                           Alt (++ P)
                           Tp1 (++ P)
                           Tp2 (++ P)
                           Env P ) ) )
                  ((atom (set Alt (get (caar X) $T)))
                     (setq P (caar Q))
                     (set Q (cdar Q))
                     (setq N (++ P))
                     (set
                        Nl (++ P)
                        Alt (++ P)
                        Tp1 (++ P)
                        Tp2 (++ P)
                        Env P ) ) ) )
            (set E $Nil)
            (let Y (val Env)
               (while (pair (cdr Y))
                  (let Z (caar Y)
                     (when (== (car Z) ZERO)
                        (set E
                           (cons
                              (cons (shift Z) (lookup ZERO Z))
                              (val E) ) ) ) )
                  (shift Y) ) )
            (set $Pnl Pnl  $Penv Penv  $At At)
            (cond
               ((pair (val E)) @)
               ((pair (val Env)) $T)
               (T $Nil) ) ) ) ) )

# (-> any [cnt]) -> any
(de _arrow (Exe)
   (let (X (cdr Exe)  L (val (val $Pnl)))
      (when (num? (cadr X))
         (let I (int @)
            (while (gt0 (dec 'I))
               (shift L) ) ) )
      (lookup (car L) (car X)) ) )

# (unify 'any) -> lst
(de _unify (Exe)
   (let (X (save (eval (cadr Exe)))  L (val (val $Pnl)))
      (if (unify (cadr L) X (car L) X)
         (val (val $Pnl))
         $Nil ) ) )
