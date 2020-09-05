source_filename = "ext.l"

declare {i64, i1} @llvm.uadd.with.overflow.i64(i64, i64)
declare {i64, i1} @llvm.usub.with.overflow.i64(i64, i64)
declare i64 @llvm.fshl.i64(i64, i64, i64)
declare i64 @llvm.fshr.i64(i64, i64, i64)
declare void @llvm.memcpy.p0i8.p0i8.i64(i8*, i8*, i64, i1)
declare void @llvm.memset.p0i8.p0i8.i64(i8*, i8, i64, i1)
declare i8* @llvm.stacksave()
declare void @llvm.stackrestore(i8*)

@$AV0 = external global i8*
@$AV = external global i8**
@$Home = external global i8*
@$HomeLen = external global i64
@$Heaps = external global i64
@$Avail = external global i64
@$Extern = external global i64
@$ExtCnt = external global i64
@$ExtSkip = external global i64
@$Coroutines = external global i8*
@$StkSize = external global i64
@$StkLimit = external global i8*
@$LinePtr = external global i8*
@$LineBuf = external global i8*
@$LinePrmt = external global i8*
@$ReplPrmt = external global i8*
@$Ret = external global i64
@$TtyPid = external global i32
@$InFiles = external global i8**
@$InFDs = external global i32
@$OutFiles = external global i8**
@$OutFDs = external global i32
@$Poll = external global i64*
@$Nfds = external global i32
@$PutBin = external global void(i8)*
@$GetBin = external global i32()*
@$SeedL = external global i64
@$SeedH = external global i64
@$USec = external global i64
@$TickU = external global i64
@$TickS = external global i64
@$Children = external global i64
@$Child = external global i8*
@$Slot = external global i64
@$Spkr = external global i32
@$Mic = external global i32
@$SpMiPipe = external global [2 x i32]
@$Talking = external global i32
@$Hear = external global i32
@$Tell = external global i32
@$TellBuf = external global i8*
@$Ptr = external global i8*
@$End = external global i8*
@$BufX = external global i8*
@$PtrX = external global i8*
@$EndX = external global i8*
@$ExtN = external global i32
@$Extn = external global i32
@$StrP = external global i64*
@$GcCount = external global i64
@$DbFiles = external global i8*
@$DbFile = external global i8*
@$DBs = external global i32
@$MaxBlkSize = external global i32
@$DbBlock = external global i8*
@$BlkIndex = external global i64
@$BlkLink = external global i64
@$BlkPtr = external global i8*
@$BlkEnd = external global i8*
@$DbJnl = external global i8*
@$DbLog = external global i8*
@$Signal = external global [15 x i32]
@SymTab = external global [840 x i64]
@gcData = external global [52 x i64]
@cbFuns = external global [24 x i64]
@env = external global [24 x i64]
@$Cell = external global [2 x i64]
@$Version = external global [3 x i64]
@$TBuf = external global [2 x i8]
@$Month = external global [13 x i8]
@$Repl = external global i1
@$PRepl = external global i1
@$Jam = external global i1
@$InBye = external global i1
@$Sync = external global i1
@$Empty = constant [1 x i8] c"\00"
@$Indent = constant [4 x i8] c"   \00"
@$Delim = constant [16 x i8] c" \09\0A\0D\22'(),[]`{}~\00"
declare i8* @malloc(i64)
declare i8* @realloc(i8*, i64)
declare void @free(i8*)
declare i32 @fork()
declare i8* @getenv(i8*)
declare i32 @setenv(i8*, i8*, i32)
declare i8* @getcwd(i8*, i64)
declare i32 @chdir(i8*)
declare i32 @getpid()
declare i32 @getpgrp()
declare i32 @setsid()
declare i32 @alarm(i32)
declare i32 @setpgid(i32, i32)
declare i32 @execvp(i8*, i8**)
declare i32 @isatty(i32)
declare i32 @tcgetattr(i32, i8*)
declare i64 @read(i32, i8*, i64)
declare i64 @write(i32, i8*, i64)
declare i64 @pread(i32, i8*, i64, i64)
declare i64 @pwrite(i32, i8*, i64, i64)
declare i32 @fread(i8*, i32, i32, i8*)
declare i32 @fwrite(i8*, i32, i32, i8*)
declare i32 @putc_unlocked(i32, i8*)
declare i32 @getc_unlocked(i8*)
declare i8* @fopen(i8*, i8*)
declare i32 @fflush(i8*)
declare i32 @feof(i8*)
declare i32 @fclose(i8*)
declare i32 @fileno(i8*)
declare i32 @fsync(i32)
declare i32 @pipe(i32*)
declare i32 @memcmp(i8*, i8*, i64)
declare i64 @strlen(i8*)
declare i8* @strcpy(i8*, i8*)
declare i8* @strdup(i8*)
declare i32 @strcmp(i8*, i8*)
declare i8* @strchr(i8*, i32)
declare i8* @strrchr(i8*, i32)
declare i8* @dlsym(i8*, i8*)
declare i8* @dlerror()
declare i32 @dup(i32)
declare i32 @dup2(i32, i32)
declare i32 @close(i32)
declare i8* @signal(i32, i8*)
declare i32 @tcsetpgrp(i32, i32)
declare i32 @waitpid(i32, i32*, i32)
declare i32 @setjmp(i8*)
declare void @longjmp(i8*, i32)
declare i32 @kill(i32, i32)
declare void @exit(i32)
declare i8* @readline(i8*)
declare void @add_history(i8*)
declare i8*** @history_list()
declare void @clear_history()
@TgOS = external global i8
@TgCPU = external global i8
@PipeBufSize = external global i64
declare i64 @stderrNum(i8*, i64)
declare i8* @stderrMsg(i8*, i8*)
declare i32 @gPrintf(i8*, i32, i8*, i8*)
declare i8* @strErrno()
declare i32 @openRd(i8*)
declare i32 @openWr(i8*)
declare i32 @openRdWr(i8*)
declare i32 @openRdWrExcl(i8*)
declare i32 @openRdWrCreate(i8*)
declare i32 @openRdWrAppend(i8*)
declare i32 @openWrAppend(i8*)
declare i1 @fseekOfs(i8*, i32)
declare i1 @fseek0(i8*)
declare i1 @seek0(i32)
declare i1 @truncate0(i32)
declare i32 @socketPair(i32*)
declare i32 @fcntlCloExec(i32)
declare void @fcntlSetFl(i32, i32)
declare i32 @nonBlocking(i32)
declare void @fcntlSetOwn(i32, i32)
declare i8* @getDir(i8*)
declare void @initReadline()
declare void @rlSigBeg()
declare void @rlSigEnd()
declare i8* @currentLine()
@Sig = external global i32
@SigDfl = external global i8*
@SigIgn = external global i8*
declare i32 @gSignal(i32)
declare void @sigUnblock(i32)
declare void @iSignal(i32, i8*)
declare void @waitNohang()
declare i32 @waitWuntraced(i32, i32*)
declare i32 @wifStopped(i32*)
declare i32 @nErrno()
declare i32 @gErrno()
@Tio = external global i1
@OrgTermio = external global i8
@Termio = external global i8*
declare void @stopTerm()
declare void @setRaw()
declare void @setCooked()
declare i1 @reopenTty(i8*)
declare i64 @getUsec(i1)
declare i64 @getMsec()
declare i64 @getDate()
declare i64 @getGmDate()
declare i64 @getTime()
declare i64 @getGmTime()
declare i64 @fileInfo(i1, i8*, i64*)
declare void @pollIn(i32, i64*)
declare void @pollOut(i32, i64*)
declare void @pollIgn(i64*)
declare i32 @gPoll(i64*, i64, i64)
declare i1 @readyIn(i64*)
declare i1 @readyOut(i64*)
declare i32 @rdLock(i32, i64, i64)
declare i32 @wrLock(i32, i64, i64, i32)
declare i32 @unLock(i32, i64, i64)
declare i32 @getLock(i32, i64, i64)
@JmpBufSize = external global i64
@QuitRst = external global i8
declare i8* @dlOpen(i8*)
declare i8* @ffiPrep(i8*, i8*, i64)
declare i64 @ffiCall(i8*, i64)
declare i64 @boxFloat(i32, i64)
declare i64 @boxDouble(i64, i64)
declare void @bufFloat(i64, i64, i8*)
declare void @bufDouble(i64, i64, i8*)
declare i1 @isLowc(i32)
declare i1 @isUppc(i32)
declare i1 @isLetterOrDigit(i32)
declare i32 @toUpperCase(i32)
declare i32 @toLowerCase(i32)
declare i1 @equal(i64, i64)
declare i64 @compare(i64, i64)
declare i64 @evList(i64)
declare i64 @cons(i64, i64)
declare i64 @consStr(i64)
declare i64 @bufSize(i64)
declare i8* @bufString(i64, i8*)
declare i64 @mkStr(i8*)
declare i8 @firstByte(i64)
declare void @pack(i64, i64*)
declare i1 @subStr(i64, i64)
declare void @flushAll()
declare void @newline()
declare void @space()
declare void @outWord(i64)
declare void @outString(i8*)
declare void @print(i64)
declare i64 @repl(i64, i8*, i64)
declare void @dbFetch(i64, i64)
declare void @dbTouch(i64, i64)
declare void @dbZap(i64)
declare i64 @brkLoad(i64)
declare i64 @xCnt(i64, i64)
declare i64 @evCnt(i64, i64)
declare i64 @evSym(i64)
declare i64 @xName(i64, i64)
declare i32 @symChar(i64*)
declare void @charSym(i32, i64*)
declare i8* @initInFile(i32, i8*)
declare i8* @initOutFile(i32)
@$SnxTab = global [194 x i8] [
  i8 48,
  i8 49,
  i8 50,
  i8 51,
  i8 52,
  i8 53,
  i8 54,
  i8 55,
  i8 56,
  i8 57,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 70,
  i8 83,
  i8 84,
  i8 0,
  i8 70,
  i8 83,
  i8 0,
  i8 0,
  i8 83,
  i8 83,
  i8 76,
  i8 78,
  i8 78,
  i8 0,
  i8 70,
  i8 83,
  i8 82,
  i8 83,
  i8 84,
  i8 0,
  i8 70,
  i8 70,
  i8 83,
  i8 0,
  i8 83,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 70,
  i8 83,
  i8 84,
  i8 0,
  i8 70,
  i8 83,
  i8 0,
  i8 0,
  i8 83,
  i8 83,
  i8 76,
  i8 78,
  i8 78,
  i8 0,
  i8 70,
  i8 83,
  i8 82,
  i8 83,
  i8 84,
  i8 0,
  i8 70,
  i8 70,
  i8 83,
  i8 0,
  i8 83,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 83,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 84,
  i8 78,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 83,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 83,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 83,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 0,
  i8 78
]

define i64 @Snx(i64) {
$1:
; # (let X (cdr Exe) (if (nil? (evSym X)) @ (let (P (push 0 (xName Ex...
; # (cdr Exe)
  %1 = inttoptr i64 %0 to i64*
  %2 = getelementptr i64, i64* %1, i32 1
  %3 = load i64, i64* %2
; # (if (nil? (evSym X)) @ (let (P (push 0 (xName Exe @) NIL) C (symC...
; # (evSym X)
  %4 = call i64 @evSym(i64 %3)
; # (nil? (evSym X))
  %5 = icmp eq i64 %4, ptrtoint (i8* getelementptr (i8, i8* bitcast ([840 x i64]* @SymTab to i8*), i32 8) to i64)
  br i1 %5, label %$2, label %$3
$2:
  %6 = phi i64 [%3, %$1] ; # X
  br label %$4
$3:
  %7 = phi i64 [%3, %$1] ; # X
; # (let (P (push 0 (xName Exe @) NIL) C (symChar P)) (while (> SNXBA...
; # (xName Exe @)
  %8 = call i64 @xName(i64 %0, i64 %4)
; # (push 0 (xName Exe @) NIL)
  %9 = alloca i64, i64 3, align 16
  store i64 0, i64* %9
  %10 = getelementptr i64, i64* %9, i32 1
  store i64 %8, i64* %10
; # (symChar P)
  %11 = call i32 @symChar(i64* %9)
; # (while (> SNXBASE C) (unless (setq C (symChar P)) (ret $Nil)))
  br label %$5
$5:
  %12 = phi i64 [%7, %$3], [%21, %$9] ; # X
  %13 = phi i32 [%11, %$3], [%22, %$9] ; # C
; # (> SNXBASE C)
  %14 = icmp sgt i32 48, %13
  br i1 %14, label %$6, label %$7
$6:
  %15 = phi i64 [%12, %$5] ; # X
  %16 = phi i32 [%13, %$5] ; # C
; # (unless (setq C (symChar P)) (ret $Nil))
; # (symChar P)
  %17 = call i32 @symChar(i64* %9)
  %18 = icmp ne i32 %17, 0
  br i1 %18, label %$9, label %$8
$8:
  %19 = phi i64 [%15, %$6] ; # X
  %20 = phi i32 [%17, %$6] ; # C
; # (ret $Nil)
  ret i64 ptrtoint (i8* getelementptr (i8, i8* bitcast ([840 x i64]* @SymTab to i8*), i32 8) to i64)
$9:
  %21 = phi i64 [%15, %$6] ; # X
  %22 = phi i32 [%17, %$6] ; # C
  br label %$5
$7:
  %23 = phi i64 [%12, %$5] ; # X
  %24 = phi i32 [%13, %$5] ; # C
; # (let (Q (link (ofs P 1) T) R (push 4 NIL ZERO NIL) N (if (pair (s...
; # (ofs P 1)
  %25 = getelementptr i64, i64* %9, i32 1
; # (link (ofs P 1) T)
  %26 = ptrtoint i64* %25 to i64
  %27 = inttoptr i64 ptrtoint (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 0) to i64) to i64*
  %28 = load i64, i64* %27
  %29 = inttoptr i64 %26 to i64*
  %30 = getelementptr i64, i64* %29, i32 1
  store i64 %28, i64* %30
  %31 = inttoptr i64 ptrtoint (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 0) to i64) to i64*
  store i64 %26, i64* %31
; # (push 4 NIL ZERO NIL)
  %32 = alloca i64, i64 4, align 16
  store i64 4, i64* %32
  %33 = getelementptr i64, i64* %32, i32 2
  store i64 2, i64* %33
; # (if (pair (shift X)) (evCnt Exe X) 24)
; # (shift X)
  %34 = inttoptr i64 %23 to i64*
  %35 = getelementptr i64, i64* %34, i32 1
  %36 = load i64, i64* %35
; # (pair (shift X))
  %37 = and i64 %36, 15
  %38 = icmp eq i64 %37, 0
  br i1 %38, label %$10, label %$11
$10:
  %39 = phi i64 [%36, %$7] ; # X
  %40 = phi i32 [%24, %$7] ; # C
; # (evCnt Exe X)
  %41 = call i64 @evCnt(i64 %0, i64 %39)
  br label %$12
$11:
  %42 = phi i64 [%36, %$7] ; # X
  %43 = phi i32 [%24, %$7] ; # C
  br label %$12
$12:
  %44 = phi i64 [%39, %$10], [%42, %$11] ; # X
  %45 = phi i32 [%40, %$10], [%43, %$11] ; # C
  %46 = phi i64 [%41, %$10], [24, %$11] ; # ->
; # (ofs R 2)
  %47 = getelementptr i64, i64* %32, i32 2
; # (link (ofs R 2))
  %48 = ptrtoint i64* %47 to i64
  %49 = inttoptr i64 ptrtoint (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 0) to i64) to i64*
  %50 = load i64, i64* %49
  %51 = inttoptr i64 %48 to i64*
  %52 = getelementptr i64, i64* %51, i32 1
  store i64 %50, i64* %52
  %53 = inttoptr i64 ptrtoint (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 0) to i64) to i64*
  store i64 %48, i64* %53
; # (when (or (and (>= C (char "a")) (>= (char "z") C)) (== C 128) (a...
; # (or (and (>= C (char "a")) (>= (char "z") C)) (== C 128) (and (>=...
; # (and (>= C (char "a")) (>= (char "z") C))
; # (>= C (char "a"))
  %54 = icmp sge i32 %45, 97
  br i1 %54, label %$15, label %$14
$15:
  %55 = phi i64 [%44, %$12] ; # X
  %56 = phi i32 [%45, %$12] ; # C
  %57 = phi i64 [%46, %$12] ; # N
; # (>= (char "z") C)
  %58 = icmp sge i32 122, %56
  br label %$14
$14:
  %59 = phi i64 [%44, %$12], [%55, %$15] ; # X
  %60 = phi i32 [%45, %$12], [%56, %$15] ; # C
  %61 = phi i64 [%46, %$12], [%57, %$15] ; # N
  %62 = phi i1 [0, %$12], [%58, %$15] ; # ->
  br i1 %62, label %$13, label %$16
$16:
  %63 = phi i64 [%59, %$14] ; # X
  %64 = phi i32 [%60, %$14] ; # C
  %65 = phi i64 [%61, %$14] ; # N
; # (== C 128)
  %66 = icmp eq i32 %64, 128
  br i1 %66, label %$13, label %$17
$17:
  %67 = phi i64 [%63, %$16] ; # X
  %68 = phi i32 [%64, %$16] ; # C
  %69 = phi i64 [%65, %$16] ; # N
; # (and (>= C 224) (>= 255 C))
; # (>= C 224)
  %70 = icmp sge i32 %68, 224
  br i1 %70, label %$19, label %$18
$19:
  %71 = phi i64 [%67, %$17] ; # X
  %72 = phi i32 [%68, %$17] ; # C
  %73 = phi i64 [%69, %$17] ; # N
; # (>= 255 C)
  %74 = icmp sge i32 255, %72
  br label %$18
$18:
  %75 = phi i64 [%67, %$17], [%71, %$19] ; # X
  %76 = phi i32 [%68, %$17], [%72, %$19] ; # C
  %77 = phi i64 [%69, %$17], [%73, %$19] ; # N
  %78 = phi i1 [0, %$17], [%74, %$19] ; # ->
  br label %$13
$13:
  %79 = phi i64 [%59, %$14], [%63, %$16], [%75, %$18] ; # X
  %80 = phi i32 [%60, %$14], [%64, %$16], [%76, %$18] ; # C
  %81 = phi i64 [%61, %$14], [%65, %$16], [%77, %$18] ; # N
  %82 = phi i1 [1, %$14], [1, %$16], [%78, %$18] ; # ->
  br i1 %82, label %$20, label %$21
$20:
  %83 = phi i64 [%79, %$13] ; # X
  %84 = phi i32 [%80, %$13] ; # C
  %85 = phi i64 [%81, %$13] ; # N
; # (& C -33)
  %86 = and i32 %84, -33
  br label %$21
$21:
  %87 = phi i64 [%79, %$13], [%83, %$20] ; # X
  %88 = phi i32 [%80, %$13], [%86, %$20] ; # C
  %89 = phi i64 [%81, %$13], [%85, %$20] ; # N
; # (charSym C R)
  call void @charSym(i32 %88, i64* %32)
; # (let Last C (loop (? (=0 (setq C (symChar P)))) (when (> C 32) (c...
; # (loop (? (=0 (setq C (symChar P)))) (when (> C 32) (cond ((or (lt...
  br label %$22
$22:
  %90 = phi i64 [%87, %$21], [%152, %$26] ; # X
  %91 = phi i32 [%88, %$21], [%153, %$26] ; # C
  %92 = phi i64 [%89, %$21], [%154, %$26] ; # N
  %93 = phi i32 [%88, %$21], [%155, %$26] ; # Last
; # (? (=0 (setq C (symChar P))))
; # (symChar P)
  %94 = call i32 @symChar(i64* %9)
; # (=0 (setq C (symChar P)))
  %95 = icmp eq i32 %94, 0
  br i1 %95, label %$24, label %$23
$23:
  %96 = phi i64 [%90, %$22] ; # X
  %97 = phi i32 [%94, %$22] ; # C
  %98 = phi i64 [%92, %$22] ; # N
  %99 = phi i32 [%93, %$22] ; # Last
; # (when (> C 32) (cond ((or (lt0 (dec 'C SNXBASE)) (>= C SNXSIZE) (...
; # (> C 32)
  %100 = icmp sgt i32 %97, 32
  br i1 %100, label %$25, label %$26
$25:
  %101 = phi i64 [%96, %$23] ; # X
  %102 = phi i32 [%97, %$23] ; # C
  %103 = phi i64 [%98, %$23] ; # N
  %104 = phi i32 [%99, %$23] ; # Last
; # (cond ((or (lt0 (dec 'C SNXBASE)) (>= C SNXSIZE) (=0 (setq C (i32...
; # (or (lt0 (dec 'C SNXBASE)) (>= C SNXSIZE) (=0 (setq C (i32 (val (...
; # (dec 'C SNXBASE)
  %105 = sub i32 %102, 48
; # (lt0 (dec 'C SNXBASE))
  %106 = icmp slt i32 %105, 0
  br i1 %106, label %$28, label %$29
$29:
  %107 = phi i64 [%101, %$25] ; # X
  %108 = phi i32 [%105, %$25] ; # C
  %109 = phi i64 [%103, %$25] ; # N
  %110 = phi i32 [%104, %$25] ; # Last
; # (>= C SNXSIZE)
  %111 = icmp sge i32 %108, 194
  br i1 %111, label %$28, label %$30
$30:
  %112 = phi i64 [%107, %$29] ; # X
  %113 = phi i32 [%108, %$29] ; # C
  %114 = phi i64 [%109, %$29] ; # N
  %115 = phi i32 [%110, %$29] ; # Last
; # (ofs $SnxTab C)
  %116 = getelementptr i8, i8* bitcast ([194 x i8]* @$SnxTab to i8*), i32 %113
; # (val (ofs $SnxTab C))
  %117 = load i8, i8* %116
; # (i32 (val (ofs $SnxTab C)))
  %118 = zext i8 %117 to i32
; # (=0 (setq C (i32 (val (ofs $SnxTab C)))))
  %119 = icmp eq i32 %118, 0
  br label %$28
$28:
  %120 = phi i64 [%101, %$25], [%107, %$29], [%112, %$30] ; # X
  %121 = phi i32 [%105, %$25], [%108, %$29], [%118, %$30] ; # C
  %122 = phi i64 [%103, %$25], [%109, %$29], [%114, %$30] ; # N
  %123 = phi i32 [%104, %$25], [%110, %$29], [%115, %$30] ; # Last
  %124 = phi i1 [1, %$25], [1, %$29], [%119, %$30] ; # ->
  br i1 %124, label %$32, label %$31
$32:
  %125 = phi i64 [%120, %$28] ; # X
  %126 = phi i32 [%121, %$28] ; # C
  %127 = phi i64 [%122, %$28] ; # N
  %128 = phi i32 [%123, %$28] ; # Last
  br label %$27
$31:
  %129 = phi i64 [%120, %$28] ; # X
  %130 = phi i32 [%121, %$28] ; # C
  %131 = phi i64 [%122, %$28] ; # N
  %132 = phi i32 [%123, %$28] ; # Last
; # (<> C Last)
  %133 = icmp ne i32 %130, %132
  br i1 %133, label %$34, label %$33
$34:
  %134 = phi i64 [%129, %$31] ; # X
  %135 = phi i32 [%130, %$31] ; # C
  %136 = phi i64 [%131, %$31] ; # N
  %137 = phi i32 [%132, %$31] ; # Last
; # (? (=0 (dec 'N)))
; # (dec 'N)
  %138 = sub i64 %136, 1
; # (=0 (dec 'N))
  %139 = icmp eq i64 %138, 0
  br i1 %139, label %$24, label %$35
$35:
  %140 = phi i64 [%134, %$34] ; # X
  %141 = phi i32 [%135, %$34] ; # C
  %142 = phi i64 [%138, %$34] ; # N
  %143 = phi i32 [%137, %$34] ; # Last
; # (charSym (setq Last C) R)
  call void @charSym(i32 %141, i64* %32)
  br label %$27
$33:
  %144 = phi i64 [%129, %$31] ; # X
  %145 = phi i32 [%130, %$31] ; # C
  %146 = phi i64 [%131, %$31] ; # N
  %147 = phi i32 [%132, %$31] ; # Last
  br label %$27
$27:
  %148 = phi i64 [%125, %$32], [%140, %$35], [%144, %$33] ; # X
  %149 = phi i32 [%126, %$32], [%141, %$35], [%145, %$33] ; # C
  %150 = phi i64 [%127, %$32], [%142, %$35], [%146, %$33] ; # N
  %151 = phi i32 [0, %$32], [%141, %$35], [%147, %$33] ; # Last
  br label %$26
$26:
  %152 = phi i64 [%96, %$23], [%148, %$27] ; # X
  %153 = phi i32 [%97, %$23], [%149, %$27] ; # C
  %154 = phi i64 [%98, %$23], [%150, %$27] ; # N
  %155 = phi i32 [%99, %$23], [%151, %$27] ; # Last
  br label %$22
$24:
  %156 = phi i64 [%90, %$22], [%134, %$34] ; # X
  %157 = phi i32 [%94, %$22], [%135, %$34] ; # C
  %158 = phi i64 [%92, %$22], [%138, %$34] ; # N
  %159 = phi i32 [%93, %$22], [%137, %$34] ; # Last
  %160 = phi i64 [0, %$22], [0, %$34] ; # ->
; # (val 3 R)
  %161 = getelementptr i64, i64* %32, i32 2
  %162 = load i64, i64* %161
; # (consStr (val 3 R))
  %163 = call i64 @consStr(i64 %162)
; # (drop *Safe)
  %164 = inttoptr i64 %26 to i64*
  %165 = getelementptr i64, i64* %164, i32 1
  %166 = load i64, i64* %165
  %167 = inttoptr i64 ptrtoint (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 0) to i64) to i64*
  store i64 %166, i64* %167
  br label %$4
$4:
  %168 = phi i64 [%6, %$2], [%156, %$24] ; # X
  %169 = phi i64 [%4, %$2], [%163, %$24] ; # ->
  ret i64 %169
}

define i64 @FD(i64) {
$1:
; # (prog1 (eval (cadr Exe)) (when (ge0 (i32 (xCnt Exe @))) (initInFi...
; # (cadr Exe)
  %1 = inttoptr i64 %0 to i64*
  %2 = getelementptr i64, i64* %1, i32 1
  %3 = load i64, i64* %2
  %4 = inttoptr i64 %3 to i64*
  %5 = load i64, i64* %4
; # (eval (cadr Exe))
  %6 = and i64 %5, 6
  %7 = icmp ne i64 %6, 0
  br i1 %7, label %$4, label %$3
$4:
  br label %$2
$3:
  %8 = and i64 %5, 8
  %9 = icmp ne i64 %8, 0
  br i1 %9, label %$6, label %$5
$6:
  %10 = inttoptr i64 %5 to i64*
  %11 = load i64, i64* %10
  br label %$2
$5:
  %12 = call i64 @evList(i64 %5)
  br label %$2
$2:
  %13 = phi i64 [%5, %$4], [%11, %$6], [%12, %$5] ; # ->
; # (when (ge0 (i32 (xCnt Exe @))) (initInFile @ null) (initOutFile @...
; # (xCnt Exe @)
  %14 = call i64 @xCnt(i64 %0, i64 %13)
; # (i32 (xCnt Exe @))
  %15 = trunc i64 %14 to i32
; # (ge0 (i32 (xCnt Exe @)))
  %16 = icmp sge i32 %15, 0
  br i1 %16, label %$7, label %$8
$7:
; # (initInFile @ null)
  %17 = call i8* @initInFile(i32 %15, i8* null)
; # (initOutFile @)
  %18 = call i8* @initOutFile(i32 %15)
  br label %$8
$8:
  ret i64 %13
}

define i64 @Base64(i64) {
$1:
  ret i64 %0
}

