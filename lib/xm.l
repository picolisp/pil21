# 26may22 Software Lab. Alexander Burger

(local) (xml? xml body attr)
(private) (_xml xmlEsc escXml)

# Check or write header
(de xml? (Flg)
   (if Flg
      (prinl "<?xml version=\"1.0\" encoding=\"utf-8\"?>")
      (skip)
      (prog1
         (head '("<" "?" "x" "m" "l") (till ">"))
         (char) ) ) )

# Generate/Parse XML data
(de xml (Lst N)
   (if Lst
      (let Tag (++ Lst)
         (space (default N 0))
         (prin "<" Tag)
         (for X (++ Lst)
            (prin " " (car X) "=\"")
            (escXml (cdr X))
            (prin "\"") )
         (nond
            (Lst (prinl "/>"))
            ((or (cdr Lst) (pair (car Lst)))
               (prin ">")
               (escXml (car Lst))
               (prinl "</" Tag ">") )
            (NIL
               (prinl ">")
               (for X Lst
                  (if (pair X)
                     (xml X (+ 3 N))
                     (space (+ 3 N))
                     (escXml X)
                     (prinl) ) )
               (space N)
               (prinl "</" Tag ">") ) ) )
      (skip)
      (unless (= "<" (char))
         (quit "Bad XML") )
      (_xml (till " /<>" T)) ) )

(de _xml (Tok)
   (use X
      (make
         (link (intern Tok))
         (let L
            (make
               (loop
                  (NIL (skip) (quit "XML parse error"))
                  (T (member @ '`(chop "/>")))
                  (NIL (setq X (intern (till "=" T))))
                  (char)
                  (unless (= "\"" (char))
                     (quit "XML parse error" X) )
                  (link (cons X (pack (xmlEsc (till "\"")))))
                  (char) ) )
            (if (= "/" (char))
               (prog (char) (and L (link L)))
               (link L)
               (loop
                  (NIL (skip) (quit "XML parse error" Tok))
                  (T (and (= "<" (setq X (char))) (= "/" (peek)))
                     (char)
                     (unless (= Tok (till " /<>" T))
                        (quit "Unbalanced XML" Tok) )
                     (char) )
                  (if (= "<" X)
                     (and (_xml (till " /<>" T)) (link @))
                     (link
                        (pack (xmlEsc (trim (cons X (till "\n<"))))) ) ) ) ) ) ) ) )

(de xmlEsc (L)
   (use (@X @Z)
      (make
         (while L
            (ifn (match '("&" @X ";" @Z) L)
               (link (++ L))
               (link
                  (cond
                     ((= @X '`(chop "quot")) "\"")
                     ((= @X '`(chop "amp")) "&")
                     ((= @X '`(chop "lt")) "<")
                     ((= @X '`(chop "gt")) ">")
                     ((= @X '`(chop "apos")) "'")
                     ((= "#" (car @X))
                        (char
                           (if (= "x" (cadr @X))
                              (hex (cddr @X))
                              (format (cdr @X)) ) ) )
                     (T @X) ) )
               (setq L @Z) ) ) ) ) )

(de escXml (X)
   (for C (chop X)
      (if (member C '`(chop "\"&<"))
         (prin "&#" (char C) ";")
         (prin C) ) ) )


# Access functions
(de body (Lst . @)
   (while (and (setq Lst (cddr Lst)) (args))
      (setq Lst (asoq (next) Lst)) )
   Lst )

(de attr (Lst Key . @)
   (while (args)
      (setq
         Lst (asoq Key (cddr Lst))
         Key (next) ) )
   (get Lst 2 Key) )
