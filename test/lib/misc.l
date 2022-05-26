# 26may22 Software Lab. Alexander Burger

### locale ###
(locale "DE" "de")
(test "Ja" (val ,"Yes"))
(locale)


### align ###
(test "   a" (align 4 'a))
(test "   a" (align 4 "a"))
(test "12  " (align -4 12))
(test "   a  12   b" (align (4 4 4) "a" 12 "b"))


### center ###
(test " 12" (center 4 12))
(test " a" (center 4 "a"))
(test "   a" (center 7 'a))
(test " a  b  c" (center (3 3 3) "a" "b" "c"))


### wrap ###
(test "The quick brown fox\njumps over the lazy\ndog"
   (wrap 20 (chop "The quick brown fox jumps over the lazy dog")) )
(test "The\nquick\nbrown\nfox\njumps\nover the\nlazy dog"
   (wrap 8 (chop "The quick brown fox jumps over the lazy dog")) )
(test "The\nquick\nbrown\nfox\njumps\nover\nthe\nlazy\ndog"
   (wrap 2 (chop "The quick brown fox jumps over the lazy dog")) )
(test '("The" "quick" "brown" "fox" "jumps" "over the" "lazy dog")
   (wrap 8 "The quick brown fox jumps over the lazy dog") )


### pad ###
(test "00001" (pad 5 1))
(test "123456789" (pad 5 123456789))


### bin ###
(test "1001001" (bin (+ 64 8 1)))
(test (+ 64 8 1) (bin "1001001"))
(test "-110110" (bin -54))
(test -54 (bin "-110110"))


### oct ###
(test "111" (oct (+ 64 8 1)))
(test (+ 64 8 1) (oct "111"))
(test "-66" (oct -54))
(test -54 (oct "-66"))


### hex ###
(test "111" (hex (+ 256 16 1)))
(test (+ 256 16 1) (hex "111"))
(test "-FFFF" (hex -65535))


### money ###
(test "1,234,567.89" (money 123456789))
(test "1,234,567.89 EUR" (money 123456789 "EUR"))

(locale "DE" "de")
(test "1.234.567,89 EUR" (money 123456789 "EUR"))
(locale)


### round ###
(scl 4)
(test "12.35" (round 123456 2))
(test "12.3456" (round 123456 6))
(test "12.346" (round 123456))


### balance ###
(test (5 (2 (1) 3 NIL 4) 7 (6) 8 NIL 9)
   (let I NIL (balance 'I (sort (1 4 2 5 3 6 7 9 8))) I) )


### *Allow allowed allow ###
(allowed ("app/")
   "start" "stop" "lib.css" "psh" )
(allow "myFoo")
(allow "myDir/" T)

(test '(("psh" ("lib.css" NIL "myFoo") "start" NIL "stop") "app/" "myDir/")
   *Allow )

(test '("lib.css" "myFoo" "psh" "start" "stop")
   (idx *Allow) )

(test '("app/" "myDir/")
   (cdr *Allow) )


### telStr ###
(test "+49 1234 5678-0" (telStr "49 1234 5678-0"))

(locale "DE" "de")
(test "01234 5678-0" (telStr "49 1234 5678-0"))
(locale)


### expTel ###
(test "49 1234 5678-0" (expTel "+49 1234 5678-0"))
(test "49 1234 5678-0" (expTel "0049 1234 5678-0"))
(test NIL (expTel "01234 5678-0"))

(locale "DE" "de")
(test "49 1234 5678-0" (expTel "01234 5678-0"))
(locale)


### dat$ ###
(test "20070601" (dat$ (date 2007 6 1)))
(test "2007-06-01" (dat$ (date 2007 6 1) "-"))


### $dat ###
(test 733134 ($dat "20070601"))
(test 733134 ($dat "2007-06-01" "-"))


### datSym ###
(test "01jun07" (datSym (date 2007 6 1)))


### datStr ###
(test "2007-06-01" (datStr (date 2007 6 1)))

(locale "DE" "de")
(test "01.06.2007" (datStr (date 2007 6 1)))
(test "01.06.07" (datStr (date 2007 6 1) T))
(locale)


### strDat ###
(test 733134 (strDat "2007-06-01"))
(test NIL (strDat "01.06.2007"))

(locale "DE" "de")
(test 733134 (strDat "01.06.2007"))
(test 733134 (strDat "1.6.2007"))
(locale)


### expDat ###
(test 733133 (date 2007 5 31))
(test 733133 (expDat "31057"))
(test 733133 (expDat "310507"))
(test 733133 (expDat "2007-05-31"))
(test 733133 (expDat "7-5-31"))

(let D (date)
   (test D (expDat "."))
   (test (inc D) (expDat "+1"))
   (test (dec D) (expDat "-1")) )

(locale "DE" "de")
(test 733133 (expDat "31.5.7"))
(locale)


### day ###
(test "Friday" (day (date 2007 6 1)))

(locale "DE" "de")
(test "Freitag" (day (date 2007 6 1)))
(test "Fr"
   (day (date 2007 6 1) '("Mo" "Tu" "We" "Th" "Fr" "Sa" "Su")) )
(locale)


### week ###
(test 22 (week (date 2007 6 1)))


### ultimo ###
(test (2007 1 31) (date (ultimo 2007 1)))
(test (2007 2 28) (date (ultimo 2007 2)))
(test (2004 2 29) (date (ultimo 2004 2)))
(test (2000 2 29) (date (ultimo 2000 2)))
(test (1900 2 28) (date (ultimo 1900 2)))


### tim$ ###
(test "10:57" (tim$ (time 10 57 56)))
(test "10:57:56" (tim$ (time 10 57 56) T))


### $tim ###
(test (10 57 56) (time ($tim "10:57:56")))
(test (10 57 0) (time ($tim "10:57")))
(test (10 0 0) (time ($tim "10")))


### stamp ###
(test "2007-06-01 10:57:56"
   (stamp (date 2007 6 1) (time 10 57 56)) )


### chdir ###
(let P (pwd)
   (chdir "/"
      (test "/" (pwd)) )
   (test P *PWD) )


### dirname basename ###
(test "a/b/c/" (dirname "a/b/c/d"))
(test "a/b/c/" (dirname "a/b/c/d/"))
(test "d" (basename "a/b/c/d"))
(test "d" (basename "a/b/c/d/"))
