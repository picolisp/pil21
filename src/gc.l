# 24may22 Software Lab. Alexander Burger

(symbols '(llvm))

(local) (mark gc need3)

(de void mark (E)
   (let Tos 0  # Clear
      (loop
         (until (cnt? E)
            (let (P (any (& E -16))  Q (cdr P))  # Cell pointer
               (? (=0 (& Q 1)))  # Already marked
               (set 2 P (setq Q (& Q -2)))  # Mark cell
               (? (big? E)
                  (until (cnt? Q)
                     (let N (val (big Q))
                        (? (=0 (& N 1)))  # Already marked
                        (setq Q (set (big Q) (& N -2))) ) ) )  # Mark big digits
               (let X E  # Current item
                  (setq E (val P))  # Get CAR
                  (set P (| Tos 1))  # First visit
                  (setq Tos X) ) ) )  # TOS on previous
         (loop
            (let P (any (& Tos -16))  # TOS cell pointer
               (unless P  # Empty
                  (ret) )
               (let Q (val P)  # Up pointer
                  (? (& Q 1)  # Second visit
                     (set P E)  # Restore CAR
                     (setq E (cdr P))  # Get CDR
                     (set 2 P (& Q -2)) ) )  # Store up pointer
               (let X Tos
                  (setq Tos (cdr P))  # TOS up
                  (set 2 P E)  # Restore CDR
                  (setq E X) ) ) ) ) ) )  # Go up

(de void gc ()
   (set $DB -ZERO)  # Cut off DB root
   # Prepare
   (let P $Nil  # Symbol table
      (set P (| (val P) 1))  # Set mark bit
      (setq P (ofs P 4))  # Skip NIL tail
      (loop
         (set P (| (val P) 1))  # Set mark bit
         (? (== P $LastSym))
         (setq P (ofs P 2)) ) )  # Next symbol
   (let P (val $Heaps)
      (loop
         (let C CELLS
            (loop
               (set 2 P (| (cdr P) 1))  # Set mark bit
               (setq P (ofs P 2))  # Next cell
               (? (=0 (dec 'C))) ) )
         (setq P (val P))  # Next heap
         (? (=0 P)) ) )
   # Mark
   (let P (any (gcData))  # Globals
      (loop
         (mark (val P))  # Mark
         (? (== P $LispEnd))
         (setq P (ofs P 1)) ) )  # Next global
   (let P (val $Link)  # Stack(s)
      (while P
         (mark (val P))  # Mark item
         (shift P) ) )
   (let P (val $Bind)  # Bind frames
      (while P
         (mark (val P))  # Mark saved value
         (mark (val 2 P))  # Mark symbol
         (setq P (val 3 P)) ) )
   (let Ca (val $Catch)  # Catch frames
      (while Ca
         (let Ca: (caFrame Ca)
            (when (Ca: tag)  # Mark 'tag'
               (mark @) )
            (mark (Ca: fin))  # Mark 'fin'
            (mark (Ca: intrn))
            (mark (Ca: trns1))
            (mark (Ca: trns2))
            (mark (Ca: priv1))
            (mark (Ca: priv2))
            (setq Ca (Ca: link)) ) ) )
   (let Put (val $Output)  # 'output' Put frames
      (while Put
         (let Put: (putFrame Put)
            (when (Put: char)  # Mark 'char'
               (mark @) )
            (setq Put (Put: link)) ) ) )
   (let Crt (val $Coroutines)
      (while Crt
         (let Crt: (coroutine Crt)
            (when (and (Crt: tag) (Crt: at))
               (mark (Crt: tag))
               (mark (Crt: prg))
               (mark (Crt: at))
               (mark (Crt: intrn))
               (mark (Crt: trns1))
               (mark (Crt: trns2))
               (mark (Crt: priv1))
               (mark (Crt: priv2))
               (let P (Crt: (env $Link any))  # Stack(s)
                  (while P
                     (mark (val P))  # Mark item
                     (shift P) ) )
               (let P (Crt: (env $Bind any))  # Bind frames
                  (while P
                     (mark (val P))  # Mark saved value
                     (mark (val 2 P))  # Mark symbol
                     (setq P (val 3 P)) ) )
               (let Ca (Crt: (env $Catch i8*))
                  (while Ca
                     (let Ca: (caFrame Ca)
                        (when (Ca: tag)  # Mark 'tag'
                           (mark (Ca: tag)) )
                        (mark (Ca: fin))
                        (mark (Ca: intrn))
                        (mark (Ca: trns1))
                        (mark (Ca: trns2))
                        (mark (Ca: priv1))
                        (mark (Ca: priv2))
                        (setq Ca (Ca: link)) ) ) ) )
            (setq Crt (Crt: nxt)) ) ) )
   (let (Tos 0  P (val $Extern))  # Externals
      (loop
         (loop
            (let X (any (& (cdr P) -2))
               (set 2 P X)  # Clear mark bit
               (let Y (any (& (cdr X) -2))  # Right subtree
                  (set 2 X Y)  # Clear mark bit
                  (? (atom Y))
                  (let Z P  # Go right
                     (setq P Y)  # Invert tree
                     (set 2 X Tos)
                     (setq Tos Z) ) ) ) )
         (loop
            (let S (val P)  # Get external symbol
               (when (& (val S) 1)  # Not marked
                  (let Tail (val (tail S))
                     (unless (num? Tail)  # Has properties
                        (setq Tail (& Tail -10))  # Clear 'extern' tag and mark bit
                        (until (num? (shift Tail))  # Skip property
                           (setq Tail (& Tail -2)) ) )  # Clear mark bit
                     (add Tail Tail)  # Get carry
                     (when @@  # Dirty or deleted
                        (mark S) ) ) ) )
            (let X (cdr P)  # Left subtree
               (? (pair (car X))
                  (let Z P  # Go left
                     (setq P @)  # Invert tree
                     (set X Tos)
                     (setq Tos (| Z 8)) ) ) )  # First visit
            (loop
               (unless Tos
                  (goto 1) )
               (? (=0 (& Tos 8))  # Second visit
                  (let (X Tos  Y (cdr X))  # Nodes
                     (setq Tos (cdr Y))  # TOS on up link
                     (set 2 Y P)
                     (setq P X) ) )
               (setq Tos (& Tos -9))  # Clear visit bit
               (let (X Tos  Y (cdr X))  # Nodes
                  (setq Tos (car Y))
                  (set Y P)
                  (setq P X) ) ) ) ) )
   (: 1
      (set $DB $Db1)  # Restore DB root
      (when (& (val $Db1) 1)  # Not marked
         (set
            $Db1 $Nil  # Clear
            (tail $Db1) DB1 ) ) )  # Set to "not loaded"
   (let (Tos 0  P (val $Extern))  # Externals
      (: 2
         (loop
            (loop
               (let X (cdr P)  # Right subtree
                  (? (atom (cdr X)))
                  (let Z P  # Go right
                     (setq P @)  # Invert tree
                     (set 2 X Tos)
                     (setq Tos Z) ) ) )
            (loop
               (when (& (val (val P)) 1)  # External symbol not marked
                  (set $ExtCnt (- (val $ExtCnt) 1))  # Remove it
                  (let X (cdr P)
                     (when (atom X)  # No subtrees
                        (set 2 P (| X 1))  # Set mark bit again
                        (setq P X)  # Use NIL
                        (goto 4) )  # Already traversed
                     (when (atom (car X))  # No left branch
                        (set 2 P (| X 1))  # Set mark bit again
                        (setq P (cdr X))  # Use right branch
                        (set 2 X (| P 1))
                        (goto 4) )  # Already traversed
                     (when (atom (cdr X))  # No right branch
                        (set 2 P (| X 1))  # Set mark bit again
                        (setq P (car X))  # Use left branch
                        (set 2 X (| (cdr X) 1))
                        (goto 2) )
                     (let Y (cdr (shift X))  # X on right branch
                        (when (atom (car Y))  # No left sub-branches
                           (set
                              P (car X)  # Insert right sub-branch
                              2 (cdr P) (cdr Y) )
                           (goto 3) )
                        (setq Y (car Y))  # Left sub-branch
                        (loop
                           (? (atom (cadr Y))  # No more left branches
                              (set  # Insert left sub-branch
                                 P (car Y)
                                 (cdr X) (cddr Y) ) )
                           (setq X Y  Y @) ) ) ) )  # Go down left
               (: 3
                  (let X (cdr P)  # Left subtree
                     (? (pair (car X))
                        (let Z P  # Go left
                           (setq P @)  # Invert tree
                           (set X Tos)
                           (setq Tos (| Z 8)) ) ) ) )  # First visit
               (: 4
                  (loop
                     (unless Tos
                        (goto 5) )
                     (? (=0 (& Tos 8))  # Second visit
                        (let (X Tos  Y (cdr X))  # Nodes
                           (setq Tos (cdr Y))  # TOS on up link
                           (set 2 Y P)
                           (setq P X) ) )
                     (let (X (& Tos -9)  Y (cdr X))  # Clear visit bit
                        (setq Tos (car Y))
                        (set Y P)
                        (setq P X) ) ) ) ) ) )
      (: 5 (set $Extern P)) )
   # Sweep
   (let (Avail 0  Heap (val $Heaps)  Cnt (val $GcCount))
      (ifn Cnt
         (let H (any $Heaps)  # Try to free heaps
            (loop
               (let (A Avail  P (ofs Heap (- HEAP 2)))  # P on last cell in chunk
                  (setq Cnt CELLS)
                  (loop
                     (when (& (cdr P) 1)  # Free cell
                        (set P Avail)  # Link avail
                        (setq Avail P)
                        (dec 'Cnt) )
                     (? (== P Heap))
                     (setq P (ofs P -2)) )  # Back one cell
                  (if Cnt
                     (setq Heap (val (setq H (ofs Heap HEAP))))  # Next heap
                     (setq Avail A  Heap (val (inc HEAP) Heap))  # Reset avail list
                     (free (i8* (val H)))  # Free empty heap
                     (set H Heap) ) )  # Store next heap in list link
               (? (=0 Heap)) )
            (set $Avail Avail) )
         (loop
            (let P (ofs Heap (- HEAP 2))  # P on last cell in chunk
               (loop
                  (when (& (cdr P) 1)  # Free cell
                     (set P Avail)  # Link avail
                     (setq Avail P)
                     (dec 'Cnt) )
                  (? (== P Heap))
                  (setq P (ofs P -2)) ) )  # Back one cell
            (? (=0 (setq Heap (val (inc HEAP) Heap)))) )
         (set $Avail Avail)
         (while (ge0 Cnt)  # Ensure free cells
            (heapAlloc)
            (dec 'Cnt CELLS) ) ) ) )

(de void need3 ()
   (let P (val $Avail)
      (unless (and P (setq P (car P)) (car P))
         (gc) ) ) )

# (gc ['cnt [cnt2]]) -> cnt | NIL
(de _gc (Exe)
   (let (X (cdr Exe)  Y (eval (car X)))  # MiBs
      (set $At $Nil  $At2 $Nil)
      (if (nil? Y)
         (gc)
         (set $GcCount (shl (xCnt Exe Y) 16))  # Multiply with CELLS
         (gc)
         (set $GcCount
            (if (atom (shift X))
               CELLS
               (shl (evCnt Exe X) 16) ) ) )  # New default
      Y ) )

# Cell allocation (consing)
(local) (cons cons2 cons3 consSym consStr consExt boxNum consNum box)

(de cons (Car Cdr)
   (let P (val $Avail)
      (unless P
         (save2 Car Cdr
            (gc) )
         (setq P (val $Avail)) )
      (set $Avail (car P))
      (set P Car)
      (set 2 P Cdr)
      P ) )

(de cons2 (Car1 Cdr1 Cdr2)
   (let P (val $Avail)
      (when P
         (let Q (val P)
            (when Q
               (set $Avail (car Q))
               (set P Car1)
               (set 2 P Cdr1)
               (set Q P)
               (set 2 Q Cdr2)
               (ret Q) ) ) ) )
   (save2 Car1 Cdr1
      (save Cdr2
         (gc) ) )
   (let (P (val $Avail)  Q (val P))
      (set $Avail (car Q))
      (set P Car1)
      (set 2 P Cdr1)
      (set Q P)
      (set 2 Q Cdr2)
      Q ) )

(de cons3 (Car1 Cdr1 Car2 Cdr2)
   (let P (val $Avail)
      (when P
         (let Q (val P)
            (when Q
               (let R (val Q)
                  (when R
                     (set $Avail (car R))
                     (set P Car1)
                     (set 2 P Cdr1)
                     (set Q Car2)
                     (set 2 Q Cdr2)
                     (set R P)
                     (set 2 R Q)
                     (ret R) ) ) ) ) ) )
   (save2 Car1 Cdr1
      (save2 Car2 Cdr2
         (gc) ) )
   (let (P (val $Avail)  Q (val P)  R (val Q))
      (set $Avail (car R))
      (set P Car1)
      (set 2 P Cdr1)
      (set Q Car2)
      (set 2 Q Cdr2)
      (set R P)
      (set 2 R Q)
      R ) )

(de consSym (Name Val)
   (let P (val $Avail)
      (unless P
         (if Val
            (save2 Name Val
               (gc) )
            (save Name
               (gc) ) )
         (setq P (val $Avail)) )
      (set $Avail (car P))
      (set P Name)
      (let S (sym P)
         (set S (if Val @ S))
         S ) ) )

(de consStr (Name)
   (if (== Name ZERO)
      $Nil
      (tailcall (consSym Name 0)) ) )

(de consExt (Name)
   (set $ExtCnt (+ (val $ExtCnt) 1))
   (tailcall (consSym (sign Name) $Nil)) )

(de boxNum (Dig)
   (let P (val $Avail)
      (unless P
         (gc)
         (setq P (val $Avail)) )
      (set $Avail (car P))
      (set P Dig)
      (set 2 P ZERO)
      (big P) ) )

(de consNum (Dig Big)
   (let P (val $Avail)
      (unless P
         (save Big
            (gc) )
         (setq P (val $Avail)) )
      (set $Avail (car P))
      (set P Dig)
      (set 2 P Big)
      (big P) ) )

(de box (N)
   (if (ge0 N)
      (box64 N)
      (sign (box64 (- N))) ) )
