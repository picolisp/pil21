# 24may22 Software Lab. Alexander Burger

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
(var $Current i8* null)                # Current coroutine
(var $Coroutines i8* null)             # Coroutines
(var $StkBrk i8* null)                 # Stack break
(var $StkLimit i8* null)               # Stack limit: StackN-Size+4096
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
(var $InFile i8* null)                 # Input file
(var $OutFile i8* null)                # Output file
(var $Chr i32 0)                       # Single-char look ahead
(var $IoCnt i32 0)                     # 'output' count
(var $IoIx i64 0)                      # 'output' index
(var $IoChar i64 0)                    # 'input' and 'output' char
(var $Put (void i8) null)              # Character output function
(var $Get (i32) null)                  # Character input function
(var $PutBin (void i8) null)           # Binary output function
(var $GetBin (i32) null)               # Binary input function
(var $OutFDs i32 0)                    # Number of ourput files
(var $Nfds i32 0)                      # Number of poll entries
(var $Poll i64* null)                  # Poll entries
(var $SeedL i64 0)                     # Random seed low
(var $SeedH i64 0)                     # Random seed high
(var $USec i64 0)                      # Startup microseconds
(var $TickU i64 0)                     # Ticks in user time
(var $TickS i64 0)                     # Ticks in system time
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
   ($OS "*OS" 0)
   ($CPU "*CPU" 0)
   ($Pid "*Pid" 0)
   ($PPid "*PPid" $Nil)
   ($DB "*DB" 0)              # Database root constant
   ($Meth "meth" __meth)
   ($Quote "quote" _quote)
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
   ($rem "%" _rem)
   (NIL ">>" _shr)
   (NIL "rev" _rev)
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
   (NIL "====" _hide)
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
   (NIL "shift" _shift)
   (NIL "cut" _cut)
   (NIL "del" _del)
   (NIL "queue" _queue)
   (NIL "fifo" _fifo)
   (NIL "rid" _rid)
   (NIL "enum" _enum)
   (NIL "enum?" _enumQ)
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
   (NIL "low?" _lowQ)
   (NIL "upp?" _uppQ)
   (NIL "lowc" _lowc)
   (NIL "uppc" _uppc)
   (NIL "fold" _fold)
   # Input/Output
   (NIL "path" _path)
   (NIL "wait" _wait)
   (NIL "sync" _sync)
   (NIL "hear" _hear)
   (NIL "tell" _tell)
   (NIL "poll" _poll)
   (NIL "read" _read)
   (NIL "key" _key)
   (NIL "peek" _peek)
   (NIL "char" _char)
   (NIL "skip" _skip)
   (NIL "eol" _eol)
   (NIL "eof" _eof)
   (NIL "from" _from)
   (NIL "till" _till)
   (NIL "line" _line)
   (NIL "in" _in)
   (NIL "out" _out)
   (NIL "err" _err)
   (NIL "ctl" _ctl)
   (NIL "input" _input)
   (NIL "output" _output)
   (NIL "fd" _fd)
   (NIL "pipe" _pipe)
   (NIL "open" _open)
   (NIL "close" _close)
   (NIL "echo" _echo)
   (NIL "prin" _prin)
   (NIL "prinl" _prinl)
   (NIL "space" _space)
   (NIL "print" _print)
   (NIL "printsp" _printsp)
   (NIL "println" _println)
   (NIL "flush" _flush)
   (NIL "rewind" _rewind)
   (NIL "ext" _ext)
   (NIL "plio" _plio)
   (NIL "rd" _rd)
   (NIL "pr" _pr)
   (NIL "wr" _wr)
   (NIL "any" _any)
   (NIL "sym" _sym)
   (NIL "str" _str)
   (NIL "load" _load)
   # Database
   (NIL "ext?" _extQ)
   (NIL "rollback" _rollback)
   (NIL "extern" _extern)
   (NIL "pool" _pool)
   (NIL "pool2" _pool2)
   (NIL "journal" _journal)
   (NIL "id" _id)
   (NIL "blk" _blk)
   (NIL "seq" _seq)
   (NIL "lieu" _lieu)
   (NIL "lock" _lock)
   (NIL "touch" _touch)
   (NIL "commit" _commit)
   (NIL "mark" _mark)
   (NIL "free" _free)
   (NIL "dbck" _dbck)
   # Mapping
   (NIL "apply" _apply)
   (NIL "pass" _pass)
   (NIL "fun" _fun)
   (NIL "maps" _maps)
   (NIL "map" _map)
   (NIL "mapc" _mapc)
   (NIL "maplist" _maplist)
   (NIL "mapcar" _mapcar)
   (NIL "mapcon" _mapcon)
   (NIL "mapcan" _mapcan)
   (NIL "filter" _filter)
   (NIL "extract" _extract)
   (NIL "seek" _seek)
   (NIL "find" _find)
   (NIL "pick" _pick)
   (NIL "fully" _fully)
   (NIL "cnt" _cnt)
   (NIL "sum" _sum)
   (NIL "maxi" _maxi)
   (NIL "mini" _mini)
   (NIL "fish" _fish)
   (NIL "by" _by)
   # Control flow
   (NIL "as" _as)
   (NIL "lit" _lit)
   (NIL "eval" _eval)
   (NIL "run" _run)
   (NIL "def" _def)
   (NIL "de" _de)
   (NIL "dm" _dm)
   (NIL "box" _box)
   (NIL "new" _new)
   (NIL "type" _type)
   (NIL "isa" _isa)
   (NIL "method" _method)
   (NIL "send" _send)
   (NIL "try" _try)
   (NIL "super" _super)
   (NIL "extra" _extra)
   (NIL "and" _and)
   (NIL "or" _or)
   (NIL "nand" _nand)
   (NIL "nor" _nor)
   (NIL "xor" _xor)
   (NIL "bool" _bool)
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
   (NIL "buf" _buf)
   (NIL "catch" _catch)
   (NIL "throw" _throw)
   (NIL "finally" _finally)
   (NIL "co" _co)
   (NIL "yield" _yield)
   (NIL "!" _break)
   (NIL "e" _e)
   (NIL "$" _trace)
   (NIL "exec" _exec)
   (NIL "call" _call)
   (NIL "ipid" _ipid)
   (NIL "opid" _opid)
   (NIL "kill" _kill)
   (NIL "fork" _fork)
   (NIL "detach" _detach)
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
   (NIL "conc" _conc)
   (NIL "circ" _circ)
   (NIL "rot" _rot)
   (NIL "list" _list)
   (NIL "need" _need)
   (NIL "range" _range)
   (NIL "full" _full)
   (NIL "make" _make)
   (NIL "made" _made)
   (NIL "chain" _chain)
   (NIL "link" _link)
   (NIL "yoke" _yoke)
   (NIL "copy" _copy)
   (NIL "mix" _mix)
   (NIL "append" _append)
   (NIL "delete" _delete)
   (NIL "delq" _delq)
   (NIL "replace" _replace)
   (NIL "insert" _insert)
   (NIL "remove" _remove)
   (NIL "place" _place)
   (NIL "strip" _strip)
   (NIL "split" _split)
   (NIL "reverse" _reverse)
   (NIL "flip" _flip)
   (NIL "trim" _trim)
   (NIL "clip" _clip)
   (NIL "head" _head)
   (NIL "tail" _tail)
   (NIL "stem" _stem)
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
   (NIL "<" _lt)
   (NIL "<=" _le)
   (NIL ">" _gt)
   (NIL ">=" _ge)
   (NIL "max" _max)
   (NIL "min" _min)
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
   (NIL "rasoq" _rasoq)
   (NIL "rank" _rank)
   (NIL "match" _match)
   (NIL "fill" _fill)
   (NIL "prove" _prove)
   (NIL "->" _arrow)
   (NIL "unify" _unify)
   (NIL "group" _group)
   (NIL "sort" _sort)
   # System functions
   (NIL "tty" _tty)
   (NIL "raw" _raw)
   (NIL "alarm" _alarm)
   (NIL "sigio" _sigio)
   (NIL "kids" _kids)
   (NIL "protect" _protect)
   (NIL "heap" _heap)
   (NIL "stack" _stack)
   (NIL "byte" _byte)
   (NIL "env" _env)
   (NIL "date" _date)
   (NIL "time" _time)
   (NIL "usec" _usec)
   (NIL "quit" _quit)
   (NIL "sys" _sys)
   (NIL "pwd" _pwd)
   (NIL "cd" _cd)
   (NIL "ctty" _ctty)
   (NIL "cmd" _cmd)
   (NIL "dir" _dir)
   (NIL "info" _info)
   (NIL "file" _file)
   (NIL "argv" _argv)
   (NIL "opt" _opt)
   (NIL "errno" _errno)
   (NIL "%@" _nat)
   (NIL "native" _native)
   (NIL "struct" _struct)
   (NIL "lisp" _lisp)
   (NIL "args" _args)
   (NIL "next" _next)
   (NIL "arg" _arg)
   (NIL "rest" _rest)
   (NIL "adr" _adr)
   (NIL "trail" _trail)
   (NIL "up" _up)
   (NIL "history" _history)
   ($LastSym "version" _version) )

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
   ($Cb (i64 i64 i64 i64 i64 i64) _cb1)
   (NIL (i64 i64 i64 i64 i64 i64) _cb2)
   (NIL (i64 i64 i64 i64 i64 i64) _cb3)
   (NIL (i64 i64 i64 i64 i64 i64) _cb4)
   (NIL (i64 i64 i64 i64 i64 i64) _cb5)
   (NIL (i64 i64 i64 i64 i64 i64) _cb6)
   (NIL (i64 i64 i64 i64 i64 i64) _cb7)
   (NIL (i64 i64 i64 i64 i64 i64) _cb8)
   (NIL (i64 i64 i64 i64 i64 i64) _cb9)
   (NIL (i64 i64 i64 i64 i64 i64) _cb10)
   (NIL (i64 i64 i64 i64 i64 i64) _cb11)
   (NIL (i64 i64 i64 i64 i64 i64) _cb12)
   (NIL (i64 i64 i64 i64 i64 i64) _cb13)
   (NIL (i64 i64 i64 i64 i64 i64) _cb14)
   (NIL (i64 i64 i64 i64 i64 i64) _cb15)
   (NIL (i64 i64 i64 i64 i64 i64) _cb16)
   (NIL (i64 i64 i64 i64 i64 i64) _cb17)
   (NIL (i64 i64 i64 i64 i64 i64) _cb18)
   (NIL (i64 i64 i64 i64 i64 i64) _cb19)
   (NIL (i64 i64 i64 i64 i64 i64) _cb20)
   (NIL (i64 i64 i64 i64 i64 i64) _cb21)
   (NIL (i64 i64 i64 i64 i64 i64) _cb22)
   (NIL (i64 i64 i64 i64 i64 i64) _cb23)
   (NIL (i64 i64 i64 i64 i64 i64) _cb24) )

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
   ($Input i8* null)             # 'input' Get frames
   ($Output i8* null)            # 'output' Put frames
   ($Parser i64* null)           # String parser
   ($Next $Nil)                  # Next vararg
   ($Typ 0)                      # Method type
   ($Key 0)                      # Method key
   ($Make 0)                     # 'make' environment
   ($Yoke 0)
   ($Protect i32 0)              # Signal protection
   ($Trace i32 0) )              # Trace level

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
