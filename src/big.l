# 12dec21 Software Lab. Alexander Burger

(symbols '(llvm))

(local) (pos neg divErr)

(inline pos (N)
   (any (& N -9)) )

(inline neg (N)
   (if (== N ZERO)
      N
      (any (x| N 8)) ) )

(de NIL divErr (Exe)
   (err Exe 0 ($ "Div/0") null) )

### Bignum byte access ###
(local) (symByte symChar byteNum byteSym charSym)

(de i8 symByte ((i64* . P))  # [cnt name]
   (let C (val P)  # Get cnt
      (unless C  # New round
         (let Nm (val 2 P)
            (cond
               ((== Nm ZERO) (ret (i8 0)))  # Done
               ((cnt? Nm)  # Short
                  (setq C (int Nm))
                  (set 2 P ZERO) )
               (T  # Big: Next digit
                  (setq C (set P (val (dig Nm))))
                  (set 2 P (val (big Nm))) ) ) ) )
      (set P (shr C 8))
      (i8 C) ) )

(de i32 symChar ((i64* . P))  # [cnt name]
   (let C (i32 (symByte P))
      (cond
         ((>= 127 C) C)  # Single byte
         ((== C (hex "FF")) (i32 TOP))  # Infinite
         (T
            (|
               (shl
                  (ifn (& C (hex "20"))
                     (& C (hex "1F"))
                     (|
                        (shl
                           (ifn (& C (hex "10"))
                              (& C (hex "0F"))
                              (|
                                 (shl (& C (hex "7")) 6)
                                 (& (i32 (symByte P)) (hex "3F")) ) )
                           6 )
                        (& (i32 (symByte P)) (hex "3F")) ) )
                  6 )
               (& (i32 (symByte P)) (hex "3F")) ) ) ) ) )

(de void byteNum ((i8 . B) (i64* . P))  # [cnt last name link]
   (let (Cnt (val P)  Nm (val 3 P))
      (if (cnt? Nm)
         # xxxxx.xxxxxxx.xxxxxxx.xxxxxxx.xxxxxxx.xxxxxxx.xxxxxxx.xxxxxxS010
         #    59      51      43      35      27      19      11       3
         (cond
            ((== Cnt 67)  # Short full
               (set 3 P
                  (set 2 P
                     (consNum (shr Nm 3) (cnt (i64 B))) ) )
               (set P 12) )  # Next digit in bignum
            ((and (== Cnt 59) (>= B 32))  # Fit into 5 bits
               (set 3 P
                  (set 2 P
                     (boxNum
                        (| (shr Nm 3) (shl (i64 B) 56)) ) ) )
               (set P 4) )  # Start next digit in bignum
            (T
               (set
                  3 P (| Nm (shl (i64 B) Cnt))
                  P (+ Cnt 8) ) ) )
         (let (Q (val 2 P)  N (val (big Q)))
            (cond
               ((== Cnt 68)  # Last short full
                  (set 2 P
                     (set (big Q)
                        (consNum (int N) (cnt (i64 B))) ) )
                  (set P 12) )  # Next digit in bignum
               ((and (== Cnt 60) (>= B 16))  # Fit into 4 bits
                  (set 2 P
                     (set (big Q)
                        (boxNum
                           (| (int N) (shl (i64 B) 56)) ) ) )
                  (set P 4) )  # Start next digit in bignum
               (T
                  (set
                     (big Q) (| N (shl (i64 B) Cnt))
                     P (+ Cnt 8) ) ) ) ) ) ) )

(de void byteSym ((i8 . B) (i64* . P))  # [cnt last name link]
   (let (Cnt (val P)  Nm (val 3 P))
      (if (cnt? Nm)
         # 0000.xxxxxxx.xxxxxxx.xxxxxxx.xxxxxxx.xxxxxxx.xxxxxxx.xxxxxxx0010
         #   60      52      44      36      28      20      12       4
         (if (> 60 Cnt)  # Digit not full
            (set
               3 P (| Nm (shl (i64 B) Cnt))
               P (+ Cnt 8) )
            (set 3 P
               (set 2 P
                  (boxNum  # Make big
                     (| (int Nm) (shl (i64 B) 56)) ) ) )
            (set P 4) )  # Start new digit
         (let (Q (val 2 P)  N (val (big Q)))
            (if (> 60 Cnt)  # Digit not full
               (set
                  (big Q) (| N (shl (i64 B) Cnt))
                  P (+ Cnt 8) )
               (set 2 P
                  (set (big Q)
                     (boxNum  # Make big
                        (| (int N) (shl (i64 B) 56)) ) ) )
               (set P 4) ) ) ) ) )  # Start new digit

(de void charSym ((i32 . C) (i64* . P))  # [cnt last name link]
   (cond
      ((>= 127 C) (byteSym (i8 C) P))  # Single byte
      ((== TOP C) (byteSym (hex "FF") P))  # Infinite
      (T
         (cond
            ((> (hex "800") C)  # Double-byte
               (byteSym (i8 (| (hex "C0") (& (shr C 6) (hex "1F")))) P) )  # 10xxxxx 10xxxxxx
            ((> (hex "10000") C)  # Three bytes
               (byteSym (i8 (| (hex "E0") (& (shr C 12) (hex "0F")))) P)  # 1110xxxx 10xxxxxx 10xxxxxx
               (byteSym (i8 (| (hex "80") (& (shr C 6) (hex "3F")))) P) )
            (T
               (byteSym (i8 (| (hex "F0") (& (shr C 18) (hex "07")))) P)  # 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
               (byteSym (i8 (| (hex "80") (& (shr C 12) (hex "3F")))) P)
               (byteSym (i8 (| (hex "80") (& (shr C 6) (hex "3F")))) P) ) )
         (byteSym (i8 (| (hex "80") (& C (hex "3F")))) P) ) ) )

### Destructive primitives ###
(local) (zapZero twiceBig twice half tenfold)

# Remove leading zeroes
(de zapZero (N)
   (let (P (push N)  X P  Y P  Z T)
      (until (cnt? (setq Z (val (big N))))  # Last cell
         (when (val (dig N))  # Null digit?
            (setq X Y) )  # New null-tail
         (setq
            Y (big N)  # New short-tail
            N (val Y) ) )  # Next cell
      (when (== Z ZERO)
         (cond
            ((setq N (val (dig N)))  # Final digit
               (unless (& N (hex "F000000000000000"))
                  (set Y (cnt N)) ) )  # Store in short-tail
            ((&
                  (setq N (val (dig (val X))))  # Digit in null-tail
                  (hex "F000000000000000") )
               (set (big (val X)) ZERO) )  # Trim null-tail
            (T (set X (cnt N))) ) )  # Store in null-tail
      (val P) ) )

# Multiply (unsigned) number by 2
(de twiceBig (N)
   (let (X N  A (val (dig X))  Y (val (big X)))
      (set (dig X) (shl A 1))
      (while (big? Y)
         (let B (val (dig Y))
            (set (dig (setq X Y))
               (| (shl B 1) (shl 0 A 1)) )
            (setq A B  Y (val (big Y))) ) )
      (set (big X)
         (box64
            (| (shl (int Y) 1) (shl 0 A 1)) ) ) )
   N )

(de twice (N)
   (if (cnt? N)
      (let X (add N N)  # Shift left
         (if @@  # Overflow
            (boxNum (shr N 3))  # Make big
            (x| X 6) ) )  # Fix tag bit
      (twiceBig N) ) )

# Divide (unsigned) number by 2
(de half (N)
   (if (cnt? N)
      (| (& (shr N 1) -10) 2)  # Clear lowest bit and tag
      (let (X N  A (shr (val (dig X)) 1)  Y (val (big X)))
         (if (big? Y)
            (let Z (val (big Y))
               (loop
                  (let B (val (dig Y))
                     (set (dig X) (| (shr B 0 1) A))
                     (setq A (shr B 1)) )
                  (? (cnt? Z))
                  (setq X Y  Y Z  Z (val (big Z))) )
               (setq
                  Z (int Z)
                  A (| (shr Z 0 1) A) )
               (ifn
                  (or
                     (setq Z (shr Z 1))
                     (& A (hex "F000000000000000")) )
                  (set (big X) (cnt A))
                  (set (dig Y) A)
                  (set (big Y) (cnt Z)) ) )
            (setq
               Y (int Y)
               A (| (shr Y 0 1) A) )
            (unless
               (or
                  (setq Y (shr Y 1))
                  (& A (hex "F000000000000000")) )
               (ret (cnt A)) )
            (set (dig X) A)
            (set (big X) (cnt Y)) )
         N ) ) )

# Multiply (unsigned) number by 10
(de tenfold (N)
   (if (cnt? N)
      (box64 (* 10 (int N)))
      (let (X N  Lo (mul 10 (val (dig X)))  Hi @@@)
         (loop
            (set (dig X) Lo)
            (? (cnt? (val (big X)))
               (set (big X)
                  (box64 (+ Hi (* 10 (int @)))) ) )
            (setq X @)
            (setq
               Lo (add (mul 10 (val (dig X))) Hi)
               Hi (+ @@@ @@) ) )
         N ) ) )

### Non-destructive unsigned primitives ###
(local) (shlu shru andu oru xoru addu sub1 subu mulAddHiLo mulu div1 divu remu)

# Multiply (unsigned) number by 2
(de shlu (N)
   (if (cnt? N)
      (let X (add N N)  # Shift left
         (if @@  # Overflow
            (boxNum (shr N 3))  # Make big
            (x| X 6) ) )  # Fix tag bit
      (let
         (A (val (dig N))
            X (boxNum (shl A 1))
            Y (val (big N))
            R (save X) )
         (while (big? Y)
            (let B (val (dig Y))
               (setq X
                  (set (big X)
                     (boxNum (| (shl B 1) (shl 0 A 1))) ) )
               (setq A B  Y (val (big Y))) ) )
         (set (big X)
            (box64
               (| (shl (int Y) 1) (shl 0 A 1)) ) )
         R ) ) )

# Divide (unsigned) number by 2
(de shru (N)
   (if (cnt? N)
      (| (& (shr N 1) -10) 2)  # Clear lowest bit and tag
      (let A (shr (val (dig N)) 1)
         (if (big? (setq N (val (big N))))
            (let
               (B (val (dig N))
                  P (boxNum (| (shr B 0 1) A))
                  R (save P) )
               (loop
                  (setq A (shr B 1))
                  (? (cnt? (setq N (val (big N)))))
                  (setq
                     B (val (dig N))
                     P
                     (set (big P)
                        (boxNum (| (shr B 0 1) A)) ) ) )
               (setq
                  N (int N)
                  A (| (shr N 0 1) A) )
               (set (big P)
                  (ifn
                     (or
                        (setq N (shr N 1))
                        (& A (hex "F000000000000000")) )
                     (cnt A)
                     (prog1
                        (boxNum A)
                        (set (big @) (cnt N)) ) ) )
               R )
            (setq
               N (int N)
               A (| (shr N 0 1) A) )
            (ifn
               (or
                  (setq N (shr N 1))
                  (& A (hex "F000000000000000")) )
               (cnt A)
               (prog1
                  (boxNum A)
                  (set (big @) (cnt N)) ) ) ) ) ) )

# Bitwise AND of two (unsigned) numbers
(de andu (A B)
   (cond
      ((cnt? A)
         (& A
            (if (cnt? B) B (cnt (val (dig B)))) ) )
      ((cnt? B)  # A is big
         (& B (cnt (val (dig A)))) )
      (T  # Both are big
         (let
            (P
               (boxNum
                  (& (val (dig A)) (val (dig B))) )
               R (save P) )
            (loop
               (setq A (val (big A))  B (val (big B)))
               (? (cnt? A)
                  (set (big P)
                     (& A
                        (if (cnt? B) B (cnt (val (dig B)))) ) ) )
               (? (cnt? B)
                  (set (big P)
                     (& B (cnt (val (dig A)))) ) )
               (setq P
                  (set (big P)
                     (boxNum
                        (& (val (dig A)) (val (dig B))) ) ) ) )
            (zapZero R) ) ) ) )

# Bitwise OR of two (unsigned) numbers
(de oru (A B)
   (cond
      ((cnt? A)
         (if (cnt? B)
            (| A B)
            (consNum
               (| (int A) (val (dig B)))
               (val (big B)) ) ) )
      ((cnt? B)  # A is big
         (consNum
            (| (int B) (val (dig A)))
            (val (big A)) ) )
      (T  # Both are big
         (let
            (P
               (boxNum
                  (| (val (dig A)) (val (dig B))) )
               R (save P) )
            (loop
               (setq A (val (big A))  B (val (big B)))
               (? (cnt? A)
                  (set (big P)
                     (if (cnt? B)
                        (| A B)
                        (consNum
                           (| (int A) (val (dig B)))
                           (val (big B)) ) ) ) )
               (? (cnt? B)
                  (set (big P)
                     (consNum
                        (| (int B) (val (dig A)))
                        (val (big A)) ) ) )
               (setq P
                  (set (big P)
                     (boxNum
                        (| (val (dig A)) (val (dig B))) ) ) ) )
            R ) ) ) )

# Bitwise XOR of two (unsigned) numbers
(de xoru (A B)
   (cond
      ((cnt? A)
         (if (cnt? B)
            (| (x| A B) 2)
            (zapZero
               (consNum
                  (x| (int A) (val (dig B)))
                  (val (big B)) ) ) ) )
      ((cnt? B)  # A is big
         (zapZero
            (consNum
               (x| (int B) (val (dig A)))
               (val (big A)) ) ) )
      (T  # Both are big
         (let
            (P
               (boxNum
                  (x| (val (dig A)) (val (dig B))) )
               R (save P) )
            (loop
               (setq A (val (big A))  B (val (big B)))
               (? (cnt? A)
                  (set (big P)
                     (if (cnt? B)
                        (| (x| A B) 2)
                        (consNum
                           (x| (int A) (val (dig B)))
                           (val (big B)) ) ) ) )
               (? (cnt? B)
                  (set (big P)
                     (consNum
                        (x| (int B) (val (dig A)))
                        (val (big A)) ) ) )
               (setq P
                  (set (big P)
                     (boxNum
                        (x| (val (dig A)) (val (dig B))) ) ) ) )
            (zapZero R) ) ) ) )

# Add two (unsigned) numbers
(de addu (A B)
   (cond
      ((cnt? A)
         (if (cnt? B)
            (box64 (+ (int A) (int B)))
            (xchg 'A 'B)
            (goto 1) ) )
      ((cnt? B)  # A is big
         (: 1
            (let N (val (big A))
               (setq B (add (int B) (val (dig A))))
               (ifn @@
                  (consNum B N)  # No carry
                  (let R (save (setq B (consNum B N)))  # Else build new head
                     (loop
                        (? (cnt? N)
                           (setq N (add N (hex "10")))  # Add carry
                           (set (big B)
                              (ifn @@  # No further carry
                                 N  # Append it
                                 (boxNum (| (int N) (hex "1000000000000000"))) ) ) )  # Set top bit
                        (let D (val (dig N))  # Next digit
                           (setq
                              N (val (big N))
                              D (add D 1) )  # Add carry
                           (? (not @@)  # No carry
                              (set (big B) (consNum D N)) )
                           (setq B (set (big B) (consNum D N))) ) )
                     R ) ) ) ) )
      (T  # Both are big
         (let
            (N (add (val (dig A)) (val (dig B)))
               C @@
               P (boxNum N)
               R (save P) )
            (loop
               (setq A (val (big A))  B (val (big B)))
               (? (cnt? A)
                  (if (cnt? B)
                     (set (big P)
                        (box64 (add (int A) (int B) C)) )
                     (xchg 'A 'B)
                     (goto 2) ) )
               (? (cnt? B)
                  (: 2
                     (setq
                        N (add (int B) (val (dig A)) C)
                        C @@ )
                     (loop
                        (setq P
                           (set (big P)
                              (consNum N (setq A (val (big A)))) ) )
                        (? (not C))
                        (? (cnt? A)
                           (set (big P) (box64 (+ (int A) C))) )
                        (setq
                           N (add (val (dig A)) 1)
                           C @@ ) ) ) )
               (setq
                  N (add (val (dig A)) (val (dig B)) C)
                  C @@
                  P (set (big P) (boxNum N)) ) )
            R ) ) ) )

# Subtract short from big number
(de sub1 (B N)
   (setq
      N (sub (val (dig B)) (int N))
      B (val (big B)) )
   (nond
      (@@  # No borrow
         (if (== B ZERO)
            (box64 N)
            (consNum N B) ) )
      ((big? B)  # Single cell
         (setq B (sub B (hex "10")))  # Subtract borrow
         (if @@  # Again borrow
            (sign (cnt (- N)))  # Lowest digit
            (zapZero (consNum N B)) ) )
      (NIL
         (let (P (boxNum N B)  R (save P))
            (loop
               (setq
                  N (sub (val (dig B)) 1)  # Subtract borrow
                  B (val (big B)) )
               (? (not @@)
                  (set (big P) (consNum N B)) )
               (setq P (set (big P) (consNum N B)))
               (? (cnt? B)
                  (set (big P) (sub B (hex "10"))) ) )  # Subtract borrow
            (zapZero R) ) ) ) )

# Subtract two (unsigned) numbers
(de subu (A B)
   (cond
      ((cnt? A)
         (if (cnt? B)
            (let N (sub A (& B -3))  # Clear tag
               (if @@
                  (+ (x| N -16) (hex "18"))  # 2-complement
                  N ) )
            (neg (sub1 B A)) ) )
      ((cnt? B)  # A is big
         (sub1 A B) )
      (T  # Both are big
         (let
            (N (sub (val (dig A)) (val (dig B)))
               C @@
               P (boxNum N)
               R (save P) )
            (loop
               (setq A (val (big A))  B (val (big B)))
               (? (cnt? B)
                  (setq B (int B))
                  (until (cnt? A)
                     (setq
                        N (sub (val (dig A)) B C)
                        C @@
                        A (val (big A))
                        P (set (big P) (consNum N A)) )
                     (unless C
                        (ret (zapZero R)) )
                     (setq B 0) )
                  (setq A (int A)) )
               (? (cnt? A)
                  (setq A (int A))
                  (loop
                     (setq
                        N (sub A (val (dig B)) C)
                        C @@
                        P (set (big P) (boxNum N)) )
                     (setq A 0)
                     (? (cnt? (setq B (val (big B))))) )
                  (setq B (int B)) )
               (setq
                  N (sub (val (dig A)) (val (dig B)) C)
                  C @@
                  P (set (big P) (boxNum N)) ) )
            (set (big P) (cnt (sub A B C)))  # Subtract final shorts with borrow
            (ifn @@
               (zapZero R)
               # 2-complement
               (let Q R
                  (loop  # Invert
                     (set (dig Q) (x| (val (dig Q)) -1))
                     (? (cnt? (setq N (val (big Q)))))
                     (setq Q N) )
                  (set (big Q) (x| N -16)) )
               (let Q R
                  (loop  # Increment
                     (set (dig Q) (add (val (dig Q)) 1))
                     (unless @@
                        (goto 9) )
                     (? (cnt? (setq N (val (big Q)))))
                     (setq Q N) )
                  (set (big Q) (+ N (hex "10"))) )
               (: 9
                  (sign (zapZero R)) ) ) ) ) ) )

# Multiply two (unsigned) numbers
(inline (Lo Hi) mulAddHiLo (X Y P)
   (let H Hi
      (setq
         Lo (add (mul X Y) (val (dig P)))
         Hi (+ @@@ @@)
         Lo (add Lo H)
         Hi (+ Hi @@) ) ) )

(de mulu (A B)
   (cond
      ((== A ZERO) A)
      ((cnt? A)
         (setq A (int A))
         (if (cnt? B)
            (let N (mul A (int B))
               (if (or @@@ (& N (hex "F000000000000000")))  # Fit in short number
                  (consNum N (cnt @@@))
                  (cnt N) ) )
            (: 1
               (let
                  (Lo (mul A (val (dig B)))
                     Hi @@@
                     P (boxNum Lo)
                     R (save P) )
                  (while (big? (setq B (val (big B))))
                     (setq
                        Lo (add (mul A (val (dig B))) Hi)
                        Hi (+ @@@ @@)
                        P (set (big P) (boxNum Lo)) ) )
                  (setq
                     Lo (add (mul A (int B)) Hi)
                     Hi (+ @@@ @@) )
                  (set (big P)
                     (if (or Hi (& Lo (hex "F000000000000000")))  # Fit in short number
                        (consNum Lo (cnt Hi))
                        (cnt Lo) ) )
                  R ) ) ) )
      ((== B ZERO) B)
      ((cnt? B)  # A is big
         (setq B (int B))
         (xchg 'A 'B)
         (goto 1) )
      (T  # Both are big
         (let (P (boxNum 0)  R (save P))
            (loop
               (let
                  (X A
                     Q P
                     Lo
                     (add
                        (mul (val (dig X)) (val (dig B)))
                        (val (dig Q)) )
                     Hi (+ @@@ @@) )
                  (loop
                     (set (dig Q) Lo)
                     (setq Q
                        (if (cnt? (val (big Q)))
                           (set (big Q) (boxNum 0))
                           @ ) )
                     (? (cnt? (setq X (val (big X)))))
                     (mulAddHiLo (val (dig X)) (val (dig B)) Q) )
                  (mulAddHiLo (int X) (val (dig B)) Q)
                  (set (dig Q) Lo)
                  (when Hi
                     (if (cnt? (val (big Q)))
                        (set (big Q) (boxNum Hi))
                        (set (big @) Hi) ) ) )
               (setq P (val (big P)))
               (? (cnt? (setq B (val (big B))))) )
            (setq B (int B))
            (let
               (Lo
                  (add
                     (mul (val (dig A)) B)
                     (val (dig P)) )
                  Hi (+ @@@ @@) )
               (loop
                  (set (dig P) Lo)
                  (setq P
                     (if (cnt? (val (big P)))
                        (set (big P) (boxNum 0))
                        @ ) )
                  (? (cnt? (setq A (val (big A)))))
                  (mulAddHiLo (val (dig A)) B P) )
               (mulAddHiLo (int A) B P)
               (set (dig P) Lo)
               (when Hi
                  (if (cnt? (val (big P)))
                     (set (big P) (boxNum Hi))
                     (set (big @) Hi) ) ) )
            (zapZero R) ) ) ) )

# Divide big number (Knuth Vol.2, p.257)
(de div1 (A B (i1 . Rem))
   (let
      (R (save ZERO)  # Quotient
         P (boxNum (val (dig A)))
         U (link (push P NIL))  # Dividend 'u'
         V (link (push B NIL))  # Divisor 'v'
         V1 T
         V2 0  # Last cell
         M 0  # 'm'
         N 1  # 'n'
         D 0
         Q T )
      # Copy dividend
      (while (big? (setq A (val (big A))))
         (setq P
            (set (big P) (boxNum (val (dig A)))) )
         (inc 'M) )  # Calculate 'm'
      (unless (== A ZERO)
         (setq P (set (big P) (boxNum (int A))))
         (inc 'M) )
      # Copy divisor
      (if (cnt? B)
         (setq Q (set V (boxNum (int B))))
         (setq Q
            (set V (boxNum (val (dig B)))) )
         (while (big? (setq B (val (big B))))
            (setq
               V2 Q  # Keep last cell
               Q (set (big Q) (boxNum (val (dig B)))) )
            (dec 'M)  # Decrement 'm'
            (inc 'N) )  # Calculate 'n'
         (unless (== B ZERO)
            (setq
               V2 Q  # Keep last cell
               Q (set (big Q) (boxNum (int B))))
            (dec 'M)
            (inc 'N) )
         (when (lt0 M)
            (ret
               (if Rem
                  (zapZero (val U))
                  ZERO ) ) ) )
      (set (big P) (boxNum 0))
      (while (ge0 (val (dig Q)))  # Shift to max left position
         (twiceBig (val U))
         (twiceBig (val V))
         (inc 'D) )
      (setq V1 (val (dig Q)))
      (when V2
         (setq V2 (val (dig V2))) )
      (loop
         (let (X (val U)  U1 0  U2 0  U3 T)
            (let I M  # Index X -> 'u'
               (while (ge0 (dec 'I))
                  (setq X (val (big X))) ) )
            (let (I N  Y X)
               (loop
                  (setq
                     U3 U2
                     U2 U1
                     U1 (val (dig Y))
                     Y (val (big Y)) )
                  (? (lt0 (dec 'I))) ) )
            (let (Hi U1  Lo U2)  # 'r'
               (setq Q
                  (if (== U1 V1)  # 'u1' = 'v1'
                     -1  # 'q' = MAX
                     (div Hi Lo V1) ) )  # 'q' = 'r' / 'v1'
               (setq
                  Lo (sub Lo (mul Q V1))  # 'r' - 'q' * 'v1'
                  Hi (sub Hi @@@ @@) )
               (until Hi  # 'r' <= MAX  and
                  (let L (mul Q V2)  # 'q' * 'v2 '> [lo(r) u3]
                     (? (> Lo @@@))
                     (? (and (== Lo @@@) (>= U3 L))) )
                  (dec 'Q)
                  (setq   # Increment 'r' by 'v1'
                     Lo (add Lo V1)
                     Hi (+ Hi @@) ) )
               (let (Z X  Y (val V))
                  (set (dig Z)
                     (sub
                        (val (dig Z))
                        (mul Q (val (dig Y))) ) )
                  (setq Hi (+ @@@ @@))  # Borrow
                  (while (big? (setq Y (val (big Y))))  # More in 'v'
                     (setq Z (val (big Z)))
                     (set (dig Z) (sub (val (dig Z)) Hi))  # Subtract borrow
                     (setq Hi (- Hi Hi @@))  # New borrow
                     (set (dig Z)
                        (sub
                           (val (dig Z))
                           (mul Q (val (dig Y))) ) )
                     (setq Hi (- (sub Hi @@@ @@))) )
                  (when Hi  # Borrow
                     (setq Z (val (big Z)))
                     (set (dig Z) (sub (val (dig Z)) Hi))  # Subtract borrow
                     (when @@
                        (dec 'Q)
                        (when (or Rem M)
                           (setq Y (val V))
                           (set (dig X)  # 'x' += 'v'
                              (add (val (dig X)) (val (dig Y))) )
                           (let C @@
                              (loop
                                 (setq X (val (big X)))
                                 (? (cnt? (setq Y (val (big Y)))))
                                 (set (dig X)
                                    (add (val (dig X)) (val (dig Y)) C) )
                                 (setq C @@) )
                              (set (dig X) (+ (val (dig X)) C)) ) ) ) ) ) ) )
         (setq R (safe (consNum Q R)))
         (? (lt0 (dec 'M))) )
      (ifn Rem
         (zapZero R)
         (setq A (zapZero (val U)))
         (while D
            (setq A (half A))  # Shift right (destructive)
            (dec 'D) )
         A ) ) )

# Divide two (unsigned) numbers
(de divu (A B)
   (cond
      ((big? A) (div1 A B NO))
      ((big? B) ZERO)
      (T (cnt (/ (int A) (int B)))) ) )

# Remainder of two (unsigned) numbers
(de remu (A B)
   (cond
      ((big? A) (div1 A B YES))
      ((big? B) A)
      (T (cnt (% (int A) (int B)))) ) )

### Non-destructive signed primitives ###
(local) (incs decs adds subs)

# Increment a (signed) number
(de incs (A)
   (if (sign? A)
      (neg (subu (pos A) ONE))
      (addu A ONE) ) )

# Decrement a (signed) number
(de decs (A)
   (if (sign? A)
      (neg (addu (pos A) ONE))
      (subu A ONE) ) )

# Add two (signed) numbers
(de adds (A B)
   (ifn (sign? A)
      (ifn (sign? B)
         (addu A B)
         (subu A (pos B)) )
      (neg
         (ifn (sign? B)
            (subu (pos A) B)
            (addu (pos A) (pos B)) ) ) ) )

# Subtract to (signed) numbers
(de subs (A B)
   (ifn (sign? A)
      (ifn (sign? B)
         (subu A B)
         (addu A (pos B)) )
      (neg
         (ifn (sign? B)
            (addu (pos A) B)
            (subu (pos A) (pos B)) ) ) ) )

### Comparisons ###
(local) (cmpu cmpNum)

(de i64 cmpu (A B)
   (if (cnt? A)
      (cond
         ((or (big? B) (> B A)) -1)
         ((== B A) 0)
         (T +1) )
      # A is big
      (if (cnt? B)
         +1
         # Both are big
         (let (X 0  Y 0)
            (prog1
               (loop
                  (let (C (val (big A))  D (val (big B)))
                     (? (== C D)  # Tails equal
                        (loop
                           (setq
                              C (val (dig A))
                              D (val (dig B)) )
                           (? (> D C) -1)
                           (? (> C D) +1)
                           (? (=0 X) 0)
                           (let Z (val (big X))
                              (set (big X) A)  # Restore A
                              (setq A X  X Z) )
                           (let Z (val (big Y))
                              (set (big Y) B)  # Restore B
                              (setq B Y  Y Z) ) ) )
                     (? (cnt? C)  # End of A
                        (cond
                           ((or (big? D) (> D C)) -1)
                           ((== D C) 0)
                           (T +1) ) )
                     (? (cnt? D) +1)  # End of B
                     (set (big A) X)  # Reverse A
                     (setq X A  A C)
                     (set (big B) Y)  # Reverse B
                     (setq Y B  B D) ) )
               (while X  # Revert
                  (let Z (val (big X))
                     (set (big X) A)  # Restore A
                     (setq A X  X Z) )
                  (let Z (val (big Y))
                     (set (big Y) B)  # Restore B
                     (setq B Y  Y Z) ) ) ) ) ) ) )

(de i64 cmpNum (A B)
   (ifn (sign? A)
      (ifn (sign? B)
         (cmpu A B)
         +1 )
      (ifn (sign? B)
         -1
         (cmpu (pos B) (pos A)) ) ) )

### Formatting ###
(local) (symToNum fmtWord fmtNum)

# Make number from symbol
(de symToNum (Name (i64 . Scl) (i8 . Sep) (i8 . Ign))
   (let
      (P (push 0 Name)  # [cnt name]
         Num (push ZERO NIL)  # Result
         Sign NO
         Frac NO
         B T )
      (until (> (setq B (symByte P)) (char " "))  # Skip white space
         (unless B  # None
            (ret 0) ) )
      (cond
         ((== B (char "+"))
            (goto 1) )
         ((== B (char "-"))
            (setq Sign YES)
            (: 1
               (unless (setq B (symByte P))
                  (ret 0) ) ) ) )
      (when (> (dec 'B (char "0")) 9)
         (ret 0) )
      (set (link Num T) (cnt (i64 B)))
      (while (setq B (symByte P))
         (? (and Frac (=0 Scl))
            (when (> (dec 'B (char "0")) 9)
               (ret 0) )
            (when (>= B 5)  # Round
               (set Num (addu (val Num) ONE)) )
            (while (setq B (symByte P))
               (when (> (dec 'B (char "0")) 9)
                  (ret 0) ) ) )
         (cond
            ((== B Sep)
               (when Frac
                  (ret 0) )
               (setq Frac YES) )
            ((<> B Ign)
               (when (> (dec 'B (char "0")) 9)
                  (ret 0) )
               (set Num
                  (addu
                     (tenfold (val Num))
                     (cnt (i64 B)) ) )
               (when Frac
                  (dec 'Scl) ) ) ) )
      (when Frac
         (while (ge0 (dec 'Scl))
            (set Num (tenfold (val Num))) ) )
      (setq Num (val Num))
      (if Sign (neg Num) Num) ) )

(de i64 fmtWord ((i64 . N) (i64 . Scl) (i8 . Sep) (i8 . Ign) (i64* . P))
   (when (> N 9)
      (setq Scl (fmtWord (/ N 10) Scl Sep Ign P))
      (cond
         ((=0 Scl) (byteSym Sep P))
         ((and Ign (gt0 Scl) (=0 (% Scl 3)))
            (byteSym Ign P) ) )
      (dec 'Scl)
      (setq N (% N 10)) )
   (byteSym (+ (i8 N) (char "0")) P)
   Scl )

# Format number to output, length, or symbol
(de fmtNum (Num (i64 . Scl) (i8 . Sep) (i8 . Ign) (i64* . P))
   (let (Sign (sign? Num)  Len (+ 19 17))  # Length of 'cnt' (60 bit) plus round up div/18
      # Calculate buffer size
      (let N (setq Num (& Num -9))  # Clear sign bit
         (until (cnt? N)  # Calculate length
            (inc 'Len 20)
            (setq N (val (big N))) ) )  # Add length of 'digit'
      (setq Len (/ Len 18))  # Divide by 18 (rounded), word count
      (let (Acc (b64 Len)  TopA Acc)
         # Build BCD
         (let (Inc (b64 Len)  TopI Inc)
            (set Acc 0  Inc 1)  # Init accumulator to 0 and incrementor to 1
            (loop
               (let (Dig Num  Mask 16)
                  (when (big? Num)  # and first digit and mask
                     (setq Dig (val (dig Num))  Mask 1) )
                  (loop
                     (when (& Dig Mask)  # Bit is set
                        # Add incrementor to accumulator
                        (let (A Acc  I Inc  C 0)  # Carry for BCD addition
                           (loop
                              (let N (+ (val A) (val I) C)  # Add BCDs and Carry
                                 (setq C
                                    (if (> 1000000000000000000 N)
                                       0
                                       (dec 'N 1000000000000000000)  # BCD overflow
                                       1 ) )
                                 (set A N) )
                              (? (> (inc 'I) TopI))
                              (when (> (inc 'A) TopA)
                                 (inc 'TopA)  # Extend accumulator
                                 (set A 0) ) )  # with 0
                           (when C  # BCD-Carry
                              (set (inc 'TopA) 1) ) ) )  # Extend accumulator with 1
                     # Shift incrementor left
                     (let (I Inc  C 0)
                        (loop
                           (let N (val I)
                              (setq C
                                 (if (> 1000000000000000000 (setq N (+ N N C)))  # Double digit
                                    0
                                    (dec 'N 1000000000000000000)  # BCD overflow
                                    1 ) )
                              (set I N) )
                           (? (> (inc 'I) TopI)) )
                        (when C  # BCD-Carry
                           (inc 'TopI)  # Extend incrementor
                           (set I 1) ) )  # with 1
                     (? (=0 (setq Mask (shl Mask 1)))) ) )
               (? (cnt? Num))
               (setq Num (val (big Num))) ) )
         (cond
            ((ge0 Scl)  # Build symbol
               (when Sign
                  (byteSym (char "-") P) )
               (let N (* (shr (- TopA Acc) 3) 18)  # Calculate length~1
                  (let D (val TopA)
                     (while (setq D (/ D 10))
                        (inc 'N) ) )
                  (when (lt0 (setq Scl (- N Scl)))
                     (byteSym (char "0") P)
                     (byteSym Sep P)
                     (while (> -1 Scl)
                        (inc 'Scl)
                        (byteSym (char "0") P) ) ) )
               (setq Scl (fmtWord (val TopA) Scl Sep Ign P))  # Pack highest word
               (while (>= (dec 'TopA) Acc)
                  (let (N (val TopA)  D 100000000000000000)
                     (loop
                        (cond
                           ((=0 Scl) (byteSym Sep P))
                           ((and Ign (gt0 Scl) (=0 (% Scl 3)))
                              (byteSym Ign P) ) )
                        (dec 'Scl)
                        (? (== 1 D))
                        (byteSym (+ (i8 (/ N D)) (char "0")) P)
                        (setq N (% N D)  D (/ D 10)) )
                     (byteSym (+ (i8 N) (char "0")) P) ) )
               0 )
            ((== Scl -1)  # Direct print
               (when Sign
                  (call $Put (char "-")) )  # Output sign
               (outWord (val TopA))  # Output highest word
               (while (>= (dec 'TopA) Acc)
                  (let (N (val TopA)  D 100000000000000000)
                     (loop
                        (call $Put (+ (i8 (/ N D)) (char "0")))  # Output next digit
                        (setq N (% N D))
                        (? (== 1 (setq D (/ D 10)))) )
                     (call $Put (+ (i8 N) (char "0"))) ) )  # Output last digit
               0 )
            (T  # Calculate length
               (let (N (* (shr (- TopA Acc) 3) 18)  D (val TopA))
                  (loop
                     (inc 'N)
                     (? (=0 (setq D (/ D 10)))) )
                  (when Sign
                     (inc 'N) )
                  (cnt N) ) ) ) ) ) )

# (format 'num ['cnt ['sym1 ['sym2]]]) -> sym
# (format 'sym|lst ['cnt ['sym1 ['sym2]]]) -> num
(de _format (Exe)
   (let
      (X (cdr Exe)
         A (save (eval (++ X)))
         Y (eval (++ X))
         Scl (if (nil? Y) 0 (xCnt Exe Y))
         Sep (i8 (char "."))
         Ign (i8 0) )
      (when (pair X)
         (setq Sep (firstByte (needSymb Exe (eval (++ X)))))
         (when (pair X)
            (setq Ign (firstByte (needSymb Exe (eval (car X))))) ) )
      (cond
         ((num? A)
            (let P (push 4 NIL ZERO NIL)  # [cnt last name link]
               (link (ofs P 2))
               (fmtNum A Scl Sep Ign P)
               (consStr (val 3 P)) ) )
         ((sym? A)
            (cond
               ((sym? (val (tail A))) $Nil)
               ((=0 (symToNum (name @) Scl Sep Ign)) $Nil)
               (T @) ) )
         (T
            (if
               (symToNum
                  (let P (push 4 NIL ZERO NIL)  # [cnt last name link]
                     (link (ofs P 2))
                     (pack A P)
                     (val 3 P) )
                  Scl Sep Ign )
               @
               $Nil ) ) ) ) )

### Arithmetics ###
# (+ 'num ..) -> num
(de _add (Exe)
   (let X (cdr Exe)
      (if (nil? (eval (car X)))
         @
         (save -ZERO
            (let R (link (push (needNum Exe @) NIL))
               (loop
                  (? (atom (shift X)) (val R))
                  (? (nil? (eval (car X))) @)
                  (safe (needNum Exe @))
                  (set R (adds (val R) @)) ) ) ) ) ) )

# (- 'num ..) -> num
(de _sub (Exe)
   (let (X (cdr Exe)  N (eval (++ X)))
      (if (nil? N)
         N
         (needNum Exe N)
         (if (atom X)  # Unary minus
            (neg N)
            (save -ZERO
               (let R (link (push N NIL))
                  (loop
                     (? (nil? (eval (++ X))) @)
                     (safe (needNum Exe @))
                     (set R (subs (val R) @))
                     (? (atom X) (val R)) ) ) ) ) ) ) )

# (inc 'num) -> num
# (inc 'var ['num]) -> num
(de _inc (Exe)
   (let X (cdr Exe)
      (cond
         ((nil? (eval (car X))) @)
         ((num? @) (incs @))
         (T
            (let Y (save (chkVar Exe @))  # Symbol or cell
               (when (and (sym? Y) (sym? (val (tail Y))))  # External
                  (dbTouch Exe Y) )
               (if (atom (shift X))
                  (if (nil? (val Y))
                     @
                     (set Y (incs (needNum Exe @))) )
                  (let (D (save (eval (car X)))  N (val Y))
                     (cond
                        ((nil? N) N)
                        ((nil? D) D)
                        (T (set Y (adds (needNum Exe N) (needNum Exe D)))) ) ) ) ) ) ) ) )

# (dec 'num) -> num
# (dec 'var ['num]) -> num
(de _dec (Exe)
   (let X (cdr Exe)
      (cond
         ((nil? (eval (car X))) @)
         ((num? @) (decs @))
         (T
            (let Y (save (chkVar Exe @))  # Symbol or cell
               (when (and (sym? Y) (sym? (val (tail Y))))  # External
                  (dbTouch Exe Y) )
               (if (atom (shift X))
                  (if (nil? (val Y))
                     @
                     (set Y (decs (needNum Exe @))) )
                  (let (D (save (eval (car X)))  N (val Y))
                     (cond
                        ((nil? N) N)
                        ((nil? D) D)
                        (T (set Y (subs (needNum Exe N) (needNum Exe D)))) ) ) ) ) ) ) ) )

# (* 'num ..) -> num
(de _mul (Exe)
   (let X (cdr Exe)
      (if (nil? (eval (car X)))
         @
         (save -ZERO
            (let
               (Sign (sign? (needNum Exe @))
                  R (link (push (pos @) NIL)) )
               (loop
                  (? (atom (shift X))
                     (let N (val R)
                        (if Sign (neg N) N) ) )
                  (let N (eval (car X))
                     (? (nil? N) N)
                     (? (== N ZERO) N)
                     (when (sign? (needNum Exe N))
                        (setq Sign (not Sign)  N (pos N)) )
                     (safe N)
                     (set R (mulu (val R) N)) ) ) ) ) ) ) )

# (*/ 'num1 ['num2 ..] 'num3) -> num
(de _mulDiv (Exe)
   (let X (cdr Exe)
      (if (nil? (eval (car X)))
         @
         (save -ZERO
            (let
               (Sign (sign? (needNum Exe @))
                  R (link (push (pos @) NIL)) )
               (shift X)
               (loop
                  (let N (eval (car X))
                     (? (nil? N) N)
                     (when (sign? (needNum Exe N))
                        (setq Sign (not Sign)  N (pos N)) )
                     (safe N)
                     (? (atom (shift X))
                        (when (== N ZERO)
                           (divErr Exe) )
                        (let Half (save (shru N))
                           (setq N
                              (divu  # Divide by last arg
                                 (set R (addu (val R) Half))  # Round
                                 N ) ) )
                        (if Sign (neg N) N) )
                     (? (== N ZERO) N)
                     (set R (mulu (val R) N)) ) ) ) ) ) ) )

# (/ 'num ..) -> num
(de _div (Exe)
   (let X (cdr Exe)
      (if (nil? (eval (car X)))
         @
         (save -ZERO
            (let
               (Sign (sign? (needNum Exe @))
                  R (link (push (pos @) NIL)) )
               (loop
                  (? (atom (shift X))
                     (let N (val R)
                        (if Sign (neg N) N) ) )
                  (let N (eval (car X))
                     (? (nil? N) N)
                     (when (== N ZERO)
                        (divErr Exe) )
                     (when (sign? (needNum Exe N))
                        (setq Sign (not Sign)  N (pos N)) )
                     (safe N)
                     (set R (divu (val R) N)) ) ) ) ) ) ) )

# (% 'num ..) -> num
(de _rem (Exe)
   (let X (cdr Exe)
      (if (nil? (eval (car X)))
         @
         (save -ZERO
            (let
               (Sign (sign? (needNum Exe @))
                  R (link (push (pos @) NIL)) )
               (loop
                  (? (atom (shift X))
                     (let N (val R)
                        (if Sign (neg N) N) ) )
                  (let N (eval (car X))
                     (? (nil? N) N)
                     (when (== N ZERO)
                        (divErr Exe) )
                     (set R
                        (remu
                           (val R)
                           (safe (pos (needNum Exe N))) ) ) ) ) ) ) ) ) )

# (>> 'cnt 'num) -> num
(de _shr (Exe)
   (let
      (X (cdr Exe)
         N (evCnt Exe X)
         Y (eval (cadr X)) )
      (if
         (or
            (=0 N)
            (nil? Y)
            (== ZERO (needNum Exe Y)) )
         Y
         (let Sign (sign? Y)
            (setq Y (save (pos Y)))
            (cond
               ((gt0 N)
                  (while (and (big? Y) (>= N 64))  # Large shift count
                     (setq Y (val (big Y)))  # Discard 64 bits
                     (unless (dec 'N 64)
                        (goto 9) ) )
                  (setq Y (safe (shru Y)))  # Non-destructive
                  (while (dec 'N)
                     (setq Y (half Y)) ) )  # Shift right (destructive)
               (T
                  (while (>= -64 N)
                     (setq Y (safe (consNum 0 Y)))
                     (unless (inc 'N 64)
                        (goto 9) ) )
                  (setq Y (safe (shlu Y)))  # Non-destructive
                  (while (inc 'N)
                     (setq Y (safe (twice Y))) ) ) )  # Shift left (destructive)
            (: 9
               (if Sign (neg Y) Y) ) ) ) ) )

# (rev 'cnt1 'cnt2) -> cnt
(de _rev (Exe)
   (let
      (X (cdr Exe)
         C (evCnt Exe X)
         N (evCnt Exe (cdr X))
         R 0 )
      (loop
         (setq
            R (+ R R (& N 1))
            N (shr N 1) )
         (? (=0 (dec 'C))) )
      (cnt R) ) )

# (lt0 'any) -> num | NIL
(de _lt0 (Exe)
   (if (and (num? (eval (cadr Exe))) (sign? @))
      @
      $Nil ) )

# (le0 'any) -> num | NIL
(de _le0 (Exe)
   (if
      (and
         (num? (eval (cadr Exe)))
         (or (== @ ZERO) (sign? @)) )
      @
      $Nil ) )

# (ge0 'any) -> num | NIL
(de _ge0 (Exe)
   (if
      (and
         (num? (eval (cadr Exe)))
         (not (sign? @)) )
      @
      $Nil ) )

# (gt0 'any) -> num | NIL
(de _gt0 (Exe)
   (if
      (and
         (num? (eval (cadr Exe)))
         (<> @ ZERO)
         (not (sign? @)) )
      @
      $Nil ) )

# (abs 'num) -> num
(de _abs (Exe)
   (if (nil? (eval (cadr Exe)))
      @
      (pos (needNum Exe @)) ) )

### Bit operations ###
# (bit? 'num ..) -> num | NIL
(de _bitQ (Exe)
   (let
      (X (cdr Exe)
         N (save (pos (needNum Exe (eval (++ X))))) )
      (loop
         (? (atom X) N)  # All matched
         (let Y (eval (++ X))
            (? (nil? Y) Y)  # Abort with NIL
            (setq Y (pos (needNum Exe Y)))
            (let Z N
               (while (big? Z)
                  (unless (big? Y)
                     (ret $Nil) )
                  (let A (val (dig Z))
                     (unless (== A (& A (val (dig Y))))
                        (ret $Nil) ) )
                  (setq
                     Y (val (big Y))
                     Z (val (big Z)) ) )
               (when (big? Y)
                  (setq Z (int Z)  Y (val (dig Y))) )
               (? (<> Z (& Y Z)) $Nil) ) ) ) ) )

# (& 'num ..) -> num
(de _bitAnd (Exe)
   (let X (cdr Exe)
      (if (nil? (eval (car X)))
         @
         (save -ZERO
            (let R (link (push (pos (needNum Exe @)) NIL))
               (loop
                  (? (atom (shift X)) (val R))
                  (? (nil? (eval (car X))) @)
                  (safe (needNum Exe @))
                  (set R (andu (val R) (pos @))) ) ) ) ) ) )

# (| 'num ..) -> num
(de _bitOr (Exe)
   (let X (cdr Exe)
      (if (nil? (eval (car X)))
         @
         (save -ZERO
            (let R (link (push (pos (needNum Exe @)) NIL))
               (loop
                  (? (atom (shift X)) (val R))
                  (? (nil? (eval (car X))) @)
                  (safe (needNum Exe @))
                  (set R (oru (val R) (pos @))) ) ) ) ) ) )

# (x| 'num ..) -> num
(de _bitXor (Exe)
   (let X (cdr Exe)
      (if (nil? (eval (car X)))
         @
         (save -ZERO
            (let R (link (push (pos (needNum Exe @)) NIL))
               (loop
                  (? (atom (shift X)) (val R))
                  (? (nil? (eval (car X))) @)
                  (safe (needNum Exe @))
                  (set R (xoru (val R) (pos @))) ) ) ) ) ) )

# (sqrt 'num ['flg|num]) -> num
(de _sqrt (Exe)
   (let X (cdr Exe)
      (if (nil? (eval (car X)))
         @
         (when (sign? (needNum Exe @))
            (argErr Exe @) )
         (let (Y (save @)  Z (save (eval (cadr X))))
            (when (num? Z)
               (setq Y (safe (mulu Y Z))) )
            (prog1
               (if (cnt? Y)
                  (let (M (hex "400000000000000")  R 0)
                     (setq Y (int Y))
                     (loop
                        (let N (+ R M)
                           (when (>= Y N)
                              (dec 'Y N)
                              (setq R (+ N M)) ) )
                        (setq R (shr R 1))
                        (? (=0 (setq M (shr M 2)))) )
                     (or (nil? Z) (>= R Y) (inc 'R))  # Round
                     (cnt R) )
                  (let
                     (M (consNum 0 ONE)
                        M* (link (push M NIL))
                        R (link (push ZERO NIL))
                        C (boxNum (val (dig Y)))  # Copy number
                        C* (link (push C NIL)) )
                     (while (big? (setq Y (val (big Y))))
                        (setq C
                           (set (big C) (boxNum (val (dig Y)))) )
                        (setq M (set M* (consNum 0 M))) )
                     (set (big C) Y)
                     (setq Y (safe (val C*)))
                     (while (le0 (cmpu M Y))
                        (twiceBig M)
                        (twiceBig M) )
                     (loop
                        (let N (set C* (addu (val R) M))
                           (when (ge0 (cmpu Y N))
                              (setq Y (safe (subu Y N)))
                              (set R (addu N M)) ) )
                        (set R (half (val R)))
                        (?
                           (==
                              ZERO
                              (setq M (set M* (half (half M)))) ) ) )
                     (setq R (val R))
                     (if (or (nil? Z) (ge0 (cmpu R Y)))
                        R
                        (addu R ONE) ) ) ) ) ) ) ) )  # Round


### Random generator ###
(local) initSeed

(de initSeed (X)
   (let C 0
      (while (pair X)
         (inc 'C (initSeed (++ X))) )
      (unless (nil? X)
         (unless (num? X)  # Need number
            (setq X (name (& (val (tail X)) -9))) )
         (if (cnt? X)
            (inc 'C (shr X 3))  # Keep sign
            (when (sign? X)
               (inc 'C)
               (setq X (pos X)) )
            (loop
               (inc 'C (val (dig X)))
               (? (cnt? (setq X (val (big X))))) )
            (inc 'C (int X)) ) )
      C ) )

# (seed 'any) -> cnt
(de _seed (Exe)
   (let N (mul 6364136223846793005 (initSeed (eval (cadr Exe))))
      (set $SeedL N  $SeedH @@@)
      (| (& (shr N (- 32 3)) -8) 2) ) )  # Get higher 32 bits

# (hash 'any) -> cnt
(de _hash (Exe)
   (let (N (initSeed (eval (cadr Exe)))  C 64  R 0)
      (loop
         (when (& (x| N R) 1)
            (setq R (x| R (hex "14002"))) )  # CRC Polynom x**16 + x**15 + x**2 + 1
         (setq N (shr N 1)  R (shr R 1))
         (? (=0 (dec 'C))) )
      (cnt (inc R)) ) )

# (rand ['cnt1 'cnt2] | ['T]) -> cnt | flg
(de _rand (Exe)
   (let
      (X (cdr Exe)
         Y (eval (++ X))
         N (add (mul 6364136223846793005 (val $SeedL)) 1) )
      (set $SeedL N  $SeedH (+ @@@ @@))
      (cond
         ((nil? Y)
            (| (& (shr N (- 32 3)) -8) 2) )  # Get higher 32 bits
         ((t? Y)
            (add N N)
            (if @@ Y $Nil) )
         (T
            (when (sign? (needCnt Exe Y))
               (argErr Exe Y) )
            (let A (int Y)
               (when (sign? (needCnt Exe (setq Y (eval (car X)))))
                  (argErr Exe Y) )
               (let B (inc (int Y))  # Seed % (cnt2 + 1 - cnt1) + cnt1
                  (when (>= A B)
                     (argErr Exe Y) )
                  (setq N
                     (+
                        (%
                           (shr (val $SeedH) (val $SeedL) 32)  # Get middle 64 bits
                           (- B A) )
                        A ) )
                  (if (lt0 N)
                     (sign (cnt (- N)))
                     (cnt N) ) ) ) ) ) ) )
