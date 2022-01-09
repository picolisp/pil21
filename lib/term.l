# 08jan22 Software Lab. Alexander Burger

(sysdefs "terminal")

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
