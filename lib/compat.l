# 17jan21 Software Lab. Alexander Burger
# Some pil64 compatibility

(private) *Arg

(redef next ()
   (setq *Arg (next)) )

(redef arg (Cnt)
   (if Cnt
      (arg Cnt)
      *Arg ) )

(de ==== ()
   (let X (all '(T))
      (set X (con X)) )
   (let X (all '(T . T))
      (set X (con X)) ) )

(de pil @
   (pass pack "~/.pil/") )

(de lines @
   (let Cnt 0
      (while (args)
         (in (next)
            (while (from "\n")
               (inc 'Cnt) ) ) )
      Cnt ) )

(de tzo ()
   (-
      (+ (* 86400 (date)) (time T))
      (+ (* 86400 (date T)) (time T)) ) )

(def 'forked prog)
