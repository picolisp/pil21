# 03apr23 Software Lab. Alexander Burger

### ext:Snx ###
(test "PSLSFSNTSNNLSF"
   (ext:Snx "PicoLisp is not Common Lisp") )
(test "PSLSFSNT"
   (ext:Snx "PicoLisp is not Common Lisp" 8) )


### ext:Base64 ###
(test "TQ=="
   (pipe (ext:Base64 77) (line T)) )
(test "AQID"
   (pipe (ext:Base64 1 2 3) (line T)) )
(test '("A" "Q" "I" "D" "B" "A" "U" "G" "B" "w" "=" "=")
   (make
      (let L (1 2 3 4 5 6 7)
         (output (link @@)
            (while L
               (ext:Base64 (++ L) (++ L) (++ L)) ) ) ) ) )

(test (77)
   (pipe
      (prinl "TQ==")
      (make (while (ext:Base64) (link @))) ) )
(test (1 2 3)
   (pipe
      (prinl "AQID")
      (make (while (ext:Base64) (link @))) ) )
(test (1 2 3 4 5 6 7)
   (let L '("A" "Q" "I" "D" "B" "A" "U" "G" "B" "w" "=" "=")
      (make
         (input (++ L)
            (while (ext:Base64) (link @)) ) ) ) )

(let F (tmp "base64")
   (out F
      (pipe
         (prin "Polyfon zwitschernd aßen Mäxchens Vögel Rüben, Joghurt und Quark")
         (while (ext:Base64 (rd 1) (rd 1) (rd 1))) ) )

   (test "UG9seWZvbiB6d2l0c2NoZXJuZCBhw59lbiBNw6R4Y2hlbnMgVsO2Z2VsIFLDvGJlbiwgSm9naHVydCB1bmQgUXVhcms="
      (in F (line T)) )

   (test "Polyfon zwitschernd aßen Mäxchens Vögel Rüben, Joghurt und Quark"
      (pipe
         (in F (while (ext:Base64) (wr @)))
         (line T) ) ) )
