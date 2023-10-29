# 29oct23 Software Lab. Alexander Burger

# View HTML buffers
(let? *Class (isa '+Buffer This)
   (dm view> (Win)
      (=: view T)
      (with Win
         (let (Y (: posY)  N (length (: buffer text)))
            (scratch (tmp "html")
               (in (list "w3m" "-cols" *Columns (: buffer file))
                  (rdLines) ) )
            (unless (: buffer view)
               (goto 1 (*/ Y (length (: buffer text)) N)) ) ) ) )
   (dm save> (Win)
      (super Win)
      (when (: view)
         (view> This Win) ) ) )
