# 09oct21 Software Lab. Alexander Burger

(symbols 'vip~draw 'vip 'pico)

(local) (*DX *DY *PX *PY *Draw *Boxes)

(zero *DX *DY)

# Drawing primitives
(local) (point hline vline go up down left right rect label)

(de point (X Y C)
   (inc 'X *DX)
   (inc 'Y *DY)
   (let P
      (or
         (nth *Draw Y)
         (nth (setq *Draw (need (- Y) *Draw)) Y) )
      (set
         (or
            (nth (car P) X)
            (nth
               (set P (need (- X) (car P) (name " ")))
               X ) )
         (name C) ) ) )

(de hline (C X Y X2 A)
   (point X Y C)
   (if (> X2 X)
      (do (- X2 X)
         (point (inc 'X) Y "-") )
      (do (- X X2)
         (point (dec 'X) Y "-") ) )
   (and A (point X Y A)) )

(de vline (C X Y Y2 A)
   (point X Y C)
   (if (> Y2 Y)
      (do (- Y2 Y)
         (point X (inc 'Y) "|") )
      (do (- Y Y2)
         (point X (dec 'Y) "|") ) )
   (and A (point X Y A)) )

(de go (X Y C)
   (point (setq *PX X) (setq *PY Y) C) )

(de up (N C)
   (vline "|" *PX (dec *PY) (dec '*PY N) C) )

(de down (N C)
   (vline "|" *PX (inc *PY) (inc '*PY N) C) )

(de left (N C)
   (hline "-" (dec *PX) *PY (dec '*PX N) C) )

(de right (N C)
   (hline "-" (inc *PX) *PY (inc '*PX N) C) )

(de rect (X Y X2 Y2)
   (hline "+" X Y (dec X2))
   (vline "+" X2 Y (dec Y2))
   (hline "+" X2 Y2 (inc X))
   (vline "+" X Y2 (inc Y)) )

(de label (X Y Txt)
   (for C (chop Txt)
      (point X Y C)
      (inc 'X) ) )

# Box
(local) (+Box mx> my> hv>)

(class +Box)
# id x y x2 y2 dx dy h v

(dm mx> ()
   (*/ (+ (: x) (: x2)) 2) )

(dm my> ()
   (*/ (+ (: y) (: y2)) 2) )

(dm hv> ()
   (for L (: h)
      (loop
         (apply hline (++ L))
         (NIL L)
         (apply vline (++ L))
         (NIL L) ) )
   (for L (: v)
      (loop
         (apply vline (++ L))
         (NIL L)
         (apply hline (++ L))
         (NIL L) ) ) )


# Draw box
(local) (block box)
(private) (X Y DX DY Txt Prg)

(de block (X Y . Prg)
   (let (*DX (dec X)  *DY (dec Y))
      (run Prg) ) )

(de box (X Y DX DY Txt . Prg)
   (with
      (new '(+Box)
         'id (if (atom Txt) Txt (car Txt))
         'x (inc 'X *DX)
         'y (inc 'Y *DY)
         'x2 (+ X DX)
         'y2 (+ Y DY)
         'dx DX
         'dy DY )
      (queue '*Boxes This)
      (let (*DX 0  *DY 0)
         (rect (: x) (: y) (: x2) (: y2))
         (when (fin Txt)
            (label
               (+ (: x) (*/ (- (: dx) (length @)) 2))
               (+ (: y) (*/ (: dy) 2))
               @ ) ) )
      (let (*DX X  *DY Y)
         (run Prg) ) ) )

# Draw arrow
(local) arrow

(de arrow (Id1 Id2)
   (with
      (if (num? Id1)
         (get *Boxes Id1)
         (find '((This) (= Id1 (: id))) *Boxes) )
      (let? B
         (if (num? Id2)
            (get *Boxes Id2)
            (find '((This) (= Id2 (: id))) *Boxes) )
         (let (X (mx> This)  Y (my> This)  X2 (mx> B)  Y2 (my> B))
            (cond
               ((> (; B y) (: y2))  # Above
                  (cond
                     ((or
                           (>= 3 (- (; B y) (: y2)))
                           (>= (inc X2) X (dec X2)) )
                        (push (:: v)
                           (list
                              (list "+" X (: y2) (dec (; B y)) "v") ) ) )
                     ((> (; B y) (+ 4 (: y2)))
                        (push (:: v)
                           (let M (/ (+ (: y2) (; B y)) 2)
                              (list
                                 (list "+" X (: y2) (dec M))
                                 (list "+" X M X2)
                                 (list "+" X2 M (dec (; B y)) "v") ) ) ) )
                     ((> (; B x) (+ 2 X))  # Left
                        (push (:: v)
                           (list
                              (list "+" X (: y2) (dec Y2))
                              (list "+" X Y2 (dec (; B x)) ">") ) ) )
                     ((> X (+ 2 (; B x2)))  # Right
                        (push (:: v)
                           (list
                              (list "+" X (: y2) (dec Y2))
                              (list "+" X Y2 (inc (; B x2)) "<") ) ) ) ) )
               ((> (: y) (; B y2))  # Below
                  (cond
                     ((or
                           (>= 3 (- (: y) (; B y2)))
                           (>= (inc X2) X (dec X2)) )
                        (push (:: v)
                           (list
                              (list "+" X (: y) (inc (; B y2)) "\^") ) ) )
                     ((> (: y) (+ 4 (; B y2)))
                        (push (:: v)
                           (let M (*/ (+ (: y) (; B y2)) 2)
                              (list
                                 (list "+" X (: y) (inc M))
                                 (list "+" X M X2)
                                 (list "+" X2 M (inc (; B y2)) "\^") ) ) ) )
                     ((> (; B x) (+ 2 X))  # Left
                        (push (:: v)
                           (list
                              (list "+" X (: y) (inc Y2))
                              (list "+" X Y2 (dec (; B x)) ">") ) ) )
                     ((> X (+ 2 (; B x2)))  # Right
                        (push (:: v)
                           (list
                              (list "+" X (: y) (inc Y2))
                              (list "+" X Y2 (inc (; B x2)) "<") ) ) ) ) )
               (T  # Besides
                  (cond
                     ((> (; B x) (: x2))  # Left
                        (push (:: h)
                           (if (= Y Y2)
                              (list
                                 (list "+" (: x2) Y (dec (; B x)) ">") )
                              (let M (*/ (+ (: x2) (; B x)) 2)
                                 (list
                                    (list "+" (: x2) Y (dec M))
                                    (list "+" M Y Y2)
                                    (list "+" M Y2 (dec (; B x)) ">") ) ) ) ) )
                     ((> (: x) (; B x2))  # Right
                        (push (:: h)
                           (if (= Y Y2)
                              (list
                                 (list "+" (: x) Y (inc (; B x2)) "<") )
                              (let M (*/ (+ (: x) (; B x2)) 2)
                                 (list
                                    (list "+" (: x) Y (inc M))
                                    (list "+" M Y Y2)
                                    (list "+" M Y2 (inc (; B x2)) "<") ) ) ) ) ]

# Draw cell structures
(local) (cell cells)

(de cell (X Y Car Cdr)
   (let A (max 6 (+ 3 (length (setq Car (sym Car)))))
      (box X Y A 2
         (cons
            (pack (+ X *DX) "/" (+ Y *DY))
            Car )
         (let B 6
            (setq Cdr
               (cond
                  ((pair Cdr) "  ---")
                  (Cdr
                     (prog1
                        (sym @)
                        (setq B (max 6 (+ 3 (length @)))) ) )
                  (T "/") ) )
            (box A 0 B 2
               (cons (pack X "/" Y "+") Cdr) )
            (+ A B) ) ) ) )

(de cells (X Y Any)
   (let Pos (list X)
      (recur (Any Y Pos)
         (let (Y2 (+ Y *DY)  Last)
            (while (pair Any)
               (use D
                  (if (atom (car Any))
                     (setq D (cell (car Pos) Y (++ Any) Any))
                     (ifn (cdr Pos)
                        (con Pos (list (car Pos)))
                        (let (P @  M (car Pos))
                           (for (A (car Any) (pair A) (car A))
                              (setq M (max M (++ P))) )
                           (map
                              '((L) (set L (max M (car L))))
                              Pos ) ) )
                     (setq D
                        (cell (car Pos) Y '| (cdr Any)) )
                     (recurse (++ Any) (+ Y 5) (cdr Pos))
                     (let X2 (+ (car Pos) *DX)
                        (arrow
                           (pack X2 "/" Y2)
                           (pack X2 "/" (+ Y2 5)) ) ) )
                  (let X2 (+ (car Pos) *DX)
                     (when Last
                        (arrow @ (pack X2 "/" Y2)) )
                     (setq Last (pack X2 "/" Y2 "+")) )
                  (inc Pos (+ 6 D)) ) ) ) ) ) )

# Override +Buffer methods in object
(let? *Class (isa '+Buffer This)
   (dm save> (Win)
      (super Win)
      (view> This Win) )
   (dm view> (Win)
      (off *Draw *Boxes)
      (symbols '(vip~draw vip pico)
         (evCmd (load (fName (: file)))) )
      (mapc 'hv> *Boxes)
      (with Win
         (scratch (tmp "draw") *Draw) ) ) )

### Debug ###
`*Dbg

(de pico~cells @
   (off *Draw *Boxes)
   (let Y 1
      (while (args)
         (let V (next)
            (cond
               ((pair V)
                  (cells 1 Y V)
                  (setq Y (+ 3 (length *Draw))) )
               (V
                  (label 1 Y V)
                  (inc 'Y) ) ) ) ) )
   (mapc 'hv> *Boxes)
   (out (tmp "cells") (mapc prinl *Draw))
   (pico~vi (tmp "cells")) )
