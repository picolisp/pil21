# 15mar20 Software Lab. Alexander Burger

(symbols '(llvm))

(local) badSymNs

(de NIL badSymNs (Exe Sym)
   (err Exe Sym ($ "Bad symbol namespace") null) )

(local) (name bufSize pathSize bufString pathString)

(de name (Tail)
   (setq Tail (& Tail -9))  # Clear 'extern' tag
   (until (num? Tail)
      (shift Tail) )
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
   (let Q (push 0 (name (val (tail X))))  # [cnt name]
      (prog1 P
         (until (=0 (set P (numByte Q)))
            (inc 'P) ) ) ) )

(de i8* pathString (X (i8* . P))
   (bufString X P) )  #!

(local) (mkChar mkStr firstByte firstChar isBlank)

(de mkChar ((i32 . C))
   (consStr
      (cnt
         (i64
            (cond
               ((>= 127 C) C)  # Single byte
               ((== TOP C) (hex "FF"))  # Infinite
               ((> (hex "800") C)  # Double-byte
                  (|
                     (| (hex "C0") (& (shr C 6) (hex "1F")))  # 10xxxxx 10xxxxxx
                     (shl (| (hex "80") (& C (hex "3F"))) 8) ) )
               ((> (hex "10000") C)  # Three bytes
                  (|
                     (|
                        (| (hex "E0") (& (shr C 12) (hex "0F")))  # 1110xxxx 10xxxxxx 10xxxxxx
                        (shl (| (hex "80") (& (shr C 6) (hex "3F"))) 8) )
                     (shl (| (hex "80") (& C (hex "3F"))) 16) ) )
               (T
                  (|
                     (|
                        (|
                           (| (hex "F0") (& (shr C 18) (hex "07")))  # 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
                           (shl (| (hex "80") (& (shr C 12) (hex "3F"))) 8) )
                        (shl (| (hex "80") (& (shr C 6) (hex "3F"))) 16) )
                     (shl (| (hex "80") (& C (hex "3F"))) 24) ) ) ) ) ) ) )

(de mkStr ((i8* . Str))
   (if (=0 Str)
      $Nil
      (let (P (push 4 ZERO NIL)  Q (link (ofs P 1)))  # [cnt name link]
         (loop
            (let B (val Str)
               (? (=0 B))
               (byteNum B P) )
            (inc 'Str) )
         (drop Q
            (consStr (val Q)) ) ) ) )

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

(de i1 isBlank (X)
   (and
      (not (num? X))
      (sym? X)
      (let P (push 0 (name (val (tail X))))  # [cnt name]
         (loop
            (let B (numByte P)
               (? (=0 B) YES)
               (? (> B 32) NO) ) ) ) ) )

# Build external symbol name
(local) extNm

(de extNm ((i32 . File) (i64 . Obj))
   (cnt
      (|
         (& Obj (hex "FFFFF"))  # Lowest 20 bits
         (|
            (shl (i64 (& File (hex "FF"))) 20)  # Lower 8 bits
            (|
               (shl
                  (& (setq Obj (shr Obj 20)) (hex "FFF"))  # Middle 12 bits
                  28 )
               (|
                  (shl (i64 (shr File 8)) 40)  # Upper 8 bits
                  (shl (shr Obj 12) 48) ) ) ) ) ) )  # Highest 10 bits

(local) (objFile objId packAO packOct packExtNm pack chopExtNm)

# Get file number from external symbol name
(de i32 objFile (Name)
   (|
      (& (i32 (setq Name (shr Name 24))) (hex "FF"))  # Low 8 bits
      (& (i32 (shr Name 12)) (hex "FF00")) ) )  # High 8 bits

# Get object ID from external symbol name
(de i64 objId (Name)
   (|
      (|
         (& (setq Name (shr Name 4)) (hex "FFFFF"))  # Lowest 20 bits
         (& (setq Name (shr Name 8)) (hex "FFF00000")) )  # Middle 12 bits
      (& (shr Name 8) (hex "3FF00000000")) ) )  # Highest 10 bits

# Pack external symbol name
(de void packAO ((i32 . File) (i64* . P))
   (when (> File 15)
      (packAO (shr File 4) P) )  # Divide by 16
   (byteNum (+ (& (i8 File) 15) (char "@")) P) )  # Make ASCII letter

(de void packOct ((i64 . Obj) (i64* . P))
   (when (> Obj 7)
      (packOct (shr Obj 3) P) )  # Divide by 8
   (byteNum (+ (& (i8 Obj) 7) (char "0")) P) )  # Make ASCII digit

(de void packExtNm (Name (i64* . P))
   (let File (objFile Name)
      (unless (=0 File)
         (packAO File P) ) )
   (packOct (objId Name) P) )

# General pack
(de void pack (X (i64* . P))
   (when (pair X)
      (loop
         (pack (++ X) P)
         (? (atom X)) ) )
   (cond
      ((nil? X))
      ((num? X) (fmtNum X 0 0 0 P))
      (T
         (let (Tail (val (tail X))  Name (name Tail))
            (if (sym? Tail)
               (packExtNm Name P)
               (let (Q (push 0 Name)  B T)  # [cnt name]
                  (until (=0 (setq B (numByte Q)))
                     (byteNum B P) ) ) ) ) ) ) )

# Chop external symbol name
(de chopExtNm (Name)
   (let (R (link (push $Nil NIL))  N (objId Name))
      (loop
         (let A (+ (& N 7) (char "0"))  # Make ASCII digit
            (unless (=0 (setq N (shr N 3)))
               (setq A
                  (|
                     (shl A 8)
                     (+ (& N 7) (char "0")) ) )  # Second octal digit
               (unless (=0 (setq N (shr N 3)))
                  (setq A
                     (|
                        (shl A 8)
                        (+ (& N 7) (char "0")) ) ) ) )  # Third octal digit
            (set R
               (cons (consSym (cnt A) 0) (val R)) ) )
         (? (=0 (setq N (shr N 3)))) )
      (unless (=0 (setq N (objFile Name)))
         (let F (i32 0)
            (loop
               (setq F
                  (| F (+ (& N 15) (char "@"))) )  # Make ASCII letter
               (? (=0 (setq N (shr N 4))))
               (setq F (shl F 8)) )
            (set R
               (cons (consSym (cnt (i64 F)) 0) (val R)) ) ) )
      (pop R) ) )

### Interning ###
(local) (cmpLong isIntern isLstIntern intern requestSym extern delNode unintern)

# Compare long names
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

# Is symbol interned?
(de i1 isIntern (Sym Name Tree)
   (if (cnt? Name)  # Short name
      (let X (car Tree)  # First tree
         (loop
            (? (atom X) NO)  # Empty
            (let (S (car X)  Nm (name (val (tail S))))
               (? (== Name Nm)
                  (set $Ret S)
                  (or (=0 Sym) (== Sym S)) )
               (setq X
                  (if (> Name Nm)  # Symbol is smaller
                     (cddr X)
                     (cadr X) ) ) ) ) )
      # Long name
      (let X (cdr Tree)  # Second tree
         (loop
            (? (atom X) NO)  # Empty
            (let
               (S (car X)
                  Nm (name (val (tail S)))
                  I (cmpLong Nm Name) )
               (? (=0 I)
                  (set $Ret S)
                  (or (=0 Sym) (== Sym S)) )
               (setq X
                  (if (lt0 I)  # Symbol is smaller
                     (cddr X)
                     (cadr X) ) ) ) ) ) ) )

(de i1 isLstIntern (Sym Name Lst)
   (loop
      (? (atom Lst) NO)
      (? (isIntern Sym Name (val (++ Lst))) YES) ) )

# Intern a symbol/name
(de intern (Sym Val Name Tree More)
   (if (cnt? Name)  # Short name
      (let X (car Tree)  # First tree
         (if (pair X)  # No empty
            (loop
               (let (S (car X)  Nm (name (val (tail S))))
                  (? (== Name Nm) S)  # Found symbol
                  (if (> Name Nm)  # Symbol is smaller
                     (let Y (cdr X)  # Get link cell
                        (? (atom Y)  # No link yet
                           (if (isLstIntern Sym Name More)
                              (val $Ret)
                              (when (=0 Sym)  # New symbol
                                 (setq Sym (consSym Name Val)) )
                              (set 2 X (cons $Nil (cons Sym $Nil)))
                              Sym ) )
                        (? (atom (setq Y (cdr (setq X Y))))
                           (if (isLstIntern Sym Name More)
                              (val $Ret)
                              (when (=0 Sym)  # New symbol
                                 (setq Sym (consSym Name Val)) )
                              (set 2 X (cons Sym $Nil))
                              Sym ) )
                        (setq X Y) )
                     # Symbol is greater
                     (let Y (cdr X)  # Get link cell
                        (? (atom Y)  # No link yet
                           (if (isLstIntern Sym Name More)
                              (val $Ret)
                              (when (=0 Sym)  # New symbol
                                 (setq Sym (consSym Name Val)) )
                              (set 2 X (cons (cons Sym $Nil) $Nil))
                              Sym ) )
                        (? (atom (setq Y (car (setq X Y))))
                           (if (isLstIntern Sym Name More)
                              (val $Ret)
                              (when (=0 Sym)  # New symbol
                                 (setq Sym (consSym Name Val)) )
                              (set X (cons Sym $Nil))
                              Sym ) )
                        (setq X Y) ) ) ) )
            # Empty
            (if (isLstIntern Sym Name More)
               (val $Ret)
               (when (=0 Sym)  # New symbol
                  (setq Sym (consSym Name Val)) )
               (set Tree (cons Sym $Nil))
               Sym ) ) )
      # Long name
      (let X (cdr Tree)  # Second tree
         (if (pair X)  # No empty
            (loop
               (let
                  (S (car X)
                     Nm (name (val (tail S)))
                     I (cmpLong Nm Name) )
                  (? (=0 I) S)  # Found symbol
                  (if (lt0 I)  # Symbol is smaller
                     (let Y (cdr X)  # Get link cell
                        (? (atom Y)  # No link yet
                           (if (isLstIntern Sym Name More)
                              (val $Ret)
                              (when (=0 Sym)  # New symbol
                                 (setq Sym (consSym Name Val)) )
                              (set 2 X (cons $Nil (cons Sym $Nil)))
                              Sym ) )
                        (? (atom (setq Y (cdr (setq X Y))))
                           (if (isLstIntern Sym Name More)
                              (val $Ret)
                              (when (=0 Sym)  # New symbol
                                 (setq Sym (consSym Name Val)) )
                              (set 2 X (cons Sym $Nil))
                              Sym ) )
                        (setq X Y) )
                     # Symbol is greater
                     (let Y (cdr X)  # Get link cell
                        (? (atom Y)  # No link yet
                           (if (isLstIntern Sym Name More)
                              (val $Ret)
                              (when (=0 Sym)  # New symbol
                                 (setq Sym (consSym Name Val)) )
                              (set 2 X (cons (cons Sym $Nil) $Nil))
                              Sym ) )
                        (? (atom (setq Y (car (setq X Y))))
                           (if (isLstIntern Sym Name More)
                              (val $Ret)
                              (when (=0 Sym)  # New symbol
                                 (setq Sym (consSym Name Val)) )
                              (set X (cons Sym $Nil))
                              Sym ) )
                        (setq X Y) ) ) ) )
            # Empty
            (if (isLstIntern Sym Name More)
               (val $Ret)
               (when (=0 Sym)  # New symbol
                  (setq Sym (consSym Name Val)) )
               (set 2 Tree (cons Sym $Nil))
               Sym ) ) ) ) )

(de requestSym (Name)
   (intern 0 $Nil Name
      (val (car (val $Intern)))
      (cdr (val $Intern)) ) )

# Intern an external symbol
(de extern (Name)
   (let (X (val $Extern)  C 0  Sym T)
      (loop
         (inc 'C)  # Next level
         (setq Sym (car X))  # Next symbol
         (let Nm (& (name (val (tail Sym))) (hex "3FFFFFFFFFFFFFF7"))  # Mask status and extern bits
            (? (== Nm Name))  # Found
            (if (> Name Nm)  # Symbol is smaller
               (let Y (cdr X)  # Get link cell
                  (? (atom Y)  # No link yet
                     (set 2 X
                        (cons $Nil (cons (setq Sym (consExt Name)) $Nil)) ) )
                  (? (atom (setq Y (cdr (setq X Y))))
                     (set 2 X
                        (cons (setq Sym (consExt Name)) $Nil) ) )
                  (setq X Y) )
               (let Y (cdr X)  # Get link cell
                  (? (atom Y)  # No link yet
                     (set 2 X
                        (cons (cons (setq Sym (consExt Name)) $Nil) $Nil) ) )
                  (? (atom (setq Y (cdr (setq X Y))))
                     (set X
                        (cons (setq Sym (consExt Name)) $Nil) ) )
                  (setq X Y) ) ) ) )
      (setq C (shr C 1))  # Half depth
      (when (> (shl 1 C) (val $ExtCnt))  # 2 ** (C/2)
         (setq X (val $Extern))
         (let N (val $ExtSkip)  # Levels to skip
            (if (> (inc 'N) C)  # Beyond half depth
               (set $ExtSkip 0)  # Don't skip
               (set $ExtSkip N)
               (loop  # Skip
                  (setq X
                     (if
                        (>
                           Name
                           (&
                              (name (val (tail (++ X))))
                              (hex "3FFFFFFFFFFFFFF7") ) )
                        (cdr X)
                        (car X) ) )
                  (? (=0 (dec 'C))) ) ) )
         (loop  # Pivot
            (let
               (Nm
                  (&
                     (name (val (tail (car X))))
                     (hex "3FFFFFFFFFFFFFF7") )
                  Y (cdr X) )
            (? (== Nm Name))  # Done
            (if (> Name Nm)  # Symbol is smaller
               (let Z (cdr Y)  # Get right node
                  (? (atom (cdr Z)))
                  (xchg Z X)  # Pivot left
                  (setq Z (cdr Z)  X (cdr Z))
                  (set  # Rotate pointers
                     2 Z (val Z)
                     Z (val Y)
                     Y (cdr Y)
                     2 Y X) )
               (let Z (car Y)  # Get left node
                  (? (atom (cdr Z)))
                  (xchg Z X)  # Pivot right
                  (setq Z (cdr Z)  X (val Z))
                  (set  # Rotate pointers
                     Z (cdr Z)
                     2 Z (cdr Y)
                     2 Y (val Y)
                     Y X) ) ) ) ) )
      Sym ) )

(de void delNode (X P)
   (let Y (cdr X)  # Subtrees
      (cond
         ((atom (car Y))  # No left branch
            (set P (cdr Y)) )  # Use right branch
         ((atom (cdr Y))  # No right branch
            (set P (car Y)) )  # Use left branch
         ((atom (car (setq P (cdr (shift Y)))))  # Y on right branch, P on sub-branches
            (set  # No left sub-branch
               X (car Y)  # Insert right sub-branch
               2 (cdr X) (cdr P) ) )
         (T
            (setq P (car P))  # Left sub-branch
            (loop
               (let Z (cdr P)  # More left branches
                  (? (atom (car Z))
                     (set
                        X (car P)  # Insert left sub-branch
                        (cdr Y) (cdr Z) ) )
                  (setq Y P  P (car Z)) ) ) ) ) ) )  # Go down left

(de void unintern (Sym Name P)
   (if (cnt? Name)  # Short name
      (loop  # First tree
         (let X (car P)  # Next node
            (? (atom X))  # Empty
            (let (S (car X)  Nm (name (val (tail S))))
               (? (== Name Nm)
                  (when (== S Sym)  # Correct symbol
                     (delNode X P) ) )
               (? (atom (shift X)))
               (setq P
                  (if (> Name Nm) (ofs X 1) X) ) ) ) )
      # Long name
      (setq P (ofs P 1))  # Second tree
      (loop
         (let X (car P)  # Next node
            (? (atom X))  # Empty
            (let
               (S (car X)
                  Nm (name (val (tail S)))
                  I (cmpLong Nm Name) )
               (? (=0 I)
                  (when (== S Sym)  # Correct symbol
                     (delNode X P) ) )
               (? (atom (shift X)))
               (setq P
                  (if (lt0 I) (ofs X 1) X) ) ) ) ) ) )

# (name 'sym) -> sym
(de _name (Exe)
   (let
      (Sym (needSym Exe (eval (cadr Exe)))
         Tail (val (tail Sym))
         Name (name Tail) )
      (if (sym? Tail)  # External
         (let (P (push 4 ZERO NIL)  Q (link (ofs P 1)))  # [cnt name link]
            (packExtNm Name P)
            (drop Q
               (consSym (val Q) 0) ) )
         (consSym Name 0) ) ) )

# (nsp 'sym) -> sym
(de _nsp (Exe)
   (let
      (Sym (needSym Exe (eval (cadr Exe)))
         Name (name (val (tail Sym)))
         Lst (val $Intern) )  # Search namespaces
      (loop
         (? (atom Lst) $Nil)
         (let Ns (++ Lst)
            (? (isIntern Sym Name (val Ns)) Ns) ) ) ) )

# (sp? 'any) -> flg
(de _spQ (Exe)
   (if (isBlank (eval (cadr Exe)))
      $T
      $Nil ) )

# (pat? 'any) -> sym | NIL
(de _patQ (Exe)
   (let X (eval (cadr Exe))
      (if
         (and
            (not (num? X))
            (sym? X)
            (== (firstChar X) (char "@")) )
         X
         $Nil ) ) )

# (fun? 'any) -> any
(de _funQ (Exe)
   (let X (funq (eval (cadr Exe)))
      (if (=0 X) $Nil X) ) )

# (getd 'any) -> fun | NIL
(de _getd (Exe)
   (let (X (eval (cadr Exe))  V T)
      (cond
         ((or (num? X) (pair X)) $Nil)
         ((n0 (funq (setq V (val X)))) V)
         ((and (nil? V) (sharedLib X)) (val X))
         (T $Nil) ) ) )

### Namespaces ###
(local) consTree

# Build sorted list from tree
(de consTree (P Lst)
   (let (Q (link (push P NIL))  Tos (link (push -ZERO NIL)))
      (loop
         (loop
            (let X (cdr P)  # Get subtrees
               (let Y (cdr X)  # Right subtree
                  (? (atom Y))
                  (let Z P  # Go right
                     (setq P Y)  # Invert tree
                     (set 2 X (val Tos))
                     (set Tos Z) ) ) ) )
         (set Q P)  # Save tree
         (loop
            (setq Lst (cons (val P) Lst))  # Cons symbol
            (let (X (cdr P)  Y (car X))  # Left subtree
               (? (pair Y)
                  (let Z P  # Go left
                     (setq P Y)  # Invert tree
                     (set X (val Tos))
                     (set Tos (| Z 8))  # First visit
                     (set Q P) ) ) )  # Save tree
            (loop
               (let X (val Tos)
                  (when (== -ZERO X)
                     (drop Q)
                     (ret Lst) )
                  (? (=0 (& X 8))  # Second visit
                     (let Y (cdr X)  # Nodes
                        (set Tos (cdr Y))  # TOS on up link
                        (set 2 Y P)
                        (setq P X)
                        (set Q P) ) )  # Save tree
                  (setq X (& X -9))  # Clear visit bit
                  (let Y (cdr X)  # Nodes
                     (set Tos (car Y))
                     (set Y P)
                     (setq P X)
                     (set Q P) ) ) ) ) ) ) )  # Save tree

# (all ['NIL | 'T | '0 | 'sym | '(NIL . flg) | '(T . flg) | '(0)]) -> lst
(de _all (Exe)
   (let X (eval (cadr Exe))
      (cond
         ((nil? X)  # Internal symbols
            (let Y (val $Intern)
               (loop
                  (let Z (val (++ Y))
                     (setq X
                        (consTree (val Z) (consTree (val 2 Z) X)) ) )
                  (? (atom Y) X) ) ) )
         ((== $T X)  # Transient symbols
            (consTree (val $Transient) (consTree (val 2 $Transient) $Nil)) )
         ((num? X)  # External symbols
            (consTree (val $Extern) $Nil) )
         ((sym? X)  # Given namespace
            (let Y (val X)
               (consTree (val Y) (consTree (val 2 Y) $Nil)) ) )
         ((nil? (car X))  # Direct internal tree
            (let Y (val (car (val $Intern)))
               (if (nil? (cdr X))
                  (val Y)
                  (val 2 Y) ) ) )
         ((== $T (car X))  # Direct transient trees
            (if (nil? (cdr X))
               (val $Transient)
               (val 2 $Transient) ) )
         (T (val $Extern)) ) ) ) # Direct external tree

# (symbols) -> lst
# (symbols 'lst) -> lst
# (symbols 'lst . prg) -> any
# (symbols 'sym1 'sym2 ..) -> lst
(de _symbols (Exe)
   (let X (cdr Exe)
      (if (atom X)  # No args
         (val $Intern)
         (let Y (eval (++ X))
            (if (pair Y)  # List argument
               (if (atom X)  # No 'prg'
                  (prog1
                     (val $Intern)
                     (set $Intern Y) )
                  (let Z (save (val $Intern))
                     (set $Intern Y)
                     (prog1
                        (run X)  # Run 'prg'
                        (set $Intern Z) ) ) )
               (let V (val (needSym Exe Y))
                  (cond
                     ((nil? V) (set Y (cons $Nil $Nil)))  # New namespace
                     ((atom V) (badSymNs Exe Y)) ) )  # Value must be a pair
               (let R (setq Y (save (cons Y $Nil)))
                  (while (pair X)
                     (let Z (needSym Exe (eval (++ X)))
                        (and (atom (val Z)) (badSymNs Exe Z))
                        (setq Y (set 2 Y (cons Z $Nil))) ) )
                  (prog1
                     (val $Intern)
                     (set $Intern R) ) ) ) ) ) ) )

# (intern 'sym ['flg]) -> sym
(de _intern (Exe)
   (let
      (X (cdr Exe)
         Sym (save (needSym Exe (eval (++ X))))
         Name (name (val (tail Sym))) )
      (if (== Name ZERO)
         $Nil
         (let (L (val $Intern)  F (nil? (eval (car X))))
            (intern Sym 0 Name
               (val (car L))
               (if F (cdr L) $Nil) ) ) ) ) )

# (box? 'any) -> sym | NIL
(de _boxQ (Exe)
   (let X (eval (cadr Exe))
      (if
         (and
            (not (num? X))
            (sym? X)
            (== ZERO (name (val (tail X)))) )
         X
         $Nil ) ) )

# (str? 'any) -> sym | NIL
(de _strQ (Exe)
   (let X (eval (cadr Exe))
      (if (or (num? X) (not (sym? X)))
         $Nil
         (let Tail (val (tail X))
            (if
               (or
                  (sym? Tail)  # External
                  (isLstIntern X (name Tail) (val $Intern)) )
               $Nil
               X ) ) ) ) )

# (zap 'sym) -> sym
(de _zap (Exe)
   (let
      (Sym (needSym Exe (eval (cadr Exe)))
         Tail (val (tail Sym)) )
      (if (sym? Tail)  # External
         (dbZap Sym)
         (unintern Sym (name Tail) (val (car (val $Intern)))) )
      Sym ) )

# (chop 'any) -> lst
(de _chop (Exe)
   (let X (eval (cadr Exe))
      (if (or (pair X) (nil? X))
         X
         (let
            (Tail (val (tail (xSym X)))
               Name (save (name Tail)) )
            (if (sym? Tail)  # External
               (chopExtNm Name)
               (let (P (push 0 Name)  C (numChar P))
                  (if (=0 C)
                     $Nil
                     (let (Y (cons (mkChar C) $Nil)  R (save Y))
                        (until (=0 (setq C (numChar P)))
                           (setq Y
                              (set 2 Y (cons (mkChar C) $Nil)) ) )
                        R ) ) ) ) ) ) ) )

# (pack 'any ..) -> sym
(de _pack (Exe)
   (let
      (X (cdr Exe)
         P (push 4 ZERO NIL)  # [cnt name link]
         Q (link (ofs P 1))
         Safe (link (push -ZERO NIL)) )
      (while (pair X)
         (pack (set Safe (eval (++ X))) P) )
      (drop Q
         (consStr (val Q)) ) ) )

# (glue 'any 'lst) -> sym
(de _glue (Exe)
   (let
      (X (cdr Exe)
         Y (save (eval (++ X)))  # 'any'
         Z (save (eval (++ X)))  # 'lst'
         P (push 4 ZERO NIL)  # [cnt name link]
         Q (link (ofs P 1)) )
      (when (pair Z)
         (loop
            (pack (++ Z) P)
            (? (atom Z))
            (pack Y P) ) )
      (drop Q
         (consStr (val Q)) ) ) )


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
      (let (P (push 0 (name (val (tail Y))))  B T)
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
   (let (X (cdr Exe)  P (save (evSym X))  Z (evSym (shift X)))
      (if (subStr P Z)
         Z
         $Nil ) ) )

# (low? 'any) -> sym | NIL
(de _lowQ (Exe)
   (let X (eval (cadr Exe))
      (if
         (and
            (not (num? X))
            (sym? X)
            (isLowc (firstChar X)) )
         X
         $Nil ) ) )

# (upp? 'any) -> sym | NIL
(de _uppQ (Exe)
   (let X (eval (cadr Exe))
      (if
         (and
            (not (num? X))
            (sym? X)
            (isUppc (firstChar X)) )
         X
         $Nil ) ) )

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
                  (drop Q
                     (consStr (val Q)) ) ) ) ) ) ) )

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
                  (drop Q
                     (consStr (val Q)) ) ) ) ) ) ) )

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
                  (drop Q
                     (consStr (val Q)) ) ) ) ) ) ) )
