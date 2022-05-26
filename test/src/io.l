# 26may22 Software Lab. Alexander Burger

### path ###
(test 'task (cadr (in (path "@lib.l") (read))))
(test (char "+") (char (path "+@")))


### read ###
(test (1 2 3) (~(1 2) 3))
(test (1 3) (~(1 . 2) 3))
(test (1 2 3 4) (1 ~(2 3) 4))
(test (1 2 4) (1 ~(2 . 3) 4))
(test (1 2 3) [1 2 3])
(test (1 2 3) (1 2 3]
(test (1 2 3) (1 2 3)]
(test (1 (2 3)) (1 (2 3]
(test (quote 1 (2 (3))) '(1 (2 (3]
(test (quote 1 (2 (3))) '[1 (2 (3])
(test (1 abc (d e f))
   (pipe (prinl "(1 abc (d e f))")
      (read) ) )
(test '(abc "=" def_ghi "(" ("x" "y" "z") "+" "-" 123 ")")
   (pipe (prinl "abc = def_ghi(\"xyz\"+-123) # Comment")
      (make
         (while (read "_" "#")
            (link @) ) ) ) )


### wait ###
(let (*Run NIL  *Cnt 0)
   (test (1 2 3 4 5 6 7)
      (make
         (task -10 0  (link (inc '*Cnt)))
         (wait NIL (>= *Cnt 7)) ) ) )


### peek char ###
(pipe (prin "ab")
   (test "a" (peek))
   (test "a" (char))
   (test "b" (peek))
   (test "b" (char))
   (test NIL (peek))
   (test NIL (char)) )
(test "A" (char 65))
(test 65 (char "A"))


### skip ###
(test "a"
   (pipe (prinl "# Comment\na")
      (skip "#") ) )
(test "#"
   (pipe (prinl "# Comment\na")
      (skip) ) )


### eof ###
(test T (pipe NIL (eof)))
(test NIL (pipe (prin "a") (eof)))
(test T (pipe (prin "a") (eof T) (eof)))


### from till ###
(test "cd"
   (pipe (prin "ab.cd:ef")
      (from ".")
      (till ":" T) ) )


### line ###
(test '("a" "b" "c")
   (pipe (prin "abc\n") (line)) )
(test "abc"
   (pipe (prin "abc") (line T)) )
(test '("abc" "def")
   (pipe (prin "abc\ndef")
      (list (line T) (line T)) ) )
(test '("abc" "def")
   (pipe (prin "abc\rdef")
      (list (line T) (line T)) ) )
(test '("abc" "def")
   (pipe (prin "abc\r\ndef")
      (list (line T) (line T)) ) )
(test '("a" "bc" "def")
   (pipe (prin "abcdef")
      (line T 1 2 3) ) )


### any ###
(test '(a b c d) (any "(a b # Comment\nc d)"))
(test "A String" (any "\"A String\""))


### sym ###
(test "(abc \"Hello\" 123)"
   (sym '(abc "Hello" 123)) )


### str ###
(test '(a (1 2) b)
   (str "a (1 2) b") )
(test '(a (1 2))
   (str "a (1 2) # b") )
(test "a \"Hello\" DEF"
   (str '(a "Hello" DEF)) )


### load ###
(test 6 (load "-* 1 2 3"))


### in out err ###
(out (tmp "file")
   (println 123)
   (println 'abc)
   (println '(d e f)) )
(in (tmp "file")
   (test 123 (read))
   (in (tmp "file")
      (test 123 (read))
      (test 'abc (in -1 (read))) )
   (test '(d e f) (read)) )

(let Err (tmp "err")
   (test 1 (err Err (msg 1)))
   (test 2 (err (pack "+" Err) (msg 2)))
   (test "1\n2\n" (in Err (till NIL T))) )


### input output ###
(test "A" (input "A" (char)))
(test '(+ 2 (* 3 4))
   (let S (chop "(+ 2 (* 3 4))") (input (++ S) (read))) )

(test "(+ 2 (* 3 4))"
   (pack (make (output (link @@) (print '(+ 2 (* 3 4)))))) )


### pipe ###
(test 123 (pipe (println 123) (read)))
(test "ABC DEF GHI"
   (pipe
      (out '(tr "[a-z]" "[A-Z]") (prinl "abc def ghi"))
      (line T) ) )


### open close ###
(let F (open (tmp "file"))
   (test 123 (in F (read)))
   (test 'abc (in F (read)))
   (test '(d e f) (in F (read)))
   (test F (close F)) )


### echo ###
(out (tmp "echo")
   (in (tmp "file")
      (echo) ) )
(in (tmp "echo")
   (test 123 (read))
   (test 'abc (read))
   (test '(d e f) (read)) )
(let F (tmp "file")
   (test "12"
      (pipe (in F (echo 2))
         (line T) ) )
   (test "23"
      (pipe (in F (echo 1 2))
         (line T) ) ) )


### prin prinl space print printsp println ###
(out (tmp "prin")
   (prin 1)
   (prinl 2)
   (space)
   (print 3)
   (printsp 4)
   (println 5) )
(test (12 "\n" " " 34 5)
   (in (tmp "prin")
      (list (read) (char) (char) (read) (read)) ) )


### flush rewind ###
(out (tmp "prin")
   (prinl "abc")
   (flush)
   (test "abc" (in (tmp "prin") (line T)))
   (rewind) )
(out (tmp "prin") (prinl "def"))
(test "def" (in (tmp "prin") (line T)))


### ext rd pr ###
(let L (list (id 1 2) (cons (id 3 9) 'a) (cons (id 2 7) 'b))
   (let L5 (list (id 6 2) (cons (id 8 9) 'a) (cons (id 7 7) 'b))
      (out (tmp "ext")
         (ext 5 (pr L5)) )
      (test L
         (in (tmp "ext") (rd)) )
      (test L5
         (in (tmp "ext") (ext 5 (rd))) ) ) )

(pipe
   (for N 4096
      (pr N) )
   (for N 4096
      (test N (rd)) ) )
(pipe
   (for C 4096
      (pr (char C)) )
   (for C 4096
      (test C (char (rd))) ) )
(pipe
   (pr (7 "abc" (1 2 3) 'a))
   (test (7 "abc" (1 2 3) 'a) (rd)) )
(test "def"
   (out (tmp "pr")
      (pr 'abc "EOF" 123 "def") ) )
(test '(abc "EOF" 123 "def")
   (in (tmp "pr")
      (make
         (use X
            (until (== "EOF" (setq X (rd "EOF")))
               (link X) ) ) ) ) )

(let N 1
   (do 200
      (test N
         (pipe (pr N) (rd)) )
      (test (- N)
         (pipe (pr (- N)) (rd)) )
      (setq N (* 2 N))
      (wait 10) ) )

### wr ###
(test 3
   (out (tmp "wr")
      (wr 1 2 3) ) )
(test (hex "010203")
   (in (tmp "wr")
      (rd 3) ) )

(for I 100
   (let (L (need I "01")  N (hex (pack L)))
      (test N
         (pipe (apply wr (mapcar format L)) (rd I)) )
      (wait 10) ) )
