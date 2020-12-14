# 14dec20 Software Lab. Alexander Burger

### quote ###
(test (1 2 3) (quote 1 2 3))


### as ###
(test NIL (as (= 3 4) A B C))
(test '(A B C) (as (= 3 3) A B C))


### lit ###
(test 123 (lit 123))
(test NIL (lit NIL))
(test T (lit T))
(test (1) (lit '(1)))
(test ''"abc" (lit "abc"))
(test ''a (lit 'a))
(test (1 2 3) (lit '(1 2 3)))
(test ''(a b c) (lit '(a b c)))


### eval ###
(test 6 (eval (list '+ 1 2 3)))
(let (X 'Y  Y 7)
   (test 7 (eval X)) )
(when 3
   ((quote (N)
         (when 2
            (test 1 N)
            (test 2 (eval '@ 1))
            (test 3 (eval '@ 2)) ) )
      1 ) )


### run ###
(test 6 (run (list (list '+ 1 2 3))))
(test 5
   (when 2
      ((quote (N)
            (and 1 (run '((+ N @)) 1)) )
         3 ) ) )


### def ###
(test '"a"
   (def '"a" '((X Y) (* X (+ X Y)))) )
(test '((X Y) (* X (+ X Y)))
   "a" )


### de ###
(test '"b"
   (de "b" (X Y) (* X (+ X Y))) )
(test '((X Y) (* X (+ X Y)))
   "b" )


### dm ###
(off "+Cls" "+A")
(class "+Cls" "+A")

(test '"foo>"
   (dm "foo>" (X Y)
      (* X (+ X Y)) ) )
(test '"foo>"
   (dm ("foo>" . "+Cls") (X Y)
      (* X (+ X Y)) ) )
(test '(("foo>" (X Y) (* X (+ X Y))) "+A")
   "+Cls" )


### box ###
(let X (box '(A B C))
   (test X (box? X))
   (test '(A B C) (val X)) )


### new type isa method meth send try ###
(let X (new '("+Cls"))
   (test X (box? X))
   (test 21 ("foo>" X 3 4))
   (test '("+Cls") (type X))
   (test X (isa '"+Cls" X))
   (test NIL (isa '(A B C) X))
   (test '((X Y) (* X (+ X Y)))
      (method '"foo>" X) )
   (test meth "foo>")
   (test 21 (send '"foo>" X 3 4))
   (test NIL (try '"bar>" X))
   (test 21 (try '"foo>" X 3 4)) )


### super ###
(off "+Sub")
(class "+Sub" "+Cls")

(dm ("foo>" . "+Sub") (X Y)
   (super X Y) )
(let X (new '("+Sub"))
   (test 21 ("foo>" X 3 4)) )


### super ###
(off "+Pref")
(class "+Pref")

(dm ("foo>" . "+Pref") (X Y)
   (extra X Y) )
(let X (new '("+Pref" "+Sub"))
   (test 21 ("foo>" X 3 4)) )


### with ###
(let X (box)
   (put X 'a 1)
   (put X 'b 2)
   (test (1 2)
      (with X (list (: a) (: b))) ) )


### bind ###
(let X 123
   (test "Hello"
      (bind 'X
         (setq X "Hello")
         X ) )
   (test (3 4 12)
      (bind '((X . 3) (Y . 4))
         (list X Y (* X Y)) ) ) )


### job ###
(off "tst")

(de "tst" ()
   (job '((A . 0) (B . 0))
      (cons (inc 'A) (inc 'B 2)) ) )

(test (1 . 2) ("tst"))
(test (2 . 4) ("tst"))
(test (3 . 6) ("tst"))


### let let? use ###
(let N 1
   (test NIL (let? N NIL N))
   (test 7 (let? N 7 N))
   (use N
      (setq N 2)
      (let N 3
         (test 3 N) )
      (test 2 N) )
   (test 1 N) )
(let N 1
   (use (N)
      (setq N 2)
      (let (N 3)
         (test 3 N) )
      (test 2 N) )
   (test 1 N) )

(test (1 2 (3) 4)
   (let (A 1  (B . C) (2 3)  D 4)
      (list A B C D) ) )
(test (1 (2 3) 4 (7 8 9))
   (let (((A . B) (C) . D) '((1 2 3) (4 5 6) 7 8 9))
      (list A B C D) ) )
(test (1 8)
   (let (((A . NIL) NIL NIL D) '((1 2 3) (4 5 6) 7 8 9))
      (list A D) ) )

### and ###
(test 7 (and T 123 7))
(test NIL (and NIL 123))


### or ###
(test NIL (or NIL))
(test 7 (or NIL 7 123))


### nand ###
(test NIL (nand T 123 7))
(test T (nand NIL 123))


### nor ###
(test T (nor NIL))
(test NIL (nor NIL 7 123))


### xor ###
(test T (xor T NIL))
(test T (xor NIL T))
(test NIL (xor NIL NIL))
(test NIL (xor T T))


### bool ###
(test T (bool 'a))
(test T (bool 123))
(test NIL (bool NIL))


### not ###
(test T (not NIL))
(test NIL (not T))
(test NIL (not 'a))


### nil ###
(test NIL (nil (+ 1 2 3)))


### t ###
(test T (t (+ 1 2 3)))


### prog ###
(let N 7
   (test 3
      (prog (dec 'N) (dec 'N) (dec 'N) (dec 'N) N) ) )


### prog1 prog2 ###
(test 1 (prog1 1 2 3))
(test 2 (prog2 1 2 3))


### if ###
(test 1 (if (= 3 3) 1 2))
(test 2 (if (= 3 4) 1 2))


### if2 ###
(test 'both
   (if2 T T 'both 'first 'second 'none) )
(test 'first
   (if2 T NIL 'both 'first 'second 'none) )
(test 'second
   (if2 NIL T 'both 'first 'second 'none) )
(test 'none
   (if2 NIL NIL 'both 'first 'second 'none) )
(test 4 (if2 3 4 @))
(test 7 (and 7 (if2 @ @ @)))
(test 7 (and 7 (if2 @ NIL 1 @)))
(test 7 (and 7 (if2 NIL @ 1 2 @)))


### ifn ###
(test 2 (ifn (= 3 3) 1 2))
(test 1 (ifn (= 3 4) 1 2))


### when ###
(test 7 (when (= 3 3) 7))
(test NIL (when (= 3 4) 7))


### unless ###
(test NIL (unless (= 3 3) 7))
(test 7 (unless (= 3 4) 7))


### cond ###
(test 1 (cond ((= 3 3) 1) (T 2)))
(test 2 (cond ((= 3 4) 1) (T 2)))


### nond ###
(test 2 (nond ((= 3 3) 1) (NIL 2)))
(test 1 (nond ((= 3 4) 1) (NIL 2)))
(test (1 . a)
   (nond ((num? 'a) (cons 1 'a)) (NIL (cons 2 @))) )
(test (2 . 7)
   (nond ((num? 7) (cons 1 7)) (NIL (cons 2 @))) )


### case ###
(test 1 (case 'a (a 1) ((b c) 2) (T 3)))
(test 2 (case 'b (a 1) ((b c) 2) (T 3)))
(test 2 (case '"b" (a 1) ((b c) 2) (T 3)))
(test 2 (case 'c (a 1) ((b c) 2) (T 3)))
(test 2 (case "c" (a 1) ((b c) 2) (T 3)))
(test 3 (case 'd (a 1) ((b c) 2) (T 3)))

(test 3 (casq 'a ("a" 1) (("b" "c") 2) (T 3)))
(test 3 (casq 'b ("a" 1) (("b" "c") 2) (T 3)))
(test 2 (casq '"b" ("a" 1) (("b" "c") 2) (T 3)))
(test 2 (casq '"c" ("a" 1) (("b" "c") 2) (T 3)))
(test 3 (casq 'b (a 1) ("b" 2) ((a b c) 3) (c 4)))


### state ###
(off "tst")

(de "tst" ()
   (job '((Cnt . 4))
      (state '(start)
         (start 'run
            (link 'start) )
         (run (and (gt0 (dec 'Cnt)) 'run)
            (link 'run) )
         (run 'stop
            (link 'run) )
         (stop 'start
            (setq Cnt 4)
            (link 'stop) ) ) ) )

(test '(start run run run run stop  start run run run run stop)
   (make (do 12 ("tst"))) )
(test '(start run run)
   (make (do 3 ("tst"))) )


### while ###
(test (1 2 3 4 5 6 7)
   (make
      (let N 0
         (while (>= 7 (inc 'N))
            (link N) ) ) ) )


### until ###
(test (1 2 3 4 5 6 7)
   (make
      (let N 0
         (until (> (inc 'N) 7)
            (link N) ) ) ) )


### loop ###
(test (1 2 3 4 5 6 7)
   (make
      (let N 1
         (loop
            (link N)
            (T (> (inc 'N) 7)) ) ) ) )
(test (1 2 3 4 5 6 7)
   (make
      (let N 1
         (loop
            (link N)
            (NIL (>= 7 (inc 'N))) ) ) ) )

(test
   '(a . 3)
   (loop (T NIL (cons @ 1)) (NIL 'a (cons @ 2)) (NIL NIL (cons @ 3))) )


### do ###
(test (1 2 3 4 5 6 7)
   (make
      (let N 0
         (do 7
            (link (inc 'N)) ) ) ) )
(test (1 2 3 4 5 6 7)
   (make
      (let N 1
         (do T
            (link N)
            (T (> (inc 'N) 7)) ) ) ) )


### at ###
(test (1 2 3 - 4 5 6 - 7 8 9 -)
   (make
      (let N 0
         (do 9
            (link (inc 'N))
            (at (0 . 3) (link '-)) ) ) ) )


### for ###
(test (1 2 3 4 5 6 7)
   (make
      (for N (1 2 3 4 5 6 7)
         (link N) ) ) )
(test (1 2 3 4 5 6 7)
   (make
      (for (N . X) '(a b c d e f g)
         (link N) ) ) )
(test (1 2 3 4 5 6 7)
   (make
      (for N 7
         (link N) ) ) )
(test (1 2 3 4 5 6 7)
   (make
      (for (N 1 (>= 7 N) (inc N))
         (link N) ) ) )
(test (1 2 3 4 5 6 7)
   (make
      (for ((N . X) 7 (gt0 X) (dec X))
         (link N) ) ) )
(test (1 2 3 4 5 6 7)
   (make
      (for (N 1 T)
         (link N)
         (T (> (inc 'N) 7)) ) ) )


### catch throw ###
(test NIL (catch NIL (throw)))
(test 'b (catch 'a (throw 'a 'b)))
(test 123 (catch T (throw 'a 123)))
(test "Undefined"
   (catch '("Undefined") (mist)) )
(test "No such file"
   (catch '("No such file")
      (in "doesntExist" (foo)) ) )
(test 6
   (casq
      (catch '("No such file" "Undefined" "expected")
         (+ 1 2 3) )
      ("No such file" (shouldNotComeHere))
      ("Undefined" (shouldNotComeHere))
      ("expected" (shouldNotComeHere))
      (T @) ) )


### finally ###
(test 'B
   (let X 'A
      (catch NIL
         (finally (setq X 'B)
            (setq X 'C)
            (throw)
            (setq X 'D) ) )
      X ) )


### co yield ###
(test (1 2 3 (1 2 3))
   (make
      (do 4
         (link
            (co "co123"
               (make
                  (yield (link 1))
                  (yield (link 2))
                  (yield (link 3)) ) ) ) ) ) )


### exec ###
(test
   (123 abc)
   (pipe (exec 'echo 123 "abc")
      (list (read) (read)) ) )

### call ###
(test T (call "test" "-d" (path "@test")))
(test NIL (call "test" "-f" (path "@test")))


### kill ###
(test T (kill *Pid 0))
