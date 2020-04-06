# 06apr20 Software Lab. Alexander Burger

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
   (let
      (Len (bufSize Sym)
         Nm (name (val (tail Sym)))
         N (if (cnt? Nm) (int Nm) (dig Nm))
         B (i8 N) )
      (if
         (or
            (== B (char "@"))
            (and
               (== B (char "+"))
               (== (i8 (shr N 8)) (char "@")) ) )
         (+ (val $HomeLen) (dec Len))
         Len ) ) )

(de i8* bufString (X (i8* . P))
   (let Q (push 0 (name (val (tail X))))  # [cnt name]
      (prog1 P
         (until (=0 (set P (numByte Q)))
            (inc 'P) ) ) ) )

(de i8* pathString (X (i8* . P))
   (let
      (Q (push 0 (name (val (tail X))))  # [cnt name]
         B (numByte Q) )
      (prog1 P
         (when (== B (char "+"))
            (set P B)
            (inc 'P)
            (setq B (numByte Q)) )
         (if (== B (char "@"))
            (let N (val $HomeLen)
               (unless (=0 N)
                  (memcpy P (val $Home) N)
                  (setq P (ofs P N)) ) )
            (set P B)
            (inc 'P) )
         (until (=0 (set P (numByte Q)))
            (inc 'P) ) ) ) )

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

(de i8 firstByte (Sym)
   (let Nm (name (val (tail Sym)))
      (i8 (if (cnt? Nm) (int Nm) (dig Nm))) ) )

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
         (let (Tail (val (tail X))  Nm (name Tail))
            (if (sym? Tail)
               (packExtNm Nm P)
               (let (Q (push 0 Nm)  B T)  # [cnt name]
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
(de i64 cmpLong (X Y)
   (loop
      (? (n0 (sub (val (dig X)) (val (dig Y))))
         (if @@ -1 +1) )
      (setq X (val (big X))  Y (val (big Y)))
      (? (cnt? X)
         (cond
            ((big? Y) -1)
            ((== Y X) 0)
            ((> Y X) -1)
            (T +1) ) )
      (? (cnt? Y) +1) ) )

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
         (if (pair X)  # Not empty
            (loop
               (let (S (car X)  Nm (name (val (tail S))))
                  (? (== Name Nm) S)  # Found symbol
                  (let Y (cdr X)  # Get link cell
                     (cond
                        ((> Name Nm)  # Symbol is smaller
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
                                 Sym ) ) )
                        (T  # Symbol is greater
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
                                 Sym ) ) ) )
                     (setq X Y) ) ) )
            # Empty
            (if (isLstIntern Sym Name More)
               (val $Ret)
               (when (=0 Sym)  # New symbol
                  (setq Sym (consSym Name Val)) )
               (set Tree (cons Sym $Nil))
               Sym ) ) )
      # Long name
      (let X (cdr Tree)  # Second tree
         (if (pair X)  # Not empty
            (loop
               (let
                  (S (car X)
                     Nm (name (val (tail S)))
                     I (cmpLong Nm Name) )
                  (? (=0 I) S)  # Found symbol
                  (let Y (cdr X)  # Get link cell
                     (cond
                        ((lt0 I)  # Symbol is smaller
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
                                 Sym ) ) )
                        (T  # Symbol is greater
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
                                 Sym ) ) ) )
                     (setq X Y) ) ) )
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
            (let Y (cdr X)  # Get link cell
               (cond
                  ((> Name Nm)  # Symbol is smaller
                     (? (atom Y)  # No link yet
                        (set 2 X
                           (cons $Nil (cons (setq Sym (consExt Name)) $Nil)) ) )
                     (? (atom (setq Y (cdr (setq X Y))))
                        (set 2 X
                           (cons (setq Sym (consExt Name)) $Nil) ) ) )
                  (T  # Symbol is greater
                     (? (atom Y)  # No link yet
                        (set 2 X
                           (cons (cons (setq Sym (consExt Name)) $Nil) $Nil) ) )
                     (? (atom (setq Y (car (setq X Y))))
                        (set X
                           (cons (setq Sym (consExt Name)) $Nil) ) ) ) )
               (setq X Y) ) ) )
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
         Nm (name Tail) )
      (if (sym? Tail)  # External
         (let (P (push 4 ZERO NIL)  Q (link (ofs P 1)))  # [cnt name link]
            (packExtNm Nm P)
            (drop Q
               (consSym (val Q) 0) ) )
         (consSym Nm 0) ) ) )

# (nsp 'sym) -> sym
(de _nsp (Exe)
   (let
      (Sym (needSym Exe (eval (cadr Exe)))
         Nm (name (val (tail Sym)))
         Lst (val $Intern) )  # Search namespaces
      (loop
         (? (atom Lst) $Nil)
         (let Ns (++ Lst)
            (? (isIntern Sym Nm (val Ns)) Ns) ) ) ) )

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
            (setq Lst (cons (car P) Lst))  # Cons symbol
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
         Nm (name (val (tail Sym))) )
      (if (== Nm ZERO)
         $Nil
         (let (L (val $Intern)  F (nil? (eval (car X))))
            (intern Sym 0 Nm
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
               Nm (save (name Tail)) )
            (if (sym? Tail)  # External
               (chopExtNm Nm)
               (let (P (push 0 Nm)  C (numChar P))
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

# (text 'any1 'any ..) -> sym
(de _text (Exe)
   (let (X (cdr Exe)  Y (evSym X))
      (if (nil? Y)
         Y
         (let
            (P (push 0 (name (val (tail Y))) NIL)  # [cnt name link]
               Q (link (ofs P 1))
               R (push 4 ZERO NIL)  # [cnt name link]
               L (link (ofs R 1))
               N 0
               C T )
            (while (pair (shift X))
               (setq L (link (push (eval (car X)) NIL)))
               (inc 'N) )
            (until (=0 (setq C (numByte P)))
               (cond
                  ((<> C (char "@")) (byteNum C R))
                  ((== (setq C (numByte P)) (char "@"))
                     (byteNum C R) )  # "@@"
                  ((gt0 (setq C (- C (char "0"))))
                     (when (> C 9)
                        (setq C (- C 7)) )  # Adjust for letter
                     (when (ge0 (setq C (- N (i64 C))))
                        (let I L
                           (loop
                              (? (lt0 (dec 'C))
                                 (pack (val I) R) )
                              (shift I) ) ) ) ) ) )
            (drop Q
               (consStr (val 2 R)) ) ) ) ) )

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
   (let (X (cdr Exe)  Y (save (evSym X))  Z (evSym (shift X)))
      (cond
         ((nil? Y) Z)
         ((== ZERO (setq Y (name (val (tail Y)))))
            Z )
         (T
            (let
               (P (push 0 (name (val (tail Z))))
                  B (numByte P) )
               (cond
                  ((=0 B) $Nil)
                  ((preStr Y B P) Z)
                  (T $Nil) ) ) ) ) ) )

# (sub? 'any1 'any2) -> any2 | NIL
(de _subQ (Exe)
   (let (X (cdr Exe)  Y (save (evSym X))  Z (evSym (shift X)))
      (if (subStr Y Z)
         Z
         $Nil ) ) )

# (val 'var) -> any
(de _val (Exe)
   (let V (needVar Exe (eval (cadr Exe)))
      (and
         (sym? V)
         (sym? (val (tail V)))
         (dbFetch Exe V) )
      (val V) ) )

# (set 'var 'any ..) -> any
(de _set (Exe)
   (let (X (cdr Exe)  Safe (link (push -ZERO NIL)))
      (loop
         (let Y (set Safe (needChkVar Exe (eval (++ X))))
            (and
               (sym? Y)
               (sym? (val (tail Y)))
               (dbTouch Exe Y) )
            (let Z (eval (++ X))
               (set Y Z)
               (? (atom X)
                  (drop Safe)
                  Z ) ) ) ) ) )

# (setq var 'any ..) -> any
(de _setq (Exe)
   (let X (cdr Exe)
      (loop
         (let Y (set (needChkVar Exe (++ X)) (eval (++ X)))
            (? (atom X) Y) ) ) ) )

# (swap 'var 'any) -> any
(de _swap (Exe)
   (let
      (X (cdr Exe)
         Y (save (needChkVar Exe (eval (++ X)))) )
      (and
         (sym? Y)
         (sym? (val (tail Y)))
         (dbTouch Exe Y) )
      (let (Z (eval (car X))  V (val Y))
         (set Y Z)
         V ) ) )

# (xchg 'var 'var ..) -> any
(de _xchg (Exe)
   (let (X (cdr Exe)  Safe (link (push -ZERO NIL)))
      (loop
         (let Y (set Safe (needChkVar Exe (eval (++ X))))
            (and
               (sym? Y)
               (sym? (val (tail Y)))
               (dbTouch Exe Y) )
            (let Z (needChkVar Exe (eval (++ X)))
               (and
                  (sym? Z)
                  (sym? (val (tail Z)))
                  (dbTouch Exe Z) )
               (setq Z (xchg Y Z))
               (? (atom X)
                  (drop Safe)
                  Z ) ) ) ) ) )

# (on var ..) -> T
(de _on (Exe)
   (let X (cdr Exe)
      (loop
         (set (needChkVar Exe (++ X)) $T)
         (? (atom X) $T) ) ) )

# (off var ..) -> NIL
(de _off (Exe)
   (let X (cdr Exe)
      (loop
         (set (needChkVar Exe (++ X)) $Nil)
         (? (atom X) $Nil) ) ) )

# (onOff var ..) -> flg
(de _onOff (Exe)
   (let X (cdr Exe)
      (loop
         (let
            (Y (needChkVar Exe (++ X))
               Z (if (nil? (val Y)) $T $Nil) )
            (set Y Z)
            (? (atom X) Z) ) ) ) )

# (zero var ..) -> 0
(de _zero (Exe)
   (let X (cdr Exe)
      (loop
         (set (needChkVar Exe (++ X)) ZERO)
         (? (atom X) ZERO) ) ) )

# (one var ..) -> 1
(de _one (Exe)
   (let X (cdr Exe)
      (loop
         (set (needChkVar Exe (++ X)) ONE)
         (? (atom X) ONE) ) ) )

# (default sym 'any ..) -> any
(de _default (Exe)
   (let X (cdr Exe)
      (loop
         (let Y (needChkVar Exe (++ X))
            (when (nil? (val Y))
               (set Y (eval (car X))) )
            (? (atom (shift X)) (val Y)) ) ) ) )

# (push 'var 'any ..) -> any
(de _push (Exe)
   (let
      (X (cdr Exe)
         Y (save (needChkVar Exe (eval (++ X)))) )
      (and
         (sym? Y)
         (sym? (val (tail Y)))
         (dbTouch Exe Y) )
      (loop
         (let Z (eval (++ X))
            (set Y (cons Z (val Y)))
            (? (atom X) Z) ) ) ) )

# (push1 'var 'any ..) -> any
(de _push1 (Exe)
   (let
      (X (cdr Exe)
         Y (save (needChkVar Exe (eval (++ X)))) )
      (and
         (sym? Y)
         (sym? (val (tail Y)))
         (dbTouch Exe Y) )
      (loop
         (let (Z (eval (++ X))  V (val Y)  L V)
            (loop  # 'member'
               (? (atom L) (set Y (cons Z V)))
               (? (equal Z (++ L))) )
            (? (atom X) Z) ) ) ) )

# (push1q 'var 'any ..) -> any
(de _push1q (Exe)
   (let
      (X (cdr Exe)
         Y (save (needChkVar Exe (eval (++ X)))) )
      (and
         (sym? Y)
         (sym? (val (tail Y)))
         (dbTouch Exe Y) )
      (loop
         (let (Z (eval (++ X))  V (val Y)  L V)
            (loop  # 'memq'
               (? (atom L) (set Y (cons Z V)))
               (? (== Z (++ L))) )
            (? (atom X) Z) ) ) ) )

# (pop 'var) -> any
(de _pop (Exe)
   (let X (needChkVar Exe (eval (cadr Exe)))
      (and
         (sym? X)
         (sym? (val (tail X)))
         (dbTouch Exe X) )
      (let V (val X)
         (if (atom V)
            V
            (set X (cdr V))
            (car V) ) ) ) )

# (++ var) -> any
(de _popq (Exe)
   (let (X (needChkVar Exe (cadr Exe))  V (val X))
      (if (atom V)
         V
         (set X (cdr V))
         (car V) ) ) )

# (cut 'cnt 'var) -> lst
(de _cut (Exe)
   (let (X (cdr Exe)  N (evCnt Exe X))
      (if (le0 N)
         $Nil
         (let Y (needChkVar Exe (eval (cadr X)))
            (and
               (sym? Y)
               (sym? (val (tail Y)))
               (dbTouch Exe Y) )
            (let
               (V (save (val Y))
                  Z (cons (++ V) $Nil)
                  R (save Z) )
               (while (and (pair V) (n0 (dec 'N)))
                  (setq Z (set 2 Z (cons (++ V) $Nil))) )
               (set Y V)  # Set new value
               R ) ) ) ) )

# (del 'any 'var ['flg]) -> lst
(de _del (Exe)
   (let
      (X (cdr Exe)
         Y (save (eval (++ X)))
         Var (save (needChkVar Exe (eval (++ X))))
         Flg (nil? (eval (car X))) )
      (and
         (sym? Var)
         (sym? (val (tail Var)))
         (dbTouch Exe Var) )
      (let V (val Var)
         (loop
            (? (atom V) V)
            (let Z (++ V)
               (? (not (equal Y Z))
                  (let (P (cons Z $Nil)  R (save P))
                     (loop
                        (? (atom V))
                        (if (equal Y (setq Z (++ V)))
                           (? Flg)
                           (setq P (set 2 P (cons Z $Nil))) ) )
                     (set 2 P V  Var R) ) ) )
            (set Var V)
            (? Flg V) ) ) ) )

# (queue 'var 'any) -> any
(de _queue (Exe)
   (let
      (X (cdr Exe)
         Y (save (needChkVar Exe (eval (++ X)))) )
      (and
         (sym? Y)
         (sym? (val (tail Y)))
         (dbTouch Exe Y) )
      (let
         (Z (eval (car X))
            L (cons Z $Nil)
            V (val Y) )
         (if (atom V)
            (set Y L)
            (while (pair (cdr V))
               (shift V) )
            (set 2 V L) )
         Z ) ) )

# (fifo 'var ['any ..]) -> any
(de _fifo (Exe)
   (let
      (X (cdr Exe)
         Y (save (needChkVar Exe (eval (++ X)))) )
      (and
         (sym? Y)
         (sym? (val (tail Y)))
         (dbTouch Exe Y) )
      (let V (val Y)
         (if (atom X)
            (if (atom V)
               $Nil
               (let Z (cdr V)
                  (if (== V Z)  # Single cell
                     (prog
                        (set Y $Nil)  # Clear value
                        (car V) )
                     (set 2 V (cdr Z))
                     (car Z) ) ) )
            (let E (eval (car X))
               (if (pair V)
                  (setq V (set 2 V (cons E (cdr V))))  # Concat into value
                  (setq V (cons E -ZERO))  # Circular cell
                  (set 2 V V) )
               (while (pair (shift X))
                  (setq V (cons (eval (car X)) (cdr V))) )
               (set Y V)
               E ) ) ) ) )

(local) (idxPut idxGet idxDel)

(de idxPut (Var Key)
   (let X (val Var)
      (if (pair X)
         (loop
            (let I (compare (car X) Key)
               (? (=0 I) X)  # Found key
               (let Y (cdr X)  # Get link cell
                  (cond
                     ((lt0 I)  # Entry is smaller
                        (? (atom Y)  # No link yet
                           (set 2 X (cons $Nil (cons Key $Nil)))
                           $Nil )
                        (? (atom (setq Y (cdr (setq X Y))))
                           (set 2 X (cons Key $Nil))
                           $Nil ) )
                     (T  # Entry is greater
                        (? (atom Y)  # No link yet
                           (set 2 X (cons (cons Key $Nil) $Nil))
                           $Nil )
                        (? (atom (setq Y (car (setq X Y))))
                           (set X (cons Key $Nil))
                           $Nil ) ) )
                  (setq X Y) ) ) )
         (set Var (cons Key $Nil))
         $Nil ) ) )

(de idxGet (Var Key)
   (let X (val Var)
      (loop
         (? (atom X) $Nil)
         (let I (compare (car X) Key)
            (? (=0 I) X)  # Found key
            (let Y (cdr X)  # Get link cell
               (setq X
                  (if (lt0 I) (cdr Y) (car Y)) ) ) ) ) ) )

(de idxDel (Var Key)
   (loop
      (let X (val Var)
         (? (atom X) $Nil)
         (let Y (cdr X)  # Subtrees
            (let I (compare (car X) Key)
               (? (=0 I)  # Found key
                  (cond
                     ((atom (car Y))  # No left branch
                        (set Var (cdr Y)) )  # Use right branch
                     ((atom (cdr Y))  # No right branch
                        (set Var (car Y)) )  # Use left branch
                     (T
                        (let Z (cdr (setq Y (cdr Y)))  # Sub-branches
                           (if (atom (car Z))  # No left sub-branch
                              (set   # Insert right sub-branch
                                 X (car Y)
                                 2 (cdr X) (cdr Z) )
                              (let L (cdr (setq Z (car Z)))  # Left sub-branch
                                 (loop
                                    (? (atom (car L)))
                                    (setq Y Z  Z (car L)  L (cdr Z)) )
                                 (set
                                    X (car Z)
                                    (cdr Y) (cdr L) ) ) ) ) ) )
                  X )
               (? (atom Y) $Nil)  # No link cell
               (setq Var Y)  # Default point to left subtree
               (and (lt0 I) (setq Var (ofs Var 1))) ) ) ) ) )  # Point to right

# (idx 'var 'any 'flg) -> lst
# (idx 'var 'any) -> lst
# (idx 'var) -> lst
(de _idx (Exe)
   (let
      (X (cdr Exe)
         Var (needChkVar Exe (eval (++ X))) )
      (if (atom X)
         (consTree (val Var) $Nil)  # Single arg
         (save Var
            (let Key (save (eval (++ X)))
               (cond
                  ((atom X) (idxGet Var Key))  # Two args
                  ((nil? (eval (car X))) (idxDel Var Key))  # Delete
                  (T (idxPut Var Key)) ) ) ) ) ) )

# (lup 'lst 'any) -> lst
# (lup 'lst 'any 'any2) -> lst
(de _lup (Exe)
   (let (X (cdr Exe)  P (save (eval (++ X))))
      (if (atom P)
         P
         (let Key (eval (++ X))
            (if (atom X)
               (loop
                  (let Y (car P)
                     (cond
                        ((== $T Y) (setq P (cadr P)))
                        ((atom Y) (setq P (cddr P)))
                        (T
                           (let I (compare (car Y) Key)
                              (? (=0 I) (car P))
                              (setq
                                 P (cdr P)
                                 P (if (lt0 I) (cdr P) (car P)) ) ) ) ) )
                  (? (atom P) $Nil) )
            (save Key)
            (let
               (Key2 (save (eval (car X)))
                  Q (link (push P NIL))
                  Tos (link (push -ZERO NIL))
                  R $Nil )
               (loop
                  (loop
                     (let Y (cdr (setq X (cdr P)))  # Right subtree
                        (? (atom Y))
                        (let Z (car P)
                           (? (== $T Z))
                           (? (and (pair Z) (gt0 (compare (car Z) Key2)))) )
                        (let Z P  # Go right
                           (setq P Y)  # Invert tree
                           (set 2 X (val Tos))
                           (set Tos Z) ) ) )
                  (set Q P)  # Save tree
                  (loop
                     (when
                        (and
                           (pair (setq X (car P)))
                           (ge0 (compare (car X) Key)) )
                        (when (le0 (compare (car X) Key2))
                           (setq R (cons X R)) )  # Cons symbol
                        (let Y (car (setq X (cdr P)))  # Left subtree
                           (? (pair Y)
                              (let Z P  # Go left
                                 (setq P Y)  # Invert tree
                                 (set X (val Tos))
                                 (set Tos (| Z 8))  # First visit
                                 (set Q P) ) ) ) )  # Save tree
                     (loop
                        (when (== -ZERO (setq X (val Tos)))
                           (ret R) )
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
                           (set Q P) ) ) ) ) ) ) ) ) ) )  # Save tree

### Property access ###
(local) (put putn get getn prop)

(de void put (Sym Key Val)
   (let Tail (val (tail Sym))
      (unless (num? Tail)  # Property list
         (let (L (any (& Tail -9))  X (car L))
            (if (atom X)
               (when (== Key X)
                  (cond
                     ((nil? Val)
                        (shift L)  # Remove first property
                        (set (tail Sym)
                           (if (sym? Tail) (| L 8) L) ) )
                     ((<> Val $T)  # Change to cell
                        (set L (cons Val Key)) ) )
                  (ret) )
               (when (== Key (cdr X))
                  (cond
                     ((nil? Val)
                        (shift L)  # Remove first property
                        (set (tail Sym)
                           (if (sym? Tail) (| L 8) L) ) )
                     ((== Val $T) (set L Key))  # Change to flag
                     (T (set X Val)) )  # Set new value
                  (ret) ) )
            (while (pair (setq X (cdr L)))
               (let Y (car X)
                  (if (atom Y)
                     (when (== Key Y)
                        (if (nil? Val)
                           (set 2 L (cdr X))  # Remove cell
                           (unless (== $T Val)
                              (set X (cons Val Key)) )
                           (set 2 L (cdr X))  # Unlink cell
                           (ifn (sym? Tail)
                              (set 2 X Tail)
                              (set 2 X (& Tail -9))
                              (setq X (| X 8)) )
                           (set (tail Sym) X) )
                        (ret) )
                     (when (== Key (cdr Y))
                        (if (nil? Val)
                           (set 2 L (cdr X))  # Remove cell
                           (if (== $T Val)
                              (set X Key)  # Change to flag
                              (set Y Val) )  # Set new value
                           (set 2 L (cdr X))  # Unlink cell
                           (ifn (sym? Tail)
                              (set 2 X Tail)
                              (set 2 X (& Tail -9))
                              (setq X (| X 8)) )
                           (set (tail Sym) X) )
                        (ret) ) ) )
                  (setq L X) ) ) )
      (unless (nil? Val)  # Non-NIL value
         (setq Val
            (if (== $T Val) Key (cons Val Key)) )
         (set (tail Sym)
            (if (sym? Tail)
               (| (cons Val (& Tail -9)) 8)
               (cons Val Tail) ) ) ) ) )

(de void putn (Exe Lst Key Val)
   (nond
      ((num? Key)
         (loop  # asoq
            (let X (car Lst)
               (? (and (pair X) (== Key (car X)))
                  (set 2 X Val) ) )
            (when (atom (shift Lst))
               (itemErr Exe Key) ) ) )
      ((== ZERO Key)
         (let Cnt (int Key)  # index
            (until (=0 (dec 'Cnt))
               (when (atom (shift Lst))
                  (itemErr Exe Key) ) ) )
         (if (sign? Key)
            (set 2 Lst Val)
            (set Lst Val) ) )
      (NIL (argErr Exe Key)) ) )

(de get (Sym Key)
   (if (== Key ZERO)
      (val Sym)
      (let Tail (val (tail Sym))
         (unless (num? Tail)
            (let (L (any (& Tail -9))  X (car L))
               (if (atom X)
                  (and (== Key X) (ret $T))
                  (and (== Key (cdr X)) (ret (car X))) )
               (while (pair (setq X (cdr L)))
                  (let Y (car X)
                     (if (atom Y)
                        (when (== Key Y)
                           (set 2 L (cdr X))  # Unlink cell
                           (ifn (sym? Tail)
                              (set 2 X Tail)
                              (set 2 X (& Tail -9))
                              (setq X (| X 8)) )
                           (set (tail Sym) X)
                           (ret $T) )
                        (when (== Key (cdr Y))
                           (set 2 L (cdr X))  # Unlink cell
                           (ifn (sym? Tail)
                              (set 2 X Tail)
                              (set 2 X (& Tail -9))
                              (setq X (| X 8)) )
                           (set (tail Sym) X)
                           (ret (car Y)) ) )
                     (setq L X) ) ) ) )
         $Nil ) ) )

(de getn (Exe X Key)
   (when (num? X)  # Need symbol or pair
      (argErr Exe X) )
   (if (pair X)
      (nond
         ((num? Key)
            (loop  # asoq
               (let Y (car X)
                  (? (and (pair Y) (== Key (car Y)))
                     (cdr Y) ) )
               (? (atom (shift X))) ) )
         ((== ZERO Key)
            (let Cnt (int Key)  # nth
               (until (=0 (dec 'Cnt))
                  (shift X) )
               (if (sign? Key)
                  (cdr X)
                  (car X) ) ) )
         (NIL $Nil) )
      (when (sym? (val (tail X)))
         (dbFetch Exe X) )
      (tailcall
         (get X Key) ) ) )

(de prop (Sym Key)
   (let Tail (val (tail Sym))
      (unless (num? Tail)
         (let (L (any (& Tail -9))  X (car L))
            (if (atom X)
               (and (== Key X) (ret Key))
               (and (== Key (cdr X)) (ret X)) )
            (while (pair (setq X (cdr L)))
               (let Y (car X)
                  (if (atom Y)
                     (when (== Key Y)
                        (set 2 L (cdr X))  # Unlink cell
                        (ifn (sym? Tail)
                           (set 2 X Tail)
                           (set 2 X (& Tail -9))
                           (setq X (| X 8)) )
                        (set (tail Sym) X)
                        (ret Key) )
                     (when (== Key (cdr Y))
                        (set 2 L (cdr X))  # Unlink cell
                        (ifn (sym? Tail)
                           (set 2 X Tail)
                           (set 2 X (& Tail -9))
                           (setq X (| X 8)) )
                        (set (tail Sym) X)
                        (ret Y) ) ) )
               (setq L X) ) ) )
      (let R (cons $Nil Key)
         (set (tail Sym)
            (if (sym? Tail)
               (| (cons R (& Tail -9)) 8)
               (cons R Tail) ) )
         R ) ) )

# (put 'sym1|lst ['sym2|cnt ..] 'any) -> any
(de _put (Exe)
   (let
      (X (cdr Exe)
         Y (eval (++ X))
         Safe (link (push Y NIL))
         Key T )
      (loop
         (setq Key (eval (++ X)))
         (? (atom (cdr X)))
         (setq Y (set Safe (getn Exe Y Key))) )
      (when (num? Y)  # Need symbol or pair
         (argErr Exe Y) )
      (link (push Key NIL))
      (let Val (eval (car X))
         (if (pair Y)
            (putn Exe Y Key Val)
            (when (sym? (val (tail Y)))
               (if (nil? Val)
                  (dbFetch Exe Y)  # Volatile property
                  (dbTouch Exe Y) ) )
            (if (== ZERO Key)
               (set (chkVar Exe Y) Val)
               (put Y Key Val) ) )
         (drop Safe)
         Val ) ) )

# (get 'sym1|lst ['sym2|cnt ..]) -> any
(de _get (Exe)
   (let (X (cdr Exe)  Y (eval (++ X)))
      (when (pair X)
         (let Safe (link (push Y NIL))
            (loop
               (setq Y (getn Exe Y (eval (++ X))))
               (? (atom X))
               (set Safe Y) )
            (drop Safe) ) )
      Y ) )

# (prop 'sym1|lst ['sym2|cnt ..] 'sym) -> var
(de _prop (Exe)
   (let
      (X (cdr Exe)
         Y (eval (++ X))
         Safe (link (push Y NIL))
         Key T )
      (loop
         (setq Key (eval (++ X)))
         (? (atom X))
         (setq Y (set Safe (getn Exe Y Key))) )
      (needSym Exe Y)
      (link (push Key NIL))
      (when (sym? (val (tail Y)))
         (if (nil? Val)
            (dbFetch Exe Y)  # Volatile property
            (dbTouch Exe Y) ) )
      (drop Safe
         (prop Y Key) ) ) )

# (; 'sym1|lst [sym2|cnt ..]) -> any
(de _semicol (Exe)
   (let (X (cdr Exe)  Y (eval (++ X)))
      (when (pair X)
         (let Safe (link (push Y NIL))
            (loop
               (setq Y (getn Exe Y (++ X)))
               (? (atom X))
               (set Safe Y) )
            (drop Safe) ) )
      Y ) )

# (=: sym|0 [sym1|cnt ..] 'any) -> any
(de _setCol (Exe)
   (let (X (cdr Exe)  Y (val $This)  Key T)
      (loop
         (setq Key (++ X))
         (? (atom (cdr X)))
         (setq Y (getn Exe Y Key)) )
      (when (num? Y)  # Need symbol or pair
         (argErr Exe Y) )
      (let Val (eval (car X))
         (if (pair Y)
            (putn Exe Y Key Val)
            (when (sym? (val (tail Y)))
               (if (nil? Val)
                  (dbFetch Exe Y)  # Volatile property
                  (dbTouch Exe Y) ) )
            (if (== ZERO Key)
               (set (chkVar Exe Y) Val)
               (put Y Key Val) ) )
         Val ) ) )

# (: sym|0 [sym1|cnt ..]) -> any
(de _col (Exe)
   (let (X (cdr Exe)  Y (val $This))
      (loop
         (setq Y (getn Exe Y (++ X)))
         (? (atom X) Y) ) ) )

# (:: sym|0 [sym1|cnt .. sym2]) -> var
(de _propCol (Exe)
   (let (X (cdr Exe)  Y (val $This)  Key T)
      (loop
         (setq Key (++ X))
         (? (atom X))
         (setq Y (getn Exe Y Key)) )
      (needSym Exe Y)
      (when (sym? (val (tail Y)))
         (if (nil? Val)
            (dbFetch Exe Y)  # Volatile property
            (dbTouch Exe Y) ) )
      (prop Y Key) ) )

# (putl 'sym1|lst1 ['sym2|cnt ..] 'lst) -> lst
(de _putl (Exe)
   (let
      (X (cdr Exe)
         Y (eval (++ X))
         Safe (link (push Y NIL))
         Z T )
      (loop
         (setq Z (eval (++ X)))
         (? (atom X))
         (setq Y (set Safe (getn Exe Y Z))) )
      (let (R (link (push Z NIL))  Tail (val (tail Sym)))
         (when (sym? (setq X Tail))
            (dbTouch Exe Y)
            (setq X (& (val (tail Y)) -9)) )
         (until (num? X)  # Skip old properties
            (shift X) )
         (while (pair Z)  # New property list
            (let P (++ Z)
               (if (atom P)
                  (setq X (cons P X))
                  (unless (nil? (car P))
                     (when (== $T (car P))
                        (setq P (cdr P)) )
                     (setq X (cons P X)) ) ) ) )
         (set (tail Y)
            (if (sym? Tail) (| X 8) X) )
         (drop Safe
            (val R) ) ) ) )

# (getl 'sym1|lst1 ['sym2|cnt ..]) -> lst
(de _getl (Exe)
   (let
      (X (cdr Exe)
         Y (eval (car X))
         Safe (link (push Y NIL)) )
      (while (pair (shift X))
         (setq Y
            (set Safe (getn Exe Y (eval (car X)))) ) )
      (when (sym? (setq X (val (tail (needSym Exe Y)))))
         (dbFetch Exe Y)
         (setq X (& (val (tail Y)) -9)) )
      (drop Safe
         (if (num? X)
            $Nil
            (let R (setq Y (cons (car X) $Nil))
               (link (push R NIL))
               (while (pair (shift X))
                  (setq Y
                     (set 2 Y (cons (car X) $Nil)) ) )
               R ) ) ) ) )

(local) wipe

(de void wipe (Exe X)
   (let
      (Tail (val (tail (needSym Exe X)))
         Nm (name Tail) )
      (if (sym? Tail)  # External symbol
         (let N (add Nm Nm)  # Get carry
            (unless @@  # Not dirty
               (add N N)
               (when @@  # and loaded
                  (set X $Nil  (tail X) (| Nm 8)) ) ) )
         (set X $Nil  (tail X) Nm) ) ) )  # Clear value and properties

# (wipe 'sym|lst) -> sym|lst
(de _wipe (Exe)
   (let X (eval (cadr Exe))
      (unless (nil? X)
         (if (atom X)
            (wipe Exe X)
            (let Y X
               (loop
                  (wipe Exe (++ Y))
                  (? (atom Y)) ) ) ) )
      X ) )

(local) meta

(de meta (X Key)
   (while (pair X)
      (let Y (car X)
         (when (and (not (num? Y)) (sym? Y))
            (let Z (get Y Key)
               (? (not (nil? Z)) Z) )
            (stkChk 0)
            (let Z (meta (car Y) Key)
               (? (not (nil? Z)) Z) ) ) )
      (shift X) )
   $Nil )

# (meta 'obj|typ 'sym ['sym2|cnt ..]) -> any
(de _meta (Exe)
   (let
      (X (cdr Exe)
         Y (eval (++ X))
         Safe (link (push Y NIL)) )
      (when (num? Y)  # Need symbol or pair
         (argErr Exe Y) )
      (when (sym? Y)
         (when (sym? (val (tail Y)))
            (dbFetch Exe Y) )
         (setq Y (val Y)) )
      (setq Y (meta (eval (car X)) Y))
      (while (pair (shift X))
         (set Safe Y)
         (setq Y (get (eval (car X)) Y)) )
      (drop Safe)
      Y ) )

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
                  (P (push 0 (name Tail) NIL)  # [cnt name link]
                     Q (link (ofs P 1))
                     R (push 4 ZERO NIL)  # [cnt name link]
                     C T )
                  (link (ofs R 1))
                  (until (=0 (setq C (numChar P)))
                     (charNum (toLowerCase C) R) )
                  (drop Q
                     (consStr (val 2 R)) ) ) ) ) ) ) )

# (uppc 'any) -> any
(de _uppc (Exe)
   (let X (eval (cadr Exe))
      (if (or (num? X) (pair X) (nil? X))
         X
         (let Tail (val (tail X))
            (if (sym? Tail)  # External symbol
               X
               (let
                  (P (push 0 (name Tail) NIL)  # [cnt name link]
                     Q (link (ofs P 1))
                     R (push 4 ZERO NIL)  # [cnt name link]
                     C T )
                  (link (ofs R 1))
                  (until (=0 (setq C (numChar P)))
                     (ifn (== C (char "ß"))
                        (charNum (toUpperCase C) R)
                        (charNum (char "S") R)
                        (charNum (char "S") R) ) )
                  (drop Q
                     (consStr (val 2 R)) ) ) ) ) ) ) )

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
                     P (push 0 (name Tail) NIL)  # [cnt name link]
                     Q (link (ofs P 1))
                     R (push 4 ZERO NIL)  # [cnt name link]
                     C T )
                  (link (ofs R 1))
                  (until (=0 (setq C (numChar P)))
                     (when (isLetterOrDigit C)
                        (charNum (toLowerCase C) R)
                        (? (=0 (dec 'N))) ) )
                  (drop Q
                     (consStr (val 2 R)) ) ) ) ) ) ) )
