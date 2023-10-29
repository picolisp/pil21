# 29oct23 Software Lab. Alexander Burger

# View HTML buffers
(let? *Class (isa '+Buffer This)
   (dm view> (Win)
      (=: view T)
      (with Win
         (let
            (Y (- (: posY) 13)
               N (- (length (: buffer text)) 15) )
            (scratch (tmp "html")
               (in (list "w3m" "-cols" *Columns (: buffer file))
                  (rdLines) ) )
            (unless (: buffer view)
               (goto 1 (*/ Y (length (: buffer text)) N)) ) ) ) )
   (dm save> (Win)
      (super Win)
      (when (: view)
         (view> This Win) ) ) )
