# 06may20 Software Lab. Alexander Burger

(symbols '(llvm))

# (apply 'fun 'lst ['any ..]) -> any
(de _apply (Exe)
   (let
      (X (cdr Exe)
         E (save (push NIL $Nil ZERO (eval (++ X)))) )
      (set E (ofs E 3))
      (let (L (save (eval (car X)))  P E)
         (while (pair (shift X))
            (setq P
               (set 2 P
                  (push NIL $Nil ZERO (eval (car X))) ) )
            (set P (ofs P 3)) )
         (while (pair L)
            (setq P
               (set 2 P (push NIL $Nil ZERO (++ L))) )
            (set P (ofs P 3)) )
         (evList E) ) ) )

# (pass 'fun ['any ..]) -> any
(de _pass (Exe)
   (let
      (X (cdr Exe)
         E (save (push NIL $Nil ZERO (eval (++ X)))) )
      (set E (ofs E 3))
      (let (L (val $Next)  P E)
         (while (pair X)
            (setq P
               (set 2 P
                  (push NIL $Nil ZERO (eval (++ X))) ) )
            (set P (ofs P 3)) )
         (while (pair L)
            (setq P
               (set 2 P (push NIL $Nil ZERO (++ L))) )
            (set P (ofs P 3)) )
         (evList E) ) ) )

# (map 'fun 'lst ..) -> lst
(de _map (Exe)
   (let
      (X (cdr Exe)
         E (save (push NIL $Nil ZERO (eval (car X)))) )
      (set E (ofs E 3))
      (let P E
         (while (pair (shift X))
            (setq P
               (set 2 P
                  (push NIL $Nil ZERO (eval (car X))) ) )
            (set P (ofs P 3)) ) )
      (let R $Nil
         (loop
            (let (P (cdr E)  S (car P))
               (? (atom (val S)))
               (setq R (evList E))
               (loop
                  (when (pair (val S))
                     (set S (cdr @)) )
                  (? (atom (shift P)))
                  (setq S (car P)) ) ) )
         R ) ) )

# (mapc 'fun 'lst ..) -> lst
(de _mapc (Exe)
   (let
      (X (cdr Exe)
         E (save (push NIL $Nil ZERO (eval (++ X))))
         A (push NIL $Nil) )
      (set E (ofs E 3))
      (let (P E  Q A  V (eval (car X)))
         (set (save A) V)
         (loop
            (when (pair V)
               (setq V (car V)) )
            (setq P
               (set 2 P (push NIL $Nil ZERO V)) )
            (set P (ofs P 3))
            (? (atom (shift X)))
            (setq
               V (eval (car X))
               Q (set 2 Q (push V $Nil)) ) ) )
      (let R $Nil
         (while (pair (car A))
            (setq R (evList E))
            (let (P (cdr E)  Q A)
               (set (car P) (car (set A (cdar A))))
               (while (pair (shift P))
                  (let S (car P)
                     (if (pair (car (shift Q)))
                        (set S (car (set Q (cdr @))))
                        (set S @) ) ) ) ) )
         R ) ) )

# (maplist 'fun 'lst ..) -> lst
(de _maplist (Exe)
   (let
      (X (cdr Exe)
         E (save (push NIL $Nil ZERO (eval (car X)))) )
      (set E (ofs E 3))
      (let P E
         (while (pair (shift X))
            (setq P
               (set 2 P
                  (push NIL $Nil ZERO (eval (car X))) ) )
            (set P (ofs P 3)) ) )
      (let R (link (push $Nil NIL 0))
         (loop
            (let (P (cdr E)  S (car P))
               (? (atom (val S)))
               (let Y (cons (evList E) $Nil)
                  (set 3 R
                     (if (=0 (val 3 R))
                        (set R Y)
                        (set 2 @ Y) ) ) )
               (loop
                  (when (pair (val S))
                     (set S (cdr @)) )
                  (? (atom (shift P)))
                  (setq S (car P)) ) ) )
         (val R) ) ) )

# (mapcar 'fun 'lst ..) -> lst
(de _mapcar (Exe)
   (let
      (X (cdr Exe)
         E (save (push NIL $Nil ZERO (eval (++ X))))
         A (push NIL $Nil) )
      (set E (ofs E 3))
      (let (P E  Q A  V (eval (car X)))
         (set (save A) V)
         (loop
            (when (pair V)
               (setq V (car V)) )
            (setq P
               (set 2 P (push NIL $Nil ZERO V)) )
            (set P (ofs P 3))
            (? (atom (shift X)))
            (setq
               V (eval (car X))
               Q (set 2 Q (push V $Nil)) ) ) )
      (let R (link (push $Nil NIL 0))
         (while (pair (car A))
            (let Y (cons (evList E) $Nil)
               (set 3 R
                  (if (=0 (val 3 R))
                     (set R Y)
                     (set 2 @ Y) ) ) )
            (let (P (cdr E)  Q A)
               (set (car P) (car (set A (cdar A))))
               (while (pair (shift P))
                  (let S (car P)
                     (if (pair (car (shift Q)))
                        (set S (car (set Q (cdr @))))
                        (set S @) ) ) ) ) )
         (val R) ) ) )

# (mapcon 'fun 'lst ..) -> lst
(de _mapcon (Exe)
   (let
      (X (cdr Exe)
         E (save (push NIL $Nil ZERO (eval (car X)))) )
      (set E (ofs E 3))
      (let P E
         (while (pair (shift X))
            (setq P
               (set 2 P
                  (push NIL $Nil ZERO (eval (car X))) ) )
            (set P (ofs P 3)) ) )
      (let R (link (push $Nil NIL 0))
         (loop
            (let (P (cdr E)  S (car P))
               (? (atom (val S)))
               (let Y (evList E)
                  (when (pair Y)
                     (set 3 R
                        (if (=0 (val 3 R))
                           (set R Y)
                           (let Z @
                              (while (pair (cdr Z))
                                 (setq Z @) )
                              (set 2 Z Y) ) ) ) ) )
               (loop
                  (when (pair (val S))
                     (set S (cdr @)) )
                  (? (atom (shift P)))
                  (setq S (car P)) ) ) )
         (val R) ) ) )

# (mapcan 'fun 'lst ..) -> lst
(de _mapcan (Exe)
   (let
      (X (cdr Exe)
         E (save (push NIL $Nil ZERO (eval (++ X))))
         A (push NIL $Nil) )
      (set E (ofs E 3))
      (let (P E  Q A  V (eval (car X)))
         (set (save A) V)
         (loop
            (when (pair V)
               (setq V (car V)) )
            (setq P
               (set 2 P (push NIL $Nil ZERO V)) )
            (set P (ofs P 3))
            (? (atom (shift X)))
            (setq
               V (eval (car X))
               Q (set 2 Q (push V $Nil)) ) ) )
      (let R (link (push $Nil NIL 0))
         (while (pair (car A))
            (let Y (evList E)
               (when (pair Y)
                  (set 3 R
                     (if (=0 (val 3 R))
                        (set R Y)
                        (let Z @
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
         (val R) ) ) )

# (filter 'fun 'lst ..) -> lst
(de _filter (Exe)
   (let
      (X (cdr Exe)
         E (save (push NIL $Nil ZERO (eval (++ X))))
         A (push NIL $Nil) )
      (set E (ofs E 3))
      (let (P E  Q A  V (eval (car X)))
         (set (save A) V)
         (loop
            (when (pair V)
               (setq V (car V)) )
            (setq P
               (set 2 P (push NIL $Nil ZERO V)) )
            (set P (ofs P 3))
            (? (atom (shift X)))
            (setq
               V (eval (car X))
               Q (set 2 Q (push V $Nil)) ) ) )
      (let R (link (push $Nil NIL 0))
         (while (pair (car A))
            (unless (nil? (evList E))
               (let Y (cons (caar A) $Nil)
                  (set 3 R
                     (if (=0 (val 3 R))
                        (set R Y)
                        (set 2 @ Y) ) ) ) )
            (let (P (cdr E)  Q A)
               (set (car P) (car (set A (cdar A))))
               (while (pair (shift P))
                  (let S (car P)
                     (if (pair (car (shift Q)))
                        (set S (car (set Q (cdr @))))
                        (set S @) ) ) ) ) )
         (val R) ) ) )

# (extract 'fun 'lst ..) -> lst
(de _extract (Exe)
   (let
      (X (cdr Exe)
         E (save (push NIL $Nil ZERO (eval (++ X))))
         A (push NIL $Nil) )
      (set E (ofs E 3))
      (let (P E  Q A  V (eval (car X)))
         (set (save A) V)
         (loop
            (when (pair V)
               (setq V (car V)) )
            (setq P
               (set 2 P (push NIL $Nil ZERO V)) )
            (set P (ofs P 3))
            (? (atom (shift X)))
            (setq
               V (eval (car X))
               Q (set 2 Q (push V $Nil)) ) ) )
      (let R (link (push $Nil NIL 0))
         (while (pair (car A))
            (unless (nil? (evList E))
               (let Y (cons @ $Nil)
                  (set 3 R
                     (if (=0 (val 3 R))
                        (set R Y)
                        (set 2 @ Y) ) ) ) )
            (let (P (cdr E)  Q A)
               (set (car P) (car (set A (cdar A))))
               (while (pair (shift P))
                  (let S (car P)
                     (if (pair (car (shift Q)))
                        (set S (car (set Q (cdr @))))
                        (set S @) ) ) ) ) )
         (val R) ) ) )
