# 16dec24 Software Lab. Alexander Burger

(symbols '(llvm))

(var $AV0 i8* null)                    # Command name
(var $AV i8** null)                    # Command line argument vector
(var $PilHome i8* null)                # Picolisp home directory
(var $PilLen i64 0)                    # $PilHome length
(var $UsrHome i8* null)                # User home directory
(var $UsrLen i64 0)                    # $UsrHome length
(var $Heaps 0)                         # Heap list
(var $Avail 0)                         # Avail list
(var $Extern 0)                        # External symbol tree
(var $ExtCnt i64 1)                    # External symbol count
(var $ExtSkip i64 0)                   # External tree skip
(var $Coroutines i8* null)             # Coroutines
(var $Current i8* null)                # Current coroutine
(var $CrtLast i8* null)                # Last Coroutine
(var $CrtFree i8* null)                # Coroutine free list link
(var $StkLimit i8* null)               # Stack limit: StackN-Size+1024
(var $StkSizeT i64 (* 4 STACK))        # Coroutine main stack segment size
(var $StkSize i64 STACK)               # Coroutine stack segment size
(var $Stdin i8* null)                  # Stdin frame
(var $Stdout i8* null)                 # Stdout frame
(var $LinePtr i8* null)                # Console line pointer
(var $LineBuf i8* null)                # Console line buffer
(var $LinePrmt i8* null)               # Console line prompt
(var $ReplPrmt i8* null)               # REPL console prompt
(var $ContPrmt i8* null)               # REPL continue prompt
(var $Ret 0)                           # Secondary return value
(var $TtyPid i32 0)                    # Terminal process ID
(var $InFDs i32 0)                     # Number of input files
(var $InFiles i8** null)               # Input files
(var $OutFiles i8** null)              # Output files
(var $IoCnt i32 0)                     # 'output' count
(var $IoIx i64 0)                      # 'output' index
(var $IoChar i64 0)                    # 'input' and 'output' char
(var $PutBin (void i8) null)           # Binary output function
(var $GetBin (i32) null)               # Binary input function
(var $OutFDs i32 0)                    # Number of ourput files
(var $Nfds i32 0)                      # Number of poll entries
(var $Poll i64* null)                  # Poll entries
(var $SeedL i64 0)                     # Random seed low
(var $SeedH i64 0)                     # Random seed high
(var $USec i64 0)                      # Startup microseconds
(var $Child i8* null)                  # Child array
(var $Children i32 0)                  # Number of children
(var $Slot i32 0)                      # Child index
(var $Spkr i32 0)                      # RPC loadspeaker
(var $Mic i32 0)                       # RPC microphone
(array $SpMiPipe i32 0 0)              # Speaker/microphone pipe
(var $Talking i32 0)                   # Active child
(var $Hear i32 0)                      # RPC listener
(var $Tell i32 0)                      # RPC broadcaster
(var $TellBuf i8* null)                # RPC buffer
(var $Ptr i8* null)                    # Byte buffer pointer
(var $End i8* null)                    # Buffer end pointer
(var $BufX i8* null)                   # Exchange buffer
(var $PtrX i8* null)                   # Exchange buffer pointer
(var $EndX i8* null)                   # Exchange end pointer
(var $ExtN i32 0)                      # External symbol offset
(var $Extn i32 0)
(var $StrP i64* null)                  # String status
(var $GcCount i64 CELLS)               # Collector count

# Database
(var $DbFiles i8* null)                # DB files
(var $DbFile i8* null)                 # DB file
(var $DBs i32 0)                       # Number of DB files
(var $MaxBlkSize i32 0)                # Maximum block size
(var $DbBlock i8* null)                # Block buffer
(var $BlkIndex i64 0)                  # Block index
(var $BlkLink i64 0)                   # Next block
(var $BlkPtr i8* null)                 # Block byte buffer pointer
(var $BlkEnd i8* null)                 # Block buffer end pointer
(var $DbJnl i8* null)                  # Journal file
(var $DbLog i8* null)                  # Transaction log file

# Signals
(array $Signal i32  # Sync src/lib.c 'gSignal'
   0    # Count
   0    # SIGHUP
   0    # SIGINT
   0    # SIGUSR1
   0    # SIGUSR2
   0    # SIGPIPE
   0    # SIGALRM
   0    # SIGTERM
   0    # SIGCHLD
   0    # SIGCONT
   0    # SIGSTOP
   0    # SIGTSTP
   0    # SIGTTIN
   0    # SIGTTOU
   0    # SIGWINCH
   0 )  # SIGIO

# Symbol Table
(symTab
   ($Nil "NIL" $Nil)          # NIL symbol
   (NIL $Nil 0)               # CDR of NIL as empty list
   ($Tilde "~" $Tilde)        # Tilde symbol
   ($PicoT $Nil $Nil 0)       # Pico trees
   ($Pico $Tilde $PicoT 0)    # Initial namespace
   ($pico "pico" $Pico)
   ($Pico1 $pico $Nil 0)
   ($PrivT $Nil $Nil 0)       # Private trees
   ($Priv $Tilde $PrivT 0)    # Private namespace
   ($priv "priv" $Priv)
   ($OS "*OS" 0)              # Operating system
   ($CPU "*CPU" 0)            # Processor
   ($Pid "*Pid" 0)            # Process ID
   ($PPid "*PPid" $Nil)       # Parent Process ID
   ($DB "*DB" $Nil)           # Database root
   ($Meth "meth" __Meth)      # Method template
   ($Quote "quote" _Quote)    # 'quote' function
   ($T "T" $T)  ### Sync src/pico.h 'T' (17*2+1) ###
   ($N "N" $Nil)
   ($C "C" $Nil)
   ($S "S" $Nil)
   ($B "B" $Nil)
   ($I "I" $Nil)
   ($P "P" $Nil)
   ($W "W" $Nil)
   ($Db1 0 $Nil)              # Database root symbol '{1}'
   ($Solo "*Solo" ZERO)
   ($At "@" $Nil)
   ($At2 "@@" $Nil)
   ($At3 "@@@" $Nil)
   ($This "This" $Nil)
   ($Prompt "*Prompt" $Nil)
   ($Zap "*Zap" $Nil)
   ($Ext "*Ext" $Nil)
   ($Scl "*Scl" ZERO)
   ($Rule "*Rule" $Nil)
   ($Class "*Class" $Nil)
   ($Run "*Run" $Nil)
   ($Hup "*Hup" $Nil)
   ($Sig1 "*Sig1" $Nil)
   ($Sig2 "*Sig2" $Nil)
   ($Winch "*Winch" $Nil)
   ($TStp1 "*TStp1" $Nil)
   ($TStp2 "*TStp2" $Nil)
   ($Term "*Term" $Nil)
   ($Up "\^" $Nil)
   ($Err "*Err" $Nil)
   ($Msg "*Msg" $Nil)
   ($Uni "*Uni" $Nil)
   ($Fork "*Fork" $Nil)
   ($Bye "*Bye" $Nil)
   ($Dbg "*Dbg" $Nil)
   ($Complete "complete" $Nil)
   ($Remark "remark" $Nil)
   # Garbage collection
   (NIL "gc" _Gc)
   # Arithmetics
   (NIL "format" _Format)
   (NIL "+" _Add)
   (NIL "-" _Sub)
   (NIL "inc" _Inc)
   (NIL "dec" _Dec)
   (NIL "*" _Mul)
   (NIL "*/" _MulDiv)
   (NIL "/" _Div)
   ($rem "%" _Rem)
   (NIL ">>" _Shr)
   (NIL "rev" _Rev)
   (NIL "lt0" _Lt0)
   (NIL "le0" _Le0)
   (NIL "ge0" _Ge0)
   (NIL "gt0" _Gt0)
   (NIL "abs" _Abs)
   (NIL "bit?"_BitQ)
   (NIL "&" _BitAnd)
   (NIL "|" _BitOr)
   (NIL "x|" _BitXor)
   (NIL "sqrt" _Sqrt)
   (NIL "seed" _Seed)
   (NIL "hash" _Hash)
   (NIL "rand" _Rand)
   # Symbol functions
   (NIL "name" _Name)
   (NIL "nsp" _Nsp)
   (NIL "sp?" _SpQ)
   (NIL "pat?" _PatQ)
   (NIL "fun?" _FunQ)
   (NIL "getd" _Getd)
   (NIL "all" _All)
   (NIL "symbols" _Symbols)
   (NIL "intern" _Intern)
   (NIL "====" _Hide)
   (NIL "box?" _BoxQ)
   (NIL "str?" _StrQ)
   (NIL "zap" _Zap)
   (NIL "chop" _Chop)
   (NIL "pack" _Pack)
   (NIL "glue" _Glue)
   (NIL "text" _Text)
   (NIL "pre?" _PreQ)
   (NIL "sub?" _SubQ)
   (NIL "val" _Val)
   (NIL "set" _Set)
   (NIL "setq" _Setq)
   (NIL "swap" _Swap)
   (NIL "xchg" _Xchg)
   (NIL "on" _On)
   (NIL "off" _Off)
   (NIL "onOff" _OnOff)
   (NIL "zero" _Zero)
   (NIL "one" _One)
   (NIL "default" _Default)
   (NIL "push" _Push)
   (NIL "push1" _Push1)
   (NIL "push1q" _Push1q)
   (NIL "pop" _Pop)
   (NIL "++" _Popq)
   (NIL "shift" _Shift)
   (NIL "cut" _Cut)
   (NIL "del" _Del)
   (NIL "queue" _Queue)
   (NIL "fifo" _Fifo)
   (NIL "rid" _Rid)
   (NIL "enum" _Enum)
   (NIL "enum?" _EnumQ)
   (NIL "idx" _Idx)
   (NIL "lup" _Lup)
   (NIL "put" _Put)
   (NIL "get" _Get)
   (NIL "prop" _Prop)
   (NIL ";" _Semicol)
   (NIL "=:" _SetCol)
   (NIL ":" _Col)
   (NIL "::" _PropCol)
   (NIL "putl" _Putl)
   (NIL "getl" _Getl)
   (NIL "wipe" _Wipe)
   (NIL "meta" _Meta)
   (NIL "low?" _LowQ)
   (NIL "upp?" _UppQ)
   (NIL "lowc" _Lowc)
   (NIL "uppc" _Uppc)
   (NIL "fold" _Fold)
   # Input/Output
   (NIL "path" _Path)
   (NIL "wait" _Wait)
   (NIL "sync" _Sync)
   (NIL "hear" _Hear)
   (NIL "tell" _Tell)
   (NIL "poll" _Poll)
   (NIL "read" _Read)
   (NIL "key" _Key)
   (NIL "peek" _Peek)
   (NIL "char" _Char)
   (NIL "skip" _Skip)
   (NIL "eol" _Eol)
   (NIL "eof" _Eof)
   (NIL "from" _From)
   (NIL "till" _Till)
   (NIL "line" _Line)
   (NIL "in" _In)
   (NIL "out" _Out)
   (NIL "err" _Err)
   (NIL "ctl" _Ctl)
   (NIL "input" _Input)
   (NIL "output" _Output)
   (NIL "fd" _Fd)
   (NIL "pipe" _Pipe)
   (NIL "open" _Open)
   (NIL "close" _Close)
   (NIL "echo" _Echo)
   (NIL "prin" _Prin)
   (NIL "prinl" _Prinl)
   (NIL "space" _Space)
   (NIL "print" _Print)
   (NIL "printsp" _Printsp)
   (NIL "println" _Println)
   (NIL "flush" _Flush)
   (NIL "rewind" _Rewind)
   (NIL "ext" _Ext)
   (NIL "plio" _Plio)
   (NIL "rd" _Rd)
   (NIL "pr" _Pr)
   (NIL "wr" _Wr)
   (NIL "any" _Any)
   (NIL "sym" _Sym)
   (NIL "str" _Str)
   (NIL "load" _Load)
   # Database
   (NIL "ext?" _ExtQ)
   (NIL "rollback" _Rollback)
   (NIL "extern" _Extern)
   (NIL "pool" _Pool)
   (NIL "pool2" _Pool2)
   (NIL "journal" _Journal)
   (NIL "id" _Id)
   (NIL "blk" _Blk)
   (NIL "seq" _Seq)
   (NIL "lieu" _Lieu)
   (NIL "lock" _Lock)
   (NIL "touch" _Touch)
   (NIL "commit" _Commit)
   (NIL "mark" _Mark)
   (NIL "free" _Free)
   (NIL "dbck" _Dbck)
   # Mapping
   (NIL "apply" _Apply)
   (NIL "pass" _Pass)
   (NIL "fun" _Fun)
   (NIL "maps" _Maps)
   (NIL "map" _Map)
   (NIL "mapc" _Mapc)
   (NIL "maplist" _Maplist)
   (NIL "mapcar" _Mapcar)
   (NIL "mapcon" _Mapcon)
   (NIL "mapcan" _Mapcan)
   (NIL "filter" _Filter)
   (NIL "extract" _Extract)
   (NIL "seek" _Seek)
   (NIL "find" _Find)
   (NIL "pick" _Pick)
   (NIL "fully" _Fully)
   (NIL "cnt" _Cnt)
   (NIL "sum" _Sum)
   (NIL "maxi" _Maxi)
   (NIL "mini" _Mini)
   (NIL "fish" _Fish)
   (NIL "by" _By)
   # Control flow
   (NIL "as" _As)
   (NIL "lit" _Lit)
   (NIL "eval" _Eval)
   (NIL "run" _Run)
   (NIL "def" _Def)
   (NIL "de" _De)
   (NIL "dm" _Dm)
   (NIL "box" _Box)
   (NIL "new" _New)
   (NIL "type" _Type)
   (NIL "isa" _Isa)
   (NIL "method" _Method)
   (NIL "send" _Send)
   (NIL "try" _Try)
   (NIL "super" _Super)
   (NIL "extra" _Extra)
   (NIL "and" _And)
   (NIL "or" _Or)
   (NIL "nand" _Nand)
   (NIL "nor" _Nor)
   (NIL "xor" _Xor)
   (NIL "bool" _Bool)
   (NIL "not" _Not)
   (NIL "nil" _Nil)
   (NIL "t" _T)
   (NIL "prog" _Prog)
   (NIL "prog1" _Prog1)
   (NIL "prog2" _Prog2)
   (NIL "if" _If)
   (NIL "ifn" _Ifn)
   (NIL "if2" _If2)
   (NIL "when" _When)
   (NIL "unless" _Unless)
   (NIL "cond" _Cond)
   (NIL "nond" _Nond)
   (NIL "case" _Case)
   (NIL "casq" _Casq)
   (NIL "state" _State)
   (NIL "while" _While)
   (NIL "until" _Until)
   (NIL "at" _At)
   (NIL "do" _Do)
   (NIL "loop" _Loop)
   (NIL "for" _For)
   (NIL "with" _With)
   (NIL "bind" _Bind)
   (NIL "job" _Job)
   (NIL "let" _Let)
   (NIL "let?" _LetQ)
   (NIL "use" _Use)
   (NIL "buf" _Buf)
   (NIL "catch" _Catch)
   (NIL "throw" _Throw)
   (NIL "finally" _Finally)
   (NIL "co" _Co)
   (NIL "yield" _Yield)
   (NIL "!" _Break)
   (NIL "e" _E)
   (NIL "$" _Trace)
   (NIL "exec" _Exec)
   (NIL "call" _Call)
   (NIL "ipid" _Ipid)
   (NIL "opid" _Opid)
   (NIL "kill" _Kill)
   (NIL "fork" _Fork)
   (NIL "detach" _Detach)
   (NIL "bye" _Bye)
   # List processing
   (NIL "car" _Car)
   (NIL "cdr" _Cdr)
   (NIL "caar" _Caar)
   (NIL "cadr" _Cadr)
   (NIL "cdar" _Cdar)
   (NIL "cddr" _Cddr)
   (NIL "caaar" _Caaar)
   (NIL "caadr" _Caadr)
   (NIL "cadar" _Cadar)
   (NIL "caddr" _Caddr)
   (NIL "cdaar" _Cdaar)
   (NIL "cdadr" _Cdadr)
   (NIL "cddar" _Cddar)
   (NIL "cdddr" _Cdddr)
   (NIL "caaaar" _Caaaar)
   (NIL "caaadr" _Caaadr)
   (NIL "caadar" _Caadar)
   (NIL "caaddr" _Caaddr)
   (NIL "cadaar" _Cadaar)
   (NIL "cadadr" _Cadadr)
   (NIL "caddar" _Caddar)
   (NIL "cadddr" _Cadddr)
   (NIL "cdaaar" _Cdaaar)
   (NIL "cdaadr" _Cdaadr)
   (NIL "cdadar" _Cdadar)
   (NIL "cdaddr" _Cdaddr)
   (NIL "cddaar" _Cddaar)
   (NIL "cddadr" _Cddadr)
   (NIL "cdddar" _Cdddar)
   (NIL "cddddr" _Cddddr)
   (NIL "nth" _Nth)
   (NIL "con" _Con)
   (NIL "cons" _Cons)
   (NIL "conc" _Conc)
   (NIL "circ" _Circ)
   (NIL "rot" _Rot)
   (NIL "list" _List)
   (NIL "need" _Need)
   (NIL "range" _Range)
   (NIL "full" _Full)
   (NIL "make" _Make)
   (NIL "made" _Made)
   (NIL "chain" _Chain)
   (NIL "link" _Link)
   (NIL "yoke" _Yoke)
   (NIL "copy" _Copy)
   (NIL "mix" _Mix)
   (NIL "append" _Append)
   (NIL "delete" _Delete)
   (NIL "delq" _Delq)
   (NIL "replace" _Replace)
   (NIL "insert" _Insert)
   (NIL "remove" _Remove)
   (NIL "place" _Place)
   (NIL "strip" _Strip)
   (NIL "split" _Split)
   (NIL "reverse" _Reverse)
   (NIL "flip" _Flip)
   (NIL "trim" _Trim)
   (NIL "clip" _Clip)
   (NIL "head" _Head)
   (NIL "tail" _Tail)
   (NIL "stem" _Stem)
   (NIL "fin" _Fin)
   (NIL "last" _Last)
   (NIL "==" _Eq)
   (NIL "n==" _Neq)
   (NIL "=" _Equal)
   (NIL "<>" _Nequal)
   (NIL "=0" _Eq0)
   (NIL "=1" _Eq1)
   (NIL "=T" _EqT)
   (NIL "n0" _Neq0)
   (NIL "nT" _NeqT)
   (NIL "<" _Lt)
   (NIL "<=" _Le)
   (NIL ">" _Gt)
   (NIL ">=" _Ge)
   (NIL "max" _Max)
   (NIL "min" _Min)
   (NIL "atom" _Atom)
   (NIL "pair" _Pair)
   (NIL "circ?" _CircQ)
   (NIL "lst?" _LstQ)
   (NIL "num?" _NumQ)
   (NIL "sym?" _SymQ)
   (NIL "flg?" _FlgQ)
   (NIL "member" _Member)
   (NIL "memq" _Memq)
   (NIL "mmeq" _Mmeq)
   (NIL "sect" _Sect)
   (NIL "diff" _Diff)
   (NIL "index" _Index)
   (NIL "offset" _Offset)
   (NIL "prior" _Prior)
   (NIL "length" _Length)
   (NIL "size" _Size)
   (NIL "bytes" _Bytes)
   (NIL "assoc" _Assoc)
   (NIL "rassoc" _Rassoc)
   (NIL "asoq" _Asoq)
   (NIL "rasoq" _Rasoq)
   (NIL "rank" _Rank)
   (NIL "match" _Match)
   (NIL "fill" _Fill)
   (NIL "prove" _Prove)
   (NIL "->" _Arrow)
   (NIL "unify" _Unify)
   (NIL "group" _Group)
   (NIL "sort" _Sort)
   # System functions
   (NIL "tty" _Tty)
   (NIL "prompt" _Prompt)
   (NIL "raw" _Raw)
   (NIL "alarm" _Alarm)
   (NIL "sigio" _Sigio)
   (NIL "kids" _Kids)
   (NIL "protect" _Protect)
   (NIL "heap" _Heap)
   (NIL "stack" _Stack)
   (NIL "byte" _Byte)
   (NIL "env" _Env)
   (NIL "date" _Date)
   (NIL "time" _Time)
   (NIL "usec" _Usec)
   (NIL "quit" _Quit)
   (NIL "sys" _Sys)
   (NIL "pwd" _Pwd)
   (NIL "cd" _Cd)
   (NIL "ctty" _Ctty)
   (NIL "cmd" _Cmd)
   (NIL "dir" _Dir)
   (NIL "info" _Info)
   (NIL "file" _File)
   (NIL "argv" _Argv)
   (NIL "opt" _Opt)
   (NIL "errno" _Errno)
   (NIL "%@" _Nat)
   (NIL "native" _Native)
   (NIL "struct" _Struct)
   (NIL "lisp" _Lisp)
   (NIL "args" _Args)
   (NIL "next" _Next)
   (NIL "arg" _Arg)
   (NIL "rest" _Rest)
   (NIL "adr" _Adr)
   (NIL "trail" _Trail)
   (NIL "up" _Up)
   (NIL "history" _History)
   ($LastSym "version" _Version) )

# GC relevant data
(local) (gcData cbFuns)

(table gcData
   ($Intern $Pico1)     # Current namespaces of internal symbols
   ($Transient $Nil)    # Short transient names
   (NIL $Nil)           # Long transient names
   ($Alarm $Nil)        # Alarm handler
   ($Sigio $Nil)        # Sigio handler
   ($Lisp $Nil)         # Lisp callbacks: tag+fun
   (NIL $Nil)
   (NIL $Nil)           # 2
   (NIL $Nil)
   (NIL $Nil)           # 3
   (NIL $Nil)
   (NIL $Nil)           # 4
   (NIL $Nil)
   (NIL $Nil)           # 5
   (NIL $Nil)
   (NIL $Nil)           # 6
   (NIL $Nil)
   (NIL $Nil)           # 7
   (NIL $Nil)
   (NIL $Nil)           # 8
   (NIL $Nil)
   (NIL $Nil)           # 9
   (NIL $Nil)
   (NIL $Nil)           # 10
   (NIL $Nil)
   (NIL $Nil)           # 11
   (NIL $Nil)
   (NIL $Nil)           # 12
   (NIL $Nil)
   (NIL $Nil)           # 13
   (NIL $Nil)
   (NIL $Nil)           # 14
   (NIL $Nil)
   (NIL $Nil)           # 15
   (NIL $Nil)
   (NIL $Nil)           # 16
   (NIL $Nil)
   (NIL $Nil)           # 17
   (NIL $Nil)
   (NIL $Nil)           # 18
   (NIL $Nil)
   (NIL $Nil)           # 19
   (NIL $Nil)
   (NIL $Nil)           # 20
   (NIL $Nil)
   (NIL $Nil)           # 21
   (NIL $Nil)
   (NIL $Nil)           # 22
   (NIL $Nil)
   (NIL $Nil)           # 23
   (NIL $Nil)
   (NIL $Nil)           # 24
   ($LispEnd $Nil) )

(table cbFuns
   ($Cb (i64 i64 i64 i64 i64 i64) _Cb1)
   (NIL (i64 i64 i64 i64 i64 i64) _Cb2)
   (NIL (i64 i64 i64 i64 i64 i64) _Cb3)
   (NIL (i64 i64 i64 i64 i64 i64) _Cb4)
   (NIL (i64 i64 i64 i64 i64 i64) _Cb5)
   (NIL (i64 i64 i64 i64 i64 i64) _Cb6)
   (NIL (i64 i64 i64 i64 i64 i64) _Cb7)
   (NIL (i64 i64 i64 i64 i64 i64) _Cb8)
   (NIL (i64 i64 i64 i64 i64 i64) _Cb9)
   (NIL (i64 i64 i64 i64 i64 i64) _Cb10)
   (NIL (i64 i64 i64 i64 i64 i64) _Cb11)
   (NIL (i64 i64 i64 i64 i64 i64) _Cb12)
   (NIL (i64 i64 i64 i64 i64 i64) _Cb13)
   (NIL (i64 i64 i64 i64 i64 i64) _Cb14)
   (NIL (i64 i64 i64 i64 i64 i64) _Cb15)
   (NIL (i64 i64 i64 i64 i64 i64) _Cb16)
   (NIL (i64 i64 i64 i64 i64 i64) _Cb17)
   (NIL (i64 i64 i64 i64 i64 i64) _Cb18)
   (NIL (i64 i64 i64 i64 i64 i64) _Cb19)
   (NIL (i64 i64 i64 i64 i64 i64) _Cb20)
   (NIL (i64 i64 i64 i64 i64 i64) _Cb21)
   (NIL (i64 i64 i64 i64 i64 i64) _Cb22)
   (NIL (i64 i64 i64 i64 i64 i64) _Cb23)
   (NIL (i64 i64 i64 i64 i64 i64) _Cb24) )

# Environment
(local) env

(table env
   ($Link 0)                     # Link register
   ($Bind 0)                     # Bind frames
   ($Break 0)                    # Breakpoint
   ($Catch i8* null)             # Catch frames
   ($InFrames i8* null)          # Input frames
   ($OutFrames i8* null)         # Output frames
   ($ErrFrames i8* null)         # Error frames
   ($CtlFrames i8* null)         # Control frames
   ($InFile i8* null)            # Input file
   ($OutFile i8* null)           # Output file
   ($Put (void i8) null)         # Character output function
   ($Get (i32) null)             # Character input function
   ($Parser i64* null)           # String parser
   ($Next $Nil)                  # Next vararg
   ($Typ 0)                      # Method type
   ($Key 0)                      # Method key
   ($Make 0)                     # 'make' environment
   ($Yoke 0)
   ($Chr i32 0)                  # Single-char look ahead
   ($Protect i32 0)              # Signal protection
   ($Trace i32 0)                # Trace level
   ($EnvPad i32 0) )

# Temporary cell
(array $Cell any
   $Nil
   $Nil )

# Version number
(table $Version
   ($Y (short (pico~car *Version)))
   ($M (short (pico~cadr *Version)))
   ($D (short (pico~caddr *Version))) )

# 'T' in PLIO format
(array $TBuf i8
   (+ INTERN 4)
   (char "T") )

# Bytes
(array $Month i8
   31 31 28 31 30 31 30 31 31 30 31 30 31 )

# Booleans
(var $Repl i1 NO)                # REPL flag
(var $PRepl i1 NO)               # Parent REPL
(var $Jam i1 NO)                 # Error jam
(var $InBye i1 NO)               # Exit status
(var $Sync i1 NO)                # Family IPC synchronization

# Strings
(str $Empty "")
(str $Delim " \t\n\r\"'(),[]`{}~")
