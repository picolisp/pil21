# 10sep20 Software Lab. Alexander Burger

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

# Base64 Encoding
(local) ($Chr64 $Stat64 $Next64)

(str $Chr64 "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/")
(var $Stat64 i32 0)  # State
(var $Next64 i32 0)  # Next value

# (ext:Base64) -> num|NIL
# (ext:Base64 'num1|NIL ['num2|NIL ['num3|NIL]]) -> flg
(de Base64 (Exe)
   (let X (cdr Exe)
      (cond
         ((atom X)  # No arguments
            (let C (val $Chr)
               (while (and (ge0 C) (>= (char " ") C))
                  (setq C (call $Get)) )
               (if (strchr $Chr64 C)
                  (let N (i32 (- @ $Chr64))  # Legal character
                     (setq C (call $Get))
                     (case (val $Stat64)  # Initial state
                        (0
                           (unless (strchr $Chr64 C)
                              (set $Stat64 0)
                              (ret $Nil) )
                           (set $Next64 (i32 (- @ $Chr64)))
                           (call $Get)
                           (set $Stat64 (inc (val $Stat64)))
                           (cnt
                              (i64
                                 (| (shl N 2) (shr (val $Next64) 4)) ) ) )
                        (1
                           (prog1
                              (cnt
                                 (i64
                                    (|
                                       (shl (& (val $Next64) 15) 4)
                                       (shr N 2) ) ) )
                              (set
                                 $Next64 N
                                 $Stat64 (inc (val $Stat64)) ) ) )
                        (T
                           (set $Stat64 0)
                           (cnt
                              (i64
                                 (| (shl (& (val $Next64) 3) 6) N) ) ) ) ) )
                  (when (== C (char "="))  # Filler
                     (call $Get)
                     (when (== (val $Stat64) 1)
                        (call $Get) ) )
                  (set $Stat64 0)
                  $Nil ) ) )
         ((nil? (eval (car X))) @)
         (T
            (let N (xCnt Exe @)
               (call $Put (val (ofs $Chr64 (shr N 2))))
               (when (nil? (eval (car (shift X))))
                  (call $Put
                     (val (ofs $Chr64 (shl (& N 3) 4))) )
                  (call $Put (char "="))
                  (call $Put (char "="))
                  (ret $Nil) )
               (let M (xCnt Exe @)
                  (call $Put
                     (val
                        (ofs $Chr64
                           (| (shl (& N 3) 4) (shr M 4)) ) ) )
                  (when (nil? (eval (cadr X)))
                     (call $Put
                        (val (ofs $Chr64 (shl (& M 15) 2))) )
                     (call $Put (char "="))
                     (ret $Nil) )
                  (setq N (xCnt Exe @))
                  (call $Put
                     (val
                        (ofs $Chr64
                           (| (shl (& M 15) 2) (shr N 6)) ) ) )
                  (call $Put (val (ofs $Chr64 (& N 63))))
                  $T ) ) ) ) ) )

(end)
