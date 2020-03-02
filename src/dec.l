# 02mar20 Software Lab. Alexander Burger

(symbols '(llvm))

(local) (inFile outFile dbFile ioFrame)

# I/O
(struct inFile
   (fd 4 i32)           # File descriptor
   (ix 4 i32)           # Buffer index
   (cnt 4 i32)          # Buffer byte count
   (next 4 i32)         # Saved next character
   (name 8 i8*)         # Current file name
   (line 8 i64)         # Current line number
   (src 8 i64)          # Source start line
   (buf BUFSIZ i8) )    # Buffer

(struct outFile
   (fd 4 i32)           # File descriptor
   (ix 4 i32)           # Buffer index
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
   (pid 4 i32)          # Process ID
   (hear 4 i32)         # Hear pipe
   (tell 4 i32)         # Tell pipe
   (ofs 4 i32)          # Buffer offset
   (cnt 4 i32) )        # Buffer byte count

# System
(local) (malloc realloc free getpid isatty read write pread pwrite fread fwrite
putc_unlocked fflush fileno strlen strcpy strdup strcmp strchr strrchr dlsym
dlerror close setjmp longjmp kill exit)

(de T i8* malloc (i64))
(de T i8* realloc (i8* i64))
(de T void free (i8*))
(de T i32 getpid ())
(de T i32 isatty (i32))
(de T i32 read (i32 i8* i32))
(de T i32 write (i32 i8* i32))
(de T i32 pread (i32 i8* i32 i64))
(de T i32 pwrite (i32 i8* i32 i64))
(de T i32 fread (i8* i32 i32 i8*))
(de T i32 fwrite (i8* i32 i32 i8*))
(de T i32 putc_unlocked (i32 i8*))
(de T i32 fflush (i8*))
(de T i32 fileno (i8*))
(de T i64 strlen (i8*))
(de T i8* strcpy (i8* i8*))
(de T i8* strdup (i8*))
(de T i32 strcmp (i8* i8*))
(de T i8* strchr (i8* i32))
(de T i8* strrchr (i8* i32))
(de T i8* dlsym (i8* i8*))
(de T i8* dlerror ())
(de T i32 close (i32))
(de T i32 setjmp (i8*))
(de T NIL longjmp (i8* i32))
(de T i32 kill (i32 i32))
(de T NIL exit (i32))

# Glue lib.c
(local) (JmpBufSize stderrMsg xprintf strErrno openRdonly openAppend
fcntlCloExec fcntlSetFl nonBlocking pollIn pollOut xPoll readyIn readyOut rdLock
wrLock unLock getLock xSignal xErrno getTime catchQuit throwQuit dlOpen ffiPrep
ffiCall)

(var JmpBufSize i64 NIL)

(de T i64 stderrMsg (i8* i64))
(de T i32 xprintf (i8* i32 i8* i8*))
(de T i8* strErrno ())
(de T i32 openRdonly (i8*))
(de T i32 openAppend (i8*))
(de T i32 fcntlCloExec (i32))
(de T i32 fcntlSetFl (i32 i32))
(de T i32 nonBlocking (i32))
(de T void pollIn (i32 i64*))
(de T void pollOut (i32 i64*))
(de T i32 xPoll (i64* i64 i64))
(de T i32 readyIn (i64*))
(de T i32 readyOut (i64*))
(de T i32 rdLock (i32 i64 i64))
(de T i32 wrLock (i32 i64 i64 i32))
(de T i32 unLock (i32 i64 i64))
(de T i32 getLock (i32 i64 i64))
(de T i32 xSignal (i32))
(de T i32 xErrno ())
(de T i64 getTime ())
(de T i32 catchQuit ())
(de T NIL throwQuit ())

# Native lib.c
(de T i8* dlOpen (i8*))
(de T i8* ffiPrep (i8* i8* i64))
(de T i64 ffiCall (i8* i64))

# Case mappings
(de T i1 isLowc (i32))
(de T i1 isUppc (i32))
(de T i1 isLetterOrDigit (i32))
(de T i32 toUpperCase (i32))
(de T i32 toLowerCase (i32))

### Forward references
(local) (evList mkStr subStr read0 pushOutFiles newline space outWord outString
print repl)

# main.l
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
(de evCnt (any any))
(de evLst (any))
(de evSym (any))
(de i1 equal (any any))
(de i32 compare (any any))
(de evList (any))
# sym.l
(de name (any))
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
(de read0 (i1))
(de void pushOutFiles (i8*))
(de void newline ())
(de void space ())
(de void outWord (i64))
(de void outString (i8*))
(de void print (any))
(de repl (any i32 any))
# db.l
(de dbTouch (any))

### Primitives
(local) (caar cadr cdar cddr int cnt sign sym length eval run)

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

(inline length (X)
   (let N 0
      (while (pair X)
         (inc 'N)
         (>>> X) )
      N ) )

(inline eval (X)
   (cond
      ((num? X) X)
      ((sym? X) (car X))
      (T (evList X)) ) )

(inline run (Bnd2)
   (loop
      (? (atom (cdr Bnd2))
         (eval (car Bnd2)) )
      (when (pair (car Bnd2))
         (evList (car Bnd2)) )
     (>>> Bnd2) ) )
