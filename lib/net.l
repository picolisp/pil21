# 27jul20 Software Lab. Alexander Burger

(symbols 'net 'pico)

(export) (port udp)

(local) (SOCK_STREAM SOCK_DGRAM AF_INET6 SOL_SOCKET SO_REUSEADDR IPPROTO_IPV6
IPV6_V6ONLY INET6_ADDRSTRLEN sockaddr_in6 sin6_family sin6_addr sin6_port
NI_MAXHOST NI_NAMEREQD)

(sysdefs "Networking")

(local) ipErr

(de ipErr (Msg)
   (quit Msg (native "@" "strErrno" 'S)) )

(private) (A Type Sd Addr Port Var)

# (port ['T] 'cnt|(cnt . cnt) ['var]) -> cnt
(de port (A . @)
   (let
      (Type (ifn (=T A) SOCK_STREAM (setq A (next)) SOCK_DGRAM)
         Sd (native "@" "socket" 'I AF_INET6 Type 0) )
      (when (lt0 Sd)
         (ipErr "IP socket") )
      (native "@" "closeOnExec" NIL (cons T (up)) Sd)
      (when
         (lt0
            (native "@" "setsockopt" 'I  #? OpenBSD
               Sd
               IPPROTO_IPV6
               IPV6_V6ONLY
               '(NIL (4 . I) (0 . 4))
               4 ) )
         (ipErr "IPV6_V6ONLY") )
      (buf Addr sockaddr_in6
         (native "@" "memset" NIL Addr 0 sockaddr_in6)
         (struct (+ Addr sin6_family) NIL (`AF_INET6 . 2))
         (struct (+ Addr sin6_addr) NIL (0 . 8) (0 . 8))  # "::" (16 null-bytes)
         (let Port A
            (cond
               ((num? A)
                  (or
                     (=0 Port)
                     (ge0
                        (native "@" "setsockopt" 'I  #? OpenBSD
                           Sd
                           SOL_SOCKET
                           SO_REUSEADDR
                           '(NIL (4 . I) (1 . 4))
                           4 ) )
                     (ipErr "SO_REUSEADDR") ) )
               ((pair A) (setq Port (car A)))
               (T (quit "Bad argument" A)) )
            (loop
               (byte (+ Addr sin6_port) (>> 8 Port))  # Put big-endian (network byte order)
               (byte (+ Addr sin6_port 1) Port)
               (T (ge0 (native "@" "bind" 'I Sd Addr sockaddr_in6)))
               (when (or (atom A) (> (inc 'Port) (cdr A)))
                  (close Sd)
                  (ipErr "IP bind") ) )
            (when
               (and
                  (== Type SOCK_STREAM)
                  (lt0 (native "@" "listen" 'I Sd 5)) )
               (close Sd)
               (ipErr "IP listen") )
            (let? Var (next)
               (when
                  (lt0
                     (native "@" "getsockname" 'I
                        Sd
                        Addr
                        '(NIL (4 . I) (`sockaddr_in6 . 4)) ) )
                  (close Sd)
                  (ipErr "IP getsockname") )
               (set Var
                  (+  # Get big-endian (network byte order)
                     (>> -8 (byte (+ Addr sin6_port)))
                     (byte (+ Addr sin6_port 1)) ) ) ) ) )
      Sd ) )

(local) server

(de server(Type Node Service)
   #!
   )

# (udp 'cnt) -> any
# (udp 'sym 'any2 'any3) -> any
(de udp (X Port Val)
   (buf P 4096
      (ifn Port
         (when (ge0 (native "@" "recv" 'N X P 4096 0))
            (plio P) )
         #!
         ]
