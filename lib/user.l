# 18jul19 Software Lab. Alexander Burger

(must "User Administration" UserAdmin (== *Login *ID))

(menu ,"User Administration"
   (idForm ,"User" '(choUser) 'nm '+User
      '(or (may UserAdmin) (== *Login (: home obj)))
      '(or (may Delete) (== *Login (: home obj)))
      '((: nm) )
      (<grid> 2
         ,"Login Name" (gui '(+E/R +Cue +TextField) '(nm : home obj) ,"User" 30)
         ,"Password"
         (gui '(+Able +PasswdField)
            '(or (may Password) (== *Login (: home obj)))
            30 )
         ,"Role"
         (gui '(+Able +E/R +Obj +TextField)
            '(may RoleAdmin)
            '(role : home obj)
            '(nm +Role)
            T )
         ,"Full Name" (gui '(+E/R +TextField) '(nam : home obj) 40)
         ,"Phone" (gui '(+E/R +TelField) '(tel : home obj) 40)
         ,"EMail" (gui '(+E/R +MailField) '(em : home obj) 40) )
      (gui> (: obj) This) ) )
