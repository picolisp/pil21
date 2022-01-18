# 18jan22 Software Lab. Alexander Burger

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
(local) (*Rt *Time *Ready *Next des pause event queue wake)

(off *Rt)  # Realtime
(zero *Time)  # Current simulation time

(de des ()
   (while (fifo '*Ready)
      (yield (cdr @) (car @)) )
   (when *Next
      (let ((Time . Co) (pop '*Next))
         (and *Rt (wait (- Time *Time)))
         (setq *Time Time)
         (yield NIL Co) ) ) )

# Wait for time or event
(de pause (E)
   (with (co)
      (cond
         ((num? E)
            (let X (cons (+ E *Time) This)
               (if (rank (car X) *Next)
                  (let P (memq @ *Next)
                     (con P (cons X (cdr P))) )
                  (push '*Next X) ) ) )
         (E (fifo (prop (=: event E) 'queue) This))
         (T (fifo '*Ready (cons This))) )
      (run (yield)) ) )

# Send event
(de event (This . Prg)
   (while (fifo (:: queue))
      (put @ 'event NIL)
      (fifo '*Ready (cons @ Prg)) ) )

# Wake up
(de wake (This . Prg)
   (cond
      ((asoq This *Ready) (con @ Prg))
      ((rasoq This *Next)
         (del @ '*Next)
         (fifo '*Ready (cons This Prg)) )
      ((: event))
         (rid (prop @ 'queue) This)
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
