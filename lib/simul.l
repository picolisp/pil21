# 27jun24 Software Lab. Alexander Burger

(symbols 'simul 'pico)

(local) (subsets shuffle samples)
(import pico~permute)

(de permute (Lst)
   (ifn (cdr Lst)
      (cons Lst)
      (mapcan
         '((X)
            (mapcar
               '((Y) (cons X Y))
               (permute (delete X Lst)) ) )
         Lst ) ) )

(de subsets (N Lst)
   (cond
      ((=0 N) '(NIL))
      ((not Lst))
      (T
         (conc
            (mapcar
               '((X) (cons (car Lst) X))
               (subsets (dec N) (cdr Lst)) )
            (subsets N (cdr Lst)) ) ) ) )

(de shuffle (Lst)
   (by '(NIL (rand)) sort Lst) )

(de samples (Cnt Lst)
   (make
      (for (N (length Lst) (n0 Cnt) (++ Lst) (dec N))
         (when (>= Cnt (rand 1 N))
            (link (car Lst))
            (dec 'Cnt) ) ) ) )

# Flooding Algorithm
(local) flood
(private) (Lst Fun Init X)

(de flood (Lst Fun Init)
   (let G (mapcar '((X) (cons X (Fun X))) Lst)
      (for L G
         (for X (cdr L)
            (let A (asoq X G)
               (unless (memq (car L) (cdr A))
                  (con A (cons (car L) (cdr A))) ) ) ) )
      (make
         (recur (Init)
            (for X Init
               (unless (memq X (made))
                  (link X)
                  (recurse (cdr (asoq X G))) ) ) ) ) ) )

(def 'flood 'doc "@doc/refF.html")

# Genetic Algorithm
(local) gen
(private) (Pop Cond Re Mu Se P)

(de gen (Pop Cond Re Mu Se)
   (until (Cond Pop)
      (for (P Pop P (cdr P))
         (set P
            (maxi Se  # Selection
               (make
                  (for (P Pop P)
                     (rot P (rand 1 (length P)))
                     (link  # Recombination + Mutation
                        (Mu (Re (++ P) (++ P))) ) ) ) ) ) ) )
   (maxi Se Pop) )

# Alpha-Beta tree search
(local) game
(private) (*Val Flg Cnt Moves Move Cost Alpha Beta Mov)

(de game (Flg Cnt Moves Move Cost)
   (let (Alpha '(1000000)  Beta -1000000)
      (recur (Flg Cnt Alpha Beta)
         (let? Lst (Moves Flg)
            (if (=0 (dec 'Cnt))
               (loop
                  (Move (caar Lst))
                  (setq *Val (list (Cost Flg) (car Lst)))
                  (Move (cdar Lst))
                  (T (>= Beta (car *Val))
                     (cons Beta (car Lst) (cdr Alpha)) )
                  (when (> (car Alpha) (car *Val))
                     (setq Alpha *Val) )
                  (NIL (shift 'Lst) Alpha) )
               (setq Lst
                  (sort
                     (mapcar
                        '((Mov)
                           (prog2
                              (Move (car Mov))
                              (cons (Cost Flg) Mov)
                              (Move (cdr Mov)) ) )
                        Lst ) ) )
               (loop
                  (Move (cadar Lst))
                  (setq *Val
                     (if (recurse (not Flg) Cnt (cons (- Beta)) (- (car Alpha)))
                        (cons (- (car @)) (cdar Lst) (cdr @))
                        (list (caar Lst) (cdar Lst)) ) )
                  (Move (cddar Lst))
                  (T (>= Beta (car *Val))
                     (cons Beta (cdar Lst) (cdr Alpha)) )
                  (when (> (car Alpha) (car *Val))
                     (setq Alpha *Val) )
                  (NIL (shift 'Lst) Alpha) ) ) ) ) ) )

### Discrete-Event Simulation ###
(local) (*Rt *Keys *Time *Ready *Next des pause event wake)
(private) (Prg X Time Dly n e s)

(zero *Time)  # Current simulation time

(de des Prg
   (while (fifo '*Ready)
      (yield (cdr @) (car @)) )
   (when (idx '*Next NIL)
      (let (X (car @)  (Time . This) X)
         (when *Rt
            (off *Keys)
            (for
               (Dly (*/ (- Time *Time) *Rt)
                  (key (max 1 Dly) 'Dly) )
               (fifo '*Keys @)
               (run Prg) ) )
         (setq *Time Time)
         (loop
            (idx '*Next X (=: n NIL))
            (for S (: e)
               (rid (prop S 's) This) )
            (=: e NIL)
            (yield 0 This)
            (NIL (setq X (lup *Next Time)))
            (setq This (cdr X)) ) ) ) )

# Wait for time and/or events
(de pause @
   (with (co)
      (ifn (args)
         (fifo '*Ready (cons This))
         (let Time T
            (while
               (let E (next)
                  (if (num? E)
                     (setq Time (min E Time))
                     (fifo (prop (push (:: e) E) 's) This) )
                  (args)) )
            (when (num? Time)
               (idx '*Next
                  (=: n (cons (+ Time *Time) This))
                  0 ) ) ) )
      (run (yield)) ) )

# Send event
(de event (This . Prg)
   (while (fifo (:: s))
      (with @
         (when (: n)
            (idx '*Next @ (=: n NIL)) )
         (for S (: e)
            (rid (prop S 's) This) )
         (=: e NIL)
         (fifo '*Ready (cons This Prg)) ) ) )

# Wake up
(de wake (This . Prg)
   (when (: n)
      (idx '*Next @ (=: n NIL)) )
   (for S (: e)
      (rid (prop S 's) This) )
   (=: e NIL)
   (if (asoq This *Ready)
      (con @ Prg)
      (fifo '*Ready (cons This Prg)) ) )

### Grids ###
(local) (grid west east south north)

(de grid (DX DY FX FY)
   (let Grid
      (make
         (for X DX
            (link
               (make
                  (for Y DY
                     (set
                        (link
                           (if (> DX 26)
                              (box)
                              (intern (pack (char (+ X 96)) Y) T) ) )
                        (cons (cons) (cons)) ) ) ) ) ) )
      (let West (and FX (last Grid))
         (for (Lst Grid  Lst)
            (let
               (Col (++ Lst)
                  East (or (car Lst) (and FX (car Grid)))
                  South (and FY (last Col)) )
               (for (L Col  L)
                  (with (++ L)
                     (set (: 0 1) (++ West))  # west
                     (con (: 0 1) (++ East))  # east
                     (set (: 0 -1) South)     # south
                     (con (: 0 -1)            # north
                        (or (car L) (and FY (car Col))) )
                     (setq South This) ) )
               (setq West Col) ) ) )
      Grid ) )

(de west (This)
   (: 0 1 1) )

(de east (This)
   (: 0 1 -1) )

(de south (This)
   (: 0 -1 1) )

(de north (This)
   (: 0 -1 -1) )

(local) (disp border)
(private) (Grid How Fun X Y DX DY N Sp)

(de disp (Grid How Fun X Y DX DY)
   (setq Grid
      (if X
         (mapcar
            '((L) (flip (head DY (nth L Y))))
            (head DX (nth Grid X)) )
         (mapcar reverse Grid) ) )
   (let (N (+ (length (cdar Grid)) (or Y 1))  Sp (length N))
      (border north)
      (while (caar Grid)
         (prin " " (align Sp N) " "
            (and How (if (and (nT How) (west (caar Grid))) " " '|)) )
         (for L Grid
            (prin
               (Fun (car L))
               (and How (if (and (nT How) (east (car L))) " " '|)) ) )
         (prinl)
         (border south)
         (map pop Grid)
         (dec 'N) )
      (unless (> (default X 1) 26)
         (space (inc Sp))
         (for @ Grid
            (prin " " (and How "  ") (char (+ 96 X)))
            (T (> (inc 'X) 26)) )
         (prinl) ) ) )

(de border (Dir)
   (when How
      (space Sp)
      (prin "  +")
      (for L Grid
         (prin (if (and (nT How) (Dir (car L))) "   +" "---+")) )
      (prinl) ) )

### Track network ###
(local) (connectors crossing linkFromTo linkFrom linkTo tracks)
(private) Var

(de connectors ()
   (=: a (list This NIL NIL))  # Connector A
   (=: b (list This NIL NIL))  # Connector B
   (con (cddr (: a)) (: b))
   (con (cddr (: b)) (: a)) )

(de crossing (Sym)
   (with (=: c (box))
      (connectors)
      (linkFromTo Sym) )  )

(de linkFromTo (Sym)
   (if2 (; Sym a 2) (: b 2)
      (set
         (; Sym b -1) (: b)
         (: a -1) (; Sym a) )
      (set
         (; Sym b -1) (: a)
         (: b -1) (; Sym a) )
      (set
         (; Sym a -1) (: b)
         (: a -1) (; Sym b) )
      (set
         (; Sym a -1) (: a)
         (: b -1) (; Sym b) ) ) )

(de linkFrom (Sym Ref)
   (let Con
      (if (; Sym a 2)
         (; Sym a)
         (; Sym b) )
      (if (== Ref (: b 2 1))
         (set
            (cddddr Con) (: a)
            (: b -2) Con )
         (set
            (cddddr Con) (: b)
            (: a -2) Con ) ) ) )

(de linkTo (Sym Ref)
   (let Con (if (: a 2) (: a) (: b))
      (if (== Ref (; Sym b 2 1))
         (set
            (cddddr Con) (; Sym a)
            (; Sym b -2) Con )
         (set
            (cddddr Con) (; Sym b)
            (; Sym a -2) Con ) ) ) )

# Define tracks
(de tracks (Var)
   (def Var  # Layout
      (clip
         (make
            (until (or (eof) (sub? (peek) "#("))
               (link (line)) ) ) ) )
   (for (Y . L) (val Var)  # Init
      (for (X . This) L
         (=: x X)
         (=: y Y)
         (unless (sp? This)
            (connectors) ) ) )
   (for 1st (1 NIL)
      (map
         '(((PU P))
            (map
               '(((Left This Right) (UpL Up UpR))
                  (case This
                     ("|"
                        (cond
                           ((= "|" Up)
                              #  |    \|     |/
                              #  |     |     |
                              (if 1st
                                 (linkFromTo Up)
                                 (when (= "\\" UpL)
                                    # \|
                                    #  |
                                    (linkFrom UpL Up) )
                                 (when (= "/" UpR)
                                    #  |/
                                    #  |
                                    (linkFrom UpR Up) ) ) )
                           ((= "\\" UpL)
                              # \
                              #  |
                              (and 1st (linkFromTo UpL)) )
                           ((= "/" UpR)
                              #   /
                              #  |
                              (and 1st (linkFromTo UpR)) ) )
                        (when 1st
                           # -|
                           (and (= "-" Left) (crossing Left))
                           #  -
                           #  |
                           (and (= "-" Up) (; Up c) (linkFromTo @)) ) )
                     ("/"
                        (cond
                           ((member UpR '("|" "/"))
                              #   |     |     /
                              #  /     /|    /
                              (if2 1st (= "|" Right)
                                 NIL
                                 (linkFromTo UpR)
                                 (linkTo UpR Right) ) )
                           ((= "-" UpR)
                              #   -    --
                              #  /     /
                              (if2 1st (= "-" Up)
                                 NIL
                                 (linkFromTo UpR)
                                 (linkTo UpR Up) ) ) ) )
                     ("-"
                        (cond
                           ((= "-" Left)
                              #       \       /     /
                              # --    --    --    ---
                              (if 1st
                                 (linkFromTo Left)
                                 (when (= "\\" UpL)
                                    # \
                                    # --
                                    (linkFrom UpL Left) ) )
                              (when (= "/" UpR)
                                 #   /      /
                                 # --     ---
                                 (if2 1st (= "-" Right)
                                    NIL
                                    (linkFromTo UpR)
                                    (linkFrom UpR Right) ) ) )
                           ((= "\\" UpL)
                              # \
                              #  -
                              (and 1st (linkFromTo UpL)) ) )
                        (when 1st
                           #  |
                           #  -
                           (and (= "|" Up) (crossing Up))
                           #  |-
                           (and (= "|" Left) (; Left c) (linkFromTo @)) ) )
                     ("\\"
                        (cond
                           ((member UpL '("|" "\\"))
                              # |     |     \
                              #  \    |\     \
                              (if2 1st (= "|" Left)
                                 NIL
                                 (linkFromTo UpL)
                                 (linkTo UpL Left) ) )
                           ((= "-" UpL)
                              # -     --
                              #  \     \
                              (if2 1st (= "-" Up)
                                 NIL
                                 (linkFromTo UpL)
                                 (linkTo UpL Up) ) ) ) ) ) )
               (cons NIL P)
               (cons NIL PU) ) )
         (cons NIL (val Var)) ) ) )
