# 26may22 Software Lab. Alexander Burger

# *Allow

(de *Day . (Mon Tue Wed Thu Fri Sat Sun .))
(de *Mon . (Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec .))

### Locale ###
(de *Ctry)
(de *Lang)
(de *Sep0 . ".")
(de *Sep3 . ",")
(de *CtryCode)
(de *NatTrunkPrf)
(de *DateFmt @Y "-" @M "-" @D)
(de *DayFmt "Monday" "Tuesday" "Wednesday" "Thursday" "Friday" "Saturday" "Sunday")
(de *MonFmt "January" "February" "March" "April" "May" "June" "July" "August" "September" "October" "November" "December")

(de locale (Ctry Lang . @)  # "DE" "de" ["app/loc/" ..]
   (load (if (setq *Ctry Ctry) (pack "@loc/" @ ".l") "@loc/NIL.l"))
   (ifn (setq *Lang Lang)
      (for S (idx '*Uni)
         (set S S) )
      (====)
      (let L
         (sort
            (make
               ("loc" (pack "@loc/" Lang))
               (while (args)
                  ("loc" (pack (next) Lang)) ) ) )
         (balance '*Uni L T)
         (for S L
            (set (car (idx '*Uni S)) (val S)) ) )
      (====) ) )

(de "loc" (F)
   (when (info F)
      (in F
         (use X
            (while (setq X (read))
               (if (=T X)
                  ("loc" (read))
                  (set (link @) (name (read))) ) ) ) ) ) )

### String ###
(de wrap (Max X)
   (let R
      (make
         (for (Lst (split (chop X) " " "\n")  Lst)
            (let L (++ Lst)
               (while
                  (and Lst
                     (> Max
                        (+ (length (car Lst)) (sum length L)) ) )
                  (setq L (conc L (list " ") (++ Lst))) )
               (link L) ) ) )
      (if (atom X)
         (mapcar pack R)
         (glue "\n" R) ) ) )

### Number ###
(de money (N Cur)
   (if Cur
      (pack (format N 2 *Sep0 *Sep3) " " Cur)
      (format N 2 *Sep0 *Sep3) ) )

(de round (N D)
   (if (> *Scl (default D 3))
      (format (*/ N (** 10 (- *Scl D))) D *Sep0 *Sep3)
      (format N *Scl *Sep0 *Sep3) ) )

# Binary notation
(de bin (X I)
   (cond
      ((num? X)
         (let (S (and (lt0 X) '-)  L (& 1 X)  A (cons 0 I))
            (until (=0 (setq X (>> 1 X)))
               (at A (push 'L " "))
               (push 'L (& 1 X)) )
            (pack S L) ) )
      ((setq X
            (filter
               '((C) (not (sp? C)))
               (chop X) ) )
         (let (S (and (= '- (car X)) (++ X))  N 0  C)
            (loop
               (NIL (setq C (format (++ X))))
               (NIL (or (=0 C) (=1 C)))
               (setq N (| C (>> -1 N)))
               (NIL X (if S (- N) N)) ) ) ) ) )

# Octal notation
(de oct (X I)
   (cond
      ((num? X)
         (let (S (and (lt0 X) '-)  L (& 7 X)  A (cons 0 I))
            (until (=0 (setq X (>> 3 X)))
               (at A (push 'L " "))
               (push 'L (& 7 X)) )
            (pack S L) ) )
      ((setq X
            (filter
               '((C) (not (sp? C)))
               (chop X) ) )
         (let (S (and (= '- (car X)) (++ X))  N 0  C)
            (loop
               (NIL (setq C (format (++ X))))
               (NIL (>= 7 C 0))
               (setq N (| C (>> -3 N)))
               (NIL X (if S (- N) N)) ) ) ) ) )

# Hexadecimal notation
(de hex (X I)
   (cond
      ((num? X)
         (let (S (and (lt0 X) '-)  L (hex1 X)  A (cons 0 I))
            (until (=0 (setq X (>> 4 X)))
               (at A (push 'L " "))
               (push 'L (hex1 X)) )
            (pack S L) ) )
      ((setq X
            (filter
               '((C) (not (sp? C)))
               (chop X) ) )
         (let (S (and (= '- (car X)) (++ X))  N 0  C)
            (loop
               (setq C (- (char (++ X)) `(char "0")))
               (and (> C 9) (dec 'C 7))
               (and (> C 22) (dec 'C 32))
               (NIL (>= 15 C 0))
               (setq N (| C (>> -4 N)))
               (NIL X (if S (- N) N)) ) ) ) ) )

(de hex1 (N)
   (let C (& 15 N)
      (and (> C 9) (inc 'C 7))
      (char (+ C `(char "0"))) ) )

# Hexadecimal/Alpha notation
(de hax (X)
   (if (num? X)
      (pack
         (mapcar
            '((C)
               (when (> (setq C (- (char C) `(char "0"))) 9)
                  (dec 'C 7) )
               (char (+ `(char "@") C)) )
            (chop (hex X)) ) )
      (hex
         (mapcar
            '((C)
               (when (> (setq C (- (char C) `(char "@"))) 9)
                  (inc 'C 7) )
               (char (+ `(char "0") C)) )
            (chop X) ) ) ) )

### Tree ###
(de balance ("Var" "Lst" "Flg")
   (unless "Flg" (set "Var"))
   (let "Len" (length "Lst")
      (recur ("Lst" "Len")
         (unless (=0 "Len")
            (let ("N" (>> 1 (inc "Len"))  "L" (nth "Lst" "N"))
               (idx "Var" (car "L") T)
               (recurse "Lst" (dec "N"))
               (recurse (cdr "L") (- "Len" "N")) ) ) ) ) )

(de depth (Idx)  #> (max . average)
   (let (C 0  D 0  N 0)
      (cons
         (recur (Idx N)
            (ifn Idx
               0
               (inc 'C)
               (inc 'D (inc 'N))
               (inc
                  (max
                     (recurse (cadr Idx) N)
                     (recurse (cddr Idx) N) ) ) ) )
         (or (=0 (setq @@ C)) (*/ D C)) ) ) )

### Allow ###
(de allowed Lst
   (setq *Allow (cons NIL (car Lst)))
   (balance *Allow (sort (cdr Lst))) )

(de allow (X Flg)
   (nond
      (*Allow)
      (Flg (idx *Allow X T))
      ((member X (cdr *Allow)) (queue '*Allow X)) )
   X )

### Telephone ###
(de telStr (S)
   (cond
      ((not S))
      ((and *CtryCode (pre? (pack *CtryCode " ") S))
         (pack *NatTrunkPrf (cdr (member " " (chop S)))) )
      (T (pack "+" S)) ) )

(de expTel (S)
   (setq S
      (make
         (for (L (chop S) L)
            (ifn (sub? (car L) " -")
               (link (++ L))
               (let F NIL
                  (loop
                     (and (= '- (++ L)) (on F))
                     (NIL L)
                     (NIL (sub? (car L) " -")
                        (link (if F '- " ")) ) ) ) ) ) ) )
   (cond
      ((= "+" (car S)) (pack (cdr S)))
      ((head '("0" "0") S) (pack (cddr S)))
      (*CtryCode
         (let L *NatTrunkPrf
            (loop
               (NIL L (pack *CtryCode " " S))
               (NIL (= (++ L) (++ S))) ) ) ) ) )

### Date ###
# ISO date
(de $dat (S C)
   (if C
      (and
         (= 3
            (length (setq S (split (chop S) C))) )
         (date
            (format (car S))               # Year
            (or (format (cadr S)) 0)       # Month
            (or (format (caddr S)) 0) ) )  # Day
      (and
         (format S)
         (date
            (/ @ 10000)       # Year
            (% (/ @ 100) 100) # Month
            (% @ 100) ) ) ) )

# Localized
(de datStr (D F)
   (when (setq D (date D))
      (let
         (@Y (if F (pad 2 (% (car D) 100)) (pad 4 (car D)))
            @M (pad 2 (cadr D))
            @D (pad 2 (caddr D)) )
         (pack (fill *DateFmt)) ) ) )

(de strDat (S)
   (use (@Y @M @D)
      (and
         (match *DateFmt (chop S))
         (date
            (format @Y)
            (or (format @M) 0)
            (or (format @D) 0) ) ) ) )

(de expDat (S)
   (cond
      ((= "." S) (date))
      ((or (pre? "+" S) (pre? "-" S)) (+ (date) (format S)))
      (T
         (use (@Y @M @D X)
            (unless (match *DateFmt (setq S (chop S)))
               (if
                  (or
                     (cdr (setq S (split S ".")))
                     (>= 2 (length (car S))) )
                  (setq
                     @D (car S)
                     @M (cadr S)
                     @Y (caddr S) )
                  (setq
                     @D (head 2 (car S))
                     @M (head 2 (nth (car S) 3))
                     @Y (nth (car S) 5) ) ) )
            (and
               (setq @D (format @D))
               (date
                  (nond
                     (@Y (car (date (date))))
                     ((setq X (format @Y)))
                     ((>= X 100)
                        (+ X
                           (* 100 (/ (car (date (date))) 100)) ) )
                     (NIL X) )
                  (nond
                     (@M (cadr (date (date))))
                     ((setq X (format @M)) 0)
                     ((n0 X) (cadr (date (date))))
                     (NIL X) )
                  @D ) ) ) ) ) )

# Day of the week
(de day (Dat Lst)
   (when Dat
      (get
         (or Lst *DayFmt)
         (inc (% (inc Dat) 7)) ) ) )

# Week of the year
(de week (Dat)
   (let W
      (-
         (_week Dat)
         (_week (date (car (date Dat)) 1 4))
         -1 )
      (if (=0 W) 53 W) ) )

(de _week (Dat)
   (/ (- Dat (% (inc Dat) 7)) 7) )

# Last day of month
(de ultimo (Y M)
   (dec
      (if (= 12 M)
         (date (inc Y) 1 1)
         (date Y (inc M) 1) ) ) )

### Time ###
(de $tim (S)
   (setq S (split (chop S) ":"))
   (unless (or (cdr S) (>= 2 (length (car S))))
      (setq S
         (list
            (head 2 (car S))
            (head 2 (nth (car S) 3))
            (nth (car S) 5) ) ) )
   (when (format (car S))
      (time @
         (or (format (cadr S)) 0)
         (or (format (caddr S)) 0) ) ) )

(de stamp (Dat Tim)
   (and (=T Dat) (setq Dat (date T)))
   (default Dat (date)  Tim (time T))
   (pack (dat$ Dat "-") " " (tim$ Tim T)) )

### I/O ###
(de chdir ("Dir" . "Prg")
   (let? "Old" (cd "Dir")
      (finally (cd "Old")
         (run "Prg") ) ) )

(de dirname (F)
   (let L (flip (chop F))
      (while (= "/" (car L))
         (++ L) )
      (pack (flip (member "/" L))) ) )

(de basename (F)
   (let L (flip (chop F))
      (while (= "/" (car L))
         (++ L) )
      (pack (stem (flip L) "/")) ) )

(de ssl ("Host" "Path" . "Prg")
   (in (list "@bin/ssl" "Host" 443 "Path")
      (and
         (tail '`(chop "200 OK") (line))
         (from "\r\n\r\n")
         (run "Prg") ) ) )

(de download (Host Src Dst)
   (let (F (tmp 'download)  Size)
      (in (list "@bin/ssl" Host 443 Src)
         (and
            (tail '`(chop "200 OK") (line))
            (from "Content-Length:")
            (setq Size (read))
            (from "\r\n\r\n")
            (out F (echo))
            (= Size (car (info F)))
            (=0 (%@ "rename" 'I F Dst)) ) ) ) )

# Echo here-documents
(de here (S)
   (line)
   (echo S) )

# Print or eval
(de prEval ("Prg" "Ofs")
   (default "Ofs" 1)
   (for "X" "Prg"
      (if (atom "X")
         (prinl (eval "X" "Ofs"))
         (eval "X" "Ofs") ) ) )

# Replace single LF with CR/LF
(de nlCrnl "Prg"
   (output
      (cond
         ((= "\n" @@)
            (prin "\r\n") )
         ((nand (= "\n" @@@) (= "\r" @@))
            (prin @@) ) )
      (run "Prg") ) )

# Multiline Base64
(de prBase64 (N C)
   (while
      (do N
         (NIL (ext:Base64 (rd 1) (rd 1) (rd 1)))
         T )
      (prinl C) ) )

# Send mail
(de mail (Host Port From To Sub Att . Prg)
   (let? S
      (if (pair Port)
         (pipe (exec "@bin/ssl" Host (fin Port)))
         (connect Host Port) )
      (let B (pack "==" (date) "-" (time T) "-" (usec) "==")
         (prog1
            (and
               (pre? "220 " (in S (line T)))
               (out S (prinl "HELO " (cdr (member "@" (chop (fin From)))) "\r"))
               (pre? "250 " (in S (line T)))
               (or
                  (atom Port)
                  (and
                     (out S
                        (prin "AUTH PLAIN ")
                        (pipe
                           (prog
                              (prin (car Port))
                              (wr 0)
                              (prin (car Port))
                              (wr 0)
                              (prin (cadr Port)) )
                           (prBase64 T "\r") )
                        (prinl "\r") )
                     (pre? "235 " (in S (line T))) ) )
               (out S (prinl "MAIL FROM:<" (fin From) ">\r"))
               (pre? "250 " (in S (line T)))
               (if (atom To)
                  (_rcpt To)
                  (find bool (mapcar _rcpt To)) )
               (out S (prinl "DATA\r"))
               (pre? "354 " (in S (line T)))
               (out S
                  (prinl "From: " (fin From) "\r")
                  (prinl "To: " (or (fin To) (glue "," To)) "\r")
                  (prin "Subject: ")
                  (ifn (find > (chop Sub) '("~" .))
                     (prinl Sub "\r")
                     (prin "=?utf-8?B?")
                     (pipe (prin Sub) (prBase64 T "\r"))
                     (prinl "?=\r") )
                  (when (pair From)
                     (prinl "Reply-To: " (car From) "\r") )
                  (prinl "User-Agent: PicoLisp\r")
                  (prinl "MIME-Version: 1.0\r")
                  (when Att
                     (prinl "Content-Type: multipart/mixed; boundary=\"" B "\"\r")
                     (prinl "\r")
                     (prinl "--" B "\r")
                     (unless (cadr Att)
                        (prinl "Content-Type: multipart/alternative; boundary=\"==" B "==\"\r")
                        (prinl "\r")
                        (prinl "--==" B "==\r") ) )
                  (prinl "Content-Type: text/plain; charset=utf-8\r")
                  (prinl "Content-Transfer-Encoding: 8bit\r")
                  (prinl "\r")
                  (nlCrnl (prEval Prg 2))
                  (prinl "\r")
                  (when Att
                     (loop
                        (if (cadr Att)
                           (prinl "--" B "\r")
                           (prinl "--==" B "==\r") )
                        (prin "Content-Type: " (or (caddr Att) "application/octet-stream"))
                        (and (cadr Att) (prin "; name=\"" @ "\""))
                        (prinl "\r")
                        (prinl
                           "Content-Transfer-Encoding: "
                           (if (cadr Att) "base64" "8bit")
                           "\r" )
                        (prinl "\r")
                        (in (car Att)
                           (ifn (cadr Att)
                              (nlCrnl (echo))
                              (prBase64 18 "\r")
                              (prinl "\r") ) )
                        (prinl "\r")
                        (unless (cadr Att)
                           (prinl "--==" B "==--\r")
                           (prinl "\r") )
                        (NIL (setq Att (cdddr Att))) )
                     (prinl "--" B "--\r") )
                  (prinl ".\r") )
               (pre? "250 " (in S (line T)))
               (out S (prinl "QUIT\r"))
               (pre? "221 " (in S (line T)))
               T )
            (close S) ) ) ) )

(de _rcpt (To)
   (out S (prinl "RCPT TO:<" To ">\r"))
   (pre? "250 " (in S (line T))) )

### Debug ###
`*Dbg

# Hex Dump
(de hd (File Cnt)
   (in File
      (let Pos 0
         (while
            (and
               (nand Cnt (lt0 (dec 'Cnt)))
               (make (do 16 (and (rd 1) (link @)))) )
            (let L @
               (prin (pad 8 (hex Pos)) "  ")
               (inc 'Pos 16)
               (for N L
                  (prin (pad 2 (hex N)) " ") )
               (space (inc (* 3 (- 16 (length L)))))
               (for N L
                  (prin (if (>= 126 N 32) (char N) ".")) )
               (prinl) ) ) ) ) )
