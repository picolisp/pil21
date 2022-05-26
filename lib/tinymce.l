# 26may22 Software Lab. Alexander Burger

### TinyMCE Interface ###
(allow "@tinymce/" T)

(de <tinymce> ()
   (javascript "@tinymce/tinymce.min.js" "
      tinymce.init( {
         mode: 'specific_textareas',
         editor_selector: 'tinymce',
         plugins: 'textcolor colorpicker hr directionality paste',
         toolbar: 'forecolor bold italic superscript underline strikethrough | hr | removeformat',
         paste_as_text: true,
         nowrap: true,
         menubar: false,
         statusbar: false,
         min_height: 12,
         toolbar_items_size: 'small',
         language: '" (or *Lang "en") "',
         entity_encoding: 'raw',
         force_br_newlines : true,
         force_p_newlines : false,
         forced_root_block : '',
         setup: function(ed) {
            ed.on('init', function(e) {
               var fld = ed.getElement();
               fld.pilSetValue = function(val) {
                  ed.setContent(val);
               }
               fld.pilDisable = function(flg) {
                  ed.getBody().setAttribute('contenteditable', !flg);
               }
               fld.pilDisable(fld.disabled);
            } )
            ed.on('change', function(e) {
               ed.getElement().value = ed.getContent();
               fldChg(ed.getElement());
            } )
         } } )" ) )

# Parse HTML text
(de htmlText (Text)
   (let (Lst (split (chop Text)  "<" ">")  Tag)
      (make
         (recur (Tag)
            (loop
               (let? S (++ Lst)
                  (unless (= S '("\n"))
                     (link (ht:Pack S)) ) )
               (NIL Lst)
               (T (and (= "/" (caar Lst)) (= Tag (cdar Lst)))
                  (++ Lst) )
               (let S (++ Lst)
                  (cond
                     ((= S '`(chop "br /"))
                        (link 0) )
                     ((= S '`(chop "hr /"))
                        (link T) )
                     ((and (= "p" (car S)) (sp? (cadr S)))
                        (and (made) (link 0))
                        (recurse '("p"))
                        (and (find bool Lst) (link 0)) )
                     ((= S '`(chop "strong"))
                        (link '(B . T))
                        (recurse S)
                        (link '(B)) )
                     ((= S '`(chop "em"))
                        (link '(I . T))
                        (recurse S)
                        (link '(I)) )
                     ((= S '`(chop "sup"))
                        (link '(S . T))
                        (recurse S)
                        (link '(S)) )
                     ((= S '`(chop "span style=\"text-decoration: underline;\""))
                        (link '(U . T))
                        (recurse '("s" "p" "a" "n"))
                        (link '(U)) )
                     ((= S '`(chop "span style=\"text-decoration: line-through;\""))
                        (link '(L . T))
                        (recurse '("s" "p" "a" "n"))
                        (link '(L)) )
                     ((head '`(chop "span style=\"color: ") S)
                        (setq S (nth S 21))
                        (link (cons 'C (pack "#" (head 6 S))))
                        (recurse '("s" "p" "a" "n"))
                        (link '(C)) )
                     (T (recurse (car (split S " ")))) ) ) ) ) ) ) )

# Remove markup
(de unmarkup (Text)
   (let L (chop Text)
      (use (@A @X @Z)
         (while (match '(@A "<" @X ">" @Z) L)
            (setq L
               (conc
                  @A
                  (and @A @Z (head '("b" "r") @X) (cons " "))
                  @Z ) ) ) )
      (extract pack (split L " " "\n")) ) )

# HTML text index relation
(class +HtIdx +Fold +Idx)

(dm has> (Val X)
   (or
      (= Val X)
      (member Val (mapcar fold (unmarkup X))) ) )

(dm rel> (Obj Old New Hook)
   (setq Old (unmarkup Old)  New (unmarkup New))
   (for O (diff Old New)
      (super Obj O NIL Hook) )
   (for N (diff New Old)
      (super Obj NIL N Hook) ) )

(dm rel?> (Obj Val Hook)
   (for V (unmarkup Val)
      (NIL (super Obj V Hook))
      T ) )

(dm lose> (Obj Val Hook)
   (for V (unmarkup Val)
      (super Obj V Hook) ) )

(dm keep> (Obj Val Hook)
   (for V (unmarkup Val)
      (super Obj V Hook) ) )

NIL ####### README #######

Using the TinyMCE 4.x Javascript/HTML WYSIWYG editor in PicoLisp applications

1. Get 'tinymce'

   $ (cd /some/path; unzip tinymce_4.1.7.zip)

2. In the application's runtime directory, create a link to the tinymce
   installation, e.g.:

   $ ln -s /some/path/tinymce

3. Load "@lib/tinymce.l" at startup

   (load .. "@lib/tinymce.l" ..)

4. On each page where you want to use tinymce in text areas, call (<tinymce>)

   (action
      (html 0 "Title" "lib.css" NIL
         (form NIL
            ..
            (<tinymce>)
            ...

5. and give each desired text area a style "tinymce":

            ...
            (gui '(+Style +Var +TextField) "tinymce" '*Text 60 8)  # Textarea
            ..
