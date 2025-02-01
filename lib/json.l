# 01feb25 Software Lab. Alexander Burger

(de checkJson (X Item)
   (unless (= X Item)
      (quit "Bad JSON" Item) ) )

(de parseJson (Str Arr)
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
                  (and Arr (link T))  # Array marker
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
                     ((and (num? X) (sub? (car L) "Ee"))
                        (and
                           (or (index "," (shift 'L)) (index "}" L))
                           (format (cut (dec @) 'L))
                           ((if (lt0 @) */ *) X (** 10 (abs @))) ) )
                     (T X) ) ) ) ) ) ) )

(de readJson (Arr)
   (case (read "_")
      ("{"
         (make
            (for (X (readJson Arr) (not (= "}" X)) (readJson Arr))
               (checkJson ":" (readJson Arr))
               (link (cons (intern X) (readJson Arr)))
               (T (= "}" (setq X (readJson Arr))))
               (checkJson "," X) ) ) )
      ("["
         (make
            (and Arr (link T))  # Array marker
            (for (X (readJson Arr) (not (= "]" X)) (readJson Arr))
               (link X)
               (T (= "]" (setq X (readJson Arr))))
               (checkJson "," X) ) ) )
      (T
         (let X @
            (cond
               ((pair X) (pack X))
               ((and (= "-" X) (format (peek)))
                  (- (read)) )
               ((and (num? X) (sub? (peek) "Ee"))
                  (when (format (cdr (till ",}")))
                     ((if (lt0 @) */ *) X (** 10 (abs @))) ) )
               (T X) ) ) ) ) )

(de packJson (Item F)
   (pack
      (make
         (recur (Item F)
            (cond
               ((atom Item) (link (if Item (sym @) "{}")))
               ((=T (car Item))
                  (link "[")
                  (map
                     '((X)
                        (recurse (car X))
                        (and (cdr X) (link ", ")) )
                     (cdr Item) )
                  (link "]") )
               ((and (car Item) (atom @) (not F))
                  (link "\"" (sym (car Item)) "\": ")
                  (recurse (cdr Item) T) )
               (T
                  (link "{")
                  (map
                     '((X)
                        (recurse (car X))
                        (and (cdr X) (link ", ")) )
                     Item )
                  (link "}") ) ) ) ) ) )

(de printJson (Item F)
   (cond
      ((atom Item) (if Item (print @) (prin "{}")))
      ((=T (car Item))
         (prin "[")
         (map
            '((X)
               (printJson (car X))
               (and (cdr X) (prin ", ")) )
            (cdr Item) )
         (prin "]") )
      ((and (car Item) (atom @) (not F))
         (prin "\"")
         (print (car Item))
         (prin "\": ")
         (printJson (cdr Item) T) )
      (T
         (prin "{")
         (map
            '((X)
               (printJson (car X))
               (and (cdr X) (prin ", ")) )
            Item )
         (prin "}") ) ) )
