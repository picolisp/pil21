# 06jun22 Software Lab. Alexander Burger

### PicoLisp LLVM frontend ###
(zap 'llvm) (symbols 'llvm 'pico)

(local) (@ @@ @@@ cross void null i1 i1* i1** i8 i8* i8** i8*** i16 i16* i16**
i32 i32* i32** i64 i64* i64** any YES NO ZERO -ZERO ONE SymTab begin end $ ?
short equ global var str const globals array table symTab inline tailcall define
struct $Nil $T $Link drop)

(import pico llvm symbols local T NIL load use setq prog */ ** >> char hex)


### Cross-compiler private ###
(symbols 'cross 'llvm 'pico)

(import any inc dec ++ #{shift}#)

(local) (*Map *Map2 putMap *Shared *Strings *Ssa *Lbl *Log *Curr *Exit *Bind
*Phi *Call *Ret log asm ssa phi +phi br label +lbl +bind type func ptr pointee
store A B C I L M N P Q V X Y Exe Prg Typ Sym Ret Args Ext Table Body Var Val
Lst Lbl Flg Skip True False Beg End Safe *Safe)

(off *Map *Map2)

(de *Err
   (and *Dbg (symbols '(cross llvm pico))) )

(de *Call . "call")

(de putMap (Sym N)
   (let F (file)
      (idx '*Map
         (def (name Sym)
            (cons
               (+ (cddr F) (or N 0))
               (pack (car F) (cadr F)) ) )
         T ) )
   Sym )

(local) de

(pico~de de Prg
   (def (putMap (car Prg)) (cdr Prg)) )

# Constant primitives
(de void . void)
(de null . null)

(de NO . `(def "0" 'i1))  # Booleans
(de YES . `(def "1" 'i1))
(de ZERO . `(def "2" 'any))  # Short number '0'
(de -ZERO . `(def "10" 'any))  # Placeholder '-0'
(de ONE . `(def "18" 'any))  # Short number '1'

# Generate LLVM-IR
(de begin (Name Flg . pico~@)
   (off *Strings)
   (prinl "source_filename = \"" Name ".l\"")
   (prinl)
   (prinl "declare {i64, i1} @llvm.uadd.with.overflow.i64(i64, i64)")
   (prinl "declare {i64, i1} @llvm.usub.with.overflow.i64(i64, i64)")
   (prinl "declare i64 @llvm.fshl.i64(i64, i64, i64)")
   (prinl "declare i64 @llvm.fshr.i64(i64, i64, i64)")
   (prinl "declare void @llvm.memcpy.p0i8.p0i8.i64(i8*, i8*, i64, i1)")
   (prinl "declare void @llvm.memset.p0i8.i64(i8*, i8, i64, i1)")
   (prinl "declare i8* @llvm.stacksave()")
   (prinl "declare void @llvm.stackrestore(i8*)")
   (prinl)
   (let *Shared Flg
      (pass load) ) )

(de *C-Defs
   (~(chop "const ") @A " " @Sym "[" @Z)
   (~(chop "const ") @A " " @Sym " " @Z)
   (~(chop "struct ") @A " " "*" @Sym ";" @Z)
   (~(chop "struct ") @A " " @Sym ";" @Z)
   (~(chop "void *") @Sym "(" @Z)
   (~(chop "void ") @Sym "(" @Z)
   (~(chop "char *") @Sym "(" @Z)
   (~(chop "int ") @Sym ";" @Z)
   (~(chop "int ") @Sym "(" @Z)
   (~(chop "int32_t ") @Sym "(" @Z)
   (~(chop "int64_t ") @Sym "(" @Z)
   (~(chop "uint64_t ") @Sym ";" @Z)
   (~(chop "uint64_t ") @Sym "(" @Z)
   (~(chop "jmp_buf ") @Sym ";" @Z)
   (~(chop "ffi *") @Sym "(" @Z) )

(de end (Map . pico~@)
   (prinl)
   (for L *Strings
      (prinl (caddr L) " = " (cdddr L)) )
   (when Map
      (out Map
         (for Sym (idx '*Map)
            (let X (val Sym)
               (prinl "llvm~" Sym " (" (car X) " \"@src/" (cdr X) "\" llvm pico)") ) )
         (while (args)
            (let (F (next)  N 1)
               (use (@A @Sym @Z)
                  (in F
                     (until (eof)
                        (let L (circ (line))
                           (when (find match *C-Defs L)
                              (prinl "llvm~" @Sym " (" N " \"@src/" F "\" llvm pico)") ) )
                        (inc 'N) ) ) ) ) )
         (for Sym (idx '*Map2)
            (let X (val (car (idx '*Map (val Sym))))
               (prinl "pico~" Sym " (" (car X) " \"@src/" (cdr X) "\" llvm pico)") ) ) ) ) )

(de log (A)
   (let? L
      (chop
         (or A
            (and *Log
               (symbols '(llvm pico cross) (sym (up 2))) ) ) )
      (and (nth L 65) (con pico~@ "..."))
      (link (cons NIL L)) ) )

(de asm Lst
   (for L (cddr Lst)
      (def (putMap (car L))
         (bind (car Lst)
            (mapc set (car Lst) (cdr L))
            (cons (caadr Lst)
               '(log)
               (let (@ '@  @@ '@@  @@@ '@@@)
                  (fill (cdadr Lst)) ) ) ) ) ) )

(de ssa (N . pico~@)
   (link
      (cons
         (pack "%" N)
         (pass pack) ) ) )

(de phi (Lbl Var)
   (let? Val (val Var)
      (if (asoq Lbl *Phi)
         (let L pico~@
            (if (asoq Var L)
               (conc pico~@ (list (cons *Curr Val)))
               (con L
                  (cons
                     (list Var NIL (cons *Curr Val))
                     (cdr L) ) ) ) )
         (queue '*Phi
            (list Lbl (list Var NIL (cons *Curr Val))) ) ) ) )

(de +phi (Lbl)
   (let M NIL
      (for Var *Bind
         (unless (memq Var M)
            (phi Lbl Var)
            (push 'M Var) ) ) )
   Lbl )

(de br (A B C)
   (link
      (if B
         (pack "br i1 " A ", label %$" (+phi B) ", label %$" (+phi C))
         (pack "br label %$" (+phi A)) ) ) )

(de label (N)
   (for L (cdr (asoq (link (setq *Curr N)) *Phi))
      (when
         (or
            (not (name (car L)))
            (memq (car L) *Bind) )
         (let Typ
            (or
               (pick
                  '((X)
                     (and (sym? (cdr X)) (val (cdr X))) )
                  (cddr L) )
               'i64 )
            (cond
               ((== void Typ) void)
               ((fully
                     '((X)
                        (cond
                           ((=T (cdr X)))
                           ((num? (cdr X))
                              (memq Typ '(i8 i16 i32 i64 any)) )
                           (T
                              (== (type Typ) (type (val (cdr X)))) ) ) )
                     (cddr L) )
                  (set
                     (car L)  # Var
                     (set
                        (cdr L)  # Ssa
                        (def (pack "%" (inc '*Ssa)) Typ) ) ) )
               (T void) ) ) ) ) )

(de +lbl ()
   (inc '*Lbl) )

(de +bind (Lst Var)
   (when
      (fish
         '((X)
            (when (pair X)
               (or
                  (and
                     (memq (car X) '(llvm~inc llvm~dec))
                     (pair (cadr X))
                     (== 'quote (caadr X))
                     (== Var (cdadr X)) )
                  (and
                     (memq (car X) '(llvm~setq llvm~++ llvm~shift))
                     (for (L (cdr X)  L  (cddr L))
                        (T (== Var (car L)) T) ) )
                  (and
                     (== (car X) 'llvm~xchg)
                     (or
                        (and (== 'quote (caadr X)) (== Var (cdadr X)))
                        (and (== 'quote (caaddr X)) (== Var (cdaddr X))) ) )
                  (and
                     (sym? (car X))
                     (memq Var (; X 1 phi)) ) ) ) )
         Lst )
      (push '*Bind Var) ) )

(de type (Typ)
   (cond
      ((== 'any Typ) 'i64)
      ((== null Typ) 'i8*)
      ((pair Typ) (func pico~@))
      (T Typ) ) )

(de func (Lst)
   (pack
      (type (car Lst))
      "("
      (glue "," (mapcar type (cdr Lst)))
      ")*" ) )

(de ptr (Typ)
   (or
      (pair Typ)
      (if (== 'any Typ)
         Typ
         (intern (pack Typ "*")) ) ) )

(de pointee (Typ)
   (if (== 'any Typ)
      Typ
      (intern (pack (head -1 (chop Typ)))) ) )

(de store (X P Ofs)
   (nond
      ((memq (val P) '(i64 any))
         (when (num? X)
            (setq X (def (format X) (pointee (val P)))) )
         (ifn Ofs
            (link
               (pack "store " (type (val X)) " " X ", "
                  (type (val P)) (and (pair (val P)) "*")
                  " " P ) )
            (ssa (inc '*Ssa) "getelementptr "
               (type (val X)) ", "
               (type (val P)) (and (pair (val P)) "*")
               " " P ", i32 " Ofs )
            (link
               (pack "store " (type (val X)) " " X ", "
                  (type (val P)) (and (pair (val P)) "*")
                  " %" *Ssa ) ) ) )
      ((pre? "@" P)
         (ssa (inc '*Ssa) "inttoptr i64 " P " to i64*")
         (when Ofs
            (ssa (inc '*Ssa) "getelementptr i64, i64* %" (dec *Ssa) ", i32 " Ofs) )
         (link (pack "store i64 " X ", i64* %" *Ssa)) )
      (NIL
         (link (pack "store i64 " X ", i64* " P)) ) )
   X )

(de $ (Str)
   (if (assoc Str *Strings)
      (cadr pico~@)
      (let
         (Sym (pack "@$" (inc (length *Strings)))
            Arr (pack "[" (inc (size Str)) " x i8]")
            Val (def (pack "bitcast (" Arr "* " Sym " to i8*)") 'i8*) )
         (push '*Strings
            (cons Str Val Sym
               (pack
                  (make
                     (link "private constant " Arr " c\"")
                     (for C (chop Str)
                        (if (or (> " " C) (sub? C "\""))
                           (link "\\" (pad 2 (hex (char C))))
                           (link C) ) )
                     (link "\\00\"") ) ) ) )
         Val ) ) )

(de short (N)
   (| 2 (>> -4 N)) )

(de equ Lst
   (while Lst
      (set (putMap (++ Lst)) (eval (++ Lst))) ) )

(de global (Sym Typ Val)
   (prin
      "@" Sym " = "
      (unless (and Val (not *Shared)) "external ")
      "global " (type Typ) )
   (and Val (putMap Sym))
   (cond
      (*Shared)
      ((pre? "_" Val) (prin " @" pico~@))
      ((pre? "$" Val)
         (if (; Val offset)
            (prin
               " ptrtoint (i8* getelementptr (i8, i8* bitcast (["
               (; Val table length)
               " x i64]* @"
               (; Val table)
               " to i8*), i32 "
               pico~@
               ") to i64)" )
            (prin " ptrtoint ("
               (if (== 'any Typ) 'i64 Typ)
               "* @" pico~@ " to "
               (if (== 'any Typ) 'i64 Typ)
               ")" ) ) )
      (Val (prin " " pico~@)) )
   (prinl)
   (def Sym (def (pack "@" Sym) (ptr Typ))) )

(de var Lst
   (global
      (++ Lst)
      (if (cdr Lst) (++ Lst) 'any)
      (eval (car Lst)) ) )

(de str Lst
   (let ((Sym Val) Lst  Arr (pack "[" (inc (size Val)) " x i8]"))
      (def (putMap Sym)
         (def (pack "bitcast (" Arr "* @" Sym " to i8*)") 'i8*) )
      (prin "@" Sym " = constant " Arr " c\"")
      (for C (chop Val)
         (if (or (> " " C) (sub? C "\"\\"))
            (prin "\\" (pad 2 (hex (char C))))
            (prin C) ) )
      (prinl "\\00\"") ) )

(de const (Val)
   (cond
      ((pre? "_" Val)
         (prin
            "  i64 ptrtoint (i8* getelementptr (i8, i8* bitcast "
            (if (pre? "__" Val) "(i64(i64,i64)*" "(i64(i64)*")
            " @"
            pico~@
            " to i8*), i32 2) to i64)" ) )
      ((pre? "$" Val)
         (if (; Val offset)
            (prin
               "  i64 ptrtoint (i8* getelementptr (i8, i8* bitcast (["
               (; Val table length)
               " x i64]* @"
               (; Val table)
               " to i8*), i32 "
               pico~@
               ") to i64)" )
            (prin Val) ) )
      (T
         (prin "  i64 " (eval Val)) ) ) )

(de array Lst
   (let
      (Sym (++ Lst)
         Typ (++ Lst)
         Len (if (pair Lst) (length Lst) (eval Lst)) )
      (def (putMap Sym)
         (def
            (pack
               "bitcast (["
               Len " x " (setq Typ (type Typ))
               "]* @" Sym " to " (ptr Typ) ")" )
            (ptr Typ) ) )
      (prin
         "@" Sym " = " (when *Shared "external ")
         "global [" Len " x " Typ "]" )
      (cond
         (*Shared (prinl))
         ((atom Lst) (prinl " zeroinitializer"))
         (T
            (prinl *Shared " [")
            (for (I . X) Lst
               (prinl
                  "  " Typ " " (eval X)
                  (unless (== I Len) ",") ) )
            (prinl "]") ) ) ) )

(de table Args
   (let
      (Table (++ Args)
         I 0
         @N (* 8 (put Table 'length (length Args)))
         @S (caar Args) )
      (def (putMap Table)
         (curry (@N @S) A
            (if A @N (i8* @S)) ) )
      (prinl
         "@" Table " = " (when *Shared "external ")
         "global [" (; Table length) " x i64]" (unless *Shared " [") )
      (for (I . Lst) Args
         (let Typ (if (caddr Lst) (cadr Lst) 'any)
            (let? Sym (car Lst)
               (put (putMap Sym I) 'table Table)
               (put Sym 'offset (* 8 (dec I)))
               (def Sym
                  (def
                     (pack
                        (if (== 'any Typ)
                           "ptrtoint (i8* getelementptr (i8, i8* bitcast (["
                           "bitcast (i8* getelementptr (i8, i8* bitcast ([" )
                        (; Table length)
                        " x i64]* @"
                        Table
                        " to i8*), i32 "
                        (; Sym offset)
                        ") to "
                        (type Typ)
                        (unless (== 'any Typ) "*")
                        ")" )
                     (ptr Typ) ) ) )
            (unless *Shared
               (nond
                  ((caddr Lst) (const (cadr Lst)))
                  ((pair Typ)
                     (prin
                        "  i64 "
                        (if (sub? "*" Typ) "ptrtoint" "sext")
                        " (" (cadr Lst) " " (caddr Lst) " to i64)") )
                  (NIL
                     (prin "  i64 ptrtoint (" (func pico~@) " @" (caddr Lst) " to i64)") ) )
               (prinl (unless (== Lst (last Args)) ",")) ) ) ) )
   (unless *Shared
      (prinl "], align 8") ) )

(de symTab Args
   (let (Table 'SymTab  I 0)
      (put Table 'length
         (sum
            '((L)
               (if (> (length (cadr L)) 7) 4 2) )
            Args ) )
      (prinl
         "@" Table " = " (when *Shared "external ")
         "global [" (; Table length) " x i64]" (unless *Shared " [") )
      (for (J . Lst) Args
         (let? Sym (car Lst)
            (put (putMap Sym J) 'table Table)
            (put Sym 'offset (+ I (or (cadddr Lst) 8)))
            (def Sym
               (def
                  (pack
                     "ptrtoint (i8* getelementptr (i8, i8* bitcast ([" (; Table length) " x i64]* @"
                     Table
                     " to i8*), i32 "
                     (; Sym offset)
                     ") to i64)" )
                  'any ) ) )
         (unless *Shared
            (let Name
               (when (str? (cadr Lst))
                  (prinl "  ; # [" I "] " pico~@)
                  (let L (chop pico~@)
                     (make
                        (when (nth L 8)  # Max 15 ASCII characters
                           (let (D 0  N 0)
                              (do 8
                                 (setq
                                    N (| N (>> D (char (++ L))))
                                    D (- D 8) ) )
                              (link N) ) )
                        (let (D 0  N 0)
                           (while L
                              (setq
                                 N (| N (>> D (char (++ L))))
                                 D (- D 8) ) )
                           (link (short N)) ) ) ) )
               (nond  # Name
                  (Name
                     (const (cadr Lst))
                     (prinl ",") )
                  ((cdr Name)
                     (prinl "  i64 " (car Name) ",") )
                  (NIL
                     (prinl
                        "  i64 ptrtoint (i8* getelementptr (i8, i8* bitcast ([" (; Table length) " x i64]* @"
                        Table
                        " to i8*), i32 "
                        (+ I 16 4)
                        ") to i64)," ) ) )
               (const (caddr Lst))  # Value
               (and
                  (cadr Lst)
                  (pre? "_" (caddr Lst))
                  (idx '*Map2 (def (cadr Lst) (caddr Lst)) T) )
               (when (cdr Name)  # Long name
                  (prinl ",")
                  (inc 'I 16)
                  (prinl "  i64 " (car Name) ",")
                  (prin "  i64 " (cadr Name)) ) )
            (prinl (unless (== Lst (last Args)) ",")) )
         (inc 'I 16) ) )
   (unless *Shared
      (prinl "], align 16") ) )

(de inline Lst
   (let L (and (lst? (car Lst)) (++ Lst))
      (put
         (def (putMap (++ Lst))
            (let ((@Args . @Body) Lst)
               (bind
                  (mapcar
                     '((X) (cons X (name X)))
                     @Args )
                  (setq
                     @Body (fill @Body @Args)
                     @Args (mapcar val @Args) ) )
               (fill
                  '(@Args
                     (log)
                     (let *Log NIL
                        (let *Bind NIL
                           (for Var '@Args
                              (+bind '@Body Var) )
                           . @Body ) ) ) ) ) )
         'phi
         L ) ) )

(de tailcall Prg
   (let *Call "tail call"
      (run Prg) ) )

(de define (Ext Ret Sym Args Body)
   (and Body (prinl))
   (setq *Ssa -1)
   (off *Bind *Phi *Safe)
   (bind (and Body (mapcar fin Args))
      (with Sym
         (setq *Ret
            (if Ret
               (type Ret)
               (=: noreturn T)
               void ) )
         (cond
            (Ext (prin "declare " *Ret " @" Sym "("))
            (Body
               (putMap Sym)
               (prin "define " *Ret " @" Sym "(") ) )
         (when
            (=: args
               (replace
                  (ifn Body
                     Args
                     (mapcar
                        '((A)
                           (+bind Body (fin A))
                           (set
                              (set (fin A) (pack "%" (inc '*Ssa)))
                              (if (atom A) 'any (car A)) ) )
                        Args ) )
                  'any 'i64 ) )
            (=: sign (cons *Ret (: args)))
            (when (or Ext Body)
               (prin (car (: args)))
               (for A (cdr (: args))
                  (prin ", " A) ) ) )
         (cond
            (Ext (prinl ")"))
            (Body (prinl ") align 8 {")) )
         (def This
            (list 'pico~@
               (make
                  (link 'let 'A
                     (list 'mapcar
                        ''((Typ) (pack Typ " " (next)))
                        (lit (: args)) ) )
                  (link '(log))
                  (let L
                     (list
                        '*Call " " (lit *Ret) " @" (lit Sym)
                        "(" '(glue ", " A) ")" )
                     (link
                        (if (== void *Ret)
                           (list 'link (cons 'pack L))
                           (cons 'ssa '(inc '*Ssa) L) ) ) )
                  (if (: noreturn)
                     (link '(link "unreachable") NIL)
                     (link
                        (or
                           (== void *Ret)
                           (list 'def '(pack "%" *Ssa) (lit Ret)) ) ) ) ) ) ) )
      (when Body
         (let (*Lbl 1  *Log T)
            (for X
               (make
                  (label *Lbl)
                  (let? R (run Body)
                     (and *Safe (drop *Safe))
                     (if (== void *Ret)
                        (link "ret void")
                        (link (pack "ret " *Ret " " R)) ) ) )
               (cond
                  ((num? X)
                     (prinl "$" X ":")
                     (for L (cdr (asoq X *Phi))
                        (when (cadr L)
                           (prin
                              "  " (cadr L) " = phi "
                              (type (val (cadr L)))
                              " [" (cdaddr L) ", %$" (caaddr L) "]" )
                           (for X (cdddr L)
                              (prin ", [" (cdr X) ", %$" (car X) "]") )
                           (prinl " ; # " (or (name (car L)) "->")) ) ) )
                  ((atom X) (prinl "  " X))
                  ((not (car X)) (prinl "; # " (cdr X)))
                  (T (prinl "  " (car X) " = " (cdr X))) ) ) )
         (prinl "}") ) ) )

(de struct Lst
   (def (putMap (car Lst))
      (let
         (@N 0
            @L
            (mapcar
               '((X)
                  (prog1
                     (cons (car X) @N (cddr X))
                     (inc '@N (eval (cadr X))) ) )
               (cdr Lst) ) )
         (curry (@N @L) (P)
            (if (=T P)
               @N
               (let @P (or P (llvm~b8 @N))
                  (curry (@P) Args
                     (log)
                     (let *Log NIL
                        (nond
                           (Args '@P)
                           ((or
                                 (asoq (car Args) '@L)
                                 (and
                                    (pair (car Args))
                                    (asoq (car pico~@) '@L) ) )
                              (quit "Bad struct item" (car Args)) )
                           (NIL
                              (let P (llvm~ofs '@P (cadr pico~@))
                                 (let Q ((ptr (caddr pico~@)) P)
                                    (if (atom (car Args))
                                       (if (cadr Args)
                                          (llvm~set Q (eval pico~@ 1 '(*Log)))
                                          (llvm~val Q) )
                                       (ifn (cdar Args)
                                          P
                                          (let A (cadar Args)
                                             (setq P
                                                (llvm~ofs P
                                                   (if (sym? A) (; A offset) (eval A 1 '(*Log))) ) ) )
                                          (ifn (cddar Args)
                                             P
                                             (let Q ((ptr (caddar Args)) P)
                                                (if (cadr Args)
                                                   (llvm~set Q (eval pico~@ 1 '(*Log)))
                                                   (llvm~val Q) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) )


### Cross compiler overridden ###
(symbols '(cross pico llvm))

(de llvm~de Lst
   (define
      (or
         (and (=T (car Lst)) (++ Lst))
         (and
            *Shared
            (not ((if (lst? (cadr Lst)) cddr cdddr) Lst)) ) )
      (if (lst? (cadr Lst)) 'any (++ Lst))
      (car Lst)
      (cadr Lst)
      (cddr Lst) ) )

(de llvm~evBool (Exe)
   (let X (eval Exe)
      (cond
         ((num? X) (if (=0 X) NO YES))
         ((== 'i1 (val X)) X)
         (T
            (let *Log NIL
               (llvm~n0 X) ) ) ) ) )

# Type casts
(asm ()
   ((X)
      (if (num? X)
         (def (format X) 'i8)
         (let V (type (val X))
            (casq V
               ((i16 i32 i64 any) (ssa (inc '*Ssa) "trunc " V " " X " to i8"))
               (T (quit "Bad type" V)) ) )
         (def (pack "%" *Ssa) 'i8) ) )
   (llvm~i8) )

(asm ()
   ((X)
      (if (num? X)
         (def (format X) 'i16)
         (let V (type (val X))
            (casq V
               ((i1 i8) (ssa (inc '*Ssa) "zext " V " " X " to i16"))
               ((i64 any) (ssa (inc '*Ssa) "trunc " V " " X " to i16"))
               (T (quit "Bad type" V)) ) )
         (def (pack "%" *Ssa) 'i16) ) )
   (llvm~i16) )

(asm ()
   ((X)
      (if (num? X)
         (def (format X) 'i32)
         (let V (type (val X))
            (casq V
               ((i1 i8) (ssa (inc '*Ssa) "zext " V " " X " to i32"))
               ((i64 any) (ssa (inc '*Ssa) "trunc " V " " X " to i32"))
               (T (quit "Bad type" V)) ) )
         (def (pack "%" *Ssa) 'i32) ) )
   (llvm~i32) )

(asm ()
   ((X)
      (let V (val X)
         (if (== 'any V)
            (def (name X) 'i64)
            (casq V
               ((i1 i8) (ssa (inc '*Ssa) "zext " V " " X " to i64"))
               ((i16 i32) (ssa (inc '*Ssa) "sext " V " " X " to i64"))
               ((i1* i8* i8** i16* i16** i32* i32** i64* i64**)
                  (ssa (inc '*Ssa) "ptrtoint " V " " X " to i64") )
               (T (quit "Bad type" V)) )
            (def (pack "%" *Ssa) 'i64) ) ) )
   (llvm~i64) )

(asm (@Typ)
   ((X)
      (let V (val X)
         (cond
            ((pair V)
               (ssa (inc '*Ssa) "bitcast " (func V) "* " X " to " '@Typ)
               (def (pack "%" *Ssa) '@Typ) )
            ((memq V '(i64 any))
               (ssa (inc '*Ssa) "inttoptr i64 " X " to " '@Typ)
               (def (pack "%" *Ssa) '@Typ) )
            ((== 'null V)
               (ssa (inc '*Ssa) "inttoptr i64 0 to " '@Typ)
               (def (pack "%" *Ssa) '@Typ) )
            ((sub? "*" V)
               (if (== V '@Typ)
                  X
                  (ssa (inc '*Ssa) "bitcast " V " " X " to " '@Typ)
                  (def (pack "%" *Ssa) '@Typ) ) )
            (T (quit "Bad type" V)) ) ) )
   (llvm~i1* llvm~i1*)
   (llvm~i8* llvm~i8*)
   (llvm~i8** llvm~i8**)
   (llvm~i16* llvm~i16*)
   (llvm~i32* llvm~i32*)
   (llvm~i64* llvm~i64*) )

(asm ()
   ((X)
      (if (num? X)
         (def (format X) 'any)
         (let V (val X)
            (cond
               ((pre? "@$" X)
                  (ssa (inc '*Ssa) "ptrtoint i64* " X " to i64") )
               ((== 'i64 V)
                  (def (name X) 'any) )
               ((memq V '(i1* i8* i16* i32* i64*))
                  (ssa (inc '*Ssa) "ptrtoint " V " " X " to i64") )
               (T (quit "Bad type" V)) )
            (def (pack "%" *Ssa) 'any) ) ) )
   (llvm~any) )

(asm ()
   (Args
      (if (pair (car Args))
         (def (pack "@" (cadr Args)) @)
         (i8*
            (def (pack "@" (car Args))
               (func (; Args 1 sign)) ) ) ) )
   (llvm~fun) )

(asm (@Tag)
   ((X)
      (let V (val X)
         (casq V
            ((i64 any)
               (ssa (inc '*Ssa) "add i64 " X ", " @Tag)
               (def (pack "%" *Ssa) 'any) )
            ((i1* i8* i64*)
               (ssa (inc '*Ssa) "ptrtoint " V " " X " to i64")
               (ssa (inc '*Ssa) "add i64 %" (dec *Ssa) ", " @Tag)
               (ssa (inc '*Ssa) "inttoptr i64 %" (dec *Ssa) " to " V)
               (def (pack "%" *Ssa) V) )
            (T (quit "Bad type" V)) ) ) )
   (llvm~big 4)
   (llvm~dig -4)
   (llvm~tail -8) )

# Type checks
(asm (@Tag @Pred)
   ((X)
      (setq llvm~@ X)
      (ssa (inc '*Ssa) "and i64 " X ", " @Tag)
      (ssa (inc '*Ssa) "icmp " @Pred " i64 %" (dec *Ssa) ", 0")
      (def (pack "%" *Ssa) 'i1) )
   (llvm~cnt? 2 "ne")
   (llvm~big? 4 "ne")
   (llvm~num? 6 "ne")
   (llvm~sym? 8 "ne")
   (llvm~sign? 8 "ne")
   (llvm~atom 15 "ne")
   (llvm~pair 15 "eq") )

(asm ()
   ((X)
      (setq llvm~@ X)
      (ssa (inc '*Ssa) "xor i64 " X ", 8")
      (ssa (inc '*Ssa) "and i64 %" (dec *Ssa) ", 14")
      (ssa (inc '*Ssa) "icmp eq i64 %" (dec *Ssa) ", 0")
      (def (pack "%" *Ssa) 'i1) )
   (llvm~symb?) )

(asm ()
   ((X)
      (ssa (inc '*Ssa) "icmp eq i1 " X ", 0")
      (def (pack "%" *Ssa) 'i1) )
   (llvm~not) )

(asm (@Sym)
   ((X)
      (setq llvm~@ X)
      (ssa (inc '*Ssa) "icmp eq i64 " X ", " @Sym)
      (def (pack "%" *Ssa) 'i1) )
   (llvm~nil? $Nil)
   (llvm~t? $T) )

# Comparisons
(asm (@Pred)
   ((X Y)
      (setq llvm~@ X)
      (ssa (inc '*Ssa) "icmp " @Pred " "
         (type (val (if (sym? X) X Y)))
         " " X ", " Y )
      (def (pack "%" *Ssa) 'i1) )
   (llvm~== "eq")
   (llvm~<> "ne") )

(asm (@Pred1 @Pred2)
   ((X Y)
      (setq llvm~@ X)
      (let V (type (val (if (sym? X) X Y)))
         (ssa (inc '*Ssa) "icmp "
            (if (== 'i32 V) @Pred1 @Pred2)
            " " V " " X ", " Y ) )
      (def (pack "%" *Ssa) 'i1) )
   (llvm~> "sgt" "ugt")
   (llvm~>= "sge" "uge")
   (llvm~< "slt" "ult")
   (llvm~<= "sle" "ule") )

(asm (@Pred)
   ((X)
      (setq llvm~@ X)
      (ssa (inc '*Ssa) "icmp " @Pred " "
         (type (val X)) " " X ", "
         (if (sub? "*" (val X)) null 0) )
      (def (pack "%" *Ssa) 'i1) )
   (llvm~=0 "eq")
   (llvm~n0 "ne") )

(asm (@Pred)
   ((X)
      (setq llvm~@ X)
      (ssa (inc '*Ssa) "icmp " @Pred
         " " (type (val X)) " " X ", 0" )
      (def (pack "%" *Ssa) 'i1) )
   (llvm~gt0 "sgt")
   (llvm~ge0 "sge")
   (llvm~le0 "sle")
   (llvm~lt0 "slt") )

# Arithmetics
(asm (@Op1 @Op2 @Sgn)
   ((X . @)
      (cond
         ((num? X) (pass @Op1 X))
         ((args)
            (let V (val X)
               (for (Y (next)  Y  (next))
                  (casq V
                     ((i8 i32 i64 any)
                        (when (and (sym? Y) (== 'i1 (val Y)))
                           (ssa (inc '*Ssa) "zext i1 " Y " to i64")
                           (setq Y (pack "%" *Ssa)) )
                        (ssa (inc '*Ssa) @Op2 " " (type V) " " X ", " Y) )
                     ((i1* i1** i8* i8** i8*** i32* i32** i64* i64**)
                        (let Typ (pointee V)
                           (if (num? Y)
                              (ssa (inc '*Ssa) "getelementptr " Typ ", " V " " X ", i32 " @Sgn Y)
                              (ssa (inc '*Ssa) "ptrtoint " V " " X " to i64")
                              (ssa (inc '*Ssa) "ptrtoint " (val Y) " " Y " to i64")
                              (ssa (inc '*Ssa) @Op2 " i64 %" (- *Ssa 2) ", %" (dec *Ssa))
                              (setq V 'i64) ) ) )
                     (T (quit "Bad type" V)) )
                  (setq X (def (pack "%" *Ssa) V)) ) ) )
         (T
            (ssa (inc '*Ssa) @Op2 " " (type (val X)) " 0, " X)
            (def (pack "%" *Ssa) (val X)) ) ) )
   (llvm~+ + "add")
   (llvm~- - "sub" "-") )

(asm (@Op)
   ((X Y C)
      (when (and (sym? Y) (== 'i1 (val Y)))
         (ssa (inc '*Ssa) "zext i1 " Y " to i64")
         (setq Y (pack "%" *Ssa)) )
      (ssa (inc '*Ssa) "call {i64, i1} @llvm.u" @Op ".with.overflow.i64(i64 " X ", i64 " Y ")")
      (ssa (inc '*Ssa) "extractvalue {i64, i1} %" (dec *Ssa) ", 1")
      (ssa (inc '*Ssa) "extractvalue {i64, i1} %" (- *Ssa 2) ", 0")
      (when C
         (ssa (inc '*Ssa) "zext i1 " C " to i64")
         (ssa (inc '*Ssa) "call {i64, i1} @llvm.u" @Op ".with.overflow.i64(i64 %" (- *Ssa 2) ", i64 %" (dec *Ssa) ")")
         (ssa (inc '*Ssa) "extractvalue {i64, i1} %" (dec *Ssa) ", 1")
         (ssa (inc '*Ssa) "or i1 %" (- *Ssa 5) ", %" (dec *Ssa))
         (ssa (inc '*Ssa) "extractvalue {i64, i1} %" (- *Ssa 3) ", 0") )
      (setq llvm~@@ (def (pack "%" (dec *Ssa)) 'i1))
      (def (pack "%" *Ssa) 'i64) )
   (llvm~add "add")
   (llvm~sub "sub") )

(asm (@Op1 @Op2 @Sgn)
   ((X Y)
      (if (num? X)
         (if Y (@Op1 X @) (@Op1 X))
         (default Y 1)
         (let
            (Typ (if (num? Y) 'i32 (type (val Y)))
               Z (or (pre? "%" X) (val X))
               V (val Z) )
            (casq V
               ((i8 i32 i64 any)
                  (ssa (inc '*Ssa) @Op2 " " (type V) " " Z ", " Y) )
               ((i1* i1** i8* i8** i8*** i16* i16** i32* i32** i64* i64**)
                  (ssa (inc '*Ssa) "getelementptr " (pointee V) ", " V " " Z ", " Typ " " @Sgn Y) )
               (T (quit "Bad type" V)) )
            (prog1
               (def (pack "%" *Ssa) V)
               (unless (pre? "%" X)
                  (set X @) ) ) ) ) )
   (llvm~inc inc "add")
   (llvm~dec dec "sub" "-") )

(asm (@Op1 @Op2)
   ((X Y)
      (if (and (num? X) (num? Y))
         (@Op1 X Y)
         (let V (type (val (if (sym? X) X Y)))
            (ssa (inc '*Ssa) @Op2 " " V " " X ", " Y)
            (def (pack "%" *Ssa) V) ) ) )
   (llvm~* * "mul")
   (llvm~/ / "udiv")
   (llvm~% % "urem")
   (llvm~& & "and")
   (llvm~| | "or")
   (llvm~x| x| "xor") )

(asm ()
   ((X Y)
      (unless (num? X)
         (ssa (inc '*Ssa) "zext i64 " X " to i128")
         (setq X (pack "%" *Ssa)) )
      (ssa (inc '*Ssa) "zext i64 " Y " to i128")
      (ssa (inc '*Ssa) "mul i128 " X ", %" (dec *Ssa))
      (ssa (inc '*Ssa) "lshr i128 %" (dec *Ssa) ", 64")
      (ssa (inc '*Ssa) "trunc i128 %" (dec *Ssa) " to i64")
      (setq llvm~@@@ (def (pack "%" *Ssa) 'i64))
      (ssa (inc '*Ssa) "trunc i128 %" (- *Ssa 3) " to i64")
      (def (pack "%" *Ssa) 'i64) )
   (llvm~mul) )

(asm ()
   ((X Y Z)
      (ssa (inc '*Ssa) "zext i64 " X " to i128")
      (ssa (inc '*Ssa) "shl i128 %" (dec *Ssa) ", 64")
      (ssa (inc '*Ssa) "zext i64 " Y " to i128")
      (ssa (setq Y (inc '*Ssa)) "or i128 %" (- *Ssa 2) ", %" (dec *Ssa))
      (unless (num? Z)
         (ssa (inc '*Ssa) "zext i64 " Z " to i128")
         (setq Z (pack "%" *Ssa)) )
      (ssa (inc '*Ssa) "urem i128 %" Y ", " Z)
      (ssa (inc '*Ssa) "trunc i128 %" (dec *Ssa) " to i64")
      (setq llvm~@@@ (def (pack "%" *Ssa) 'i64))
      (ssa (inc '*Ssa) "udiv i128 %" Y ", " Z)
      (ssa (inc '*Ssa) "trunc i128 %" (dec *Ssa) " to i64")
      (def (pack "%" *Ssa) 'i64) )
   (llvm~div) )

(asm (@Op @Op2)
   ((X Y Z)
      (when (num? X)
         (setq X (def (format X) 'i64)) )
      (ifn Z
         (let V (type (val X))
            (ssa (inc '*Ssa) @Op " " V " " X ", " Y)
            (def (pack "%" *Ssa) V) )
         (ssa (inc '*Ssa) "call "
            "i64 @llvm." @Op2 ".i64("
            "i64 " X ", "
            "i64 " Y ", "
            "i64 " Z ")" )
         (def (pack "%" *Ssa) 'i64) ) )
   (llvm~shl "shl" "fshl")
   (llvm~shr "lshr" "fshr") )

# Memory access
(asm ()
   ((X Y)
      (if (=0 Y)
         X
         (casq (val X)
            (any
               (if (num? Y)
                  (ssa (inc '*Ssa) "add i64 " X ", " (* 8 Y))
                  (if (== 'i64 (val Y))
                     (ssa (inc '*Ssa) "shl i64 " Y ", 3")
                     (ssa (inc '*Ssa) "zext " (val Y) " " Y " to i64")
                     (ssa (inc '*Ssa) "shl i64 %" (dec *Ssa) ", 3") )
                  (ssa (inc '*Ssa) "add i64 " X ", %" (dec *Ssa)) ) )
            ((i1* i1** i8* i8** i8*** i32* i32** i64* i64**)
               (ssa (inc '*Ssa) "getelementptr " (pointee (val X)) ", "
                  (val X) " " X ", "
                  (if (num? Y) 'i32 (val Y)) " " Y ) )
            (T (quit "Bad type" (val X))) )
         (def (pack "%" *Ssa) (val X)) ) )
   (llvm~ofs) )

(asm ()
   ((X)
      (ssa (inc '*Ssa) "inttoptr i64 " X " to i64*")
      (ssa (inc '*Ssa) "load i64, i64* %" (dec *Ssa))
      (def (pack "%" *Ssa) 'any) )
   (llvm~car) )

(asm ()
   ((X)
      (ssa (inc '*Ssa) "inttoptr i64 " X " to i64*")
      (ssa (inc '*Ssa) "getelementptr i64, i64* %" (dec *Ssa) ", i32 1")
      (ssa (inc '*Ssa) "load i64, i64* %" (dec *Ssa))
      (def (pack "%" *Ssa) 'any) )
   (llvm~cdr) )

(asm ()
   (Args
      (ssa (inc '*Ssa) "inttoptr i64 " (val (car Args)) " to i64*")
      (ssa (inc '*Ssa) "load i64, i64* %" (dec *Ssa))
      (let P *Ssa
         (ssa (inc '*Ssa) "getelementptr i64, i64* %" (- *Ssa 2) ", i32 1")
         (ssa (inc '*Ssa) "load i64, i64* %" (dec *Ssa))
         (set (car Args) (def (pack "%" *Ssa) 'any))
         (def (pack "%" P) 'any) ) )
   (llvm~++) )

(asm ()
   (Args
      (ssa (inc '*Ssa) "inttoptr i64 " (val (car Args)) " to i64*")
      (ssa (inc '*Ssa) "getelementptr i64, i64* %" (dec *Ssa) ", i32 1")
      (ssa (inc '*Ssa) "load i64, i64* %" (dec *Ssa))
      (set (car Args) (def (pack "%" *Ssa) 'any)) )
   (llvm~shift) )

(asm ()
   (@
      (let (X (next)  Ofs)
         (when (num? X)
            (setq Ofs (dec X)  X (next)) )
         (casq (val X)
            (any
               (if (pre? "@" X)
                  (ssa (inc '*Ssa) "load " "i64, i64* " X)
                  (ssa (inc '*Ssa) "inttoptr i64 " X " to i64*")
                  (when Ofs
                     (ssa (inc '*Ssa) "getelementptr i64, i64* %" (dec *Ssa) ", i32 " Ofs) )
                  (ssa (inc '*Ssa) "load " "i64, i64* %" (dec *Ssa)) )
               (def (pack "%" *Ssa) 'any) )
            ((i1* i1** i8* i8** i8*** i16* i16** i32* i32** i64* i64**)
               (let Typ (pointee (val X))
                  (ifn Ofs
                     (ssa (inc '*Ssa) "load " Typ ", " (val X) " " X)
                     (ssa (inc '*Ssa) "getelementptr " Typ ", " (val X) " " X ", i32 " Ofs)
                     (ssa (inc '*Ssa) "load " Typ ", " (val X) " %" (dec *Ssa)) )
                  (def (pack "%" *Ssa) Typ) ) )
            (T (quit "Bad type" (val X))) ) ) )
   (llvm~val) )

(asm ()
   (Args
      (while Args
         (let (A (eval (++ Args) 1)  B (eval (++ Args) 1))
            (ifn (num? A)
               (store B A)
               (store (eval (++ Args) 1) B (dec A)) ) ) ) )
   (llvm~set) )

(asm ()
   ((X Y)
      (ifn (pre? "%" X)
         (xchg X Y)
         (ssa (inc '*Ssa) "inttoptr i64 " X " to i64*")
         (ssa (inc '*Ssa) "load " "i64, i64* %" (dec *Ssa))
         (ssa (inc '*Ssa) "inttoptr i64 " Y " to i64*")
         (ssa (inc '*Ssa) "load " "i64, i64* %" (dec *Ssa))
         (link (pack "store i64 %" *Ssa ", i64* %" (- *Ssa 3)))
         (link (pack "store i64 %" (- *Ssa 2) ", i64* %" (dec *Ssa)))
         (def (pack "%" (- *Ssa 2)) 'any) ) )
   (llvm~xchg) )

(asm ()
   ((X Y Z Flg)
      (link
         (pack
            "call void @llvm.memcpy.p0i8.p0i8.i64(i8* "
            (and Flg "align 8 ") X
            ", " 'i8* " " Y
            ", i64 " Z
            ", i1 0)" ) ) )
   (llvm~memcpy) )

(asm ()
   ((X Y Z Flg)
      (link
         (pack
            "call void @llvm.memset.p0i8.i64(i8* "
            (and Flg "align 8 ") X
            ", " 'i8 " " Y
            ", i64 " Z
            ", i1 0)" ) ) )
   (llvm~memset) )

(asm ()
   (Lst
      (use *Bind
         (let (X (++ Lst)  Safe *Safe)
            (prog1
               (if (pair X)
                  (recur ()
                     (let (Var (++ X)  Val (eval (++ X)))
                        (and (atom Val) (+bind Lst Var))
                        (bind Var
                           (set Var Val)
                           (if X (recurse) (run Lst)) ) ) )
                  (let Val (eval (++ Lst))
                     (and (atom Val) (+bind Lst X))
                     (bind X
                        (set X Val)
                        (run Lst) ) ) )
               (when (and @ *Safe (not Safe))
                  (drop *Safe)
                  (off *Safe) ) ) ) ) )
   (llvm~let) )

# Stack operations
(asm ()
   ((P)
      (if P
         (prog
            (link (pack "call void @llvm.stackrestore(i8* " P ")"))
            P )
         (ssa (inc '*Ssa) "call i8* @llvm.stacksave()")
         (def (pack "%" *Ssa) 'i8*) ) )
   (llvm~stack) )

(asm (@Typ @Ptr)
   ((N)
      (ssa (inc '*Ssa) "alloca " '@Typ ", "
         (if (num? N) 'i64 (val N))
         " " N )
      (def (pack "%" *Ssa) '@Ptr) )
   (llvm~b8 i8 i8*)
   (llvm~b8* i8* i8**)
   (llvm~b32 i32 i32*)
   (llvm~b64 i64 i64*) )

(asm ()
   (@
      (let
         (Lst (rest)
            Typ
            (or
               (pick
                  '((X)
                     (cond
                        ((num? X) 'i64)
                        (X (val X)) ) )
                  Lst )
               'any ) )
         (ssa (inc '*Ssa) "alloca "
            (type Typ) ", i64 " (length Lst)
            (and (cdr Lst) ", align 16") )
         (when (== 'any Typ)
            (ssa (inc '*Ssa) "ptrtoint i64* %" (dec *Ssa) " to i64") )
         (let P (def (pack "%" *Ssa) (ptr Typ))
            (for (I . Y) Lst
               (when Y
                  (if (=1 I)
                     (store Y P)
                     (if (== 'any Typ)
                        (ssa (inc '*Ssa) "add i64 " P ", " (* 8 (dec I)))
                        (ssa (inc '*Ssa) "getelementptr "
                           (type Typ) ", " (val P) " " P ", i32 " (dec I) ) )
                     (store Y (def (pack "%" *Ssa) (val P))) ) ) )
            P ) ) )
   (llvm~push) )

# Flow
(asm ()
   ((Fun X Y)
      (ssa (inc '*Ssa) "and i64 " Fun ", -3")
      (ssa (inc '*Ssa) "inttoptr i64 %" (dec *Ssa) " to i64(i64,i64)*")
      (ssa (inc '*Ssa) "call i64 %" (dec *Ssa) "(i64 " X "," "i64 " Y ")")
      (def (pack "%" *Ssa) 'any) )
   (llvm~subr) )

(asm (@Val1 @Val2 @Lbl1 @Lbl2)
   (Prg
      (let (End (+lbl)  Var (box))
         (for Exe Prg
            (if (== Exe (last Prg))
               (when (set Var (evBool (car Prg)))
                  (phi End Var)
                  (br End) )
               (let (Flg (evBool (++ Prg))  Skip (+lbl))
                  (set Var @Val1)
                  (phi End Var)
                  (br Flg @Lbl1 @Lbl2)
                  (label Skip) ) ) )
         (label End) ) )
   (llvm~and NO YES Skip End)
   (llvm~or YES NO End Skip) )

(asm ()
   (Prg
      (prog1
         (setq llvm~@ (eval (++ Prg)))
         (run Prg) ) )
   (llvm~prog1) )

(asm ()
   (Prg
      (prog2
         (eval (++ Prg))
         (setq llvm~@ (eval (++ Prg)))
         (run Prg) ) )
   (llvm~prog2) )

(asm (@Lbl1 @Lbl2)
   (Prg
      (let (Flg (evBool (++ Prg))  Var (box)  Body (+lbl)  Skip (+lbl)  End (+lbl))
         (br Flg @Lbl1 @Lbl2)
         (label Body)
         (use llvm~@
            (when (set Var (eval (++ Prg)))
               (phi End Var)
               (br End) )
            (label Skip) )
         (use llvm~@
            (when (set Var (run Prg))
               (phi End Var)
               (br End) ) )
         (label End) ) )
   (llvm~if Body Skip)
   (llvm~ifn Skip Body) )

(asm (@Lbl1 @Lbl2)
   (Prg
      (let (Flg (evBool (++ Prg))  Body (+lbl)  End (+lbl))
         (br Flg @Lbl1 @Lbl2)
         (label Body)
         (use llvm~@
            (and (run Prg) (br End)) )
         (label End) )
      T )
   (llvm~when Body End)
   (llvm~unless End Body) )

(asm (@Flg @Lbl1 @Lbl2 @Lbl3 @Lbl4 @Lbl5 @Lbl6)
   (Lst
      (let (Var (box)  End (+lbl)  Flg)
         (for Prg Lst
            (if (== @Flg (car Prg))
               (use llvm~@
                  (when (set Var (run (cdr Prg)))
                     (phi End Var)
                     (br End) ) )
               (setq Flg (evBool (++ Prg)))
               (let Skip (+lbl)
                  (if Prg
                     (let Body (+lbl)
                        (br Flg @Lbl1 @Lbl2)
                        (label Body)
                        (use llvm~@
                           (when (set Var (run Prg))
                              (phi End Var)
                              (br End) ) ) )
                     (br Flg @Lbl3 @Lbl4) )
                  (label Skip) ) ) )
         (if (== @Flg (car (last Lst)))
            (label End)
            (set Var 0)
            (phi End Var)
            (br End)
            (label End)
            T ) ) )
   (llvm~cond T Body Skip End Skip Body End)
   (llvm~nond NIL Skip Body Skip End End Body) )

(asm ()
   (Lst
      (let
         (Var (box)
            True (+lbl)
            Flg (asoq T Lst)
            End (if Flg (+lbl) True)
            X (setq llvm~@ (eval (++ Lst))) )
         (link
            (pack
               "switch " (type (val X)) " " X
               ", label %$" (+phi True) " [" ) )
         (let Lbl
            (extract
               '((Prg)
                  (unless (=T (car Prg))
                     (let Y (eval (car Prg))
                        (prog1
                           (+lbl)
                           (link
                              (pack
                                 "  " (type (val X)) " " Y
                                 ", label %$" (+phi @) ) ) ) ) ) )
               Lst )
            (link "]")
            (for Prg Lst
               (label (if (=T (++ Prg)) True (++ Lbl)))
               (use llvm~@
                  (when (set Var (if Prg (run @) 0))
                     (and Flg (phi End Var))
                     (br End) ) ) ) )
         (label End) ) )
   (llvm~case) )

(asm ()
   (Prg
      (let (Flg (evBool (++ Prg))  False (+lbl))
         (default *Exit (cons (+lbl) (box)))
         (if Prg
            (let True (+lbl)
               (br Flg True False)
               (label True)
               (use llvm~@
                  (let? X (run Prg)
                     (when (cdr *Exit)
                        (set @ X)
                        (phi (car *Exit) @) )
                     (br (car *Exit)) ) ) )
            (when (cdr *Exit)
               (set @ 0)
               (phi (car *Exit) @) )
            (br Flg (car *Exit) False) )
         (label False) )
      T )
   (llvm~?) )

(asm (@Lbl1 @Lbl2)
   (Prg
      (let Beg (+lbl)
         (br Beg)
         (label Beg)
         (let (Flg (evBool (++ Prg))  Body (+lbl)  *Exit (cons (+lbl)))
            (br Flg @Lbl1 @Lbl2)
            (label Body)
            (use llvm~@
               (and (run Prg) (br Beg)) )
            (label (car *Exit)) ) )
      T )
   (llvm~while Body (car *Exit))
   (llvm~until (car *Exit) Body) )

(asm ()
   (Prg
      (let (Beg (+lbl)  *Exit)
         (br Beg)
         (label Beg)
         (and (run Prg) (br Beg))
         (cond
            (*Exit (label (car *Exit)))
            ((fish
                  '((X)
                     (and
                        (== 'llvm~goto (car (pair X)))
                        (not (memq (- (cadr X)) (made))) ) )
                  Prg )
               (label (+lbl)) ) ) ) )
   (llvm~loop) )

(asm ()
   ((Fun . @)
      (let
         (L (val Fun)
            F (func L)
            A
            (mapcar
               '((Typ) (pack Typ " " (next)))
               (cdr L) ) )
         (ssa (inc '*Ssa) "load " F ", " F "* " Fun)
         (let S
            (pack *Call " "
               (car L) " " (pack "%" *Ssa)
               "(" (glue ", " A) ")" )
            (if (== void (car L))
               (link S)
               (ssa (inc '*Ssa) S)
               (def (pack "%" *Ssa) (car L)) ) ) ) )
   (llvm~call) )

(asm ()
   ((Lbl . Prg)
      (br (- Lbl))
      (label (- Lbl))
      (run Prg) )
   (llvm~:) )

(asm ()
   ((Lbl) (br (- Lbl)) NIL)
   (llvm~goto) )

(asm ()
   ((X)
      (and *Safe (drop *Safe))
      (if (== void *Ret)
         (link "ret void")
         (link (pack "ret " *Ret " " X)) )
      NIL )
   (llvm~ret) )


### Composite ###
(symbols '(llvm cross pico))

(local) (link drop pop save save2 safe)

(cross~de link (P Top)
   (log)
   (pico~let *Log NIL
      (pico~when (pico~== 'i64* (pico~val P))
         (setq P (any P)) )
      (pico~when Top
         (default *Safe P) )
      (set 2 P (val $Link))
      (set $Link P) ) )

(cross~de drop (P . Prg)
   (log)
   (pico~let *Log NIL
      (pico~when (pico~== 'i64* (pico~val P))
         (setq P (any P)) )
      (pico~if Prg
         (prog1
            (pico~let *Log T
               (run pico~@) )
            (set $Link (cdr P)) )
         (set $Link (cdr P)) ) ) )

(cross~de pop (P)
   (log)
   (pico~let *Log NIL
      (prog1
         (val P)
         (set $Link (cdr P)) ) ) )

(cross~de save (X . Prg)
   (log)
   (pico~let (*Log NIL  Safe *Safe  P (push X (val $Link)))
      (default *Safe P)
      (set $Link P)
      (pico~if Prg
         (prog1
            (pico~let *Log T
               (run pico~@) )
            (pico~when pico~@
               (log "drop")
               (drop P)
               (setq *Safe Safe) ) )
         X ) ) )

(cross~de save2 (X Y . Prg)
   (log)
   (pico~let (*Log NIL  Safe *Safe  P (push X (val $Link)))
      (default *Safe P)
      (set $Link (push Y P))
      (pico~if Prg
         (prog1
            (pico~let *Log T
               (run pico~@) )
            (pico~when pico~@
               (log "drop")
               (drop P)
               (setq *Safe Safe) ) )
         Y ) ) )

(cross~de safe (V)
   (log)
   (pico~let *Log NIL
      (store V *Safe) ) )
