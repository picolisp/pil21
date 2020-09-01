# 01sep20 Software Lab. Alexander Burger

(symbols '(llvm))

(begin "ext" T
   "vers.l" "defs.l" "glob.l" "dec.l" )

(local) (SNXBASE SNXSIZE Snx FD)

# External declarations
(local) (xCnt evCnt evSym xName symChar charSym initInFile initOutFile)

(de T i64 xCnt (any any))
(de T i64 evCnt (any any))
(de T evSym (any))
(de T xName (any any))
(de T i32 symChar (i64*))
(de T void charSym (i32 i64*))
(de T i8* initInFile (i32 i8*))
(de T i8* initOutFile (i32))

# Soundex Algorithm
(array $SnxTab i8
   (char "0") (char "1") (char "2") (char "3") (char "4") (char "5") (char "6") (char "7")  # 48
   (char "8") (char "9")        0          0          0          0          0          0
          0          0   (char "F") (char "S") (char "T")        0   (char "F") (char "S")  # 64
          0          0   (char "S") (char "S") (char "L") (char "N") (char "N")        0
   (char "F") (char "S") (char "R") (char "S") (char "T")        0   (char "F") (char "F")
   (char "S")        0   (char "S")        0          0          0          0          0
          0          0   (char "F") (char "S") (char "T")        0   (char "F") (char "S")  # 96
          0          0   (char "S") (char "S") (char "L") (char "N") (char "N")        0
   (char "F") (char "S") (char "R") (char "S") (char "T")        0   (char "F") (char "F")
   (char "S")        0   (char "S")        0          0          0          0          0
          0          0          0          0          0          0          0          0  # 128
          0          0          0          0          0          0          0          0
          0          0          0          0          0          0          0          0
          0          0          0          0          0          0          0          0
          0          0          0          0          0          0          0          0  # 160
          0          0          0          0          0          0          0          0
          0          0          0          0          0          0          0          0
          0          0          0          0          0          0          0          0
          0          0          0          0          0          0          0   (char "S")  # 192
          0          0          0          0          0          0          0          0
   (char "T") (char "N")   0    0          0          0          0   (char "S")
          0          0          0          0          0          0          0   (char "S")
          0          0          0          0          0          0          0   (char "S")  # 224
          0          0          0          0          0          0          0          0
          0   (char "N") )

(setq
   SNXBASE 48
   SNXSIZE (+ (* 24 8) 2) )

# (ext:Snx 'any ['cnt]) -> sym
(de Snx (Exe)
   (let X (cdr Exe)
      (if (nil? (evSym X))
         @
         (let
            (P (push 0 (xName Exe @) NIL)  # [cnt name link]
               C (symChar P) )
            (while (> SNXBASE C)
               (unless (setq C (symChar P))
                  (ret $Nil) ) )
            (let
               (Q (link (ofs P 1) T)
                  R (push 4 NIL ZERO NIL)  # [cnt last name link]
                  N (if (pair (shift X)) (evCnt Exe X) 24) )
               (link (ofs R 2))
               (when
                  (or
                     (and (>= C (char "a")) (>= (char "z") C))
                     (== C 128)
                     (and (>= C 224) (>= 255 C)) )
                  (setq C (& C -33)) )  # Convert to lower case
               (charSym C R)
               (let Last C
                  (loop
                     (? (=0 (setq C (symChar P))))
                     (when (> C 32)  # Non-white
                        (cond
                           ((or
                                 (lt0 (dec 'C SNXBASE))  # Too small
                                 (>= C SNXSIZE)  # Too big
                                 (=0 (setq C (i32 (val (ofs $SnxTab C))))) )  # No entry
                              (setq Last 0) )
                           ((<> C Last)
                              (? (=0 (dec 'N)))
                              (charSym (setq Last C) R) ) ) ) )
                  (consStr (val 3 R)) ) ) ) ) ) )

# File Descriptor
# (ext:FD 'cnt) -> fd
(de FD (Exe)
   (prog1
      (eval (cadr Exe))
      (when (ge0 (i32 (xCnt Exe @)))
         (initInFile @ null)
         (initOutFile @) ) ) )

(end)
