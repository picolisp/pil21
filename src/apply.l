# 27feb20 Software Lab. Alexander Burger

(symbols '(llvm))

# (apply 'fun 'lst ['any ..]) -> any
(de _apply (Exe)
   (let
      (X (cdr Exe)
         E (save (push NIL $Nil ZERO (eval (++ X)))) )
      (set E (ofs E 3))
      (let (L (save (eval (++ X)))  P E)
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
         E (save (push NIL $Nil ZERO (eval (++ X))))
         P E )
      (set E (ofs E 3))
      (while (pair X)
         (setq P
            (set 2 P
               (push NIL $Nil ZERO (eval (++ X))) ) )
         (set P (ofs P 3)) )
      (while (pair (val (car (setq P (cdr E)))))
         (setq X (evList E))
         (loop
            (set (car P) (cdr (val (car P))))
            (? (atom (>>> P)) ) ) )
      X ) )

# (mapcar 'fun 'lst ..) -> lst
(de _mapcar (Exe)
   (let
      (X (cdr Exe)
         E (save (push NIL $Nil ZERO (eval (++ X))))
         P E )
      (set E (ofs E 3))
      (let (V (eval (++ X))  Args (save (push V $Nil))  Q Args)
         (loop
            (setq P
               (set 2 P (push NIL $Nil ZERO (car V))) )
            (set P (ofs P 3))
            (? (atom X))
            (setq
               V (eval (++ X))
               Q (set 2 Q (push V $Nil)) ) )
         (if (atom (car Args))
            $Nil
            (prog1
               (setq X (save (cons (evList E) $Nil)))
               (loop
                  (setq Q Args)
                  (loop
                     (set Q (cdr (++ Q)))
                     (? (atom Q) ) )
                  (? (atom (car Args)))
                  (setq P (cdr E)  Q Args)
                  (loop
                     (set (car P) (car (++ Q)))
                     (? (atom (>>> P))) )
                  (setq X (set 2 X (cons (evList E) $Nil))) ) ) ) ) ) )
