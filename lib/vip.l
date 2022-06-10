# 10jun22 Software Lab. Alexander Burger

(symbols 'vip 'pico)

(sysdefs "unistd")

(load "@lib/term.l")

(local) getSize

(de getSize ()
   (if (getTerm)
      (setq *Lines (car @)  *Columns (cadr @))
      (quit "Can't get terminal size") ) )

(local) (*Ns *Shell *CmdWin *StatNm *Chr *Complete *Repeat *Change *Count *Cnt
*Search *Clip *Lines *Columns *TagStack *Spell *CmdMap *Keys *KeyMap *KeyMap-g
*KeyMap-q *F7 *F8 *F9 *F10 *F11 *F12 *@)

(def '*Shell (or (sys "SHELL") "sh"))

### VIP Editor ###
(local) (*Buffers +Buffer mkLoc fName prName rplFile fileBuffer rdLines delim?
arkup min1 beep undo redo evCmd dirty> load> save> syms> view> status delwin
cursor addLine chgLine unmark redraw repaint scLeft scRight goto chgwin eqwin
getch getch2 reload scratch syms pushTag tag done change jmp@@ cnt@@ goCol
goLeft goRight goUp goDown goAbs goFind tword word lword end lend getWord
_forward goForward _backward goBackward goPFore goPBack shift shiftY indent cutX
cutN paste join tglCase insChar incNum overwrite _bs insMode cmdMode cmdPipe
evRpt move chgRight jmpMark wordFun moveSearch patMatch parMatch spell pipeN
nextBuf shell shFile prCmd reset posChar getText s-expr command vi)


(class +Buffer)
# text file symbols key undo redo dirt
# posX posY lastX lastY subd flat fmt syms <c>

(dm T (File Y)
   (and (=: file File) (queue '*Buffers This))
   (=: symbols (symbols))
   (=: posX 1)
   (=: posY (or Y 1))
   (=: lastX (=: lastY 1))
   (=: fmt 80) )

(de mkLoc (File)
   (let P (conc (chop (pwd)) '("/"))
      (when (head P File)
         (setq File (cdr (nth File (length P)))) ) )
   (if (pat? (car File))
      (cons (name ".") (name "/") File)
      File ) )

(de fName (File)
   (when (setq File (path File))
      (use R
         (when (=0 (%@ "realpath" 'N File '(R (`PATH_MAX C . `PATH_MAX))))
            (setq R (chop File)) )
         (pack (mkLoc R)) ) ) )

(de prName (File)
   (if (pre? (sys "HOME") File)
      (pack "~/" (cddr (nth (chop File) (length (sys "HOME")))))
      File ) )

(de rplFile (File)
   (pack
      (replace (chop File) "%"
         (if (== This *CmdWin)
            (: next buffer file)
            (: buffer file) ) ) ) )

(de fileBuffer (File Y)
   (let F (fName File)
      (prog1
         (or
            (find '((This) (= F (: file))) *Buffers)
            (new '(+Buffer) F Y) )
         (put @ 'subd (<> "/" (last (chop File)))) ) ) )

(de rdLines ()
   (make (until (eof) (link (line)))) )

(de delim? (C Str)
   (or
      (member C '`(cons NIL (chop " \t\n\r\"'(),[]`")))
      (sub? C Str) ) )

(de markup (Lst)
   (let (S 'text  N 1)
      (for L Lst
         (let P NIL
            (while L
               (let? C (++ L)
                  (state 'S
                     (text (and (= "\"" C) 'string)
                        (set C 0) )
                     (text
                        (and
                           (= "#" C)
                           (delim? P)
                           (if L 'comment 'text) )
                        (set C N)
                        (when (= "{" (car L))
                           (set (++ L) (inc 'N)) ) )
                     (text 'text
                        (or
                           (set (setq P C)
                              (and (sp? C) (not L)) )
                           (when (= "\\" C)
                              (let? C (++ L)
                                 (set C (and (sp? C) (not L))) ) ) ) )
                     (string (and (= "\"" C) 'text)
                        (set (setq P C) 0) )
                     (string (and (= "\\" C) (not L) 'skip)
                        (set C T) )
                     (string 'string
                        (set C T)
                        (and (= "\\" C) L (++ L) (set @ T)) )
                     (skip (and (sp? C) 'skip)
                        (set C) )
                     (skip (and (= "\"" C) 'text)
                        (set (setq P C) 0) )
                     (skip 'string
                        (set C T) )
                     (comment
                        (cond
                           ((=1 (set (setq P C) N))
                              (if L
                                 'comment
                                 (and (sp? C) (not L) (set P T))
                                 'text ) )
                           ((and
                                 (= "}" C)
                                 (= "#" (car L))
                                 (=1 (set (++ L) (dec 'N))) )
                              'text )
                           (T
                              (and
                                 (= "#" C)
                                 (= "{" (car L))
                                 (set (++ L) (inc 'N)) )
                              'comment ) ) ) ) ) ) ) ) ) )

(de min1 (A B)
   (max 1 (min A B)) )

(de beep ()
   (pico~beep)
   NIL )

(dm dirty> (Win)
   (<> (: undo) (: dirt)) )

(dm load> (Win)
   (markup
      (=: text
         (let? File (: file)
            (let? I (info File)
               (if (=T (car I))
                  (mapcar
                     '((X)
                        (let (S (cdddr X)  F (caddr X))
                           (conc
                              (mkLoc F)
                              (cond
                                 ((=T S) (chop "/  "))
                                 ((not S)
                                    (conc
                                       (chop " -> ")
                                       (in (list "readlink" F) (line))
                                       (chop "  ") ) )
                                 (T
                                    (conc
                                       (chop " (")
                                       (chop (/ (+ S 1023) 1024))
                                       (chop ")  ") ) ) )
                              (chop (dat$ (- (car X)) "-"))
                              (chop " ")
                              (chop (tim$ (- (cadr X)) T)) ) ) )
                     (sort
                        (make
                           (unless (= "/" (last (setq File (chop File))))
                              (conc File (chop "/")) )
                           (recur (File)
                              (for F (dir File T)
                                 (unless (member F '("." ".."))
                                    (let? I (info (setq F (append File (chop F))) T)
                                       (if (and (=T (car I)) (: subd))
                                          (recurse (conc F (chop "/")))
                                          (link
                                             (cons
                                                (- (cadr I))
                                                (- (cddr I))
                                                F
                                                (car I) ) ) ) ) ) ) ) ) ) )
                  (gc (+ 4 (*/ (car I) 32768)))  # 2 cells / char
                  (if (sys "CCRYPT" (: key))
                     (in (list "ccrypt" "-c" "-ECCRYPT" File)
                        (rdLines) )
                     (in File (rdLines)) ) ) ) ) ) )
   (=: symbols (symbols))
   (=: undo (=: redo (=: dirt)))
   (=: posX
      (min1
         (: posX)
         (length
            (get
               (: text)
               (=: posY (min1 (: posY) (length (: text)))) ) ) ) )
   (when (head '`(chop "# VIP ") (: text 1))
      (let? L (clip (: text 1 -6))
         (evCmd
            (symbols '(vip pico)
               (if (= "(" (car L))
                  (run (str (pack L)))
                  (setq L (split L " "))
                  (apply script (cdr L) (fName (pack (car L)))) ) ) ) ) ) )

(dm save> (Win)
   (when (: file)
      (unless (=T (car (info @)))
         (if (sys "CCRYPT" (: key))
            (pipe
               (out '("ccrypt" "-e" "-ECCRYPT")
                  (mapc prinl (: text)) )
               (out (: file) (echo)) )
            (out (: file) (mapc prinl (: text))) ) )
      (=: dirt (: undo))
      (for (This *CmdWin (setq This (: next)))
         (status) )
      (when (: syms)
         (and (find ext? @) (pico~dbSync))
         (in (: file)
            (while (and (setq "*X" (read)) (atom @))
               (unless (= (val "*X") (setq "*V" (read)))
                  (set "*X" "*V") )
               (until (= '(=======) (setq "*K" (read)))
                  (unless (= (get "*X" "*K") (setq "*V" (read)))
                     (put "*X" "*K" "*V") ) ) ) )
         (when (find ext? (: syms))
            (commit 'pico~upd)
            (syms> This (: syms)) ) ) )
   (on *StatNm) )

(dm syms> ("Lst")
   (out (: file)
      (for "S" (=: syms "Lst")
         (if
            (and
               (ext? "S")
               (not (rank (car (id "S" T)) *Ext))
               (lock "S") )
            (prinl "# " "S" " locked")
            (printsp "S")
            (fish
               '(("X")
                  (if (circ? "X")
                     "skip"
                     (and
                        (str? "X")
                        (or
                           (and (val "X") (n== @ "X"))
                           (getl "X") )
                        (intern "X" 'priv) )
                     NIL ) )
               (cons (val "S") (getl "S"))
               "skip" )
            (pretty (val "S"))
            (prinl)
            (for "X" (sort (getl "S"))
               (space 3)
               (if (atom "X")
                  (println "X" T)
                  (printsp (cdr "X"))
                  (pretty (setq "X" (car "X")) -3)
                  (cond
                     ((type "X")
                        (prin "  # ")
                        (print @) )
                     ((>= 799999 "X" 700000)
                        (prin "  # ")
                        (print (date "X")) ) )
                  (prinl) ) ) )
         (prinl)
         (println '(=======))
         (prinl) ) ) )

(dm view> (Win)
   (beep) )


(local) (*Window +Window)

(class +Window)
# buffer top lines winX winY posX posY prev next last mark sc

(dm T (Buffer Top Lines WinX WinY PosX PosY Prev Mark)
   (=: buffer Buffer)
   (=: top Top)
   (=: lines Lines)
   (when (=: prev Prev)
      (when (=: next (: prev next))
         (=: next prev This) )
      (=: prev next This) )
   (=: winX WinX)
   (=: winY WinY)
   (=: posX PosX)
   (=: posY PosY)
   (=: mark Mark)
   (=: sc 0) )

(dm view> ()
   (view> (: buffer) This) )

(de delwin ()
   (when (=: prev next (: next))
      (=: next prev (: prev)) ) )

(de cursor ()
   (cup
      (+ (: top) (- (: posY) (: winY) -1))
      (- (: posX) (: winX) -1) ) )

(de addLine (Y L N)
   (cup (+ (: top) Y) 1)
   (clreol)
   (for C (nth L (: winX))
      (T (lt0 (dec 'N)))
      (cond
         ((: buffer flat))
         ((=T (val C))
            (ifn (>= "^_" C "^A")
               (attr NIL T)
               (setq C (char (+ 64 (char C))))
               (attr RED T) ) )
         ((>= "^_" C "^A")
            (setq C (char (+ 64 (char C))))
            (attr RED) )
         ((gt0 (val C))
            (attr CYAN) )
         (T (attr)) )
      (prin C) )
   (attr) )

(de chgLine (L)
   (addLine (- (: posY) (: winY) -1) L *Columns)
   (cursor) )

(de unmark ()
   (when (: mark)
      (out @ (println (: posX) (: posY)))
      (=: mark) ) )

(de status ()
   (unless (== This *CmdWin)
      (cup (+ (: top) (: lines) 1) 1)
      (let
         (N (length (: buffer text))
            A (pack
               (index (: buffer) *Buffers)
               "/"
               (length *Buffers)
               (if (dirty> (: buffer) This) " * " " ") )
            F (prName (: buffer file))
            Z (pack
               (and (: mark) (cons @ " "))
               (casq (: buffer symbols 1)
                  (pico)
                  (T (cons @ " ")) )
               (: posX) "," (: posY) "/" N " "
               (if (gt0 (dec N))
                  (*/ 100 (dec (: posY)) @)
                  0 )
               "%" ) )
         (attr REVERS)
         (cond
            ((ge0
                  (setq N
                     (- *Columns (length A) (length F) (length Z)) ) )
               (prin A F (need N " ") Z) )
            ((onOff *StatNm)
               (prin (align (- *Columns) (tail *Columns (chop F)))) )
            (T
               (prin
                  A
                  (need (- *Columns (length A) (length Z)) " ")
                  Z ) ) )
         (attr)
         (flush) ) ) )

(de redraw ()
   (hideCsr)
   (let L (nth (: buffer text) (: winY))
      (for Y (: lines)
         (addLine Y (++ L) *Columns) ) )
   (showCsr)
   (status) )

(de repaint ()
   (for (This *CmdWin This (: next))
      (redraw) ) )

(de scLeft (N)
   (and
      (> (: winX) 1)
      (>= (- (: posX) (dec (:: winX))) *Columns)
      (dec (:: posX)) ) )

(de scRight (N)
   (cond
      ((> (: posX) (: winX))
         (inc (:: winX)) )
      ((cdr (nth (: buffer text) (: posY) (: posX)))
         (inc (:: posX))
         (inc (:: winX)) )
      (T
         (for (Y . L) (cdr (nth (: buffer text) (: posY)))
            (T (cdr (nth L (: posX)))
               (inc (:: posY) Y) )
            (T (= Y (: lines))) ) ) ) )

(de goto (X Y F)
   (=: buffer posX (=: posX X))
   (setq X
      (cond
         ((and F
               (>= (inc (: posY)) Y (dec (: posY)))
               (>= (+ (: winX) *Columns -1) X (: winX)) )
            (: winX) )
         ((>= (*/ *Columns 3 4) X) 1)
         (T (- X (/ *Columns 2))) ) )
   (=: buffer posY (=: posY Y))
   (setq Y
      (min1
         (- Y (/ (: lines) 2))
         (- (length (: buffer text)) (: lines) -1) ) )
   (if (and F (= X (: winX)) (= Y (: winY)))
      (status)
      (=: winX X)
      (=: winY Y)
      (redraw) ) )

(de chgwin (Lines Top)
   (=: lines Lines)
   (and Top (=: top @))
   (=: winY
      (min1
         (- (: posY) (/ (: lines) 2))
         (- (length (: buffer text)) (: lines) -1) ) )
   (redraw) )

(de eqwin ()
   (let
      (H (dec *Lines)
         D (*/ H
            (let N 0
               (for (This *CmdWin (: next) @)
                  (inc 'N) ) ) ) )
      (with *CmdWin (chgwin 1 H))
      (when (>= D 3)
         (for (This *CmdWin (setq This (: next)))
            (if (: next)
               (chgwin (dec D) (dec 'H D))
               (chgwin (dec H) 0) ) ) )
      (cursor) ) )

(de getch ()
   (symbols *Ns
      (if (= "\e" (setq *Chr (or (++ *Keys) (key))))
         (when (or (++ *Keys) (key 120))
            (loop
               (setq *Chr (pack *Chr @))
               (T (member *Chr '("\e[A" "\e[B" "\e[C" "\e[D")) *Chr)
               (NIL (or (++ *Keys) (key 120)) *Chr) ) )
         *Chr ) ) )

(de getch2 (C)
   (if (= "^V" C)
      (or (++ *Keys) (symbols *Ns (key)))
      C ) )

(de reload (File Y X)
   (unless (== This *CmdWin)
      (when File
         (unless
            (==
               (=: last (: buffer))
               (=: buffer (fileBuffer File)) )
            (unmark) ) )
      (load> (: buffer) This)
      (off *StatNm)
      (goto
         (or X (: buffer posX))
         (or Y (: buffer posY)) )
      (repaint) ) )

(de scratch (File Lst Y)
   (setq File (fName File))
   (if (find '((This) (= File (: file))) *Buffers)
      (put @ 'text Lst)
      (=: last (: buffer))
      (unmark)
      (put
         (=: buffer (new '(+Buffer) File Y))
         'text
         Lst )
      (goto 1 (: buffer posY)) )
   (repaint) )

(de syms ("Lst")
   (prog1
      (tmp "syms")
      (syms> (fileBuffer @) "Lst") ) )

(de pushTag (File)
   (push '*TagStack (: posX) (: posY) File (symbols)) )

(de tag (S C)
   (ifn
      (if C
         (or
            (get C '*Dbg -1 S)
            (meta C '*Dbg -1 S) )
         (get S '*Dbg 1) )
      (beep)
      (pushTag (: buffer file))
      (apply symbols (cddr @))
      (reload (cadr @) (car @) 1) ) )

(de done (Flg)
   (and Flg
      (dirty> (: buffer) This)
      (save> (: buffer) This) )
   (unmark)
   (nond
      ((; *CmdWin next next)
         (screen1)
         (rollback)
         (throw 'done Flg) )
      ((n== This *CmdWin))
      ((== This (; *CmdWin next))
         (delwin)
         (let (N (: lines)  Top (: top))
            (with (setq *Window (: prev))
               (chgwin (+ 1 N (: lines)) Top) ) ) )
      (NIL
         (delwin)
         (let N (: lines)
            (with (setq *Window (: next))
               (chgwin (+ 1 N (: lines))) ) ) ) ) )

(de change Prg
   (let
      (Pos (nth (: buffer text) (: posY))
         Env
         (env
            'PosX1 (: posX)  'PosY1 (: posY)
            'OldA (car Pos)  'OldD (cdr Pos)
            'NewD (: buffer text)
            '(Pos PosX2 PosY2 NewA) ) )
      (let? Res
         (job Env
            (prog1
               (run Prg)
               (setq
                  PosX2 (: posX)  PosY2 (: posY)
                  NewA (if Pos (car @) (: buffer text)) )
               (and Pos (setq NewD (cdr @))) ) )
         (=: buffer redo NIL)
         (push (:: buffer undo)
            (cons Env
               '(ifn Pos
                  (=: buffer text NewD)
                  (set Pos OldA)
                  (con Pos OldD) )
               '(ifn Pos
                  (=: buffer text NewA)
                  (set Pos NewA)
                  (con Pos NewD) ) ) )
         (markup (: buffer text))
         (goto (: posX) (: posY))
         (repaint)
         Res ) ) )

(de undo ()
   (ifn (pop (:: buffer undo))
      (beep)
      (let U @
         (push (:: buffer redo) U)
         (bind (car U)
            (eval (cadr U))
            (markup (: buffer text))
            (goto PosX1 PosY1)
            (repaint) ) ) ) )

(de redo ()
   (ifn (pop (:: buffer redo))
      (beep)
      (let R @
         (push (:: buffer undo) R)
         (bind (car R)
            (eval (cddr R))
            (markup (: buffer text))
            (goto PosX2 PosY2)
            (repaint) ) ) ) )

(de jmp@@ (Y)
   (=: buffer lastX (: posX))
   (=: buffer lastY (: posY))
   (setq @@ Y) )

(de cnt@@ ()
   (- @@ (: posY) -1) )

(de goCol (N)
   (setq @@ (: posY))
   N )

(de goLeft (N)
   (goCol (max 1 (- (: posX) N))) )

(de goRight (N I)
   (goCol
      (min1
         (or (=T N) (+ (: posX) N))
         (+
            (or I 0)
            (length (get (: buffer text) (: posY))) ) ) ) )

(de goUp (N)
   (setq @@ (max 1 (- (: posY) N)))
   (min1 (: posX) (length (get (: buffer text) @@))) )

(de goDown (N I)
   (setq @@
      (min1
         (or (=T N) (+ (: posY) N))
         (+ (or I 0) (length (: buffer text))) ) )
   (min1 (: posX) (length (get (: buffer text) @@))) )

(de goAbs (X Y I)
   (jmp@@
      (min1 Y
         (+ (or I 0) (length (: buffer text))) ) )
   (min1 X (length (get (: buffer text) @@))) )

(de goFind (C D N I)
   (setq @@ (: posY))
   (let (Lst (get (: buffer text) (: posY))  L (nth Lst (: posX)))
      (do N (setq L (member C (cdr L))))
      (if L
         (+ D (or I 0) (offset L Lst))
         (beep) ) ) )

(de tword (L)
   (and
      (delim? (car L))
      (or
         (sub? (cadr L) "\"()[]")
         (not (delim? (cadr L))) ) ) )

(de word (L C)
   (and
      (delim? C)
      (or
         (sub? (car L) "\"()[]")
         (not (delim? (car L))) ) ) )

(de lword (L C)
   (and (sp? C) (not (sp? (car L))) ) )

(de end (L)
   (and (not (delim? (car L))) (delim? (cadr L))) )

(de lend (L)
   (and (not (sp? (car L))) (sp? (cadr L))) )

(de getWord (Flg)
   (make
      (let Lst (get (: buffer text) (: posY))
         (when Flg
            (for C (nth Lst (: posX))
               (T (delim? C))
               (link C) ) )
         (for
            (L (nth Lst (dec (: posX)))
               (not (delim? (car L)))
               (prior L Lst) )
            (yoke (car L)) ) ) ) )

(de _forward (Lst C)
   (for ((X . L) Lst  L  (cdr L))
      (T (and (Fun L C) (=0 (dec 'N)))
         (jmp@@ Y)
         (+ (or I 0) X) )
      (setq C (car L))
      NIL ) )

(de goForward (Fun N I)
   (let (Y (: posY)  Pos (nth (: buffer text) Y)  L (nth (++ Pos) (: posX)))
      (if (_forward (cdr L) (car L))
         (+ (: posX) @)
         (loop
            (NIL Pos (beep))
            (inc 'Y)
            (T (_forward (++ Pos)) @) ) ) ) )

(de _backward (Lst L)
   (use P
      (loop
         (NIL L)
         (setq P (prior L Lst))
         (T (and (Fun L (car P)) (=0 (dec 'N)))
            (jmp@@ Y)
            (offset L Lst) )
         (setq L P)
         NIL ) ) )

(de goBackward (Fun N)
   (let (Y (: posY)  Pos (nth (: buffer text) Y))
      (or
         (_backward
            (car Pos)
            (nth (car Pos) (dec (: posX))) )
         (loop
            (NIL (setq Pos (prior Pos (: buffer text)))
               (beep) )
            (dec 'Y)
            (T (_backward (car Pos) (tail 1 (car Pos))) @ ) ) ) ) )

(de goPFore (Cnt D I)
   (let (Y (: posY)  Pos (nth (: buffer text) Y))
      (loop
         (NIL (cdr Pos)
            (jmp@@ Y)
            (max 1 (+ (or I 0) (length (car Pos)))) )
         (inc 'Y)
         (T
            (and
               (car Pos)
               (not (cadr Pos))
               (=0 (dec 'Cnt)) )
            (jmp@@ (+ Y D))
            1 )
         (++ Pos) ) ) )

(de goPBack (Cnt)
   (let (Y (: posY)  Pos (nth (: buffer text) Y))
      (loop
         (NIL (setq Pos (prior Pos (: buffer text))))
         (dec 'Y)
         (T
            (and
               (not (car Pos))
               (cadr Pos)
               (=0 (dec 'Cnt)) ) ) )
      (jmp@@ Y)
      1 ) )

(de shift (N Flg)
   (change
      (let? P Pos
         (do N
            (when (car P)
               (if Flg
                  (do 3 (push P (name " ")))
                  (do 3
                     (NIL (sp? (caar P)))
                     (pop P) ) ) )
            (NIL (cdr P))
            (setq P (con P (cons (car @) (cdr @)))) )
         (=: posX 1) ) ) )

(de shiftY (X Flg)
   (shift (cnt@@) Flg) )

(de indent ()
   (change
      (let? P Pos
         (when (clip (car P))
            (let (N (*/ (offset @ (trim (car P))) 3)  Sup N)
               (set P @)
               (loop
                  (do (* N 3) (push P (name " ")))
                  (for C (car P)
                     (unless (val C)
                        (case C
                           ("(" (inc 'N))
                           (")" (dec 'N))
                           ("[" (push 'Sup N) (inc 'N))
                           ("]" (setq N (++ Sup))) ) ) )
                  (while (val (caadr P))
                     (++ P) )
                  (NIL (clip (cadr P)) T)
                  (setq P (con P (cons @ (cddr P)))) ) ) ) ) ) )

(de cutX (X Flg)
   (when X
      (let Y @@
         (unless (> (list Y X) (list (: posY) (: posX)))
            (xchg 'X (:: posX)  'Y (:: posY)) )
         (change
            (when Pos
               (let (L (car Pos)  DX (: posX))
                  (and
                     (set *Clip
                        (make
                           (if Flg
                              (set Pos (cut (dec DX) 'L))
                              (setq L (nth L DX)) )
                           (while (>= (dec 'Y) (: posY))
                              (link L)
                              (setq L (cadr Pos))
                              (if Flg
                                 (con Pos (cddr Pos))
                                 (++ Pos) )
                              (one DX) )
                           (link (cut (- X DX) 'L))
                           (when Flg
                              (set Pos (conc (car Pos) L))
                              (=: posX (min1 (: posX) (length (car Pos)))) )
                           (setq @@ (unless L 1)) ) )
                     Flg ) ) ) ) ) ) )

(de cutN (N)
   (change
      (when Pos
         (off @@)
         (set *Clip
            (cons T
               (if (setq Pos (prior Pos (: buffer text)))
                  (make
                     (setq OldA (car @)  OldD (cdr @))
                     (do N
                        (link (cadr Pos))
                        (NIL (con Pos (cddr Pos))
                           (one @@)
                           (dec (:: posY)) ) )
                     (=: posX 1) )
                  (cut N (:: buffer text)) ) ) ) ) ) )

(de paste (Lst Flg)
   (change
      (let P (or Pos (=: buffer text (cons)))
         (ifn (=T (car Lst))
            (let L (car P)
               (cond
                  ((=0 Flg) (setq PosX1 (=: posX 1)))
                  ((=1 Flg)
                     (and
                        (get (: buffer text) (: posY) 1)
                        (get (: buffer text) (: posY) (inc (:: posX)))
                        (inc 'PosX1) ) )
                  (Flg
                     (=: posX
                        (max 1
                           (inc (length (get (: buffer text) (: posY)))) ) ) ) )
               (set P
                  (conc (cut (dec (: posX)) 'L) (mapcar name (++ Lst))) )
               (for S Lst
                  (setq P (con P (cons (mapcar name S) (cdr P))))
                  (inc (:: posY)) )
               (=: posX (max 1 (length (car P))))
               (set P (append (car P) L)) )
            (=: posX 1)
            (ifn Flg
               (for L (cdr Lst)
                  (con P (cons (car P) (cdr P)))
                  (set P (mapcar name L))
                  (setq P (cdr P)) )
               (inc (:: posY))
               (for L (cdr Lst)
                  (setq P (con P (cons (mapcar name L) (cdr P)))) ) ) )
         T ) ) )

(de join (Cnt)
   (change
      (do Cnt
         (NIL (cdr Pos))
         (set Pos
            (append
               (car Pos)
               (cons (name " ") (clip (cadr Pos))) ) )
         (con Pos (cddr Pos)) )
      T ) )

(de tglCase (Cnt)
   (change
      (let? C (get Pos 1 (: posX))
         (do Cnt
            (set Pos
               (place (: posX) (car Pos)
                  ((if (upp? C) lowc uppc) C) ) )
            (NIL (setq C (get Pos 1 (inc (: posX)))))
            (inc (:: posX)) )
         T ) ) )

(de insChar (C Cnt)
   (change
      (when (car Pos)
         (do Cnt
            (set Pos (place (: posX) (car Pos) (name C)))
            (NIL (get Pos 1 (inc (:: posX)))) )
         (dec (:: posX)) ) ) )

(de incNum (Cnt)
   (change
      (let (I (: posX)  L (car Pos)  S (get L I))
         (ifn (format S)
            (set Pos
               (place (: posX) L (char (+ Cnt (char S)))) )
            (while
               (and
                  (gt0 (dec 'I))
                  (format (get L @)) )
               (setq S (pack @ S)) )
            (inc (:: posX)
               (-
                  (length
                     (set Pos
                        (conc
                           (head I L)
                           (need
                              (if (= `(char "0") (char S)) (length S) 1)
                              (chop (max 0 (+ Cnt (format S))))
                              (name "0") )
                           (tail (- (: posX)) L) ) ) )
                  (length L) ) ) ) ) ) )

(de overwrite (Lst)
   (change
      (let
         (P (or Pos (=: buffer text (cons)))
            L (conc (cut (dec (: posX)) P) (car Lst)) )
         (set P
            (append L
               (cdr (nth (car P) (length (++ Lst)))) ) )
         (=: posX (max 1 (length L))) ) ) )

(de _bs ()
   (++ Chg)
   (dec (:: posX))
   (unless Rpl
      (set P (remove (: posX) (car P))) ) )

(de insMode (Flg Win Rpl . @)
   (change
      (let (P (or Pos (=: buffer text (cons)))  Chg)
         (cond
            ((=0 Flg)
               (con P (cons (car P) (cdr P)))
               (set P)
               (goto 1 (: posY)) )
            ((=1 Flg))
            (Flg
               (setq P (con P (cons NIL (cdr P))))
               (goto 1 (inc (: posY)))
               (setq Chg (0)) ) )
         (cursor)
         (off *Complete)
         (while
            (case (or (next) (getch))
               (NIL)
               (("\n" "\r")
                  (cond
                     (Rpl (beep) T)
                     ((== This *CmdWin)
                        (nil (command (or Win This) (car P))) )
                     (T
                        (push 'Chg 0)
                        (con P
                           (cons (nth (car P) (: posX)) (cdr P)) )
                        (set P (head (dec (: posX)) (car P)))
                        (setq P (cdr P))
                        (goto 1 (inc (: posY)))
                        (cursor)
                        T ) ) )
               (("\b" "^?")  # [BACKSPACE]
                  (when (and Chg (n0 (car Chg)))
                     (_bs)
                     (chgLine (car P)) )
                  T )
               (T
                  (let S (list @)
                     (cond
                        ((<> @ "\t") (off *Complete))
                        ((= '(":" " ") (get (: buffer text) (: posY)))
                           (setq S
                              (chop (car (rot (setq *Complete (history))))) ) )
                        ((or Rpl (nor *Complete (setq S (pack (getWord)))))
                           (setq S
                              (make
                                 (do (- 3 (% (dec (: posX)) 3))
                                    (link (name " ")) ) ) ) )
                        (T
                           (default *Complete (cons S (flip (all* S))))
                           (do (length (car *Complete)) (_bs))
                           (setq S (chop (car (rot *Complete)))) ) )
                     (when (= "^V" (car S))
                        (set S (or (next) (getch2 "^V"))) )
                     (for C S
                        (push 'Chg C)
                        (set P
                           ((if (and Rpl (car P)) place insert)
                              (: posX)
                              (car P)
                              C ) )
                        (inc (:: posX)) )
                     (goto (: posX) (: posY) T) )
                  (chgLine (car P))
                  T ) ) )
         (=: posX (max 1 (dec (: posX))))
         (cond
            ((=0 Flg) (push 'Chg 0))
            ((=1 Flg) (and (> PosX1 1) (dec 'PosX1))) )
         (split (reverse Chg) 0) ) ) )

(de cmdMode @
   (let Win (if (== This *CmdWin) (: next) This)
      (with *CmdWin
         (pass insMode (: buffer text) Win NIL) ) ) )

(de cmdPipe (N)
   (apply cmdMode (chop (pack ":" N "!"))) )

(de evRpt (Exe)
   (eval (setq *Repeat Exe) 1) )

(de move @
   (let M (conc (rest) (1))
      (case *Change
         (NIL (and (eval (rest)) (goto @ @@ T)))
         ("!" (eval (rest)) (cmdPipe (cnt@@)))  # External filter
         (">" (evRpt (list 'shiftY M T)))  # Shift right
         ("<" (evRpt (list 'shiftY M)))  # Shift left
         ("c"  # Change
            (when (cutX (eval M) T)
               (and @@
                  (get (: buffer text) (: posY) 1)
                  (inc (:: posX)) )
               (let L (insMode @@)
                  (setq *Repeat
                     (list 'prog
                        (list 'cutX M T)
                        (list 'paste (lit L) '@@)) ) ) ) )
         ("d" (evRpt (list 'cutX M T)))  # Delete
         ("y" (cutX (eval M)))  # Yank
         (T (beep)) ) ) )

(de chgRight (X)
   (setq *Change "c")
   (move 'goRight X) )

(de jmpMark (C D X)
   (cond
      ((= C D)
         (move 'goAbs
            (or X (: buffer lastX))
            (: buffer lastY) ) )
      ((get (: buffer) (intern C))
         (move 'goAbs (default X (car @)) (cdr @)) ) ) )

(de wordFun (@W)
   (setq *Search
      (let @N (inc (length @W))
         (curry (@W @N) (L C)
            (and
               (delim? C "~")
               (head '@W L)
               (delim? (get L @N) "~") ) ) ) ) )

(de moveSearch (Fun1 Fun2)
   (move Fun1 (lit Fun2) *Cnt) )

(de patMatch (Fun @Pat)
   (moveSearch Fun
      (setq *Search
         (ifn (= "\\" (car @Pat))
            (let @Lst 'L
               (when (= "~" (car @Pat))
                  (setq
                     @Pat (mapcar lowc (cdr @Pat))
                     @Lst '(mapcar lowc L) ) )
               (if
                  (nor
                     (= "\^" (car @Pat))
                     (= "$" (last @Pat))
                     (find pat? @Pat) )
                  (curry (@Pat @Lst) (L)
                     (head '@Pat @Lst) )
                  (setq @Pat
                     (if (= "$" (last @Pat))
                        (head -1 @Pat)
                        (append @Pat '(@)) ) )
                  (ifn (= "\^" (car @Pat))
                     (curry (@Pat @Lst) (L)
                        (match '@Pat @Lst) )
                     (++ @Pat)
                     (curry (@Pat @Lst) (L C)
                        (unless C (match '@Pat @Lst)) ) ) ) )
            (++ @Pat)
            (curry (@Pat) (L)
               (head '@Pat L) ) ) ) ) )

(de parMatch (Fun1 @Par1 @Sup1 @ParO @ParC @SupO @SupC)
   (moveSearch Fun1
      (let (Par @Par1  Sup @Sup1)
         (curry (Par Sup @Par1 @Sup1 @ParO @ParC @SupO @SupC) (L C)
            (unless (caar L)
               (and
                  (case (car L)
                     (@ParO (nil (inc 'Par)))
                     (@ParC (or (not C) (= (dec 'Par) 0 Sup)))
                     (@SupO (nil (push 'Sup Par) (zero Par)))
                     (@SupC
                        (or
                           (not C)
                           (= (setq Par (++ Sup)) 0 Sup) ) ) )
                  (setq Par @Par1  Sup @Sup1) ) ) ) ) ) )

(de *Spell
   "hunspell" "-l" "-d" "en_US,de_DE" )

(de spell ()
   (let? @W
      (pipe
         (out *Spell
            (let Pos (nth (: buffer text) (: posY))
               (prinl
                  (seek
                     '((L) (not (fold (car L))))
                     (nth (++ Pos) (: posX)) ) )
               (mapc prinl Pos) ) )
         (line) )
      (let @N (inc (length @W))
         (moveSearch 'goForward
            (setq *Search
               (curry (@W @N) (L C)
                  (and
                     (not (fold C))
                     (head '@W L)
                     (not (fold (get L @N))) ) ) ) ) ) ) )

(de pipeN (Cnt Line)
   (evRpt
      (fill
         '(when (cdr (cutN Cnt))
            (pipe (out (list *Shell "-c" Line) (mapc prinl @))
               (paste (cons T (rdLines)) @@) ) )
         '(Line Cnt) ) ) )

(de nextBuf (B)
   (let? M (member (: buffer) *Buffers)
      (=: last (: buffer))
      (unmark)
      (=: buffer
         (nond
            (B (car (or (cdr M) *Buffers)))
            ((=T B) B)
            (NIL
               (car (or (prior M *Buffers) (tail 1 *Buffers))) ) ) )
      (unless (: buffer text)
         (load> (: buffer) This) )
      (off *StatNm)
      (goto (: buffer posX) (: buffer posY)) ) )

(de shell (S)
   (screen1)
   (do *Columns (prin "#"))
   (call *Shell "-c" S)
   (prin "[====] ")
   (flush)
   (getch)
   (prinl)
   (screen2)
   (repaint) )

(de shFile (S)
   (when (: buffer file)
      (shell (text S @ *Cnt)) ) )

(de prCmd (L)
   (with *CmdWin
      (paste (cons T L) (: buffer text))
      (inc (:: posY) (dec (length L))) ) )

(de evCmd Prg
   (out (tmp "repl")
      (err NIL
         (catch '(NIL)
            (setq *@ (run Prg 1)  *Msg)
            (println '-> *@) ) )
      (when *Msg
         (prin "!? ")
         (println ^)
         (prinl *Msg) ) )
   (in (tmp "repl")
      (prCmd (rdLines)) ) )

(de posChar ()
   (get (: buffer text) (: posY) (: posX)) )

(de getText Prg
   (let (*Change "y"  *Clip (box))
      (run Prg 1)
      (glue "\n" (val *Clip)) ) )

(de s-expr ()
   (any
      (getText
         (case (posChar)
            ("\"" (move 'goFind "\"" 0 1))
            ("(" (parMatch 'goForward 1 0 "(" ")" "[" "]"))
            ("[" (parMatch 'goForward 0 (0 . 0) "(" ")" "[" "]"))
            (T (move 'goForward 'end 1)) ) ) ) )

(de reset ()
   (off *Count *Change)
   (setq *Clip '\"\") )

### Commands ###
(de command (This Line)
   (case (++ Line)
      ("/" (patMatch 'goForward Line))  # Search forward
      ("?" (patMatch 'goBackward Line))  # Search backward
      ("&" (moveSearch 'goForward (wordFun Line)))  # Search word
      (":"
         (let Cnt 0
            (while (format (car Line))
               (setq Cnt (+ @ (* 10 Cnt)))
               (++ Line) )
            (let C (++ Line)
               (when (>= "z" C "a")
                  (until (sp? (car Line))
                     (setq C (pack C (++ Line))) ) )
               (let L (pack (clip Line))
                  (if (assoc C *CmdMap)
                     ((cdr @) L Line Cnt)
                     (case C
                        (" "  # Eval
                           (setq @ *@)
                           (evCmd (run (str L))) )
                        ("$"  # Shell command
                           (scratch (tmp "cmd")
                              (in (list *Shell "-c" (rplFile L))
                                 (rdLines) ) ) )
                        ("!"  # External filter
                           (when L
                              (if (=0 Cnt)
                                 (shell (rplFile L))
                                 (pipeN Cnt L) ) ) )
                        ("cp"  # Copy to system clipboard
                           (out '("copy")  # System dependent script
                              (let V (val *Clip)
                                 (if (=T (car V))
                                    (mapc prinl (cdr V))
                                    (map
                                       '(((S . L)) (prin S (and L "\n")))
                                       V ) ) ) ) )
                        ("ix.io"  # Paste to http://ix.io
                           (pipe
                              (out '("curl" "-sF" "f:1=<-" "ix.io")
                                 (mapc prinl (: buffer text)) )
                              (prCmd (rdLines)) ) )
                        ("bak" (shFile "mv @1 @1- && cp -p @1- @1"))  # Backup to <file>-
                        ("kab"  # Restore from <file>-
                           (shFile "mv @1- @1 && cp -p @1 @1-")
                           (reload) )
                        ("ls"  # List buffers
                           (prCmd
                              (make
                                 (for (I . This) *Buffers
                                    (link
                                       (chop (pack ":" I " " (prName (: file)))) ) ) ) ) )
                        ("key" (=: buffer key L) (reload))
                        ("m"
                           (when (info (=: mark (fName (rplFile L))))
                              (in (: mark) (move 'goAbs (read) (read))) ) )
                        ("n" (nextBuf))  # Next buffer
                        ("N" (nextBuf T))  # Previous buffer
                        (("ta" "tag") (apply tag (str L)))
                        ("v" (reload (syms (str L)) 1 1))
                        ("e" (reload (rplFile L)))  # (Edit) Reload buffer
                        ("E"  # (Edit) Toggle subdir recursion and reload buffer
                           (=: buffer subd (not (: buffer subd)))
                           (reload (rplFile L)) )
                        ("r"  # Read file contents
                           (let F (fName (rplFile L))
                              (when (info F)
                                 (in F (paste (cons T (rdLines)) 1)) ) ) )
                        ("w"  # (Write) Save buffer
                           (if L
                              (out (fName (rplFile @))
                                 (mapc prinl (: buffer text)) )
                              (save> (: buffer) This) ) )
                        ("l"  # (load) Save and load
                           (when (: buffer file)
                              (when (dirty> (: buffer) This)
                                 (save> (: buffer) This) )
                              (evCmd (load (: buffer file))) ) )
                        ("x" (done T))  # (Exit) Save buffer and close window
                        ("q" (done))  # (Quit) Close window
                        ("bx"  # Buffer exchange
                           (let X (memq (: buffer) *Buffers)
                              (if (cdr X)
                                 (xchg X @)
                                 (beep) ) ) )
                        ("bd"  # Buffer delete
                           (when (cdr *Buffers)
                              (let Buf (: buffer)
                                 (for (This *CmdWin (setq This (: next)))
                                    (when (== Buf (: buffer))
                                       (nextBuf) ) )
                                 (del Buf '*Buffers)
                                 (=: last) ) ) )
                        ("map"  # Add/remove key mappings
                           (++ Line)
                           (let C (++ Line)
                              (until (sp? (car Line))
                                 (setq C (pack C (++ Line))) )
                              (if Line
                                 (push '*KeyMap
                                    (list C
                                       (list 'setq '*Keys
                                          (lit (mapcar name (cdr Line))) ) ) )
                                 (del (assoc C *KeyMap) '*KeyMap) ) ) )
                        (T
                           (if (get *Buffers Cnt)
                              (nextBuf @)
                              (beep) ) ) ) ) ) ) )
         (with *CmdWin
            (redraw) ) )
      (T (beep)) ) )

### VIP Entry Point ###
(de vi ("Lst")  # (file (pat . file) (99 . file) (T . file) (sym [sym ..])
   (getSize)
   (and "Lst" (co 'vip))
   (co 'vip
      (off *Buffers)
      (when (=0 (%@ "isatty" 'I 0))
         (with (fileBuffer (tmp "stdin"))
            (out (: file) (in 0 (echo))) )
         (ctty "/dev/tty") )
      (for "X" "Lst"
         (cond
            ((not "X"))
            ((atom "X") (fileBuffer "X"))  # Path name
            ((pair (car "X"))  # Pattern
               (wordFun @)
               (fileBuffer (cdr "X")) )
            ((or (num? (car "X")) (=T (car "X")))  # Line number
               (fileBuffer (cdr "X") @) )
            (T (syms "X")) ) )  # List of symbols
      (unless *Buffers
         (fileBuffer (tmp "empty")) )
      (screen2)
      (let
         (*Winch '((getSize) (eqwin) (flush))
            *TStp1 '((screen1))
            *TStp2 '((screen2) (repaint) (cursor) (flush)) )
         (reset)
         (setq *CmdWin
            (new '(+Window) (new '(+Buffer)) (dec *Lines) 1 1 1 1 1) )
         (with (car *Buffers)
            (load> This)
            (setq *Window
               (new '(+Window) This
                  0 (- *Lines 2)
                  1
                  (min1
                     (- (: posY) (/ (- *Lines 2) 2))
                     (- (length (: text)) *Lines -3) )
                  1 (: posY)
                  *CmdWin ) ) )
         (with *Window (redraw))
         (catch 'done
            (loop
               (setq *Cnt (max 1 (format *Count)))
               (with *Window
                  (=: posX
                     (min1 (: posX)
                        (length
                           (get (: buffer text)
                              (=: posY
                                 (min1 (: posY) (length (: buffer text))) ) ) ) ) )
                  (symbols (: buffer symbols))
                  (when
                     (or
                        (> (: winX) (: posX))
                        (> (: winY) (: posY)) )
                     (=: winX (min1 (: posX) (: winX)))
                     (=: winY (min1 (: posY) (: winY)))
                     (redraw) )
                  (cursor)
                  (case (getch)
                     ("0"
                        (if *Count
                           (queue '*Count "0")
                           (move 'goAbs 1 (: posY))  # Go to beginning of line
                           (off *Change) ) )
                     (("1" "2" "3" "4" "5" "6" "7" "8" "9")  # ["Count" prefix]
                        (queue '*Count *Chr) )
                     ("\"" (setq *Clip (intern (pack '"\"" (getch)))))  # "Register" prefix
                     (("!" "<" ">" "c" "d" "y")  # ["Change" prefix]
                        (cond
                           ((= *Chr *Change)
                              (case *Chr
                                 ("!" (cmdPipe *Cnt))  # [!!] External filter
                                 (">" (evRpt (list 'shift *Cnt T)))  # [>>] Shift line(s) right
                                 ("<" (evRpt (list 'shift *Cnt)))  # [<<] Shift line(s) left
                                 ("c" (=: posX 1) (chgRight T))  # [cc] Change whole line
                                 ("d" (evRpt (list 'cutN *Cnt)))  # [dd] Delete line(s)
                                 ("y"  # [yy] Yank line(s)
                                    (set *Clip
                                       (cons T
                                          (head *Cnt (nth (: buffer text) (: posY))) ) ) ) )
                              (reset) )
                           (*Change (off *Change))
                           (T (setq *Change *Chr)) ) )
                     (T
                        (if (assoc *Chr *KeyMap)
                           (run (cdr @))
                           (case *Chr
                              (NIL)
                              (("\n" "\r")
                                 (if (== This *CmdWin)
                                    (command (: next) (get (: buffer text) (: posY)))
                                    (goto 1 (inc (: posY)) T)  # Go to next line
                                    (do (: sc) (scRight))
                                    (redraw) ) )
                              ("." (if *Repeat (eval @) (beep)))  # Repeat last change
                              (("j" "\e[B") (move 'goDown *Cnt))  # [DOWN] Move down
                              (("^F" "\e[6~") (move 'goDown (: lines)))  # [PGDOWN] Page down
                              (("k" "\e[A") (move 'goUp *Cnt))  # [UP] Move up
                              (("^B" "\e[5~") (move 'goUp (: lines)))  # [PGUP] Page up
                              ("h" (move 'goLeft *Cnt))  # Move left
                              ("l" (move 'goRight *Cnt))  # Move right
                              ("\e[D" (scLeft) (redraw))  # [LEFT] Scroll left
                              ("\e[C" (scRight) (redraw))  # [RIGHT] Scroll right
                              ("z" (do 3 (scRight)) (redraw))  # Scroll right 3 columns
                              ("Z" (do 3 (scLeft)) (redraw))  # Scroll left 3 columns
                              ("|" (move 'goCol *Cnt))  # Go to column
                              ("$" (move 'goRight T))  # Go to end of line
                              ("G" (move 'goAbs 1 (or (format *Count) T)))  # Go to end of text
                              ("f" (and (getch2 (getch)) (move 'goFind @ 0 *Cnt)))  # Find character
                              ("t" (and (getch2 (getch)) (move 'goFind @ -1 *Cnt)))  # Till character
                              ("\t" (move 'goForward 'tword *Cnt))  # TAB word forward
                              ("w" (move 'goForward 'word *Cnt))  # Word forward
                              ("W" (move 'goForward 'lword *Cnt))  # Long word forward
                              ("b" (move 'goBackward 'word *Cnt))  # Word backward
                              ("B" (move 'goBackward 'lword *Cnt))  # Long word backward
                              ("e" (move 'goForward 'end *Cnt))  # End of word
                              ("E" (move 'goForward 'lend *Cnt))  # End of long word
                              ("{" (move 'goPBack *Cnt))  # Paragraph(s) backward
                              ("}" (move 'goPFore *Cnt 0))  # Paragraph(s) forward
                              ("'" (jmpMark (getch) "'" 1))  # Jump to mark line
                              ("`" (jmpMark (getch) "`")) # Jump to mark position
                              ("~" (evRpt (list 'tglCase *Cnt)))  # Toggle case
                              ((":" " ") (cmdMode (name ":")))  # Command
                              ("/" (cmdMode (name "/")))  # Search forward
                              ("?" (cmdMode (name "?")))  # Search backward
                              ("&" (cmdMode (name "&")))  # Search word
                              ("n"  # Search next
                                 (if *Search
                                    (move 'goForward (lit @) *Cnt)
                                    (beep) ) )
                              ("N"  # Search previous
                                 (if *Search
                                    (move 'goBackward (lit @) *Cnt)
                                    (beep) ) )
                              ("*"  # Search word under cursor
                                 (and (getWord T) (moveSearch 'goForward (wordFun @))) )
                              ("#"  # Search word under cursor backward
                                 (and (getWord T) (moveSearch 'goBackward (wordFun @))) )
                              ("%"  # Matching parenthesis
                                 (case (posChar)
                                    ("(" (parMatch 'goForward 1 0 "(" ")" "[" "]"))
                                    ("[" (parMatch 'goForward 0 (0 . 0) "(" ")" "[" "]"))
                                    (")" (parMatch 'goBackward 1 0 ")" "(" "]" "["))
                                    ("]" (parMatch 'goBackward 0 (0 . 0) ")" "(" "]" "["))
                                    (T (beep)) ) )
                              ("i"  # Insert
                                 (when (insMode)
                                    (setq *Repeat (list 'paste (lit @))) ) )
                              ("I"  # Insert at beginning of line
                                 (goto 1 (: posY))
                                 (when (insMode)
                                    (setq *Repeat (list 'paste (lit @) 0)) ) )
                              ("a"  # Append
                                 (when (get (: buffer text) (: posY) 1)
                                    (inc (:: posX)) )
                                 (when (insMode 1)
                                    (setq *Repeat (list 'paste (lit @) 1)) ) )
                              ("A"  # Append to end of line
                                 (goto
                                    (inc (length (get (: buffer text) (: posY))))
                                    (: posY)
                                    T )
                                 (when (insMode 1)
                                    (setq *Repeat (list 'paste (lit @) T)) ) )
                              ("o"  # Open new line below current line
                                 (setq *Repeat (list 'paste (lit (insMode T)) T)) )
                              ("O"  # Open new line above current line
                                 (setq *Repeat (list 'paste (lit (insMode 0)) 0)) )
                              ("x" (setq *Change "d") (move 'goRight *Cnt))  # Delete characters
                              ("X" (setq *Change "d") (move 'goLeft *Cnt))  # Delete characters left
                              ("D" (setq *Change "d") (move 'goRight T))  # Delete rest of line
                              ("p" (evRpt (list 'paste (lit (val *Clip)) 1)))  # Paste after current position
                              ("P" (evRpt (list 'paste (lit (val *Clip)))))  # Paste before current position
                              ("J" (evRpt (list 'join *Cnt)))  # Join lines
                              ("m"  # Set mark
                                 (put (: buffer) (intern (getch))
                                    (cons (: posX) (: posY)) ) )
                              ("M" (=: sc (dec (: winX))))  # Mark horizontal scroll position
                              ("r"  # Replace character(s)
                                 (and (getch2 (getch)) (evRpt (list 'insChar @ *Cnt))) )
                              ("R"  # Replace
                                 (when (insMode NIL NIL T)
                                    (setq *Repeat (list 'overwrite (lit @))) ) )
                              ("s" (chgRight 1))  # Substitute character
                              ("C" (chgRight T))  # Change rest of line
                              ("S" (=: posX 1) (chgRight T))  # Change whole line
                              ("," (evRpt '(indent)))  # Fix indentation
                              ("^A" (evRpt (list 'incNum *Cnt)))
                              ("^X" (evRpt (list 'incNum (- *Cnt))))
                              ("u" (undo))  # Undo
                              ("^R" (redo))  # Redo
                              ("^E" (evCmd (eval (s-expr))))  # Evaluate expression
                              ("g"  # ["Go" prefix]
                                 (if (assoc (getch) *KeyMap-g)
                                    (run (cdr @))
                                    (case *Chr
                                       ("f"  # [gf] Edit file under cursor
                                          (pushTag (: buffer file))
                                          (reload (pack (getWord T))) )
                                       ("g" (move 'goAbs 1 (or (format *Count) 1)))  # [gg] Go to beginning of text
                                       ("s" (spell))
                                       (T (beep)) ) ) )
                              ("+"  # Increase window size
                                 (loop
                                    (NIL (setq This (: prev))
                                       (for (This (; *Window next) This (: next))
                                          (T (> (: lines) 1)
                                             (with *Window
                                                (chgwin (inc (: lines)) (dec (: top)))
                                                (for (This (: next) (=1 (: lines)) (: next))
                                                   (chgwin 1 (dec (: top))) ) )
                                             (chgwin (dec (: lines))) ) ) )
                                    (T (> (: lines) 1)
                                       (with *Window
                                          (chgwin (inc (: lines)))
                                          (for (This (: prev) (=1 (: lines)) (: prev))
                                             (chgwin 1 (inc (: top))) ) )
                                       (chgwin (dec (: lines)) (inc (: top))) ) ) )
                              ("-"  # Decrease window size
                                 (cond
                                    ((=1 ( : lines)))
                                    ((: prev)
                                       (chgwin (dec (: lines)))
                                       (with (: prev)
                                          (chgwin (inc (: lines)) (dec (: top))) ) )
                                    (T
                                       (chgwin (dec (: lines)) (inc (: top)))
                                       (with (: next)
                                          (chgwin (inc (: lines))) ) ) ) )
                              ("=" (eqwin))  # Set all windows to equal size
                              ("K"  # Edit symbol
                                 (let S (any (getWord T))
                                    (ifn (: buffer syms)
                                       (tag S)
                                       (pushTag @)
                                       (syms> (: buffer) (cons S @))
                                       (reload (: buffer file) 1 1) ) ) )
                              ("^]"  # Edit symbol definition
                                 (tag (any (getWord T))) )
                              (("Q" "^T")  # Pop tag stack
                                 (ifn *TagStack
                                    (beep)
                                    (symbols (++ *TagStack))
                                    (if (atom (car *TagStack))
                                       (reload (++ *TagStack) (++ *TagStack) (++ *TagStack))
                                       (syms> (: buffer) (++ *TagStack))
                                       (reload (: buffer file) (++ *TagStack) (++ *TagStack)) ) ) )
                              (("\eOP" "\e[[A")  # [F1] Highlight on/off
                                 (=: buffer flat (not (: buffer flat)))
                                 (repaint) )
                              (("\eOQ" "\e[[B")  # [F2] Show chages to <file>-
                                 (shFile
                                    (if (sys "CCRYPT" (: buffer key))
                                       "diff -Bb <(ccrypt -c -ECCRYPT @1-) <(ccrypt -c -ECCRYPT @1)"
                                       "diff -Bb @1- @1" ) ) )
                              (("\eOR" "\e[[C")  # [F3] Custom dif
                                 (shFile "dif @1 @2") )
                              (("\eOS" "\e[[D")  # [F4] Format paragraph
                                 (and *Count (=: buffer fmt @))
                                 (goPFore 1 -1)
                                 (pipeN (cnt@@) (pack "fmt -" (: buffer fmt))) )
                              (("\e[15~" "\e[[E")  # [F5] Previous buffer
                                 (nextBuf T) )
                              ("\e[17~"  # [F6] Next buffer
                                 (nextBuf) )
                              ("\e[18~" (run *F7))  # [F7] Custom key
                              ("\e[19~" (run *F8))  # [F8] Custom key
                              ("\e[20~" (run *F9))  # [F9] Custom key
                              ("\e[21~" (run *F10))  # [F10] Custom key
                              ("\e[23~" (run *F11))  # [F11] Custom key
                              ("\e[24~" (run *F12))  # [F12] Custom key
                              ("\\"  # Select or toggle buffer
                                 (nextBuf
                                    (if *Count
                                       (get *Buffers (format @))
                                       (or (: last) (car *Buffers)) ) ) )
                              (("q" "^W")  # ["Window" prefix]
                                 (if (assoc (getch) *KeyMap-q)
                                    (run (cdr @))
                                    (case *Chr
                                       ("s"  # [qs] Split window
                                          (unless (== This *CmdWin)
                                             (let (Old (inc (: lines))  New (/ Old 2))
                                                (with
                                                   (new '(+Window) (: buffer)
                                                      (+ (: top) New) (- Old New 1)
                                                      (: winX) (: winY)
                                                      (: posX) (: posY)
                                                      (: prev)
                                                      (: mark) )
                                                   (goto (: posX) (: posY)) )
                                                (=: mark)
                                                (chgwin (dec New)) ) ) )
                                       ("x"  # [qx] Exchange windows
                                          (and
                                             (; *CmdWin next next)
                                             (n== This *CmdWin)
                                             (let W (if (== (: prev) *CmdWin) (: next) (: prev))
                                                (for P '(buffer winX winY posX posY)
                                                   (xchg (prop This P) (prop W P)) )
                                                (goto (: posX) (: posY))
                                                (with W
                                                   (goto (: posX) (: posY)) ) ) ) )
                                       ("k" (and (: next) (setq *Window @)))  # [qk] Above window
                                       ("j" (and (: prev) (setq *Window @)))  # [qj] Below window
                                       ("q" (done))  # [qq] (Quit) Close window
                                       ("z" (run *TStp1) (yield) (run *TStp2))  # [qz] Suspend
                                       (T (beep)) ) ) )
                              ("v" (view> This))  # View hook
                              (T (beep)) ) )
                        (reset) ) ) ) ) ) ) ) )

(and (info "~/.pil/viprc") (load @@))

### Debug ###
`*Dbg

(de pico~vi ("X" C)
   (and
      (symbols (setq *Ns (symbols))
         (vi
            (list
               (cond
                  ((pair "X") @)
                  ((if C
                        (or
                           (get C '*Dbg -1 "X")
                           (meta C '*Dbg -1 "X") )
                        (get "X" '*Dbg 1) )
                     (apply symbols (cddr @))
                     (cons (car @) (cadr @)) )
                  (T "X") ) ) ) )
      "X" ) )

(de pico~vf (Pat Dir Ext)
   (setq Pat (chop Pat))
   (when
      (in
         (list
            "grep" "-Rl"
            (if Ext (pack "--include=*" @) "--exclude=*-")
            (cons
               "\\(\^\\|[[:space:]\"'(),`{}~]\\|\\[\\|\\]\\)"
               (replace Pat "." "\\." "*" "\\*")
               "\\([[:space:]\"'(),`{}~]\\|\\[\\|\\]\\|$\\)" )
            (or (fName Dir) ".") )
         (make (while (line T) (link @))) )
      (symbols (setq *Ns (symbols))
         (vi (cons (cons Pat (car @)) (cdr @))) ) ) )

(de pico~v "Lst"
   (symbols (setq *Ns (symbols))
      (cond
         ("Lst" (vi (list @)))
         ((asoq 'vip (stack)) (vi)) ) ) )
