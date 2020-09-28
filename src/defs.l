# 28sep20 Software Lab. Alexander Burger

(symbols '(llvm))

# Constants
(local) (HEAP CELLS STACK TOP BUFSIZ DB1)

(equ
   HEAP (*/ 1024 1024 8)      # Heap size (number of pointers)
   CELLS (/ HEAP 2)           # Number of cells in a heap (65536)
   STACK (* 64 1024)          # Default coroutine stack size (64 kB)
   TOP (hex "110000")         # Character top
   BUFSIZ 4096                # I/O buffer size
   DB1 (hex "1A")             # Name of '{1}'
   292MY (dec (** 2 63)) )    # 292 million years

# PLIO Tokens
(local) (NIX BEG DOT END NUMBER INTERN TRANSIENT EXTERN)

(equ
   NIX 0        # NIL
   BEG 1        # Begin list
   DOT 2        # Dotted pair
   END 3        # End list
   NUMBER 0     # Number
   INTERN 1     # Internal symbol
   TRANSIENT 2  # Transient symbol
   EXTERN 3 )   # External symbol

# DB-I/O
(local) (BLK BLKSIZE BLKMASK BLKTAG)

(equ
   BLK 6        # Block address size
   BLKSIZE 64   # DB block unit size
   BLKMASK -64  # Block address mask
   BLKTAG 63 )  # Block tag mask

## Sync src/lib.c 'gSignal' and src/glob.l '$Signal'
(local) (SIGHUP SIGINT SIGUSR1 SIGUSR2 SIGPIPE SIGALRM SIGTERM SIGCHLD SIGCONT
SIGSTOP SIGTSTP SIGTTIN SIGTTOU SIGWINCH SIGIO)

(equ
   SIGHUP    1
   SIGINT    2
   SIGUSR1   3
   SIGUSR2   4
   SIGPIPE   5
   SIGALRM   6
   SIGTERM   7
   SIGCHLD   8
   SIGCONT   9
   SIGSTOP  10
   SIGTSTP  11
   SIGTTIN  12
   SIGTTOU  13
   SIGWINCH 14
   SIGIO    15 )

## Sync src/lib.c 'gErrno'
(local) (ENOENT EINTR EBADF EAGAIN EACCES EPIPE ECONNRESET)

(equ
   ENOENT     1      # No such file or directory
   EINTR      2      # Interrupted system call
   EBADF      3      # Bad file number
   EAGAIN     4      # Try again
   EACCES     5      # Permission denied
   EPIPE      6      # Broken pipe
   ECONNRESET 7 )    # Connection reset by peer
