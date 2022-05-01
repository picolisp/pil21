# 01may22 Software Lab. Alexander Burger

(symbols '(llvm))

# (apply 'fun 'lst ['any ..]) -> any
(de _apply (Exe)
   (let
      (X (cdr Exe)
         E (push NIL $Nil ZERO (eval (++ X)) NIL) )  # [car cdr name fun link]
      (set E (link (ofs E 3) T))
      (let (L (save (eval (car X)))  P E)
         (while (pair (shift X))
            (setq P
               (set 2 P
                  (push NIL $Nil ZERO (eval (car X)) NIL) ) )  # [car cdr name val link]
            (set P (link (ofs P 3))) )
         (while (pair L)
            (stkChk Exe)
            (setq P
               (set 2 P (push NIL $Nil ZERO (++ L) NIL)) )
            (set P (link (ofs P 3))) )
         (evList E) ) ) )

# (pass 'fun ['any ..]) -> any
(de _pass (Exe)
   (let
      (X (cdr Exe)
         E (push NIL $Nil ZERO (eval (++ X)) NIL) )
      (set E (link (ofs E 3) T))
      (let P E
         (while (pair X)
            (setq P
               (set 2 P
                  (push NIL $Nil ZERO (eval (++ X)) NIL) ) )
            (set P (link (ofs P 3))) )
         (let L (val $Next)
            (while (pair L)
               (setq P
                  (set 2 P (push NIL $Nil ZERO (cdr L) NIL)) )
               (set P (link (ofs P 3)))
               (setq L (car L)) ) ) )
      (evList E) ) )

# (fun 'fun ['any ..]) -> any
(de _fun (Exe)
   (evList (cdr Exe)) )

# (maps 'fun 'sym ['lst ..]) -> any
(de _maps (Exe)
   (let
      (X (cdr Exe)
         R $Nil
         E (push NIL $Nil ZERO (eval (++ X)) NIL)
         A (push NIL NIL) )
      (set E (link (ofs E 3) T))
      (let
         (P E
            Q A
            Sym (save (needSymb Exe (eval (car X))))
            V Sym )
         (set Q V)
         (loop
            (setq P
               (set 2 P (push NIL $Nil ZERO V NIL)) )
            (set P (link (ofs P 3)))
            (? (atom (shift X)))
            (setq
               Q (set 2 Q (push NIL NIL))
               V (save (eval (car X))) )
            (set Q V)
            (when (pair V)
               (setq V (car V)) ) )
         (when (sym? (setq V (val (tail Sym))))
            (dbFetch Exe Sym)
            (setq V (& (val (tail Sym)) -9)) )
         (set 4 (cdr E)
            (if (pair V) (car V) V) )
         (set A V) )
      (when (pair (car A))
         (loop
            (setq R (evList E))
            (? (atom (set A (cdar A))))
            (let (P (cdr E)  Q A)
               (set 4 P (car @))
               (while (pair (shift P))
                  (set 4 P
                     (cond
                        ((atom (car (shift Q))) @)
                        ((atom (set Q (cdr @))) @)
                        (T (car @)) ) ) ) ) ) )
      R ) )

# (map 'fun 'lst ..) -> lst
(de _map (Exe)
   (let
      (X (cdr Exe)
         R $Nil
         E (push NIL $Nil ZERO (eval (car X)) NIL) )
      (set E (link (ofs E 3) T))
      (let P E
         (while (pair (shift X))
            (setq P
               (set 2 P
                  (push NIL $Nil ZERO (eval (car X)) NIL) ) )
            (set P (link (ofs P 3))) ) )
      (loop
         (let P (cdr E)
            (? (atom (val 4 P)))
            (setq R (evList E))
            (loop
               (when (pair (val 4 P))
                  (set 4 P (cdr @)) )
               (? (atom (shift P))) ) ) )
      R ) )

# (mapc 'fun 'lst ..) -> lst
(de _mapc (Exe)
   (let
      (X (cdr Exe)
         R $Nil
         E (push NIL $Nil ZERO (eval (++ X)) NIL)
         A (push NIL NIL) )
      (set E (link (ofs E 3) T))
      (let (P E  Q A)
         (loop
            (let V (set Q (save (eval (car X))))
               (when (pair V)
                  (setq V (car V)) )
               (setq P
                  (set 2 P (push NIL $Nil ZERO V NIL)) )
               (set P (link (ofs P 3))) )
            (? (atom (shift X)))
            (setq Q (set 2 Q (push NIL NIL))) ) )
      (when (pair (car A))
         (loop
            (setq R (evList E))
            (? (atom (set A (cdar A))))
            (let (P (cdr E)  Q A)
               (set 4 P (car @))
               (while (pair (shift P))
                  (set 4 P
                     (cond
                        ((atom (car (shift Q))) @)
                        ((atom (set Q (cdr @))) @)
                        (T (car @)) ) ) ) ) ) )
      R ) )

# (maplist 'fun 'lst ..) -> lst
(de _maplist (Exe)
   (let
      (X (cdr Exe)
         R (save $Nil)
         L 0
         E (push NIL $Nil ZERO (eval (car X)) NIL) )
      (set E (link (ofs E 3)))
      (let P E
         (while (pair (shift X))
            (setq P
               (set 2 P
                  (push NIL $Nil ZERO (eval (car X)) NIL) ) )
            (set P (link (ofs P 3))) ) )
      (loop
         (let P (cdr E)
            (? (atom (val 4 P)))
            (let Y (cons (evList E) $Nil)
               (setq L
                  (if L
                     (set 2 L Y)
                     (setq R (safe Y)) ) ) )
            (loop
               (when (pair (val 4 P))
                  (set 4 P (cdr @)) )
               (? (atom (shift P))) ) ) )
      R ) )

# (mapcar 'fun 'lst ..) -> lst
(de _mapcar (Exe)
   (let
      (X (cdr Exe)
         R (save $Nil)
         L 0
         E (push NIL $Nil ZERO (eval (++ X)) NIL)
         A (push NIL NIL) )
      (set E (link (ofs E 3)))
      (let (P E  Q A)
         (loop
            (let V (set Q (save (eval (car X))))
               (when (pair V)
                  (setq V (car V)) )
               (setq P
                  (set 2 P (push NIL $Nil ZERO V NIL)) )
               (set P (link (ofs P 3))) )
            (? (atom (shift X)))
            (setq Q (set 2 Q (push NIL NIL))) ) )
      (when (pair (car A))
         (loop
            (let Y (cons (evList E) $Nil)
               (setq L
                  (if L
                     (set 2 L Y)
                     (setq R (safe Y)) ) ) )
            (? (atom (set A (cdar A))))
            (let (P (cdr E)  Q A)
               (set 4 P (car @))
               (while (pair (shift P))
                  (set 4 P
                     (cond
                        ((atom (car (shift Q))) @)
                        ((atom (set Q (cdr @))) @)
                        (T (car @)) ) ) ) ) ) )
      R ) )

# (mapcon 'fun 'lst ..) -> lst
(de _mapcon (Exe)
   (let
      (X (cdr Exe)
         R (save $Nil)
         L 0
         E (push NIL $Nil ZERO (eval (car X)) NIL) )
      (set E (link (ofs E 3)))
      (let P E
         (while (pair (shift X))
            (setq P
               (set 2 P
                  (push NIL $Nil ZERO (eval (car X)) NIL) ) )
            (set P (link (ofs P 3))) ) )
      (loop
         (let P (cdr E)
            (? (atom (val 4 P)))
            (let Y (evList E)
               (when (pair Y)
                  (setq L
                     (if L
                        (let Z L
                           (while (pair (cdr Z))
                              (setq Z @) )
                           (set 2 Z Y) )
                        (setq R (safe Y)) ) ) ) )
            (loop
               (when (pair (val 4 P))
                  (set 4 P (cdr @)) )
               (? (atom (shift P))) ) ) )
      R ) )

# (mapcan 'fun 'lst ..) -> lst
(de _mapcan (Exe)
   (let
      (X (cdr Exe)
         R (save $Nil)
         L 0
         E (push NIL $Nil ZERO (eval (++ X)) NIL)
         A (push NIL NIL) )
      (set E (link (ofs E 3)))
      (let (P E  Q A)
         (loop
            (let V (set Q (save (eval (car X))))
               (when (pair V)
                  (setq V (car V)) )
               (setq P
                  (set 2 P (push NIL $Nil ZERO V NIL)) )
               (set P (link (ofs P 3))) )
            (? (atom (shift X)))
            (setq Q (set 2 Q (push NIL NIL))) ) )
      (when (pair (car A))
         (loop
            (let Y (evList E)
               (when (pair Y)
                  (setq L
                     (if L
                        (let Z L
                           (while (pair (cdr Z))
                              (setq Z @) )
                           (set 2 Z Y) )
                        (setq R (safe Y)) ) ) ) )
            (? (atom (set A (cdar A))))
            (let (P (cdr E)  Q A)
               (set 4 P (car @))
               (while (pair (shift P))
                  (set 4 P
                     (cond
                        ((atom (car (shift Q))) @)
                        ((atom (set Q (cdr @))) @)
                        (T (car @)) ) ) ) ) ) )
      R ) )

# (filter 'fun 'lst ..) -> lst
(de _filter (Exe)
   (let
      (X (cdr Exe)
         R (save $Nil)
         L 0
         E (push NIL $Nil ZERO (eval (++ X)) NIL)
         A (push NIL NIL) )
      (set E (link (ofs E 3)))
      (let (P E  Q A)
         (loop
            (let V (set Q (save (eval (car X))))
               (when (pair V)
                  (setq V (car V)) )
               (setq P
                  (set 2 P (push NIL $Nil ZERO V NIL)) )
               (set P (link (ofs P 3))) )
            (? (atom (shift X)))
            (setq Q (set 2 Q (push NIL NIL))) ) )
      (when (pair (car A))
         (loop
            (unless (nil? (evList E))
               (let Y (cons (caar A) $Nil)
                  (setq L
                     (if L
                        (set 2 L Y)
                        (setq R (safe Y)) ) ) ) )
            (? (atom (set A (cdar A))))
            (let (P (cdr E)  Q A)
               (set 4 P (car @))
               (while (pair (shift P))
                  (set 4 P
                     (cond
                        ((atom (car (shift Q))) @)
                        ((atom (set Q (cdr @))) @)
                        (T (car @)) ) ) ) ) ) )
      R ) )

# (extract 'fun 'lst ..) -> lst
(de _extract (Exe)
   (let
      (X (cdr Exe)
         R (save $Nil)
         L 0
         E (push NIL $Nil ZERO (eval (++ X)) NIL)
         A (push NIL NIL) )
      (set E (link (ofs E 3)))
      (let (P E  Q A)
         (loop
            (let V (set Q (save (eval (car X))))
               (when (pair V)
                  (setq V (car V)) )
               (setq P
                  (set 2 P (push NIL $Nil ZERO V NIL)) )
               (set P (link (ofs P 3))) )
            (? (atom (shift X)))
            (setq Q (set 2 Q (push NIL NIL))) ) )
      (when (pair (car A))
         (loop
            (unless (nil? (evList E))
               (let Y (cons @ $Nil)
                  (setq L
                     (if L
                        (set 2 L Y)
                        (setq R (safe Y)) ) ) ) )
            (? (atom (set A (cdar A))))
            (let (P (cdr E)  Q A)
               (set 4 P (car @))
               (while (pair (shift P))
                  (set 4 P
                     (cond
                        ((atom (car (shift Q))) @)
                        ((atom (set Q (cdr @))) @)
                        (T (car @)) ) ) ) ) ) )
      R ) )

# (seek 'fun 'lst ..) -> lst
(de _seek (Exe)
   (let
      (X (cdr Exe)
         E (push NIL $Nil ZERO (eval (car X)) NIL) )
      (set E (link (ofs E 3) T))
      (let P E
         (while (pair (shift X))
            (setq P
               (set 2 P
                  (push NIL $Nil ZERO (eval (car X)) NIL) ) )
            (set P (link (ofs P 3))) ) )
      (loop
         (let P (cdr E)
            (? (atom (val 4 P)) $Nil)
            (? (not (nil? (evList E)))
               (set $At2 @)
               (val 4 P) )
            (loop
               (when (pair (val 4 P))
                  (set 4 P (cdr @)) )
               (? (atom (shift P))) ) ) ) ) )

# (find 'fun 'lst ..) -> any
(de _find (Exe)
   (let
      (X (cdr Exe)
         E (push NIL $Nil ZERO (eval (++ X)) NIL)
         A (push NIL NIL) )
      (set E (link (ofs E 3) T))
      (let (P E  Q A)
         (loop
            (let V (set Q (save (eval (car X))))
               (when (pair V)
                  (setq V (car V)) )
               (setq P
                  (set 2 P (push NIL $Nil ZERO V NIL)) )
               (set P (link (ofs P 3))) )
            (? (atom (shift X)))
            (setq Q (set 2 Q (push NIL NIL))) ) )
      (if (atom (car A))
         $Nil
         (loop
            (? (not (nil? (evList E)))
               (set $At2 @)
               (caar A) )
            (? (atom (set A (cdar A))) $Nil)
            (let (P (cdr E)  Q A)
               (set 4 P (car @))
               (while (pair (shift P))
                  (set 4 P
                     (cond
                        ((atom (car (shift Q))) @)
                        ((atom (set Q (cdr @))) @)
                        (T (car @)) ) ) ) ) ) ) ) )

# (pick 'fun 'lst ..) -> any
(de _pick (Exe)
   (let
      (X (cdr Exe)
         E (push NIL $Nil ZERO (eval (++ X)) NIL)
         A (push NIL NIL) )
      (set E (link (ofs E 3) T))
      (let (P E  Q A)
         (loop
            (let V (set Q (save (eval (car X))))
               (when (pair V)
                  (setq V (car V)) )
               (setq P
                  (set 2 P (push NIL $Nil ZERO V NIL)) )
               (set P (link (ofs P 3))) )
            (? (atom (shift X)))
            (setq Q (set 2 Q (push NIL NIL))) ) )
      (if (atom (car A))
         $Nil
         (loop
            (? (not (nil? (evList E))) @)
            (? (atom (set A (cdar A))) $Nil)
            (let (P (cdr E)  Q A)
               (set 4 P (car @))
               (while (pair (shift P))
                  (set 4 P
                     (cond
                        ((atom (car (shift Q))) @)
                        ((atom (set Q (cdr @))) @)
                        (T (car @)) ) ) ) ) ) ) ) )

# (fully 'fun 'lst ..) -> flg
(de _fully (Exe)
   (let
      (X (cdr Exe)
         E (push NIL $Nil ZERO (eval (++ X)) NIL)
         A (push NIL NIL) )
      (set E (link (ofs E 3) T))
      (let (P E  Q A)
         (loop
            (let V (set Q (save (eval (car X))))
               (when (pair V)
                  (setq V (car V)) )
               (setq P
                  (set 2 P (push NIL $Nil ZERO V NIL)) )
               (set P (link (ofs P 3))) )
            (? (atom (shift X)))
            (setq Q (set 2 Q (push NIL NIL))) ) )
      (if (atom (car A))
         $T
         (loop
            (? (nil? (evList E)) @)
            (? (atom (set A (cdar A))) $T)
            (let (P (cdr E)  Q A)
               (set 4 P (car @))
               (while (pair (shift P))
                  (set 4 P
                     (cond
                        ((atom (car (shift Q))) @)
                        ((atom (set Q (cdr @))) @)
                        (T (car @)) ) ) ) ) ) ) ) )

# (cnt 'fun 'lst ..) -> cnt
(de _cnt (Exe)
   (let
      (X (cdr Exe)
         R ZERO
         E (push NIL $Nil ZERO (eval (++ X)) NIL)
         A (push NIL NIL) )
      (set E (link (ofs E 3) T))
      (let (P E  Q A)
         (loop
            (let V (set Q (save (eval (car X))))
               (when (pair V)
                  (setq V (car V)) )
               (setq P
                  (set 2 P (push NIL $Nil ZERO V NIL)) )
               (set P (link (ofs P 3))) )
            (? (atom (shift X)))
            (setq Q (set 2 Q (push NIL NIL))) ) )
      (when (pair (car A))
         (loop
            (unless (nil? (evList E))
               (inc 'R (hex "10")) )  # Increment count
            (? (atom (set A (cdar A))))
            (let (P (cdr E)  Q A)
               (set 4 P (car @))
               (while (pair (shift P))
                  (set 4 P
                     (cond
                        ((atom (car (shift Q))) @)
                        ((atom (set Q (cdr @))) @)
                        (T (car @)) ) ) ) ) ) )
      R ) )

# (sum 'fun 'lst ..) -> num
(de _sum (Exe)
   (let
      (X (cdr Exe)
         R (save ZERO)
         E (push NIL $Nil ZERO (eval (++ X)) NIL)
         A (push NIL NIL) )
      (set E (link (ofs E 3)))
      (let (P E  Q A)
         (loop
            (let V (set Q (save (eval (car X))))
               (when (pair V)
                  (setq V (car V)) )
               (setq P
                  (set 2 P (push NIL $Nil ZERO V NIL)) )
               (set P (link (ofs P 3))) )
            (? (atom (shift X)))
            (setq Q (set 2 Q (push NIL NIL))) ) )
      (when (pair (car A))
         (loop
            (when (num? (evList E))
               (save @
                  (setq R (safe (adds R @))) ) )
            (? (atom (set A (cdar A))))
            (let (P (cdr E)  Q A)
               (set 4 P (car @))
               (while (pair (shift P))
                  (set 4 P
                     (cond
                        ((atom (car (shift Q))) @)
                        ((atom (set Q (cdr @))) @)
                        (T (car @)) ) ) ) ) ) )
      R ) )

# (maxi 'fun 'lst ..) -> any
(de _maxi (Exe)
   (let
      (X (cdr Exe)
         R $Nil
         R2 (save $Nil)
         E (push NIL $Nil ZERO (eval (++ X)) NIL)
         A (push NIL NIL) )
      (set E (link (ofs E 3)))
      (let (P E  Q A)
         (loop
            (let V (set Q (save (eval (car X))))
               (when (pair V)
                  (setq V (car V)) )
               (setq P
                  (set 2 P (push NIL $Nil ZERO V NIL)) )
               (set P (link (ofs P 3))) )
            (? (atom (shift X)))
            (setq Q (set 2 Q (push NIL NIL))) ) )
      (when (pair (car A))
         (loop
            (let Y (evList E)
               (when (gt0 (compare Y R2))
                  (setq R (caar A))
                  (setq R2 (safe Y)) ) )
            (? (atom (set A (cdar A))))
            (let (P (cdr E)  Q A)
               (set 4 P (car @))
               (while (pair (shift P))
                  (set 4 P
                     (cond
                        ((atom (car (shift Q))) @)
                        ((atom (set Q (cdr @))) @)
                        (T (car @)) ) ) ) ) ) )
      (set $At2 R2)
      R ) )

# (mini 'fun 'lst ..) -> any
(de _mini (Exe)
   (let
      (X (cdr Exe)
         R $Nil
         R2 (save $T)
         E (push NIL $Nil ZERO (eval (++ X)) NIL)
         A (push NIL NIL) )
      (set E (link (ofs E 3)))
      (let (P E  Q A)
         (loop
            (let V (set Q (save (eval (car X))))
               (when (pair V)
                  (setq V (car V)) )
               (setq P
                  (set 2 P (push NIL $Nil ZERO V NIL)) )
               (set P (link (ofs P 3))) )
            (? (atom (shift X)))
            (setq Q (set 2 Q (push NIL NIL))) ) )
      (when (pair (car A))
         (loop
            (let Y (evList E)
               (when (lt0 (compare Y R2))
                  (setq R (caar A))
                  (setq R2 (safe Y)) ) )
            (? (atom (set A (cdar A))))
            (let (P (cdr E)  Q A)
               (set 4 P (car @))
               (while (pair (shift P))
                  (set 4 P
                     (cond
                        ((atom (car (shift Q))) @)
                        ((atom (set Q (cdr @))) @)
                        (T (car @)) ) ) ) ) ) )
      (set $At2 R2)
      R ) )

(local) fish

(de void fish (E V P R S)
   (set P V)
   (cond
      ((nil? (evList E))
         (when (pair V)
            (stkChk 0)
            (unless (nil? (cdr V))
               (fish E @ P R S) )
            (fish E (car V) P R S) ) )
      ((<> @ S)
         (set R (cons V (val R))) ) ) )

# (fish 'fun 'any ['any2] ..) -> lst
(de _fish (Exe)
   (let
      (X (cdr Exe)
         R (link (push $Nil NIL) T)
         P (push NIL $Nil ZERO NIL)
         E (push NIL P ZERO (eval (++ X)) NIL) )
      (set
         P (ofs P 3)
         E (link (ofs E 3)) )
      (let
         (V (save (eval (++ X)))
            S (save (eval (car X)))
            Q P )
         (while (pair (shift X))
            (setq Q
               (set 2 Q
                  (push NIL $Nil ZERO (eval (car X)) NIL) ) )  # [car cdr name val link]
            (set Q (link (ofs Q 3))) )
         (fish E V (ofs P 3) R S)
         (val R) ) ) )

# (by 'fun1 'fun2 'lst ..) -> lst
(de _by (Exe)
   (let
      (X (cdr Exe)
         R (save $Nil)
         L 0
         E (push NIL $Nil ZERO (eval (++ X)) NIL)
         A (push NIL NIL)
         Fun2 (save (eval (++ X)))
         A2 A )
      (set E (link (ofs E 3)))
      (let (P E  Q A)
         (loop
            (let V (set Q (save (eval (car X))))
               (when (pair V)
                  (setq V (car V)) )
               (setq P
                  (set 2 P (push NIL $Nil ZERO V NIL)) )
               (set P (link (ofs P 3))) )
            (? (atom (shift X)))
            (setq Q (set 2 Q (push NIL NIL))) ) )
      (when (pair (car A))
         (loop
            (let Y (cons (cons (evList E) (caar A)) $Nil)
               (setq L
                  (if L
                     (set 2 L Y)
                     (setq R (safe Y)) ) ) )
            (? (atom (set A (cdar A))))
            (let (P (cdr E)  Q A)
               (set 4 P (car @))
               (while (pair (shift P))
                  (set 4 P
                     (cond
                        ((atom (car (shift Q))) @)
                        ((atom (set Q (cdr @))) @)
                        (T (car @)) ) ) ) ) )
         (set 4 E Fun2  4 (cdr E) R)
         (let Z (setq R (safe (evList E)))
            (loop
               (set Z (cdar Z))
               (? (atom (shift Z))) ) ) )
      R ) )

# Readline
(local) tabComplete

(de i8* tabComplete ((i8* . Text))
   (if (nil? (val $Complete))
      null
      (let
         (V (push NIL $Nil ZERO NIL NIL)  # [car cdr name arg link]
            E (push NIL V ZERO @ NIL) )  # [car cdr name fun link]
         (set 4 V
            (nond
               (Text $Nil)
               ((val Text) $T)
               (NIL (mkStr Text)) ) )
         (set
            V (link (ofs V 3) T)
            E (link (ofs E 3)) )
         (if (nil? (evList E))
            null
            (let Nm (name (val (tail (xSym @))))
               (strdup (bufString Nm (b8 (bufSize Nm)))) ) ) ) ) )
