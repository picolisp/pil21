# 05sep20 Software Lab. Alexander Burger

(symbols '(llvm))

(begin "ht" T
   "vers.l" "defs.l" "glob.l" "dec.l" )

(local) (Prin Fmt Pack Read In Out)

# External declarations
(local) (prin symByte prExt begString tglString endString isLstIntern outName
mkChar evCnt getChar)

(de T void prin (any))
(de T i8 symByte (i64*))
(de T void prExt (any))
(de T void begString (i64*))
(de T void tglString (i64*))
(de T endString ())
(de T isLstIntern (any any))
(de T void outName (any))
(de T mkChar (i32))
(de T i64 evCnt (any any))
(de T i32 getChar (i32))

# (ht:Prin 'sym ..) -> sym
(de Prin (Exe)
   (let X (cdr Exe)
      (loop
         (let Y (eval (car X))
            (if
               (or
                  (num? Y)
                  (pair Y)
                  (sym? (val (tail Y))) )
               (prin Y)
               (let P (push 0 (name (val (tail Y))))  # [cnt name]
                  (while (symByte P)
                     (case @
                        ((char "<") (outString ($ "&lt;")))
                        ((char ">") (outString ($ "&gt;")))
                        ((char "&") (outString ($ "&amp;")))
                        ((char "\"") (outString ($ "&quot;")))
                        ((hex "FF")
                           (call $Put (hex "F7"))
                           (call $Put (hex "BF"))
                           (call $Put (hex "BF"))
                           (call $Put (hex "BF")) )
                        (T
                           (let B @
                              (call $Put B)
                              (when (& B (hex "80"))  # Multi-byte
                                 (call $Put (symByte P))  # Second byte
                                 (when (& B (hex "20"))
                                    (call $Put (symByte P))  # Third byte
                                    (when (& B (hex "10"))
                                       (call $Put (symByte P)) ) ) ) ) ) ) ) ) )  # Fourth byte
            (? (atom (shift X)) Y) ) ) ) )

(local) (putHex htEncode htFmt)

(de void putHex ((i8 . B))
   (call $Put (char "%"))  # Prefix with "%"
   (call $Put  # Upper nibble
      (+
         (if (> (& (shr B 4) 15) 9)
            (+ @ 7)
            @ )
         (char "0") ) )
   (call $Put  # Lower nibble
      (+
         (if (> (& B 15) 9)
            (+ @ 7)
            @ )
         (char "0") ) ) )

(de void htEncode ((i8 . B) (i64* . P))
   (while B
      (if (strchr ($ " \"#%&:;<=>?\\_") (i32 B))
         (putHex B)
         (call $Put B)
         (when (& B (hex "80"))  # Multi-byte
            (call $Put (symByte P))  # Second byte
            (when (& B (hex "20"))
               (call $Put (symByte P))  # Third byte
               (when (& B (hex "10"))
                  (call $Put (symByte P)) ) ) ) )  # Fourth byte
      (setq B (symByte P)) ) )

(de void htFmt (X)
   (cond
      ((nil? X))
      ((num? X)
         (call $Put (char "+"))  # Prefix with "+"
         (prin X) )
      ((pair X)
         (loop
            (call $Put (char "_"))  # Prefix with "_"
            (htFmt (++ X))
            (? (atom X)) ) )
      ((sym? (val (tail X)))  # External symbol
         (call $Put (char "-"))  # Prefix with "-"
         (prExt (name (& @ -9))) )
      ((== (name @) ZERO))
      (T
         (let (Nm @  P (push 0 Nm)  B (symByte P))  # [cnt name]
            (cond
               ((== X (isLstIntern Nm (val $Intern)))  # Internal symbol
                  (call $Put (char "$"))  # Prefix with "$"
                  (htEncode B P) )
               ((or  # Special
                     (== B (char "$"))
                     (== B (char "+"))
                     (== B (char "-")) )
                  (putHex B)
                  (htEncode (symByte P) P) )
               (T (htEncode B P)) ) ) ) ) )

# (ht:Fmt 'any ..) -> sym
(de Fmt (Exe)
   (let (X (cdr Exe)  P (push 4 NIL ZERO NIL NIL))  # [cnt last name link fun]
      (begString P)
      (loop
         (htFmt
            (prog2
               (tglString P)
               (eval (car X))
               (tglString P) ) )
         (? (atom (shift X)))
         (call $Put (char "&")) )
      (endString) ) )

(local) (getHex head)

(de i8 getHex (Sym)
   (if (> (- (firstByte Sym) (char "0")) 9)
      (- (& @ (hex "DF")) 7)
      @ ) )

(de head ((i8* . S) Lst)
   (let B (val S)
      (loop
         (? (<> B (firstByte (++ Lst))) 0)
         (? (=0 (setq B (val (inc 'S)))) Lst) ) ) )

# (ht:Pack 'lst ['flg']) -> sym
(de Pack (Exe)
   (let
      (X (cdr Exe)
         Lst (save (eval (++ X)))
         Flg (nil? (eval (car X))) )
      (begString (push 4 NIL ZERO NIL NIL))  # [cnt last name link fun]
      (while (pair Lst)
         (let (C (++ Lst)  B (firstByte C))
            (cond
               ((== B (char "%"))  # Hex-escaped
                  (call $Put
                     (if Flg
                        B
                        (|
                           (shl (getHex (++ Lst)) 4)  # Upper nibble
                           (getHex (++ Lst)) ) ) ) )  # Lower nibble
               ((<> B (char "&")) (outName C))  # Normal character
               ((head ($ "lt;") Lst)
                  (call $Put (char "<"))
                  (setq Lst @) )
               ((head ($ "gt;") Lst)
                  (call $Put (char ">"))
                  (setq Lst @) )
               ((head ($ "amp;") Lst)
                  (call $Put (char "&"))
                  (setq Lst @) )
               ((head ($ "quot;") Lst)
                  (call $Put (char "\""))
                  (setq Lst @) )
               ((head ($ "nbsp;") Lst)
                  (call $Put (char " "))
                  (setq Lst @) )
               ((== (firstByte (car Lst)) (char "#"))
                  (let
                     (L (shift Lst)
                        D (firstByte (++ L))  # Digit
                        N (i32 (- D (char "0"))) )  # Character
                     (loop
                        (?
                           (or
                              (> (char "0") D)
                              (> D (char "9")) )
                           (call $Put (char "&"))
                           (call $Put (char "#")) )
                        (? (== (setq D (firstByte (++ L))) (char ";"))
                           (outName (mkChar N))
                           (setq Lst L) )
                        (setq N
                           (+
                              (* N 10)
                              (i32 (- D (char "0"))) ) ) ) ) )
               (T (call $Put (char "&"))) ) ) )
      (endString) ) )

# Read content length bytes
# (ht:Read 'cnt) -> lst
(de Read (Exe)
   (let (N (evCnt Exe (cdr Exe))  C (val $Chr))
      (if
         (or
            (le0 N)
            (and
               (=0 C)
               (lt0 (setq C (call $Get))) ) )
         $Nil
         (let C (getChar C)
            (when (>= C (hex "80"))  # Multi-byte
               (dec 'N)
               (when (>= C (hex "800"))
                  (dec 'N)
                  (when (>= C (hex "10000"))
                     (dec 'N) ) ) )
            (if (lt0 (dec 'N))
               $Nil
               (let (X (cons (mkChar C) $Nil)  R (save X))
                  (loop
                     (? (=0 N) (set $Chr 0) R)
                     (? (lt0 (setq C (call $Get))) $Nil)
                     (setq C (getChar C))
                     (when (>= C (hex "80"))  # Multi-byte
                        (dec 'N)
                        (when (>= C (hex "800"))
                           (dec 'N)
                           (when (>= C (hex "10000"))
                              (dec 'N) ) ) )
                     (? (lt0 (dec 'N)) $Nil)
                     (setq X
                        (set 2 X (cons (mkChar C) $Nil)) ) ) ) ) ) ) ) )

# Chunked Encoding
(local) (CHUNK $CnkCnt $CnkGet $CnkPut $CnkBuf chrHex chunkSize getChunked)

(setq CHUNK 4000)
(var $CnkCnt i32 0)  # Chunk size count
(var $CnkGet (i32) null)  # Saved $Get function
(var $CnkPut (void i8) null)  # Saved $Put function
(array $CnkBuf i8 . CHUNK)  # Chunk buffer

(de i32 chrHex ()
   (let C (val $Chr)
      (cond
         ((and
               (>= C (char "0"))
               (>= (char "9") C) )
            (- C 48) )  # Decimal digit
         ((and
               (>=
                  (setq C (& C (hex "DF")))
                  (char "A") )
               (>= (char "F") C) )
            (- C 55) )  # Hex letter
         (T -1) ) ) )

(de void chunkSize ()
   (unless (val $Chr)
      (call $Get) )
   (when (ge0 (set $CnkCnt (chrHex)))
      #!
      0 ) )

(de void getChunked ()
   #!
   )

# (ht:In 'flg . prg) -> any
(de In (Exe)
   #!
   Exe )

# (ht:Out 'flg . prg) -> any
(de Out (Exe)
   #!
   Exe )

(end)
