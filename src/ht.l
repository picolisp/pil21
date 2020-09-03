# 03sep20 Software Lab. Alexander Burger

(symbols '(llvm))

(begin "ht" T
   "vers.l" "defs.l" "glob.l" "dec.l" )

(local) (Prin Fmt Pack Read In Out)

# External declarations
(local) (prin symByte prExt begString tglString endString isLstIntern)

(de T void prin (any))
(de T i8 symByte (i64*))
(de T void prExt (any))
(de T void begString (i64*))
(de T void tglString (i64*))
(de T endString ())
(de T isLstIntern (any any))

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

(local) (putHex htFmt)

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
            (if (== X (isLstIntern Nm (val $Intern)))  # Internal symbol
               (call $Put (char "$"))  # Prefix with "$"
               (if
                  (or  # Special
                     (== B (char "$"))
                     (== B (char "+"))
                     (== B (char "-")) )
                  (putHex B)
                  (call $Put B) )
               (setq B (symByte P)) )
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
               (setq B (symByte P)) ) ) ) ) )

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

# (ht:Pack 'lst ['flg']) -> sym
(de Pack (Exe)
   #!
   Exe )

# Read content length bytes
# (ht:Read 'cnt) -> lst
(de Read (Exe)
   #!
   Exe )

# (ht:In 'flg . prg) -> any
(de In (Exe)
   #!
   Exe )

# (ht:Out 'flg . prg) -> any
(de Out (Exe)
   #!
   Exe )

(end)
