# 18jul19 Software Lab. Alexander Burger

(must "Role Administration" RoleAdmin)

(menu ,"Role Administration"
   (idForm ,"Role" ,"Roles" 'nm '+Role T '(may Delete) '((: nm))
      (gui '(+E/R +Cue +TextField) '(nm : home obj) ,"Role" 30 ,"Name")
      (gui '(+E/R +Fmt +Chart) '(perm : home obj)
         '((Val) (mapcar '((S) (list (memq S Val))) *Perms))
         '((Lst) (filter '((S L) (and (car L) S)) *Perms Lst))
         1 )
      (<table> NIL NIL NIL
         (for This *Perms
            (<row> NIL
               (ht:Prin (: 0 0))
               (gui 1 '(+Checkbox)) ) ) )
      (gui '(+/R +Chart) '(usr : home obj) 1 list)
      (<table> 'chart ,"User" NIL
         (do 8
            (<row> (alternating)
               (gui 1 '(+Obj +TextField) '(nm +User)) ) ) )
      (scroll 8 T) ) )
