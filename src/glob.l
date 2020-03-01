# 27feb20 Software Lab. Alexander Burger

(symbols '(llvm))

(var $AV0 i8* null)                    # Command name
(var $AV i8** null)                    # Command line argument vector
(var $Home i8* null)                   # Home directory
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
(var $PutBin (void any) null)          # Binary output function
(var $GetBin (any) null)               # Binary input function
(var $SeedL i64 0)                     # Random seed low
(var $SeedH i64 0)                     # Random seed high
(var $TickU i64 0)                     # Ticks in user time
(var $TickS i64 0)                     # Ticks in system time
(var $Slot i32 0)                      # Child index
(var $Spkr i32 0)                      # RPC loadspeaker
(var $Mic i32 0)                       # RPC microphone
(var $SpMiPipe i64 0)                  # Speaker/microphone pipe
(var $Hear i32 0)                      # RPC listener
(var $Tell i32 0)                      # RPC broadcaster
(var $TellBuf i8* null)                # RPC buffer
(var $Talking i32 0)                   # Active child
(var $Children i64 0)                  # Number of children
(var $Child i8* null)                  # Child array
(var $ExtN i32 0)                      # External symbol offset
(var $Break i1 NO)                     # Breakpoint
(var $GcCount i64 CELLS)               # Collector count

# Database
(var $DbFiles i8* null)                # DB files
(var $DbFile i8* null)                 # DB file
(var $DBs i32 0)                       # Number of DB files
(var $MaxBlkSize i32 0)                # Maximum block size
(var $DbBlock i8* null)                # Block buffer
(var $IniBlk i8* null)                 # Empty initial block
(var $BlkPtr i8* null)                 # Block pointer
(var $BlkIndex i64 0)                  # Block index
(var $BlkLink i64 0)                   # Next block
(var $DbJnl i8* null)                  # Journal file
(var $DbLog i8* null)                  # Transaction log file

# Console line
(array $Line i64
   0    # cnt
   0 )  # name

# Signals
(array $Signal i32  # Sync src/lib.c 'xErrno'
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
   (NIL ">>" _shift)
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
   # Database
   (NIL "pool" _pool)
   # Symbol functions
   (NIL "pre?" _preQ)
   (NIL "sub?" _subQ)
   (NIL "low?" _lowQ)
   (NIL "upp?" _uppQ)
   (NIL "lowc" _lowc)
   (NIL "uppc" _uppc)
   (NIL "fold" _fold)
   # Input/Output
   (NIL "read" _read)
   (NIL "in" _in)
   (NIL "out" _out)
   (NIL "prin" _prin)
   (NIL "prinl" _prinl)
   (NIL "space" _space)
   (NIL "print" _print)
   (NIL "printsp" _printsp)
   (NIL "println" _println)
   (NIL "flush" _flush)
   (NIL "load" _load)
   # Mapping
   (NIL "apply" _apply)
   (NIL "map" _map)
   (NIL "mapcar" _mapcar)
   # Control flow
   (NIL "de" _de)
   (NIL "dm" _dm)
   (NIL "and" _and)
   (NIL "if" _if)
   (NIL "catch" _catch)
   (NIL "throw" _throw)
   (NIL "finally" _finally)
   (NIL "co" _co)
   (NIL "yield" _yield)
   (NIL "bye" _bye)
   # List processing
   (NIL "car" _car)
   (NIL "cdr" _cdr)
   (NIL "cons" _cons)
   (NIL "list" _list)
   (NIL "=" _equal)
   (NIL ">=" _ge)
   # Networking
   (NIL "udp" _udp)
   # System functions
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
   ($Put (void i32) _putStdout)  # Character output function
   ($Get (i32) _getStdin)        # Character input function
   ($InFile i8* null)            # Input file
   ($OutFile i8* null)           # Output file
   ($Intern $Pico1)              # Current namespaces of internal symbols
   ($Next $Nil)                  # Next vararg
   ($Cls 0)                      # Method class
   ($Key 0)                      # Method key
   ($Make 0)                     # 'make' environment
   ($Yoke 0)
   ($Task $Nil)                  # Task list
   ($Protect 0)                  # Signal protection
   ($Trace 0) )                  # Trace level

# Version number
(table $Version
   ($Y (short (pico~car *Version)))
   ($M (short (pico~cadr *Version)))
   ($D (short (pico~caddr *Version))) )

# Booleans
(var $Repl i1 0)                 # REPL flag
(var $PRepl i1 0)                # Parent REPL
(var $Jam i1 0)                  # Error jam

# Bytes

# Strings
(str $Delim " \t\n\r\"'(),[]`~{}")
