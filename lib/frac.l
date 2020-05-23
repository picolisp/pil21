# 22may20 Software Lab. Alexander Burger

(symbols 'frac 'pico)

(local) (gcd lcm f)

(de gcd (A B)
   (until (=0 B)
      (let M (% A B)
         (setq A B B M) ) )
   (abs A) )

(de lcm (A B)
   (*/ A B (gcd A B)) )

(de f (N D)
   (and (=0 D) (quit "frac/0" N))
   (if (=0 N)
      (cons 0 1)
      (let G (gcd N D)
         (if (gt0 N)
            (cons (/ N G) (/ D G))
            (cons (- (/ N G)) (- (/ D G))) ) ) ) )

(local) (fabs 1/f f+ f- f* f/ f** fcmp)

(de fabs (A)
   (cons (abs (car A)) (cdr A)) )

(de 1/f (A)
   (and (=0 (car A)) (quit "frac/0" A))
   (if (gt0 (car A))
      (cons (cdr A) (car A))
      (cons (- (cdr A)) (- (car A))) ) )

(de f+ (A B)
   (let D (lcm (cdr A) (cdr B))
      (let N
         (+
            (* (/ D (cdr A)) (car A))
            (* (/ D (cdr B)) (car B)) )
         (if (=0 N)
            (cons 0 1)
            (let G (gcd N D)
               (cons (/ N G) (/ D G)) ) ) ) ) )

(de f- (A B)
   (if B
      (f+ A (f- B))
      (cons (- (car A)) (cdr A)) ) )

(de f* (A B)
   (let (G (gcd (car A) (cdr B))  H (gcd (car B) (cdr A)))
      (cons
         (* (/ (car A) G) (/ (car B) H))
         (* (/ (cdr A) H) (/ (cdr B) G)) ) ) )

(de f/ (A B)
   (f* A (1/f B)) )

(de f** (A N)
   (if (ge0 N)
      (cons (** (car A) N) (** (cdr A) N))
      (cons (** (cdr A) (- N)) (** (car A) (- N))) ) )

(de fcmp (A B)
   (if (gt0 (* (car A) (car B)))
      (let Q (f/ A B)
         (*
            (if (gt0 (car A)) 1 -1)
            (- (car Q) (cdr Q))) )
      (- (car A) (car B)) ) )

(local) (f< f<= f> f>=)

(de f< (A B)
   (lt0 (fcmp A B)) )

(de f<= (A B)
   (ge0 (fcmp B A)) )

(de f> (A B)
   (gt0 (fcmp A B)) )

(de f>= (A B)
   (ge0 (fcmp A B)) )
