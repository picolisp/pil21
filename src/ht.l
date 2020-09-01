# 01sep20 Software Lab. Alexander Burger

(symbols '(llvm))

(begin "ht" T
   "vers.l" "defs.l" "glob.l" "dec.l" )

(local) (Prin Fmt Pack Read In Out)

# External declarations
(local) (prin prExt)

(de T void prin (any))
(de T void prExt (any))

# (ht:Prin 'sym ..) -> sym
(de Prin (Exe)
   #!
   Exe )

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
