# 19may21 Software Lab. Alexander Burger

(de clang (Nm L . Lst)
   (out (tmp Nm ".c") (here "/**/"))
   (apply call L "clang" "-o" (tmp Nm)
      "-fPIC" "-O" "-w" "-shared" (tmp Nm ".c"))
   (for L Lst
      (def (car L)
         (list
            (cadr L)
            (cons 'native (tmp Nm) (name (caddr L)) (cdddr L)) ) )
      (when (== '@ (fin (cadr L)))
         (push (cdaar L) 'pass) ) ) )
