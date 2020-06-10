# 10jun20 Software Lab. Alexander Burger

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
               (set 2 P (push NIL $Nil ZERO (cdr L) NIL)) )
            (set P (link (ofs P 3)))
            (setq L (car L)) )
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
      (while (pair (car A))
         (setq R (evList E))
         (let (P (cdr E)  Q A)
            (set 4 P (car (set A (cdar A))))
            (while (pair (shift P))
               (if (pair (car (shift Q)))
                  (set 4 P (car (set Q (cdr @))))
                  (set 4 P @) ) ) ) )
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
                  (if (=0 L)
                     (setq R (safe Y))
                     (set 2 L Y) ) ) )
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
      (while (pair (car A))
         (let Y (cons (evList E) $Nil)
            (setq L
               (if (=0 L)
                  (setq R (safe Y))
                  (set 2 L Y) ) ) )
         (let (P (cdr E)  Q A)
            (set 4 P (car (set Q (cdar Q))))
            (while (pair (shift P))
               (if (pair (car (shift Q)))
                  (set 4 P (car (set Q (cdr @))))
                  (set 4 P @) ) ) ) )
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
                     (if (=0 L)
                        (setq R (safe Y))
                        (let Z L
                           (while (pair (cdr Z))
                              (setq Z @) )
                           (set 2 Z Y) ) ) ) ) )
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
            (set 4 P (car (set A (cdar A))))
            (while (pair (shift P))
               (if (pair (car (shift Q)))
                  (set 4 P (car (set Q (cdr @))))
                  (set 4 P @) ) ) ) )
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
      (while (pair (car A))
         (unless (nil? (evList E))
            (let Y (cons (caar A) $Nil)
               (setq L
                  (if (=0 L)
                     (setq R (safe Y))
                     (set 2 L Y) ) ) ) )
         (let (P (cdr E)  Q A)
            (set 4 P (car (set A (cdar A))))
            (while (pair (shift P))
               (if (pair (car (shift Q)))
                  (set 4 P (car (set Q (cdr @))))
                  (set 4 P @) ) ) ) )
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
      (while (pair (car A))
         (unless (nil? (evList E))
            (let Y (cons @ $Nil)
               (setq L
                  (if (=0 L)
                     (setq R (safe Y))
                     (set 2 L Y) ) ) ) )
         (let (P (cdr E)  Q A)
            (set 4 P (car (set A (cdar A))))
            (while (pair (shift P))
               (if (pair (car (shift Q)))
                  (set 4 P (car (set Q (cdr @))))
                  (set 4 P @) ) ) ) )
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
            (? (atom (val 4 P)))
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
      (loop
         (? (atom (car A)) $Nil)
         (? (not (nil? (evList E)))
            (set $At2 @)
            (caar A) )
         (let (P (cdr E)  Q A)
            (set 4 P (car (set A (cdar A))))
            (while (pair (shift P))
               (if (pair (car (shift Q)))
                  (set 4 P (car (set Q (cdr @))))
                  (set 4 P @) ) ) ) ) ) )

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
      (loop
         (? (atom (car A)) $Nil)
         (? (not (nil? (evList E))) @)
         (let (P (cdr E)  Q A)
            (set 4 P (car (set A (cdar A))))
            (while (pair (shift P))
               (if (pair (car (shift Q)))
                  (set 4 P (car (set Q (cdr @))))
                  (set 4 P @) ) ) ) ) ) )

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
      (loop
         (? (atom (car A)) $T)
         (? (nil? (evList E)) @)
         (let (P (cdr E)  Q A)
            (set 4 P (car (set A (cdar A))))
            (while (pair (shift P))
               (if (pair (car (shift Q)))
                  (set 4 P (car (set Q (cdr @))))
                  (set 4 P @) ) ) ) ) ) )

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
      (while (pair (car A))
         (when (num? (evList E))
            (save @
               (setq R (safe (adds R @))) ) )
         (let (P (cdr E)  Q A)
            (set 4 P (car (set A (cdar A))))
            (while (pair (shift P))
               (if (pair (car (shift Q)))
                  (set 4 P (car (set Q (cdr @))))
                  (set 4 P @) ) ) ) )
      R ) )

(local) fish

(de void fish (E V P R)
   (set P V)
   (nond
      ((nil? (evList E))
         (set R (cons V (val R))) )
      ((atom V)
         (unless (nil? (cdr V))
            (fish E @ P R) )
         (fish E (car V) P R) ) ) )

# (fish 'fun 'any) -> lst
(de _fish (Exe)
   (let
      (X (cdr Exe)
         R (link (push $Nil NIL) T)
         E (push NIL $Nil ZERO (eval (++ X)) NIL) )
      (set E (link (ofs E 3)))
      (let
         (V (eval (car X))
            P (push NIL $Nil ZERO NIL NIL) )
         (set 2 E P  P (link (ofs P 3)))
         (fish E V (ofs P 3) R)
         (val R) ) ) )

(local) tabComplete

(de i8* tabComplete ((i8* . Text))
   (if (nil? (val $Tab))
      null
      (let
         (E (push NIL NIL ZERO @ NIL)  # [car cdr name fun link]
            P (push NIL $Nil ZERO NIL NIL) )
         (set
            E (link (ofs E 3) T)
            2 E P
            P (link (ofs P 3))
            4 P
            (cond
               ((=0 Text) $Nil)
               ((=0 (val Text)) $T)
               (T (mkStr Text)) ) )
         (if (nil? (evList E))
            null
            (let Nm (name (val (tail (xSym @))))
               (strdup (bufString Nm (b8 (bufSize Nm)))) ) ) ) ) )
