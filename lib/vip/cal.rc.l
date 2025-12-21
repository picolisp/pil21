# 21dec25 Software Lab. Alexander Burger

(symbols '(pico)
   (load "@lib/misc.l") )

(private) (*Cal *Pat slot entry calFile patFile findCal drawCal loadCal)

(de *Cal . "~/.pil/cal/")

(cmd "cal" (L Lst Cnt)
   (let
      (D (date (date))
         M (car (setq L (str L)))
         Y (cadr L) )
      (drawCal
         (or (index M *Mon) M (cadr D))
         (ifn Y
            (car D)
            (if
               (and
                  (>= 99 Y)
                  (>= (inc 'Y 2000) (+ 9 (car D))) )
               (- Y 100)
               Y ) ) ) )
   (setq *Search
      '((L C)
         (or
            (head '("·" "=") L)
            (and (sp? C) (= "=" (car L))) ) ) )
   (=: buffer keys
      (quote
         ("K"  # Edit
            (if (get (: buffer text) (: posY) (: posX) 'cal)
               (loadCal @)
               (beep) ) )
         ("w" (move 'goForward 'slot *Cnt))  # Slot forward
         ("b" (move 'goBackward 'slot *Cnt))  # Slot backward
         ("W" (move 'goForward 'entry *Cnt))  # Entry forward
         ("B" (move 'goBackward 'entry *Cnt))  # Entry backward
         ("\e[A"  # UP
            (findCal flip
               (P) (and (=0 (dec P)) (set P 12)) ) )
         ("\e[B"  # DOWN
            (findCal prog
               (P) (and (== 13 (inc P)) (set P 1)) ) )
         ("\e[C"  # RIGHT
            (if (== 12 (: buffer mon))
               (drawCal 1 (inc (: buffer year)))
               (drawCal (inc (: buffer mon)) (: buffer year)) ) )
         ("\e[D"  # LEFT
            (if (=1 (: buffer mon))
               (drawCal 12 (dec (: buffer year)))
               (drawCal (dec (: buffer mon)) (: buffer year)) ) ) ) )
   (let *Class (: buffer)
      (dm search> (Win Pat)
         (setq *Pat (append '(@) Pat '(@)))
         '((L)
            (and
               (= "·" (car L))
               (; L 1 cal)
               (info (calFile @))
               (patFile @@) ) ) ) )
   (let *Class This
      (dm status> (A F Z)
         (let Dat
            (get
               (: buffer text)
               (: posY)
               (: posX)
               'cal )
            (when (and (: buffer mon) (member NIL (: buffer text)))
               (con @
                  (and Dat (info (calFile @)) (in @@ (rdLines))) )
               (drawin)
               (setq F (day Dat)  Z (dat$ Dat "-")) ) )
         (super A F Z) ) ) )

(de slot (L C)
   (and (sp? C) (; L 1 cal)) )

(de entry (L)
   (= "·" (car L)) )

(de calFile (Dat)
   (pack *Cal (glue "/" (date Dat))) )

(de patFile (F)
   (find
      '((L) (match *Pat L))
      (in F (rdLines)) ) )

(de findCal (Fun1 . Fun2)
   (let
      (Y
         (member
            (format (: buffer year))
            (Fun1 (sort (dir *Cal))) )
         M (: buffer mon) )
      (loop
         (T (and (Fun2 'M) (not (shift 'Y)))
            (beep) )
         (T
            (and
               (info (pack *Cal (car Y) "/" M))
               (find
                  '((F)
                     (patFile (pack *Cal (car Y) "/" M "/" F)) )
                  (dir @@) ) )
            (goto 4 3)
            (keys '("n"))
            (drawCal M (format (car Y))) ) ) ) )

(de drawCal (Mon Year)
   (with
      (scratch (tmp "cal")
         (let
            (Dat (date Year Mon 1)
               Skip (% (inc Dat) 7)
               Day 1 )
            (make
               (link
                  (chop (pack "              " (get *Mon Mon) " " Year))
                  (chop "     Mo  Tu  We  Th  Fr  Sa  Su") )
               (loop
                  (link
                     (make
                        (chain (chop (align 2 (week Dat))))
                        (link (name " "))
                        (do 7
                           (NIL
                              (if (ge0 (dec 'Skip))
                                 (chain (chop "    "))
                                 (link (name " "))
                                 (let L
                                    (chop
                                       (pack
                                          (and (info (calFile Dat)) "·")
                                          (if (= (date) Dat) "==" Day) ) )
                                    (or (cdr L) (link (name " ")))
                                    (or (cddr L) (link (name " ")))
                                    (mapc put (chain L) 'cal Dat) )
                                 (setq Dat (date Year Mon (inc 'Day)))) ) ) ) )
                  (NIL Dat) )
               (link NIL) ) )
         3 )
      (=: mon Mon)
      (=: year Year) ) )

(de loadCal (Dat)
   (reload (calFile Dat))
   (evCmd (day (=: buffer cal Dat) *Day))
   (=: buffer keys
      (quote
         ("\e[C"  # RIGHT
            (let B (: buffer)
               (loadCal (+ (: buffer cal) *Cnt))
               (delBuf B)
               (repaint) ) )
         ("\e[D"  # LEFT
            (let B (: buffer)
               (loadCal (- (: buffer cal) *Cnt))
               (delBuf B)
               (repaint) ) ) ) )
   (let *Class (: buffer)
      (dm save> (Win)
         (call "mkdir" "-p" (dirname (: file)))
         (super Win)
         (unless (: text)
            (call "rm" (: file)) )
         (let ((Y M) (date (: cal)))
            (with Win (drawCal M Y)) ) ) ) )

NIL

The above code implements a ":cal" (calendar) command for Vip.

To enable it, include the line

   (load "@lib/vip/cal.rc.l")

in your "~/.pil/viprc" (or in a local ".viprc") file.


The calendar opens in a new buffer with

   :cal

to display the current month. You can pass a month name (starting with
an uppercase letter) or a number to display another month of the current
year:

   :cal Nov
   :cal 11

You can also specify a year:

   :cal Jan 2026
   :cal 1 2026

If you enter only two digits for the year, the corresponding year within
the range −90 .. +10 years from the current year is chosen:

   :cal Jan 26


Use the RIGHT and LEFT arrow keys to skip to the next or previous month.

"Today" is indicated by "==". The editor's search pattern is initialized
to this marker, so pressing "n" (the Vip command for “search next”)
jumps to today’s date.

The editor commands "w" (move word forward) and "b" (move word backward)
are redefined for this buffer to move to the next or previous day,
respectively.

Pressing "K" on a day opens a new buffer for that date’s file in the
"~/.pil/cal/" directory tree. The file is automatically created when you
add text and save it (e.g. with ":w" or ":x"), and it is deleted if the
text is empty. While editing a day, the RIGHT and LEFT arrow keys move
directly to the next or previous day.

In the calendar window, days that have an associated file (i.e. contain
text) are marked with a "·" character. The "W" (move long word forward)
and "B" (move long word backward) commands move to the next or previous
non-empty day.

When you move the cursor to a non-empty day, its text content is
displayed below the calendar.

If you enter a new search pattern using the "/" or "?" command, the
initial search for "today" is replaced by a search through the daily
text files of that month. Using the DOWN and UP arrow keys then
continues the search in the next or previous months, jumping directly to
matching days.
