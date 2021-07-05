# 04jul21 Software Lab. Alexander Burger

(test T (pool (tmp "db")))

### extern ###
(test NIL (extern (box)))
(test *DB (extern "1"))


### ext? ###
(test *DB (ext? *DB))
(test NIL (ext? 'abc))
(test NIL (ext? "abc"))
(test NIL (ext? 123))


### touch ###
(test *DB (touch *DB))
(rollback)


### id ###
(test *DB (id 1))
(test 1 (id *DB))
(let I (id 3 4)
   (test (3 . 4) (id I T)) )


### wipe ###
(set *DB (1 2 3 4))
(put *DB 'a 1)
(put *DB 'b 2)
(test (1 2 3 4) (val *DB))
(test '((2 . b) (1 . a)) (getl *DB))
(wipe *DB)
(test (1 2 3 4) (val *DB))
(test '((2 . b) (1 . a)) (getl *DB))
(rollback)


### lieu ###
(test NIL (lieu *DB))
(test *DB (val *DB) (lieu *DB))
(rollback)


### commit rollback ###
(let (X (new T)  Y (new T))
   (set X 1  Y 2)
   (commit)
   (test 1 (val X))
   (test 2 (val Y))
   (set X 111)
   (set Y 222)
   (test 111 (val X))
   (test 222 (val Y))
   (rollback)
   (test 1 (val X))
   (test 2 (val Y)) )


### mark ###
(test NIL (mark *DB))
(test NIL (mark *DB T))
(test T (mark *DB))
(test T (mark *DB 0))
(test NIL (mark *DB))


### dbck ###
(test NIL (dbck))

(rollback)
(call "rm" (tmp "db"))
