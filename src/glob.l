# 12may20 Software Lab. Alexander Burger

(symbols '(llvm))

(var $AV0 i8* null)                    # Command name
(var $AV i8** null)                    # Command line argument vector
(var $Home i8* null)                   # Home directory
(var $HomeLen i64 0)                   # Home directory
(var $Heaps 0)                         # Heap list
(var $Avail 0)                         # Avail list
(var $Extern 0)                        # External symbol tree
(var $ExtCnt i64 1)                    # External symbol count
(var $ExtSkip i64 0)                   # External tree skip
(var $Coroutines i8* null)             # Coroutines
(var $StkSize i32 STACK)               # Coroutine stack segment size
(var $StkLimit i8* null)               # Stack limit: StackN-Size+4096
(var $Ret 0)                           # Secondary return value
(var $TtyPid i32 0)                    # Terminal process ID
(var $InFDs i32 0)                     # Number of input files
(var $InFiles i8** null)               # Input files
(var $OutFDs i32 0)                    # Number of ourput files
(var $OutFiles i8** null)              # Output files
(var $PutBin (void i8) null)           # Binary output function
(var $GetBin (i32) null)               # Binary input function
(var $SeedL i64 0)                     # Random seed low
(var $SeedH i64 0)                     # Random seed high
(var $TickU i64 0)                     # Ticks in user time
(var $TickS i64 0)                     # Ticks in system time
(var $Slot i64 0)                      # Child index
(var $Spkr i32 0)                      # RPC loadspeaker
(var $Mic i32 0)                       # RPC microphone
(array $SpMiPipe i32 0 0)              # Speaker/microphone pipe
(var $Hear i32 0)                      # RPC listener
(var $Tell i32 0)                      # RPC broadcaster
(var $TellBuf i8* null)                # RPC buffer
(var $Talking i32 0)                   # Active child
(var $Children i64 0)                  # Number of children
(var $Child i8* null)                  # Child array
(var $Ptr i8* null)                    # Byte buffer pointer
(var $End i8* null)                    # Buffer end pointer
(var $ExtN i32 0)                      # External symbol offset
(var $Extn i32 0)
(var $Break i1 NO)                     # Breakpoint
(var $GcCount i64 CELLS)               # Collector count

# Database
(var $DbFiles i8* null)                # DB files
(var $DbFile i8* null)                 # DB file
(var $DBs i32 0)                       # Number of DB files
(var $MaxBlkSize i32 0)                # Maximum block size
(var $DbBlock i8* null)                # Block buffer
(var $IniBlk i8* null)                 # Empty initial block
(var $BlkIndex i64 0)                  # Block index
(var $BlkLink i64 0)                   # Next block
(var $DbJnl i8* null)                  # Journal file
(var $DbLog i8* null)                  # Transaction log file

# Console line
(array $Line i64
   0    # cnt
   0 )  # name

# Signals
(array $Signal i32  # Sync src/lib.c 'gErrno'
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
   0 )  # SIGIO

# Symbol Table
(symTab
   ($Nil "NIL" $Nil)    # NIL symbol
   (NIL $Nil 0)         # CDR of NIL as empty list
   ($Db1 0 $Nil)        # Database root symbol
   ($Pico $Nil $Nil 0)  # Initial namespace
   # Protected symbols
   ($pico "pico" $Pico)
   ($Pico1 $pico $Nil 0)
   ($DB "*DB" $Db1)
   ($Meth "meth" _meth)
   ($Quote "quote" _quote)
   ## Sync src/pico.h 'T' (9*2+1)
   ($T "T" $T)
   ($I "I" $Nil)
   ($N "N" $Nil)
   ($S "S" $Nil)
   ($C "C" $Nil)
   ($B "B" $Nil)
   ($Solo "*Solo" ZERO)
   ($PPid "*PPid" $Nil)
   ($Pid "*Pid" 0)
   ($At "@" $Nil)
   ($At2 "@@" $Nil)
   ($At3 "@@@" $Nil)
   ($This "This" $Nil)
   ($Prompt "*Prompt" $Nil)
   ($Zap "*Zap" $Nil)
   ($Ext "*Ext" $Nil)
   ($Scl "*Scl" ZERO)
   ($Class "*Class" $Nil)
   ($Run "*Run" $Nil)
   ($Hup "*Hup" $Nil)
   ($Sig1 "*Sig1" $Nil)
   ($Sig2 "*Sig2" $Nil)
   ($TStp1 "*TStp1" $Nil)
   ($TStp2 "*TStp2" $Nil)
   ($Up "\^" $Nil)
   ($Err "*Err" $Nil)
   ($Msg "*Msg" $Nil)
   ($Uni "*Uni" $Nil)
   ($Led "*Led" $Nil)
   ($Adr "*Adr" $Nil)
   ($Fork "*Fork" $Nil)
   ($Bye "*Bye" $Nil)
   ($Dbg "*Dbg" $Nil)
   # Garbage collection
   (NIL "gc" _gc)
   # Arithmetics
   (NIL "format" _format)
   (NIL "+" _add)
   (NIL "-" _sub)
   (NIL "inc" _inc)
   (NIL "dec" _dec)
   (NIL "*" _mul)
   (NIL "*/" _mulDiv)
   (NIL "/" _div)
   (NIL "%" _rem)
   (NIL ">>" _shr)
   (NIL "lt0" _lt0)
   (NIL "le0" _le0)
   (NIL "ge0" _ge0)
   (NIL "gt0" _gt0)
   (NIL "abs" _abs)
   (NIL "bit?"_bitQ)
   (NIL "&" _bitAnd)
   (NIL "|" _bitOr)
   (NIL "x|" _bitXor)
   (NIL "sqrt" _sqrt)
   (NIL "seed" _seed)
   (NIL "hash" _hash)
   (NIL "rand" _rand)
   # Symbol functions
   (NIL "name" _name)
   (NIL "nsp" _nsp)
   (NIL "sp?" _spQ)
   (NIL "pat?" _patQ)
   (NIL "fun?" _funQ)
   (NIL "getd" _getd)
   (NIL "all" _all)
   (NIL "symbols" _symbols)
   (NIL "intern" _intern)
   (NIL "box?" _boxQ)
   (NIL "str?" _strQ)
   (NIL "zap" _zap)
   (NIL "chop" _chop)
   (NIL "pack" _pack)
   (NIL "glue" _glue)
   (NIL "text" _text)
   (NIL "pre?" _preQ)
   (NIL "sub?" _subQ)
   (NIL "val" _val)
   (NIL "set" _set)
   (NIL "setq" _setq)
   (NIL "swap" _swap)
   (NIL "xchg" _xchg)
   (NIL "on" _on)
   (NIL "off" _off)
   (NIL "onOff" _onOff)
   (NIL "zero" _zero)
   (NIL "one" _one)
   (NIL "default" _default)
   (NIL "push" _push)
   (NIL "push1" _push1)
   (NIL "push1q" _push1q)
   (NIL "pop" _pop)
   (NIL "++" _popq)
   (NIL "cut" _cut)
   (NIL "del" _del)
   (NIL "queue" _queue)
   (NIL "fifo" _fifo)
   (NIL "idx" _idx)
   (NIL "lup" _lup)
   (NIL "put" _put)
   (NIL "get" _get)
   (NIL "prop" _prop)
   (NIL ";" _semicol)
   (NIL "=:" _setCol)
   (NIL ":" _col)
   (NIL "::" _propCol)
   (NIL "putl" _putl)
   (NIL "getl" _getl)
   (NIL "wipe" _wipe)
   (NIL "meta" _meta)
   #!
   (NIL "low?" _lowQ)
   (NIL "upp?" _uppQ)
   (NIL "lowc" _lowc)
   (NIL "uppc" _uppc)
   (NIL "fold" _fold)
   # Input/Output
   (NIL "path" _path)
   (NIL "wait" _wait)
   (NIL "read" _read)
   (NIL "key" _key)
   (NIL "char" _char)
   (NIL "in" _in)
   (NIL "out" _out)
   (NIL "pipe" _pipe)
   (NIL "prin" _prin)
   (NIL "prinl" _prinl)
   (NIL "space" _space)
   (NIL "print" _print)
   (NIL "printsp" _printsp)
   (NIL "println" _println)
   (NIL "flush" _flush)
   (NIL "rewind" _rewind)
   (NIL "ext" _ext)
   (NIL "rd" _rd)
   (NIL "pr" _pr)
   (NIL "wr" _wr)
   (NIL "load" _load)
   # Database
   (NIL "ext?" _extQ)
   (NIL "rollback" _rollback)
   (NIL "extern" _extern)
   (NIL "pool" _pool)
   (NIL "touch" _touch)
   # Mapping
   (NIL "apply" _apply)
   (NIL "pass" _pass)
   (NIL "map" _map)
   (NIL "mapc" _mapc)
   (NIL "maplist" _maplist)
   (NIL "mapcar" _mapcar)
   (NIL "mapcon" _mapcon)
   (NIL "mapcan" _mapcan)
   (NIL "filter" _filter)
   (NIL "extract" _extract)
   (NIL "sum" _sum)
   (NIL "fish" _fish)
   # Control flow
   (NIL "as" _as)
   (NIL "lit" _lit)
   (NIL "eval" _eval)
   (NIL "run" _run)
   (NIL "def" _def)
   (NIL "de" _de)
   (NIL "dm" _dm)
   (NIL "box" _box)
   (NIL "and" _and)
   (NIL "or" _or)
   (NIL "not" _not)
   (NIL "nil" _nil)
   (NIL "t" _t)
   (NIL "prog" _prog)
   (NIL "prog1" _prog1)
   (NIL "prog2" _prog2)
   (NIL "if" _if)
   (NIL "ifn" _ifn)
   (NIL "if2" _if2)
   (NIL "when" _when)
   (NIL "unless" _unless)
   (NIL "cond" _cond)
   (NIL "nond" _nond)
   (NIL "case" _case)
   (NIL "casq" _casq)
   (NIL "state" _state)
   (NIL "while" _while)
   (NIL "until" _until)
   (NIL "at" _at)
   (NIL "do" _do)
   (NIL "loop" _loop)
   (NIL "for" _for)
   (NIL "with" _with)
   (NIL "bind" _bind)
   (NIL "job" _job)
   (NIL "let" _let)
   (NIL "let?" _letQ)
   (NIL "use" _use)
   (NIL "catch" _catch)
   (NIL "throw" _throw)
   (NIL "finally" _finally)
   (NIL "co" _co)
   (NIL "yield" _yield)
   (NIL "bye" _bye)
   # List processing
   (NIL "car" _car)
   (NIL "cdr" _cdr)
   (NIL "caar" _caar)
   (NIL "cadr" _cadr)
   (NIL "cdar" _cdar)
   (NIL "cddr" _cddr)
   (NIL "caaar" _caaar)
   (NIL "caadr" _caadr)
   (NIL "cadar" _cadar)
   (NIL "caddr" _caddr)
   (NIL "cdaar" _cdaar)
   (NIL "cdadr" _cdadr)
   (NIL "cddar" _cddar)
   (NIL "cdddr" _cdddr)
   (NIL "caaaar" _caaaar)
   (NIL "caaadr" _caaadr)
   (NIL "caadar" _caadar)
   (NIL "caaddr" _caaddr)
   (NIL "cadaar" _cadaar)
   (NIL "cadadr" _cadadr)
   (NIL "caddar" _caddar)
   (NIL "cadddr" _cadddr)
   (NIL "cdaaar" _cdaaar)
   (NIL "cdaadr" _cdaadr)
   (NIL "cdadar" _cdadar)
   (NIL "cdaddr" _cdaddr)
   (NIL "cddaar" _cddaar)
   (NIL "cddadr" _cddadr)
   (NIL "cdddar" _cdddar)
   (NIL "cddddr" _cddddr)
   (NIL "nth" _nth)
   (NIL "con" _con)
   (NIL "cons" _cons)
   (NIL "list" _list)
   (NIL "need" _need)
   (NIL "range" _range)
   (NIL "full" _full)
   (NIL "make" _make)
   (NIL "made" _made)
   (NIL "chain" _chain)
   (NIL "link" _link)
   (NIL "yoke" _yoke)
   (NIL "replace" _replace)
   (NIL "fin" _fin)
   (NIL "last" _last)
   (NIL "==" _eq)
   (NIL "n==" _neq)
   (NIL "=" _equal)
   (NIL "<>" _nequal)
   (NIL "=0" _eq0)
   (NIL "=1" _eq1)
   (NIL "=T" _eqT)
   (NIL "n0" _neq0)
   (NIL "nT" _neqT)
   (NIL ">" _gt)
   (NIL ">=" _ge)
   (NIL "atom" _atom)
   (NIL "pair" _pair)
   (NIL "circ?" _circQ)
   (NIL "lst?" _lstQ)
   (NIL "num?" _numQ)
   (NIL "sym?" _symQ)
   (NIL "flg?" _flgQ)
   (NIL "member" _member)
   (NIL "memq" _memq)
   (NIL "mmeq" _mmeq)
   (NIL "sect" _sect)
   (NIL "diff" _diff)
   (NIL "index" _index)
   (NIL "offset" _offset)
   (NIL "prior" _prior)
   (NIL "length" _length)
   (NIL "size" _size)
   (NIL "bytes" _bytes)
   (NIL "assoc" _assoc)
   (NIL "rassoc" _rassoc)
   (NIL "asoq" _asoq)
   (NIL "fill" _fill)
   # Networking
   (NIL "udp" _udp)
   # System functions
   (NIL "raw" _raw)
   (NIL "sys" _sys)
   (NIL "pwd" _pwd)
   (NIL "cd" _cd)
   (NIL "argv" _argv)
   (NIL "native" _native)
   (NIL "args" _args)
   (NIL "next" _next)
   (NIL "rest" _rest)
   ($LastSym "version" _version) )

# GC relevant data
(local) gcData

(table gcData
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

# Environment
(local) env

(table env
   ($Link 0)                     # Link register
   ($Bind 0)                     # Bind frames
   ($Catch i8* null)             # Catch frames
   ($CoFrames i8* null)          # Coroutine frames
   ($InFrames i8* null)          # Input frames
   ($OutFrames i8* null)         # Output frames
   ($ErrFrames i8* null)         # Error frames
   ($CtlFrames i8* null)         # Control frames
   ($Chr i32 0)                  # Single-char look ahead
   ($Put (void i8) _putStdout)   # Character output function
   ($Get (i32) _getStdin)        # Character input function
   ($InFile i8* null)            # Input file
   ($OutFile i8* null)           # Output file
   ($Parser i64* null)           # String parser
   ($Intern $Pico1)              # Current namespaces of internal symbols
   ($Next $Nil)                  # Next vararg
   ($Cls 0)                      # Method class
   ($Key 0)                      # Method key
   ($Make 0)                     # 'make' environment
   ($Yoke 0)
   ($Task $Nil)                  # Task list
   ($Protect 0)                  # Signal protection
   ($Trace 0) )                  # Trace level

# Temporary cell
(array $Cell any
   $Nil
   $Nil )

# Version number
(table $Version
   ($Y (short (pico~car *Version)))
   ($M (short (pico~cadr *Version)))
   ($D (short (pico~caddr *Version))) )

# Bytes
(array $Month i8
   31 31 28 31 30 31 30 31 31 30 31 30 31 )

# Booleans
(var $Repl i1 0)                 # REPL flag
(var $PRepl i1 0)                # Parent REPL
(var $Jam i1 0)                  # Error jam
(var $InBye i1 0)                # Exit status
(var $Sync i1 0)                 # Family IPC synchronization

# Strings
(str $Delim " \t\n\r\"'(),[]`~{}")
