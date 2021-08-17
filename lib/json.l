# 16aug21 Software Lab. Alexander Burger

(de checkJson (X Item)
   (unless (= X Item)
      (quit "Bad JSON" Item) ) )

(de parseJson (Str)
   (let L (str Str "_")
      (recur ()
         (case (++ L)
            ("{"
               (make
                  (for (X (recurse) (not (= "}" X)) (recurse))
                     (checkJson ":" (recurse))
                     (link (cons (intern X) (recurse)))
                     (T (= "}" (setq X (recurse))))
                     (checkJson "," X) ) ) )
            ("["
               (make
                  (for (X (recurse) (not (= "]" X)) (recurse))
                     (link X)
                     (T (= "]" (setq X (recurse))))
                     (checkJson "," X) ) ) )
            (T
               (let X @
                  (cond
                     ((pair X) (pack X))
                     ((and (= "-" X) (format (car L)))
                        (- (++ L)) )
                     (T X) ) ) ) ) ) ) )

(de readJson ()
   (case (read "_")
      ("{"
         (make
            (for (X (readJson) (not (= "}" X)) (readJson))
               (checkJson ":" (readJson))
               (link (cons (intern X) (readJson)))
               (T (= "}" (setq X (readJson))))
               (checkJson "," X) ) ) )
      ("["
         (make
            (for (X (readJson) (not (= "]" X)) (readJson))
               (link X)
               (T (= "]" (setq X (readJson))))
               (checkJson "," X) ) ) )
      (T
         (let X @
            (cond
               ((pair X) (pack X))
               ((and (= "-" X) (format (peek)))
                  (- (read)) )
               (T X) ) ) ) ) )

(de packJson (Item)
   (pack
      (make
         (recur (Item)
            (cond
               ((atom Item) (link (if Item (sym @) "{}")))
               ((atom (car Item))
                  (link "[")
                  (map
                     '((X)
                        (recurse (car X))
                        (and (cdr X) (link ", ")) )
                     Item )
                  (link "]") )
               (T
                  (link "{")
                  (map
                     '((X)
                        (link "\"")
                        (link (sym (caar X)))
                        (link "\": ")
                        (recurse (cdar X))
                        (and (cdr X) (link ", ")) )
                     Item )
                  (link "}") ) ) ) ) ) )

(de printJson (Item)
   (cond
      ((atom Item) (if Item (print @) (prin "{}")))
      ((atom (car Item))
         (prin "[")
         (map
            '((X)
               (printJson (car X))
               (and (cdr X) (prin ", ")) )
            Item )
         (prin "]") )
      (T
         (prin "{")
         (map
            '((X)
               (prin "\"")
               (print (caar X))
               (prin "\": ")
               (printJson (cdar X))
               (and (cdr X) (prin ", ")) )
            Item )
         (prin "}") ) ) )
