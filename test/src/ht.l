# 06oct20 Software Lab. Alexander Burger

### ht:Prin ###
(test "1&lt;2&gt;3&amp;äöü&lt;i&gt;ÄÖÜß"
   (pipe (ht:Prin "1<2>3&äöü<i>ÄÖÜß") (line T)) )


### ht:Fmt ###
(test "+123&abc&$def&-123&_+1_xyz_+7"
   (ht:Fmt 123 "abc" 'def '{123} (1 "xyz" 7)) )


### ht:Pack ###
(test "A+B%20C"
   (ht:Pack '("A" "+" "B" "%" "2" "0" "C")) )
(test "A+B C"
   (ht:Pack '("A" "+" "B" "%" "2" "0" "C") T) )
(test "a b>c"
   (ht:Pack '("a" "%" "2" "0" "b" "&" "g" "t" ";" "c") T) )
(test "a€z"
   (ht:Pack '("a" "&" "#" "8" "3" "6" "4" ";" "z")) )
(test "äöü"
   (ht:Pack '("%" "C" "3" "%" "A" "4" "%" "C" "3" "%" "B" "6" "%" "C" "3" "%" "B" "C") T) )


### ht:Read ###
(test NIL
   (pipe (prin "abcde") (ht:Read 0)) )
(test NIL
   (pipe (prin "abcde") (ht:Read 6)) )
(test NIL
   (pipe NIL (ht:Read 3)) )
(test NIL
   (pipe (prin "äö") (ht:Read 3)) )
(test '("ä" "ö")
   (pipe (prin "äö") (ht:Read 4)) )
(test '("a" "b" "c")
   (pipe (prin "abcde") (ht:Read 3)) )
(test '("ä" "ö" "ü")
   (pipe (prin "äöüxyz") (ht:Read 6)) )


### ht:In ht:Out ###
(test "Hello world"
   (pipe (ht:Out T (prinl "Hello world")) (ht:In T (line T))) )
