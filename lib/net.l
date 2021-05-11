# 11may21 Software Lab. Alexander Burger

(sysdefs "errno")
(sysdefs "networking")

(private) (ipErr A Type Sd Addr Port Var)

(de ipErr (Msg)
   (quit Msg (%@ "strErrno" 'S)) )

# (port ['T] 'cnt|(cnt . cnt) ['var]) -> cnt
(de port (A . @)
   (let
      (Type (ifn (=T A) SOCK_STREAM (setq A (next)) SOCK_DGRAM)
         Sd (%@ "socket" 'I AF_INET6 Type 0) )
      (when (lt0 Sd)
         (ipErr "IP socket") )
      (%@ "closeOnExec" NIL (cons T (up)) Sd)
      ~(as (<> *OS "OpenBSD")
         (when
            (lt0
               (%@ "setsockopt" 'I Sd IPPROTO_IPV6 IPV6_V6ONLY
                  '(NIL (4 . I) (0 . 4))
                  4 ) )
            (ipErr "IPV6_V6ONLY") ) )
      (buf Addr sockaddr_in6
         (%@ "memset" NIL Addr 0 sockaddr_in6)
         (struct (+ Addr sin6_family) NIL (`AF_INET6 . 2))
         (struct (+ Addr sin6_addr) NIL (0 . 8) (0 . 8))  # "::" (16 null-bytes)
         (let Port A
            (cond
               ((num? A)
                  (or
                     (=0 Port)
                     (ge0
                        (%@ "setsockopt" 'I Sd SOL_SOCKET SO_REUSEADDR
                           '(NIL (4 . I) (1 . 4))
                           4 ) )
                     (ipErr "SO_REUSEADDR") ) )
               ((pair A) (setq Port (car A)))
               (T (quit "Bad argument" A)) )
            (loop
               (byte (+ Addr sin6_port) (>> 8 Port))  # Put big-endian (network byte order)
               (byte (+ Addr sin6_port 1) Port)
               (T (ge0 (%@ "bind" 'I Sd Addr sockaddr_in6)))
               (when (or (atom A) (> (inc 'Port) (cdr A)))
                  (close Sd)
                  (ipErr "IP bind") ) )
            (when
               (and
                  (== Type SOCK_STREAM)
                  (lt0 (%@ "listen" 'I Sd 5)) )
               (close Sd)
               (ipErr "IP listen") )
            (let? Var (next)
               (when
                  (lt0
                     (%@ "getsockname" 'I Sd Addr
                        '(NIL (4 . I) (`sockaddr_in6 . 4)) ) )
                  (close Sd)
                  (ipErr "IP getsockname") )
               (set Var
                  (+  # Get big-endian (network byte order)
                     (>> -8 (byte (+ Addr sin6_port)))
                     (byte (+ Addr sin6_port 1)) ) ) ) ) )
      Sd ) )

# (accept 'cnt) -> cnt | NIL
(de accept (Sd)
   (let (Flg (%@ "nonBlocking" 'I Sd)  N 200)
      (buf Addr sockaddr_in6
         (loop
            (T
               (ge0
                  (%@ "accept" 'I Sd Addr
                     '(NIL (4 . I) (`sockaddr_in6 . 4)) ) )
               (let Sd2 @
                  (%@ "fcntlSetFl" 'I Sd Flg)
                  ## (%@ "fcntlSetFl" 'I Sd2 0)  # Non-Linux?
                  (buf Str INET6_ADDRSTRLEN
                     (setq *Adr
                        (%@ "inet_ntop" 'S AF_INET6 (+ Addr sin6_addr) Str INET6_ADDRSTRLEN) ) )
                  (setq *SPort
                     (+  # Get big-endian (network byte order)
                        (>> -8 (byte (+ Addr sin6_port)))
                        (byte (+ Addr sin6_port 1)) ) )
                  (%@ "initInFile" NIL Sd2 0)
                  (%@ "initOutFile" NIL Sd2)
                  Sd2 ) )
            (NIL (and (== (errno) EAGAIN) (gt0 (dec 'N)))
               (%@ "fcntlSetFl" NIL Sd Flg) )
            (%@ "usleep" NIL 99999) ) ) ) )

# (listen 'cnt1 ['cnt2]) -> cnt | NIL
(de listen (Sd Ms)
   (loop
      (NIL (wait Ms T Sd))
      (T (accept Sd) @) ) )

# (host 'any) -> sym
(de host (Node)
   (use Lst
      (when (=0 (%@ "getaddrinfo" 'I Node 0 0 '(Lst (8 . P))))
         (buf Host NI_MAXHOST
            (prog1
               (let P Lst
                  (loop
                     (T
                        (=0
                           (%@ "getnameinfo" 'I
                              (struct (+ P ai_addr) 'P)
                              (struct (+ P ai_addrlen) 'I)
                              Host
                              NI_MAXHOST
                              0
                              NI_NAMEREQD ) )
                        (struct Host 'S) )
                     (T
                        (=0 (setq P (struct (+ P ai_next) 'P))) ) ) )
               (%@ "freeaddrinfo" 'I Lst) ) ) ) ) )

(private) server

(de server (Type Node Service)
   (use Lst
      (and
         (=0
            (%@ "getaddrinfo" 'I Node (sym Service)
               (cons NIL (`addrinfo)  # hints:
                  (0 . 4)  # ai_flags
                  (`AF_UNSPEC . 4)  # ai_family
                  (cons Type 4)  # ai_socktype
                  0 )  # Clear rest
               '(Lst (8 . P)) ) )
         Lst ) ) )

# (connect 'any1 'any2) -> cnt | NIL
(de connect (Node Port)
   (let? Lst (server SOCK_STREAM Node Port)
      (prog1
         (let (P Lst  Sd)
            (loop
               (T
                  (and
                     (ge0
                        (setq Sd
                           (%@ "socket" 'I
                              (struct (+ P ai_family) 'I)
                              (struct (+ P ai_socktype) 'I)
                              0 ) ) )
                     (or
                        (=0
                           (%@ "connect" 'I Sd
                              (struct (+ P ai_addr) 'P)
                              (struct (+ P ai_addrlen) 'I) ) )
                        (nil (close Sd)) ) )
                  (%@ "closeOnExec" NIL (cons T (up)) Sd)
                  (%@ "initInFile" NIL Sd 0)
                  (%@ "initOutFile" NIL Sd)
                  Sd )
               (T
                  (=0 (setq P (struct (+ P ai_next) 'P))) ) ) )
         (%@ "freeaddrinfo" 'I Lst) ) ) )

(private) UDPMAX

(de UDPMAX . 4096)

# (udp 'cnt) -> any
# (udp 'sym 'any2 'any3) -> any
(de udp (X Port Val)
   (buf Buf UDPMAX
      (cond
         (Port
            (let? Lst (server SOCK_DGRAM X Port)
               (let (P Lst  N (plio Buf UDPMAX Val))
                  (loop
                     (T (=0 P)
                        (%@ "freeaddrinfo" 'I Lst)
                        NIL )
                     (T
                        (ge0
                           (%@ "socket" 'I
                              (struct (+ P ai_family) 'I)
                              (struct (+ P ai_socktype) 'I)
                              0 ) )
                        (%@ "sendto" 'I @ Buf N 0
                           (struct (+ P ai_addr) 'P)
                           (struct (+ P ai_addrlen) 'I) )
                        (close @)
                        (%@ "freeaddrinfo" 'I Lst)
                        Val )
                     (setq P (struct (+ P ai_next) 'P)) ) ) ) )
         ((ge0 (%@ "recv" 'N X Buf UDPMAX 0))
            (plio Buf) ) ) ) )
