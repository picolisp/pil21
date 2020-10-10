# 10oct20 Software Lab. Alexander Burger

(ifn (info "fifo/beat")
   (de heartbeat ())

   (de heartbeat @
      (out "fifo/beat"
         (pr
            (cons
               *Pid
               (+ (* 86400 (date T)) (time T) 300)  # Busy period 5 minutes
               (rest) ) ) ) )

   (task -54321 0 (heartbeat))
   (push1 '*Bye '(out "fifo/beat" (pr *Pid))) )

(de nobeat ()
   (task -54321) )
