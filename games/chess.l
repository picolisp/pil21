# 27nov20 Software Lab. Alexander Burger
# ./pil games/chess.l -chess~main +

(load "@games/libChess.l")

(symbols '(chess simul pico))

(local) (display main go ppos)

(dm (img> . +White) ()
   (pack " " (name> This) " ") )

(dm (img> . +Black) ()
   (pack "<" (name> This) ">") )

(de display (Res)
   (when Res
      (disp *Board T
         '((This)
            (cond
               ((: piece) (img> @))
               ((: color) " - ")
               (T "   ") ) ) ) )
   (and (inCheck *You) (prinl "(+)"))
   Res )

# Start game
(de main (Depth You Init)
   (symbols '(chess simul pico))
   (setup Depth You Init)
   (display T) )

# Single move
(de go Args
   (display
      (cond
         ((not Args) (xchg '*Me '*You) (myMove))
         ((== '- (car Args)) (and *Undo (undo)))
         ((== '+ (car Args)) (and *Redo (redo)))
         ((apply yourMove Args) (display T) (myMove)) ) ) )

# Print position to file
(de ppos (File)
   (out File
      (println
         (list 'main *Depth *You
            (lit
               (mapcar
                  '((This)
                     (list
                        (: field)
                        (val This)
                        (not (memq This *Moved)) ) )
                  (append *White *Black) ) ) ) ) ) )
