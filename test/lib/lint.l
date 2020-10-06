# 06oct20 Software Lab. Alexander Burger

### noLint ###
(let foo '(() (bar FreeVariable))
   (use *NoLint
      (noLint 'bar)
      (noLint 'foo 'FreeVariable)
      (test NIL (lint 'foo)) ) )


### lint ###
(let foo '((R S T R) (let N 7 (bar X Y)))
    (test '((var T) (dup R) (def bar) (bnd Y X) (use N))
       (lint 'foo) ) )

(let foo '(() (task -6000 0 X 7 (println N)))
   (test '((bnd N) (use X))
       (lint 'foo) ) )
