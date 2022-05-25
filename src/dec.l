# 25may22 Software Lab. Alexander Burger

(symbols '(llvm))

(local) (inFile outFile ioFrame ctFrame dbFile)

# I/O
(struct inFile
   (name 8 i8*)         # File name
   (fd 4 i32)           # File descriptor
   (chr 4 i32)          # Next character
   (line 4 i32)         # Current line number
   (src 4 i32)          # Source start line
   (ix 4 i32)           # Buffer index
   (cnt 4 i32)          # Buffer byte count
   (buf BUFSIZ i8)      # Buffer
   (tty 1 i1) )         # TTY flag

(struct outFile
   (fd 4 i32)           # File descriptor
   (ix 4 i32)           # Buffer index
   (buf BUFSIZ i8)      # Buffer
   (tty 1 i1) )         # TTY flag

(struct ioFrame
   (link 8 i8*)         # Frame link
   (file 8 i8*)         # File structure
   (fun 8 i8*)          # I/O function
   (pid 4 i32) )        # Process ID

(struct getFrame
   (link 8 i8*)         # Frame link
   (exe 8 any)          # Expression
   (fun 8 i8*)          # Saved $Get
   (chr 4 i32) )        # Saved $Chr

(struct putFrame
   (link 8 i8*)         # Frame link
   (exe 8 any)          # Expression
   (fun 8 i8*)          # Saved $Put
   (char 8 any) )       # Next char

(struct ctFrame
   (link 8 i8*)         # Frame link
   (fd 4 i32) )         # File descriptor

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

# Catch/throw
(local) caFrame

(struct caFrame
   (link 8 i8*)         # Frame link
   (tag 8 any)          # Catch tag
   (fin 8 any)          # 'finally' expression
   (co 8 i8*)           # Current coroutine
   (env (env T) i8)     # Saved environment
   (intrn 8 any)        # Internal symbols
   (trns1 8 any)        # Transient symbols
   (trns2 8 any)
   (priv1 8 any)        # Private symbols
   (priv2 8 any)
   (rst 0 i8) )         # Restart jmp_buf (JmpBufSize)

# Coroutines
(local) coroutine

(struct coroutine
   (tag 8 any)          # Coroutine tag
   (prv 8 i8*)          # Previous coroutine
   (nxt 8 i8*)          # Next coroutine
   (org 8 i8*)          # Originator
   (prg 8 any)          # Code body
   (lim 8 i8*)          # Stack limit
   (at 8 any)           # Saved [@]
   (lnk 8 any)          # Link marker
   (bnd 8 any)          # Bind marker
   (ca 8 i8*)           # Catch marker
   (in 8 i8*)           # InFrames marker
   (out 8 i8*)          # OutFrames marker
   (env (env T) i8)     # Saved environment
   (intrn 8 any)        # Internal symbols
   (trns1 8 any)        # Transient symbols
   (trns2 8 any)
   (priv1 8 any)        # Private symbols
   (priv2 8 any)
   (rst 0 i8) )         # Restart jmp_buf (JmpBufSize)

# Family IPC
(local) child

(struct child
   (buf 8 i8*)          # Buffer
   (ofs 4 i32)          # Buffer offset
   (cnt 4 i32)          # Buffer byte count
   (pid 4 i32)          # Process ID
   (hear 4 i32)         # Hear pipe
   (tell 4 i32) )       # Tell pipe

# libc
(local) (malloc realloc free fork getenv setenv getpid getpgrp setsid alarm
setpgid execvp isatty openpty login_tty tcgetattr tcgetpgrp tcsetpgrp read write
pread pwrite fread fwrite putc_unlocked getc_unlocked fopen fflush feof fclose
fileno fsync pipe memcmp strlen strcpy strdup strcmp strchr strrchr dlsym
dlerror dup dup2 close signal poll waitpid setjmp longjmp kill exit)

(de T i8* malloc (i64))
(de T i8* realloc (i8* i64))
(de T void free (i8*))
(de T i32 fork ())
(de T i8* getenv (i8*))
(de T i32 setenv (i8* i8* i32))
(de T i8* getcwd (i8* i64))
(de T i32 chdir (i8*))
(de T i32 getpid ())
(de T i32 getpgrp ())
(de T i32 setsid ())
(de T i32 alarm (i32))
(de T i32 setpgid (i32 i32))
(de T i32 execvp (i8* i8**))
(de T i32 isatty (i32))
(de T i32 openpty (i32* i32* i8* i8* i8*))
(de T i32 login_tty (i32))
(de T i32 tcgetattr (i32 i8*))
(de T i32 tcgetpgrp (i32))
(de T i32 tcsetpgrp (i32 i32))
(de T i64 read (i32 i8* i64))
(de T i64 write (i32 i8* i64))
(de T i64 pread (i32 i8* i64 i64))
(de T i64 pwrite (i32 i8* i64 i64))
(de T i32 fread (i8* i64 i64 i8*))
(de T i32 fwrite (i8* i64 i64 i8*))
(de T i32 putc_unlocked (i32 i8*))
(de T i32 getc_unlocked (i8*))
(de T i8* fopen (i8* i8*))
(de T i32 fflush (i8*))
(de T i32 feof (i8*))
(de T i32 fclose (i8*))
(de T i32 fileno (i8*))
(de T i32 fsync (i32))
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
(de T i32 dup (i32))
(de T i32 dup2 (i32 i32))
(de T i32 close (i32))
(de T i8* signal (i32 i8*))
(de T i32 waitpid (i32 i32* i32))
(de T i32 poll (i64* i32 i64))
(de T i32 setjmp (i8*))
(de T NIL longjmp (i8* i32))
(de T i32 kill (i32 i32))
(de T NIL exit (i32))

# libreadline
(local) (add_history history_list clear_history)

(de T void add_history (i8*))
(de T i8*** history_list ())
(de T void clear_history ())

# Glue lib.c
(local) (TgOS TgCPU PipeBufSize)

(var TgOS i8 NIL)  # Target OS
(var TgCPU i8 NIL)  # Target CPU
(var PipeBufSize i32 NIL)  # PIPE_BUF
(var Fsign i1 NIL)  # Float conversion
(var Fdigit i64 NIL)

(local) (stderrMsg gPrintf strErrno openRd openWr openRdWr openRdWrExcl
openRdWrCreate openRdWrAppend openWrAppend fseekOfs fseek0 seek0 truncate0
socketPair fcntlCloExec fcntlSetFl nonBlocking fcntlSetOwn getDir)

(de T i8* stderrMsg (i8* i8*))
(de T i32 gPrintf (i8* i32 i8* i8*))
(de T i8* strErrno ())
(de T i32 openRd (i8*))
(de T i32 openWr (i8*))
(de T i32 openRdWr (i8*))
(de T i32 openRdWrExcl (i8*))
(de T i32 openRdWrCreate (i8*))
(de T i32 openRdWrAppend (i8*))
(de T i32 openWrAppend (i8*))
(de T i1 fseekOfs (i8* i32))
(de T i1 fseek0 (i8*))
(de T i1 seek0 (i32))
(de T i1 truncate0 (i32))
(de T i32 socketPair (i32*))
(de T i32 fcntlCloExec (i32))
(de T void fcntlSetFl (i32 i32))
(de T i32 nonBlocking (i32))
(de T void fcntlSetOwn(i32 i32))
(de T i8* getDir (i8*))

(local) (initReadline gReadline rlHide rlShow rlSigBeg rlSigEnd currentLine)

(de T void initReadline ())
(de T i8* gReadline (i8*))
(de T void rlHide ())
(de T void rlShow ())
(de T void rlSigBeg ())
(de T void rlSigEnd ())
(de T i8* currentLine ())

# Signals
(local) (Sig SigDfl SigIgn)

(var Sig i32 NIL)
(var SigDfl i8* NIL)
(var SigIgn i8* NIL)

(local) (gSignal sigUnblock iSignal sigChld waitWuntraced wifStopped)

(de T i32 gSignal (i32))
(de T void sigUnblock (i32))
(de T void iSignal (i32 i8*))
(de T void sigChld (i32))
(de T i32 waitWuntraced (i32 i32*))
(de T i32 wifStopped (i32*))

(local) (nErrno gErrno)
(de T i32 nErrno ())
(de T i32 gErrno ())

# Terminal
(local) (Tio OrgTermio Termio setRaw setCooked reopenTty)

(var Tio i1 NIL)
(var OrgTermio i8 NIL)
(var Termio i8* NIL)

(de T void stopTerm ())
(de T void setRaw ())
(de T void setCooked ())
(de T i1 reopenTty (i8*))

# System
(local) (getUsec getMsec getDate getGmDate getTime getGmTime ulimStk fileInfo)

(de T i64 getUsec (i1))
(de T i64 getMsec ())
(de T i64 getDate ())
(de T i64 getGmDate ())
(de T i64 getTime ())
(de T i64 getGmTime ())
(de T i8* ulimStk ())
(de T i64 fileInfo (i1 i8* i64*))

# Polling
(local) (pollIn pollOut pollIgn gPoll readyIn readyOut)

(de T void pollIn (i32 i64*))
(de T void pollOut (i32 i64*))
(de T void pollIgn (i64*))
(de T i32 gPoll (i64* i32 i64))
(de T i1 readyIn (i64*))
(de T i1 readyOut (i64*))

# Locking
(local) (rdLock wrLock unLock getLock)

(de T i32 rdLock (i32 i64 i64 i1))
(de T i32 wrLock (i32 i64 i64 i1))
(de T i32 unLock (i32 i64 i64))
(de T i32 getLock (i32 i64 i64))

# Catch and Throw
(local) (JmpBufSize QuitRst)

(var JmpBufSize i64 NIL)  # sizeof(jmp_buf)
(var QuitRst i8 NIL)

# Native lib.c
(local) (dlOpen ffiPrep ffiCall)

(de T i8* dlOpen (i8*))
(de T i8* ffiPrep (i8* i8* i64))
(de T i64 ffiCall (i8* i64))

(local) (boxFloat boxFlt boxDouble boxDbl bufFloat bufDouble)
(de T i64 boxFloat (i32 i64))
(de T i64 boxFlt ())
(de T i64 boxDouble (i64 i64))
(de T i64 boxDbl ())
(de T void bufFloat (i64 i64 i8*))
(de T void bufDouble (i64 i64 i8*))

# Case mappings lib.c
(local) (isLowc isUppc isLetterOrDigit toUpperCase toLowerCase)

(de T i1 isLowc (i32))
(de T i1 isUppc (i32))
(de T i1 isLetterOrDigit (i32))
(de T i32 toUpperCase (i32))
(de T i32 toLowerCase (i32))

### Forward references ###

# main.l
(local) (dbg equal compare evList)

(de dbg (i64 any))
(de i1 equal (any any))
(de i64 compare (any any))
(de evList (any))

# gc.l
(local) (cons cons2 cons3 consStr)

(de cons (any any))
(de cons2 (any any any))
(de cons3 (any any any any))
(de consStr (any))

# sym.l
(local) (bufSize bufString mkStr firstByte pack xSym subStr)

(de i64 bufSize (any))
(de i8* bufString (any i8*))
(de mkStr (i8*))
(de i8 firstByte (any))
(de void pack (any i64*))
(de i1 subStr (any any))

# io.l
(local) (flush flushAll newline space outWord outString print repl)

(de i1 flush (i8*))
(de void flushAll ())
(de void newline ())
(de void space ())
(de void outWord (i64))
(de void outString (i8*))
(de void print (any))
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
      (if (& N (hex "F000000000000000"))
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

# Runtime checks
(local) (stkChk sigChk)

(inline stkChk (Exe)
   (when (> (val $StkLimit) (stack))
      (stkErr Exe) ) )

(inline sigChk (Exe)
   (when (val $Signal)
      (sighandler Exe) ) )

# Argument checks
(local) (needCnt needNum needSymb needPair needLst needVar chkVar needChkVar needNsp)

(inline needCnt (Exe X)
   (unless (cnt? X)
      (cntErr Exe X) )
   X )

(inline needNum (Exe X)
   (unless (num? X)
      (numErr Exe X) )
   X )

(inline needSymb (Exe X)
   (unless (symb? X)
      (symErr Exe X) )
   X )

(inline needPair (Exe X)
   (when (atom X)
      (pairErr Exe X) )
   X )

(inline needLst (Exe X)
   (unless (or (pair X) (nil? X))
      (lstErr Exe X) )
   X )

(inline needVar (Exe X)
   (when (num? X)
      (varErr Exe X) )
   X )

(inline chkVar (Exe X)
   (when (and (>= X $Nil) (>= $T X))
      (protErr Exe X) )
   X )

(inline needChkVar (Exe X)
   (when (num? X)
      (varErr Exe X) )
   (chkVar Exe X)
   X )

(inline needNsp (Exe X)
   (unless (and (pair (val X)) (== $Tilde (car @)))
      (symNspErr Exe X) )
   X )

# Copy environments
(inline putCaEnv (Ca)
   (let Ca: (caFrame Ca)
      (memcpy (Ca: (env)) (env) (env T) T)
      (Ca: intrn (val $Intern))
      (Ca: trns1 (val $Transient))
      (Ca: trns2 (val 2 $Transient))
      (Ca: priv1 (val $PrivT))
      (Ca: priv2 (val 2 $PrivT)) ) )

(inline getCaEnv (Ca)
   (let Ca: (caFrame Ca)
      (memcpy (env) (Ca: (env)) (env T) T)
      (set $Intern (Ca: intrn))
      (set $Transient (Ca: trns1))
      (set 2 $Transient (Ca: trns2))
      (set $PrivT (Ca: priv1))
      (set 2 $PrivT (Ca: priv2)) ) )

(inline putCrtEnv (Crt)
   (let Crt: (coroutine Crt)
      (memcpy (Crt: (env)) (env) (env T) T)
      (Crt: intrn (val $Intern))
      (Crt: trns1 (val $Transient))
      (Crt: trns2 (val 2 $Transient))
      (Crt: priv1 (val $PrivT))
      (Crt: priv2 (val 2 $PrivT)) ) )

(inline getCrtEnv (Crt)
   (let Crt: (coroutine Crt)
      (memcpy (env) (Crt: (env)) (env T) T)
      (set $Intern (Crt: intrn))
      (set $Transient (Crt: trns1))
      (set 2 $Transient (Crt: trns2))
      (set $PrivT (Crt: priv1))
      (set 2 $PrivT (Crt: priv2)) ) )
