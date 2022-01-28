# 28jan22 Software Lab. Alexander Burger

### c[ad]*r ###
(let L '(1 2 3 4 5)
   (test 1 (car L))
   (test (2 3 4 5) (cdr L))
   (test 2 (cadr L))
   (test (3 4 5) (cddr L))
   (test 3 (caddr L))
   (test (4 5) (cdddr L))
   (test 4 (cadddr L))
   (test (5) (cddddr L)) )
(let L '((1 2 3) (4 5))
   (test 1 (caar L))
   (test (2 3) (cdar L))
   (test 2 (cadar L))
   (test (3) (cddar L))
   (test 4 (caadr L))
   (test (5) (cdadr L)) )
(let L '(((1 2)))
   (test 1 (caaar L))
   (test (2) (cdaar L)) )


### nth ###
(test '(b c d) (nth '(a b c d) 2))
(test '(c) (nth '(a (b c) d) 2 2))


### con ###
(let C (1 . a)
   (test '(b c d) (con C '(b c d)))
   (test (1 b c d) C) )


### cons ###
(test (1 . 2) (cons 1 2))
(test '(a b c d) (cons 'a '(b c d)))
(test '((a b) c d) (cons '(a b) '(c d)))
(test '(a b c . d) (cons 'a 'b 'c 'd))


### conc ###
(let (A (1 2 3)  B '(a b c))
   (test (1 2 3 a b c) (conc A B))
   (test (1 2 3 a b c) A) )

(test (1 2 3 4 5 6)
   (conc (1 2 3) NIL (4 5 6)) )


### circ ###
(let C (circ 'a 'b 'c)
   (test '(a b c . @) C)
   (test T (== C (cdddr C))) )


### rot ###
(test (4 1 2 3) (rot (1 2 3 4)))
(test (3 1 2 4 5 6) (rot (1 2 3 4 5 6) 3))
(test (3 1 2 . @Z) (rot (1 2 3 .)))


### list ###
(test (1 2 3 4) (list 1 2 3 4))
(test '(a (2 3) "OK") (list 'a (2 3) "OK"))


### need ###
(test '(NIL NIL NIL NIL NIL) (need 5))
(test '(NIL NIL a b c) (need 5 '(a b c)))
(test '(a b c NIL NIL) (need -5 '(a b c)))
(test '(" " " " a b c) (need 5 '(a b c) " "))
(test (0 0 0) (need 3 0))


### range ###
(test (1 2 3 4 5 6) (range 1 6))
(test (6 5 4 3 2 1) (range 6 1))
(test (-3 -2 -1 0 1 2 3) (range -3 3))
(test (3 1 -1 -3) (range 3 -3 2))
(test (-3 -2 -1) (range -3 -1))


### full ###
(test T (full (1 2 3)))
(test NIL (full (1 NIL 3)))
(test T (full 123))


### make made chain link yoke ###
(let (A 'a I 'i)
   (test '(x y z z a)
      (make
         (link (for A '(x y z) (link A)))
         (link A) ) )
   (test (-1 0 1 x 2 y 3 z i a)
      (make
         (made (cons 0 (box)))
         (for (I . A) '(x y z) (link I A))
         (test (0 1 x 2 y 3 z) (made))
         (made (cons -1 (made)))
         (link I A) ) )
   (test (1 2 3 4 5 6 7 8 9)
      (make (chain (1 2 3)) (chain (4 5 6) (7 8 9))) )
   (test '(a b c)
      (make (yoke 'b) (link 'c) (yoke 'a)) )
   (test '((x y z) (y z) (z) (z) a)
      (make (link (for (A '(x y z) A (cdr A)) (link A))) (link A)) )
   (test (1 (x y z) 2 (y z) 3 (z) (z) i a)
      (make (link (for ((I . A) '(x y z) A (cdr A)) (link I A))) (link I A)) ) )


### copy ###
(test T (=T (copy T)))
(let L (1 2 3)
   (test T (== L L))
   (test NIL (== L (copy L)))
   (test T (= L (copy L)))
   (test T (= (1 2 3) (copy L))) )


### mix ###
(test '(c d a b) (mix '(a b c d) 3 4 1 2))
(test '(a A d D) (mix '(a b c d) 1 'A 4 'D))


### append ###
(test '(a b c 1 2 3) (append '(a b c) (1 2 3)))
(test (1 2 3 . 4) (append (1) (2) (3) 4))


### delete ###
(test (1 3)
   (delete 2 (1 2 3)) )
(test '((1 2) (5 6) (3 4))
   (delete (3 4) '((1 2) (3 4) (5 6) (3 4))) )
(test (1 2 3 1 2 3)
   (delete 1 (1 1 2 3 1 2 3)) )
(test (2 3 2 3)
   (delete 1 (1 1 2 3 1 2 3) T) )


### delq ###
(test '(a c)
   (delq 'b '(a b c)) )
(test (1 (2) 3)
   (delq (2) (1 (2) 3)) )
(test '(a b c a b c)
   (delq 'a '(a a b c a b c)) )
(test '(b c b c)
   (delq 'a '(a a b c a b c) T) )


### replace ###
(test '(A b b A) (replace '(a b b a) 'a 'A))
(test '(a B B a) (replace '(a b b a) 'b 'B))
(test '(B A A B) (replace '(a b b a) 'a 'B 'b 'A))


### insert ###
(test '(a b 777 c d e) (insert 3 '(a b c d e) 777))
(test (777 a b c d e) (insert 1 '(a b c d e) 777))
(test '(a b c d e 777) (insert 9 '(a b c d e) 777))


### remove ###
(test '(a b d e) (remove 3 '(a b c d e)))
(test '(b c d e) (remove 1 '(a b c d e)))
(test '(a b c d e) (remove 9 '(a b c d e)))


### place ###
(test (7) (place 1 NIL 7))
(test (7 2 3) (place -1 (1 2 3) 7))
(test '(a b 777 d e) (place 3 '(a b c d e) 777))
(test (777 b c d e) (place 1 '(a b c d e) 777))
(test '(a b c d e 777) (place 9 '(a b c d e) 777))


### strip ###
(test 123 (strip 123))
(test '(a) (strip '''(a)))
(test '(a b c) (strip (quote quote a b c)))


### split ###
(test '((1) (2 b) (c 4 d 5) (6))
   (split (1 a 2 b 3 c 4 d 5 e 6) 'e 3 'a) )
(test '("The" "quick" "brown" "fox")
   (mapcar pack (split (chop "The quick brown fox") " ")) )


### reverse ###
(test (4 3 2 1) (reverse (1 2 3 4)))
(test NIL (reverse NIL))


### flip ###
(test (4 3 2 1) (flip (1 2 3 4)))
(test (3 2 1 4 5 6) (flip (1 2 3 4 5 6) 3))
(test NIL (flip NIL))


### trim ###
(test (1 NIL 2) (trim (1 NIL 2 NIL NIL)))
(test '(a b) (trim '(a b " " " ")))


### clip ###
(test (1 NIL 2) (clip '(NIL 1 NIL 2 NIL)))
(test '(a " " b) (clip '(" " a " " b " ")))


### head ###
(test '(a b c) (head 3 '(a b c d e f)))
(test NIL (head NIL '(a b c d e f)))
(test NIL (head 0 '(a b c d e f)))
(test '(a b c d e f) (head 10 '(a b c d e f)))
(test '(a b c d) (head -2 '(a b c d e f)))
(test '(a b c) (head '(a b c) '(a b c d e f)))


### tail ###
(test '(d e f) (tail 3 '(a b c d e f)))
(test '(c d e f) (tail -2 '(a b c d e f)))
(test NIL (tail NIL '(a b c d e f)))
(test NIL (tail 0 '(a b c d e f)))
(test '(a b c d e f) (tail 10 '(a b c d e f)))
(test '(d e f) (tail '(d e f) '(a b c d e f)))


### stem ###
(test '("g" "h" "i") (stem (chop "abc/def\\ghi") "/" "\\"))
(test '("g" "h" "i") (stem (chop "abc/def\\ghi") "\\" "/"))


### fin ###
(test 'a (fin 'a))
(test 'b (fin '(a . b)))
(test 'c (fin '(a b . c)))
(test NIL (fin '(a b c)))


### last ###
(test 4 (last (1 2 3 4)))
(test '(d e f) (last '((a b) c (d e f))))


### == ###
(test T (== 'a 'a))
(test T (== 'NIL NIL (val NIL) (car NIL) (cdr NIL)))
(test NIL (== (1 2 3) (1 2 3)))


### n== ###
(test NIL (n== 'a 'a))
(test T (n== (1) (1)))


### = ###
(test T (= 6 (* 1 2 3)))
(test T (= "a" "a"))
(test T (== "a" "a"))
(test T (= (1 (2) 3) (1 (2) 3)))
(test T (= (1 . (2 3 .)) (1 . (2 3 .))))


### <> ###
(test T (<> 'a 'b))
(test T (<> 'a 'b 'b))
(test NIL (<> 'a 'a 'a))


### =0 ###
(test 0 (=0 (- 6 3 2 1)))
(test NIL (=0 'a))


### =1 ###
(test 1 (=1 (- 6 3 2)))
(test NIL (=0 'a))


### =T ###
(test NIL (=T 0))
(test NIL (=T "T"))
(test T (=T T))


### n0 ###
(test NIL (n0 (- 6 3 2 1)))
(test T (n0 'a))


### nT ###
(test T (nT 0))
(test T (nT "T"))
(test NIL (nT T))


### < ###
(test T (< 3 4))
(test T (< 'a 'b 'c))
(test T (< 999 'a))
(test T (< NIL 7 'x (1) T))


### <= ###
(test T (<= 3 3))
(test T (<= 1 2 3))
(test T (<= "abc" "abc" "def"))


### > ###
(test T (> 4 3))
(test T (> 'A 999))
(test T (> T (1) 'x 7 NIL))


### >= ###
(test T (>= 'A 999))
(test T (>= 3 2 2 1))


### max ###
(test 'z (max 2 'a 'z 9))
(test (5) (max (5) (2 3) 'X))


### min ###
(test 2 (min 2 'a 'z 9))
(test 'X (min (5) (2 3) 'X))


### atom ###
(test T (atom 123))
(test T (atom 'a))
(test T (atom NIL))
(test NIL (atom (123)))


### pair ###
(test NIL (pair NIL))
(test (1 . 2) (pair (1 . 2)))
(test (1 2 3) (pair (1 2 3)))


### circ? ###
(test NIL (circ? 'a))
(test NIL (circ? (1 2 3)))
(test (2 3 . @) (circ? (1 . (2 3 .))))


### lst? ###
(test T (lst? NIL))
(test NIL (lst? T))
(test T (lst? (1 . 2)))
(test T (lst? (1 2 3)))


### num? ###
(test 123 (num? 123))
(test NIL (num? 'abc))
(test NIL (num? (1 2 3)))


### sym? ###
(test T (sym? 'a))
(test T (sym? NIL))
(test NIL (sym? 123))
(test NIL (sym? '(a b)))


### flg? ###
(test T (flg? T))
(test T (flg? NIL))
(test NIL (flg? 0))
(test T (flg? (= 3 3)))
(test T (flg? (= 3 4)))
(test NIL (flg? (+ 3 4)))


### member ###
(test (3 4 5 6) (member 3 (1 2 3 4 5 6)))
(test (3 . @) (member 3 (1 2 3 4 5 6 .)))
(test NIL (member 9 (1 2 3 4 5 6)))
(test NIL (member 9 (1 2 3 4 5 6 .)))
(test '((d e f) (g h i))
   (member '(d e f) '((a b c) (d e f) (g h i))) )


### memq ###
(test '(c d e f) (memq 'c '(a b c d e f)))
(test '(c . @) (memq 'c '(a b c d e f .)))
(test NIL (memq (2) '((1) (2) (3))))
(test NIL (memq (2) '((1) (2) (3) .)))
(test 'c (memq 'c '(a b . c)))
(test '(b c a . @Z) (memq 'b '(a b c .)))
(test NIL (memq 'd '(a b c .)))


### mmeq ###
(test NIL (mmeq '(a b c) '(d e f)))
(test '(b x) (mmeq '(a b c) '(d b x)))


### sect ###
(test (3 4) (sect (1 2 3 4) (3 4 5 6)))
(test (1 2 3) (sect (1 2 3) (1 2 3)))
(test NIL (sect (1 2 3) (4 5 6)))


### diff ###
(test (1 3 5) (diff (1 2 3 4 5) (2 4)))
(test (1 2 3) (diff (1 2 3) NIL))
(test NIL (diff (1 2 3) (1 2 3)))


### index ###
(test 3 (index 'c '(a b c d e f)))
(test NIL (index 'z '(a b c d e f)))
(test 3 (index '(5 6) '((1 2) (3 4) (5 6) (7 8))))


### offset ###
(test 3 (offset '(c d e f) '(a b c d e f)))
(test NIL (offset '(c d e) '(a b c d e f)))


### prior ###
(let (L (1 2 3 4 5 6)  X (cdddr L))
   (test NIL (prior L L))
   (test NIL (prior NIL L))
   (test (3 4 5 6) (prior X L)) )


### length ###
(test 3 (length "abc"))
(test 3 (length "äbc"))
(test 3 (length 123))
(test 3 (length (1 (2) 3)))
(test T (length (1 2 3 .)))
(test T (length (1 . (2 3 .))))


### size ###
(test 3 (size "abc"))
(test 4 (size "äbc"))
(test 1 (size 127))
(test 2 (size 128))
(test 4 (size (1 (2) 3)))
(test 3 (size (1 2 3 .)))
(test 8 (size '((1 2 3) (4 5 6))))
(test 6 (size '((1 2 .) (4 5 .))))
(test 3 (size (1 . (2 3 .))))


### bytes ###
(test 4 (bytes "abc"))
(test 5 (bytes "äbc"))
(test 9 (bytes "abcdefgh"))
(test 2 (bytes 127))
(test 3 (bytes 128))
(test 10 (bytes (101 (102) 103)))
(test 9 (bytes (101 102 103 .)))
(let (L (7 "abc" (1 2 3) 'a)  F (tmp "bytes"))
   (out F (pr L))
   (test (bytes L) (car (info F))) )


### assoc ###
(test '("b" . 7)
   (assoc "b" '((999 1 2 3) ("b" . 7) ("ok" "Hello"))) )
(test '("b" . 7)
   (assoc "b" '((999 1 2 3) ("b" . 7) ("ok" "Hello") .)) )
(test (999 1 2 3)
   (assoc 999 '((999 1 2 3) ("b" . 7) ("ok" "Hello"))) )
(test NIL
   (assoc 'u '((999 1 2 3) ("b" . 7) ("ok" "Hello"))) )
(test NIL
   (assoc 'u '((999 1 2 3) ("b" . 7) ("ok" "Hello") .)) )


### rassoc ###
(test '("b" . 7)
   (rassoc 7 '((999 1 2 3) ("b" . 7) ("ok" "Hello"))) )
(test '("b" . 7)
   (rassoc 7 '((999 1 2 3) ("b" . 7) ("ok" "Hello") .)) )
(test (999 1 2 3)
   (rassoc (1 2 3) '((999 1 2 3) ("b" . 7) ("ok" "Hello"))) )
(test NIL
   (rassoc 'u '((999 1 2 3) ("b" . 7) ("ok" "Hello"))) )
(test NIL
   (rassoc 'u '((999 1 2 3) ("b" . 7) ("ok" "Hello") .)) )


### asoq ###
(test NIL
   (asoq (9) '(((9) 1 2 3) (b . 7) ("ok" "Hello"))) )
(test NIL
   (asoq (9) '(((9) 1 2 3) (b . 7) ("ok" "Hello") .)) )
(test '(b . 7)
   (asoq 'b '(((9) 1 2 3) (b . 7) ("ok" "Hello"))) )
(test '(b . 7)
   (asoq 'b '(((9) 1 2 3) (b . 7) ("ok" "Hello") .)) )


### rasoq ###
(test '(2 . b)
   (rasoq 'b '((1 . a) (2 . b) (3 . c))) )
(test '(2 . b)
   (rasoq 'b '((1 . a) (2 . b) (3 . c) .)) )
(test NIL
   (rasoq "b" '((1 . a) (2 . b) (3 . c))) )
(test NIL
   (rasoq "b" '((1 . a) (2 . b) (3 . c) .)) )


### rank ###
(test NIL
   (rank 0 '((1 . a) (100 . b) (1000 . c))) )
(test (1 . a)
   (rank 50 '((1 . a) (100 . b) (1000 . c))) )
(test (100 . b)
   (rank 100 '((1 . a) (100 . b) (1000 . c))) )
(test (100 . b)
   (rank 300 '((1 . a) (100 . b) (1000 . c))) )
(test (1000 . c)
   (rank 9999 '((1 . a) (100 . b) (1000 . c))) )
(test (100 . b)
   (rank 50 '((1000 . a) (100 . b) (1 . c)) T) )


### match ###
(use (@A @B @X @Y @Z)
   (test T
      (match '(@A is @B) '(This is a test)) )
   (test '(This) @A)
   (test '(a test) @B)
   (test T
      (match '(@X (d @Y) @Z) '((a b c) (d (e f) g) h i)) )
   (test '((a b c)) @X)
   (test '((e f) g) @Y)
   (test '(h i) @Z) )


### fill ###
(let (@X 1234  @Y (1 2 3 4))
   (test 1234 (fill '@X))
   (test '(a b (c 1234) (((1 2 3 4) . d) e))
      (fill '(a b (c @X) ((@Y . d) e))) ) )
(test (1 a b c 9)
   (fill (1 ^(list 'a 'b 'c) 9)) )
(test (1 5 7)
   (fill (1 ^(+ 2 3) 7)) )
(let X 2 (test (1 2 3) (fill (1 X 3) 'X)))
(let X 2 (test (1 2 3) (fill (1 X 3) '(X))))
(test (1 (a (7 . 2) c) 3)
   (fill (1 (a (b . 2) c) 3) 'b 7) )
(test (1 (a (b . 123) c) 3)
   (fill (1 (a (b . 2) c) 3) 2 123) )


### prove ###
(test T
   (prove (goal '((equal 3 3)))) )
(test '((@X . 3))
   (prove (goal '((equal 3 @X)))) )
(test NIL
   (prove (goal '((equal 3 4)))) )


### -> ###
(test '((@A . 3) (@B . 7))
   (prove (goal '(@A 3 (^ @B (+ 4 (-> @A)))))) )
(test '((@A . 3) (@B . 7))
   (prove (goal '(@A 3 (^ @B (+ 4 @A))))) )
(test '((@A . 3) (@B . 4) (@N . 12))
   (prove (goal '(@A 3 @B 4 (^ @N (* @A @B))))) )


### unify ###
(test '((@A ((NIL . @C) 0 . @C) ((NIL . @B) 0 . @B) T))
   (prove (goal '((^ @A (unify '(@B @C)))))) )


### not/1 call/1 or/2 nil/1 uniq/2 ###
(test NIL
   (prove (goal '(@A 3 @B 3 (not (equal @A @B))))) )
(test '((@A . 3) (@B . 4))
   (prove (goal '(@A 3 @B 4 (not (equal @A @B))))) )
(test '((@A 1 2 3) (@X 4 5 6))
   (prove (goal '(@A (1 2 3) (call append @A @X (1 2 3 4 5 6))))) )
(test '((@X . 7))
   (prove (goal '((or ((equal 3 @X) (equal @X 4)) ((equal 7 @X) (equal @X 7)))))) )
(test '((@X)) (prove (goal '(@X NIL (nil @X)))))
(test '(a b c d)
   (solve '((^ @B (box)) (lst @X (a b c b c d)) (uniq @B @X)) @X) )


### asserta/1 assertz/1 retract/1 ###
(test T
   (prove
      (goal
         (quote
            (asserta (a (2)))
            (assertz (a (3)))
            (asserta (a (1))) ) ) ) )
(test '(((1)) ((2)) ((3)))
   (get 'a T) )
(test T
   (prove (goal '((retract (a 2))))) )
(test '(((1)) ((3)))
   (get 'a T) )


### clause/2 ###
(test T
   (prove (goal '((clause append ((NIL @X @X)))))) )
(test '((@C (NIL @X @X)))
   (prove (goal '((clause append @C)))) )


### for/2 for/3 for/4 ###
(test '(((@I . 1)) ((@I . 2)) ((@I . 3)))
   (solve '((for @I 3))) )
(test '(((@I . 3)) ((@I . 4)) ((@I . 5)) ((@I . 6)) ((@I . 7)))
   (solve '((for @I 3 7))) )
(test '(((@I . 7)) ((@I . 5)) ((@I . 3)))
   (solve '((for @I 7 3 2))) )


### group ###
(test '((1 a b c) (2 d e f))
   (group '((1 . a) (1 . b) (1 . c) (2 . d) (2 . e) (2 . f))) )


### sort ###
(test '(NIL 1 2 3 4 a b c d (1 2 3) (a b c) (x y z) T)
   (sort '(a 3 1 (1 2 3) d b 4 T NIL (a b c) (x y z) c 2)) )
(test '(T (x y z) (a b c) (1 2 3) d c b a 4 3 2 1 NIL)
   (sort '(a 3 1 (1 2 3) d b 4 T NIL (a b c) (x y z) c 2) >) )
