# 11feb22 Software Lab. Alexander Burger

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
               (prog1
                  R
                  (setq R $Nil) ) ) )
         Z R )
      (when C
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
      (unless (val $Make)
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
      (unless (val $Make)
         (makeErr Exe) )
      (loop
         (let Y (set (val $Make) (eval (++ X)))
            (when (pair Y)
               (let Z Y
                  (while (pair (cdr Z))
                     (setq Z @) )
                  (set $Make (ofs Z 1)) ) )
            (? (atom X) Y) ) ) ) )

# (link 'any ..) -> any
(de _link (Exe)
   (let X (cdr Exe)
      (unless (val $Make)
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
      (unless (val $Make)
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

# (copy 'any) -> any
(de _copy (Exe)
   (let X (cdr Exe)
      (if (atom (setq X (eval (car X))))
         X
         (let
            (Y (cons (car X) (cdr X))
               R (save Y)
               Z X )
            (while (pair (setq X (cdr Y)))
               (? (== X Z) (set 2 Y R))
               (setq Y
                  (set 2 Y (cons (car X) (cdr X))) ) )
            R ) ) ) )

# (mix 'lst cnt|'any ..) -> lst
(de _mix (Exe)
   (let (X (cdr Exe)  Y (eval (car X)))
      (nond
         ((or (pair Y) (nil? Y)) Y)
         ((pair (shift X)) $Nil)
         (NIL
            (save Y
               (let
                  (Z
                     (cons
                        (if (cnt? (car X))
                           (nth @ Y)
                           (eval @) )
                        $Nil )
                     R (save Z) )
                  (while (pair (shift X))
                     (setq Z
                        (set 2 Z
                           (cons
                              (if (cnt? (car X))
                                 (nth @ Y)
                                 (eval @) )
                              $Nil ) ) ) )
                  R ) ) ) ) ) )

# (append 'lst ..) -> lst
(de _append (Exe)
   (let X Exe
      (loop
         (? (atom (cdr (shift X)))
            (eval (car X)) )
         (? (pair (eval (car X)))
            (let
               (Y (save @)
                  R (safe (cons (++ Y) Y))
                  Z R )
               (while (pair Y)
                  (setq Z (set 2 Z (cons (++ Y) Y))) )
               (while (pair (cdr (shift X)))
                  (save (setq Y (eval (car X)))
                     (while (pair Y)
                        (setq Z (set 2 Z (cons (++ Y) Y))) ) ) )
               (set 2 Z (eval (car X)))
               R ) ) ) ) )

# (delete 'any 'lst ['flg]) -> lst
(de _delete (Exe)
   (let
      (X (cdr Exe)
         Y (save (eval (++ X)))
         L (save (eval (++ X)))
         F (nil? (eval (car X))) )
      (loop
         (? (atom L) L)
         (? (not (equal Y (car L)))
            (let R (save (setq X (cons (car L) $Nil)))
               (loop
                  (? (atom (shift L))
                     (set 2 X L) )
                  (ifn (equal Y (car L))
                     (setq X (set 2 X (cons (car L) $Nil)))
                     (? F (set 2 X (cdr L))) ) )
               R ) )
         (shift L)
         (? F L) ) ) )

# (delq 'any 'lst ['flg]) -> lst
(de _delq (Exe)
   (let
      (X (cdr Exe)
         Y (save (eval (++ X)))
         L (save (eval (++ X)))
         F (nil? (eval (car X))) )
      (loop
         (? (atom L) L)
         (? (<> Y (car L))
            (let R (save (setq X (cons (car L) $Nil)))
               (loop
                  (? (atom (shift L))
                     (set 2 X L) )
                  (if (<> Y (car L))
                     (setq X (set 2 X (cons (car L) $Nil)))
                     (? F (set 2 X (cdr L))) ) )
               R ) )
         (shift L)
         (? F L) ) ) )

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

# (insert 'cnt 'lst 'any) -> lst
(de _insert (Exe)
   (let
      (X (cdr Exe)
         N (evCnt Exe X)
         L (save (eval (car (shift X)))) )
      (setq X (eval (car (shift X))))
      (if (or (atom L) (le0 (dec 'N)))
         (cons X L)
         (let (Y (cons (car L) $Nil)  R (save Y))
            (while (and (pair (shift L)) (dec 'N))
               (setq Y (set 2 Y (cons (car L) $Nil))) )
            (set 2 Y (cons X L))
            R ) ) ) )

# (remove 'cnt 'lst) -> lst
(de _remove (Exe)
   (let
      (X (cdr Exe)
         N (evCnt Exe X)
         L (save (eval (car (shift X)))) )
      (cond
         ((or (atom L) (lt0 (dec 'N))) L)
         ((=0 N) (cdr L))
         (T
            (let (Y (cons (car L) $Nil)  R (save Y))
               (loop
                  (? (atom (shift L))
                     (set 2 Y L) )
                  (? (=0 (dec 'N))
                     (set 2 Y (cdr L)) )
                  (setq Y (set 2 Y (cons (car L) $Nil))) )
               R ) ) ) ) )

# (place 'cnt 'lst 'any) -> lst
(de _place (Exe)
   (let
      (X (cdr Exe)
         N (evCnt Exe X)
         L (save (eval (car (shift X))))
         Y (save (eval (car (shift X)))) )
      (cond
         ((atom L) (cons Y $Nil))
         ((le0 (dec 'N)) (cons Y (cdr L)))
         (T
            (let (Z (cons (car L) $Nil)  R (save Z))
               (loop
                  (? (atom (shift L))
                     (set 2 Z (cons Y L)) )
                  (? (=0 (dec 'N))
                     (set 2 Z (cons Y (cdr L))) )
                  (setq Z (set 2 Z (cons (car L) $Nil))) )
               R ) ) ) ) )

# (strip 'any) -> any
(de _strip (Exe)
   (let X (eval (cadr Exe))
      (while (and (pair X) (== $Quote (car X)))
         (? (== (cdr X) X))  # Circular
         (setq X @) )
      X ) )

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

# (reverse 'lst) -> lst
(de _reverse (Exe)
   (let
      (X (cdr Exe)
         Y (save (eval (car X)))
         Z $Nil )
      (while (pair Y)
         (setq Z (cons (++ Y) Z)) )
      Z ) )

# (flip 'lst ['cnt]) -> lst
(de _flip (Exe)
   (let (X (cdr Exe)  Y (eval (car X)))
      (if (atom Y)
         Y
         (let Z (cdr Y)
            (cond
               ((atom Z) Y)
               ((atom (shift X))
                  (set 2 Y $Nil)
                  (loop
                     (setq X (cdr Z))
                     (set 2 Z Y)
                     (? (atom X) Z)
                     (setq Y Z  Z X) ) )
               (T
                  (let N (save Y (evCnt Exe X))
                     (if (le0 (dec 'N))
                        Y
                        (set 2 Y (cdr Z)  2 Z Y)
                        (until
                           (or
                              (=0 (dec 'N))
                              (atom (setq X (cdr Y))) )
                           (set 2 Y (cdr X)  2 X Z)
                           (setq Z X) )
                        Z ) ) ) ) ) ) ) )

(local) trim

(de trim (X)
   (if (atom X)
      X
      (stkChk 0)
      (let Y (trim (cdr X))
         (if (and (nil? Y) (isBlank (car X)))
            $Nil
            (cons (car X) Y) ) ) ) )

# (trim 'lst) -> lst
(de _trim (Exe)
   (trim (save (eval (cadr Exe)))) )

# (clip 'lst) -> lst
(de _clip (Exe)
   (let (X (cdr Exe)  Y (eval (car X)))
      (while (and (pair Y) (isBlank (car Y)))
         (shift Y) )
      (trim (save Y)) ) )

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
                        (le0 (inc 'N (length L))) )
                     $Nil )
                  (T
                     (save L
                        (let (Z (cons (car L) $Nil)  R (save Z))
                           (while (and (dec 'N) (pair (shift L)))
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

# (stem 'lst 'any ..) -> lst
(de _stem (Exe)
   (let (X (cdr Exe)  L (save (eval (++ X))))
      (if (atom X)
         L
         (let (R L  N 1  A T)
            (loop
               (setq A (link (push (eval (car X)) NIL)))
               (? (atom (shift X)))
               (inc 'N) )
            (loop
               (let (P A  I N)
                  (loop
                     (? (equal (car L) (car P))
                        (setq R (cdr L)) )
                     (? (=0 (dec 'I)))
                     (shift P) ) )
               (? (atom (shift L))) )
            R ) ) ) )

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
   (if (t? (eval (cadr Exe))) @ $Nil) )

# (n0 'any) -> flg
(de _neq0 (Exe)
   (if (== (eval (cadr Exe)) ZERO) $Nil $T) )

# (nT 'any) -> flg
(de _neqT (Exe)
   (if (t? (eval (cadr Exe))) $Nil $T) )

# (< 'any ..) -> flg
(de _lt (Exe)
   (let (X (cdr Exe)  Y (save (eval (car X))))
      (loop
         (? (atom (shift X)) $T)
         (let Z (eval (car X))
            (? (ge0 (compare Y Z)) $Nil)
            (setq Y (safe Z)) ) ) ) )

# (<= 'any ..) -> flg
(de _le (Exe)
   (let (X (cdr Exe)  Y (save (eval (car X))))
      (loop
         (? (atom (shift X)) $T)
         (let Z (eval (car X))
            (? (gt0 (compare Y Z)) $Nil)
            (setq Y (safe Z)) ) ) ) )

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

# (max 'any ..) -> any
(de _max (Exe)
   (let (X (cdr Exe)  R (save (eval (car X))))
      (while (pair (shift X))
         (let Z (eval (car X))
            (when (gt0 (compare Z R))
               (setq R (safe Z)) ) ) )
      R ) )

# (min 'any ..) -> any
(de _min (Exe)
   (let (X (cdr Exe)  R (save (eval (car X))))
      (while (pair (shift X))
         (let Z (eval (car X))
            (when (lt0 (compare Z R))
               (setq R (safe Z)) ) ) )
      R ) )

# (atom 'any) -> flg
(de _atom (Exe)
   (if (atom (eval (cadr Exe))) $T $Nil) )

# (pair 'any) -> any
(de _pair (Exe)
   (if (pair (eval (cadr Exe))) @ $Nil) )

# (circ? 'any) -> any
(de _circQ (Exe)
   (if (circ (eval (cadr Exe))) @ $Nil) )

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
         Z (eval (car X))
         H Z )
      (loop
         (? (atom Z)
            (if (equal Y Z) Z $Nil) )
         (? (equal Y (car Z)) Z)
         (? (== H (shift Z)) $Nil) ) ) )

# (memq 'any 'lst) -> any
(de _memq (Exe)
   (let
      (X (cdr Exe)
         Y (save (eval (++ X)))
         Z (eval (car X))
         H Z )
      (loop
         (? (atom Z)
            (if (== Y Z) Z $Nil) )
         (? (== Y (car Z)) Z)
         (? (== H (shift Z)) $Nil) ) ) )

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
         Z (save (eval (car X)))
         P 0
         R (link (push $Nil NIL)) )
      (while (pair Y)
         (let U (++ Y)
            (when (member U Z)
               (let V (cons U $Nil)
                  (setq P
                     (if P
                        (set 2 P V)
                        (set R V) ) ) ) ) ) )
      (val R) ) )

# (diff 'lst 'lst) -> lst
(de _diff (Exe)
   (let
      (X (cdr Exe)
         Y (save (eval (++ X)))
         Z (save (eval (car X)))
         P 0
         R (link (push $Nil NIL)) )
      (while (pair Y)
         (let U (++ Y)
            (unless (member U Z)
               (let V (cons U $Nil)
                  (setq P
                     (if P
                        (set 2 P V)
                        (set R V) ) ) ) ) ) )
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
                  (? (& (car X) 1)
                     (until (== X Y)
                        (set Y (& (car Y) -2))
                        (shift Y) )
                     (loop
                        (set Y (& (car Y) -2))
                        (? (== X (shift Y))) )
                     $T )  # Infinite
                  (inc 'C (hex "10")) ) ) )
         ((nil? X) ZERO)
         ((sym? (val (tail X))) ZERO)
         (T
            (let (C ZERO  P (push 0 (name @)))
               (while (symChar P)
                  (inc 'C (hex "10")) )
               C ) ) ) ) )

(local) (size binSize)

(de size (L)
   (let (C 1  X L  Y (car X))
      (loop
         (when (pair Y)
            (stkChk 0)
            (inc 'C (size Y)) )
         (set X (| Y 1))
         (? (atom (shift X))
            (loop
               (set L (& (car L) -2))
               (? (== X (shift L))) )
            C )
         (? (& (setq Y (car X)) 1)
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
               (while (setq X (shr X 8))
                  (inc 'C) )
               C ) ) )
      ((big? X)
         (setq X (pos X))
         (let C 9  # Count 8 significant bytes plus 1
            (loop
               (setq D (val (dig X)))
               (? (cnt? (setq X (val (big X)))))
               (inc 'C 8) )  # Increment count by 8
            (setq X (int X))
            (add D D)  # Get most significant bit of last digit
            (setq X (+ X X @@))
            (: 2
               (when X
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
            ((cnt? (setq X @))
               (setq X (shr (shl X 2) 6))  # Strip status bits
               (goto 1) )
            (T
               (let C 9  # Count 8 significant bytes plus 1
                  (until (cnt? (setq X (val (big X))))
                     (inc 'C 8) )  # Increment count by 8
                  (setq X (int X))
                  (goto 2) ) ) ) )
      (T
         (let (C 2  Y X)
            (loop
               (inc 'C (binSize (++ X)))
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
               (while (setq X (shr X 8))
                  (inc 'C (hex "10")) )
               C ) )
         ((big? X)
            (setq X (pos X))
            (let (C (hex "82")  D T)  # Count '8' significant bytes
               (loop
                  (setq D (val (dig X)))
                  (? (cnt? (setq X (val (big X)))))
                  (inc 'C (hex "80")) )  # Increment count by '8'
               (setq X (int X))
               (add D D)  # Get most significant bit of last digit
               (when (setq X (+ X X @@))
                  (loop
                     (inc 'C (hex "10"))
                     (? (=0 (setq X (shr X 8)))) ) )
               C ) )
         ((pair X) (cnt (size X)))
         ((nil? X) ZERO)
         ((sym? (val (tail X)))
            (dbFetch Exe X)
            (let
               (C (+ (binSize (val X)) (inc BLK))  # Value
                  Y (& (val (tail X)) -9) )
               (while (pair Y)  # Properties
                  (let Z (++ Y)
                     (setq C
                        (+ C
                           (if (atom Z)
                              (+ (binSize Z) 2)
                              (+
                                 (binSize (car Z))
                                 (binSize (cdr Z)) ) ) ) ) ) )
               (cnt C) ) )
         ((== (name @) ZERO) @)
         ((cnt? @)
            (let (C ONE  Z (int @))
               (while (setq Z (shr Z 8))
                  (inc 'C (hex "10")) )
               C ) )
         (T
            (let (C (hex "82")  Z @)  # Count '8' significant bytes
               (until (cnt? (setq Z (val (big Z))))
                  (inc 'C (hex "80")) )  # Increment count by '8'
               (when (setq Z (int Z))
                  (loop
                     (inc 'C (hex "10"))
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
         Z (eval (car X))
         H Z )
      (loop
         (? (atom Z) $Nil)
         (let C (car Z)
            (? (and (pair C) (equal Y (car C))) C) )
         (? (== H (shift Z)) $Nil) ) ) )

# (rassoc 'any 'lst) -> lst
(de _rassoc (Exe)
   (let
      (X (cdr Exe)
         Y (save (eval (++ X)))
         Z (eval (car X))
         H Z )
      (loop
         (? (atom Z) $Nil)
         (let C (car Z)
            (? (and (pair C) (equal Y (cdr C))) C) )
         (? (== H (shift Z)) $Nil) ) ) )

# (asoq 'any 'lst) -> lst
(de _asoq (Exe)
   (let
      (X (cdr Exe)
         Y (save (eval (++ X)))
         Z (eval (car X))
         H Z )
      (loop
         (? (atom Z) $Nil)
         (let C (car Z)
            (? (and (pair C) (== Y (car C))) C) )
         (? (== H (shift Z)) $Nil) ) ) )

# (rasoq 'any 'lst) -> lst
(de _rasoq (Exe)
   (let
      (X (cdr Exe)
         Y (save (eval (++ X)))
         Z (eval (car X))
         H Z )
      (loop
         (? (atom Z) $Nil)
         (let C (car Z)
            (? (and (pair C) (== Y (cdr C))) C) )
         (? (== H (shift Z)) $Nil) ) ) )

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

(local) (fill2 fill3)

(de fill2 (X Y)
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
               ((or (== X Y) (memq X Y)) V)
               (T 0) ) ) )
      (T
         (stkChk 0)
         (let Z (++ X)
            (if (== Z $Up)  # Expand expression
               (let V (eval (++ X))
                  (if (nil? V)
                     (if (fill2 X Y) @ X)
                     (save (setq Z V)
                        (if (atom V)
                           (safe (setq Z (setq V (cons V $Nil))))
                           (while (pair (cdr V))
                              (setq V @) ) )
                        (set 2 V
                           (if (fill2 X Y) @ X) )
                        Z ) ) )
               (cond
                  ((fill2 Z Y)
                     (save @
                        (cons @ (if (fill2 X Y) @ X)) ) )
                  ((fill2 X Y) (cons Z @))
                  (T 0) ) ) ) ) ) )

(de fill3 (X Y Z)
   (if (atom X)
      (if (== X Y) Z 0)
      (stkChk 0)
      (let A (++ X)
         (cond
            ((fill3 A Y Z)
               (save @
                  (cons @ (if (fill3 X Y Z) @ X)) ) )
            ((fill3 X Y Z) (cons A @))
            (T 0) ) ) ) )

# (fill 'any ['sym|lst]) -> any
# (fill 'any ['cnt|sym] 'any2) -> any
(de _fill (Exe)
   (let
      (X (cdr Exe)
         Y (save (eval (++ X)))
         Z (save (eval (++ X))) )
      (if
         (if (pair X)
            (fill3 Y Z (save (eval (car X))))
            (fill2 Y Z) )
         @
         Y ) ) )

(local) ($Penv $Pnl unify lup lookup uniFill uniRun)

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
               (set Penv  # (((n1 . x1) . (n2 . x2)) . Penv)
                  (cons (cons3 N1 X1 N2 X2) (val Penv)) ) )
            YES )
         ((and (symb? X2) (== (firstByte X2) (char "@")))
            (unless (== X2 $At)
               (set Penv  # (((n2 . x2) . (n1 . x1)) . Penv)
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
   (let Penv (val $Penv)
      (: 1
         (when (and (symb? X) (== (firstByte X) (char "@")))
            (let V (val Penv)
               (while (pair (car V))
                  (let (Y @  Z (car Y))
                     (when
                        (and
                           (== N (car Z))
                           (== X (cdr Z)) )
                        (setq
                           Z (cdr Y)
                           N (car Z)
                           X (cdr Z) )
                        (goto 1) ) )
                  (shift V) ) ) ) ) )
   (if
      (or
         (atom X)
         (cnt? (car X))
         (== @ $Up) )
      X
      (stkChk 0)
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

(de uniRun (Prg)
   (let (P (val $Bind)  Q P  Z Prg  Tos 0)
      (loop
         (until (atom (car Z))
            (let U Z  # Go left
               (setq Z @)  # Invert tree
               (set U Tos)
               (setq Tos U) ) )
         (let Y (car Z)
            (when
               (and
                  (symb? Y)
                  (<> -ZERO (val Y))
                  (== (firstByte Y) (char "@")) )
               (set $Bind (setq P (push (val Y) Y P)))
               (set Y -ZERO) ) )
         (loop
            (? (pair (cdr Z))  # Right subtree
               (let U Z  # Go right
                  (setq Z @)  # Invert tree
                  (set 2 U Tos)
                  (setq Tos (| U 8)) ) )
            (let Y @  # Dotted structure symbol?
               (when
                  (and
                     (symb? Y)
                     (<> -ZERO (val Y))
                     (== (firstByte Y) (char "@")) )
                  (set $Bind (setq P (push (val Y) Y P)))
                  (set Y -ZERO) ) )
            (loop
               (unless Tos
                  (let (X P  N (car (val (val $Pnl))))
                     (until (== Q X)
                        (let Y (val 2 X)
                           (set Y (lookup N Y)) )
                        (setq X (val 3 X)) ) )
                  (loop
                     (let X (++ Prg)
                        (when (atom Prg)
                           (setq X (eval X))
                           (until (== Q P)
                              (set (val 2 P) (val P))  # Restore values
                              (setq P (val 3 P)) )
                           (set $Bind P)
                           (ret X) )
                        (and (pair X) (evList X)) ) ) )
               (? (=0 (& Tos 8))  # Second visit
                  (let U Tos
                     (setq Tos (car U))  # TOS on up link
                     (set U Z)
                     (setq Z U) ) )
               (let U (& Tos -9)  # Set second visit
                  (setq Tos (cdr U))
                  (set 2 U Z)
                  (setq Z U) ) ) ) ) ) )

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
               (sigChk Exe)
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
                        (when Dbg
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
                        (inc 'N (hex "10")) ) )  # Increment
                  ((atom (setq X (val Tp1)))
                     (set
                        Tp1 (car (val Tp2))
                        Tp2 (cdr (val Tp2))
                        Nl (cdr (val Nl)) ) )
                  ((atom (car X))  # Cut operator
                     (while
                        (and
                           (pair (car Q))
                           (>= (caar @) (car (val Nl))) )
                        (set Q (cdar Q)) )
                     (set Tp1 (cdr X)) )
                  ((cnt? (car @))
                     (set E (uniRun (cdar X)))
                     (let (I (int (caar X))  Y (val Nl))
                        (while (gt0 (dec 'I))
                           (shift Y) )
                        (set
                           Nl (cons (car Y) (val Nl))
                           Tp2 (cons (cdr X) (val Tp2))
                           Tp1 (val E) ) ) )
                  ((== @ $Up)
                     (if
                        (and
                           (not
                              (nil? (set E (uniRun (cddr (car X))))) )
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
      (when (cnt? (cadr X))
         (let I (int @)
            (while (gt0 (dec 'I))
               (shift L) ) ) )
      (lookup (car L) (car X)) ) )

# (unify 'any) -> lst
# (unify 'cnt) -> cnt
(de _unify (Exe)
   (let
      (X (eval (cadr Exe))
         Pnl (val (val $Pnl))
         N (car Pnl) )
      (ifn (cnt? X)
         (save X
            (if (unify (cadr Pnl) X N X)
               (val (val $Penv))
               $Nil ) )
         (let (I (int @)  Penv (val (val $Penv)))
            (while (gt0 (dec 'I))
               (shift Pnl) )
            (let M (car Pnl)
               (while (pair (car Penv))
                  (let Y (car @)
                     (when (== (car Y) M)
                        (let S (cdr Y)
                           (unify M S N S) ) ) )
                  (shift Penv) ) )
            X ) ) ) )

# (group 'lst) -> lst
(de _group (Exe)
   (let X (save (eval (cadr Exe)))
      (if (atom X)
         $Nil
         (let Y (cons (cdar X) $Nil)
            (setq Y
               (cons (cons (caar X) (cons Y Y)) $Nil) )
            (let R (save Y)
               (while (pair (shift X))
                  (let (L (car X)  K (car L))
                     (setq Y (cons (cdr L) $Nil))
                     (let Z R
                        (loop
                           (let V (car Z)
                              (? (equal K (car V))
                                 (set
                                    (shift V)
                                    (set 2 (car V) Y) ) )
                              (? (atom (cdr Z))
                                 (set 2 Z
                                    (cons (cons K (cons Y Y)) $Nil) ) )
                              (setq Z @) ) ) ) ) )
               (let Z R
                  (loop
                     (let V (car Z)
                        (set 2 V (cddr V)) )
                     (? (atom (shift Z))) ) )
               R ) ) ) ) )

(local) cmpSort

(inline (E A B) cmpSort (X Y)
   (set 4 A X  4 B Y)
   (if (nil? (evList E)) 0 -1) )

# (sort 'lst ['fun]) -> lst
(de _sort (Exe)
   (let (X (cdr Exe)  Y (eval (++ X)))
      (cond
         ((atom Y) @)
         ((atom X)
            (let (Out0 Y  Out1 $Nil)
               (loop
                  (let (In0 Out0  In1 Out1  P)
                     (if
                        (and
                           (pair In1)
                           (ge0 (compare (car In0) (car In1))) )
                        (setq In1 (cdr (setq P In1)))
                        (setq In0 (cdr (setq P In0))) )
                     (let (Tail0 (ofs P 1)  Tail1 0  Last (car P))
                        (setq Out0 P  Out1 $Nil)
                        (set 2 P $Nil)
                        (while (or (pair In0) (pair In1))
                           (cond
                              ((atom In1)
                                 (setq In0 (cdr (setq P In0)))
                                 (when (lt0 (compare (car P) Last))
                                    (xchg 'Tail0 'Tail1) ) )
                              ((atom In0)
                                 (setq In1 (cdr (setq P In1)))
                                 (when (lt0 (compare (car P) Last))
                                    (xchg 'Tail0 'Tail1) ) )
                              ((lt0 (compare (car In0) Last))
                                 (if (ge0 (compare (car In1) Last))
                                    (setq In1 (cdr (setq P In1)))
                                    (if (lt0 (compare (car In0) (car In1)))
                                       (setq In0 (cdr (setq P In0)))
                                       (setq In1 (cdr (setq P In1))) )
                                    (xchg 'Tail0 'Tail1) ) )
                              ((lt0 (compare (car In1) Last))
                                 (setq In0 (cdr (setq P In0))) )
                              ((lt0 (compare (car In0) (car In1)))
                                 (setq In0 (cdr (setq P In0))) )
                              (T (setq In1 (cdr (setq P In1)))) )
                           (setq Tail0
                              (ofs
                                 (if Tail0
                                    (set Tail0 P)
                                    (setq Out1 P) )
                                 1 ) )
                           (set 2 P $Nil)
                           (setq Last (car P)) ) ) )
                  (? (atom Out1) Out0) ) ) )
         (T
            (let
               (Out0 (link (push Y NIL) T)
                  Out1 (link (push $Nil NIL))
                  In0 (link (push -ZERO NIL))
                  In1 (link (push -ZERO NIL))
                  B (push NIL $Nil ZERO NIL)
                  A (push NIL B ZERO NIL)
                  E (push NIL A ZERO (eval (car X)) NIL)  # [car cdr name fun link]
                  P )
               (set
                  B (ofs B 3)
                  A (ofs A 3)
                  E (link (ofs E 3)) )
               (loop
                  (set In0 (val Out0)  In1 (val Out1))
                  (if
                     (and
                        (pair (val In1))
                        (ge0 (cmpSort (caar In0) (caar In1))) )
                     (set In1 (cdr (setq P (val In1))))
                     (set In0 (cdr (setq P (val In0)))) )
                  (let (Tail0 (ofs P 1)  Tail1 0  Last (car P))
                     (set Out0 P  Out1 $Nil)
                     (set 2 P $Nil)
                     (while (or (pair (val In0)) (pair (val In1)))
                        (cond
                           ((atom (val In1))
                              (set In0 (cdr (setq P (val In0))))
                              (when (lt0 (cmpSort (car P) Last))
                                 (xchg 'Tail0 'Tail1) ) )
                           ((atom (val In0))
                              (set In1 (cdr (setq P (val In1))))
                              (when (lt0 (cmpSort (car P) Last))
                                 (xchg 'Tail0 'Tail1) ) )
                           ((lt0 (cmpSort (caar In0) Last))
                              (if (ge0 (cmpSort (caar In1) Last))
                                 (set In1 (cdr (setq P (val In1))))
                                 (if (lt0 (cmpSort (caar In0) (caar In1)))
                                    (set In0 (cdr (setq P (val In0))))
                                    (set In1 (cdr (setq P (val In1)))) )
                                 (xchg 'Tail0 'Tail1) ) )
                           ((lt0 (cmpSort (caar In1) Last))
                              (set In0 (cdr (setq P (val In0)))) )
                           ((lt0 (cmpSort (caar In0) (caar In1)))
                              (set In0 (cdr (setq P (val In0)))) )
                           (T (set In1 (cdr (setq P (val In1))))) )
                        (setq Tail0
                           (ofs
                              (if Tail0
                                 (set Tail0 P)
                                 (set Out1 P) )
                              1 ) )
                        (set 2 P $Nil)
                        (setq Last (car P)) ) )
                  (? (atom (val Out1)) (val Out0)) ) ) ) ) ) )
