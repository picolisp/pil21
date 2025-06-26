# 26jun25 Software Lab. Alexander Burger

(symbols 'ulimit 'pico)

(sysdefs "ulimit")

(local) (stack files nproc)
(private) (error rlimit)

(de error ()
   (quit (%@ "strErrno" 'S) 'ulimit) )

(de rlimit (Res Val Mul)
   (use Lim
      (nond
         ((=0
               (%@ "getrlimit" 'I Res '(Lim (16 pico~P pico~P))) )
            (error) )
         (Val (*/ (car Lim) Mul))
         ((=0
               (%@ "setrlimit" 'I Res
                  (list NIL (16)
                     (cons (* Val Mul) 8)
                     (cons (cadr Lim) 8) ) ) )
            (error) )
         (NIL Val) ) ) )

(de stack (KiB)
   (rlimit RLIMIT_STACK KiB 1024) )

(de files (N)
   (rlimit RLIMIT_NOFILE N 1) )

(de nproc (N)
   (rlimit RLIMIT_NPROC N 1) )
