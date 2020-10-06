# 06oct20 Software Lab. Alexander Burger

(scl 6)
(load "@lib/math.l")

### pow ###
(test 8.0 (pow 2.0 3.0))
(test 8.0 (pow 64.0 0.5))

### exp ###
(test 2.718282 (exp 1.0))

### log ###
(test 0.693147 (log 2.0))

### sin ###
(test 0.0 (sin 0.0))
(test 1.0 (sin (/ pi 2)))

### cos ###
(test 1.0 (cos 0.0))
(test -1.0 (cos pi))

### tan ###
(test 0.0 (tan 0.0))
(test 0.0 (tan pi))

### asin ###
(test 0.0 (asin 0.0))
(test (/ pi 2) (asin 1.0))

### acos ###
(test 0.0 (acos 1.0))
(test pi (acos -1.0))

### atan ###
(test 0.0 (atan 0.0))

### atan2 ###
(test 0.0 (atan2 0.0 1.0))
(test (/ pi 2) (atan2 1.0 0.0))
