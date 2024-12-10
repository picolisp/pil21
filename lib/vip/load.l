# 10dec24 Software Lab. Alexander Burger

# View output of 'load'ing the file
(let? *Class (isa '+Buffer This)
   (dm view> (Win)
      (=: view T)
      (with Win
         (scratch (tmp "xml")
            (pipe (load (: buffer file))
               (rdLines) ) ) ) )
   (dm save> (Win)
      (super Win)
      (when (: view)
         (view> This Win) ) ) )
