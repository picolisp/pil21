# 19jun21 Software Lab. Alexander Burger

(de xhtml (Path)
   (for X
      (quote
         ("html" . *XhtmlHtml)
         ("layout" . *XhtmlLayout)
         ("menu" . *XhtmlMenu)
         ("tab" . *XhtmlTab)
         ("input" . *XhtmlInput)
         ("field" . *XhtmlField)
         ("area" . *XhtmlArea)
         ("select" . *XhtmlSelect)
         ("submit" . *XhtmlSubmit) )
      (when (info (pack Path (++ X)))
         (set X
            (in @@
               (make
                  (until (eof)
                     (let? L (clip (line))
                        (while (= " " (peek))
                           (conc L (list "\n") (clip (line))) )
                        (setq L (split (replace L "~" *SesId) "@"))
                        (link
                           (cond
                              ((= L '(("<" ">"))))
                              ((cdr L) (mapcar pack L))
                              (T (pack (car L))) ) ) ) ) ) ) ) ) ) )

(xhtml "@lib/xhtml/")

(mapc allow '(*JS *Menu *Tab *ID "!ping"))
(setq *Menu 0  *Tab 1)
(off "*JS")

(private) (Prg Ofs X Attr Cls Var Val Nm JS)

(de htPrin (Prg Ofs)
   (default Ofs 1)
   (for X Prg
      (if (atom X)
         (ht:Prin (eval X Ofs))
         (eval X Ofs) ) ) )

(de htJs ()
   (for X "*JS"
      (prin " " (car X) "=\"")
      (ht:Prin (cdr X))
      (prin "\"") ) )

(de htStyle (Attr)
   (cond
      ((atom Attr)
         (prin " class=\"")
         (ht:Prin Attr)
         (prin "\"") )
      ((and (atom (car Attr)) (atom (cdr Attr)))
         (prin " " (car Attr) "=\"")
         (ht:Prin (cdr Attr))
         (prin "\"") )
      (T (mapc htStyle Attr)) ) )

(de dfltCss (Cls)
   (htStyle
      (cond
         ((not *Style) Cls)
         ((atom *Style) (pack *Style " " Cls))
         ((and (atom (car *Style)) (atom (cdr *Style)))
            (list Cls *Style) )
         ((find atom *Style)
            (replace *Style @ (pack @ " " Cls)) )
         (T (cons Cls *Style)) ) ) )

(de tag (Nm Attr Ofs Prg)
   (prin "<" Nm)
   (and Attr (htStyle @))
   (prin ">")
   (if (atom Prg)
      (ht:Prin (eval Prg Ofs))
      (for X Prg
         (if (atom X)
            (ht:Prin (eval X Ofs))
            (eval X Ofs) ) ) )
   (prin "</" Nm ">") )

(de <tag> (Nm Attr . Prg)
   (tag Nm Attr 2 Prg) )

(de <js> (JS . Prg)
   (let "*JS" (append "*JS" JS)
      (run Prg) ) )

(de style (X S)
   (nond
      (X S)
      (S X)
      ((pair X)
         (cond
            ((atom S) (pack S " " X))
            ((and (atom (car S)) (atom (cdr S)))
               (list X S) )
            ((find atom S)
               (replace S @ (pack @ " " X)) )
            (T (cons X S)) ) )
      ((or (pair (car X)) (pair (cdr X)))
         (cond
            ((atom S) (list S X))
            ((and (atom (car S)) (atom (cdr S)))
               (if (= (car X) (car S))
                  X
                  (list S X) ) )
            (T
               (cons X (delete (assoc (car X) S) S)) ) ) )
      (NIL
         (for Y X
            (setq S (style Y S)) ) ) ) )

(de <style> (X . Prg)
   (let *Style (style X *Style)
      (run Prg) ) )

(de nonblank (Str)
   (or Str `(pack (char 160) (char 160))) )

(de <javascript> @
   (prin "<script type=\"text/javascript\">")
   (pass prin)
   (prinl "</script>") )

(private) (Upd Ttl Css)

### XHTML output ###
(de html (Upd Ttl Css Attr . Prg)
   (httpHead NIL Upd)
   (let ((Beg (LangA LangZ) HeadA Head (BodyA BodyZ) End) *XhtmlHtml)
      (ht:Out *Chunked
         (prinl Beg)
         (prinl LangA (or *Lang "en") LangZ)
         (prinl HeadA)
         (and (fin Ttl) (<tag> "title" NIL @) (prinl))
         (mapc prinl Ttl)
         (and *Host *Port (prinl "<base href=\"" (baseHRef) "\"/>"))
         (when Css
            (if (atom Css)
               (css Css)
               (mapc css Css)
               (when (fin Css)
                  (prinl "<style type=\"text/css\">")
                  (prinl @)
                  (prinl "</style>") ) ) )
         (and *SesId (<javascript> "SesId='" @ "'"))
         (mapc javascript *JS)
         (prinl Head)
         (prin BodyA)
         (and Attr (htStyle @))
         (prinl BodyZ)
         (htPrin Prg 2)
         (prinl End) ) ) )

(de css (Css)
   (prinl "<link rel=\"stylesheet\" type=\"text/css\" href=\"" (srcUrl Css) "\"/>") )

(de javascript (JS . @)
   (when *JS
      (when JS
         (prinl "<script type=\"text/javascript\" src=\"" (srcUrl JS) "\"></script>") )
      (and (rest) (<javascript> @)) ) )

(de serverSentEvent (Id Var . Prg)
   (allow "!ssEvt")
   (<javascript>
      "(new EventSource(SesId+'!ssEvt?'+'"
      Id
      "')).onmessage = function(ev) {if (ev.data.charAt(0) == '&') document.title = ev.data.substr(1); else document.getElementById('"
      Id
      "').innerHTML = ev.data;}" )
   (if (assoc Id *SsEvts)
      (con @ (cons Var (unless (val Var) Prg)))
      (push '*SsEvts (cons Id Var Prg)) ) )

(de ssEvt (Id)
   (when (assoc Id *SsEvts)
      (let ((@Var . Prg) (cdr @))
         (task *HtSock)
         (macro
            (and @Var (task (close @Var)))
            (task (setq @Var *HtSock)
               (in @
                  (unless (char)
                     (task (close @Var))
                     (off @Var) ) ) ) )
         (httpHead "text/event-stream" 0)
         (run Prg) ) ) )

(private) Sock

(de serverSend (Sock . Prg)
   (when Sock
      (out @
         (ht:Out (bool *Chunked)
            (prin "data: ")
            (htPrin Prg 2)
            (prinl "^J") ) ) ) )

(de ping (Min)
   (timeout (setq *Timeout (* Min `(* 60 1000))))
   (respond) )

(de <ping> (Min)
   (<javascript> "onload=ping(" Min ")") )

(de <div> (Attr . Prg)
   (tag "div" Attr 2 Prg)
   (prinl) )

(de <span> (Attr . Prg)
   (tag "span" Attr 2 Prg) )

(de <br> Prg
   (htPrin Prg 2)
   (prinl "<br/>") )

(de -- ()
   (prinl "<br/>") )

(de ---- ()
   (prinl "<br/><br/>") )

(de <hr> ()
   (prinl "<hr/>") )

(de <nbsp> (N)
   (do (or N 1) (prin "&nbsp;")) )

(de <small> Prg
   (tag "small" NIL 2 Prg) )

(de <big> Prg
   (tag "big" NIL 2 Prg) )

(de <em> Prg
   (tag "em" NIL 2 Prg) )

(de <strong> Prg
   (tag "strong" NIL 2 Prg) )

(de <h1> (Attr . Prg)
   (tag "h1" Attr 2 Prg)
   (prinl) )

(de <h2> (Attr . Prg)
   (tag "h2" Attr 2 Prg)
   (prinl) )

(de <h3> (Attr . Prg)
   (tag "h3" Attr 2 Prg)
   (prinl) )

(de <h4> (Attr . Prg)
   (tag "h4" Attr 2 Prg)
   (prinl) )

(de <h5> (Attr . Prg)
   (tag "h5" Attr 2 Prg)
   (prinl) )

(de <h6> (Attr . Prg)
   (tag "h6" Attr 2 Prg)
   (prinl) )

(de <p> (Attr . Prg)
   (tag "p" Attr 2 Prg)
   (prinl) )

(de <pre> (Attr . Prg)
   (tag "pre" Attr 2 Prg)
   (prinl) )

(de <ol> (Attr . Prg)
   (tag "ol" Attr 2 Prg)
   (prinl) )

(de <ul> (Attr . Prg)
   (tag "ul" Attr 2 Prg)
   (prinl) )

(de <li> (Attr . Prg)
   (tag "li" Attr 2 Prg)
   (prinl) )

(de <dl> (Attr . Prg)
   (tag "dl" Attr 2 Prg)
   (prinl) )

(de <dt> (Attr . Prg)
   (tag "dt" Attr 2 Prg)
   (prinl) )

(de <dd> (Attr . Prg)
   (tag "dd" Attr 2 Prg)
   (prinl) )

(de <href> (Str Url Tar)
   (prin "<a href=\""
      (sesId
         (ifn (pre? "+" Url)
            Url
            (setq Tar "_blank")
            (pack (cdr (chop Url))) ) )
      "\"" )
   (and Tar (prin " target=\"" Tar "\""))
   (and *Style (htStyle @))
   (prin ">")
   (ht:Prin Str)
   (prin "</a>") )

(de <img> (Src Alt Url DX DY)
   (when Url
      (prin "<a href=\""
         (sesId
            (ifn (pre? "+" Url)
               Url
               (pack (cdr (chop Url)) "\" target=\"_blank") ) )
         "\">" ) )
   (prin "<img src=\"" (sesId Src) "\"")
   (when Alt
      (prin " alt=\"")
      (ht:Prin Alt)
      (prin "\"") )
   (and DX (prin " width=\"" DX "\""))
   (and DY (prin " height=\"" DY "\""))
   (and *Style (htStyle @))
   (prin "/>")
   (and Url (prin "</a>")) )

(de <this> (Var Val . Prg)
   (prin "<a href=\""
      (urlMT (sesId *Url) *Menu *Tab *ID
         (pack "&" Var "=" (ht:Fmt Val) "\"") ) )
   (and *Style (htStyle @))
   (prin ">")
   (htPrin Prg 2)
   (prin "</a>") )

(private) (Attr Prg)

(de <th> (Attr . Prg)
   (tag "th" Attr 2 Prg) )

(de <tr> (Attr . Prg)
   (tag "tr" Attr 2 Prg) )

(de <td> (Attr . Prg)
   (tag "td" Attr 2 Prg) )

(de <thead> (Attr . Prg)
   (tag "thead" Attr 2 Prg) )

(de <tbody> (Attr . Prg)
   (tag "tbody" Attr 2 Prg) )

(private) (Attr Ttl Head Prg *RowF H L Y A N)

(de <table> (Attr Ttl Head . Prg)
   (on *RowF)
   (<tag> "table"
      (list
         '("ontouchstart" . "return tblTouch(event)")
         '("ontouchmove" . "return tblMove(this,event)")
         Attr )
      (and Ttl (<tag> "caption" NIL Ttl))
      (when (find cdr Head)
         (<tr> NIL
            (for H Head
               (<th> (car H) (htPrin (cdr H) 5)) ) ) )
      (htPrin Prg 3) ) )

(de alternating ()
   (onOff *RowF) )

(de <row> (Attr . Prg)
   (<tr> NIL
      (let (L Prg  H Head)
         (while L
            (let (Y (++ L)  A (car (++ H))  N 1)
              (while (== '- (car L))
                  (inc 'N)
                  (++ L)
                  (++ H) )
               (<td>
                  (style Attr
                     (style
                        (and (> N 1) (cons "colspan" N))
                        (if (== 'align A) '(align (align . right)) A) ) )
                  (if (atom Y)
                     (ht:Prin (eval Y 3))
                     (eval Y 3) ) ) ) ) ) ) )

(private) (Y Lst L C E N)

(de <grid> (Y . Lst)
   (<tag> "table" "grid"
      (while Lst
         (<tr> NIL
            (use Y
               (let L (and (sym? Y) (chop Y))
                  (do (or (num? Y) (length Y))
                     (let
                        (C
                           (cond
                              ((pair Y) (++ Y))
                              ((= "." (++ L)) "align") )
                           E (++ Lst) )
                        (unless (== '- E)
                           (when (== '- (car Lst))
                              (let N 1
                                 (for (P Lst (and P (== '- (++ P))))
                                    (inc 'N) )
                                 (push 'N "colspan")
                                 (setq C (if C (list C N) N)) ) )
                           (<td> C
                              (if (atom E)
                                 (ht:Prin (eval E 4))
                                 (eval E 4) ) ) ) ) ) ) ) ) ) ) )

(de <trident> Lst
   (<table> '(width . "100%") NIL NIL
      (<tr> NIL
         (<td> '((width . "33%") (align . left))
            (eval (car Lst) 1) )
         (<td> '((width . "34%") (align . center))
            (eval (cadr Lst) 1) )
         (<td> '((width . "33%") (align . right))
            (eval (caddr Lst) 1) ) ) ) )

(de <spread> Lst
   (<table> '(width . "100%") NIL '((norm) (align))
      (<row> NIL
         (eval (car Lst) 5)
         (run (cdr Lst) 5) ) ) )

(private) (X Txt Prg)

(de tip (X Txt)
   (<span> (cons 'title (glue "^J" X)) Txt) )

(de <tip> (X . Prg)
   (let *Style (style (cons 'title (glue "^J" X)) *Style)
      (run Prg) ) )

(private) (Lst P LayX LayY L Args DX DY Cls Style)

# Layout
(de <layout> Lst
   (let
      (Lay *XhtmlLayout
         P (and (=T (car Lst)) (++ Lst))
         LayX 0
         LayY 0 )
      (ifn Lay
         (recur (Lst LayX)
            (use (LayX LayY)
               (for L Lst
                  (let
                     (Args (mapcar eval (cddar L))
                        DX (eval (caar L))
                        DY (eval (cadar L))
                        Cls (unless (sub? ":" (car Args)) (++ Args))
                        Style
                        (cons 'style
                           (glue "; "
                              (cons
                                 "position:absolute"
                                 (pack "top:" LayY (if P "%" "px"))
                                 (pack "left:" LayX (if P "%" "px"))
                                 (cond
                                    ((=0 DX) "min-width:100%")
                                    (DX (pack "width:" DX (if P "%" "px"))) )
                                 (cond
                                    ((=0 DY) "min-height:100%")
                                    (DY (pack "height:" DY (if P "%" "px"))) )
                                 Args ) ) ) )
                     (prog1
                        (if Cls (list Cls Style) Style)  # -> '@'
                        (eval (cadr L)) )
                     (recurse (cddr L) (+ LayX DX))
                     (inc 'LayY DY) ) ) ) )
         (recur (Lst)
            (for L Lst
               (prinl (caar Lay))
               (run (cddadr L))
               (prinl (cadr (++ Lay)))
               (recurse (cddr L)) ) ) ) ) )

(private) (Url Str)

(de <button> (Url Str)
   (<div> "button"
      (prin "<a href=\"" (sesId Url) "\"")
      (and *Style (htStyle @))
      (prin ">")
      (<span> "button2" Str)
      (prin "</a>") ) )

# Menus
(de urlMT (Url Menu Tab Id Str)
   (pack Url "?"  "*Menu=+" Menu  "&*Tab=+" Tab  "&*ID=" (ht:Fmt Id) Str) )

(private) (Lst M N E U L)

(de <menu> Lst
   (let
      ((Beg
            BegL
            (A Z)  # Plain
            (DisA DisZ)  # Disabled
            (CmdA Cmd CmdZ)  # Command
            (ActA Act ActZ)  # Active command
            (SubA SubB SubC SubD SubZ)  # Closed submenu
            (TopA TopB TopC TopD TopZ)  # Open submenu
            TopEnd
            EndL
            End )
         *XhtmlMenu
         M 1
         E 2
         U )
      (prin Beg)
      (recur (Lst E)
         (prin BegL)
         (for L Lst
            (nond
               ((car L)
                  (prin A)
                  (htPrin (cdr L))
                  (prinl Z) )
               ((=T (car L))
                  (nond
                     ((setq U (eval (cadr L) E))
                        (prin DisA)
                        (ht:Prin (eval (car L) E))
                        (prinl DisZ) )
                     ((pair U)
                        (prin
                           (if (= U *Url) ActA CmdA)
                           (sesId
                              (urlMT U *Menu (if (= U *Url) *Tab 1)
                                 (eval (caddr L))
                                 (eval (cadddr L)) ) )
                           (if (= U *Url) Act Cmd) )
                        (ht:Prin (eval (car L) E))
                        (prinl (if (= U *Url) ActZ CmdZ)) )
                     (NIL
                        (<href> (eval (car L) E) (car U) (cdr U)) ) ) )
               ((bit? M *Menu)
                  (shift 'L)
                  (let (S (eval (++ L) E)  I)
                     (when (num? S)
                        (setq I S  S (eval (++ L) E)) )
                     (prin
                        SubA I SubB
                        (sesId (urlMT *Url (| M *Menu) *Tab *ID))
                        SubC )
                     (ht:Prin ,"Open submenu")
                     (prin SubD)
                     (ht:Prin S)
                     (setq M (>> -1 M))
                     (recur (L)
                        (for X L
                           (when (=T (car X))
                              (recurse X)
                              (setq M (>> -1 M)) ) ) )
                     (prinl SubZ) ) )
               (NIL
                  (shift 'L)
                  (let (S (eval (++ L) E)  I)
                     (when (num? S)
                        (setq I S  S (eval (++ L) E)) )
                     (prin
                        TopA I TopB
                        (sesId (urlMT *Url (x| M *Menu) *Tab *ID))
                        TopC )
                     (ht:Prin ,"Close submenu")
                     (prin TopD)
                     (ht:Prin S)
                     (prinl TopZ)
                     (setq M (>> -1 M))
                     (recurse L (inc E))
                     (prinl TopEnd) ) ) ) )
         (prin EndL) )
      (prinl End) ) )

# Update link
(de updLink ()
   (<tip> ,"Update"
      (<span> "step" (<href> "@" (urlMT *Url *Menu *Tab *ID))) ) )

(private) (Lst N L)

# Tabs
(de <tab> Lst
   (let ((Beg (TopA TopZ) (SubA Sub SubZ) End) *XhtmlTab)
      (prin Beg)
      (for (N . L) Lst
         (if (= N *Tab)
            (prog
               (prin TopA)
               (ht:Prin (eval (car L) 1))
               (prin TopZ) )
            (prin SubA (sesId (urlMT *Url *Menu N *ID)) Sub)
            (ht:Prin (eval (car L) 1))
            (prin SubZ) ) )
      (prinl End)
      (htPrin (get Lst *Tab -1)) ) )

### DB Linkage ###
(de mkUrl (Lst)
   (pack (++ Lst) "?"
      (make
         (while Lst
            (and
               (sym? (car Lst))
               (= `(char '*) (char (car Lst)))
               (link (++ Lst) "=") )
            (link (ht:Fmt (++ Lst)))
            (and Lst (link "&")) ) ) ) )

(de <$> (Str Obj Msg Tab)
   (cond
      ((not Obj) (ht:Prin Str))
      ((=T Obj) (<href> Str (pack Msg Str)))
      ((send (or Msg 'url>) Obj (or Tab 1))
         (<href> Str (mkUrl @)) )
      (T (ht:Prin Str)) ) )

(private) (X S1 S2 Rel K Cls Hook Q1 Q2 Msg)

# Links to previous and next object
# (stepBtn 'lst ['msg])
# (stepBtn 'var 'cls [['hook] 'msg])
(de stepBtn (X . @)
   (<span> "step"
      (use (S1 S2)
         (if (pair X)
            (setq S1 (car X)  S2 (cdr X))
            (let
               (Rel (meta *ID X)
                  K
                  (cond
                     ((isa '+Key Rel)
                        (get *ID X) )
                     ((isa '+Fold Rel)
                        (cons (fold (get *ID X)) *ID) )
                     (T
                        (cons
                           (get *ID X)
                           (conc
                              (mapcar '((S) (get *ID S)) (; Rel aux))
                              *ID ) ) ) )
                  Cls (next)
                  Hook (next)
                  Q1 (init (tree X Cls Hook) K NIL)
                  Q2 (init (tree X Cls Hook) K T) )
               (unless (get *ID T)
                  (step Q1 T)
                  (step Q2 T) )
               (setq
                  S1 (step Q1 T)
                  S2 (step Q2 T) ) ) )
         (let Msg (or (next) 'url>)
            (if (and S1 (send Msg @ *Tab))
               (<tip> ,"Next object of the same type"
                  (<href> "<<<" (mkUrl @)) )
               (prin "&lt;&lt;&lt;") )
            (prin "&nbsp;--&nbsp;")
            (if (and S2 (send Msg @ *Tab))
               (<tip> ,"Next object of the same type"
                  (<href> ">>>" (mkUrl @)) )
               (prin "&gt;&gt;&gt;") ) ) ) ) )

# Character Separated Values
(off "*CSV")

(de csv ("Nm" . "Prg")
   (%@ "unlink" NIL (tmp "Nm" ".csv"))
   (let "*CSV" (pack "+" (tmp "Nm" ".csv"))
      (run "Prg") )
   (<href> "CSV" (tmp "Nm" ".csv")) )

(de <0> @
   (when "*CSV"
      (out @
         (prin (next))
         (while (args)
            (prin "^I" (next)) )
         (prinl "^M") ) ) )

(de <%> @
   (prog1
      (pass pack)
      (ht:Prin @)
      (prinl "<br/>")
      (<0> @) ) )

(de <!> ("Lst")
   (when "*CSV"
      (out @
         (prin (eval (cadar "Lst")))
         (for "S" (cdr "Lst")
            (prin "^I" (eval (cadr "S"))) )
         (prinl "^M") ) )
   "Lst" )

(de <+> (Str Obj Msg Tab)
   (if (sub? "^J" Str)
      (let L (split (chop Str) "^J")
         (<span> (cons 'title Str) (ht:Prin (car L)))
         (and "*CSV" (out @ (prin (glue " " L) "^I"))) )
      (<$> Str Obj Msg Tab)
      (and "*CSV" (out @ (prin Str "^I"))) ) )

(de <-> (Str Obj Msg Tab)
   (if (sub? "^J" Str)
      (let L (split (chop Str) "^J")
         (<span> (cons 'title Str) (ht:Prin (car L)))
         (<0> (glue " " L)) )
      (<$> Str Obj Msg Tab)
      (<0> Str) ) )

### HTML form ###
(de <post> (Attr Url . Prg)
   (prin
      "<form enctype=\"multipart/form-data\" action=\""
      (sesId Url)
      (and *JS "\" onkeydown=\"return formKey(event)\" onkeypress=\"return formKey(event)\" onsubmit=\"return doPost(this)")
      "\" method=\"post\""
      (when (=T Attr)
         (off Attr)
         " target=\"_blank\"" )
      ">" )
   (prin "<noscript><input type=\"hidden\" name=\"*JS\" value=\"\"/></noscript>")
   (tag "fieldset" Attr 2 Prg)
   (prinl "</form>") )

(de htmlVar ("Var")
   (prin "name=\"")
   (if (pair "Var")
      (prin (car "Var") ":" (cdr "Var"))
      (prin "Var") )
   (prin "\"") )

(de htmlVal ("Var")
   (if (pair "Var")
      (cdr (assoc (cdr "Var") (val (car "Var"))))
      (val "Var") ) )

(de <label> (Attr . Prg)
   (tag "label" Attr 2 Prg) )

(de <field> (N "Var" Max Flg)
   (prin (caar *XhtmlField) "text" (cadar *XhtmlField))
   (htmlVar "Var")
   (prin " value=\"")
   (ht:Prin (htmlVal "Var"))
   (prin "\" size=\"")
   (if (lt0 N)
      (prin (- N) "\" style=\"text-align: right;\"")
      (prin N "\"") )
   (and Max (prin " maxlength=\"" Max "\""))
   (when *JS
      (prin " onchange=\"return fldChg(this)\"")
      (htJs) )
   (dfltCss "field")
   (and Flg (prin " disabled=\"disabled\""))
   (prinl (caddar *XhtmlField)) )

(de <hidden> ("Var" Val)
   (prin "<input type=\"hidden\" ")
   (htmlVar "Var")
   (prin " value=\"")
   (ht:Prin Val)
   (prinl "\"/>") )

(de <passwd> (N "Var" Max Flg)
   (prin (caar *XhtmlInput) "password" (cadar *XhtmlInput))
   (htmlVar "Var")
   (prin " value=\"")
   (ht:Prin (htmlVal "Var"))
   (prin "\" size=\"" N "\"")
   (and Max (prin " maxlength=\"" Max "\""))
   (when *JS
      (prin " onchange=\"return fldChg(this)\"")
      (htJs) )
   (dfltCss "passwd")
   (and Flg (prin " disabled=\"disabled\""))
   (prinl (caddar *XhtmlInput)) )

(de <upload> (N "Var" Flg)
   (prin (caar *XhtmlInput) "file" (cadar *XhtmlInput))
   (htmlVar "Var")
   (prin " value=\"")
   (ht:Prin (htmlVal "Var"))
   (prin "\" size=\"" N "\"")
   (when *JS
      (prin " onchange=\"return fldChg(this)\"")
      (htJs) )
   (dfltCss "upload")
   (and Flg (prin " disabled=\"disabled\""))
   (prinl (caddar *XhtmlInput)) )

(de <rgb> ("Var" Flg)
   (prin (caar *XhtmlInput) "color" (cadar *XhtmlInput))
   (htmlVar "Var")
   (prin " value=\"")
   (ht:Prin (htmlVal "Var"))
   (prin "\"")
   (when *JS
      (prin " onchange=\"return fldChg(this)\"")
      (htJs) )
   (dfltCss "rgb")
   (and Flg (prin " disabled=\"disabled\""))
   (prinl (caddar *XhtmlInput)) )

(de <area> (Cols Rows "Var" Flg)
   (let (((Beg C R Z) End) *XhtmlArea)
      (prin Beg Cols C Rows R)
      (htmlVar "Var")
      (when *JS
         (prin " onchange=\"return fldChg(this)\"")
         (htJs) )
      (dfltCss "area")
      (and Flg (prin " disabled=\"disabled\""))
      (prin Z)
      (ht:Prin (htmlVal "Var"))
      (prinl End) ) )

(de <select> (Lst "Var" Flg)
   (let (((SelA SelZ) (OptA OptB OptZ) End) *XhtmlSelect)
      (prin SelA)
      (htmlVar "Var")
      (when *JS
         (prin " onchange=\"return fldChg(this)\"")
         (htJs) )
      (dfltCss "select")
      (prin SelZ)
      (for "X" Lst
         (let "V" (if (atom "X") "X" (car "X"))
            (prin OptA)
            (when (pair "X")
               (and (pair (cdr "X")) (htStyle (car @)))
               (and (fin "X") (prin " title=\"" @ "\"")) )
            (prin
               (cond
                  ((= "V" (htmlVal "Var")) " selected=\"selected\"")
                  (Flg " disabled=\"disabled\"") )
               OptB )
            (ht:Prin "V") )
         (prin OptZ) )
      (prinl End) ) )

(de <check> ("Var" Flg)
   (let Val (htmlVal "Var")
      (prin "<input type=\"hidden\" ")
      (htmlVar "Var")
      (prin " value=\"" (and Flg Val T) "\">")
      (prin (caar *XhtmlInput) "checkbox" (cadar *XhtmlInput))
      (htmlVar "Var")
      (prin " value=\"T\"" (and Val " checked=\"checked\""))
      (when *JS
         (prin " onchange=\"return fldChg(this)\"")
         (htJs) )
      (dfltCss "check")
      (and Flg (prin " disabled=\"disabled\""))
      (prinl (caddar *XhtmlInput)) ) )

(de <radio> ("Var" Val Flg)
   (prin (caar *XhtmlInput) "radio" (cadar *XhtmlInput))
   (htmlVar "Var")
   (prin " value=\"")
   (ht:Prin Val)
   (prin "\"" (and (= Val (htmlVal "Var")) " checked=\"checked\""))
   (when *JS
      (prin " onchange=\"return fldChg(this)\"")
      (htJs) )
   (dfltCss "radio")
   (and Flg (prin " disabled=\"disabled\""))
   (prinl (caddar *XhtmlInput)) )

(de <submit> (S "Var" Flg JS)
   (prin (caar *XhtmlSubmit) "submit" (cadar *XhtmlSubmit))
   (and "Var" (space) (htmlVar "Var"))
   (prin " value=\"")
   (ht:Prin S)
   (prin "\"")
   (when *JS
      (prin " onmousedown=\"inBtn(this,1)\" onblur=\"inBtn(this,0)\"")
      (and JS (prin " onclick=\"return doBtn(this)\""))
      (htJs) )
   (dfltCss "submit")
   (and Flg (prin " disabled=\"disabled\""))
   (prinl (caddar *XhtmlSubmit)) )

(de <image> (Src "Var" Flg JS)
   (prin (caar *XhtmlSubmit) "image" (cadar *XhtmlSubmit))
   (and "Var" (space) (htmlVar "Var"))
   (prin " src=\"" (sesId Src) "\"")
   (when *JS
      (prin " onmousedown=\"inBtn(this,1)\" onblur=\"inBtn(this,0)\"")
      (and JS (prin " onclick=\"return doBtn(this)\""))
      (htJs) )
   (dfltCss "image")
   (and Flg (prin " disabled=\"disabled\""))
   (prinl (caddar *XhtmlSubmit)) )
