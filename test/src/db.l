# 06oct20 Software Lab. Alexander Burger

### id ###
(test *DB (id 1))
(test 1 (id *DB))
(let I (id 3 4)
   (test (3 . 4) (id I T)) )


### lieu ###
(rollback)
(test NIL (lieu *DB))
(test *DB (val *DB) (lieu *DB))


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
