# 06oct20 Software Lab. Alexander Burger

### port listen connect ###
(test '(a b c)
   (let P (port 0 "ListenPort")
      (unless (fork)
         (close P)
         (until (connect "localhost" "ListenPort")
            (wait 80) )
         (out @ (pr '(a b c)))
         (bye) )
      (prog1
         (in (listen P) (rd))
         (close P) ) ) )


### udp ###
(test '(a b c)
   (let P (port T 0 "UdpPort")
      (if (fork)
         (udp P)
         (close P)
         (wait 400)
         (udp "localhost" "UdpPort" '(a b c))
         (bye) ) ) )
