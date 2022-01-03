# 03jan22 Software Lab. Alexander Burger

### +Joint ###
(pool (tmp "db"))

(class +A +Entity)
(rel k (+Key +String))
(rel b (+List +Bag)
   ((+Joint) a (+B))
   ((+Number)) )

(class +B +Entity)
(rel k (+Key +String))
(rel a (+Joint) b (+A) list asoq)

(let
   (A (new T '(+A) 'k "a")
      B (new T '(+B) 'k "b")
      C (new T '(+B) 'k "c") )

   (test T (bool (has> A 'k "a")))
   (test T (bool (has> B 'k "b")))
   (test A (db 'k '+A "a"))
   (test B (db 'k '+B "b"))
   (test C (db 'k '+B "c"))

   (put> B 'a A)
   (test (list (list B)) (; A b))
   (test A (; B a))

   (test T (bool (has> A 'b B)))
   (test T (bool (has> A 'b (list B))))
   (test T (bool (has> A 'b (list (list B)))))

   (test T (bool (has> B 'a A)))

   (put> B 'a NIL)
   (test NIL (; A b))
   (test NIL (; B a))

   (put> A 'b (list (list B 123)))
   (test (list (list B 123)) (; A b))
   (test A (; B a))

   (put> A 'b (list (list C 7)))
   (test (list (list C 7)) (; A b))
   (test NIL (; B a))
   (test A (; C a))

   (put> A 'b NIL)
   (test NIL (; A b))
   (test NIL (; B a)) )

(rollback)

### +Swap ###
(class +C +Entity)
(rel s (+Swap +String))
(rel l (+Swap +List +String))
(rel b (+List +Bag)
   ((+Number))
   ((+Swap +String)) )
(rel c (+Swap +List +Bag)
   ((+Number))
   ((+String)) )

(let A
   (new T '(+C)
      's "a"
      'l '("b" "c")
      'b '((123 "def"))
      'c '((123 "def")) )

   (test T (bool (has> A 's "a")))
   (test NIL (has> A 's "x"))
   (test T (bool (has> A 'l '("b" "c"))))
   (test NIL (has> A 'l '("b")))
   (test NIL (has> A 'l '("c")))
   (test NIL (has> A 'l '("x")))
   (test T (bool (has> A 'b '((123 "def")))))
   (test NIL (has> A 'b '((123))))
   (test NIL (has> A 'b '(("def"))))
   (test T (bool (has> A 'c '((123 "def")))))
   (test NIL (has> A 'c '((123))))
   (test NIL (has> A 'c '(("def"))))

   (let S (; A l)
      (put> A 'l '("x"))
      (test S (; A l))
      (test '("x") (; A l 0)) )

   (let S (; A b 1 2)
      (put> A 'b (list (list 4 S)))
      (test S (; A b 1 2))
      (test "def" (; A b 1 2 0))
      (test 4 (; A b 1 1))
      (put> A 'b '((7 "y")))
      (test S (; A b 1 2))
      (test 7 (; A b 1 1))
      (test "y" (; A b 1 2 0)) ) )

(rollback)
