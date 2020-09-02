# 02sep20 Software Lab. Alexander Burger

(symbols '(llvm))

(begin "ht" T
   "vers.l" "defs.l" "glob.l" "dec.l" )

(local) (Prin Fmt Pack Read In Out)

# External declarations
(local) (prin symByte prExt)

(de T void prin (any))
(de T i8 symByte (i64*))
(de T void prExt (any))

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

# (ht:Fmt 'any ..) -> sym
(de Fmt (Exe)
   #!
   Exe )

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
