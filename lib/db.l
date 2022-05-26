# 26may22 Software Lab. Alexander Burger

# *Jnl *Blob

### Tree Access ###
(de tree (Var Cls Hook)
   (cons Var
      (if Hook
         (cons Cls Hook)
         Cls ) ) )

(de genKey (Var Cls Hook Min Max)
   (if (lt0 Max)
      (let K (minKey (tree Var Cls Hook) Min Max)
         (if (lt0 K) (dec K) (or Max -1)) )
      (let K (maxKey (tree Var Cls Hook) Min Max)
         (if (gt0 K) (inc K) (or Min 1)) ) ) )

(de useKey (Var Cls Hook)
   (let (Tree (tree Var Cls Hook)  Max (* 2 (inc (count Tree)))  N)
      (while (fetch Tree (setq N (rand 1 Max))))
      N ) )

(de genStrKey (Str Var Cls Hook)
   (while (fetch (tree Var Cls Hook) Str)
      (setq Str (pack "# " Str)) )
   Str )

(de ubZval (Lst X)
   (let (Res 0  P 1  Q 1)
      (while (find '((N) (>= N Q)) Lst)
         (for N Lst
            (and
               N
               (bit? Q N)
               (setq Res (| Res P)) )
            (setq P (>> -1 P)) )
         (setq Q (>> -1 Q)) )
      (cons Res X) ) )


### Relations ###
(class +relation)

(dm T (Var)
   (=: cls *Class)
   (=: var Var) )

# Type check
(dm mis> (Val Obj))  #> lst
(dm ele> (Val))

# Value present?
(dm has> (Val X)  #> flg
   (= Val X) )

# Set value
(dm put> (Obj Old New)
   New )

# Delete value
(dm del> (Obj Old Val)
   (and (<> Old Val) Val) )

# Maintain relations
(dm rel> (Obj Old New))

(dm rel?> (Obj Val)
   T )

(dm lose> (Obj Val))

(dm keep> (Obj Val))

# Finalizer
(dm zap> (Obj Val))

(class +Any +relation)

# (+Bag) (cls ..) (..) (..)
(class +Bag +relation)

(dm T (Var Lst)
   (=: bag
      (mapcar
         '((L)
            (prog1
               (new (car L) Var (cdr L))
               (and (get @ 'hook) (=: hook T)) ) )
         Lst ) )
   (super Var) )

(dm mis> (Val Obj)
   (ifn (lst? Val)
      "Not a Bag"
      (pick
         '((This V)
            (mis> This V Obj
               (when (: hook)
                  (get (if (sym? @) Obj Val) (: hook)) ) ) )
         (: bag)
         Val ) ) )

(dm ele> (Val)
   (and Val
      (or
         (atom Val)
         (find 'ele> (: bag) Val) ) ) )

(dm has> (Val X)
   (when Val
      (if (atom Val)
         (find 'has> (: bag) Val X)
         (fully 'has> (: bag) Val X) ) ) )

(dm put> (Obj Old New)
   (trim
      (mapcar
         '((X O N) (put> X Obj O N))
         (: bag)
         Old
         New ) ) )

(dm rel> (Obj Old New)
   (when Old
      (mapc
         '((This O)
            (rel> This Obj O NIL
               (when (: hook)
                  (get (if (sym? @) Obj Old) (: hook)) ) ) )
         (: bag)
         Old ) )
   (when New
      (mapc
         '((This N)
            (rel> This Obj NIL N
               (when (: hook)
                  (get (if (sym? @) Obj New) (: hook)) ) ) )
         (: bag)
         New ) ) )

(dm rel?> (Obj Val)
   (fully
      '((This V)
         (or
            (not V)
            (rel?> This Obj V
               (when (: hook)
                  (get (if (sym? @) Obj Val) (: hook)) ) ) ) )
      (: bag)
      Val ) )

(dm lose> (Obj Val)
   (mapc
      '((This V)
         (lose> This Obj V
            (when (: hook)
               (get (if (sym? @) Obj Val) (: hook)) ) ) )
      (: bag)
      Val ) )

(dm keep> (Obj Val)
   (mapc
      '((This V)
         (keep> This Obj V
            (when (: hook)
               (get (if (sym? @) Obj Val) (: hook)) ) ) )
      (: bag)
      Val ) )


(class +Bool +relation)

(dm mis> (Val Obj)
   (and Val (nT Val) ,"Boolean input expected") )


# (+Number) [num]
(class +Number +relation)

(dm T (Var Lst)
   (=: scl (car Lst))
   (super Var) )

(dm mis> (Val Obj)
   (and Val (not (num? Val)) ,"Numeric input expected") )


# (+Date)
(class +Date +Number)

(dm T (Var Lst)
   (super Var (cons NIL Lst)) )


# (+Time)
(class +Time +Number)

(dm T (Var Lst)
   (super Var (cons NIL Lst)) )


# (+Symbol)
(class +Symbol +relation)

(dm mis> (Val Obj)
   (unless (sym? Val)
      ,"Symbolic type expected" ) )


# (+String)
(class +String +Symbol)

(dm mis> (Val Obj)
   (and Val (not (str? Val)) ,"String type expected") )

(private) canQuery

# (+Link) typ
(class +Link +relation)

(dm T (Var Lst)
   (unless (=: type (car Lst))
      (quit "No Link" Var) )
   (super Var) )

(de canQuery (Val)
   (and
      (pair Val)
      (pair (car Val))
      (fully
         '((L)
            (find
               '((Cls)
                  (get Cls
                     ((if (lst? (car L)) cadr car) L) ) )
               (: type) ) )
         Val ) ) )

(dm mis> (Val Obj)
   (and
      Val
      (nor
         (isa (: type) Val)
         (canQuery Val) )
      ,"Type error" ) )


# (+Joint) var typ [put get]
(class +Joint +Link)

(dm T (Var Lst)
   (=: slot (car Lst))
   (=: put (caddr Lst))
   (=: get (cadddr Lst))
   (super Var (cdr Lst)) )

(dm mis> (Val Obj)
   (and
      Val
      (nor
         (canQuery Val)
         (and
            (isa (: type) Val)
            (with (meta Val (: slot))
               (or
                  (isa '+Link This)
                  (find
                     '((B) (isa '+Link B))
                     (: bag) ) ) ) ) )
      ,"Type error" ) )

(dm rel> (Obj Old New)
   (and Old
      (del> Old (: slot)
         (if (: get)
            (@ Obj (get Old (: slot)))
            Obj ) ) )
   (and New
      (not (get Obj T))
      (not (has> New (: slot) Obj))
      (put> New (: slot)
         (if (: put) (@ Obj) Obj) ) ) )

(dm rel?> (Obj Val)
   (let X (get Val (: slot))
      (cond
         ((atom X) (== Obj X))
         ((: get) (@ Obj X))
         (T (memq Obj X)) ) ) )

(dm lose> (Obj Val)
   (when Val
      (put Val (: slot)
         (del> (meta Val (: slot))
            Obj
            (get Val (: slot))
            (if (: put) (@ Obj) Obj) ) ) ) )

(dm keep> (Obj Val)
   (when Val
      (put Val (: slot)
         (put> (meta Val (: slot))
            Obj
            (get Val (: slot))
            (if (: put) (@ Obj) Obj) ) ) ) )


# +Link or +Joint prefix
(class +Hook)

(dm rel> (Obj Old New Hook)
   (let L
      (extract
         '((X)
            (and (atom X) (setq X (cons T X)))
            (and
               (or
                  (== (: var) (meta Obj (cdr X) 'hook))
                  (find
                     '((B) (== (: var) (get B 'hook)))
                     (meta Obj (cdr X) 'bag) ) )
               X ) )
         (getl Obj) )
      (for X L
         (rel> (meta Obj (cdr X)) Obj (car X) NIL (or Old *DB))
         (rel> (meta Obj (cdr X)) Obj NIL (car X) (or New *DB)) ) )
   (extra Obj Old New Hook) )


# +Index prefix
(class +Hook2)

(dm rel> (Obj Old New Hook)
   (extra Obj Old New *DB)
   (when (or (and Hook (n== Hook *DB)) (and (: hook) (get Obj @)))
      (extra Obj Old New Hook) ) )

(dm lose> (Obj Val Hook)
   (extra Obj Val *DB)
   (when (or (and Hook (n== Hook *DB)) (and (: hook) (get Obj @)))
      (extra Obj Val Hook) ) )

(dm keep> (Obj Val Hook)
   (extra Obj Val *DB)
   (when (or (and Hook (n== Hook *DB)) (and (: hook) (get Obj @)))
      (extra Obj Val Hook) ) )


# (+Blob)
(class +Blob +relation)

(de blob (Obj Var)
   (pack *Blob (glue "/" (chop Obj)) "." Var) )

(dm put> (Obj Old New)
   (and
      New
      (dirname (blob Obj))
      (call "mkdir" "-p" @) )
   (if (flg? New)
      New
      (in New (out (blob Obj (: var)) (echo)))
      T ) )

(dm zap> (Obj Val)
   (and Val (%@ "unlink" NIL (blob Obj (: var)))) )


### Index classes ###
(private) (idxRel? relAux)

(class +index)

(dm T (Var Lst)
   (=: hook (car Lst))
   (extra Var (cdr Lst)) )

(dm rel?> (Obj Val Hook))

# (+Key +relation) [hook]
(class +Key +index)

(dm mis> (Val Obj Hook)
   (or
      (extra Val Obj Hook)
      (and
         Val
         (not (has> Obj (: var) Val))
         (fetch
            (tree (: var) (: cls) (or Hook (and (: hook) (get Obj @))))
            Val )
         ,"Not unique" ) ) )

(dm rel> (Obj Old New Hook)
   (let Tree (tree (: var) (: cls) (or Hook (and (: hook) (get Obj @))))
      (and Old
         (= Obj (fetch Tree Old))
         (store Tree Old NIL (: dbf)) )
      (and New
         (not (get Obj T))
         (not (fetch Tree New))
         (store Tree New Obj (: dbf)) ) )
   (extra Obj Old New Hook) )

(dm rel?> (Obj Val Hook)
   (== Obj
      (fetch
         (tree (: var) (: cls) (or Hook (and (: hook) (get Obj @))))
         Val ) ) )

(dm lose> (Obj Val Hook)
   (store
      (tree (: var) (: cls) (or Hook (and (: hook) (get Obj @))))
      Val NIL (: dbf) )
   (extra Obj Val Hook) )

(dm keep> (Obj Val Hook)
   (store
      (tree (: var) (: cls) (or Hook (and (: hook) (get Obj @))))
      Val Obj (: dbf) )
   (extra Obj Val Hook) )


# (+Ref +relation) [hook]
(class +Ref +index)

(dm rel> (Obj Old New Hook)
   (let
      (Tree (tree (: var) (: cls) (or Hook (and (: hook) (get Obj @))))
         Aux (mapcar '((S) (get Obj S)) (: aux)) )
      (when Old
         (let Key (cons Old Aux)
            (store Tree
               (if (: ub)
                  (ubZval Key Obj)
                  (append Key Obj) )
               NIL
               (: dbf) ) ) )
      (and New
         (not (get Obj T))
         (let Key (cons New Aux)
            (store Tree
               (if (: ub)
                  (ubZval Key Obj)
                  (conc Key Obj) )
               Obj
               (: dbf) ) ) ) )
   (extra Obj Old New Hook) )

(dm rel?> (Obj Val Hook)
   (let Key (cons Val (mapcar '((S) (get Obj S)) (: aux)))
      (== Obj
         (fetch
            (tree (: var) (: cls) (or Hook (and (: hook) (get Obj @))))
            (if (: ub)
               (ubZval Key Obj)
               (append Key Obj) ) ) ) ) )

(dm lose> (Obj Val Hook)
   (let Key (cons Val (mapcar '((S) (get Obj S)) (: aux)))
      (store
         (tree (: var) (: cls) (or Hook (and (: hook) (get Obj @))))
         (if (: ub)
            (ubZval Key Obj)
            (conc Key Obj) )
         NIL
         (: dbf) ) )
   (extra Obj Val Hook) )

(dm keep> (Obj Val Hook)
   (let Key (cons Val (mapcar '((S) (get Obj S)) (: aux)))
      (store
         (tree (: var) (: cls) (or Hook (and (: hook) (get Obj @))))
         (if (: ub)
            (ubZval Key Obj)
            (conc Key Obj) )
         Obj
         (: dbf) ) )
   (extra Obj Val Hook) )


# Backing index prefix
(class +Ref2)

(dm T (Var Lst)
   (unless (meta *Class Var)
      (quit "No Ref2" Var) )
   (extra Var Lst) )

(dm rel> (Obj Old New Hook)
   (with (meta (: cls) (: var))
      (let Tree (tree (: var) (: cls))
         (when Old
            (store Tree (cons Old Obj) NIL (: dbf)) )
         (and New
            (not (get Obj T))
            (store Tree (cons New Obj) Obj (: dbf)) ) ) )
   (extra Obj Old New Hook) )

(dm rel?> (Obj Val Hook)
   (and
      (with (meta (: cls) (: var))
         (== Obj
            (fetch
               (tree (: var) (: cls))
               (cons Val Obj) ) ) )
      (extra Obj Val Hook) ) )

(dm lose> (Obj Val Hook)
   (with (meta (: cls) (: var))
      (store (tree (: var) (: cls)) (cons Val Obj) NIL (: dbf)) )
   (extra Obj Val Hook) )

(dm keep> (Obj Val Hook)
   (with (meta (: cls) (: var))
      (store (tree (: var) (: cls)) (cons Val Obj) Obj (: dbf)) )
   (extra Obj Val Hook) )


# (+Idx +relation) [cnt [hook]]
(class +Idx +Ref)

(dm T (Var Lst)
   (=: min (or (car Lst) 3))
   (super Var (cdr Lst)) )

(de idxRel (Obj Old Old2 Olds New New2 News Hook)
   (let
      (Tree (tree (: var) (: cls) (or Hook (and (: hook) (get Obj @))))
         Aux (mapcar '((S) (get Obj S)) (: aux))
         Aux2 (append Aux (cons Obj)) )
      (setq Aux (conc Aux Obj))
      (and Old (store Tree (cons @ Aux) NIL (: dbf)))
      (and Old2 (store Tree (cons @ Aux2) NIL (: dbf)))
      (for S Olds
         (while (nth S (: min))
            (store Tree (cons (pack S) Aux2) NIL (: dbf))
            (++ S) ) )
      (unless (get Obj T)
         (and New (store Tree (cons @ Aux) Obj (: dbf)))
         (and New2 (store Tree (cons @ Aux2) Obj (: dbf)))
         (for S News
            (while (nth S (: min))
               (store Tree (cons (pack S) Aux2) Obj (: dbf))
               (++ S) ) ) ) ) )

(de idxRel? (Obj Val Val2 Vals Hook)
   (let
      (Tree (tree (: var) (: cls) (or Hook (and (: hook) (get Obj @))))
         Aux (mapcar '((S) (get Obj S)) (: aux))
         Aux2 (append Aux (cons Obj)) )
      (setq Aux (conc Aux Obj))
      (and
         (== Obj (fetch Tree (cons Val Aux)))
         (or (not Val2) (== Obj (fetch Tree (cons Val2 Aux2))))
         (fully
            '((S)
               (loop
                  (NIL (nth S (: min)) T)
                  (NIL (== Obj (fetch Tree (cons (pack S) Aux2))))
                  (++ S) ) )
            Vals ) ) ) )

(dm rel> (Obj Old New Hook)
   (idxRel Obj
      Old NIL (split (cdr (chop Old)) " " "\n")
      New NIL (split (cdr (chop New)) " " "\n")
      Hook )
   (extra Obj Old New Hook) )

(dm rel?> (Obj Val Hook)
   (and
      (idxRel? Obj
         Val NIL (split (cdr (chop Val)) " " "\n")
         Hook )
      (extra Obj Val Hook) ) )

(dm lose> (Obj Val Hook)
   (idxRel Obj
      Val NIL (split (cdr (chop Val)) " " "\n")
      NIL NIL NIL
      Hook )
   (extra Obj Val Hook) )

(dm keep> (Obj Val Hook)
   (idxRel Obj
      NIL NIL NIL
      Val NIL (split (cdr (chop Val)) " " "\n")
      Hook )
   (extra Obj Val Hook) )


# (+Sn +index) [hook]
(class +Sn)

(dm rel> (Obj Old New Hook)
   (let Tree (tree (: var) (: cls) (or Hook (and (: hook) (get Obj @))))
      (and Old
         (ext:Snx Old)
         (store Tree (cons @ Obj T) NIL (: dbf)) )
      (and New
         (not (get Obj T))
         (ext:Snx New)
         (store Tree (cons @ Obj T) Obj (: dbf)) ) )
   (extra Obj Old New Hook) )

(dm rel?> (Obj Val Hook)
   (and
      (let S (ext:Snx Val)
         (or
            (not S)
            (== Obj
               (fetch
                  (tree (: var) (: cls) (or Hook (and (: hook) (get Obj @))))
                  (cons S Obj T) ) ) ) )
      (extra Obj Val Hook) ) )

(dm lose> (Obj Val Hook)
   (let? S (ext:Snx Val)
      (store
         (tree (: var) (: cls) (or Hook (and (: hook) (get Obj @))))
         (cons S Obj T)
         NIL (: dbf) ) )
   (extra Obj Val Hook) )

(dm keep> (Obj Val Hook)
   (let? S (ext:Snx Val)
      (store
         (tree (: var) (: cls) (or Hook (and (: hook) (get Obj @))))
         (cons S Obj T)
         Obj (: dbf) ) )
   (extra Obj Val Hook) )


# (+Fold +index) [hook]
(class +Fold)

(dm has> (Val X)
   (extra Val
      (if (= Val (fold Val)) (fold X) X) ) )

(dm rel> (Obj Old New Hook)
   (extra Obj (fold Old) (fold New) Hook) )

(dm rel?> (Obj Val Hook)
   (let V (fold Val)
      (or (not V) (extra Obj V Hook)) ) )

(dm lose> (Obj Val Hook)
   (extra Obj (fold Val) Hook) )

(dm keep> (Obj Val Hook)
   (extra Obj (fold Val) Hook) )


# (+IdxFold +relation) [cnt [hook]]
(class +IdxFold +Ref)

(dm T (Var Lst)
   (=: min (or (car Lst) 3))
   (super Var (cdr Lst)) )

(dm rel> (Obj Old New Hook)
   (idxRel Obj
      Old (fold Old)
      (extract '((L) (extract fold L))
         (split (cdr (chop Old)) " " "\n") )
      New (fold New)
      (extract '((L) (extract fold L))
         (split (cdr (chop New)) " " "\n") )
      Hook )
   (extra Obj Old New Hook) )

(dm rel?> (Obj Val Hook)
   (and
      (let V (fold Val)
         (or (not V)
            (idxRel? Obj
               Val V
               (extract '((L) (extract fold L))
                  (split (cdr (chop Val)) " " "\n") )
               Hook ) ) )
      (extra Obj Val Hook) ) )

(dm lose> (Obj Val Hook)
   (idxRel Obj
      Val (fold Val)
      (extract '((L) (extract fold L))
         (split (cdr (chop Val)) " " "\n") )
      NIL NIL NIL
      Hook )
   (extra Obj Val Hook) )

(dm keep> (Obj Val Hook)
   (idxRel Obj
      NIL NIL NIL
      Val (fold Val)
      (extract '((L) (extract fold L))
         (split (cdr (chop Val)) " " "\n") )
      Hook )
   (extra Obj Val Hook) )


# (+Aux) lst
(class +Aux)

(dm T (Var Lst)
   (=: aux (car Lst))
   (with *Class
      (for A (car Lst)
         (if (asoq A (: Aux))
            (queue '@ Var)
            (queue (:: Aux) (list A Var)) ) ) )
   (extra Var (cdr Lst)) )

(de relAux (Obj Var Old Lst)
   (let New (get Obj Var)
      (put Obj Var Old)
      (for A Lst
         (rel> (meta Obj A) Obj (get Obj A) NIL) )
      (put Obj Var New)
      (for A Lst
         (rel> (meta Obj A) Obj NIL (get Obj A)) ) ) )


# UB-Tree (+Aux prefix)
(class +UB)

(dm T (Var Lst)
   (=: ub T)
   (extra Var Lst) )

(dm has> (Val X)
   (and Val
      (or
         (extra Val X)
         (extra
            (let (N (inc (length (: aux)))  M 1  V 0)
               (while (gt0 Val)
                  (and (bit? 1 Val) (inc 'V M))
                  (setq M (>> -1 M)  Val (>> N Val)) )
               V )
            X ) ) ) )


### Relation prefix classes ###
(class +Dep)

(dm T (Var Lst)
   (=: dep (car Lst))
   (extra Var (cdr Lst)) )

(dm rel> (Obj Old New Hook)
   (unless New
      (for Var (: dep)
         (let? V (get Obj Var)
            (rel> (meta Obj Var) Obj V
               (put Obj Var (put> (meta Obj Var) Obj V NIL)) )
            (when (asoq Var (meta Obj 'Aux))
               (relAux Obj Var V (cdr @)) )
            (upd> Obj Var V) ) ) )
   (extra Obj Old New Hook) )


(class +List)

(dm mis> (Val Obj)
   (ifn (lst? Val)
      "Not a List"
      (pick '((V) (extra V Obj)) Val) ) )

(dm ele> (Val)
   (and Val (or (atom Val) (find extra Val))) )

(dm has> (Val X)
   (when Val
      (or
         (= Val X)
         (find '((X) (extra Val X)) X)
         (loop
            (NIL
               (let (V (++ Val)  Y (++ X))
                  (or (= V Y) (extra V Y)) ) )
            (NIL (or Val X) T)
            (T (xor Val X)) ) ) ) )

(dm put> (Obj Old New)
   (if (ele> This New)
      (cons (extra Obj Old New) Old)
      (mapcar
         '((N O) (extra Obj O N))
         New
         Old ) ) )

(dm del> (Obj Old Val)
   (and
      (<> Old Val)
      (delete Val Old T) ) )

(dm rel> (Obj Old New Hook)
   (if (or (ele> This Old) (ele> This New))
      (extra Obj Old New Hook)
      (for O Old
         (if (: bag)
            (for (I . This) @
               (let V (get O I)
                  (unless (find '((L) (= V (get L I))) New)
                     (rel> This Obj V NIL
                        (when (: hook)
                           (get (if (sym? @) Obj O) (: hook)) ) ) ) ) )
            (unless (member O New)
               (extra Obj O NIL Hook) ) ) )
      (for N New
         (if (: bag)
            (for (I . This) @
               (let V (get N I)
                  (unless (find '((L) (= V (get L I))) Old)
                     (rel> This Obj NIL V
                        (when (: hook)
                           (get (if (sym? @) Obj N) (: hook)) ) ) ) ) )
            (unless (member N Old)
               (extra Obj NIL N Hook) ) ) ) ) )

(dm rel?> (Obj Val Hook)
   (for V Val
      (NIL (or (not V) (extra Obj V Hook)))
      T ) )

(dm lose> (Obj Val Hook)
   (if (ele> This Val)
      (extra Obj Val Hook)
      (for V Val
         (extra Obj V Hook) ) ) )

(dm keep> (Obj Val Hook)
   (if (ele> This Val)
      (extra Obj Val Hook)
      (for V Val
         (extra Obj V Hook) ) ) )


(class +Need)

(dm mis> (Val Obj)
   (ifn Val
      ,"Input required"
      (extra Val Obj) ) )


(class +Mis)

(dm T (Var Lst)
   (=: mis (car Lst))
   (extra Var (cdr Lst)) )

(dm mis> (Val Obj)
   (or ((: mis) Val Obj) (extra Val Obj)) )


(class +Alt)

(dm T (Var Lst)
   (extra Var (cdr Lst))
   (=: cls (car Lst)) )


(class +Swap)

(dm mis> (Val Obj)
   (extra (if (ext? Val) (val Val) Val) Obj) )

(dm has> (Val X)
   (if (ext? Val)
      (== Val X)
      (extra Val (val X)) ) )

(dm put> (Obj Old New)
   (setq New
      (extra
         Obj
         (val Old)
         (if (ext? New) (val @) New) ) )
   (cond
      ((ext? Old) (set @ New) @)
      (New
         (prog1
            (new (or (: dbf 1) 1))
            (set @ New) ) ) ) )

(dm del> (Obj Old Val)
   (ifn (ext? Old)
      (extra Obj Old Val)
      (set @ (extra Obj (val Old) Val))
      @ ) )

(dm rel> (Obj Old New Hook)
   (extra
      Obj
      (if (ext? Old) (val @) Old)
      (if (ext? New) (val @) New)
      Hook ) )

(dm rel?> (Obj Val Hook)
   (if (ext? Val)
      (if (val @)
         (extra Obj @ Hook)
         T )
      (extra Obj Val Hook) ) )

(dm lose> (Obj Val Hook)
   (extra Obj (if (ext? Val) (val @) Val) Hook) )

(dm keep> (Obj Val Hook)
   (extra Obj (if (ext? Val) (val @) Val) Hook) )


### Entities ###
(de dbSync (Obj)
   (let *Run NIL
      (while (lock (or Obj *DB))
         (wait 40) )
      (sync) ) )

(class +Entity)

(var Dbf)
(var Aux)

(de incECnt (Obj)
   (let M NIL
      (for Cls (type Obj)
         (recur (Cls)
            (or
               (== '+Entity Cls)
               (memq Cls M)
               (when (isa '+Entity (push 'M Cls))
                  (for C (type @)
                     (recurse C) )
                  (if (get *DB Cls)
                     (inc @)
                     (put *DB Cls (new T 1)) ) ) ) ) ) ) )

(de decECnt (Obj)
  (let M NIL
     (for Cls (type Obj)
        (recur (Cls)
           (or
              (== '+Entity Cls)
              (memq Cls M)
              (when (isa '+Entity (push 'M Cls))
                 (for C (type @)
                    (recurse C) )
                 (and (get *DB Cls) (dec @)) ) ) ) ) ) )

(private) (cloneKey cloneAny)

(dm T @
   (incECnt This)
   (while (args)
      (let A (next)
         (cond
            ((=T A) (put This T T))
            ((atom A) (put> This A (next)))
            (T (put> This (car A) (eval (cdr A)))) ) ) )
   (upd> This (val This)) )

(dm zap> ()
   (for X (getl This)
      (let V (or (atom X) (++ X))
         (and (meta This X) (zap> @ This V)) ) )
   (unless (: T) (decECnt This)) )

(dm url> (Tab Fld))

(dm url1> (Tab Fld) (url> This 1 Fld))
(dm url2> (Tab Fld) (url> This 2 Fld))
(dm url3> (Tab Fld) (url> This 3 Fld))
(dm url4> (Tab Fld) (url> This 4 Fld))
(dm url5> (Tab Fld) (url> This 5 Fld))
(dm url6> (Tab Fld) (url> This 6 Fld))
(dm url7> (Tab Fld) (url> This 7 Fld))
(dm url8> (Tab Fld) (url> This 8 Fld))
(dm url9> (Tab Fld) (url> This 9 Fld))

(dm gui> ())

(dm upd> (X Old))

(dm has> (Var Val)
   (or
      (nor
         Val
         (if2 (get This Var) (ext? @) (val @) @) )
      (has> (meta This Var) Val (get This Var)) ) )

(dm rel?> (Var Val)
   (nond
      (Val T)
      ((meta This Var) T)
      (NIL (rel?> @ This Val)) ) )

(dm put> (Var Val)
   (unless (has> This Var Val)
      (let Old (get This Var)
         (rel> (meta This Var) This Old
            (put This Var (put> (meta This Var) This Old Val)) )
         (when (asoq Var (meta This 'Aux))
            (relAux This Var Old (cdr @)) )
         (upd> This Var Old) ) )
   Val )

(dm put!> (Var Val)
   (unless (has> This Var Val)
      (dbSync)
      (let Old (get This Var)
         (rel> (meta This Var) This Old
            (put This Var (put> (meta This Var) This Old Val)) )
         (when (asoq Var (meta This 'Aux))
            (relAux This Var Old (cdr @)) )
         (upd> This Var Old)
         (commit 'upd) ) )
   Val )

(dm del> (Var Val)
   (when (and Val (has> (meta This Var) Val (get This Var)))
      (let Old (get This Var)
         (rel> (meta This Var) This Old
            (put This Var (del> (meta This Var) This Old Val)) )
         (when (asoq Var (meta This 'Aux))
            (relAux This Var Old (cdr @)) )
         (upd> This Var Old) ) ) )

(dm del!> (Var Val)
   (when (and Val (has> (meta This Var) Val (get This Var)))
      (dbSync)
      (let Old (get This Var)
         (rel> (meta This Var) This Old
            (put This Var (del> (meta This Var) This Old Val)) )
         (when (asoq Var (meta This 'Aux))
            (relAux This Var Old (cdr @)) )
         (upd> This Var Old)
         (commit 'upd) ) ) )

(dm inc> (Var Val)
   (let P (prop This Var)
      (when (num? (car P))
         (let Old @
            (rel> (meta This Var) This Old
               (inc P (or Val 1)) )
            (when (asoq Var (meta This 'Aux))
               (relAux This Var Old (cdr @)) )
            (upd> This Var Old) )
         (car P) ) ) )

(dm inc!> (Var Val)
   (when (num? (get This Var))
      (dbSync)
      (let (P (prop This Var)  Old (car P))
         (rel> (meta This Var) This Old
            (inc P (or Val 1)) )
         (when (asoq Var (meta This 'Aux))
            (relAux This Var Old (cdr @)) )
         (upd> This Var Old)
         (commit 'upd)
         (car P) ) ) )

(dm dec> (Var Val)
   (let P (prop This Var)
      (when (num? (car P))
         (let Old @
            (rel> (meta This Var) This Old
               (dec P (or Val 1)) )
            (when (asoq Var (meta This 'Aux))
               (relAux This Var Old (cdr @)) )
            (upd> This Var Old) )
         (car P) ) ) )

(dm dec!> (Var Val)
   (when (num? (get This Var))
      (dbSync)
      (let (P (prop This Var)  Old (car P))
         (rel> (meta This Var) This Old
            (dec P (or Val 1)) )
         (when (asoq Var (meta This 'Aux))
            (relAux This Var Old (cdr @)) )
         (upd> This Var Old)
         (commit 'upd)
         (car P) ) ) )

(dm mis> (Var Val)
   (mis> (meta This Var) Val This) )

(dm lose1> (Var)
   (when (meta This Var)
      (lose> @ This (get This Var)) ) )

(dm lose> (Lst)
   (unless (: T)
      (for X (getl This)
         (let V (or (atom X) (++ X))
            (and
               (not (memq X Lst))
               (meta This X)
               (lose> @ This V) ) ) )
      (decECnt This)
      (=: T T)
      (upd> This) ) )

(dm lose!> (Lst)
   (dbSync)
   (lose> This Lst)
   (commit 'upd) )

(de lose "Prg"
   (let "Flg" (: T)
      (=: T T)
      (run "Prg")
      (=: T "Flg") ) )

(dm keep1> (Var)
   (when (meta This Var)
      (keep> @ This (get This Var)) ) )

(dm keep> (Lst)
   (when (: T)
      (=: T)
      (incECnt This)
      (for X (getl This)
         (let V (or (atom X) (++ X))
            (and
               (not (memq X Lst))
               (meta This X)
               (keep> @ This V) ) ) )
      (upd> This T) ) )

(dm keep?> (Lst)
   (extract
      '((X)
         (with (and (pair X) (meta This (cdr X)))
            (and
               (isa '+Key This)
               (fetch (tree (: var) (: cls) (and (: hook) (get (up This) @))) (car X))
               (cons (car X) ,"Not unique") ) ) )
      (getl This) ) )

(dm keep!> (Lst)
   (dbSync)
   (keep> This Lst)
   (commit 'upd) )

(de keep "Prg"
   (let "Flg" (: T)
      (=: T)
      (run "Prg")
      (=: T "Flg") ) )

(dm set> (Val)
   (unless (= Val (val This))
      (decECnt This)
      (let Lst (make (maps '((X) (link (fin X))) This))
         (for Var Lst
            (let? Rel (meta This Var)
               (unless (== Rel (meta Val Var))
                  (let V (get This Var)
                     (and (isa '+Swap Rel) (setq V (val V)))
                     (rel> Rel This V (put> Rel This V NIL)) ) ) ) )
         (xchg This 'Val)
         (for Var Lst
            (let? Rel (meta This Var)
               (unless (== Rel (meta Val Var))
                  (let V (get This Var)
                     (rel> Rel This NIL
                        (put> Rel This NIL
                           (if (isa '+Swap Rel) (val V) V) ) ) ) ) ) ) )
      (incECnt This)
      (upd> This (val This) Val) )
   (val This) )

(dm set!> (Val)
   (unless (= Val (val This))
      (dbSync)
      (decECnt This)
      (let Lst (make (maps '((X) (link (fin X))) This))
         (for Var Lst
            (let? Rel (meta This Var)
               (unless (== Rel (meta Val Var))
                  (let V (get This Var)
                     (and (isa '+Swap Rel) (setq V (val V)))
                     (rel> Rel This V (put> Rel This V NIL)) ) ) ) )
         (xchg This 'Val)
         (for Var Lst
            (let? Rel (meta This Var)
               (unless (== Rel (meta Val Var))
                  (let V (get This Var)
                     (rel> Rel This NIL
                        (put> Rel This NIL
                           (if (isa '+Swap Rel) (val V) V) ) ) ) ) ) ) )
      (incECnt This)
      (upd> This (val This) Val)
      (commit 'upd) )
   (val This) )

(dm clone> (Lst)
   (let Obj (new (or (var: Dbf 1) 1) (val This))
      (for X
         (by
            '((X)
               (nand
                  (pair X)
                  (isa '+Hook (meta This (cdr X))) ) )
            sort
            (getl This) )
         (unless (memq (fin X) Lst)
            (if (atom X)
               (ifn (meta This X)
                  (put Obj X T)
                  (let Rel @
                     (put> Obj X T)
                     (when (isa '+Blob Rel)
                        (in (blob This X)
                           (out (blob Obj X) (echo)) ) ) ) )
               (ifn (meta This (cdr X))
                  (put Obj (cdr X) (car X))
                  (let Rel @
                     (cond
                        ((find '((B) (isa '+Key B)) (get Rel 'bag))
                           (let (K @  H (get K 'hook))
                              (put> Obj (cdr X)
                                 (mapcar
                                    '((Lst)
                                       (mapcar
                                          '((B Val)
                                             (if (== B K)
                                                (cloneKey B (cdr X) Val
                                                   (and H (get (if (sym? H) This Lst) H)) )
                                                Val ) )
                                          (get Rel 'bag)
                                          Lst ) )
                                    (car X) ) ) ) )
                        ((isa '+Key Rel)
                           (put> Obj (cdr X)
                              (cloneKey Rel (cdr X) (car X)
                                 (and (get Rel 'hook) (get This @)) ) ) )
                        ((or (not (isa '+Joint Rel)) (isa '+List (meta Obj (cdr X))))
                           (put> Obj (cdr X) (cloneAny (car X) Rel)) ) ) ) ) ) ) )
      Obj ) )

(de cloneKey (Rel Var Val Hook)
   (cond
      ((isa '+Number Rel)
         (genKey Var (get Rel 'cls) Hook) )
      ((isa '+String Rel)
         (genStrKey (pack "# " Val) Var (get Rel 'cls) Hook) ) ) )

(de cloneAny (Val Rel)
   (cond
      ((isa '+Swap Rel) (val Val))
      ((isa '+Bag Rel)
         (if (isa '+List Rel)
            (mapcar
               '((B) (mapcar cloneAny B (; Rel bag)))
               Val )
            (mapcar cloneAny Val (; Rel bag)) ) )
      (T Val) ) )

(dm clone!> ()
   (prog2
      (dbSync)
      (clone> This)
      (commit 'upd) ) )

(de new! ("Typ" . @)
   (prog2
      (dbSync)
      (pass new (or (meta "Typ" 'Dbf 1) 1) "Typ")
      (commit 'upd) ) )

(de set! (Obj Val)
   (unless (= Val (val Obj))
      (dbSync)
      (set Obj Val)
      (commit 'upd) )
   Val )

(de put! (Obj Var Val)
   (unless (= Val (get Obj Var))
      (dbSync)
      (put Obj Var Val)
      (commit 'upd) )
   Val )

(de inc! (Obj Var Val)
   (when (num? (get Obj Var))
      (prog2
         (dbSync)
         (inc (prop Obj Var) (or Val 1))
         (commit 'upd) ) ) )

(de blob! (Obj Var File)
   (put!> Obj Var File)
   (blob+ Obj Var)
   File )

(de blob+ (Obj Var)
   (when *Jnl
      (chdir *Blob
         (%@ "symlink" 'I
            (pack (glue "/" (chop Obj)) "." Var)
            (pack "=" (name Obj) "." Var) ) ) ) )


# Remote entities
(class +Remote)

(dm zap> ())
(dm has> ~(method 'has> '+Entity))
(dm url> (Tab Fld))
(dm url1> ~(method 'url1> '+Entity))
(dm url2> ~(method 'url2> '+Entity))
(dm url3> ~(method 'url3> '+Entity))
(dm url4> ~(method 'url4> '+Entity))
(dm url5> ~(method 'url5> '+Entity))
(dm url6> ~(method 'url6> '+Entity))
(dm url7> ~(method 'url7> '+Entity))
(dm url8> ~(method 'url8> '+Entity))
(dm url9> ~(method 'url9> '+Entity))
(dm put> (Var Val))
(dm put!> (Var Val))
(dm del> (Var Val))
(dm del!> (Var Val))
(dm inc> (Var Val))
(dm inc!> (Var Val))
(dm dec> (Var Val))
(dm dec!> (Var Val))
(dm mis> (Var Val))
(dm lose1> (Var))
(dm lose> (Lst))
(dm lose!> (Lst))
(dm keep1> (Var))
(dm keep> (Lst))
(dm keep?> (Lst))
(dm keep!> (Lst))
(dm set> (Val))
(dm set!> (Val))


# Default syncronization function
(de upd Lst
   (wipe Lst) )

### DB Sizes ###
(de dbs Lst
   (setq *Dbs
      (make
         (for (N . L) Lst
            (let Dbf (cons N (>> (- (link (car L))) 64))
               (for Cls (cdr L)
                  (if (atom Cls)
                     (put Cls 'Dbf Dbf)
                     (for Var (cdr Cls)
                        (let Rel (get Cls 1 Var)
                           (unless Rel
                              (quit "Bad relation" (cons Var (car Cls))) )
                           (when (or (isa '+index Rel) (isa '+Swap Rel))
                              (put @ 'dbf Dbf) )
                           (for B (; Rel bag)
                              (when (or (isa '+index B) (isa '+Swap B))
                                 (put @ 'dbf Dbf)) ) ) ) ) ) ) ) ) ) )

(de db: Typ
   (or (meta Typ 'Dbf 1) 1) )

### Utilities ###
(private) _db

(de treeRel (Var Cls)
   (with (or (get Cls Var) (meta Cls Var))
      (or
         (find '((B) (isa '+index B)) (: bag))
         This ) ) )

# (db 'var 'cls ['hook] 'any ['var 'any ..]) -> sym
(de db (Var Cls . @)
   (with (treeRel Var Cls)
      (let (Tree (tree (: var) (: cls) (and (: hook) (next)))  Val (next))
         (if (isa '+Key This)
            (if (args)
               (and (fetch Tree Val) (pass _db @))
               (fetch Tree Val) )
            (let Key (cons (if (isa '+Fold This) (fold Val) Val))
               (let? A (: aux)
                  (while (and (args) (== (++ A) (arg 1)))
                     (next)
                     (queue 'Key (next)) )
                  (and (: ub) (setq Key (ubZval Key))) )
               (let Q (init Tree Key (append Key T))
                  (loop
                     (NIL (step Q T))
                     (T (pass _db @ Var Val) @) ) ) ) ) ) ) )

(de _db (Obj . @)
   (when (isa Cls Obj)
      (loop
         (NIL (next) Obj)
         (NIL (has> Obj @ (next))) ) ) )

# (aux 'var 'cls ['hook] 'any ..) -> sym
(de aux (Var Cls . @)
   (with (treeRel Var Cls)
      (let Key (if (: ub) (ubZval (rest)) (rest))
         (step
            (init (tree (: var) (: cls) (and (: hook) (next)))
               Key
               (append Key T) ) ) ) ) )

# (collect 'var 'cls ['hook] ['any|beg ['end [var ..]]]) -> lst
(de collect (Var Cls . @)
   (with (treeRel Var Cls)
      (let
         (Tree (tree (: var) (: cls) (and (: hook) (next)))
            X1 (next)
            X2 (if (args) (next) (or X1 T)) )
         (make
            (cond
               ((isa '+Key This)
                  (iter Tree
                     '((X) (and (isa Cls X) (link (pass get X))))
                     X1 X2 ) )
               ((: ub)
                  (if X1
                     (ubIter Tree (inc (length (: aux)))
                        '((X) (and (isa Cls X) (link (pass get X))))
                        X1 X2 )
                     (iter Tree
                        '((X) (and (isa Cls X) (link (pass get X)))) ) ) )
               (T
                  (when (isa '+Fold This)
                     (setq X1 (fold X1)  X2 (or (=T X2) (fold X2))) )
                  (if (>= X2 X1)
                     (if (pair X1)
                        (setq X2 (append X2 T))
                        (setq X1 (cons X1)  X2 (cons X2 T)) )
                     (if (pair X1)
                        (setq X1 (append X1 T))
                        (setq X1 (cons X1 T)  X2 (cons X2)) ) )
                  (iter Tree
                     '((X)
                        (and (isa Cls X) (link (pass get X))) )
                     X1 X2
                     (or (isa '+Idx This) (isa '+IdxFold This)) ) ) ) ) ) ) )

# Iterate all objects of given class
(de forall (X . Prg)
   (for
      (This
         (seq
            (or
               (and (pair X) (car @))
               (; X Dbf 1)
               (meta X 'Dbf 1)
               1 ) )
         This
         (seq This) )
      (and (isa (fin X) This) (run Prg 1)) ) )

# Define object variables as relations
(de rel Lst
   (def *Class
      (car Lst)
      (new (cadr Lst) (car Lst) (cddr Lst)) ) )

# Find or create object
(de request (Typ Var . @)
   (let Dbf (or (meta Typ 'Dbf 1) 1)
      (ifn Var
         (new Dbf Typ)
         (with (meta Typ Var)
            (or
               (pass db Var (: cls))
               (if (: hook)
                  (pass new Dbf Typ @ (next) Var)
                  (pass new Dbf Typ Var) ) ) ) ) ) )

(de request! (Typ Var . @)
   (prog2
      (dbSync)
      (pass request Typ Var)
      (commit 'upd) ) )

# Create or update object
(private) *ObjIdx

(de obj Lst
   (let Obj
      (let L (++ Lst)
         (if (pair (car L))
            (apply request L)
            (cache '*ObjIdx (++ Lst)
               (new (or (meta L 'Dbf 1) 1) L) ) ) )
      (while Lst
         (let (K (++ Lst)  V (++ Lst))
            (if (=T K)
               (lose> Obj)
               (put> Obj K V) ) ) )
      Obj ) )

# Create or update lots of objects
(de create (Typ Key Vars . Prg)
   (prune 0)
   (gc 200 200)
   (setq Vars  # ((var fd lst cnt . cnt) ..)
      (mapcar
         '((Var)
            (if (isa '+index (meta Typ Var))
               (cons Var
                  (open (tmp (pack "create-" Var)))
                  NIL 0 1000000 )
               Var ) )
         Vars ) )
   (while (run Prg)  # (val ..)
      (let (Lst @  Obj (or (fin Lst) (new (meta Typ 'Dbf 1) Typ)))
         (and Key (++ Lst) (put> Obj Key @))
         (let store '((Tree Key Val Dbf) (link Key))
            (mapc
               '((V Val)
                  (when Val
                     (if (atom V)
                        (put> Obj V Val)
                        (out (cadr V)
                           (for Key (make (put> Obj (car V) Val))
                              (at (cdddr V) (push (cddr V) Key))
                              (pr Key Obj) ) ) ) ) )
               Vars
               Lst ) ) )
      (at (0 . 1000000) (commit) (prune 2)) )
   (commit)
   (prune 0)
   (let Lst
      (mapcan
         '((V)
            (unless (atom V)
               (close (cadr V))
               (let (Var (car V)  File (tmp (pack "create-" Var)))
                  (later (cons)
                     (off Vars)
                     (gc 0 100)
                     (setq V
                        (mapcar
                           '((Key)
                              (let F (tmp (pack "create-" (inc (0))))
                                 (cons Key F
                                    (or (open F) (quit "Too many files")) ) ) )
                           (cons NIL (sort (caddr V))) ) )
                     (in File
                        (while (setq Key (rd))
                           (out (cddr (rank Key V))
                              (pr Key (rd)) ) ) )
                     (%@ "unlink" NIL File)
                     (let (Dbf (meta Typ Var 'dbf)  Tree (cons Var (new T)))
                        (for R V
                           (close (cddr R))
                           (for X
                              (sort
                                 (make
                                    (in (cadr R)
                                       (while (rd)
                                          (link (cons @ (rd))) ) ) ) )
                              (store Tree (car X) (cdr X) Dbf)
                              (at (0 . 1000) (prune 2)) )
                           (commit)
                           (prune 2)
                           (%@ "unlink" NIL (cadr R)) )
                        (commit)
                        Tree ) ) ) ) )
         Vars )
      (off Vars)
      (prune)
      (gc 0)
      (wait NIL (full Lst))
      (for Tree Lst
         (let
            (Base (get *DB (meta Typ (car Tree) 'cls))
               Root (get (cdr Tree) (car Tree)) )
            (ifn (get Base (car Tree))
               (put Base (car Tree) Root)
               (touch Base)
               (inc @ (car Root)) ) )
         (zap (cdr Tree)) )
      (commit) ) )

### Debug ###
`*Dbg

(noLint 'create 'store)
