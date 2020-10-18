# 18oct20 Software Lab. Alexander Burger
# Use: nice pil misc/stress.l -main -go -bye; rm db/test jnl db/test2

(load "@lib/too.l")

(class +A +Entity)
(rel key (+Key +Number))               # Key  1 .. 999
(rel dat (+Ref +Number))               # Data 1 .. 999

(de rnd ()
   (rand 1 999) )

(de modify (N)
   (do N
      (do (rand 10 40)
         (let K (rnd)
            (with (db 'key '+A K)
               (unless (= K (: key))
                  (quit "key mismatch" K) ) ) ) )
      (dbSync)
      (let (D (rnd)  X (db 'key '+A (rnd)))
         (inc *DB (- D (get X 'dat)))
         (put> X 'dat D) )
      (commit 'upd) ) )

(de verify ()
   (dbCheck)
   (let N 0
      (scan (tree 'dat '+A)
         '((K V)
            (unless (= (car K) (get V 'dat))
               (quit "dat mismatch" K) )
            (inc 'N (car K)) ) )
      (unless (= N (val *DB))
         (quit "val mismatch" (- N (val *DB))) ) ) )

(de main ()
   (seed (in "/dev/urandom" (rd 8)))
   (call "mkdir" "-p" "db")
   (call "rm" "-f" "db/test" "jnl" "db/test2")
   (pool "db/test" NIL "jnl")
   (set *DB 0)
   (for K 999
      (let D (rnd)
         (new T '(+A)  'key K  'dat D)
         (inc *DB D) ) )
   (commit) )

(de go ()
   (do 12
      (do 99
         (rand)
         (unless (fork)
            (modify 999)
            (bye) ) )
      (while (kids)
         (wait 999) )
      (rollback) )
   (verify)
   (pool "db/test2")
   (journal "jnl")
   (call "cmp" "db/test" "db/test2") )
