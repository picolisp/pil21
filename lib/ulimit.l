# 27aug25 Software Lab. Alexander Burger

(symbols 'ulimit 'pico)

(local) (RLIMIT_STACK RLIMIT_NOFILE RLIMIT_NPROC stack files nproc)
(private) (error rlimit)

(sysdefs "ulimit")

(de error ()
   (quit (%@ "strErrno" 'S) 'ulimit) )

(de rlimit (Res Val U)
   (use Lim
      (nond
         ((=0
               (%@ "getrlimit" 'I Res '(Lim (16 P P))) )
            (error) )
         (Val
            (cons
               (*/ (car Lim) U)
               (*/ (cadr Lim) U) ) )
         ((=0
               (%@ "setrlimit" 'I Res
                  (list NIL (16)
                     (cons (* Val U) 8)
                     (cons (cadr Lim) 8) ) ) )
            (error) )
         (NIL Val) ) ) )

# (ulimit~stack ['cnt))
(de stack (KiB)
   (prog1
      (rlimit RLIMIT_STACK KiB 1024)
      (%@ "ulimStk") ) )

# (ulimit~files ['cnt))
(de files (N)
   (rlimit RLIMIT_NOFILE N 1) )

# (ulimit~nproc ['cnt))
(de nproc (N)
   (rlimit RLIMIT_NPROC N 1) )
