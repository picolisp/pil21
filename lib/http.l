# 26may22 Software Lab. Alexander Burger

# *HPorts *Home *Gate *Host *Port *Port1 *Port% *Http1 *Chunked
# *Sock *Agent *ContL *ContLen *MPartLim *MPartEnd "*HtSet"
# *Post *Uri *Url *Timeout *SesAdr *SesId *ConId *Retire
# *Referer *Cookies "*Cookies"

(default
   *HPorts 0
   *Timeout (* 300 1000) )

(private) (Host Port Sock How Prg)

(mapc allow '(*Adr *Gate *Cipher *Host *ContL))

(zero *Http1)

(de *Mimes
   (`(chop "html") "text/html; charset=utf-8")
   (`(chop "svg") "image/svg+xml; charset=utf-8")
   (`(chop "au") "audio/basic" 3600)
   (`(chop "wav") "audio/x-wav" 3600)
   (`(chop "mp3") "audio/x-mpeg" 3600)
   (`(chop "gif") "image/gif" 3600)
   (`(chop "tif") "image/tiff" 3600)
   (`(chop "tiff") "image/tiff" 3600)
   (`(chop "bmp") "image/bmp" 86400)
   (`(chop "png") "image/png" 86400)
   (`(chop "jpg") "image/jpeg" 3600)
   (`(chop "jpeg") "image/jpeg" 3600)
   (`(chop "txt") "text/octet-stream" 1 T)
   (`(chop "csv") "text/csv; charset=utf-8" 1 T)
   (`(chop "css") "text/css" 86400)
   (`(chop "js") "application/x-javascript" 86400)
   (`(chop "ps") "application/postscript" 1)
   (`(chop "pdf") "application/pdf" 1)
   (`(chop "zip") "application/zip" 1)
   (`(chop "epub") "application/epub+zip" 86400)
   (`(chop "jar") "application/java-archive" 86400) )

(de mime (S . @)
   (let L (chop S)
      (if (assoc L *Mimes)
         (con @ (rest))
         (push '*Mimes (cons L (rest))) ) ) )

(de mimetype (File Typ)
   (in (list 'file "-b" (if Typ "--mime-type" "--mime") File)
      (line T) ) )

### HTTP-Client ###
(de client (Host Port How . Prg)
   (let? Sock (connect Host Port)
      (prog1
         (out Sock
            (if (atom How)
               (prinl "GET /" How " HTTP/1.0\r")
               (prinl "POST /" (car How) " HTTP/1.0\r")
               (prinl "Content-Length: " (size (cdr How)) "\r") )
            (prinl "User-Agent: PicoLisp\r")
            (prinl "Host: " Host "\r")
            (prinl "Accept-Charset: utf-8\r")
            (prinl "\r")
            (and (pair How) (prin (cdr @)))
            (flush)
            (in Sock (run Prg 1)) )
         (close Sock) ) ) )

# Local Password
(de pw (N)
   (if N
      (out "~/.pil/pw"
         (prinl (in "/dev/urandom" (rd N))) )
      (in "~/.pil/pw"
         (line T) ) ) )

# PicoLisp Shell
(de psh (Pw Tty)
   (cond
      ((not Pw) (println *Port) (bye))
      ((<> Pw (pw)) (quit "Bad pw"))
      ((ctty Tty)
         (if *SesId
            (setq *Adr *SesAdr)
            (off *Run) )
         (println *Pid)
         (unless *Dbg
            (on *Dbg)
            (symbols '(pico)
               (and (info "~/.pil/rc") (load @@))
               (load "@lib/debug.l" "@lib/vip.l" "@lib/sq.l") ) )
         (load "@lib/too.l")
         (off *Err)
         (quit) ) ) )

### HTTP-Server ###
(de -server ()
   (server (format (opt)) (opt)) )

(de server (P H)
   (setq
      *Port P
      *Port1 (or (sys "NAME") P)
      *Home (cons H (chop H))
      P (port *Port) )
   (gc)
   (loop
      (setq *Sock (listen P))
      (NIL (fork) (close P))
      (close *Sock) )
   (task *Sock (http @))
   (http *Sock)
   (or *SesId (bye))
   (task *Sock
      (when (accept @)
         (task @ (http @)) ) ) )

(de retire (Min . Prg)
   (when (sys "PORT")
      (task -60000 60000  X (cons Min Min Prg)
         (cond
            (*Adr (off *Adr) (set X (cadr X)))
            ((diff (kids) *Retire) (set X (cadr X)))
            ((=0 (dec X)) (run (cddr X)) (bye)) ) ) ) )

(de baseHRef (Port . @)
   (pass pack
      (or *Gate "http") "://" *Host
      (if *Gate "/" ":")
      (or Port (if *SesId *Port *Port1))
      "/" ) )

(de https @
   (pass pack "https://" *Host "/" *Port "/" *SesId) )

(de ext.html (Sym)
   (pack (ht:Fmt Sym) ".html") )

(de disallowed ()
   (and
      *Allow
      (not (idx *Allow *Url))
      (or
         (sub? ".." *Url)
         (nor
            (and *Tmp (pre? *Tmp *Url))
            (find pre? (cdr *Allow) (circ *Url)) ) ) ) )

(de notAllowed (X)
   (unless (= X "favicon.ico")
      (msg X " [" *Adr "] not allowed") ) )

# Application startup
(de app ()
   (if *SesId
      (unless (= *Adr *SesAdr)
         (forbidden) )
      (setq
         *SesAdr *Adr
         *SesId (pack (in "/dev/urandom" (rd 7)) "~")
         *Sock (port *HPorts '*Port)
         *Port% (not *Gate) )
      (timeout *Timeout)
      (out 2 (prinl *Pid " = " *Port " " *SesId)) ) )

# Set a cookie
(de cookie @
   (let A (next)
      (if (assoc A "*Cookies")
         (con @ (rest))
         (push '"*Cookies" (cons A (rest))) ) ) )

# Handle HTTP-Transaction
(de http (*HtSock)
   (use (*Post U L @X)
      (off *Post *Port% *ContL *ContLen *Cookies "*Cookies" "*HtSet")
      (catch 'http
         (in *HtSock
            (case (till " " T)
               ("GET" (_htHead))
               ("POST"
                  (on *Post)
                  (off *MPartLim *MPartEnd)
                  (_htHead)
                  (cond
                     (*MPartLim (_htMultipart))
                     ((=0 *ContLen))
                     ((cond (*ContL (line)) (*ContLen (ht:Read @)))
                        (for L (split @ '&)
                           (when (setq L (split L "="))
                              (let? S (_htSet (car L) (ht:Pack (cadr L) T))
                                 (and
                                    (cddr L)
                                    (format (car @))
                                    (unless (out (tmp S) (echo @))
                                       (%@ "unlink" NIL (tmp S)) ) ) ) ) ) )
                     (T (throw 'http)) ) )
               (T
                  (and @ (out *HtSock (httpStat 501 "Not Implemented")))
                  (task (close *HtSock))
                  (off *HtSock)
                  (throw 'http) ) )
            (if (<> *ConId *SesId)
               (prog (task (close *HtSock)) (off *HtSock))
               (setq
                  L (split (setq *Uri U) "?")
                  U (car L)
                  L (mapcan
                     '((A)
                        (cond
                           ((cdr (setq A (split A "=")))
                              (nil (_htSet (car A) (htArg (cadr A)))) )
                           ((tail '`(chop ".html") (car A))
                              (cons (pack (car A))) )
                           (T (cons (htArg (car A)))) ) )
                     (split (cadr L) "&") ) )
               (unless (setq *Url (ht:Pack U T))
                  (setq  *Url (car *Home)  U (cdr *Home)) )
               (out *HtSock
                  (cond
                     ((match '("-" @X "." "h" "t" "m" "l") U)
                        (and *SesId (timeout *Timeout))
                        (apply try L 'html> (extern (ht:Pack @X T))) )
                     ((disallowed)
                        (notAllowed *Url)
                        (http404) )
                     ((= "!" (car U))
                        (and *SesId (timeout *Timeout))
                        (apply (val (intern (ht:Pack (cdr U) T))) L) )
                     ((tail '("." "l") U)
                        (and *SesId (timeout *Timeout))
                        (apply script L *Url) )
                     ((=T (car (info *Url)))
                        (if (info (setq *Url (pack *Url "/default")))
                           (apply script L *Url)
                           (http404) ) )
                     ((assoc (stem U ".") *Mimes)
                        (apply httpEcho (cdr @) *Url) )
                     (T (httpEcho *Url "application/octet-stream" 1 T)) ) ) ) ) )
      (and *HtSock (=0 *Http1) (task (close *HtSock))) ) )

(de _htHead ()
   (unless
      (and
         (char)
         (= "/" (char))
         (prog (setq U (till " ")) (char))
         (= "HTTP/1" (till "." T))
         (char)
         (setq *Http1 (format (line T))) )
      (task (close *HtSock))
      (off *HtSock)
      (throw 'http) )
   (setq *Chunked (gt0 *Http1))
   (if (index "~" U)
      (setq
         *ConId (head @ U)
         U (cdr (nth U @))
         *ConId (pack (if (member "/" *ConId) (cdr @) *ConId)) )
      (off *ConId) )
   (while
      (case (lowc (till " \r\n" T))
         ("host:" (setq *Host (cdr (line))))
         ("referer:" (setq *Referer (cdr (line))))
         ("cookie:"
            (setq *Cookies
               (mapcar
                  '((L)
                     (setq L (split L "="))
                     (cons (htArg (clip (car L))) (htArg (cadr L))) )
                  (split (cdr (line)) ";") ) ) )
         ("user-agent:" (setq *Agent (cdr (line))))
         ("content-length:" (setq *ContLen (format (cdr (line)))))
         ("content-type:"
            (if (= " multipart/form-data; boundary" (lowc (till "=\r\n" T)))
               (setq
                  *MPartLim (append '(- -) (cdr (line)))
                  *MPartEnd (append *MPartLim '(- -)) )
               (line) ) )
         ("x-pil:"
            (char)
            (when (till "=\r\n")
               (_htSet @ (ht:Pack (cdr (line)) T))
               T ) )
         (T (if (eol) (char) (line T))) ) )
   (unless *Gate
      (and (member ":" *Host) (con (prior @ *Host))) ) )

# rfc1867 multipart/form-data
(de _htMultipart ()
   (use Var
      (let L (line)
         (while (= *MPartLim L)
            (unless (= "content-disposition: form-data; name=" (lowc (till "\"" T)))
               (line)
               (throw 'http) )
            (char)
            (setq Var (till "\""))
            (char)
            (nond
               ((line)
                  (while (line))
                  (_htSet Var
                     (pack
                        (make
                           (until
                              (or
                                 (= *MPartLim (setq L (line)))
                                 (= *MPartEnd L) )
                              (when (eof)
                                 (throw 'http) )
                              (when (made)
                                 (link "\n") )
                              (link (trim L)) ) ) ) ) )
               ((head '`(chop "; filename=") (setq L @))
                  (while (line)) )
               (NIL
                  (while (line))
                  (setq L (cdr (rot (nth L 13))))
                  (if (_htSet Var (pack (stem L "/" "\\")))
                     (let F (tmp @)
                        (unless (out F (echo (pack "\r\n" *MPartLim)))
                           (%@ "unlink" NIL F) ) )
                     (out "/dev/null" (echo (pack "\r\n" *MPartLim))) )
                  (setq L (if (= "-" (car (line))) *MPartEnd *MPartLim)) ) ) ) ) ) )

(de _htSet (L Val)
   (let "Var" (intern (ht:Pack (car (setq L (split L ":"))) T))
      (cond
         ((and *Allow (not (idx *Allow "Var")))
            (notAllowed "Var")
            (throw 'http) )
         ((cadr L)
            (let? N (format (car (setq L (split @ "."))))
               (case (caadr L)
                  ("x" (setq Val (cons (format Val))))
                  ("y" (setq Val (cons NIL (format Val)))) )
               (nond
                  ((memq "Var" "*HtSet")
                     (push '"*HtSet" "Var")
                     (set "Var" (cons (cons N Val)))
                     Val )
                  ((assoc N (val "Var"))
                     (queue "Var" (cons N Val))
                     Val )
                  (NIL
                     (let X @
                        (cond
                           ((nand (cadr L) (cdr X)) (con X Val))
                           ((car Val) (set (cdr X) @))
                           (T (con (cdr X) (cdr Val))) ) ) ) ) ) )
         (T
            (if (= "*" (caar L))
               (set "Var" Val)
               (put "Var" 'http Val) ) ) ) ) )

(de htArg (Lst)
   (case (car Lst)
      ("$" (intern (ht:Pack (cdr Lst) T)))
      ("+" (format (cdr Lst)))
      ("-" (extern (ht:Pack (cdr Lst) T)))
      ("_" (mapcar htArg (split (cdr Lst) "_")))
      (T (ht:Pack Lst T)) ) )

# Http Transfer Header
(de http1 (Typ Upd File Att)
   (prinl "HTTP/1." *Http1 " 200 OK\r")
   (prinl "Server: PicoLisp\r")
   (prin "Date: ")
   (httpDate (date T) (time T))
   (when Upd
      (prinl "Cache-Control: max-age=" Upd "\r")
      (when (=0 Upd)
         (prinl "Cache-Control: private, no-store, no-cache\r") ) )
   (prinl "Content-Type: " (or Typ "text/html; charset=utf-8") "\r")
   (when File
      (prinl
         "Content-Disposition: "
         (if Att "attachment" "inline")
         "; filename=\"" File "\"\r" ) ) )

(de httpCookies ()
   (mapc
      '((L)
         (prin "Set-Cookie: "
            (ht:Fmt (++ L)) "=" (ht:Fmt (++ L))
            "; path=" (or (++ L) "/") )
         (and (++ L) (prin "; expires=" @))
         (and (++ L) (prin "; domain=" @))
         (and (++ L) (prin "; secure"))
         (and (++ L) (prin "; HttpOnly"))
         (prinl) )
      "*Cookies" ) )

(de respond (S)
   (http1 "application/octet-stream" 0)
   (prinl "Content-Length: " (size S) "\r\n\r")
   (prin S) )

(de httpHead (Typ Upd File Att)
   (http1 Typ Upd File Att)
   (and *Chunked (prinl "Transfer-Encoding: chunked\r"))
   (httpCookies)
   (prinl "\r") )

(de httpDate (Dat Tim)
   (let D (date Dat)
      (prinl
         (day Dat *Day) ", "
         (pad 2 (caddr D)) " "
         (get *Mon (cadr D)) " "
         (car D) " "
         (tim$ Tim T) " GMT\r" ) ) )

# Http Echo
(de httpEcho (File Typ Upd Att Name)
   (and *Tmp (pre? *Tmp File) (one Upd))
   (ifn (info File)
      (http404)
      (let I @
         (http1
            (or Typ (mimetype File))
            Upd
            (or Name (stem (chop File) "/"))
            Att )
         (prinl "Content-Length: " (car I) "\r")
         (prin "Last-Modified: ")
         (httpDate (cadr I) (cddr I))
         (prinl "\r")
         (in File (echo)) ) ) )

(de srcUrl (Url)
   (if (or (pre? "http:" Url) (pre? "https:" Url))
      Url
      (baseHRef *Port1 Url) ) )

(de sesId (Url)
   (if
      (or
         (pre? "http:" Url)
         (pre? "https:" Url)
         (pre? "mailto:" Url)
         (pre? "javascript:" Url)
         (pre? "tel:" Url) )
      Url
      (pack *SesId Url) ) )

(de httpStat (N X . @)
   (let B (fin X)
      (if (pair X)
         (setq X (car X))
         (setq B (pack "<H1>" B "</H1>")) )
      (prinl "HTTP/1." *Http1 " " N " " X "\r")
      (prinl "Server: PicoLisp\r")
      (while (args)
         (prinl (next) "\r") )
      (prinl "Content-Type: text/html\r")
      (httpCookies)
      (prinl "Content-Length: " (+ 59 (length N) (length X) (length B)) "\r")
      (prinl "\r")
      (prinl "<HTML>")
      (prinl "<HEAD><TITLE>" N " " X "</TITLE></HEAD>")
      (prinl "<BODY>" B "</BODY>")
      (prinl "</HTML>") ) )

(de noContent ()
   (prinl "HTTP/1.0 204 No Content\r")
   (prinl "\r") )

(de redirect @
   (httpStat 303 "See Other" (pass pack "Location: ")) )

(de forbidden (X)
   (httpStat 403 "No Permission")
   (and X (msg *Pid " No permission: " @))
   (throw 'http) )

(de http404 ()
   (httpStat 404 "Not Found") )
