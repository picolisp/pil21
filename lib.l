# 03may22 Software Lab. Alexander Burger

(de task (Key . Prg)
   (nond
      (Prg (del (assoc Key *Run) '*Run))
      ((num? Key) (quit "Bad Key" Key))
      ((assoc Key *Run)
         (push '*Run
            (conc
               (make
                  (when (lt0 (link Key))
                     (link (eval (++ Prg) 1)) ) )
               (ifn (sym? (car Prg))
                  Prg
                  (cons
                     (cons 'job
                        (cons
                           (lit
                              (make
                                 (while (atom (car Prg))
                                    (link
                                       (cons (++ Prg) (eval (++ Prg) 1)) ) ) ) )
                           Prg ) ) ) ) ) ) )
      (NIL (quit "Key conflict" Key)) ) )

(de timeout (N)
   (if2 N (assoc -1 *Run)
      (set (cdr @) N)
      (push '*Run (list -1 N '(bye)))
      (del @ '*Run) ) )

(de tasks Task
   (task -2 (abs (run Task))  "Prg" Task
      (let (L (assoc @ *Run)  P (run "Prg"))
         (if2 (lt0 (car L)) (lt0 P)
            (set (cdr L) (abs P))            # (-2 111 ..) -> (-2 999 ..)
            (ifn P
               (task -2)
               (set L P)                     # (-2 999 ..) -> (7 ..)
               (con L (cddr L)) )
            (prog                            # (7 ..) -> (-2 999 ...)
               (set L -2)
               (con L (cons (abs P) (cdr L))) )
            (ifn P
               (task (car L))
               (set L P) ) ) ) ) )           # (3 ..) -> (7 ..)

(de abort ("N" . "Prg")
   (catch 'abort
      (alarm "N" (throw 'abort))
      (finally (alarm 0) (run "Prg")) ) )

(de macro "Prg"
   (run (fill "Prg")) )

(de later ("@Var" . "@Prg")
   (macro
      (task (pipe (pr (prog . "@Prg")))
         (setq "@Var" (in @ (rd)))
         (task (close @)) ) )
   "@Var" )

(de recur recurse
   (run (cdr recurse)) )

(de curry "Z"
   (let ("X" (++ "Z")  "Y" (++ "Z")  "P" (filter pat? "X"))
      (if2 "P" (diff "X" "P")
         (list "Y" (cons 'job (lit (env @)) (fill "Z" "P")))
         (cons "Y" (fill "Z" "P"))
         (list "Y" (cons 'job (lit (env @)) "Z"))
         (cons "Y" "Z") ) ) )

### Definitions ###
(de expr ("F")
   (set "F"
      (list '@ (list 'pass (box (getd "F")))) ) )

(de subr ("F")
   (set "F" (getd (cadadr (getd "F")))) )

(de undef ("X" "C")
   (when (pair "X")
      (setq  "C" (cdr "X")  "X" (car "X")) )
   (ifn "C"
      (prog1 (val "X") (set "X"))
      (prog1
         (cdr (asoq "X" (val "C")))
         (set "C"
            (delq (asoq "X" (val "C")) (val "C")) ) ) ) )

(de redef "Lst"
   (let ("Old" (car "Lst")  "New" (name "Old"))
      (set
         "New" (getd "Old")
         "Old" "New"
         "Old" (fill (cdr "Lst") "Old") )
      "New" ) )

(de sysdefs ("Sym" "Alt")
   (in (or "Alt" "@lib/sysdefs")
      (if (from (pack "\n[" "Sym" "]\n"))
         (while (and (skip) (<> "[" @))
            (def (read) (read)) )
         (quit "No sysdefs" "Sym") ) ) )

(de daemon ("X" . Prg)
   (prog1
      (nond
         ((pair "X")
            (or (pair (getd "X")) (expr "X")) )
         ((pair (cdr "X"))
            (method (car "X") (cdr "X")) )
         (NIL
            (method (car "X") (get (or (cddr "X") *Class) (cadr "X"))) ) )
      (con @ (append Prg (cdr @))) ) )

(de patch ("Lst" "Pat" . "Prg")
   (bind (fish pat? "Pat")
      (recur ("Lst")
         (loop
            (cond
               ((match "Pat" (car "Lst"))
                  (set "Lst" (run "Prg")) )
               ((pair (car "Lst"))
                  (recurse @) ) )
            (NIL (cdr "Lst"))
            (T (atom (cdr "Lst"))
               (when (match "Pat" (cdr "Lst"))
                  (con "Lst" (run "Prg")) ) )
            (setq "Lst" (cdr "Lst")) ) ) ) )

(de cache ("Var" "X" . "Prg")
   (let "K" (cons (char (hash "X")) "X")
      (nond
         ("Prg" (caar (idx "Var" "K")))
         ((setq "Var" (caar (idx "Var" "K" T)))
            (set (car "K") (run "Prg" 1)) )
         ((n== "Var" (val "Var"))
            (set "Var" (run "Prg" 1)) )
         (NIL (val "Var")) ) ) )

### I/O ###
(de tab (Lst . @)
   (for N Lst
      (let V (next)
         (and (gt0 N) (space (- N (length V))))
         (prin V)
         (and (lt0 N) (args) (space (- 0 N (length V)))) ) )
   (prinl) )

(de beep ()
   (prin "^G") )

(de msg (X . @)
   (tty (print X) (pass prinl))
   X )

(de script (File . @)
   (load File) )

(de once "Prg"
   (unless (idx '*Once (file) T)
      (run "Prg" 1) ) )

(de rc (File Key . @)
   (ctl File
      (in File
         (let Lst (read)
            (ifn (args)
               (cdr (assoc Key Lst))
               (let Val (next)
                  (loop
                     (if (assoc Key Lst)
                        (con @ Val)
                        (push 'Lst (cons Key Val)) )
                     (NIL (args))
                     (setq Key (next)  Val (next)) )
                  (protect
                     (out File (println Lst)) )
                  Val ) ) ) ) ) )

(de acquire (File)
   (ctl File
      (in File
         (let P (rd)
            (or
               (= P *Pid)
               (unless (and P (kill P 0))
                  (out File (pr *Pid)) ) ) ) ) ) )

(de release (File)
   (ctl File (out File)) )

# Temporary Files
(de tmp @
   (unless *Tmp
      (push '*Bye '(call "rm" "-r" *Tmp))
      (push '*Fork '(off *Tmp))
      (call "mkdir" "-p"
         (setq *Tmp (pack (path "~/.pil/tmp/") *Pid "/")) ) )
   (pass pack *Tmp) )

### String ###
(de pad (N Val)
   (pack (need N (chop Val) "0")) )

(de align (X . @)
   (pack
      (if (pair X)
         (mapcar
            '((X) (need X (chop (next)) " "))
            X )
         (need X (chop (next)) " ") ) ) )

(de center (X . @)
   (pack
      (if (pair X)
         (let R 0
            (mapcar
               '((X)
                  (let (S (chop (next))  N (>> 1 (+ X (length S))))
                     (prog1
                        (need (+ N R) S " ")
                        (setq R (- X N)) ) ) )
               X ) )
         (let S (chop (next))
            (need (>> 1 (+ X (length S))) S " ") ) ) ) )

### List ###
(de uniq (Lst)
   (let R NIL
      (filter
         '((X)
            (not (idx 'R (cons (hash X) X) T)) )
         Lst ) ) )

### Symbol ###
(de qsym "Sym"
   (cons (val "Sym") (getl "Sym")) )

(de loc (S X)
   (if (and (str? X) (= S X))
      X
      (and
         (pair X)
         (or
            (loc S (car X))
            (loc S (cdr X)) ) ) ) )

(de -symbols ()
   (symbols (cons (intern (opt)) (symbols))) )

(de private ()
   (symbols '(priv) (read)) )

(de local ()
   (symbols (list (car (symbols)))
      (read) ) )

(de export (Sym)
   (symbols (list (or Sym (cadr (symbols))))
      (read) ) )

(de import Lst
   (for Sym Lst
      (unless (== Sym (intern Sym T))
         (quit "Import conflict" Sym) ) )
   Lst )

(de all* (S)
   (sort
      (conc
         (let (L (split (chop S) "~")  N NIL  S)
            (while (cdr L)
               (setq
                  N (intern (pack (car L)) N)
                  S (pack S (++ L) "~") ) )
            (let P (pack (car L))
               (extract
                  '((X) (and (pre? P X) (pack S X)))
                  (all N) ) ) )
         (let P (rot (split (chop S) "/"))
            (setq
               S (pack (car P))
               P (and (cdr P) (pack (glue "/" @) "/")) )
            (extract
               '((X)
                  (when (pre? S X)
                     (let F (pack P X)
                        (if (=T (car (info F)))
                           (pack F "/")
                           F ) ) ) )
               (dir P T) ) ) ) ) )

### Date/Time ###
(de *mon . (jan feb mar apr may jun jul aug sep oct nov dec .))

(de dat$ (Dat C)
   (when (date Dat)
      (pack (car @) C (pad 2 (cadr @)) C (pad 2 (caddr @))) ) )

(de tim$ (Tim F)
   (when (setq Tim (time Tim))
      (pack (pad 2 (car Tim)) ":" (pad 2 (cadr Tim))
         (and F ":")
         (and F (pad 2 (caddr Tim))) ) ) )

(de datSym (Dat)
   (when (date Dat)
      (pack
         (pad 2 (caddr @))
         (get *mon (cadr @))
         (pad 2 (% (car @) 100)) ) ) )

### OOP ###
(de class Lst
   (set (setq *Class (++ Lst)) (type *Class))
   (putl *Class)
   (def *Class Lst) )

(de object ("Sym" "Val" . @)
   (putl "Sym")
   (def "Sym" "Val")
   (while (args)
      (put "Sym" (next) (next)) )
   "Sym" )

(de extend X
   (setq *Class (car X)) )

# Class variables
(de var X
   (if (pair (car X))
      (def (cdar X) (car (++ X)) X)
      (def *Class (++ X) X) )
   X )

(de var: X
   (apply meta X This) )

### Math ###
(de scl ("N" . "Prg")
   (if "Prg"
      (let *Scl "N" (run "Prg"))
      (setq *Scl "N") ) )

# (Knuth Vol.2, p.442)
(de ** (X N)  # N th power of X
   (if (ge0 N)
      (let Y 1
         (loop
            (when (bit? 1 N)
               (setq Y (* Y X)) )
            (T (=0 (setq N (>> 1 N)))
               Y )
            (setq X (* X X)) ) )
      0 ) )

# Accumulate
(de accu ("Var" Key Val)
   (when Val
      (if (assoc Key (val "Var"))
         (con @ (+ Val (cdr @)))
         (push "Var" (cons Key Val)) ) ) )

### REPL ###
(de complete (S)
   (when S
      (setq "*Cmpl"
         (if (=T S)
            (list "   ")
            (flip (all* S)) ) ) )
   (pop '"*Cmpl") )

### Pretty Printing ###
(de pretty (X N)
   (setq N (abs (space (or N 0))))
   (while (and (pair X) (== 'quote (car X)))
      (prin "'")
      (++ X) )
   (cond
      ((atom X) (print X))
      ((memq (car X) '(de dm redef))
         (_pretty
            (spPrt (++ X))
            (spPrt (++ X))
            (prtty1 X N Z) ) )
      ((memq (car X) '(let let?))
         (_pretty
            (cond
               ((atom (car X))
                  (spPrt (++ X))
                  (prtty? (++ X) N) )
               ((>= 12 (size (car X)))
                  (prin " (")
                  (let Z (++ X)
                     (prtty2 Z NIL Z) )
                  (prin ")") )
               (T
                  (nlPrt N)
                  (prin "(")
                  (let Z (++ X)
                     (prtty2 Z (+ N 3) Z) )
                  (prin " )") ) )
            (prtty1 X N Z) ) )
      ((== 'for (car X))
         (_pretty
            (cond
               ((or (atom (car X)) (atom (cdar X)))
                  (spPrt (++ X))
                  (prtty? (++ X) N) )
               ((>= 12 (size (car X)))
                  (spPrt (++ X)) )
               (T
                  (nlPrt N)
                  (prtty0 (++ X) (+ 3 N)) ) )
            (prtty1 X N Z) ) )
      ((== 'if2 (car X))
         (_pretty
            (when (>= 12 (size (head 2 X)))
               (spPrt (++ X))
               (spPrt (++ X)) )
            (prtty1 X N Z) ) )
      ((memq (car X) '(while until do state finally co))
         (prtty3 X N) )
      ((>= 12 (size X))
         (ifn (memq (car X) '(set setq default))
            (print X)
            (prin "(")
            (let Z X
               (printsp (++ X))
               (prtty2 X NIL Z) )
            (prin ")") ) )
      ((memq (car X) '(=: use later recur tab new))
         (_pretty
            (space)
            (print (++ X))
            (prtty1 X N Z) ) )
      ((memq (car X) '(setq default))
         (_pretty
            (if (cdddr X)
               (prog
                  (nlPrt N)
                  (prtty2 X N Z) )
               (spPrt (++ X))
               (nlPrt1 (++ X) N) ) ) )
      ((memq (car X) '(T NIL ! if ifn when unless case casq with catch throw push bind job in out err ctl))
         (prtty3 X N) )
      (T (prtty0 X N)) ) )

(de _pretty "Prg"
   (prin "(")
   (let Z X
      (print (++ X))
      (run "Prg") )
   (prin " )") )

(de prtty0 (X N)
   (prin "(")
   (let Z X
      (pretty (++ X) (- -3 N))
      (prtty1 X N Z) )
   (prin " )") )

(de prtty1 (X N Z)
   (loop
      (NIL X)
      (T (== Z X) (prin " ."))
      (T (atom X) (prin " . ") (print X))
      (nlPrt1 (++ X) N) ) )

(de prtty2 (X N Z)
   (loop
      (print (++ X))
      (NIL X)
      (T (== Z X) (prin " ."))
      (T (atom X) (prin " . ") (print X))
      (if N
         (prtty? (++ X) N)
         (space)
         (print (++ X)) )
      (NIL X)
      (T (== Z X) (prin " ."))
      (T (atom X) (prin " . ") (print X))
      (if N
         (nlPrt N)
         (space 2) ) ) )

(de prtty3 (X N)
   (prin "(")
   (let Z X
      (print (++ X))
      (when (or (atom (car X)) (>= 12 (size (car X))))
         (spPrt (++ X)) )
      (when X
         (prtty1 X N Z)
         (space) ) )
   (prin ")") )

(de prtty? (X N)
   (ifn (or (atom X) (>= 12 (size X)))
      (nlPrt1 X N)
      (spPrt X) ) )

(de spPrt (X)
   (space)
   (print X) )

(de nlPrt (N)
   (prinl)
   (space (+ 3 N)) )

(de nlPrt1 (X N)
   (prinl)
   (pretty X (+ 3 N)) )

(de pp ("X" C)
   (let *Dbg NIL
      (pretty
         (if (or C (pair "X"))
            (cons 'dm "X"
               (if (pair "X")
                  (method (car "X") (cdr "X"))
                  (method "X" C) ) )
            (cons 'de "X" (val "X")) ) )
      (prinl)
      "X" ) )

(de show ("X" . @)
   (let *Dbg NIL
      (setq "X" (pass get "X"))
      (when (sym? "X")
         (print "X" (val "X"))
         (prinl)
         (maps
            '((X)
               (space 3)
               (if (atom X)
                  (println X)
                  (println (cdr X) (car X)) ) )
            "X" ) )
      "X" ) )

(de view (X Y)
   (let *Dbg NIL
      (if (=T Y)
         (let N 0
            (recur (N X)
               (when X
                  (recurse (+ 3 N) (cddr X))
                  (space N)
                  (println (car X))
                  (recurse (+ 3 N) (cadr X)) ) ) )
         (let Z X
            (loop
               (T (atom X) (println X))
               (if (atom (car X))
                  (println '+-- (++ X))
                  (print '+---)
                  (view
                     (++ X)
                     (append Y (cons (if X "|   " "    "))) ) )
               (NIL X)
               (mapc prin Y)
               (T (== Z X) (println '*))
               (println '|)
               (mapc prin Y) ) ) ) ) )

### Check ###
# Assertions
(de assert Prg
   (when *Dbg
      (let A (if (cdr Prg) (cons 'and Prg) (car Prg))
         (cons
            (list 'unless A
               (list 'quit "'assert' failed" (lit A)) ) ) ) ) )

# Unit tests
(de test ("Pat" . "Prg")
   (bind (fish pat? "Pat")
      (unless (match "Pat" (run "Prg"))
         (msg "Prg")
         (quit "'test' failed" "Pat") ) ) )

### Debug ###
`*Dbg

(and (info "~/.pil/rc") (load @@))

(load "@lib/lint.l" "@lib/debug.l" "@lib/vip.l")

(noLint 'pretty 'Z)
(noLint '_pretty 'Z)
