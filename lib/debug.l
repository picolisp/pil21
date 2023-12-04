# 04dec23 Software Lab. Alexander Burger

# Prompt
(de *Prompt
   (casq (car (symbols)) (pico) (T @)) )

(private) (_who _match nest nst1 nst2 C D E M S X Y Z Fun Prg Who dep1 dep2)

# Edit history
(de h ()
   (let F (tmp "history")
      (out F
         (mapc prinl (history)) )
      (and
         (vi (cons T F))
         (history
            (in F
               (make (while (line T) (link @))) ) )
         T ) ) )

# Browsing
(de help (Sym Ex)
   (when (; Sym doc)
      (prinl "========================================")
      (in @
         (from
            (pack
               "<dt><a id=\""
               (replace (chop Sym)
                  "%" "%25"
                  "<" "%3C"
                  ">" "%3E"
                  "\^" "%5E"
                  "|" "%7C")
               "\">" ) )
         (out '("w3m" "-T" "text/html" "-dump")
            (prin "<dt>")
            (echo "</a>")
            (echo "<dd>")
            (prinl "<br/>")
            (echo "\n<pre>")
            (ifn Ex
               (prinl "<br/><br/>")
               (prin "<pre>")
               (prinl (echo "\n</pre>")) ) ) ) )
   Sym )

(de docs (Dir)
   (when (=T (car (info Dir)))
      (let All (all)
         (for F (dir Dir)
            (when (match '("r" "e" "f" @ "." "h" "t" "m" "l") (chop F))
               (let P (pack Dir F)
                  (in P
                     (while (from "<dt><a id=\"")
                        (let (L (till "\"")  S (ht:Pack L T))
                           (cond
                              ((member S All) (put (car @) 'doc P))
                              ((and
                                    (not (cddr (setq L (split L "/"))))
                                    (format (cadr L))
                                    (member (pack (car L)) All) )
                                 (put (intern S) 'doc P) ) ) ) ) ) ) ) ) ) ) )

(de doc (Sym Browser)
   (call (or Browser (sys "BROWSER") "w3m")
      (pack
         "file:"
         (and (= `(char '/) (char (path "@"))) "//")
         (path
            (if (get Sym 'doc)
               (pack @ "#"
                  (replace (chop Sym)
                     "%" "%25"
                     "<" "%3C"
                     ">" "%3E"
                     "\^" "%5E"
                     "|" "%7C" ) )
               "@doc/ref.html" ) ) ) ) )

(de more (M Fun)
   (let *Dbg NIL
      (if (pair M)
         ((default Fun println) (++ M))
         (println (type M))
         (setq
            Fun (list '(X) (list 'pp 'X (lit M)))
            M (mapcar car (filter pair (val M))) ) )
      (loop
         (T (atom M))
         (T (= "\e" (key)) T)
         (Fun (++ M)) ) ) )

(de what (S)
   (let *Dbg NIL
      (setq S (chop S))
      (filter
         '(("X") (match S (chop "X")))
         (all) ) ) )

(de who (X . Prg)
   (let (*Dbg NIL  Who '(Who @ @@ @@@))
      (make (mapc _who (all))) ) )

(and noLint (@ 'who 'Prg))

(de _who (Y)
   (unless (or (ext? Y T) (memq Y Who))
      (push 'Who Y)
      (ifn (= `(char "+") (char Y))
         (and (pair (val Y)) (nest @) (link Y))
         (for Z (pair (val Y))
            (if (atom Z)
               (and (_match Z) (link Y))
               (when (nest (cdr Z))
                  (link (cons (car Z) Y)) ) ) )
         (maps
            '((Z)
               (if (atom Z)
                  (and (_match Z) (link Y))
                  (when (nest (car Z))
                     (link (cons (cdr Z) Y)) ) ) )
            Y ) ) ) )

(de nest (Y)
   (nst1 Y)
   (nst2 Y) )

(de nst1 (Y)
   (let Z (setq Y (strip Y))
      (loop
         (T (atom Y) (and (sym? Y) (_who Y)))
         (and (sym? (car Y)) (_who (car Y)))
         (and (pair (car Y)) (nst1 @))
         (T (== Z (setq Y (cdr Y)))) ) ) )

(de nst2 (Y)
   (let Z (setq Y (strip Y))
      (loop
         (T (atom Y) (_match Y))
         (T (or (_match (car Y)) (nst2 (car Y)))
            T )
         (T (== Z (setq Y (cdr Y)))) ) ) )

(de _match (D)
   (and
      (cond
         ((str? X) (and (str? D) (= X D)))
         ((sym? X) (== X D))
         (T (match X D)) )
      (or
         (not Prg)
         (let *Dbg (up 2 *Dbg) (run Prg)) ) ) )

(de has (X)
   (let *Dbg NIL
      (filter
         '((S) (= X (val S)))
         (all) ) ) )

(de can (X)
   (let *Dbg NIL
      (extract
         '((Y)
            (and
               (= `(char "+") (char Y))
               (asoq X (val Y))
               (cons X Y) ) )
         (all) ) ) )

(private) (Flg Nsp Lst Sym N L S)

# Namespaces nested in current search order
(de namespaces (Flg)
   (let N 3
      (make
         (for Nsp (symbols)
            (recur (Nsp N)
               (link Nsp)
               (when Flg
                  (space N)
                  (println Nsp) )
               (for S (all Nsp)
                  (and
                     (pair (val S))
                     (== '\~ (car @))
                     (not (memq S (made)))
                     (recurse S (+ N 3)) ) ) ) ) ) ) )

# Namespace shadowing
(de shadows (Flg)
   (let Lst (mapcan all (symbols))
      (make
         (while (cdr Lst)
            (let Sym (++ Lst)
               (unless (member Sym (made))
                  (let? L
                     (filter
                        '((S)
                           (and
                              (= S Sym)
                              (n== S Sym)
                              (val S) ) )
                        Lst )
                     (when Flg
                        (space 3)
                        (apply println L Sym) )
                     (link Sym) ) ) ) ) ) ) )

# Class dependencies
(de dep (C)
   (let *Dbg NIL
      (dep1 0 C)
      (dep2 3 C)
      C ) )

(de dep1 (N C)
   (for X (type C)
      (dep1 (+ 3 N) X) )
   (space N)
   (println C) )

(de dep2 (N C)
   (for X (all)
      (when
         (and
            (= `(char "+") (char X))
            (memq C (type X)) )
         (space N)
         (println X)
         (dep2 (+ 3 N) X) ) ) )

# Inherited methods
(de methods (Obj)
   (make
      (let Mark NIL
         (recur (Obj)
            (for X (val Obj)
               (nond
                  ((pair X) (recurse X))
                  ((memq (car X) Mark)
                     (link (cons (car X) Obj))
                     (push 'Mark (car X)) ) ) ) ) ) ) )

(private) (_dbg _dbg2 dbg ubg traced? U)

# Single-Stepping
(de _dbg (Lst)
   (or
      (atom (car Lst))
      (num? (caar Lst))
      (flg? (caar Lst))
      (== '! (caar Lst))
      (set Lst (cons '! (car Lst))) ) )

(de _dbg2 (Lst)
   (map
      '((L)
         (if (and (pair (car L)) (flg? (caar L)))
            (map _dbg (cdar L))
            (_dbg L) ) )
      Lst ) )

(de dbg (Lst)
   (when (pair Lst)
      (casq (++ Lst)
         ((case casq state)
            (_dbg Lst)
            (for L (cdr Lst)
               (map _dbg (cdr L)) ) )
         ((cond nond)
            (for L Lst
               (map _dbg L) ) )
         (quote
            (when (fun? Lst)
               (map _dbg (cdr Lst)) ) )
         ((job use let let? recur)
            (map _dbg (cdr Lst)) )
         (loop
            (_dbg2 Lst) )
         ((bind do)
            (_dbg Lst)
            (_dbg2 (cdr Lst)) )
         (for
            (and (pair (car Lst)) (map _dbg (cdar Lst)))
            (_dbg2 (cdr Lst)) )
         (T (map _dbg Lst)) )
      T ) )

(de d ()
   (let *Dbg NIL
      (dbg ^) ) )

(de -debug ()
   (debug (intern (opt))) )

(de debug (X C)
   (ifn (traced? X C)
      (let *Dbg NIL
         (when (pair X)
            (setq C (cdr X)  X (car X)) )
         (or
            (dbg (if C (method X C) (getd X)))
            (quit "Can't debug" X) ) )
      (untrace X C)
      (debug X C)
      (trace X C) ) )

(de ubg (Lst)
   (when (pair Lst)
      (map
         '((L)
            (when (pair (car L))
               (when (== '! (caar L))
                  (set L (cdar L)) )
               (ubg (car L)) ) )
         Lst )
      T ) )

(de u ()
   (let *Dbg NIL
      (ubg ^) ) )

(de unbug (X C)
   (let *Dbg NIL
      (when (pair X)
         (setq C (cdr X)  X (car X)) )
      (or
         (ubg (if C (method X C) (getd X)))
         (quit "Can't unbug" X) ) ) )

# Tracing
(de traced? (X C)
   (setq X
      (if C
         (method X C)
         (getd X) ) )
   (and
      (pair X)
      (pair (cadr X))
      (== '$ (caadr X)) ) )

# Convert ((X Y) A B) --> ((X Y) ($ foo (X Y) A B))
(de -trace ()
   (trace (intern (opt))) )

(de trace (X C)
   (let *Dbg NIL
      (when (pair X)
         (setq C (cdr X)  X (car X)) )
      (if C
         (unless (traced? X C)
            (or (method X C) (quit "Can't trace" X))
            (con @
               (cons
                  (conc
                     (list '$ (cons X C) (car @))
                     (cdr @) ) ) ) )
         (unless (traced? X)
            (and (sym? (getd X)) (quit "Can't trace" X))
            (and (num? (getd X)) (expr X))
            (set X
               (list
                  (car (getd X))
                  (conc (list '$ X) (getd X)) ) ) ) )
      X ) )

# Convert ((X Y) ($ foo (X Y) A B)) --> ((X Y) A B)
(de untrace (X C)
   (let *Dbg NIL
      (when (pair X)
         (setq C (cdr X)  X (car X)) )
      (if C
         (when (traced? X C)
            (con
               (method X C)
               (cdddr (cadr (method X C))) ) )
         (when (traced? X)
            (let Y (set X (cddadr (getd X)))
               (and
                  (== '@ (++ Y))
                  (=1 (length Y))
                  (= 2 (length (car Y)))
                  (== 'pass (caar Y))
                  (sym? (cdadr Y))
                  (subr X) ) ) ) )
      X ) )

(de *NoTrace
   @ @@ @@@
   pp show more led
   what who can dep d e debug u unbug trace untrace )

(de traceAll (Excl)
   (let *Dbg NIL
      (for X (all)
         (or
            (memq X Excl)
            (memq X *NoTrace)
            (= `(char "*") (char X))
            (cond
               ((= `(char "+") (char X))
                  (mapc trace
                     (extract
                        '((Y)
                           (and
                              (pair Y)
                              (fun? (cdr Y))
                              (cons (car Y) X) ) )
                        (val X) ) ) )
               ((pair (getd X))
                  (trace X) ) ) ) ) ) )

# Process Listing
(when (member *OS '("Android" "Linux"))
   (de proc @
      (apply call
         (make (while (args) (link "-C" (next))))
         "ps" "-H" "-o" "pid,ppid,start,size,pcpu,cmd" ) ) )

# Benchmarking
(de bench Prg
   (let U (usec)
      (prog1
         (run Prg 1)
         (out 2
            (prinl
               (format (*/ (- (usec) U) 1000) 3)
               " sec" ) ) ) ) )

# Backtrace
(de bt (Flg)
   (let (S NIL  *Dbg)
      (for (L (trail T) L)
         (if (pair (car L))
            (let E (++ L)
               (push 'S
                  (list
                     (if (getd (box? (car E)))
                        (cons @ (cdr E))
                        E ) ) ) )
            (conc
               (car (default S (cons (cons))))
               (cons (cons (++ L) (++ L))) ) )
         (T (== '^ (car L)))
         (T
            (and
               (pair (car L))
               (== 'bt (caar L)) ) ) )
      (for L S
         (let? X (++ L)
            (pretty
               (cons
                  (or
                     (and (sym? (car X)) (car X))
                     (find
                        '((S) (== (car X) (val S)))
                        (all) )
                     (car X) )
                  (less (cdr X)) ) ) )
         (prinl)
         (while L
            (space 3)
            (println (caar L) (less (cdr (++ L)))) )
         (NIL (or Flg (<> "\e" (key))) T) ) ) )

# Source code
`(info "@lib/map")

(symbols 'llvm 'pico)

(in "@lib/map"
   (while (read)
      (let Sym @
         (if (get Sym '*Dbg)
            (set @ (read))
            (put Sym '*Dbg (cons (read))) ) ) ) )
