# 26may22 Software Lab. Alexander Burger

(sysdefs "terminal")

(local) (ULINE U-OFF REVERS CYAN RED *AttrA *AttrU)

(de ULINE . 4)
(de U-OFF . 24)
(de REVERS . 7)
(de CYAN . 36)
(de RED . 31)

(off *AttrA *AttrU)

(local) (xterm getTerm setTerm)

(de xterm ()
   (member (sys "TERM") '("xterm" "screen")) )

(de getTerm ()
   (use Lst
      (and
         (=0
            (%@ "ioctl" 'I 1 TIOCGWINSZ
               '(Lst (`winsize W W W W)) ) )
         Lst ) ) )

(de setTerm (Term Rows Cols DX DY)
   (sys "TERM" Term)
   (sys "LINES" Rows)
   (sys "COLUMNS" Cols)
   (%@ "ioctl" 'I 1 TIOCSWINSZ
      (cons NIL (`winsize)
         (cons Rows 2)  # ws_row
         (cons Cols 2)  # ws_col
         (cons DX 2)  # ws_xpixel
         (cons DY 2) ) )  # ws_ypixel
   (%@ "rl_reset_terminal" 'I 0) )

(local) (attr cup clreol hideCsr showCsr screen1 screen2)

(de attr (A U)
   (if2 (<> A *AttrA) (<> U *AttrU)
      (prin "\e["
         (or (setq *AttrA A) 0)
         ";"
         (if (setq *AttrU U) ULINE U-OFF)
         "m" )
      (prin "\e[" (or (setq *AttrA A) 0) "m")
      (prin "\e[" (if (setq *AttrU U) ULINE U-OFF) "m") ) )

(de cup (Y X)
   (prin "\e[" Y ";" X "H") )

(de clreol ()
   (prin "\e[0K") )

(de hideCsr ()
   (prin "\e[?25l") )

(de showCsr ()
   (prin "\e[?25h") )

(de screen1 ()
   (if (xterm)
      (prin "\e[?1049l")
      (cup *Lines 1) )
   (flush) )

(de screen2 ()
   (and (xterm) (prin "\e[?1049h")) )
