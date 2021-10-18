# 18oct21 Software Lab. Alexander Burger

# *Salt *Login *Users *Perms

# crypt(3) algorithm, e.g. (setq *Salt (16 . "$6$@1$"))
(de passwd (Str Salt)
   (if *Salt
      (native "libcrypt.so" "crypt" 'S Str (or Salt (salt)))
      Str ) )

(de salt ()
   (text (cdr *Salt) (randpw (car *Salt))) )

(de randpw (Len)
   (make
      (in "/dev/urandom"
         (do Len
            (link
               (get
                  '`(mapcar char
                     (conc
                        (range (char ".") (char "9"))
                        (range (char "A") (char "Z"))
                        (range (char "a") (char "z")) ) )
                  (inc (& 63 (rd 1))) ) ) ) ) ) )

(de auth (Nm Pw Cls)
   (with (db 'nm (or Cls '+User) Nm)
      (and
         (: pw 0)
         (= @ (passwd Pw @))
         This ) ) )

### Login ###
(de login (Nm Pw Cls)
   (ifn (setq *Login (auth Nm Pw Cls))
      (msg *Pid " ? " Nm)
      (msg *Pid " * " (stamp) " " Nm)
      (tell 'hi *Pid Nm *Adr)
      (push1 '*Bye '(logout))
      (when *Timeout
         (timeout (setq *Timeout `(* 3600 1000))) ) )
   *Login )

(de logout ()
   (when *Login
      (rollback)
      (off *Login)
      (tell 'hi *Pid)
      (msg *Pid " / " (stamp))
      (when *Timeout
         (timeout (setq *Timeout `(* 300 1000))) ) ) )

(de hi (Pid Nm Adr)
   (if (and Nm (= Nm (; *Login nm)) (= Adr *Adr))
      (bye)
      (hi2 Pid Nm)
      (tell 'hi2 *Pid (; *Login nm)) ) )

(de hi2 (Pid Nm)
   (if2 Nm (lup *Users Pid)
      (con @ Nm)
      (idx '*Users (cons Pid Nm) T)
      (idx '*Users @ NIL) ) )


### Role ###
(class +Role +Entity)

(rel nm (+Need +Key +String))          # Role name
(rel perm (+List +Symbol))             # Permission list
(rel usr (+List +Joint) role (+User))  # Associated users

(allow "@lib/role.l")

(dm url> (Tab)
   (and (may RoleAdmin) (list "@lib/role.l" '*ID This)) )


### User ###
(class +User +Entity)

(rel nm (+Need +Key +String))          # User name
(rel pw (+Swap +String))               # Password
(rel role (+Joint) usr (+Role))        # User role
(rel nam (+String))                    # Full Name
(rel tel (+String))                    # Phone
(rel em (+String))                     # E-Mail

(allow "@lib/user.l")

(dm url> (Tab)
   (and
      (or (may UserAdmin) (== *Login This))
      (list "@lib/user.l" '*ID This) ) )

(dm gui> (This)
   (<grid> 2
      ,"Full Name" (gui '(+E/R +TextField) '(nam : home obj) 40)
      ,"Phone" (gui '(+E/R +TelField) '(tel : home obj) 40)
      ,"E-Mail" (gui '(+E/R +MailField) '(em : home obj) 40) ) )

(dm login> ())


### Permission management ###
(de permission Lst
   (while Lst
      (queue '*Perms (car Lst))
      (def (++ Lst) (++ Lst)) ) )

(de may Args
   (mmeq Args (; *Login role perm)) )

(de must Args
   (unless
      (and
         (= *Adr *SesAdr)
         (if (cdr Args)
            (find
               '((X)
                  (if (atom X)
                     (memq X (; *Login role perm))
                     (eval X) ) )
               @ )
            *Login ) )
      (forbidden (car Args)) ) )

### GUI ###
(de choUser (Dst)
   (choDlg Dst ,"Users" '(nm +User)) )

(de loginForm "Opt"
   (form NIL
      (when "Opt"
         (eval (car "Opt"))
         (----) )
      (<grid> 2
         ,"Name" (gui 'nm '(+Focus +Able +TextField) '(not *Login) 20)
         ,"Password" (gui 'pw '(+Able +PwField) '(not *Login) 20) )
      (--)
      (gui '(+Button) '(if *Login ,"logout" ,"login")
         '(cond
            (*Login (post (logout)))
            ((login (val> (: home nm)) (val> (: home pw)))
               (post
                  (clr> (: home pw))
                  (login> *Login) ) )
            (T (error ,"Permission denied")) ) )
      (when *Login
         (<nbsp> 4)
         (<span> "bold green"
            (ht:Prin "'" (; *Login nm) ,"' logged in") ) )
      (when "Opt"
         (----)
         (htPrin (cdr "Opt")) ) ) )

(class +PasswdField +E/R +Fmt +TextField)

(dm T @
   (pass super
      '(pw : home obj)
      '((V) (and V "****"))
      '((V)
         (if (= V "****")
            (: home obj pw 0)
            (passwd V (: home obj pw 0)) ) ) ) )
