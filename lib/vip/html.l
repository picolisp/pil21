# 19oct23 Software Lab. Alexander Burger

# View HTML buffers
(let? *Class (isa '+Buffer This)
   (dm view> (Win)
      (=: view T)
      (with Win
         (scratch (tmp "html")
            (in (list "w3m" "-cols" *Columns (: buffer file))
               (rdLines) ) ) ) )
   (dm save> (Win)
      (super Win)
      (when (: view)
         (view> This Win) ) ) )
