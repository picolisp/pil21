# 14oct20 Software Lab. Alexander Burger

# *Prune

(private) (_store _put _splitBt _del)

(de root (Tree)
   (cond
      ((not Tree) (val *DB))
      ((atom Tree) (val Tree))
      ((ext? (cdr Tree)) (get @ (car Tree)))
      ((atom (cdr Tree))
         (get *DB (cdr Tree) (car Tree)) )
      (T (get (cddr Tree) (cadr Tree) (car Tree))) ) )

# Fetch
(de fetch (Tree Key)
   (let? Node (cdr (root Tree))
      (and *Prune (idx '*Prune Node T))
      (use R
         (loop
            (and *Prune (set (prop Node NIL) 0))
            (T
               (and
                  (setq R (rank Key (cdr (val Node))))
                  (= Key (car R)) )
               (or (cddr R) (fin (car R))) )
            (NIL
               (setq Node (if R (cadr R) (car (val Node)))) ) ) ) ) )

# Store
(de store (Tree Key Val Dbf)
   (default Dbf (1 . 256))
   (if (atom Tree)
      (let Base (or Tree *DB)
         (_store (or (val Base) (set Base (cons 0)))) )
      (let Base
         (if (atom (cdr Tree))
            (or
               (ext? (cdr Tree))
               (get *DB (cdr Tree))
               (put *DB (cdr Tree) (new T 0)) )
            (or
               (get (cddr Tree) (cadr Tree))
               (put (cddr Tree) (cadr Tree) (new T)) ) )
         (_store
            (or
               (get Base (car Tree))
               (put Base (car Tree) (cons 0)) ) ) ) ) )

(de _store (Root)
   (and *Prune (cdr Root) (idx '*Prune @ T))
   (ifn Val
      (when (and (cdr Root) (_del @))
         (touch Base)
         (cond
            (*Solo (zap (cdr Root)))
            (*Zap (push @ (cdr Root))) )
         (con Root) )
      (and (= Val (fin Key)) (off Val))
      (if (cdr Root)
         (when (_put @)
            (touch Base)
            (con Root (def (new (car Dbf)) (list (car @) (cdr @)))) )
         (touch Base)
         (con Root
            (def (new (car Dbf))
               (list NIL (cons Key NIL Val)) ) )
         (and *Prune (set (prop (cdr Root) NIL) 0))
         (inc Root) ) ) )

(de _put (Top)
   (and *Prune (set (prop Top NIL) 0))
   (let (V (val Top)  R (rank Key (cdr V)))
      (cond
         (R
            (if (= Key (car R))
               (nil (touch Top) (con (cdr R) Val))
               (let X (memq R V)
                  (if (cadr R)
                     (when (_put @)
                        (touch Top)
                        (set (cdr R) (car @))
                        (con X (cons (cdr @) (cdr X)))
                        (_splitBt) )
                     (touch Top)
                     (con X
                        (cons (cons Key (cons NIL Val)) (cdr X)) )
                     (touch Base)
                     (inc Root)
                     (_splitBt) ) ) ) )
         ((car V)
            (when (_put @)
               (touch Top)
               (set V (car @))
               (con V (cons (cdr @) (cdr V)))
               (_splitBt) ) )
         (T
            (touch Top)
            (con V
               (cons (cons Key (cons NIL Val)) (cdr V)) )
            (touch Base)
            (inc Root)
            (_splitBt) ) ) ) )

(de _splitBt ()
   (when (and (cddddr V) (> (size Top) (cdr Dbf)))
      (let (N (>> 1 (length V))  X (get V (inc N)))
         (set (cdr X)
            (def (new (car Dbf))
               (cons (cadr X) (nth V (+ 2 N))) ) )
         (cons
            (if *Solo
               (prog (set Top (head N V)) Top)
               (and *Zap (push @ Top))
               (def (new (car Dbf)) (head N V)) )
            X ) ) ) )

# Del
(de _del (Top)
   (and *Prune (set (prop Top NIL) 0))
   (let (V (val Top)  R (rank Key (cdr V)))
      (cond
         ((not R)
            (when (and (car V) (_del @))
               (touch Top)
               (cond
                  (*Solo (zap (car V)))
                  (*Zap (push @ (car V))) )
               (set V)
               (not (cdr V)) ) )
         ((= Key (car R))
            (if (cadr R)
               (let X (val @)
                  (while (car X) (setq X (val @)))
                  (touch Top)
                  (xchg R (cadr X))
                  (con (cdr R) (cddr (cadr X)))
                  (when (_del (cadr R))
                     (cond
                        (*Solo (zap (cadr R)))
                        (*Zap (push @ (cadr R))) )
                     (set (cdr R)) ) )
               (touch Base)
               (dec Root)
               (nand
                  (or
                     (con V (delq R (cdr V)))
                     (car V) )
                  (touch Top) ) ) )
         ((cadr R)
            (when (_del @)
               (touch Top)
               (cond
                  (*Solo (zap (cadr R)))
                  (*Zap (push @ (cadr R))) )
               (set (cdr R)) ) ) ) ) )


# Delayed deletion
(de zap_ ()
   (let (F (cdr *Zap)  Z (pack F "_"))
      (cond
         ((info Z)
            (in Z (while (rd) (zap @)))
            (if (info F)
               (call "mv" F Z)
               (%@ "unlink" NIL Z) ) )
         ((info F) (call "mv" F Z)) ) ) )

# Tree node count
(de count (Tree)
   (or (car (root Tree)) 0) )

# Return first leaf
(de leaf (Tree)
   (let (Node (cdr (root Tree))  X)
      (while (val Node)
         (setq X (cadr @)  Node (car @)) )
      (cddr X) ) )

(private) revNode

# Reverse node
(de revNode (Node)
   (let? Lst (val Node)
      (let (L (car Lst)  R)
         (for X (cdr Lst)
            (push 'R (cons (car X) L (cddr X)))
            (setq L (cadr X)) )
         (cons L R) ) ) )

# Key management
(de minKey (Tree Min Max)
   (default Max T)
   (let (Node (cdr (root Tree))  K)
      (use (V R X)
         (loop
            (NIL (setq V (val Node)) K)
            (T
               (and
                  (setq R (rank Min (cdr V)))
                  (= Min (car R)) )
               Min )
            (if R
               (prog
                  (and
                     (setq X (cdr (memq R V)))
                     (>= Max (caar X))
                     (setq K (caar X)) )
                  (setq Node (cadr R)) )
               (when (>= Max (caadr V))
                  (setq K (caadr V)) )
               (setq Node (car V)) ) ) ) ) )

(de maxKey (Tree Min Max)
   (default Max T)
   (let (Node (cdr (root Tree))  K)
      (use (V R X)
         (loop
            (NIL (setq V (revNode Node)) K)
            (T
               (and
                  (setq R (rank Max (cdr V) T))
                  (= Max (car R)) )
               Max )
            (if R
               (prog
                  (and
                     (setq X (cdr (memq R V)))
                     (>= (caar X) Min)
                     (setq K (caar X)) )
                  (setq Node (cadr R)) )
               (when (>= (caadr V) Min)
                  (setq K (caadr V)) )
               (setq Node (car V)) ) ) ) ) )

# Step
(de init (Tree Beg End)
   (or Beg End (on End))
   (let (Node (cdr (root Tree))  Q)
      (use (V R X)
         (if (>= End Beg)
            (loop
               (NIL (setq V (val Node)))
               (T
                  (and
                     (setq R (rank Beg (cdr V)))
                     (= Beg (car R)) )
                  (push 'Q (memq R V)) )
               (if R
                  (prog
                     (and
                        (setq X (cdr (memq R V)))
                        (>= End (caar X))
                        (push 'Q X) )
                     (setq Node (cadr R)) )
                  (and
                     (cdr V)
                     (>= End (caadr V))
                     (push 'Q (cdr V)) )
                  (setq Node (car V)) ) )
            (loop
               (NIL (setq V (revNode Node)))
               (T
                  (and
                     (setq R (rank Beg (cdr V) T))
                     (= Beg (car R)) )
                  (push 'Q (memq R V)) )
               (if R
                  (prog
                     (and
                        (setq X (cdr (memq R V)))
                        (>= (caar X) End)
                        (push 'Q X) )
                     (setq Node (cadr R)) )
                  (and
                     (cdr V)
                     (>= (caadr V) End)
                     (push 'Q (cdr V)) )
                  (setq Node (car V)) ) ) ) )
      (cons (cons (cons Beg End) Q)) ) )

(de step (Q Flg)
   (use (L F X)
      (catch NIL
         (loop
            (until (cdar Q)
               (or (cdr Q) (throw))
               (set Q (cadr Q))
               (con Q (cddr Q)) )
            (setq
               L (car Q)
               F (>= (cdar L) (caar L))
               X (pop (cdr L)) )
            (or (cadr L) (con L (cddr L)))
            (if ((if F > <) (car X) (cdar L))
               (con (car Q))
               (for (V (cadr X) ((if F val revNode) V) (car @))
                  (con L (cons (cdr @) (cdr L))) )
               (unless (and Flg (flg? (fin (car X))))
                  (when (cddr X)
                     (setq @@ (car X))
                     (throw NIL @) )
                  (setq @@ (caar X))
                  (throw NIL (fin (car X))) ) ) ) ) ) )

(private) (_scan _nacs _iter _reti)
(private) (Tree Fun Beg End Flg Node R X V)

# Scan tree nodes
(de scan (Tree Fun Beg End Flg)
   (default Fun println)
   (or Beg End (on End))
   (let Node (cdr (root Tree))
      ((if (>= End Beg) _scan _nacs) Node) ) )

(de _scan (Node)
   (let? V (val Node)
      (for X
         (if (rank Beg (cdr V))
            (let R @
               (if (= Beg (car R))
                  (memq R (cdr V))
                  (_scan (cadr R))
                  (cdr (memq R (cdr V))) ) )
            (_scan (car V))
            (cdr V) )
         (T (> (car X) End))
         (unless (and Flg (flg? (fin (car X))))
            (Fun
               (car X)
               (or (cddr X) (fin (car X))) ) )
         (_scan (cadr X)) ) ) )

(de _nacs (Node)
   (let? V (revNode Node)
      (for X
         (if (rank Beg (cdr V) T)
            (let R @
               (if (= Beg (car R))
                  (memq R (cdr V))
                  (_nacs (cadr R))
                  (cdr (memq R (cdr V))) ) )
            (_nacs (car V))
            (cdr V) )
         (T (> End (car X)))
         (unless (and Flg (flg? (fin (car X))))
            (Fun
               (car X)
               (or (cddr X) (fin (car X))) ) )
         (_nacs (cadr X)) ) ) )

# Iterate tree values
(de iter (Tree Fun Beg End Flg)
   (default Fun println)
   (or Beg End (on End))
   (let Node (cdr (root Tree))
      ((if (>= End Beg) _iter _reti) Node) ) )

(de _iter (Node)
   (let? V (val Node)
      (for X
         (if (rank Beg (cdr V))
            (let R @
               (if (= Beg (car R))
                  (memq R (cdr V))
                  (_iter (cadr R))
                  (cdr (memq R (cdr V))) ) )
            (_iter (car V))
            (cdr V) )
         (T (> (car X) End))
         (unless (and Flg (flg? (fin (car X))))
            (Fun (or (cddr X) (fin (car X)))) )
         (_iter (cadr X)) ) ) )

(de _reti (Node)
   (let? V (revNode Node)
      (for X
         (if (rank Beg (cdr V) T)
            (let R @
               (if (= Beg (car R))
                  (memq R (cdr V))
                  (_reti (cadr R))
                  (cdr (memq R (cdr V))) ) )
            (_reti (car V))
            (cdr V) )
         (T (> End (car X)))
         (unless (and Flg (flg? (fin (car X))))
            (Fun (or (cddr X) (fin (car X)))) )
         (_reti (cadr X)) ) ) )

# UB-Trees
(de ub>= (Dim End Val Beg)
   (let (D (>> (- 1 Dim) 1)  Pat D)
      (while (> End Pat)
         (setq Pat (| D (>> (- Dim) Pat))) )
      (do Dim
         (NIL
            (>=
               (& Pat End)
               (& Pat Val)
               (& Pat Beg) ) )
         (setq Pat (>> 1 Pat)) ) ) )

(private) (Tree Dim Fun X1 X2 Node Lst Left Beg End B E X Msb Pat N Min Max Lo Hi)

(de ubIter (Tree Dim Fun X1 X2)
   (let
      (Node (cdr (root Tree))
         Lst (val Node)
         Left (++ Lst)
         Beg (ubZval (copy X1))
         End (ubZval (copy X2) T)
         B (car Beg)
         E (car End) )
      (recur (Left Lst Beg End  X)
         (while (setq X (++ Lst))
            (cond
               ((> (car X) End)
                  (setq Lst (; Left 0 -1)  Left (; Left 0 1)) )
               ((> Beg (car X))
                  (if Lst
                     (setq Left (cadr X))
                     (setq Left (; X 2 0 1)  Lst (; X 2 0 -1)) ) )
               ((ub>= Dim E (caar X) B)
                  (Fun (cdar X))
                  (recurse (; Left 0 1) (; Left 0 -1) Beg (car X))
                  (setq Beg (car X))
                  (if Lst
                     (setq Left (cadr X))
                     (setq Left (; X 2 0 1)  Lst (; X 2 0 -1)) ) )
               (T
                  (let (Msb 1  Pat 0  N 0  Min B  Max E  Lo (caar X)  Hi Lo)
                     (while (>= Max Msb)
                        (setq Msb (>> -1 Msb)  Pat (>> -1 Pat))  # Msb 100000000
                        (when (= Dim (inc 'N))                           # Pat 000100100
                           (inc 'Pat)
                           (zero N) ) )
                     (catch "ub"                                    # Clr 111..111011011
                        (let (Top Msb   Clr (| Top (x| Pat (dec Msb))))
                           (loop
                              (T (=0 (setq Msb (>> 1 Msb))))
                              (setq
                                 Pat (>> 1 Pat)
                                 Clr (| Top (>> 1 Clr)) )
                              (ifn (bit? Msb (caar X))
                                 (when (bit? Msb Max)
                                    (ifn (bit? Msb Min)  # 001
                                       (setq
                                          Max (- (| Pat Max) Msb)  # 0111(Max)
                                          Lo (| Msb (& Min Clr)) )   # 1000(Min)
                                       (setq Lo Min)     # 011
                                       (throw "ub") ) )
                                 (unless (bit? Msb Min)
                                    (if (bit? Msb Max)   # 101
                                       (setq
                                          Hi (- (| Pat Max) Msb)   # 0111(Max)
                                          Min (| Msb (& Min Clr)) )  # 1000(Min)
                                       (setq Hi Max)     # 100
                                       (throw "ub") ) ) ) ) ) )
                     (recurse (; Left 0 1) (; Left 0 -1) Beg (cons Hi T))
                     (setq Beg (cons Lo))
                     (if Lst
                        (setq Left (cadr X))
                        (setq Left (; X 2 0 1)  Lst (; X 2 0 -1)) ) ) ) ) ) ) ) )

(de prune (N)
   (for Node (idx '*Prune)
      (recur (Node)
         (let? V (val (lieu Node))
            (if (>= (inc (prop Node NIL)) N)
               (wipe Node)
               (recurse (car V))
               (for X (cdr V)
                  (recurse (cadr X)) ) ) ) ) )
   (or (gt0 N) (setq *Prune N)) )

# Delete Tree
(de zapTree (Node)
   (let? V (val Node)
      (zapTree (car V))
      (for L (cdr V)
         (zapTree (cadr L)) )
      (zap Node) ) )

(private) (Node Fun N L V X Y)

# Check tree structure
(de chkTree (Node Fun)
   (let (N 0  X)
      (when Node
         (recur (Node)
            (let V (val Node)
               (let L (car V)
                  (for Y (cdr V)
                     (when L
                        (unless (ext? L)
                           (quit "Bad node link" Node) )
                        (recurse L) )
                     (when (>= X (car Y))
                        (quit "Bad sequence" Node) )
                     (setq X (car Y))
                     (inc 'N)
                     (and
                        Fun
                        (not (Fun (car Y) (cddr Y)))
                        (quit "Check fail" Node) )
                     (setq L (cadr Y)) )
                  (and L (recurse L)) ) )
            (wipe Node) ) )
      N ) )
