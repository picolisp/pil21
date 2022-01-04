# 04jan22 Software Lab. Alexander Burger

(symbols '(llvm))

(local) (bufSize pathSize bufString pathString)

(de i64 bufSize (Nm)
   (let N 1
      (while (big? Nm)
         (inc 'N 8)
         (setq Nm (val (big Nm))) )
      (setq Nm (int Nm))
      (while Nm
         (inc 'N)
         (setq Nm (shr Nm 8)) )
      N ) )

(de i64 pathSize (Nm)
   (let
      (Len (bufSize Nm)
         N (if (cnt? Nm) (int @) (val (dig @)))
         B (i8 N) )
      (cond
         ((or
               (== B (char "@"))
               (and
                  (== B (char "+"))
                  (== (i8 (shr N 8)) (char "@")) ) )
            (+ (val $PilLen) (dec Len)) )
         ((or
               (== B (char "~"))
               (and
                  (== B (char "+"))
                  (== (i8 (shr N 8)) (char "~")) ) )
            (+ (val $UsrLen) (dec Len)) )
         (T Len) ) ) )

(de i8* bufString (Nm (i8* . P))
   (let Q (push 0 Nm)  # [cnt name]
      (prog1 P
         (while (set P (symByte Q))
            (inc 'P) ) ) ) )

(de i8* pathString (Nm (i8* . P))
   (let (Q (push 0 Nm)  B (symByte Q))  # [cnt name]
      (prog1 P
         (when (== B (char "+"))
            (set P B)
            (inc 'P)
            (setq B (symByte Q)) )
         (case B
            ((char "@")
               (when (val $PilLen)
                  (memcpy P (val $PilHome) @)
                  (inc 'P @) ) )
            ((char "~")
               (when (val $UsrLen)
                  (memcpy P (val $UsrHome) @)
                  (inc 'P @) ) )
            (T
               (set P B)
               (inc 'P) ) )
         (while (set P (symByte Q))
            (inc 'P) ) ) ) )

(local) (mkChar mkStr firstByte firstChar isBlank)

(de mkChar ((i32 . C))
   (consStr
      (cnt
         (cond
            ((>= 127 C) (i64 C))  # Single byte
            ((== TOP C) (hex "FF"))  # Infinite
            ((> (hex "800") C)  # Double-byte
               (i64
                  (|
                     (| (hex "C0") (& (shr C 6) (hex "1F")))  # 10xxxxx 10xxxxxx
                     (shl (| (hex "80") (& C (hex "3F"))) 8) ) ) )
            ((> (hex "10000") C)  # Three bytes
               (i64
                  (|
                     (|
                        (| (hex "E0") (& (shr C 12) (hex "0F")))  # 1110xxxx 10xxxxxx 10xxxxxx
                        (shl (| (hex "80") (& (shr C 6) (hex "3F"))) 8) )
                     (shl (| (hex "80") (& C (hex "3F"))) 16) ) ) )
            (T
               (|
                  (i64
                     (|
                        (|
                           (| (hex "F0") (& (shr C 18) (hex "07")))  # 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
                           (shl (| (hex "80") (& (shr C 12) (hex "3F"))) 8) )
                        (shl (| (hex "80") (& (shr C 6) (hex "3F"))) 16) ) )
                  (shl
                     (| (hex "80") (& (i64 C) (hex "3F")))
                     24 ) ) ) ) ) ) )

(de mkStr ((i8* . Str))
   (if Str
      (let P (push 4 NIL ZERO NIL)  # [cnt last name link]
         (link (ofs P 2) T)
         (while (val Str)
            (byteSym @ P)
            (inc 'Str) )
         (consStr (val 3 P)) )
      $Nil ) )

(de mkStrE ((i8* . Str) (i8* . End))
   (let P (push 4 NIL ZERO NIL)  # [cnt last name link]
      (link (ofs P 2) T)
      (loop
         (? (== Str End))
         (? (=0 (val Str)))
         (byteSym @ P)
         (inc 'Str) )
      (consStr (val 3 P)) ) )

(de i8 firstByte (Sym)
   (i8
      (cond
         ((nil? Sym) 0)
         ((sym? (val (tail Sym))) 0)
         ((cnt? (name @)) (int @))
         (T (val (dig @))) ) ) )

(de i32 firstChar (Sym)
   (cond
      ((nil? Sym) 0)
      ((sym? (val (tail Sym))) 0)  # External symbol
      (T (symChar (push 0 (name @)))) ) )  # Else get name

(de i1 isBlank (X)
   (or
      (nil? X)
      (and
         (symb? X)
         (not (sym? (val (tail X))))
         (let P (push 0 (name @))  # [cnt name]
            (loop
               (? (=0 (symByte P)) YES)
               (? (> @ 32) NO) ) ) ) ) )

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
   (byteSym (+ (& (i8 File) 15) (char "@")) P) )  # Make ASCII letter

(de void packOct ((i64 . Obj) (i64* . P))
   (when (> Obj 7)
      (packOct (shr Obj 3) P) )  # Divide by 8
   (byteSym (+ (& (i8 Obj) 7) (char "0")) P) )  # Make ASCII digit

(de void packExtNm (Name (i64* . P))
   (when (objFile Name)
      (packAO @ P) )
   (packOct (objId Name) P) )

# General pack
(de void pack (X (i64* . P))
   (when (pair X)
      (stkChk 0)
      (loop
         (pack (++ X) P)
         (? (atom X)) ) )
   (cond
      ((nil? X))
      ((num? X) (fmtNum X 0 0 0 P))
      ((sym? (val (tail X)))
         (byteSym (char "{") P)
         (packExtNm (name (& @ -9)) P)
         (byteSym (char "}") P) )
      (T
         (let Q (push 0 (name @))  # [cnt name]
            (while (symByte Q)
               (byteSym @ P) ) ) ) ) )

# Chop external symbol name
(de chopExtNm (Name)
   (let (R (link (push $Nil NIL))  N (objId Name))
      (loop
         (let A (+ (& N 7) (char "0"))  # Make ASCII digit
            (when (setq N (shr N 3))
               (setq A
                  (|
                     (shl A 8)
                     (+ (& N 7) (char "0")) ) )  # Second octal digit
               (when (setq N (shr N 3))
                  (setq A
                     (|
                        (shl A 8)
                        (+ (& N 7) (char "0")) ) ) ) )  # Third octal digit
            (set R
               (cons (consSym (cnt A) 0) (val R)) ) )
         (? (=0 (setq N (shr N 3)))) )
      (when (setq N (objFile Name))
         (let F (i32 0)
            (loop
               (setq F
                  (| F (+ (& N 15) (char "@"))) )  # Make ASCII letter
               (? (=0 (setq N (shr N 4))))
               (setq F (shl F 8)) )
            (set R
               (cons (consStr (cnt (i64 F))) (val R)) ) ) )
      (pop R) ) )

### Interning ###
(local) (cmpLong isIntern isLstIntern findSym)

# Compare long names
(de i64 cmpLong (X Y)
   (loop
      (? (sub (val (dig X)) (val (dig Y)))
         (if @@ -1 +1) )
      (setq X (val (big X))  Y (val (big Y)))
      (? (cnt? X)
         (cond
            ((big? Y) -1)
            ((== Y X) 0)
            ((> Y X) -1)
            (T +1) ) )
      (? (cnt? Y) +1) ) )

# Is name interned?
(de isIntern (Name Tree)
   (if (cnt? Name)  # Short name
      (let X (car Tree)  # First tree
         (loop
            (? (atom X) 0)  # Empty
            (let (S (car X)  Nm (name (val (tail S))))
               (? (== Name Nm) S)
               (setq X
                  (if (> Name Nm)  # Symbol is smaller
                     (cddr X)
                     (cadr X) ) ) ) ) )
      # Long name
      (let X (cdr Tree)  # Second tree
         (loop
            (? (atom X) 0)  # Empty
            (let (S (car X)  Nm (name (val (tail S))))
               (? (=0 (cmpLong Nm Name)) S)
               (setq X
                  (if (lt0 @)  # Symbol is smaller
                     (cddr X)
                     (cadr X) ) ) ) ) ) ) )

(de isLstIntern (Name Lst)
   (loop
      (? (atom Lst) 0)
      (? (isIntern Name (cdar (car Lst))) @)
      (shift Lst) ) )

(de i1 findSym (Sym Name Lst)
   (loop
      (? (atom Lst) NO)
      (? (== Sym (isIntern Name (cdar (car Lst)))) YES)
      (shift Lst) ) )

(local) (intern1 intern2 internRight internLeft)

(inline intern1 (Sym Val Name Node More)
   (if (isLstIntern Name More)
      @
      (unless Sym  # New symbol
         (setq Sym (consSym Name Val)) )
      (set Node (cons Sym $Nil))
      Sym ) )

(inline intern2 (Sym Val Name Node More)
   (if (isLstIntern Name More)
      @
      (unless Sym  # New symbol
         (setq Sym (consSym Name Val)) )
      (set 2 Node (cons Sym $Nil))
      Sym ) )

(inline internRight (Sym Val Name Node More)
   (if (isLstIntern Name More)
      @
      (unless Sym  # New symbol
         (setq Sym (consSym Name Val)) )
      (set 2 Node (cons $Nil (cons Sym $Nil)))
      Sym ) )

(inline internLeft (Sym Val Name Node More)
   (if (isLstIntern Name More)
      @
      (unless Sym  # New symbol
         (setq Sym (consSym Name Val)) )
      (set 2 Node (cons (cons Sym $Nil) $Nil))
      Sym ) )

(local) (intern requestSym extern delNode unintern)

# Intern a symbol/name
(de intern (Sym Val Name Tree More (i1 . Rpl))
   (if (cnt? Name)  # Short name
      (let X (car Tree)  # First tree
         (if (pair X)  # Not empty
            (loop
               (let (S (car X)  Nm (name (val (tail S))))
                  (? (== Name Nm)  # Found name
                     (if Rpl
                        (set X Sym)  # Replace with argument symbol
                        S ) )  # Return found symbol
                  (let Y (cdr X)  # Get link cell
                     (cond
                        ((> Name Nm)  # Symbol is smaller
                           (? (atom Y) (internRight Sym Val Name X More))  # No link yet
                           (? (atom (setq Y (cdr (setq X Y))))
                              (intern2 Sym Val Name X More) ) )
                        (T  # Symbol is greater
                           (? (atom Y) (internLeft Sym Val Name X More))  # No link yet
                           (? (atom (setq Y (car (setq X Y))))
                              (intern1 Sym Val Name X More) ) ) )
                     (setq X Y) ) ) )
            # Empty
            (intern1 Sym Val Name Tree More) ) )
      # Long name
      (let X (cdr Tree)  # Second tree
         (if (pair X)  # Not empty
            (loop
               (let (S (car X)  Nm (name (val (tail S))))
                  (? (=0 (cmpLong Nm Name))  # Found name
                     (if Rpl
                        (set X Sym)  # Replace with argument symbol
                        S ) )  # Return found symbol
                  (let Y (cdr X)  # Get link cell
                     (cond
                        ((lt0 @)  # Symbol is smaller
                           (? (atom Y) (internRight Sym Val Name X More))  # No link yet
                           (? (atom (setq Y (cdr (setq X Y))))
                              (intern2 Sym Val Name X More) ) )
                        (T  # Symbol is greater
                           (? (atom Y) (internLeft Sym Val Name X More))  # No link yet
                           (? (atom (setq Y (car (setq X Y))))
                              (intern1 Sym Val Name X More) ) ) )
                     (setq X Y) ) ) )
            # Empty
            (intern2 Sym Val Name Tree More) ) ) ) )

(de requestSym (Name)
   (if (isIntern Name $PrivT)
      @
      (let L (val $Intern)
         (intern 0 $Nil Name
            (cdar (car L))
            (cdr L)
            NO ) ) ) )

# Intern an external symbol
(de extern (Name)
   (need3)  # Reserve 3 cells
   (let (X (val $Extern)  C 0  Sym T)
      (loop
         (inc 'C)  # Next level
         (setq Sym (car X))  # Next symbol
         (let Nm
            (&
               (name (& (val (tail Sym)) -9))
               (hex "3FFFFFFFFFFFFFF7") )  # Mask status and extern bits
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
                              (name (& (val (tail (++ X))) -9))
                              (hex "3FFFFFFFFFFFFFF7") ) )
                        (cdr X)
                        (car X) ) )
                  (? (=0 (dec 'C))) ) ) )
         (loop  # Pivot
            (let
               (Nm
                  (&
                     (name (& (val (tail (car X))) -9))
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
   (let Tail (val (tail (needSymb Exe (eval (cadr Exe)))))
      (if (sym? Tail)  # External
         (let P (push 4 NIL ZERO NIL)  # [cnt last name link]
            (link (ofs P 2) T)
            (packExtNm (name (& Tail -9)) P)
            (consStr (val 3 P)) )
         (consStr (name Tail)) ) ) )

# (nsp 'sym) -> sym
(de _nsp (Exe)
   (let Sym (needSymb Exe (eval (cadr Exe)))
      (if (sym? (val (tail Sym)))
         $Nil
         (let (Nm (name @)  Lst (val $Intern))  # Search namespaces
            (loop
               (? (atom Lst) $Nil)
               (let Nsp (car Lst)
                  (? (== Sym (isIntern Nm (cdar Nsp))) Nsp) )
               (shift Lst) ) ) ) ) )

# (sp? 'any) -> flg
(de _spQ (Exe)
   (if (isBlank (eval (cadr Exe)))
      $T
      $Nil ) )

# (pat? 'any) -> sym | NIL
(de _patQ (Exe)
   (let X (eval (cadr Exe))
      (if (and (symb? X) (== (firstChar X) (char "@")))
         X
         $Nil ) ) )

# (fun? 'any) -> any
(de _funQ (Exe)
   (if (funq (eval (cadr Exe)))
      @
      $Nil ) )

# (getd 'any) -> fun | NIL
(de _getd (Exe)
   (let (X (eval (cadr Exe))  V T)
      (cond
         ((not (symb? X)) $Nil)
         ((funq (setq V (val X))) V)
         ((and (nil? V) (sharedLib X)) (val X))
         (T $Nil) ) ) )

### Namespaces ###
(local) consTree

# Build sorted list from tree
(de consTree (P Lst)
   (if (atom P)
      Lst
      (let
         (Q (link (push NIL NIL))
            Tos (link (push -ZERO NIL)))
         (loop
            (loop
               (let X (cdr P)  # Get subtrees
                  (? (atom (cdr X)))  # Right subtree
                  (let Y P  # Go right
                     (setq P @)  # Invert tree
                     (set 2 X (val Tos))
                     (set Tos Y) ) ) )
            (set Q P)  # Save tree
            (loop
               (setq Lst (cons (car P) Lst))  # Cons symbol
               (let X (cdr P)
                  (? (pair (car X))  # Left subtree
                     (let Y P  # Go left
                        (setq P @)  # Invert tree
                        (set X (val Tos))
                        (set Tos (| Y 8))  # First visit
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
                        (set Q P) ) ) ) ) ) ) ) )  # Save tree

# (all ['NIL | 'T | '0 | 'sym | '(NIL . flg) | '(T . flg) | '(0)]) -> lst
(de _all (Exe)
   (let X (eval (cadr Exe))
      (cond
         ((nil? X)  # Internal symbols
            (let Y (val $Intern)
               (loop
                  (let Z (cdar (++ Y))
                     (setq X
                        (consTree (car Z) (consTree (cdr Z) X)) ) )
                  (? (atom Y) X) ) ) )
         ((t? X)  # Transient symbols
            (consTree (val $Transient) (consTree (val 2 $Transient) $Nil)) )
         ((num? X)  # External symbols
            (consTree (val $Extern) $Nil) )
         ((sym? X)  # Given namespace
            (let Y (cdar X)
               (if (pair Y)
                  (consTree (car Y) (consTree (cdr Y) $Nil))
                  $Nil ) ) )
         ((nil? (car X))  # Direct internal tree
            (let Y (val (car (val $Intern)))
               (if (nil? (cdr X))
                  (val Y)
                  (val 2 Y) ) ) )
         ((t? (car X))  # Direct transient trees
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
               (let L Y
                  (loop
                     (needNsp Exe (needSymb Exe (++ L)))
                     (? (atom L)) )
                  (if (atom X)  # No 'prg'
                     (prog1
                        (val $Intern)
                        (set $Intern Y) )
                     (let Z (save (val $Intern))
                        (set $Intern Y)
                        (prog1
                           (run X)  # Run 'prg'
                           (set $Intern Z) ) ) ) )
               (if
                  (or  # New namespace
                     (nil? (val (needSymb Exe Y)))
                     (== @ Y) )
                  (set
                     (chkVar Exe Y)
                     (cons $Tilde (cons $Nil $Nil)) )
                  (needNsp Exe Y) )
               (let R (setq Y (save (cons Y $Nil)))
                  (while (pair X)
                     (setq Y
                        (set 2 Y
                           (cons
                              (needNsp Exe (needSymb Exe (eval (++ X))))
                              $Nil ) ) ) )
                  (prog1
                     (val $Intern)
                     (set $Intern R) ) ) ) ) ) ) )

# (intern 'sym ['nsp]) -> sym
(de _intern (Exe)
   (let
      (X (cdr Exe)
         Sym (save (needSymb Exe (eval (++ X)))) )
      (cond
         ((sym? (val (tail Sym))) $Nil)  # External symbol
         ((== (name @) ZERO) $Nil)  # Anonymous symbol
         (T
            (let Nm @
               (if (nil? (eval (car X)))
                  (let L (val $Intern)
                     (intern Sym 0 Nm
                        (cdar (car L))
                        (cdr L)
                        NO ) )
                  (intern Sym 0 Nm
                     (if (t? @)
                        (cdar (car (val $Intern)))
                        (cdar @) )
                     $Nil
                     NO ) ) ) ) ) ) )

# (====) -> NIL
(de _hide (Exe)
   (set $Transient (set 2 $Transient $Nil)) )

# (box? 'any) -> sym | NIL
(de _boxQ (Exe)
   (let X (eval (cadr Exe))
      (if
         (and
            (symb? X)
            (not (sym? (val (tail X))))
            (== ZERO (name @)) )
         X
         $Nil ) ) )

# (str? 'any) -> sym | NIL
(de _strQ (Exe)
   (let X (eval (cadr Exe))
      (cond
         ((not (symb? X)) $Nil)
         ((or
               (sym? (val (tail X)))  # External
               (findSym X (name @) (val $Intern)) )
            $Nil )
         (T X) ) ) )

# (zap 'sym) -> sym
(de _zap (Exe)
   (let Sym (needSymb Exe (eval (cadr Exe)))
      (if (sym? (val (tail Sym)))  # External
         (dbZap Sym)
         (unintern Sym (name @) (cdar (car (val $Intern)))) )
      Sym ) )

# (chop 'any) -> lst
(de _chop (Exe)
   (let X (eval (cadr Exe))
      (if (or (pair X) (nil? X))
         X
         (let Tail (val (tail (xSym X)))
            (if (sym? Tail)  # External
               (chopExtNm (name (& Tail -9)))
               (let (P (push 0 (name Tail))  C (symChar P))
                  (if C
                     (save Tail
                        (let (Y (cons (mkChar C) $Nil)  R (save Y))
                           (while (setq C (symChar P))
                              (setq Y
                                 (set 2 Y (cons (mkChar C) $Nil)) ) )
                           R ) )
                     $Nil ) ) ) ) ) ) )

# (pack 'any ..) -> sym
(de _pack (Exe)
   (save -ZERO
      (let
         (X (cdr Exe)
            P (push 4 NIL ZERO NIL) )  # [cnt last name link]
         (link (ofs P 2))
         (while (pair X)
            (pack (safe (eval (++ X))) P) )
         (consStr (val 3 P)) ) ) )

# (glue 'any 'lst) -> sym
(de _glue (Exe)
   (let (X (cdr Exe)  Y (save (eval (++ X))))  # 'any'
      (if (atom (eval (++ X)))  # 'lst'
         @
         (let (Z (save @)  P (push 4 NIL ZERO NIL))  # [cnt last name link]
            (link (ofs P 2))
            (loop
               (pack (++ Z) P)
               (? (atom Z))
               (pack Y P) )
            (consStr (val 3 P)) ) ) ) )

# (text 'any1 'any ..) -> sym
(de _text (Exe)
   (let (X (cdr Exe)  Y (evSym X))
      (if (nil? Y)
         Y
         (let
            (P (push 0 (xName Exe Y) NIL)  # [cnt name link]
               Q (link (ofs P 1) T)
               R (push 4 NIL ZERO NIL)  # [cnt last name link]
               A (link (ofs R 2))
               N 0
               C T )
            (while (pair (shift X))
               (setq A (link (push (eval (car X)) NIL)))
               (inc 'N) )
            (while (setq C (symByte P))
               (cond
                  ((<> C (char "@")) (byteSym C R))
                  ((== (setq C (symByte P)) (char "@"))
                     (byteSym C R) )  # "@@"
                  ((gt0 (dec 'C (char "0")))
                     (when (> C 9)
                        (dec 'C 7) )  # Adjust for letter
                     (when (ge0 (setq C (- N (i64 C))))
                        (let I A
                           (while (ge0 (dec 'C))
                              (shift I) )
                           (pack (val I) R) ) ) ) ) )
            (consStr (val 3 R)) ) ) ) )

### Matching ###
(local) (preStr subStr)

(de i1 preStr (Nm (i8 . B) (i64* . P))
   (let (Q (push 0 (i64 Nm))  C (symByte Q))
      (loop
         (? (<> B C) NO)
         (? (=0 (setq C (symByte Q))) YES)
         (? (=0 (setq B (symByte P))) NO) ) ) )

(de i1 subStr (X Y)
   (or
      (nil? X)
      (== ZERO (setq X (xName 0 X)))
      (let (P (push 0 (xName 0 Y))  B T)
         (loop
            (? (=0 (setq B (symByte P))) NO)
            (let (Cnt (val P)  Nm (val 2 P))
               (? (preStr X B P) YES)
               (set P Cnt  2 P Nm) ) ) ) ) )

# (pre? 'any1 'any2) -> any2 | NIL
(de _preQ (Exe)
   (let (X (cdr Exe)  Y (save (evSym X))  Z (evSym (shift X)))
      (cond
         ((nil? Y) Z)
         ((== ZERO (setq Y (xName Exe Y)))
            Z )
         (T
            (let P (push 0 (xName Exe Z))
               (cond
                  ((=0 (symByte P)) $Nil)
                  ((preStr Y @ P) Z)
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
      (when (and (sym? V) (sym? (val (tail V))))
         (dbFetch Exe V) )
      (val V) ) )

# (set 'var 'any ..) -> any
(de _set (Exe)
   (save -ZERO
      (let X (cdr Exe)
         (loop
            (let Y (safe (needChkVar Exe (eval (++ X))))
               (when (and (sym? Y) (sym? (val (tail Y))))
                  (dbTouch Exe Y) )
               (let Z (eval (++ X))
                  (set Y Z)
                  (? (atom X) Z) ) ) ) ) ) )

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
      (when (and (sym? Y) (sym? (val (tail Y))))
         (dbTouch Exe Y) )
      (let (Z (eval (car X))  V (val Y))
         (set Y Z)
         V ) ) )

# (xchg 'var 'var ..) -> any
(de _xchg (Exe)
   (save -ZERO
      (let X (cdr Exe)
         (loop
            (let Y (safe (needChkVar Exe (eval (++ X))))
               (when (and (sym? Y) (sym? (val (tail Y))))
                  (dbTouch Exe Y) )
               (let Z (needChkVar Exe (eval (++ X)))
                  (when (and (sym? Z) (sym? (val (tail Z))))
                     (dbTouch Exe Z) )
                  (setq Z (xchg Y Z))
                  (? (atom X) Z) ) ) ) ) ) )

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
      (when (and (sym? Y) (sym? (val (tail Y))))
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
      (when (and (sym? Y) (sym? (val (tail Y))))
         (dbTouch Exe Y) )
      (loop
         (let (Z (eval (++ X))  V (val Y))
            (unless (member Z V)
               (set Y (cons Z V)) )
            (? (atom X) Z) ) ) ) )

# (push1q 'var 'any ..) -> any
(de _push1q (Exe)
   (let
      (X (cdr Exe)
         Y (save (needChkVar Exe (eval (++ X)))) )
      (when (and (sym? Y) (sym? (val (tail Y))))
         (dbTouch Exe Y) )
      (loop
         (let (Z (eval (++ X))  V (val Y))
            (unless (memq Z V)
               (set Y (cons Z V)) )
            (? (atom X) Z) ) ) ) )

# (pop 'var) -> any
(de _pop (Exe)
   (let X (needChkVar Exe (eval (cadr Exe)))
      (when (and (sym? X) (sym? (val (tail X))))
         (dbTouch Exe X) )
      (if (atom (val X))
         @
         (set X (cdr @))
         (car @) ) ) )

# (++ var) -> any
(de _popq (Exe)
   (let X (needChkVar Exe (cadr Exe))
      (if (atom (val X))
         @
         (set X (cdr @))
         (car @) ) ) )

# (shift 'var) -> any
(de _shift (Exe)
   (let X (needChkVar Exe (eval (cadr Exe)))
      (when (and (sym? X) (sym? (val (tail X))))
         (dbTouch Exe X) )
      (set X (cdr (needLst Exe (val X)))) ) )

# (cut 'cnt 'var) -> lst
(de _cut (Exe)
   (let (X (cdr Exe)  N (evCnt Exe X))
      (if (le0 N)
         $Nil
         (let Y (needChkVar Exe (eval (cadr X)))
            (when (and (sym? Y) (sym? (val (tail Y))))
               (dbTouch Exe Y) )
            (if (atom (val Y))
               @
               (let
                  (V (save @)
                     Z (cons (++ V) $Nil)
                     R (save Z) )
                  (while (and (pair V) (dec 'N))
                     (setq Z (set 2 Z (cons (++ V) $Nil))) )
                  (set Y V)  # Set new value
                  R ) ) ) ) ) )

# (del 'any 'var ['flg]) -> lst
(de _del (Exe)
   (let
      (X (cdr Exe)
         Y (save (eval (++ X)))
         Var (save (needChkVar Exe (eval (++ X))))
         Flg (nil? (eval (car X))) )
      (when (and (sym? Var) (sym? (val (tail Var))))
         (dbTouch Exe Var) )
      (let V (val Var)
         (loop
            (? (atom V) V)
            (let Z (++ V)
               (? (not (equal Y Z))
                  (let (P (cons Z $Nil)  R P)
                     (save R
                        (loop
                           (? (atom V))
                           (if (equal Y (setq Z (++ V)))
                              (? Flg)
                              (setq P (set 2 P (cons Z $Nil))) ) ) )
                     (set 2 P V  Var R) ) ) )
            (set Var V)
            (? Flg V) ) ) ) )

# (queue 'var 'any) -> any
(de _queue (Exe)
   (let
      (X (cdr Exe)
         Y (save (needChkVar Exe (eval (++ X)))) )
      (when (and (sym? Y) (sym? (val (tail Y))))
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
      (when (and (sym? Y) (sym? (val (tail Y))))
         (dbTouch Exe Y) )  # External symbol
      (let V (val Y)
         (cond
            ((pair X)  # Add to fifo
               (let E (eval (car X))
                  (if (pair V)
                     (setq V (set 2 V (cons E (cdr V))))  # Concat into value
                     (setq V (cons E -ZERO))  # Circular cell
                     (set 2 V V) )
                  (while (pair (shift X))
                     (setq V
                        (set 2 V
                           (cons
                              (setq E (eval (car X)))
                              (cdr V) ) ) ) )
                  (set Y V)
                  E ) )
            ((atom V) $Nil)  # Empty
            ((== (cdr V) V)  # Single cell
               (set Y $Nil)  # Clear value
               (car V) )
            (T
               (set 2 V (cdr @))  # Remove
               (car @) ) ) ) ) )  # and return

# (rid 'var 'any) -> any
(de _rid (Exe)
   (let
      (X (cdr Exe)
         Y (save (needChkVar Exe (eval (++ X)))) )
      (when (and (sym? Y) (sym? (val (tail Y))))
         (dbTouch Exe Y) )  # External symbol
      (setq X (eval (car X)))
      (let V (val Y)
         (cond
            ((pair V)
               (let (Z V  L (cdr Z))
                  (loop
                     (? (atom L)  # Non-circular
                        (when (equal L X)
                           (set 2 Z $Nil) )
                        (if (equal (car V) X)
                           (set Y (cdr V))
                           V ) )
                     (? (== L V)  # Circular
                        (nond
                           ((equal (car L) X) V)
                           ((== L Z)
                              (set 2 Z (cdr L))
                              (set Y Z) )
                           (NIL (set Y $Nil)) ) )
                     (if (equal (car L) X)
                        (set 2 Z (shift L))
                        (setq L (cdr (shift Z))) ) ) ) )
            ((equal V X) (set Y $Nil))
            (T V) ) ) ) )

# (enum 'var 'cnt ['cnt ..]) -> lst
# (enum 'var) -> lst
(de _enum (Exe)
   (let
      (X (cdr Exe)
         Var (save (needChkVar Exe (eval (++ X))))
         Cnt T )
      (if (pair X)
         (loop
            (? (le0 (setq Cnt (evCnt Exe X))) $Nil)
            (let P (val Var)
               (loop
                  (let N (shr Cnt 1)
                     (? (=0 N)
                        (setq Var
                           (if (pair P)
                              @
                              (set Var (cons $Nil $Nil)) ) ) )
                     (if (& Cnt 1)
                        (cond
                           ((atom P)
                              (let Y (cons $Nil (setq P $Nil))
                                 (set Var (cons $Nil Y))
                                 (setq Var (ofs Y 1)) ) )
                           ((atom (cdr P))
                              (setq Var
                                 (ofs
                                    (set 2 P (cons $Nil (setq P $Nil)))
                                    1 ) ) )
                           (T
                              (setq P (val (setq Var (ofs @ 1)))) ) )
                        (cond
                           ((atom P)
                              (let Y (cons (setq P $Nil) $Nil)
                                 (set Var (cons $Nil Y))
                                 (setq Var Y) ) )
                           ((atom (cdr P))
                              (setq Var
                                 (set 2 P (cons (setq P $Nil) $Nil)) ) )
                           (T (setq P (val (setq Var @)))) ) )
                     (setq Cnt N) ) ) )
            (? (atom (shift X)) Var) )
         (setq Cnt 0)
         (let
            (Q (link (push NIL NIL))
               Tos (link (push -ZERO NIL))
               R (link (push $Nil NIL))
               P (val Var)
               M 1 )
            (loop
               (loop
                  (let Y (cdr P)  # Get subtrees
                     (? (atom (cdr Y)))  # Right subtree
                     (let Z P  # Go right
                        (setq P @)  # Invert tree
                        (set 2 Y (val Tos))
                        (set Tos Z) )
                     (setq
                        Cnt (| Cnt M)
                        M (shl M 1) ) ) )
               (set Q P)  # Save tree
               (loop
                  (unless (nil? (car P))
                     (set R
                        (cons  # (cnt . any)
                           (cons (cnt (| Cnt M)) @)
                           (val R) ) ) )
                  (let Y (cdr P)
                     (? (pair (car Y))  # Left subtree
                        (let Z P  # Go left
                           (setq P @)  # Invert tree
                           (set Y (val Tos))
                           (set Tos (| Z 8))  # First visit
                           (set Q P) )  # Save tree
                        (setq M (shl M 1)) ) )
                  (loop
                     (let Y (val Tos)
                        (when (== -ZERO Y)
                           (ret (val R)) )
                        (? (=0 (& Y 8))  # Second visit
                           (setq
                              M (shr M 1)
                              Cnt (& Cnt (x| M -1)) )
                           (let Z (cdr Y)  # Nodes
                              (set Tos (cdr Z))  # TOS on up link
                              (set 2 Z P)
                              (setq P Y)
                              (set Q P) ) )  # Save tree
                        (setq
                           Y (& Y -9)  # Clear visit bit
                           M (shr M 1)
                           Cnt (& Cnt (x| M -1)) )
                        (let Z (cdr Y)  # Nodes
                           (set Tos (car Z))
                           (set Z P)
                           (setq P Y)
                           (set Q P) ) ) ) ) ) ) ) ) )  # Save tree

# (enum? 'lst 'cnt ['cnt ..]) -> lst | NIL
(de _enumQ (Exe)
   (let
      (X (cdr Exe)
         P (save (eval (++ X)))
         Cnt T )
      (loop
         (? (le0 (setq Cnt (evCnt Exe X))) $Nil)
         (loop
            (let N (shr Cnt 1)
               (? (=0 N))
               (setq P
                  (if (& Cnt 1) (cddr P) (cadr P)) )
               (? (atom P) (ret $Nil))
               (setq Cnt N) ) )
         (? (atom (shift X)) P)
         (setq P (car P)) ) ) )

(local) (idxPut idxGet idxDel)

(de idxPut (Var Key)
   (let X (val Var)
      (if (pair X)
         (loop
            (? (=0 (compare (car X) Key)) X)  # Found key
            (let Y (cdr X)  # Get link cell
               (cond
                  ((lt0 @)  # Entry is smaller
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
               (setq X Y) ) )
         (set Var (cons Key $Nil))
         $Nil ) ) )

(de idxGet (Var Key)
   (let X (val Var)
      (loop
         (? (atom X) $Nil)
         (? (=0 (compare (car X) Key)) X)  # Found key
         (let Y (cdr X)  # Get link cell
            (setq X
               (if (lt0 @) (cdr Y) (car Y)) ) ) ) ) )

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
                        ((t? Y) (setq P (cadr P)))
                        ((atom Y) (setq P (cddr P)))
                        (T
                           (? (=0 (compare (car Y) Key)) (car P))
                           (setq
                              P (cdr P)
                              P (if (lt0 @) (cdr P) (car P)) ) ) ) )
                  (? (atom P) $Nil) )
               (save Key)
               (let
                  (Key2 (save (eval (car X)))
                     Q (link (push NIL NIL))
                     Tos (link (push -ZERO NIL))
                     R $Nil )
                  (loop
                     (loop
                        (let Y (cdr (setq X (cdr P)))  # Right subtree
                           (? (atom Y))
                           (let Z (car P)
                              (? (t? Z))
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
                           (? (pair (car (setq X (cdr P))))  # Left subtree
                              (let Z P  # Go left
                                 (setq P @)  # Invert tree
                                 (set X (val Tos))
                                 (set Tos (| Z 8))  # First visit
                                 (set Q P) ) ) )  # Save tree
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
                           (if (sym? Tail) (sym L) L) ) )
                     ((<> Val $T)  # Change to cell
                        (set L (cons Val Key)) ) )
                  (ret) )
               (when (== Key (cdr X))
                  (cond
                     ((nil? Val)
                        (shift L)  # Remove first property
                        (set (tail Sym)
                           (if (sym? Tail) (sym L) L) ) )
                     ((t? Val) (set L Key))  # Change to flag
                     (T (set X Val)) )  # Set new value
                  (ret) ) )
            (while (pair (setq X (cdr L)))
               (let Y (car X)
                  (if (atom Y)
                     (when (== Key Y)
                        (if (nil? Val)
                           (set 2 L (cdr X))  # Remove cell
                           (unless (t? Val)
                              (set X (cons Val Key)) )
                           (set 2 L (cdr X))  # Unlink cell
                           (ifn (sym? Tail)
                              (set 2 X Tail)
                              (set 2 X (& Tail -9))
                              (setq X (sym X)) )
                           (set (tail Sym) X) )
                        (ret) )
                     (when (== Key (cdr Y))
                        (if (nil? Val)
                           (set 2 L (cdr X))  # Remove cell
                           (if (t? Val)
                              (set X Key)  # Change to flag
                              (set Y Val) )  # Set new value
                           (set 2 L (cdr X))  # Unlink cell
                           (ifn (sym? Tail)
                              (set 2 X Tail)
                              (set 2 X (& Tail -9))
                              (setq X (sym X)) )
                           (set (tail Sym) X) )
                        (ret) ) ) )
                  (setq L X) ) ) )
      (unless (nil? Val)  # Non-NIL value
         (setq Val
            (if (t? Val) Key (cons Val Key)) )
         (set (tail Sym)
            (if (sym? Tail)
               (sym (cons Val (& Tail -9)))
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
            (while (dec 'Cnt)
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
                  (when (== Key X)
                     (ret $T) )
                  (when (== Key (cdr X))
                     (ret (car X)) ) )
               (while (pair (setq X (cdr L)))
                  (let Y (car X)
                     (if (atom Y)
                        (when (== Key Y)
                           (set 2 L (cdr X))  # Unlink cell
                           (ifn (sym? Tail)
                              (set 2 X Tail)
                              (set 2 X (& Tail -9))
                              (setq X (sym X)) )
                           (set (tail Sym) X)
                           (ret $T) )
                        (when (== Key (cdr Y))
                           (set 2 L (cdr X))  # Unlink cell
                           (ifn (sym? Tail)
                              (set 2 X Tail)
                              (set 2 X (& Tail -9))
                              (setq X (sym X)) )
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
               (? (atom (shift X)) $Nil) ) )
         ((== ZERO Key) (nth Key X))
         (NIL $Nil) )
      (when (sym? (val (tail X)))
         (dbFetch Exe X) )
      (tailcall (get X Key)) ) )

(de prop (Sym Key)
   (let Tail (val (tail Sym))
      (unless (num? Tail)
         (let (L (any (& Tail -9))  X (car L))
            (if (atom X)
               (when (== Key X)
                  (ret Key) )
               (when (== Key (cdr X))
                  (ret X) ) )
            (while (pair (setq X (cdr L)))
               (let Y (car X)
                  (if (atom Y)
                     (when (== Key Y)
                        (set 2 L (cdr X))  # Unlink cell
                        (ifn (sym? Tail)
                           (set 2 X Tail)
                           (set 2 X (& Tail -9))
                           (setq X (sym X)) )
                        (set (tail Sym) X)
                        (ret Key) )
                     (when (== Key (cdr Y))
                        (set 2 L (cdr X))  # Unlink cell
                        (ifn (sym? Tail)
                           (set 2 X Tail)
                           (set 2 X (& Tail -9))
                           (setq X (sym X)) )
                        (set (tail Sym) X)
                        (ret Y) ) ) )
               (setq L X) ) ) )
      (let R (cons $Nil Key)
         (set (tail Sym)
            (if (sym? Tail)
               (sym (cons R (& Tail -9)))
               (cons R Tail) ) )
         R ) ) )

# (put 'sym1|lst ['sym2|cnt ..] 'any) -> any
(de _put (Exe)
   (let
      (X (cdr Exe)
         Y (save (eval (++ X)))
         Key T )
      (loop
         (setq Key (eval (++ X)))
         (? (atom (cdr X)))
         (setq Y (safe (getn Exe Y Key))) )
      (when (num? Y)  # Need symbol or pair
         (argErr Exe Y) )
      (link (push Key NIL))
      (let Val (eval (car X))
         (if (pair Y)
            (putn Exe Y Key Val)
            (when (sym? (val (tail Y)))
               (if (nil? Key)
                  (dbFetch Exe Y)  # Volatile property
                  (dbTouch Exe Y) ) )
            (if (== ZERO Key)
               (set (chkVar Exe Y) Val)
               (put Y Key Val) ) )
         Val ) ) )

# (get 'sym1|lst ['sym2|cnt ..]) -> any
(de _get (Exe)
   (let (X (cdr Exe)  Y (eval (++ X)))
      (when (pair X)
         (save Y
            (loop
               (setq Y (getn Exe Y (eval (++ X))))
               (? (atom X))
               (safe Y) ) ) )
      Y ) )

# (prop 'sym1|lst ['sym2|cnt ..] 'sym) -> var
(de _prop (Exe)
   (let
      (X (cdr Exe)
         Y (save (eval (++ X)))
         Key T )
      (loop
         (setq Key (eval (++ X)))
         (? (atom X))
         (setq Y (safe (getn Exe Y Key))) )
      (needSymb Exe Y)
      (link (push Key NIL))
      (when (sym? (val (tail Y)))
         (if (nil? Key)
            (dbFetch Exe Y)  # Volatile property
            (dbTouch Exe Y) ) )
      (prop Y Key) ) )

# (; 'sym1|lst [sym2|cnt ..]) -> any
(de _semicol (Exe)
   (let (X (cdr Exe)  Y (eval (++ X)))
      (when (pair X)
         (save Y
            (loop
               (setq Y (getn Exe Y (++ X)))
               (? (atom X))
               (safe Y) ) ) )
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
               (if (nil? Key)
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
      (needSymb Exe Y)
      (when (sym? (val (tail Y)))
         (if (nil? Key)
            (dbFetch Exe Y)  # Volatile property
            (dbTouch Exe Y) ) )
      (prop Y Key) ) )

# (putl 'sym1|lst1 ['sym2|cnt ..] 'lst) -> lst
(de _putl (Exe)
   (let
      (X (cdr Exe)
         Y (save (eval (++ X)))
         Z T )
      (loop
         (setq Z (eval (++ X)))
         (? (atom X))
         (setq Y (safe (getn Exe Y Z))) )
      (let
         (R (save Z)
            Tail (val (tail (needSymb Exe Y))) )
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
                     (when (t? (car P))
                        (setq P (cdr P)) )
                     (setq X (cons P X)) ) ) ) )
         (set (tail Y)
            (if (sym? Tail) (sym X) X) )
         R ) ) )

# (getl 'sym1|lst1 ['sym2|cnt ..]) -> lst
(de _getl (Exe)
   (let (X (cdr Exe)  Y (save (eval (car X))))
      (while (pair (shift X))
         (setq Y
            (safe (getn Exe Y (eval (car X)))) ) )
      (when (sym? (setq X (val (tail (needSymb Exe Y)))))
         (dbFetch Exe Y)
         (setq X (& (val (tail Y)) -9)) )
      (if (num? X)
         $Nil
         (let R (setq Y (cons (car X) $Nil))
            (link (push R NIL))
            (while (pair (shift X))
               (setq Y
                  (set 2 Y (cons (car X) $Nil)) ) )
            R ) ) ) )

(local) wipe

(de void wipe (Exe X)
   (let
      (Tail (val (tail (needSymb Exe X)))
         Nm (name (& Tail -9)) )
      (ifn (sym? Tail)  # External symbol
         (set
            X $Nil  # Clear value
            (tail X) Nm )  # and properties
         (setq Nm (add Nm Nm))  # Get carry
         (unless @@  # Not dirty
            (setq Nm (add Nm Nm))
            (when @@  # and loaded
               (set
                  X $Nil
                  (tail X) (sym (shr Nm 2)) ) ) ) ) ) )  # Set "not loaded"

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
   (loop
      (? (atom X) $Nil)
      (let Y (car X)
         (when (symb? Y)
            (? (not (nil? (get Y Key))) @)
            (stkChk 0)
            (? (not (nil? (meta (car Y) Key))) @) ) )
      (shift X) ) )

# (meta 'obj|typ 'sym ['sym2|cnt ..]) -> any
(de _meta (Exe)
   (let (X (cdr Exe)  Y (save (eval (++ X))))
      (when (num? Y)  # Need symbol or pair
         (argErr Exe Y) )
      (when (sym? Y)
         (when (sym? (val (tail Y)))
            (dbFetch Exe Y) )
         (setq Y (val Y)) )
      (setq Y (meta Y (eval (car X))))
      (while (pair (shift X))
         (safe Y)
         (setq Y (getn Exe Y (eval (car X)))) )
      Y ) )

# (low? 'any) -> sym | NIL
(de _lowQ (Exe)
   (let X (eval (cadr Exe))
      (if (and (symb? X) (isLowc (firstChar X)))
         X
         $Nil ) ) )

# (upp? 'any) -> sym | NIL
(de _uppQ (Exe)
   (let X (eval (cadr Exe))
      (if (and (symb? X) (isUppc (firstChar X)))
         X
         $Nil ) ) )

# (lowc 'any) -> any
(de _lowc (Exe)
   (let X (eval (cadr Exe))
      (if (or (not (symb? X)) (nil? X))
         X
         (let
            (P (push 0 (xName Exe X) NIL)  # [cnt name link]
               Q (link (ofs P 1) T)
               R (push 4 NIL ZERO NIL)  # [cnt last name link]
               C T )
            (link (ofs R 2))
            (while (setq C (symChar P))
               (charSym (toLowerCase C) R) )
            (consStr (val 3 R)) ) ) ) )

# (uppc 'any) -> any
(de _uppc (Exe)
   (let X (eval (cadr Exe))
      (if (or (not (symb? X)) (nil? X))
         X
         (let
            (P (push 0 (xName Exe X) NIL)  # [cnt name link]
               Q (link (ofs P 1) T)
               R (push 4 NIL ZERO NIL)  # [cnt last name link]
               C T )
            (link (ofs R 2))
            (while (setq C (symChar P))
               (ifn (== C (char "ß"))
                  (charSym (toUpperCase C) R)
                  (charSym (char "S") R)
                  (charSym (char "S") R) ) )
            (consStr (val 3 R)) ) ) ) )

# (fold 'any ['cnt]) -> sym
(de _fold (Exe)
   (let (X (cdr Exe)  Y (eval (++ X)))
      (if (or (not (symb? Y)) (nil? Y))
         Y
         (let
            (N (if (atom X) 0 (evCnt Exe X))
               P (push 0 (xName Exe Y) NIL)  # [cnt name link]
               Q (link (ofs P 1) T)
               R (push 4 NIL ZERO NIL)  # [cnt last name link]
               C T )
            (link (ofs R 2))
            (while (setq C (symChar P))
               (when (isLetterOrDigit C)
                  (charSym (toLowerCase C) R)
                  (? (=0 (dec 'N))) ) )
            (consStr (val 3 R)) ) ) ) )
