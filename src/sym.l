# 27feb20 Software Lab. Alexander Burger

(symbols '(llvm))

(local) (name bufSize pathSize bufString pathString mkStr firstByte firstChar)

(de name (Tail)
   (setq Tail (any (& (i64 Tail) -9)))  # Clear 'extern' tag
   (until (num? Tail)
      (>>> Tail) )
   Tail )

(de i64 bufSize (Sym)
   (let (X (name (val (tail Sym)))  N 1)
      (while (big? X)
         (setq N (+ N 8)  X (val (big X))) )
      (setq X (int X))
      (until (=0 X)
         (inc 'N)
         (setq X (shr X 8)) )
      N ) )

(de i64 pathSize (Sym)
   (bufSize Sym) )  #!

(de i8* bufString (X (i8* . P))
   (let (Q (push 0 (name (val (tail X)))))  # [cnt name]
      (prog1 P
         (until (=0 (set P (numByte Q)))
            (inc 'P) ) ) ) )

(de i8* pathString (X (i8* . P))
   (bufString X P) )  #!

(de mkStr ((i8* . Str))
   (if (=0 Str)
      $Nil
      (let (P (push 4 ZERO NIL)  Q (link (ofs P 1)))  # [cnt name link]
         (loop
            (let B (val Str)
               (? (=0 B))
               (byteNum B P) )
            (inc 'Str) )
         (prog1
            (consStr (val Q))
            (drop Q) ) ) ) )

(de i8 firstByte (Tail)
   (if (sym? Tail)  # External symbol
      0
      (let Name (name Tail)  # Else get name
         (i8 (if (cnt? Name) (int Name) (dig Name))) ) ) )

(de i32 firstChar (Sym)
   (if (nil? Sym)
      0
      (let Tail (val (tail Sym))
         (if (sym? Tail)  # External symbol
            0
            (numChar (push 0 (name Tail))) ) ) ) )  # Else get name

(local) (pack xSym)

(de void pack (X (i64* . P))
   (when (pair X)
      (loop
         (pack (car X) P)
         (? (atom (>>> X))) ) )
   (cond
      ((nil? X))
      ((num? X) (fmtNum X 0 0 0 P))
      ((sym? (val (tail X)))  # External symbol
         )
      (T
         (let (Q (push 0 (name (val (tail X))))  B NIL)  # [cnt name]
            (until (=0 (setq B (numByte Q)))
               (byteNum B P) ) ) ) ) )

(de xSym (X)
   (if (or (num? X) (pair X))
      (let (P (push 4 ZERO NIL)  Q (link (ofs P 1)))  # [cnt name link]
         (pack X P)
         (prog1
            (consStr (val Q))
            (drop Q) ) )
      X ) )

### Interning ###
(local) (cmpLong intern isIntern findSym)

(de i32 cmpLong (X Y)
   (loop
      (? (n0 (sub (val (dig X)) (val (dig Y))))
         (if @@ (i32 -1) (i32 +1)) )
      (setq X (val (big X))  Y (val (big Y)))
      (? (cnt? X)
         (cond
            ((big? Y) (i32 -1))
            ((== Y X) (i32 0))
            ((> Y X) (i32 -1))
            (T (i32 +1)) ) )
      (? (cnt? Y) (i32 +1)) ) )

(de intern (Sym Val Name Tree More)
   (when (cnt? Name)  # Short name
      (let X (car Tree)  # First tree
         (when (atom X)  # Empty
            # .. check More
            (when (=0 Sym)  # New symbol
               (setq Sym (consSym Name Val)) )
            (set Tree (cons Sym $Nil))
            (ret Sym) )
         (loop
            (let (S (car X)  Nm (name (val (tail S))))
               (cond
                  ((== Name Nm) (ret S))  # Found symbol
                  ((> Name Nm)  # Symbol is smaller
                     (let Y (cdr X)  # Get link cell
                        (when (atom Y)  # No link yet
                           # .. check More
                           (when (=0 Sym)  # New symbol
                              (setq Sym (consSym Name Val)) )
                           (set 2 X (cons $Nil (cons Sym $Nil)))
                           (ret Sym) )
                        (if (pair (setq Y (cdr (setq X Y))))
                           (setq X Y)
                           # .. check More
                           (when (=0 Sym)  # New symbol
                              (setq Sym (consSym Name Val)) )
                           (set 2 X (cons Sym $Nil))
                           (ret Sym) ) ) )
                  (T  # Symbol is greater
                     (let Y (cdr X)  # Get link cell
                        (when (atom Y)  # No link yet
                           # .. check More
                           (when (=0 Sym)  # New symbol
                              (setq Sym (consSym Name Val)) )
                           (set 2 X (cons (cons Sym $Nil) $Nil))
                           (ret Sym) )
                        (if (pair (setq Y (car (setq X Y))))
                           (setq X Y)
                           # .. check More
                           (when (=0 Sym)  # New symbol
                              (setq Sym (consSym Name Val)) )
                           (set X (cons Sym $Nil))
                           (ret Sym) ) ) ) ) ) ) ) )
   # Long name
   (let X (cdr Tree)  # Second tree
      (when (atom X)  # Empty
         # .. check More
         (when (=0 Sym)  # New symbol
            (setq Sym (consSym Name Val)) )
         (set 2 Tree (cons Sym $Nil))
         (ret Sym) )
      (loop
         (let
            (S (car X)
               Nm (name (val (tail S)))
               I (cmpLong Nm Name) )
            (cond
               ((=0 I) (ret S))  # Found symbol
               ((lt0 I)  # Symbol is smaller
                  (let Y (cdr X)  # Get link cell
                     (when (atom Y)  # No link yet
                        # .. check More
                        (when (=0 Sym)  # New symbol
                           (setq Sym (consSym Name Val)) )
                        (set 2 X (cons $Nil (cons Sym $Nil)))
                        (ret Sym) )
                     (if (pair (setq Y (cdr (setq X Y))))
                        (setq X Y)
                        # .. check More
                        (when (=0 Sym)  # New symbol
                           (setq Sym (consSym Name Val)) )
                        (set 2 X (cons Sym $Nil))
                        (ret Sym) ) ) )
               (T  # Symbol is greater
                  (let Y (cdr X)  # Get link cell
                     (when (atom Y)  # No link yet
                        # .. check More
                        (when (=0 Sym)  # New symbol
                           (setq Sym (consSym Name Val)) )
                        (set 2 X (cons (cons Sym $Nil) $Nil))
                        (ret Sym) )
                     (if (pair (setq Y (car (setq X Y))))
                        (setq X Y)
                        # .. check More
                        (when (=0 Sym)  # New symbol
                           (setq Sym (consSym Name Val)) )
                        (set X (cons Sym $Nil))
                        (ret Sym) ) ) ) ) ) ) ) )

(de i1 isIntern (Sym Name Tree More)
   (if (cnt? Name)  # Short name
      (let X (car Tree)  # First tree
         (loop
            (when (atom X)  # Empty
               # .. check More
               (ret NO) )
            (let Nm (name (val (tail (car X))))
               (? (== Name Nm))
               (setq X
                  (if (> Name Nm)  # Symbol is smaller
                     (cddr X)
                     (cadr X) ) ) ) )
         (cond
            ((=0 Sym)  # No symbol given
               (set $Ret (car X)) )  # Found one
            ((<> Sym (car X))  # Different Symbol
               (ret NO)  # .. check More
               ) )
         YES )
      # Long name
      (let X (cdr Tree)  # Second tree
         (loop
            (when (atom X)  # Empty
               # .. check More
               (ret NO) )
            (let (Nm (name (val (tail (car X))))  I (cmpLong Nm Name))
               (? (=0 I))
               (setq X
                  (if (lt0 I)  # Symbol is smaller
                     (cddr X)
                     (cadr X) ) ) ) )
         (cond
            ((=0 Sym)  # No symbol given
               (set $Ret (car X)) )  # Found one
            ((<> Sym (car X))  # Different Symbol
               (ret NO)  # .. check More
               ) )
         YES ) ) )

(de findSym (Name)
   (intern 0 $Nil Name
      (val (car (val $Intern)))
      (cdr (val $Intern)) ) )

### Matching ###
(local) (preStr subStr)

(de i1 preStr (Nm (i8 . B) (i64* . P))
   (let (Q (push 0 (i64 Nm))  C (numByte Q))
      (loop
         (? (<> B C) NO)
         (? (=0 (setq C (numByte Q))) YES)
         (? (=0 (setq B (numByte P))) NO) ) ) )

(de i1 subStr (X Y)
   (or
      (nil? X)
      (== ZERO (setq X (name (val (tail X)))))
      (let (P (push 0 (name (val (tail Y))))  B NIL)
         (loop
            (? (=0 (setq B (numByte P))) NO)
            (let (Cnt (val P)  Nm (val 2 P))
               (? (preStr X B P) YES)
               (set P Cnt  2 P Nm) ) ) ) ) )

# (pre? 'any1 'any2) -> any2 | NIL
(de _preQ (Exe)
   $Nil )

# (sub? 'any1 'any2) -> any2 | NIL
(de _subQ (Exe)
   (let (X (cdr Exe)  P (save (evSym X))  Z (evSym (>>> X)))
      (if (subStr P Z)
         Z
         $Nil ) ) )

# (low? 'any) -> sym | NIL
(de _lowQ (Exe)
   (let X (eval (cadr Exe))
      (cond
         ((num? X) $Nil)
         ((sym? X) (if (isLowc (firstChar X)) X $Nil))
         (T $Nil) ) ) )

# (upp? 'any) -> sym | NIL
(de _uppQ (Exe)
   (let X (eval (cadr Exe))
      (cond
         ((num? (setq X (eval (cadr X)))) $Nil)
         ((sym? X) (if (isUppc (firstChar X)) X $Nil))
         (T $Nil) ) ) )

# (lowc 'any) -> any
(de _lowc (Exe)
   (let X (eval (cadr Exe))
      (if (or (num? X) (pair X) (nil? X))
         X
         (let Tail (val (tail X))
            (if (sym? Tail)  # External symbol
               X
               (let
                  (P (push 4 ZERO NIL)  # [cnt name link]
                     Q (link (ofs P 1))
                     R (push 0 (name Tail) NIL)  # [cnt name link]
                     C NIL )
                  (link (ofs R 1))
                  (until (=0 (setq C (numChar R)))
                     (charNum (toLowerCase C) P) )
                  (prog1
                     (consStr (val Q))
                     (drop Q) ) ) ) ) ) ) )

# (uppc 'any) -> any
(de _uppc (Exe)
   (let X (eval (cadr Exe))
      (if (or (num? X) (pair X) (nil? X))
         X
         (let Tail (val (tail X))
            (if (sym? Tail)  # External symbol
               X
               (let
                  (P (push 4 ZERO NIL)  # [cnt name link]
                     Q (link (ofs P 1))
                     R (push 0 (name Tail) NIL)  # [cnt name link]
                     C NIL )
                  (link (ofs R 1))
                  (until (=0 (setq C (numChar R)))
                     (cond
                        ((== C (char "ß"))
                           (charNum (char "S") P)
                           (charNum (char "S") P) )
                        (T (charNum (toUpperCase C) P)) ) )
                  (prog1
                     (consStr (val Q))
                     (drop Q) ) ) ) ) ) ) )

# (fold 'any ['cnt]) -> sym
(de _fold (Exe)
   (let (X (cdr Exe)  Y (eval (++ X)))
      (if (or (num? Y) (pair Y) (nil? Y))
         Y
         (let Tail (val (tail Y))
            (if (sym? Tail)  # External symbol
               Y
               (let
                  (N (if (atom X) 0 (evCnt Exe X))
                     P (push 4 ZERO NIL)  # [cnt name link]
                     Q (link (ofs P 1))
                     R (push 0 (name Tail) NIL)  # [cnt name link]
                     C NIL )
                  (link (ofs R 1))
                  (until (=0 (setq C (numChar R)))
                     (when (isLetterOrDigit C)
                        (charNum (toLowerCase C) P)
                        (? (=0 (dec 'N))) ) )
                  (prog1
                     (consStr (val Q))
                     (drop Q) ) ) ) ) ) ) )
