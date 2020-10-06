# 06oct20 Software Lab. Alexander Burger

### Evaluation ###
(test 2
   (when 1
      ('((N) N) (and 2))
      @ ) )

### alarm ###
(let N 6
   (alarm 1 (inc 'N))
   (test 6 N)
   (wait 2000)
   (test 7 N)
   (alarm 0) )


### sigio ###
(unless (member *OS '("SunOS" "OpenBSD" "Cygwin" "AIX" "HP-UX" "IRIX64"))
   (sigio (setq "SigSock" (port T 0 "SigPort"))
      (setq "SigVal" (udp "SigSock")) )
   (udp "localhost" "SigPort" '(a b c))
   (wait 200)
   (test '(a b c) "SigVal")
   (close "SigSock") )


### kids ###
(test
   (make
      (do 7
         (link (or (fork) (wait 2000) (bye))) ) )
   (flip (kids)) )

### protect ###
(test NIL (pipe (prog (kill *Pid) (pr 7)) (rd)))
(test 7 (pipe (protect (kill *Pid) (pr 7)) (rd)))


### quit ###
(test "Quit" (catch '("Quit") (quit "Quit")))


### byte ###
(test (hex "12")
   (byte (adr (1))) )

(test "ABC"
   (let P (native "@" "malloc" 'N 8)
      (byte P (char "A"))
      (byte (inc P) (char "B"))
      (byte (+ P 2) (char "C"))
      (byte (+ P 3) 0)
      (prog1
         (native "@" "strdup" 'S P)
         (native "@" "free" NIL P) ) ) )


### adr ###
(let (X (box 7)  L (123))
   (test 7 (val (adr (adr X))))
   (test 123 (car (adr (adr L)))) )

### env ###
(setq *E (env))
(test NIL *E)

(let (A 1 B 2)
   (setq *E (env)) )
(test '((A . 1) (B . 2)) *E)

(let (A 1 B 2)
   (setq *E (env '(A B))) )
(test '((B . 2) (A . 1)) *E)

(let (A 1 B 2)
   (setq *E (env 'X 7 '(A B (C . 3)) 'Y 8)) )
(test '((Y . 8) (C . 3) (B . 2) (A . 1) (X . 7)) *E)


### trail ###
(when trail
   (let
      (F '((A B) (G (inc A) (dec B)))
         G '((X Y) (trail T)) )
      (test '(@X (F 3 4) A 3 B 4 (G (inc A) (dec B)) X 4 Y 3)
         (F 3 4) ) ) )

### up ###
(test 1
   (let N 1
      ((quote (N) (up N)) 2) ) )
(test 7
   (let N 1
      ((quote (N) (up N 7)) 2)
      N ) )


### sys ###
(test "PicoLisp" (sys "TEST" "PicoLisp"))
(test "PicoLisp" (sys "TEST"))


### args next arg rest ####
(test '(T 1 3 (2 3 4))
   (let foo '(@ (list (args) (next) (arg 2) (rest)))
      (foo 1 2 3 4) ) )

(test (7 NIL)
   ((quote @ (list (next) (next))) 7) )


### usec ###
(let U (usec)
   (wait 400)
   (test 4 (*/ (- (usec) U) 100000)) )


### pwd ###
(test *PWD (pwd))


### cd ###
(chdir "/"
   (test "/" (pwd)) )


### info ###
(test '(T . @) (info "@test"))
(test (5 . @)
   (out (tmp "info") (prinl "info"))
   (info (tmp "info")) )


### file ###
(test (cons (tmp) "file" 1)
   (out (tmp "file") (println '(file)))
   (load (tmp "file")) )


### dir ###
(call "mkdir" "-p" (tmp "dir"))
(out (tmp "dir/.abc"))
(out (tmp "dir/a"))
(out (tmp "dir/b"))
(out (tmp "dir/c"))

(test '("a" "b" "c") (sort (dir (tmp "dir"))))
(test '("." ".." ".abc" "a" "b" "c") (sort (dir (tmp "dir") T)))


### cmd ###
(cmd "test")
(test "test" (cmd))


### argv ###
(test '("abc" "123")
   (pipe
      (call *CMD "-prog (println (argv)) (bye)" "abc" 123)
      (read) ) )
(test '("abc" "123")
   (pipe
      (call *CMD "-prog (argv A B) (println (list A B)) (bye)" "abc" 123)
      (read) ) )


### opt ###
(test '("abc" "123")
   (pipe
      (call *CMD "-prog (println (list (opt) (opt))) (bye)" "abc" 123)
      (read) ) )
(test "abc"
   (pipe
      (call *CMD "-de f () (println (opt))" "-f" "abc" "-bye")
      (read) ) )


### date time ###
(use (Dat1 Tim1 Dat2 Tim2 D1 T1 D2 T2)
   (until
      (=
         (setq Dat1 (date)  Tim1 (time T))
         (prog
            (setq
               Dat2 (date T)
               Tim2 (time T)
               D1 (in '(date "+%Y %m %d") (list (read) (read) (read)))
               T1 (in '(date "+%H %M %S") (list (read) (read) (read)))
               D2 (in '(date "-u" "+%Y %m %d") (list (read) (read) (read)))
               T2 (in '(date "-u" "+%H %M %S") (list (read) (read) (read))) )
            (time) ) ) )
   (test Tim1 (time T1))
   (test Tim1 (apply time T1))
   (test Tim2 (time T2))
   (test Dat1 (date D1))
   (test Dat1 (apply date D1))
   (test Dat2 (date D2)) )

(test (2000 7 15) (date 730622))
(test 730622 (date 2000 7 15))
(test 730622 (date (2000 7 15)))
(test NIL (date NIL))

(test (11 17 23) (time 40643))
(test 40643 (time 11 17 23))
(test 40643 (time (11 17 23)))
(test NIL (time NIL))
