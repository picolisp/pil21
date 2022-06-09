# 09jun22 Software Lab. Alexander Burger

# *PRG *Top *Gui *Btn *Get *Got *Form *FormIx *FormLst *Evt *Lock *Spans

(private) (*Chart *App *Ix *Err *Foc *Post2 *Stat *Cho *TZO)

(allow "@img/" T)
(push1 '*JS (allow "@lib/form.js"))  #! @lib
(mapc allow
   (quote
      *Gui *Get *Got *Form "!jsForm" *Evt *Drop
      *JsHint "!jsHint" jsUp jsDn *JsArgs "!tzOffs" ) )

(default *FormIx 1)

(de *Go.png . "@img/go.png")
(de *No.png . "@img/no.png")

(de *Throbber
   ("+---" "-+--" "--+-" "---+" "--+-" "-+--" .) )

(de tzOffs (Min)
   (setq *TZO (* Min 60))
   (respond) )

(private) (Attr Prg App Lst F L)

# Define GUI form
(de form (Attr . Prg)
   (inc '*Form)
   (let App
      (if *PRG
         (get *FormLst (- *FormIx *Get) *Form)
         (prog1
            (setq *Top (new NIL NIL 'able T 'evt 0))
            ~(as *Dbg
               (when (file)
                  (put *Top '*Dbg
                     (list (cons (cddr @) (pack (car @) (cadr @)))) ) ) )
            (put *Top 'home *Top)
            (queue (nth *FormLst (- *FormIx *Get)) *Top) ) )
      (let Lst (get *FormLst (- *FormIx *Get) 1)
         (for (F . L) Lst
            (let *Form (- F (length Lst))
               (cond
                  ((and (== *PRG (car L)) (memq App (get *PRG 'top)))
                     (apply "form" L) )
                  ((or (== *PRG App) (memq App (get *PRG 'top)))
                     (if (get L 1 'top)
                        (apply "form" L)
                        (put (car L) 'top (cons *PRG (get *PRG 'top)))
                        (let *PRG NIL (apply "form" L)) ) ) ) ) ) )
      ("form" App Attr Prg) ) )

(de "form" (*App Attr Prg)
   (with *App
      (job (: env)
         (<post> Attr (urlMT *Url *Menu *Tab *ID)
            (<hidden> '*Get *Get)
            (<hidden> '*Form *Form)
            (<hidden> '*Evt (: evt))
            (zero *Ix)
            (if *PRG
               (let gui
                  '(()
                     (with (get *App 'gui (inc '*Ix))
                        (for E *Err
                           (when (== This (car E))
                              (<div> 'error
                                 (if (atom (cdr E))
                                    (ht:Prin (eval (cdr E) 1))
                                    (eval (cdr E) 1) ) ) ) )
                        (if (: id)
                           (let *Gui (val *App)
                              (show> This (cons '*Gui @)) )
                           (setq *Chart This) )
                        This ) )
                  (and (== *PRG *App) (setq *Top *App))
                  (htPrin Prg) )
               (set *App)
               (let gui
                  '((X . @)
                     (inc '*Ix)
                     (with
                        (cond
                           ((pair X) (pass new X))
                           ((not X) (pass new))
                           ((num? X)
                              (ifn *Chart
                                 (quit "no chart" (rest))
                                 (with *Chart
                                    (let L (last (: gui))
                                       (when (get L X)
                                          (inc (:: rows))
                                          (queue (:: gui) (setq L (need (: cols)))) )
                                       (let Fld (pass new)
                                          (set (nth L X) Fld)
                                          (put Fld 'chart (list This (: rows) X))
                                          (and (get Fld 'chg) (get Fld 'able) (=: lock))
                                          (set> Fld
                                             (get
                                                ((: put)
                                                   (get (nth (: data) (: ofs)) (: rows))
                                                   (+ (: ofs) (: rows) -1) )
                                                X )
                                             T )
                                          Fld ) ) ) ) )
                           ((get *App X) (quit "gui conflict" X))
                           (T (put *App X (pass new))) )
                        (queue (:: home gui) This)
                        (unless (: chart) (init> This))
                        (when (: id)
                           (let *Gui (val *App)
                              (show> This (cons '*Gui (: id))) ) )
                        This ) )
                  (htPrin Prg) ) ) )
         (off *Chart)
         (--)
         (and
            (: show)
            (info @)
            (in (: show) (echo)) ) ) ) )

# Disable form
(de disable (Flg)
   (and Flg (=: able)) )

(private) Prg

# Handle form actions
(de action Prg
   (off *Chart *Foc)
   (or *PRG *Post2 (off *Err))
   (catch 'stop
      (nond
         (*Post
            (unless (and *PRG (= *Form (car *Got)) (= *Get (cadr *Got)))
               (pushForm (cons)) )
            (if *Port%
               (let *JS NIL (_doForm))
               (_doForm) )
            (off *PRG *Got) )
         (*PRG
            (with (postForm)
               (ifn (= *Evt (: evt))
                  (noContent)
                  (postGui)
                  (redirect
                     (baseHRef)
                     *SesId
                     (urlMT *Url *Menu *Tab *ID)
                     "&*Evt=+" (inc (:: evt))
                     "&*Got=_+" *Form "_+" *Get ) ) ) )
         (NIL
            (off *PRG)
            (pushForm (cons))
            (_doForm) ) ) ) )

(de pushForm (L)
   (push '*FormLst L)
   (and (nth *FormLst 99) (con @))
   (setq *Get *FormIx)
   (inc '*FormIx) )

(de _doForm ()
   (one *Form)
   (run Prg)
   (setq *Stat
      (cons
         (pair *Err)
         (copy (get *FormLst (- *FormIx *Get))) ) ) )

(de jsForm (Url)
   (if (or *PRG (not *Post))
      (noContent)
      (setq *Url Url  Url (chop Url))
      (let action
         '(Prg
            (off *Err)
            (with (postForm)
               (catch 'stop
                  (postGui)
                  (httpHead "text/plain; charset=utf-8")
                  (if
                     (and
                        (= (car *Stat) *Err)
                        (= (cdr *Stat) (get *FormLst (- *FormIx *Get))) )
                     (ht:Out *Chunked
                        (when (: auto)
                           (prin "i" *Form "-" (: auto 1 id) ":" (: auto -1))
                           (=: auto) )
                        (for S *Spans
                           (prin "&" (car S) "&" (run (cdr S))) )
                        (for This (: gui)
                           (if (: id)
                              (prin "&i" *Form "-" @ "&" (js> This))
                              (setq *Chart This) ) ) )
                     (setq *Post2 (cons *Get *Form *PRG))
                     (ht:Out *Chunked (prin T)) ) ) )
            (off *PRG) )
         (use @X
            (cond
               ((match '("-" @X "." "h" "t" "m" "l") Url)
                  (try 'html> (extern (ht:Pack @X T))) )
               ((disallowed)
                  (notAllowed *Url)
                  (http404) )
               ((= "!" (car Url))
                  ((intern (pack (cdr Url)))) )
               ((tail '("." "l") Url)
                  (load *Url) ) ) ) ) ) )

(de postForm ()
   (when (num? (format *Get))
      (let? Lst (get *FormLst (- *FormIx (setq *Get @)))
         (and
            (setq *Form (format *Form))
            (setq *Evt (format *Evt))
            (setq *PRG
               (cond
                  ((and
                        (= *Get (car *Post2))
                        (= *Form (cadr *Post2)) )
                     (cddr *Post2) )
                  ((off *Post2))
                  ((gt0 *Form) (get Lst *Form))
                  (T (get Lst 1 (+ (length (car Lst)) *Form) 1)) ) )
            (val *PRG)
            *PRG ) ) ) )

(de postGui ()
   (if *Post2
      (off *Gui *Post2)
      (let ("Fun" NIL *Btn NIL)
         (for G *Gui
            (if (=0 (car G))
               (setq "Fun" (cdr G))
               (and (lt0 (car G)) (setq *Btn (cdr G)))
               (con (assoc (car G) (val *PRG)) (cdr G)) ) )
         (off *Gui)
         (and (: lock) (n== @ *Lock) (=: able))
         (job (: env)
            (for This (: gui)
               (cond
                  ((not (: id)) (setq *Chart This))
                  ((chk> This) (error @))
                  ((or (: rid) (: home able))
                     (set> This (val> This) T) ) ) )
            (unless *Err
               (for This (: gui)
                  (cond
                     ((: id))
                     ((chk> (setq *Chart This)) (error @))
                     ((or (: rid) (: home able))
                        (set> This (val> This)) ) ) ) )
            (if (pair *Err)
               (when *Lock
                  (=: lock (with (caar *Err) (tryLock *Lock))) )
               (finally
                  (when *Lock
                     (if (lock @)
                        (=: able (=: lock (off *Lock)))
                        (sync)
                        (tell) ) )
                  (when "Fun"
                     (when (and *Allow (not (idx *Allow "Fun")))
                        (notAllowed "Fun")
                        (throw 'stop) )
                     (apply (intern "Fun")
                        (mapcar
                           '((X)
                              ((if (= "+" (car (setq X (chop (cdr X))))) format pack)
                                 (cdr X) ) )
                           *JsArgs ) ) )
                  (for This (: gui)
                     (nond
                        ((: id) (setq *Chart This))
                        ((ge0 (: id))
                           (let? A (assoc (: id) (val *PRG))
                              (when (cdr A)
                                 (con A)
                                 (act> This) ) ) ) ) ) )
               (for This (: gui)
                  (or (: id) (setq *Chart This))
                  (upd> This) ) ) ) ) ) )

(de error (Exe)
   (cond
      ((=T Exe) (on *Err))
      ((nT *Err) (queue '*Err (cons This Exe))) ) )

(de url (Url . @)
   (when Url
      (off *PRG)
      (when *Timeout
         (timeout `(* 3600 1000)) )
      (redirect (baseHRef) *SesId Url
         (and (args) "?")
         (pack
            (make
               (loop
                  (let A (next)
                     (and
                        (sym? A)
                        (= `(char '*) (char A))
                        (link A "=")
                        (setq A (next)) )
                     (link (ht:Fmt A)) )
                  (NIL (args))
                  (link "&") ) ) ) )
      (throw 'stop) ) )

(de post Prg
   (run Prg)
   (url *Uri) )

# Active <span> elements
(de span Args
   (def (car Args)
      (list NIL
         (list '<span>
            (lit (cons 'id (car Args)))
            (cons 'ht:Prin (cdr Args)) ) ) )
   (push '*Spans Args) )

(span expires
   (pack
      `(char 8230)  # Ellipsis
      (let Tim (+ (time T) (/ (cadr (assoc -1 *Run)) 1000))
         (if *TZO
            (tim$ (% (- Tim -86400 @) 86400))
            (<javascript>
               "lisp(null, 'tzOffs', (new Date()).getTimezoneOffset())" )
            (pack (tim$ (% Tim 86400)) " UTC") ) ) ) )

# Return chart property
(de chart @
   (pass get *Chart) )

# Table extension
(daemon '<table>
   (with *Chart
      (setq ATTR
         (make
            (link
               (cons "chart" (index This (: home chart)))
               '("ontouchmove" . "return tblMove(this,event)")
               '("ontouchstart" . "return tblTouch(event)")
               (and ATTR (link @)) ) ) ) ) )

# REPL form
(private) Str

(de repl (Attr DX DY)
   (default DX 80  DY 25)
   (form Attr
      (=: repl (tmp "repl"))
      (gui 'view '(+Able +FileField)
         '(<> (: file) (: home repl))
         (: repl)
         DX DY )
      (--)
      (gui '(+View +SymField) '(car (symbols)))
      (<nbsp>)
      (gui 'line '(+Focus +Able +Hint1 +TextField)
         '(= (: home view file) (: home repl))
         '*ReplH
         (*/ DX 4 5) )
      (----)
      (gui '(+JS +Able +Button) '(= (: home view file) (: home repl)) "Eval"
         '(let Str (val> (: home line))
            (out (pack "+" (: home repl))
               (if (= `(char "!") (char Str))
                  (err NIL
                     (prinl Str)
                     (flush)
                     (in (list "sh" "-c" (cdr (chop Str)))
                        (echo) ) )
                  (err NIL
                     (prinl (car (symbols)) ": " Str)
                     (flush)
                     (catch '(NIL)
                        (in "/dev/null"
                           (up 99 @@@ "@3")
                           (up 99 @@ "@2")
                           (up 99 @ "@1")
                           (setq  "@3" "@2"  "@2" "@1"  "@1" (run (str Str) 99)) )
                        (off *Msg)
                        (println '-> "@1") ) )
                  (when *Msg
                     (prin "!? ")
                     (println ^)
                     (prinl *Msg) ) ) )
            (push1 '*ReplH Str)
            (clr> (: home line)) ) )
      (gui '(+JS +Button)
         '(if (= (: home view file) (: home repl)) ,"Edit" ,"Done")
         '(file> (: home view)
            (if (= (: home view file) (: home repl))
               (if (val> (: home line))
                  (setq *ReplF (push1 '*ReplH @))
                  (set> (: home line) *ReplF)
                  *ReplF )
               (clr> (: home line))
               (: home repl) ) ) ) ) )

(private) (dlg Attr Env Lst Prg)

# Dialogs
(de dlg (Attr Env Prg)
   (let L (get *FormLst (- *FormIx *Get))
      (while (and (car L) (n== *PRG (caar @)))
         (pop L) )
      (push L
         (list
            (new NIL NIL  'btn This  'able T  'evt 0  'env Env)
            Attr
            Prg ) )
      (pushForm L) ) )

(de dialog (Env . Prg)
   (dlg 'dialog Env Prg) )

(de alert (Env . Prg)
   (dlg 'alert Env Prg) )

(de note (Str Lst)
   (alert (env '(Str Lst))
      (<span> 'note Str)
      (--)
      (for S Lst (<br> S))
      (okButton) ) )

(de ask (Str . Prg)
   (alert (env '(Str Prg))
      (<span> 'ask Str)
      (--)
      (yesButton (cons 'prog Prg))
      (noButton) ) )

(de diaform (Lst . Prg)
   (cond
      ((num? (caar Lst))  # Dst
         (gui (gt0 (caar Lst)) '(+ChoButton)
            (cons 'diaform
               (list 'cons
                  (list 'cons (lit (car Lst)) '(field 1))
                  (lit (env (cdr Lst))) )
               Prg ) ) )
      ((and *PRG (not (: diaform)))
         (dlg 'dialog (env Lst) Prg) )
      (T
         (=: env (env Lst))
         (=: diaform T)
         (run Prg 1) ) ) )

(de saveButton (Exe)
   (gui '(+Button) ,"Save" Exe) )

(de closeButton (Lbl Exe)
   (when (get *App 'top)
      (gui '(+Rid +Close +Button) Lbl Exe) ) )

(de okButton (Exe)
   (when (get *App 'top)
      (if (=T Exe)
         (gui '(+Force +Close +Button) T "OK")
         (gui '(+Close +Button) "OK" Exe) ) ) )

(de cancelButton ()
   (when (get *App 'top)
      (gui '(+Force +Close +Button) T ',"Cancel") ) )

(de yesButton (Exe)
   (gui '(+Close +Button) ',"Yes" Exe) )

(de noButton (Exe)
   (gui '(+Close +Button) ',"No" Exe) )

(de choButton (Exe)
   (gui '(+Rid +Tip +Button)
      ,"Find or create an object of the same type"
      ',"Select" Exe ) )


(class +Force)
# force

(dm T (Exe . @)
   (=: force Exe)
   (pass extra) )

(dm chk> ()
   (when
      (and
         (cdr (assoc (: id) (val *PRG)))
         (eval (: force)) )
      (for A (val *PRG)
         (and
            (lt0 (car A))
            (<> (: id) (car A))
            (con A) ) )
      T ) )


(class +Close)

(dm act> ()
   (when (able)
      (and
         (get *FormLst (- *FormIx *Get))
         (pushForm
            (cons
               (filter
                  '((L) (memq (car L) (: home top)))
                  (car @) )
               (cdr @) ) ) )
      (extra)
      (for This (: home top)
         (for This (: gui)
            (or (: id) (setq *Chart This))
            (upd> This) ) ) ) )


# Choose a value
(class +ChoButton +Tiny +Tip +Button)

(dm T (Exe)
   (super  ,"Choose a suitable value" "+" Exe)
   (=: chg T) )


(class +PickButton +Tiny +Tip +Button)

(dm T (Exe)
   (super ,"Adopt this value" "@" Exe) )


(class +DstButton +Set +Able +Close +PickButton)
# msg obj

(dm T (Dst Msg)
   (=: msg (or Msg 'url>))
   (super
      '((Obj) (=: obj Obj))
      '(: obj)
      (when Dst
         (or
            (pair Dst)
            (list 'chgDst (lit Dst) '(: obj)) ) ) ) )

(de chgDst (This Val)
   (set> This (if (: new) (@ Val) Val)) )

(dm js> ()
   (cond
      ((: act) (super))
      ((try (: msg) (: obj) 1 This)
         (pack "@&+" (ht:Fmt (sesId (mkUrl @)))) )
      (T "@") ) )

(dm show> (Var)
   (if (: act)
      (super Var)
      (<style> (cons 'id (pack "i" *Form "-" (: id)))
         (if (try (: msg) (: obj) 1 This)
            (<tip> "-->" (<href> "@" (mkUrl @)))
            (<span> *Style "@") ) ) ) )


(class +Choice +ChoButton)
# ttl hint

(dm T (Ttl Exe)
   (=: ttl Ttl)
   (=: hint Exe)
   (super
      '(dialog (env 'Ttl (eval (: ttl))  'Lst (eval (: hint))  'Dst (field 1))
         (<table> 'chart Ttl '((btn) NIL)
            (for X Lst
               (<row> NIL
                  (gui '(+Close +PickButton)
                     (list 'set> 'Dst
                        (if (get Dst 'dy)
                           (list 'pack '(str> Dst) (fin X))
                           (lit (fin X)) ) ) )
                  (ht:Prin (if (atom X) X (car X))) ) ) )
         (cancelButton) ) ) )


(class +Tok)

(dm T @
   (=: tok T)
   (pass extra) )


(class +Coy)

(dm T @
   (=: coy T)
   (pass extra) )


(class +hint)
# tok coy

(dm show> (Var)
   (<js>
      (list
         '("autocomplete" . "off")
         '("onfocus" . "doHint(this)")
         (cons
            "onkeyup"
            (pack
               "return hintKey(this,event"
               (if2 (: tok) (: coy) ",true,true" ",true" ",false,true")
               ")" ) ) )
      (extra Var) ) )

(de jsHint (I)
   (when I
      (httpHead "text/plain; charset=utf-8")
      (ht:Out *Chunked
         (let? L
            (if (sym? I)
               ((; I hint) *JsHint)
               (let? Lst (get *FormLst (- *FormIx (format *Get)))
                  (pair
                     (hint>
                        (get
                           (if (gt0 (format *Form))
                              (get Lst @)
                              (get Lst 1 (+ (length (car Lst)) (format *Form)) 1) )
                           'gui
                           I )
                        *JsHint ) ) ) )
            (prin
               (ht:Fmt
                  (if (atom (car L))
                     (car L)
                     (caar L) ) ) )
            (for X (cdr L)
               (prin "&"
                  (ht:Fmt (if (atom X) X (car X))) ) ) ) ) ) )


(class +Hint +hint)
# hint

(dm T (Fun . @)
   (=: hint Fun)
   (pass extra) )

(dm hint> (Str)
   ((: hint) (extra Str)) )

(de queryHint (Var CL Str)
   (make
      (for (Q (goal CL) (prove Q))
         (for V
            (fish
               '((S) (and (atom S) (sub? (fold Str) (fold S))))
               (get (asoq '@@ @) -1 Var) )
            (unless (member V (made))
               (link V) ) )
         (T (nth (made) 24)) ) ) )

(de dbHint (Str Var Cls Hook)
   (queryHint Var
      (cons (list 'db Var Cls Hook Str '@@))
      Str ) )


(class +DbHint +Hint)

(dm T (Rel . @)
   (pass super
      (list '(Str)
         (list 'dbHint 'Str
            (lit (car Rel))
            (lit (last Rel))
            (and (meta (cdr Rel) (car Rel) 'hook) (next)) ) ) ) )


(class +Hint1 +hint)
# hint

(dm T (Exe . @)
   (=: hint Exe)
   (pass extra) )

(dm hint> (Str)
   (setq Str (extra Str))
   (extract '((S) (pre? Str S))
      (eval (: hint)) ) )


(class +Hint2 +hint)

(dm hint> (Str)
   (setq Str (extra Str))
   (extract '((X) (pre? Str (if (atom X) X (car X))))
      (with (field -1) (eval (: hint))) ) )


(class +Txt)
# txt

(dm T (Fun . @)
   (=: txt Fun)
   (pass extra) )

(dm txt> (Val)
   ((: txt) Val) )


(class +Set)
# set

(dm T (Fun . @)
   (=: set Fun)
   (pass extra) )

(dm set> (Val Dn)
   (extra ((: set) Val) Dn) )


(class +Val)
# val

(dm T (Fun . @)
   (=: val Fun)
   (pass extra) )

(dm val> ()
   ((: val) (extra)) )


(class +Fmt)
# set val

(dm T (Fun1 Fun2 . @)
   (=: set Fun1)
   (=: val Fun2)
   (pass extra) )

(dm set> (Val Dn)
   (extra ((: set) Val) Dn) )

(dm val> ()
   ((: val) (extra)) )


(class +Chg)
# old new

(dm T (Fun . @)
   (=: new Fun)
   (pass extra) )

(dm set> (Val Dn)
   (extra (=: old Val) Dn) )

(dm val> ()
   (let Val (extra)
      (if (and (<> (: old) Val) (able))
         ((: new) (=: old Val))
         Val ) ) )


(class +Upd)
# upd

(dm T (Exe . @)
   (=: upd Exe)
   (pass extra) )

(dm upd> ()
   (set> This (eval (: upd))) )


(class +Init)
# init

(dm T (Val . @)
   (=: init Val)
   (pass extra) )

(dm init> ()
   (set> This (: init)) )


(class +Dflt)
# dflt

(dm T (Exe . @)
   (=: dflt Exe)
   (pass extra) )

(dm set> (Val Dn)
   (extra (or Val (eval (: dflt))) Dn) )

(dm val> ()
   (let Val (extra)
      (unless (= Val (eval (: dflt))) Val) ) )


(class +Cue)
# cue

(dm T (Str . @)
   (=: cue (pack "<" Str ">"))
   (pass extra) )

(dm show> (Var)
   (<js>
      (cons (cons "placeholder" (: cue)))
      (extra Var) ) )


(class +Trim)

(dm val> ()
   (pack (trim (chop (extra)))) )


(class +Enum)
# enum

(dm T (Lst . @)
   (=: enum Lst)
   (pass extra) )

(dm set> (N Dn)
   (extra (get (: enum) N) Dn) )

(dm val> ()
   (index (extra) (: enum)) )


(class +Map)
# map

(dm T (Lst . @)
   (=: map Lst)
   (pass extra) )

(dm set> (Val Dn)
   (extra
      (if
         (find
            '((X) (= Val (cdr X)))
            (: map) )
         (val (car @))
         Val )
      Dn ) )

(dm val> ()
   (let Val (extra)
      (if
         (find
            '((X) (= Val (val (car X))))
            (: map) )
         (cdr @)
         Val ) ) )


# Case conversions
(class +Uppc)

(dm set> (Val Dn)
   (extra (uppc Val) Dn) )

(dm val> ()
   (uppc (extra)) )

(dm hint> (Str)
   (extra (uppc Str)) )


(class +Lowc)

(dm set> (Val Dn)
   (extra (lowc Val) Dn) )

(dm val> ()
   (lowc (extra)) )

(dm hint> (Str)
   (extra (lowc Str)) )


# Field enable/disable
(de able ()
   (when (or (: rid) (: home able))
      (eval (: able)) ) )

(class +Able)

(dm T (Exe . @)
   (pass extra)
   (when (: able)
      (=: able
         (cond
            ((=T (: able)) Exe)
            ((and (pair (: able)) (== 'and (car @)))
               (cons 'and Exe (cdr (: able))) )
            (T (list 'and Exe (: able))) ) ) ) )


(class +Lock +Able)

(dm T @
   (pass super NIL) )


(class +View +Lock +Upd)


# Escape from form lock
(class +Rid)
# rid

(dm T @
   (=: rid T)
   (pass extra) )


(class +Align)

(dm T @
   (=: align T)
   (pass extra) )


(class +Limit)
# lim

(dm T (Exe . @)
   (=: lim Exe)
   (pass extra) )


(class +Clr0)

(dm val> ()
   (let N (extra)
      (unless (=0 N) N) ) )


(class +Var)
# var

(dm T (Var . @)
   (=: var Var)
   (pass extra) )

(dm set> (Val Dn)
   (extra (set (: var) Val) Dn) )

(dm upd> ()
   (set> This (val (: var))) )


(class +Chk)
# chk

(dm T (Exe . @)
   (=: chk Exe)
   (pass extra) )

(dm chk> ()
   (eval (: chk)) )


(class +Tip)
# tip

(dm T (Exe . @)
   (unless (: tip)
      (=: tip Exe) )
   (pass extra) )

(dm show> (Var)
   (<tip> (eval (: tip)) (extra Var)) )

(dm js> ()
   (pack (extra) "&?" (ht:Fmt (glue "\n" (eval (: tip))))) )


(class +Tiny)

(dm show> (Var)
   (<style> 'tiny (extra Var)) )


(class +Click)
# clk

(dm T (Exe . @)
   (=: clk Exe)
   (pass extra) )

(dm show> (Var)
   (extra Var)
   (and
      (atom *Err)
      (eval (: clk))
      (<javascript>
         "window.setTimeout(\"document.getElementById('"
         "i" *Form "-" (: id)
         "').click()\","
         @
         ")" ) ) )


(class +Focus)

(dm show> (Var)
   (extra Var)
   (when (and (able) (not *Foc))
      (on *Foc)
      (<javascript> "idFocus('" "i" *Form "-" (: id) "')") ) )


### Styles ###
(class +Style)
# style

(dm T (Exe . @)
   (=: style Exe)
   (pass extra) )

(dm show> (Var)
   (<style> (eval (: style)) (extra Var)) )

(dm js> ()
   (pack (extra) "&#" (eval (: style))) )


# Monospace font
(class +Mono)

(dm show> (Var)
   (<style> "mono" (extra Var)) )

(dm js> ()
   (pack (extra) "&#mono") )


# Signum field
(class +Sgn)

(dm show> (Var)
   (<style> (and (lt0 (val> This)) "red") (extra Var)) )

(dm js> ()
   (pack (extra) "&#" (and (lt0 (val> This)) "red")) )


### Form field classes ###
(de showFld Prg
   (when (: lbl)
      (ht:Prin (eval @))
      (<nbsp>) )
   (let *Style (style (cons 'id (pack "i" *Form "-" (: id))) *Style)
      (run Prg 1) ) )


(class +gui)
# home id chg able chart

(dm T ()
   (push (=: home *App) (cons (=: id *Ix)))
   (=: able T) )

(dm txt> (Val))

(dm set> (Val Dn))

(dm clr> ()
   (set> This) )

(dm val> ())

(dm hint> (Str)
   Str )

(dm init> ()
   (upd> This) )

(dm upd> ())

(dm chk> ())


(class +field +gui)

(dm T ()
   (super)
   (=: chg T) )

(dm txt> (Val)
   Val )

(dm js> ()
   (let S (ht:Fmt (cdr (assoc (: id) (val *PRG))))
      (if (able) S (pack S "&=")) ) )

(dm set> (Str Dn)
   (con (assoc (: id) (val (: home))) Str)
   (and (not Dn) (: chart) (set> (car @) (val> (car @)))) )

(dm str> ()
   (cdr (assoc (: id) (val (: home)))) )

(dm val> ()
   (str> This) )


# Get field
(de field (X . @)
   (if (sym? X)
      (pass get (: home) X)
      (pass get (: home gui) (+ X (abs (: id)))) ) )

# Get current chart data row
(de row (D)
   (+ (: chart 1 ofs) (: chart 2) -1 (or D 0)) )

(de curr @
   (pass get (: chart 1 data) (row)) )

(de prev @
   (pass get (: chart 1 data) (row -1)) )


(class +Button +gui)
# img lbl alt act js

# ([T] lbl [alt] act)
(dm T @
   (let A (next)
      (=: lbl
         (if (=: img (=T A)) (next) A) ) )
   (let X (next)
      (ifn (args)
         (=: act X)
         (=: alt X)
         (=: act (next)) ) )
   (super)
   (set
      (car (val *App))
      (=: id (- (: id))) ) )

(dm js> ()
   (if (able)
      (let Str (ht:Fmt (eval (: lbl)))
         (if (: img) (sesId Str) Str) )
      (let Str (ht:Fmt (or (eval (: alt)) (eval (: lbl))))
         (pack (if (: img) (sesId Str) Str) "&=") ) ) )

(dm show> (Var)
   (<style> (cons 'id (pack "i" *Form "-" (: id)))
      (if (able)
         ((if (: img) <image> <submit>)
            (eval (: lbl))
            Var NIL (: js) )
         ((if (: img) <image> <submit>)
            (or (eval (: alt)) (eval (: lbl)))
            Var T (: js) ) ) ) )

(dm act> ()
   (and (able) (eval (: act))) )


(class +OnClick)
# onclick

(dm T (Exe . @)
   (=: onclick Exe)
   (pass extra) )

(dm show> (Var)
   (<js> (list (cons 'onclick (eval (: onclick))))
      (extra Var) ) )


(class +Drop)
# "drop" drop

(dm T (Fld . @)
   (=: "drop" Fld)
   (pass extra) )

(dm show> (Var)
   (<js>
      (quote
         ("ondragenter" . "doDrag(event)")
         ("ondragover" . "doDrag(event)")
         ("ondrop" . "doDrop(this,event)") )
      (extra Var) ) )

(dm act> ()
   (when (able)
      (=: drop
         (and
            (or *Drop (val> (eval (: "drop"))))
            (tmp @) ) )
      (extra)
      (off *Drop) ) )


(class +JS)

(dm T @
   (=: js T)
   (pass extra) )


(class +Auto +JS)
# auto

(dm T (Fld Exe . @)
   (=: auto (cons Fld Exe))
   (pass super) )

(dm act> ()
   (when (able)
      (=: home auto
         (cons
            (eval (car (: auto)))
            (eval (cdr (: auto))) ) )
      (extra) ) )


# Chart prefix
(class +Stop)

(dm scroll> (N)
   (when (find '((F) (isa '+Auto F)) (: home gui))
      (=: home auto (cons @)) )
   (extra N) )


(class +DnButton +Tiny +Rid +JS +Able +Button)

(dm T (Exe Lbl)
   (super
      '(> (length (chart 'data)) (chart 'ofs))
      (or Lbl ">")
      (list 'scroll> (lit *Chart) Exe) ) )

(de jsDn (I)
   (with (get (: chart) I)
      (and
         (: data)
         (> (length @) (: ofs))
         (scroll> This 1) ) ) )

(class +UpButton +Tiny +Rid +JS +Able +Button)

(dm T (Exe Lbl)
   (super
      '(> (chart 'ofs) 1)
      (or Lbl "<")
      (list 'scroll> (lit *Chart) (list '- Exe)) ) )

(de jsUp (I)
   (with (get (: chart) I)
      (when (> (: ofs) 1)
         (scroll> This -1) ) ) )

(class +GoButton +Tiny +Rid +JS +Able +Button)

(dm T (Exe Lbl)
   (super
      (list 'and
         (list '>= '(length (chart 'data)) Exe)
         (list '<> '(chart 'ofs) Exe) )
      Lbl
      (list 'goto> (lit *Chart) Exe) ) )

(de scroll (N Flg)
   (when Flg
      (gui '(+Tip +GoButton) ,"Go to first line" 1 "|<") )
   (gui '(+Tip +UpButton) ,"Scroll up one page" N "<<")
   (gui '(+Tip +UpButton) ,"Scroll up one line" 1)
   (gui '(+Tip +DnButton) ,"Scroll down one line" 1)
   (gui '(+Tip +DnButton) ,"Scroll down one page" N ">>")
   (when Flg
      (gui '(+Tip +GoButton) ,"Go to last line"
         (list '- '(length (chart 'data)) (dec N))
         ">|" )
      (<nbsp>)
      (gui '(+View +TextField)
         '(let? Len (gt0 (length (chart 'data)))
            (pack
               (chart 'ofs)
               "-"
               (min Len (dec (+ (chart 'ofs) (chart 'rows))))
               " / "
               Len ) ) ) ) )


# Insert empty row
(class +InsRowButton +Tiny +JS +Able +Tip +Button)

(dm T ()
   (super '(nth (: chart 1 data) (row)) ,"Insert empty row" "<"
      '(set> (: chart 1)
         (insert (row) (val> (: chart 1))) ) )
   (=: chg T) )

# Delete row
(class +DelRowButton +Tiny +JS +Able +Tip +Button)
# exe del

(dm T (Exe Txt)
   (=: exe Exe)
   (=: del Txt)
   (super '(nth (: chart 1 data) (row)) ,"Delete row" "x"
      '(if (or (: home del) (not (curr)))
         (_delRow (: exe))
         (ask (if (: del) (eval @) ,"Delete row?")
            (with (: home btn)
               (=: home del T)
               (_delRow (: exe)) ) ) ) )
   (=: chg T) )

(de _delRow (Exe)
   (eval Exe)
   (set> (: chart 1)
      (remove (row) (val> (: chart 1))) ) )

# Move row up
(class +BubbleButton +Tiny +JS +Able +Tip +Button)
# exe

(dm T (Exe)
   (=: exe Exe)
   (super
      '(>= (length (: chart 1 data)) (row) 2)
      ,"Shift row up"
      "\^"
      '(let L (val> (: chart 1))
         (eval (: exe))
         (set> (: chart 1)
            (conc
               (cut (row -2) 'L)
               (and (cadr L) (cons @))
               (and (car L) (cons @))
               (cddr L) ) ) ) )
   (=: chg T) )


(class +ClrButton +JS +Tip +Button)
# clr

(dm T (Lbl Lst . @)
   (=: clr Lst)
   (pass super ,"Clear all input fields" Lbl
      '(for X (: clr)
         (if (atom X)
            (clr> (field X))
            (set> (field (car X)) (eval (cdr X))) ) ) ) )


(class +ShowButton +Button)

(dm T (Flg Exe)
   (let F (tmp (basename *Url) "=")
      (super ,"Show" (list 'out F Exe))
      (=: home show F)
      (and Flg (out F (eval Exe))) ) )


(class +Checkbox +field)
# lbl

# ([lbl])
(dm T (Lbl)
   (=: lbl Lbl)
   (super) )

(dm txt> (Val)
   (if Val ,"Yes" ,"No") )

(dm show> (Var)
   (showFld (<check> Var (not (able)))) )

(dm set> (Val Dn)
   (super (bool Val) Dn) )

(dm val> ()
   (bool (super)) )


(class +Radio +field)  # Inited by Tomas Hlavaty <kvietaag@seznam.cz>
# grp rad lbl

# (grp rad [lbl])
(dm T (Grp Rad Lbl)
   (super)
   (=: grp (if Grp (field @) This))
   (=: rad Rad)
   (=: lbl Lbl) )

(dm show> (Var)
   (showFld
      (<radio>
         (cons '*Gui (: grp id))
         (: rad)
         (not (able)) ) ) )

(dm js> ()
   (pack
      (ht:Fmt (: rad))
      "&" (= (: rad) (str> (: grp)))
      (unless (able) "&=") ) )

(dm set> (Val Dn)
   (when (== This (: grp))
      (super Val Dn) ) )


(class +TextField +field)
# dx dy lst lbl lim align

# ([dx [dy] [lbl]])
# ([lst [lbl]])
(dm T (X Y Z)
   (nond
      ((num? X)
         (=: lst X)
         (=: lbl Y) )
      ((num? Y)
         (=: dx X)
         (=: lbl Y) )
      (NIL
         (=: dx X)
         (=: dy Y)
         (=: lbl Z) ) )
   (super)
   (or (: dx) (: lst) (=: chg)) )

(dm show> (Var)
   (showFld
      (cond
         ((: dy)
            (<area> (: dx) (: dy) Var (not (able))) )
         ((: dx)
            (<field>
               (if (: align) (- (: dx)) (: dx))
               Var
               (eval (: lim))
               (not (able)) ) )
         ((: lst)
            (let
               (L
                  (mapcar
                     '(("X")
                        (cond
                           ((atom "X") (eval "X"))
                           ((pair (cdr "X"))
                              (cons
                                 (val (car "X"))
                                 (cadr "X")
                                 (val (cdr @)) ) )
                           (T (cons (val (car "X")) (val (cdr "X")))) ) )
                     @ )
                  S (str> This) )
               (<select>
                  (if (or (member S L) (assoc S L))
                     L
                     (cons S L) )
                  Var
                  (not (able)) ) ) )
         (T
            (<style> (cons 'id (pack "i" *Form "-" (: id)))
               (<span> *Style
                  (if (str> This) (ht:Prin @) (<nbsp>)) ) ) ) ) ) )


(class +LinesField +TextField)

(dm set> (Val Dn)
   (super (glue "\n" Val) Dn) )

(dm val> ()
   (split (chop (super)) "\n") )


(class +ListTextField +TextField)
# split

(dm T (Lst . @)
   (=: split (or Lst '(" " "\t" "\n")))
   (pass super) )

(dm set> (Val Dn)
   (super (glue (car (: split)) Val) Dn) )

(dm val> ()
   (extract
      '((L) (pack (clip L)))
      (apply split (: split) (chop (super))) ) )


# Password field
(class +PwField +TextField)

(dm show> (Var)
   (showFld
      (<passwd> (: dx) Var (eval (: lim)) (not (able))) ) )


# Upload field
(class +UpField +TextField)

(dm show> (Var)
   (showFld
      (<upload> (: dx) Var (not (able))) ) )


# Color picker
(class +RgbPicker +field)

(dm show> (Var)
   (showFld
      (<rgb> Var (not (able))) ) )


# Symbol fields
(class +SymField +TextField)

(dm val> ()
   (let S (super)
      (and (<> "-" S) (intern S)) ) )

(dm set> (Val Dn)
   (super (and Val (name @)) Dn) )


(class +numField +Align +TextField)
# scl

(dm chk> ()
   (and
      (str> This)
      (not (format @ (: scl) *Sep0 *Sep3))
      ,"Numeric input expected" ) )


(class +NumField +numField)

(dm txt> (Val)
   (format Val) )

(dm set> (Val Dn)
   (super (format Val) Dn) )

(dm val> ()
   (format (super) NIL *Sep0 *Sep3) )


(class +FixField +numField)

(dm T (N . @)
   (=: scl N)
   (pass super) )

(dm txt> (Val)
   (format Val (: scl) *Sep0 *Sep3) )

(dm set> (Val Dn)
   (super (format Val (: scl) *Sep0 *Sep3) Dn) )

(dm val> ()
   (let S (super)
      (format
         (or (sub? *Sep0 S) (pack S *Sep0))
         (: scl)
         *Sep0
         *Sep3 ) ) )


(class +AtomField +Mono +TextField)

(dm set> (Val Dn)
   (super
      (if (num? Val)
         (align (: dx) (format Val))
         Val )
      Dn ) )

(dm val> ()
   (let S (super)
      (or (format S) S) ) )


(class +DateField +TextField)

(dm txt> (Val)
   (datStr Val) )

(dm set> (Val Dn)
   (super (datStr Val) Dn) )

(dm val> ()
   (expDat (super)) )

(dm chk> ()
   (and
      (str> This)
      (not (expDat @))
      ,"Bad date format" ) )


(class +TimeField +TextField)

(dm txt> (Val)
   (tim$ Val (> (: dx) 6)) )

(dm set> (Val Dn)
   (super (tim$ Val (> (: dx) 6)) Dn) )

(dm val> ()
   ($tim (super)) )

(dm chk> ()
   (and
      (str> This)
      (not ($tim @))
      ,"Bad time format" ) )


(class +Img +gui)
# img alt url dx dy

(dm T (Alt Url DX DY)
   (=: alt Alt)
   (=: url Url)
   (=: dx DX)
   (=: dy DY)
   (super) )

(dm js> ()
   (pack
      (ht:Fmt (sesId (or (: img) *No.png))) "&"
      (eval (: alt)) "&"
      (and (eval (: url)) (ht:Fmt (sesId @))) ) )

(dm show> (Var)
   (showFld
      (<img>
         (or (: img) *No.png)
         (eval (: alt))
         (eval (: url))
         (: dx)
         (: dy) ) ) )

(dm set> (Val Dn)
   (=: img Val) )

(dm val> ()
   (: img) )


(class +Icon)
# icon url

(dm T (Exe Url . @)
   (=: icon Exe)
   (=: url Url)
   (pass extra) )

(dm js> ()
   (pack (extra) "&*"
      (ht:Fmt (sesId (eval (: icon)))) "&"
      (and (eval (: url)) (ht:Fmt (sesId @))) ) )

(dm show> (Var)
   (prin "<table cellspacing=\"0\" cellpadding=\"0\"><td>")
   (extra Var)
   (prin "</td><td>")
   (<img> (eval (: icon)) 'icon (eval (: url)))
   (prinl "</td></table>") )


(class +FileField +TextField)
# file org

(dm T (Exe . @)
   (=: file Exe)
   (pass super) )

(dm set> (Val Dn)
   (and
      (<> Val (: org))
      (eval (: file))
      (ctl @ (out @ (prin (=: org Val)))) )
   (super Val Dn) )

(dm upd> ()
   (set> This
      (=: org
         (let? F (eval (: file))
            (and
               (info F)
               (ctl (pack "+" F)
                  (in F (till NIL T)) ) ) ) ) ) )

(dm file> (Exe)
   (=: file Exe)
   (upd> This) )


(class +Url)
# url

(dm T (Fun . @)
   (=: url Fun)
   (pass extra) )

(dm js> ()
   (if2 (or (: dx) (: lst)) (txt> This (val> This))
      (pack (extra) "&*" (ht:Fmt (sesId *Go.png)) "&" (ht:Fmt (sesId ((: url) @))))
      (pack (extra) "&*" (ht:Fmt (sesId *No.png)) "&")
      (pack @ "&+" (ht:Fmt (sesId ((: url) @))))
      (extra) ) )

(dm show> (Var)
   (cond
      ((or (: dx) (: lst))
         (prin "<table cellspacing=\"0\" cellpadding=\"0\"><td>")
         (extra Var)
         (prin "</td><td title=\"-->\">")
         (if (txt> This (val> This))
            (<img> *Go.png 'url ((: url) @))
            (<img> *No.png) )
         (prinl "</td></table>") )
      ((txt> This (val> This))
         (showFld (<href> @ ((: url) @))) )
      (T (extra Var)) ) )


(class +HttpField +Url +TextField)

(dm T @
   (pass super
      '((S) (or (sub? "://" S) (pack "https://" S))) ) )


(class +MailField +Url +TextField)

(dm T @
   (pass super '((S) (pack "mailto:" S))) )


(class +TelField +Url +TextField)

(dm T @
   (pass super '((S) (pack "tel:" S))) )

(dm txt> (Val)
   (telStr Val) )

(dm set> (Val Dn)
   (super (telStr Val) Dn) )

(dm val> ()
   (expTel (super)) )

(dm chk> ()
   (and
      (str> This)
      (not (expTel @))
      ,"Bad phone number format" ) )


(class +SexField +Map +TextField)

(dm T (Lbl)
   (super
      '((,"male" . T) (,"female" . 0))
      '(NIL ,"male" ,"female")
      Lbl ) )


### GUI charts ###
(class +Chart)
# home gui rows cols ofs lock put get data

# (cols [put [get]])
(dm T (N Put Get)
   (setq *Chart This)
   (queue (prop (=: home *App) 'chart) This)
   (=: rows 1)
   (when N
      (=: gui (list (need (=: cols N)))) )
   (=: ofs 1)
   (=: lock T)
   (=: put (or Put prog1))
   (=: get (or Get prog1)) )

(dm put> ()
   (let I (: ofs)
      (mapc
         '((G D)
            (unless (memq NIL G)
               (mapc 'set> G ((: put) D I) T) )
            (inc 'I) )
         (: gui)
         (nth (: data) I) ) ) )

(dm get> ()
   (and
      (or (: rid) (: home able))
      (not (: lock))
      (let I (: ofs)
         (map
            '((G D)
               (set D
                  (trim
                     ((: get)
                        (mapcar 'val> (car G))
                        (car D)
                        (car G)
                        I ) ) )
               (mapc 'set>
                  (car G)
                  ((: put) (car D) I)
                  T )
               (inc 'I) )
            (: gui)
            (nth
               (=: data
                  (need (- 1 I (: rows)) (: data)) )
               I ) )
         (=: data (trim (: data))) ) ) )

(dm scroll> (N)
   (get> This)
   (unless (gt0 (inc (:: ofs) N))
      (=: ofs 1) )
   (put> This) )

(dm goto> (N)
   (get> This)
   (=: ofs (max 1 N))
   (put> This) )

(dm find> ("Fun")
   (get> This)
   (let "D" (cdr (nth (: data) (: ofs)))
      (=: ofs
         (if (find "Fun" "D")
            (index @ (: data))
            1 ) ) )
   (put> This) )

(dm txt1> (I Lst)
   (map
      '((G D)
         (prin
            (txt> (car G) (car D))
            (if (cdr G) "\t" "\n") ) )
      (: gui 1)
      ((: put) Lst I) ) )

(dm txt> ()
   (for (I . L) (: data)
      (txt1> This I L) ) )

(dm set> (Lst)
   (=: ofs
      (max 1
         (min (: ofs) (length (=: data (copy Lst)))) ) )
   (put> This)
   Lst )

(dm log> (Lst)
   (=: ofs (max (: ofs) (- (length (: data)) (: rows) -2)))
   (set> This (conc (val> This) (cons Lst))) )

(dm clr> ()
   (set> This) )

(dm val> ()
   (get> This)
   (: data) )

(dm init> ()
   (upd> This) )

(dm upd> ())

(dm chk> ())


(class +Chart1 +Chart)

# (cols)
(dm T (N)
   (super N list car) )


### DB GUI ###
(de newUrl @
   (prog1
      (pass new!)
      (lock (setq *Lock @))
      (apply url (url> @ 1)) ) )

(de sortButton (@Var . @Fun)
   (gui '(+Tiny +JS +Button) "v"
      (fill
         '(put!> (: home obj) '@Var
            (by '@Fun sort (: home obj @Var)) ) ) )
   (gui '(+Tiny +JS +Button) "\^"
      (fill
         '(put!> (: home obj) '@Var
            (flip (by '@Fun sort (: home obj @Var))) ) ) ) )

# (choDlg Dst Ttl Rel [Hook] [((+XyzField) ..) Exe Able])
(de choDlg (Dst Ttl Rel . @)
   (let
      (Hook (and (meta (cdr Rel) (car Rel) 'hook) (next))
         Fld
         (or (next)
            (if Hook
               (list '(+DbHint +TextField) Rel (lit Hook) 40)
               (list '(+DbHint +TextField) Rel 40) ) )
         Gui
         (if (next)
            (list '(+ObjView +TextField) @)
            (list (list '+ObjView (last (car Fld))) (list ': (car Rel))) )
         Able (if (args) (next) T) )
      (diaform '(Dst Ttl Rel Hook Fld Gui Able)
         (apply gui
            (cons
               (cons '+Focus '+Var (car Fld))
               (cdr (or (assoc Rel *Cho) (push '*Cho (list Rel NIL))))
               (cdr Fld) ) )
         (searchButton '(init> (: home query)))
         (gui 'query '(+QueryChart) (cho)
            '(goal
               (list
                  (list 'db (car Rel) (last Rel) Hook (val> (: home gui 1)) '@@) ) )
            2 '((Obj) (list Obj Obj)) )
         (<table> 'chart
            (pack
               (format
                  (or (get (or Hook *DB) (last Rel) 0) 0)
                  NIL NIL *Sep3 )
               " "
               Ttl )
            '((btn) NIL)
            (do (cho)
               (<row> (alternating)
                  (gui 1 '(+DstButton) Dst)
                  (apply gui Gui 2) ) ) )
         (<spread>
            (scroll (cho))
            (if (meta (cdr Rel) (car Rel) 'hook)
               (newButton Able Dst (cdr Rel)
                  (meta (cdr Rel) (car Rel) 'hook)
                  Hook
                  (car Rel)
                  (let? Val (val> (: home gui 1))
                     (unless (db (car Rel) (last Rel) Hook Val)
                        Val ) ) )
               (newButton Able Dst (cdr Rel)
                  (car Rel)
                  (let? Val (val> (: home gui 1))
                     (unless (db (car Rel) (last Rel) Val)
                        Val ) ) ) )
            (cancelButton) ) ) ) )

(de choTtl (Ttl X . @)
   (pack
      (format
         (if (next)
            (with (or (get @ X) (meta @ X))
               (count (tree (: var) (: cls) (next))) )
            (or (get *DB X 0) 0) )
         NIL NIL *Sep3 )
      " "
      Ttl ) )

(de cho ()
   (if (: diaform) 16 8) )


# Able object
(class +AO +Able)
# ao

(dm T (Exe . @)
   (=: ao Exe)
   (pass super
      '(and
         (: home obj)
         (not (: home obj T))
         (eval (: ao)) ) ) )


# Lock/Edit button prefix
(class +Edit +Rid +Force +Tip)
# save

(dm T (Exe)
   (super
      '(nor (: home able) (lock (: home obj)))
      '(if (: home able)
         ,"Release exclusive write access for this object"
         ,"Gain exclusive write access for this object" )
      '(if (: home able) ,"Done" ,"Edit")
      '(if (: home able)
         (when (able)
            (eval (: save))
            (unless (pair *Err)
               (rollback)
               (=: home lock (off *Lock)) ) )
         (=: home lock (tryLock (: home obj))) ) )
   (=: save Exe) )

(de tryLock (Obj)
   (if (lock Obj)
      (nil
         (error (text ,"Currently edited by '@2' (@1)" @  (cdr (lup *Users @)))) )
      (sync)
      (tell)
      (setq *Lock Obj) ) )

(de onDone (Exe)
   (for This (: gui)
      (and (isa '+Edit This) (=: save Exe)) ) )

(de editButton (Able Exe)
   (<style> (and (: able) "edit")
      (gui '(+AO +Focus +Edit +Button) Able Exe) ) )

(de searchButton (Exe)
   (gui '(+Rid +JS +Tip +Button) ,"Start search" ,"Search" Exe) )

(de resetButton (Lst)
   (gui '(+Rid +Force +ClrButton) T ,"Reset" Lst) )

(de newButton (Able Dst . Args)
   (gui '(+Rid +Able +Close +Tip +Button) Able ,"Create new object" ',"New"
      (nond
         (Dst (cons 'newUrl Args))
         ((pair Dst)
            (list 'set> (lit Dst) (cons 'new! Args)) )
         (NIL
            (list 'prog (list '=: 'obj (cons 'new! Args)) Dst) ) ) ) )

# Clone object in form
(de cloneButton (Able)
   (gui '(+Rid +Able +Tip +Button) (or Able T)
      ,"Create a new copy of this object"
      ,"New/Copy"
      '(apply url
         (url>
            (prog1
               (clone!> (: home obj))
               (lock (setq *Lock @)) )
            1 ) ) ) )

# Delete object in form
(de delButton (Able @Txt)
   (gui '(+Force +Rid +Able +Tip +Button) T
      (list 'and '(or (: home able) (: home obj T)) Able)
      '(if (: home obj T)
         ,"Mark this object as \"not deleted\""
         ,"Mark this object as \"deleted\"" )
      '(if (: home obj T) ,"Restore" ,"Delete")
      (fill
         '(nond
            ((: home obj T)
               (ask (text ,"Delete @1?" @Txt)
                  (lose!> (: home top 1 obj))
                  (rollback)
                  (=: home lock (off *Lock)) ) )
            ((keep?> (: home obj))
               (ask (text ,"Restore @1?" @Txt)
                  (keep!> (: home top 1 obj)) ) )
            (NIL
               (note ,"Restore"
                  (mapcar
                     '((X) (text "'@1' -- @2" (car X) (cdr X)))
                     @ ) ) ) ) ) ) )


# Relations
(class +/R +Able)
# erVar erObj

(dm T (Lst . @)
   (=: erVar (car Lst))
   (=: erObj (cdr Lst))
   (pass super
      '(and (eval (: erObj)) (not (get @ T))) ) )

(dm upd> ()
   (set> This (get (eval (: erObj)) (: erVar))) )


# Entity/Relation
(class +E/R +/R)
# er

(dm set> (Val Dn)
   (=: er Val)
   (and
      (not (: lock))
      (eval (: erObj))
      (put!> @ (: erVar) Val) )
   (extra Val Dn) )

(dm val> ()
   (let Val (extra)
      (if (= Val (: er))
         (get (eval (: erObj)) (: erVar))
         Val ) ) )

(dm chk> ()
   (or
      (extra)
      (and
         (eval (: erObj))
         (mis> @ (: erVar) (val> This)) ) ) )


# +Swap relations
(class +Swp)

(dm set> (Val Dn)
   (extra
      (if (ext? Val) (val Val) Val)
      Dn ) )

(dm val> ()
   (let Val (extra)
      (if (ext? Val) (val Val) Val) ) )


(class +Swap/R +Swp +E/R)


# Subobject relation
(class +SubE/R +E/R)
# sub

(dm T (Lst . @)
   (pass super
      (cons
         (++ Lst)
         (append '(: home obj) (cons (car Lst))) ) )
   (=: sub Lst)
   (=: able (bool (: able))) )

(dm set> (Val Dn)
   (when (and Val (not (eval (: erObj))))
      (dbSync)
      (put> (: home obj)
         (: sub 1)
         (new (or (meta (: sub -1) 'Dbf 1) 1) (: sub -1)) )
      (commit 'upd) )
   (super Val Dn) )


(class +BlobField +/R +TextField)
# org

(dm set> (Val Dn)
   (and
      (not (: lock))
      (<> Val (: org))
      (let? Obj (eval (: erObj))
         (protect
            (when (put!> Obj (: erVar) (bool Val))
               (out (blob Obj (: erVar))
                  (prin (=: org Val)) )
               (blob+ Obj (: erVar)) ) ) ) )
   (super Val Dn) )

(dm upd> ()
   (set> This
      (=: org
         (let? Obj (eval (: erObj))
            (when (get Obj (: erVar))
               (in (blob Obj (: erVar))
                  (till NIL T) ) ) ) ) ) )


(class +ClassField +Map +TextField)
# erObj

(dm T (Exe Lst)
   (=: erObj Exe)
   (super Lst (mapcar car Lst)) )

(dm upd> ()
   (set> This (val (eval (: erObj)))) )

(dm set> (Val Dn)
   (and
      (eval (: erObj))
      (set!> @ Val) )
   (super Val Dn) )


(class +obj)
# msg obj

# ([T|msg] ..)
(dm T ()
   (let A (next)
      (if (atom A)
         (prog (=: msg A) (next))
         (=: msg 'url>)
         A ) ) )

(dm js> ()
   (if (=T (: msg))
      (extra)
      (if2 (or (: dx) (: lst)) (try (: msg) (: obj) 1 This)
         (pack (extra) "&*" (ht:Fmt (sesId *Go.png)) "&" (ht:Fmt (sesId (mkUrl @))))
         (pack (extra) "&*" (ht:Fmt (sesId *No.png)) "&")
         (pack (ht:Fmt (nonblank (str> This))) "&+" (ht:Fmt (sesId (mkUrl @))))
         (extra) ) ) )

(dm show> (Var)
   (cond
      ((=T (: msg)) (extra Var))
      ((or (: dx) (: lst))
         (prin "<table cellspacing=\"0\" cellpadding=\"0\"><td>")
         (extra Var)
         (prin "</td><td title=\"-->\">")
         (if (try (: msg) (: obj) 1 This)
            (<img> *Go.png 'obj (mkUrl @))
            (<img> *No.png) )
         (prinl "</td></table>") )
      ((try (: msg) (: obj) 1 This)
         (showFld (<href> (nonblank (str> This)) (mkUrl @))) )
      (T (extra Var)) ) )


(class +hintObj +hint +obj)
# objVar objTyp objHook

(dm hint> (Str)
   (dbHint (extra Str)
      (: objVar)
      (last (: objTyp))
      (eval (: objHook)) ) )



(class +Obj +hintObj)
# objVar objTyp objHook

# ([T|msg] (var . typ) [hook] [T] ..)
(dm T @
   (let A (super)
      (=: objVar (car A))
      (=: objTyp (cdr A)) )
   (when (meta (: objTyp) (: objVar) 'hook)
      (=: objHook (next)) )
   (let A (next)
      (pass extra
         (if (=T A)
            (cons NIL
               (if (meta (: objTyp) (: objVar) 'hook)
                  (collect (: objVar) (last (: objTyp)) (eval (: objHook)) NIL T (: objVar))
                  (collect (: objVar) (last (: objTyp)) NIL T (: objVar)) ) )
            A ) ) ) )

(dm txt> (Obj)
   (if (ext? Obj)
      (get Obj (: objVar))
      Obj ) )

(dm set> (Obj Dn)
   (extra
      (if (ext? (=: obj Obj))
         (get Obj (: objVar))
         Obj )
      Dn ) )

(dm val> ()
   (let Val (extra)
      (cond
         ((and (: obj) (not (ext? @))) Val)
         ((= Val (get (: obj) (: objVar)))
            (: obj) )
         ((: objTyp)
            (=: obj
               (if (meta (: objTyp) (: objVar) 'hook)
                  (db (: objVar) (last (: objTyp)) (eval (: objHook)) Val)
                  (db (: objVar) (last (: objTyp)) Val) ) ) )
         (T Val) ) ) )

(dm chk> ()
   (or
      (extra)
      (let? S (str> This)
         (and
            (: objTyp)
            (not (val> This))
            (<> "-" S)
            ,"Data not found" ) ) ) )


(class +Obj2 +Obj)
# objVar2

(dm T @
   (=: objVar2 (next))
   (pass super) )

(dm hint> (Str)
   (let L
      (make
         (for S (dbHint Str (: objVar2) (last (: objTyp)))
            (for Obj (collect (: objVar2) (last (: objTyp)) S)
               (link (pack (get Obj (: objVar)) " — " S)) )
            (T (nth (made) 36)) ) )
      (if
         (if (meta (: objTyp) (: objVar) 'hook)
            (db (: objVar) (last (: objTyp)) (eval (: objHook)) (format Str))
            (db (: objVar) (last (: objTyp)) (format Str)) )
         (cons (pack Str " — " (get @ (: objVar2))) L)         # Dash
         L ) ) )

(dm str> ()
   (let? S (extra)
      (let (L (split (chop S) " ")  N (format (car L)))
         (format
            (nond
               (N                                              # Text
                  (get
                     (db (: objVar2) (last (: objTyp)) S)
                     (: objVar) ) )
               ((cdr L) N)                                     # Nr
               ((= '("—") (cadr L))                            # Nr Text
                  (get
                     (db (: objVar2) (last (: objTyp)) S)
                     (: objVar) ) )
               ((<>                                            # Nr — Text
                     (glue " " (cddr L))
                     (get
                        (if (meta (: objTyp) (: objVar) 'hook)
                           (db (: objVar) (last (: objTyp)) (eval (: objHook)) N)
                           (db (: objVar) (last (: objTyp)) N) )
                        (: objVar2) ) )
                  N ) ) ) ) ) )


(class +ObjVal +hintObj)
# objVar objTyp hook objHook

# ([T|msg] (var . typ) [hook] ..)
(dm T @
   (let A (super)
      (=: objVar (car A))
      (=: objTyp (cdr A)) )
   (when (=: hook (meta (: objTyp) (: objVar) 'hook))
      (=: objHook (next)) )
   (pass extra) )

(dm txt> (Obj)
   (if (ext? Obj)
      (get Obj (: objVar))
      Obj ) )

(dm set> (Obj Dn)
   (extra
      (get (=: obj Obj) (: objVar))
      Dn ) )

(dm val> ()
   (let Val (extra)
      (nond
         (Val
            (and (: obj) (put!> @ (: objVar) NIL))
            (=: obj NIL) )
         ((: obj)
            (dbSync)
            (=: obj (new (or (meta (: objTyp) 'Dbf 1) 1) (: objTyp)))
            (and
               (: hook)
               (nT @)
               (put> (: obj) (: hook) (eval (: objHook))) )
            (put> (: obj) (: objVar) Val)
            (commit 'upd) )
         (NIL (put!> @ (: objVar) Val)) ) )
   (: obj) )


(class +ObjVar +obj)
# objVar

(dm T (Var . @)
   (=: objVar Var)
   (=: msg 'url>)
   (pass extra) )

(dm set> (Obj Dn)
   (extra
      (get (=: obj Obj) (: objVar))
      Dn ) )

(dm val> ()
   (let? Obj (: obj)
      (put!> Obj (: objVar) (extra))
      Obj ) )


(class +ObjView +obj)
# disp obj

# ([T|msg] exe ..)
(dm T @
   (=: disp (super))
   (pass extra)
   (=: able) )

(dm txt> (Obj)
   (let Exe (: disp)
      (if (ext? Obj)
         (with Obj (eval Exe))
         Obj ) ) )

(dm set> (Obj Dn)
   (let Exe (: disp)
      (extra
         (if (ext? (=: obj Obj))
            (with Obj (eval Exe))
            Obj )
         Dn ) ) )

(dm val> ()
   (: obj) )


### Incremental charts ###
(class +stepChart +Chart)
# iniR iniQ query

# (iniR iniQ cols [put [get]])
(dm T (R Q . @)
   (=: iniR R)
   (=: iniQ Q)
   (pass super) )

(dm query> (Q)
   (=: query Q)
   (set> This) )

(dm init> ()
   (query> This (eval (: iniQ))) )

(dm put> ()
   (while
      (and
         (> (: ofs) (- (length (: data)) (max (: rows) (: iniR))))
         (step> This) )
      (queue (:: data) @) )
   (super) )

(dm clr> ()
   (query> This (fail)) )


# DB query chart
(class +QueryChart +stepChart)

(dm step> ()
   (; (prove (: query)) @@) )

(dm txt> ()
   (for ((I . Q) (eval (: iniQ)) (prove Q))
      (txt1> This I (; @ @@)) ) )

(dm all> ()
   (make
      (for (Q (eval (: iniQ)) (prove Q))
         (link (; @ @@)) ) ) )


# Tree traversal chart
(class +TreeChart +stepChart)

(dm step> ()
   (and (step (: query)) (cons @@ @)) )

(dm txt> ()
   (for ((I . Q) (eval (: iniQ)) (step Q))
      (txt1> This I (cons @@ @)) ) )

(dm all> ()
   (make
      (for (Q (eval (: iniQ)) (step Q))
         (link (cons @@ @)) ) ) )

(private) (Attr Var H1 Rows Gui Sep H2 Cols Put Get Prg Len R)

# 3D-Chart (list of bags with list of bags)
(de bagBag (Attr Var H1 Rows Gui Sep H2 Cols Put Get . Prg)
   (let Len (length Gui)
      (<grid> 3
         (prog
            (put
               (gui '(+E/R +Chart) (cons Var '(: home obj)) (+ 2 Len)
                  '((L I)
                     (when (= I (+ (format (: home radio)) (: ofs)))
                        (unless (= I (: radio))
                           (=: radio I)
                           (set> (cadr (memq This (: home chart)))
                              (get L (inc (: gf 1))) ) ) )
                     (mapcar
                        '((F) (if F (++ L) (car L)))
                        (: gf -1) ) )
                  '((L D)
                     (conc
                        (filter prog2 L (: gf -1))
                        (nth D (inc (: gf 1))) ) ) )
               'gf (cons (cnt car Gui) (mapcar car Gui)) )
            (<table> Attr NIL H1
               (macro
                  (for R (range 0 (dec Rows))
                     (<row> NIL
                        ^ (mapcar cdr Gui)
                        (gui (inc Len) '(+Able +DelRowButton)
                           '(nor
                              (= (row) (: chart 1 radio))
                              (>= (: chart 1 radio) (length (: chart 1 data))) )
                           '(=: chart 1 radio NIL) )
                        (gui (+ 2 Len) '(+BubbleButton) '(=: chart 1 radio NIL))
                        (if (=0 R)
                           (gui '(+Rid +Init +Var +Radio) "0" (:: radio) NIL "0")
                           (gui '(+Rid +Radio) (* R (- -3 Len)) (format R)) ) ) ) )
               (<row> NIL (scroll Rows T) - -) ) )
         (run Sep)
         (prog
            (gui '(+Init +Set +Chart)
               (get (: obj) Var 1
                  (length (meta (: obj) Var 'bag)) )
               '((Lst)
                  (=: ctl
                     (car (prior (memq This (: home chart)) (: home chart))) )
                  (=: pos
                     (or
                        (+ (format (: home radio)) (: ctl ofs))
                        1 ) )
                  (when (: home able)
                     (put!> (: home obj) (: ctl erVar)
                        (let L (get (: home obj) (: ctl erVar))
                           (conc
                              (cut (dec (: pos)) 'L)
                              (list
                                 (conc
                                    (need (- (: ctl gf 1))
                                       (head (: ctl gf 1) (++ L)) )
                                    (list Lst) ) )
                              L ) ) ) )
                  Lst )
               Cols
               Put
               Get )
            (<table> Attr NIL H2 (run Prg)) ) ) ) )

(private) (Lst X)

# Form object
(de <id> Lst
   (idObj Lst) )

(de idObj (Lst)
   (with (if *PRG (: obj) (=: obj *ID))
      (and (: T) (prin "["))
      (for X (if (=T (car Lst)) (cdr Lst) Lst)
         (if (pair (setq X (eval X)))
            (<$> (cdr X) (car X))
            (ht:Prin X) ) )
      (and (: T) (prin "]")) )
   (=: able
      (cond
         ((: obj T))
         ((not (: obj)))
         ((=T (car Lst)) T)
         ((== *Lock (: obj)) (=: lock (: obj)) T)
         (*Lock (rollback) (=: lock (off *Lock))) ) ) )

(private) (Able Txt Del Dlg Var X Hook Msg Exe Prg)

(de panel (Able Txt Del Dlg Var X Hook Msg Exe . Prg)
   (unless (eval Able)
      (when *Lock
         (rollback)
         (=: lock (off *Lock)) )
      (=: able) )
   (<spread>
      (editButton Able Exe)
      (run Prg 1)
      (delButton
         (cond
            ((=T Able) Del)
            ((=T Del) Able)
            ((and Able Del) (list 'and Able Del)) )
         (list 'text Txt
            (if (pair Var)
               (list 'with '(: home obj) (car Var))
               (list ': 'home 'obj Var) ) ) )
      (choButton Dlg)
      (when X
         (if (pair X)
            (stepBtn X Msg)
            (stepBtn (fin Var) X Hook Msg) ) ) )
   (--) )

(private) (Entity Cho Var X Able Del Lst Prg)

# Standard ID form
(de idForm (Entity Cho Var X Able Del Lst . Prg)
   (ifn *ID
      (prog
         (<h3> NIL ,"Select" " " Entity)
         (form 'dialog
            (if (pair Cho)
               (eval @)
               (choDlg NIL Cho (list (fin Var) X)) ) ) )
      (form NIL
         (<h3> NIL Entity ": " (idObj Lst))
         (panel Able (pack Entity " '@1'") Del
            (or
               (pair Cho)
               (list 'choDlg NIL (lit Cho) (lit (list (fin Var) X))) )
            Var X
            (and
               (atom X)
               (or (get X (fin Var) 'hook) (meta X (fin Var) 'hook))
               (get (: obj) @) ) )
         (run Prg) ) ) )

(private) (Msg Env X)

### Undo / Redo ###
(de change (Msg Env . X)
   (set> (: home undo)
      (cons
         (cons Msg Env X)
         (val> (: home undo)) ) )
   (set> (: home redo))
   (bind Env (run (cdr X))) )


(class +todoButton +Able +Tip +Button)
# todo

(dm T (Tip Lbl Exe)
   (super '(val> This)
      (list 'and '(val> This) (list 'text Tip '(caar @)))
      Lbl
      Exe ) )

(dm set> (Val Dn)
   (=: todo Val) )

(dm val> ()
   (: todo) )


(class +UndoButton +todoButton)

(dm T ()
   (super ,"Undo: '@1'" ,"Undo"
      '(let U (val> This)
         (set> (: home redo)
            (cons (car U) (val> (: home redo))) )
         (set> This (cdr U))
         (bind (cadar U)
            (eval (caddar U)) ) ) )
   (=: home undo This) )


(class +RedoButton +todoButton)

(dm T ()
   (super ,"Redo: '@1'" ,"Redo"
      '(let R (val> This)
         (set> (: home undo)
            (cons (car R) (val> (: home undo))) )
         (set> This (cdr R))
         (bind (cadar R)
            (run (cdddar R)) ) ) )
   (=: home redo This) )

### Debug ###
`*Dbg

(allow "!console")
(de console @  # JS: lisp(null, "console", "Message");
   (msg (cons 'console (rest)))
   (respond) )

(noLint 'gui)
(noLint 'choDlg 'gui)
(noLint 'jsForm 'action)

(docs "@doc/form/")
