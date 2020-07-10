# 10jul20 Software Lab. Alexander Burger

(symbols '(llvm))

(local) (inFile outFile dbFile ioFrame)

# I/O
(struct inFile
   (ix 8 i64)           # Buffer index
   (cnt 8 i64)          # Buffer byte count
   (fd 4 i32)           # File descriptor
   (next 4 i32)         # Saved next character
   (name 8 i8*)         # Current file name
   (line 4 i32)         # Current line number
   (src 4 i32)          # Source start line
   (buf BUFSIZ i8) )    # Buffer

(struct outFile
   (ix 8 i64)           # Buffer index
   (fd 4 i32)           # File descriptor
   (buf BUFSIZ i8)      # Buffer
   (tty 1 i1) )         # TTY flag

(struct dbFile
   (fd 4 i32)           # File descriptor
   (db 4 i32)           # File number
   (sh 4 i32)           # Block shift
   (siz 4 i32)          # Block size (64 << sh)
   (mark 8 i8*)         # Mark bit vector
   (mrks 8 i64)         # Mark vector size
   (flu 8 i64)          # Free list use count
   (lck 1 i1)           # Lock flag
   (drt 1 i1) )         # Dirty flag

(struct ioFrame
   (link 8 i8*)         # Frame link
   (fd 4 i32)           # File descriptor
   (pid 4 i32)          # Process ID
   (fun 8 i8*) )        # Function pointer

# Catch/throw
(local) caFrame

(struct caFrame
   (link 8 i8*)         # Frame link
   (tag 8 any)          # Catch tag
   (fin 8 any)          # 'finally' expression
   (env (env T) i8)     # Saved environment
   (rst 0 i8) )         # Restart jmp_buf (JmpBufSize)

# Coroutines
(local) (coroutine coFrame)

(struct coroutine
   (tag 8 any)          # Coroutine tag
   (next 8 i8*)         # Next coroutine
   (prg 8 any)          # Code body
   (lim 8 i8*)          # Stack limit
   (at 8 any)           # Saved [@]
   (env (env T) i8)     # Saved environment
   (rst 0 i8) )         # Restart jmp_buf (JmpBufSize)

(struct coFrame
   (link 8 i8*)         # Frame link
   (crt 8 i8*) )        # Coroutine

# Family IPC
(local) child

(struct child
   (buf 8 i8*)          # Buffer pointer
   (ofs 8 i64)          # Buffer offset
   (cnt 8 i64)          # Buffer byte count
   (pid 4 i32)          # Process ID
   (hear 4 i32)         # Hear pipe
   (tell 4 i32) )       # Tell pipe

# libc
(local) (malloc realloc free fork getenv setenv getpid setpgid execvp isatty
tcgetattr read write pread pwrite fread fwrite putc_unlocked fflush fileno pipe
memcmp strlen strcpy strdup strcmp strchr strrchr dlsym dlerror dup2 close
signal waitpid setjmp longjmp kill exit)

(de T i8* malloc (i64))
(de T i8* realloc (i8* i64))
(de T void free (i8*))
(de T i32 fork ())
(de T i8* getenv (i8*))
(de T i32 setenv (i8* i8* i32))
(de T i8* getcwd (i8* i64))
(de T i32 chdir (i8*))
(de T i32 getpid ())
(de T i32 alarm (i32))
(de T i32 setpgid (i32 i32))
(de T i32 execvp (i8* i8**))
(de T i32 isatty (i32))
(de T i32 tcgetattr (i32 i8*))
(de T i64 read (i32 i8* i64))
(de T i64 write (i32 i8* i64))
(de T i64 pread (i32 i8* i64 i64))
(de T i64 pwrite (i32 i8* i64 i64))
(de T i32 fread (i8* i32 i32 i8*))
(de T i32 fwrite (i8* i32 i32 i8*))
(de T i32 putc_unlocked (i32 i8*))
(de T i32 fflush (i8*))
(de T i32 fileno (i8*))
(de T i32 pipe (i32*))
(de T i32 memcmp (i8* i8* i64))
(de T i64 strlen (i8*))
(de T i8* strcpy (i8* i8*))
(de T i8* strdup (i8*))
(de T i32 strcmp (i8* i8*))
(de T i8* strchr (i8* i32))
(de T i8* strrchr (i8* i32))
(de T i8* dlsym (i8* i8*))
(de T i8* dlerror ())
(de T i32 dup2 (i32 i32))
(de T i32 close (i32))
(de T i8* signal (i32 i8*))
(de T i32 waitpid (i32 i32* i32))
(de T i32 setjmp (i8*))
(de T NIL longjmp (i8* i32))
(de T i32 kill (i32 i32))
(de T NIL exit (i32))

# libreadline
(local) (readline add_history history_list clear_history)

(de T i8* readline (i8*))
(de T void add_history (i8*))
(de T i8*** history_list ())
(de T void clear_history ())

# Glue lib.c
(local) (PipeBufSize)

(var PipeBufSize i64 NIL)  # PIPE_BUF

(local) (stderrNum stderrMsg gPrintf strErrno openRdonly openWronly openRdWr
openWrAppend socketPair fcntlCloExec fcntlSetFl nonBlocking fcntlSetOwn getDir)

(de T i64 stderrNum (i8* i64))
(de T i8* stderrMsg (i8* i8*))
(de T i32 gPrintf (i8* i32 i8* i8*))
(de T i8* strErrno ())
(de T i32 openRdonly (i8*))
(de T i32 openWronly (i8*))
(de T i32 openRdWr (i8*))
(de T i32 openWrAppend (i8*))
(de T i32 socketPair (i32*))
(de T i32 fcntlCloExec (i32))
(de T void fcntlSetFl (i32 i32))
(de T i32 nonBlocking (i32))
(de T void fcntlSetOwn(i32 i32))
(de T i8* getDir (i8*))

(local) (initReadline rlSigBeg rlSigEnd currentLine)

(de T void initReadline ())
(de T void rlSigBeg ())
(de T void rlSigEnd ())
(de T i8* currentLine ())

# Signals
(local) (Sig SigDfl SigIgn gSignal sigUnblock iSignal waitNohang)

(var Sig i32 NIL)
(var SigDfl i8* NIL)
(var SigIgn i8* NIL)

(de T i32 gSignal (i32))
(de T void sigUnblock (i32))
(de T void iSignal (i32 i8*))
(de T void waitNohang ())

(local) gErrno
(de T i32 gErrno ())

# Terminal
(local) (Tio OrgTermio Termio setRaw setCooked)

(var Tio i1 NIL)
(var OrgTermio i8 NIL)
(var Termio i8* null)

(de T void stopTerm ())
(de T void setRaw ())
(de T void setCooked ())

# System
(local) (getUsec getMsec getDate getGmDate getTime getGmTime fileInfo)

(de T i64 getUsec ())
(de T i64 getMsec ())
(de T i64 getDate ())
(de T i64 getGmDate ())
(de T i64 getTime ())
(de T i64 getGmTime ())
(de T i64 fileInfo (i1 i8* i64*))

# Polling
(local) (pollIn pollOut gPoll readyIn readyOut)

(de T void pollIn (i32 i64*))
(de T void pollOut (i32 i64*))
(de T i32 gPoll (i64* i64 i64))
(de T i1 readyIn (i64* i32))
(de T i1 readyOut (i64* i32))

# Locking
(local) (rdLock wrLock unLock getLock)

(de T i32 rdLock (i32 i64 i64))
(de T i32 wrLock (i32 i64 i64 i32))
(de T i32 unLock (i32 i64 i64))
(de T i32 getLock (i32 i64 i64))

# Catch and Throw
(local) (JmpBufSize QuitRst)

(var JmpBufSize i64 NIL)  # sizeof(jmp_buf)
(var QuitRst i8 NIL)

# Native lib.c
(local) (dlOpen ffiPrep ffiCall boxFloat boxDouble)

(de T i8* dlOpen (i8*))
(de T i8* ffiPrep (i8* i8* i64))
(de T i64 ffiCall (i8* i64))
(de T i64 boxFloat (i32 i64))
(de T i64 boxDouble (i64 i64))

# Case mappings lib.c
(local) (isLowc isUppc isLetterOrDigit toUpperCase toLowerCase)

(de T i1 isLowc (i32))
(de T i1 isUppc (i32))
(de T i1 isLetterOrDigit (i32))
(de T i32 toUpperCase (i32))
(de T i32 toLowerCase (i32))

### Forward references ###

# main.l
(local) (err stkErr argErr cntErr numErr symErr extErr atomErr pairErr lstErr
varErr protErr xCnt evCnt evLst evSym xName equal compare evList)

(de NIL err (any any i8* i8*))
(de NIL stkErr (any))
(de NIL argErr (any any))
(de NIL cntErr (any any))
(de NIL numErr (any any))
(de NIL symErr (any any))
(de NIL extErr (any any))
(de NIL atomErr (any any))
(de NIL pairErr (any any))
(de NIL lstErr (any any))
(de NIL varErr (any any))
(de NIL protErr (any any))
(de i64 xCnt (any any))
(de i64 evCnt (any any))
(de evLst (any))
(de evSym (any))
(de xName (any any))
(de i1 equal (any any))
(de i64 compare (any any))
(de evList (any))

# gc.l
(local) (cons consSym consStr)

(de cons (any any))
(de consSym (any any))
(de consStr (any))

# sym.l
(local) (bufSize pathSize bufString pathString mkStr firstByte firstChar pack
xSym subStr)

(de i64 bufSize (any))
(de i64 pathSize (any))
(de i8* bufString (any i8*))
(de i8* pathString (any i8*))
(de mkStr (i8*))
(de i8 firstByte (any))
(de i32 firstChar (any))
(de void pack (any i64*))
(de xSym (any))
(de i1 subStr (any any))

# io.l
(local) (flushAll newline space outWord outString print begString endString repl)

(de void flushAll ())
(de void newline ())
(de void space ())
(de void outWord (i64))
(de void outString (i8*))
(de void print (any))
(de void begString (i64*))
(de endString ())
(de repl (any i8* any))

# db.l
(local) (dbFetch dbTouch dbZap)

(de void dbFetch (any any))
(de void dbTouch (any any))
(de void dbZap (any))

# flow.l
(local) brkLoad

(de brkLoad (any))

### Primitives ###
(local) (caar cadr cdar cddr int cnt sign sym name memq member length boxNum
box64 eval run)

(inline caar (X)
   (car (car X)) )

(inline cadr (X)
   (car (cdr X)) )

(inline cdar (X)
   (cdr (car X)) )

(inline cddr (X)
   (cdr (cdr X)) )

(inline int (X)
   (shr X 4) )

(inline cnt (X)
   (any (| (shl X 4) 2)) )

(inline sign (X)
   (any (| X 8)) )

(inline sym (X)
   (any (| X 8)) )

(inline name (Tail)
   (until (num? Tail)
      (shift Tail) )
   Tail )

(inline memq (X L)
   (use @
      (loop
         (? (atom L) NO)
         (? (== X (car L)) YES)
         (shift L) ) ) )

(inline member (X L)
   (use @
      (loop
         (? (atom L) NO)
         (? (equal X (car L)) YES)
         (shift L) ) ) )

(inline nth (N X)
   (use @
      (let C (int N)
         (while (dec 'C)
            (shift X) )
         (if (sign? N)
            (cdr X)
            (car X) ) ) ) )

(inline length (X)
   (use @
      (let N 0
         (while (pair X)
            (inc 'N)
            (shift X) )
         N ) ) )

(inline box64 (N)
   (use @
      (if (& N (hex "F000000000000000"))  # Fit in short number
         (boxNum N)
         (cnt N) ) ) )

(inline eval (X)
   (use @
      (cond
         ((num? X) X)
         ((sym? X) (val X))
         (T (evList X)) ) ) )

(inline exec (Prg)
   (use @
      (loop
         (when (pair (++ Prg))
            (evList @) )
         (? (atom Prg)) ) ) )

(inline run (Prg)
   (use @
      (loop
         (let X (++ Prg)
            (? (atom Prg) (eval X))
            (and (pair X) (evList X)) ) ) ) )
