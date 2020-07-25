# 25jul20 Software Lab. Alexander Burger

(symbols 'net 'pico)

(local) (SOCK_STREAM SOCK_DGRAM AF_INET6 sockaddr_in6)

(const 'SOCK_STREAM)
(const 'SOCK_DGRAM)
(const 'AF_INET6)
(const 'sockaddr_in6)

(local) (ipErr)

(de ipErr (Msg)
   (quit Msg (native "@" "strErrno" 'S)) )

(export) (port udp)

# (port ['T] 'cnt|(cnt . cnt) ['var]) -> cnt
(de port (A . @)
   (let
      (Type (ifn (=T A) SOCK_STREAM (setq A (next)) SOCK_DGRAM)
         Sd (native "@" "socket" 'I AF_INET6 Type 0) )
      (when (lt0 Sd)
         (ipErr "socket") )
      (native "@" "closeOnExec" NIL (list T 'port A) Sd)
      #!
      Sd ) )

(de udp ()
   )
