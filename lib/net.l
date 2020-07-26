# 26jul20 Software Lab. Alexander Burger

(symbols 'net 'pico)

(local) (SOCK_STREAM SOCK_DGRAM AF_INET6 IPPROTO_IPV6 IPV6_V6ONLY sockaddr_in6
sin6_family sin6_addr sin6_port)

(mapc const
   (quote
      SOCK_STREAM SOCK_DGRAM AF_INET6 IPPROTO_IPV6 IPV6_V6ONLY
      sockaddr_in6 sin6_family sin6_addr sin6_port ) )

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
      (native "@" "closeOnExec" NIL (cons T (up)) Sd)
      (when
         (lt0
            (native "@" "setsockopt" 'I  #? OpenBSD
               Sd
               IPPROTO_IPV6
               IPV6_V6ONLY
               '(NIL (4 . I) . 0)
               4 ) )
         (ipErr "IPV6_V6ONLY") )
      (buf Addr sockaddr_in6
         (native "@" "memset" NIL Addr 0 sockaddr_in6)
         (struct (+ Addr sin6_family) NIL `(- AF_INET6))
         (struct (+ Addr sin6_addr) NIL (0 . 8) (0 . 8))  # "::" (16 null-bytes)
         #!
         )
      Sd ) )

(de udp ()
   )
