# 11may20 Software Lab. Alexander Burger

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
      (let (L (val $Next)  P E)
         (while (pair X)
            (setq P
               (set 2 P
                  (push NIL $Nil ZERO (eval (++ X)) NIL) ) )
            (set P (link (ofs P 3))) )
         (while (pair L)
            (setq P
               (set 2 P (push NIL $Nil ZERO (++ L) NIL)) )
            (set P (link (ofs P 3))) )
         (evList E) ) ) )

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
         (let (P (cdr E)  S (car P))
            (? (atom (val S)))
            (setq R (evList E))
            (loop
               (when (pair (val S))
                  (set S (cdr @)) )
               (? (atom (shift P)))
               (setq S (car P)) ) ) )
      R ) )

# (mapc 'fun 'lst ..) -> lst
(de _mapc (Exe)
   (let
      (X (cdr Exe)
         R $Nil
         E (push NIL $Nil ZERO (eval (++ X)) NIL)
         A (push NIL $Nil) )
      (set E (link (ofs E 3) T))
      (let (P E  Q A  V (eval (car X)))
         (set (save A) V)
         (loop
            (when (pair V)
               (setq V (car V)) )
            (setq P
               (set 2 P (push NIL $Nil ZERO V NIL)) )
            (set P (link (ofs P 3) T))
            (? (atom (shift X)))
            (setq
               V (eval (car X))
               Q (set 2 Q (push V $Nil)) ) ) )
      (while (pair (car A))
         (setq R (evList E))
         (let (P (cdr E)  Q A)
            (set (car P) (car (set A (cdar A))))
            (while (pair (shift P))
               (let S (car P)
                  (if (pair (car (shift Q)))
                     (set S (car (set Q (cdr @))))
                     (set S @) ) ) ) ) )
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
         (let (P (cdr E)  S (car P))
            (? (atom (val S)))
            (let Y (cons (evList E) $Nil)
               (setq L
                  (if (=0 L)
                     (setq R (safe Y))
                     (set 2 L Y) ) ) )
            (loop
               (when (pair (val S))
                  (set S (cdr @)) )
               (? (atom (shift P)))
               (setq S (car P)) ) ) )
      R ) )

# (mapcar 'fun 'lst ..) -> lst
(de _mapcar (Exe)
   (let
      (X (cdr Exe)
         R (save $Nil)
         L 0
         E (push NIL $Nil ZERO (eval (++ X)) NIL)
         A (push NIL $Nil) )
      (set E (link (ofs E 3)))
      (let (P E  Q A  V (eval (car X)))
         (set (save A) V)
         (loop
            (when (pair V)
               (setq V (car V)) )
            (setq P
               (set 2 P (push NIL $Nil ZERO V NIL)) )
            (set P (link (ofs P 3)))
            (? (atom (shift X)))
            (setq
               V (eval (car X))
               Q (set 2 Q (push V $Nil)) ) ) )
      (while (pair (car A))
         (let Y (cons (evList E) $Nil)
            (setq L
               (if (=0 L)
                  (setq R (safe Y))
                  (set 2 L Y) ) ) )
         (let (P (cdr E)  Q A)
            (set (car P) (car (set A (cdar A))))
            (while (pair (shift P))
               (let S (car P)
                  (if (pair (car (shift Q)))
                     (set S (car (set Q (cdr @))))
                     (set S @) ) ) ) ) )
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
         (let (P (cdr E)  S (car P))
            (? (atom (val S)))
            (let Y (evList E)
               (when (pair Y)
                  (setq L
                     (if (=0 L)
                        (setq R (safe Y))
                        (let Z L
                           (while (pair (cdr Z))
                              (setq Z @) )
                           (set 2 Z Y) ) ) ) ) )
            (loop
               (when (pair (val S))
                  (set S (cdr @)) )
               (? (atom (shift P)))
               (setq S (car P)) ) ) )
      R ) )

# (mapcan 'fun 'lst ..) -> lst
(de _mapcan (Exe)
   (let
      (X (cdr Exe)
         R (save $Nil)
         L 0
         E (push NIL $Nil ZERO (eval (++ X)) NIL)
         A (push NIL $Nil) )
      (set E (link (ofs E 3)))
      (let (P E  Q A  V (eval (car X)))
         (set (save A) V)
         (loop
            (when (pair V)
               (setq V (car V)) )
            (setq P
               (set 2 P (push NIL $Nil ZERO V NIL)) )
            (set P (link (ofs P 3)))
            (? (atom (shift X)))
            (setq
               V (eval (car X))
               Q (set 2 Q (push V $Nil)) ) ) )
      (while (pair (car A))
         (let Y (evList E)
            (when (pair Y)
               (setq L
                  (if (=0 L)
                     (setq R (safe Y))
                     (let Z L
                        (while (pair (cdr Z))
                           (setq Z @) )
                        (set 2 Z Y) ) ) ) ) )
         (let (P (cdr E)  Q A)
            (set (car P) (car (set A (cdar A))))
            (while (pair (shift P))
               (let S (car P)
                  (if (pair (car (shift Q)))
                     (set S (car (set Q (cdr @))))
                     (set S @) ) ) ) ) )
      R ) )

# (filter 'fun 'lst ..) -> lst
(de _filter (Exe)
   (let
      (X (cdr Exe)
         R (save $Nil)
         L 0
         E (push NIL $Nil ZERO (eval (++ X)) NIL)
         A (push NIL $Nil) )
      (set E (link (ofs E 3)))
      (let (P E  Q A  V (eval (car X)))
         (set (save A) V)
         (loop
            (when (pair V)
               (setq V (car V)) )
            (setq P
               (set 2 P (push NIL $Nil ZERO V NIL)) )
            (set P (link (ofs P 3)))
            (? (atom (shift X)))
            (setq
               V (eval (car X))
               Q (set 2 Q (push V $Nil)) ) ) )
      (while (pair (car A))
         (unless (nil? (evList E))
            (let Y (cons (caar A) $Nil)
               (setq L
                  (if (=0 L)
                     (setq R (safe Y))
                     (set 2 L Y) ) ) ) )
         (let (P (cdr E)  Q A)
            (set (car P) (car (set A (cdar A))))
            (while (pair (shift P))
               (let S (car P)
                  (if (pair (car (shift Q)))
                     (set S (car (set Q (cdr @))))
                     (set S @) ) ) ) ) )
      R ) )

# (extract 'fun 'lst ..) -> lst
(de _extract (Exe)
   (let
      (X (cdr Exe)
         R (save $Nil)
         L 0
         E (push NIL $Nil ZERO (eval (++ X)) NIL)
         A (push NIL $Nil) )
      (set E (link (ofs E 3)))
      (let (P E  Q A  V (eval (car X)))
         (set (save A) V)
         (loop
            (when (pair V)
               (setq V (car V)) )
            (setq P
               (set 2 P (push NIL $Nil ZERO V NIL)) )
            (set P (link (ofs P 3)))
            (? (atom (shift X)))
            (setq
               V (eval (car X))
               Q (set 2 Q (push V $Nil)) ) ) )
      (while (pair (car A))
         (unless (nil? (evList E))
            (let Y (cons @ $Nil)
               (setq L
                  (if (=0 L)
                     (setq R (safe Y))
                     (set 2 L Y) ) ) ) )
         (let (P (cdr E)  Q A)
            (set (car P) (car (set A (cdar A))))
            (while (pair (shift P))
               (let S (car P)
                  (if (pair (car (shift Q)))
                     (set S (car (set Q (cdr @))))
                     (set S @) ) ) ) ) )
      R ) )

# (sum 'fun 'lst ..) -> num
(de _sum (Exe)
   (let
      (X (cdr Exe)
         R (save ZERO)
         E (push NIL $Nil ZERO (eval (++ X)) NIL)
         A (push NIL $Nil) )
      (set E (link (ofs E 3)))
      (let (P E  Q A  V (eval (car X)))
         (set (save A) V)
         (loop
            (when (pair V)
               (setq V (car V)) )
            (setq P
               (set 2 P (push NIL $Nil ZERO V NIL)) )
            (set P (link (ofs P 3)))
            (? (atom (shift X)))
            (setq
               V (eval (car X))
               Q (set 2 Q (push V $Nil)) ) ) )
      (while (pair (car A))
         (when (num? (evList E))
            (save @
               (setq R (safe (adds R @))) ) )
         (let (P (cdr E)  Q A)
            (set (car P) (car (set A (cdar A))))
            (while (pair (shift P))
               (let S (car P)
                  (if (pair (car (shift Q)))
                     (set S (car (set Q (cdr @))))
                     (set S @) ) ) ) ) )
      R ) )
