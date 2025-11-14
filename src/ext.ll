source_filename = "ext.l"

declare {i64, i1} @llvm.uadd.with.overflow.i64(i64, i64)
declare {i64, i1} @llvm.usub.with.overflow.i64(i64, i64)
declare i64 @llvm.fshl.i64(i64, i64, i64)
declare i64 @llvm.fshr.i64(i64, i64, i64)
declare void @llvm.memcpy.p0i8.p0i8.i64(i8*, i8*, i64, i1)
declare void @llvm.memset.p0i8.i64(i8*, i8, i64, i1)
declare i8* @llvm.stacksave()
declare void @llvm.stackrestore(i8*)
declare void @llvm.donothing() nounwind readnone

@$AV0 = external global i8*
@$AV = external global i8**
@$PilHome = external global i8*
@$PilLen = external global i64
@$UsrHome = external global i8*
@$UsrLen = external global i64
@$Heaps = external global i64
@$Avail = external global i64
@$Extern = external global i64
@$ExtCnt = external global i64
@$ExtSkip = external global i64
@$Coroutines = external global i8*
@$Current = external global i8*
@$CrtLast = external global i8*
@$CrtFree = external global i8*
@$SysStkLimit = external global i8*
@$StkLimit = external global i8*
@$StkSizeT = external global i64
@$StkSize = external global i64
@$Stdin = external global i8*
@$Stdout = external global i8*
@$LinePtr = external global i8*
@$LineBuf = external global i8*
@$LinePrmt = external global i8*
@$ReplPrmt = external global i8*
@$ContPrmt = external global i8*
@$Ret = external global i64
@$Ret2 = external global i64
@$TtyPid = external global i32
@$InFDs = external global i32
@$InFiles = external global i8**
@$OutFiles = external global i8**
@$IoCnt = external global i32
@$IoIx = external global i64
@$IoChar = external global i64
@$PutBin = external global void(i8)*
@$GetBin = external global i32()*
@$OutFDs = external global i32
@$Nfds = external global i32
@$Poll = external global i64*
@$SeedL = external global i64
@$SeedH = external global i64
@$USec = external global i64
@$Rt = external global i64
@$Child = external global i8*
@$Children = external global i32
@$Slot = external global i32
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
@$Signal = external global [16 x i32]
@SymTab = external global [896 x i64]
@gcData = external global [53 x i64]
@cbFuns = external global [24 x i64]
@env = external global [25 x i64]
@$Cell = external global [2 x i64]
@$Version = external global [3 x i64]
@$TBuf = external global [2 x i8]
@$Month = external global [13 x i8]
@$Repl = external global i1
@$PRepl = external global i1
@$Tc = external global i1
@$Jam = external global i1
@$InBye = external global i1
@$Sync = external global i1
@$Empty = constant [1 x i8] c"\00"
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
declare i32 @openpty(i32*, i32*, i8*, i8*, i8*)
declare i32 @login_tty(i32)
declare i32 @tcgetattr(i32, i8*)
declare i32 @tcgetpgrp(i32)
declare i32 @tcsetpgrp(i32, i32)
declare i64 @read(i32, i8*, i64)
declare i64 @write(i32, i8*, i64)
declare i64 @pread(i32, i8*, i64, i64)
declare i64 @pwrite(i32, i8*, i64, i64)
declare i32 @fread(i8*, i64, i64, i8*)
declare i32 @fwrite(i8*, i64, i64, i8*)
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
declare i32 @waitpid(i32, i32*, i32)
declare i32 @poll(i64*, i32, i64)
declare i32 @setjmp(i8*)
declare void @longjmp(i8*, i32)
declare i32 @kill(i32, i32)
declare void @exit(i32)
declare void @add_history(i8*)
declare i8*** @history_list()
declare void @clear_history()
@TgOS = external global i8
@TgCPU = external global i8
@PipeBufSize = external global i32
@Fsign = external global i1
@Fdigit = external global i64
declare i8* @stderrMsg(i8*, i8*)
declare void @gPrintf(i8*, i32, i8*, i8*)
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
declare i8* @gReadline(i8*)
declare void @rlHide()
declare void @rlShow()
declare void @rlSigBeg()
declare void @rlSigEnd()
declare i8* @currentLine()
@Sig = external global i32
@SigDfl = external global i8*
@SigIgn = external global i8*
declare i32 @gSignal(i32)
declare void @iSignal(i32, i8*)
declare void @sigUnblock(i32)
declare void @sigChld(i32)
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
declare i8* @ulimStk()
declare i64 @fileInfo(i1, i1, i8*, i64*)
declare void @pollIn(i32, i64*)
declare void @pollOut(i32, i64*)
declare void @pollIgn(i64*)
declare i32 @gPoll(i64*, i32, i64)
declare i1 @readyIn(i64*)
declare i1 @readyOut(i64*)
declare i32 @rdLock(i32, i64, i64, i1)
declare i32 @wrLock(i32, i64, i64, i1)
declare i32 @unLock(i32, i64, i64)
declare i32 @getLock(i32, i64, i64)
@JmpBufSize = external global i64
@QuitRst = external global i8
@SoRst = external global i8
declare i8* @dlOpen(i8*)
declare i8* @ffiPrep(i8*, i8*, i64)
declare i64 @ffiCall(i8*, i64)
declare i64 @boxFloat(i32, i64)
declare i64 @boxFlt()
declare i64 @boxDouble(i64, i64)
declare i64 @boxDbl()
declare void @bufFloat(i64, i64, i32*)
declare void @bufDouble(i64, i64, i64*)
declare i1 @chance(i64)
declare i1 @isLowc(i32)
declare i1 @isUppc(i32)
declare i1 @isLetterOrDigit(i32)
declare i32 @toUpperCase(i32)
declare i32 @toLowerCase(i32)
declare i64 @dbg(i64, i64)
declare i1 @equal(i64, i64)
declare i64 @compare(i64, i64)
declare i64 @evList(i64)
declare i64 @cons(i64, i64)
declare i64 @cons2(i64, i64, i64)
declare i64 @cons3(i64, i64, i64, i64)
declare i64 @consStr(i64)
declare i64 @bufSize(i64)
declare i8* @bufString(i64, i8*)
declare i64 @mkStr(i8*)
declare i8 @firstByte(i64)
declare void @pack(i64, i64*)
declare i64 @subStr(i64, i64, i64)
declare i1 @flush(i8*)
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
declare void @putSrc(i64, i64)
declare i64 @brkLoad(i64)
declare i64 @xCnt(i64, i64)
declare i64 @evCnt(i64, i64)
declare i64 @evSym(i64)
declare i64 @xName(i64)
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

define i64 @Snx(i64) align 8 {
$1:
; # (let X (cdr Exe) (if (nil? (evSym X)) @ (let (P (push 0 (xName @)...
; # (cdr Exe)
  %1 = inttoptr i64 %0 to i64*
  %2 = getelementptr i64, i64* %1, i32 1
  %3 = load i64, i64* %2
; # (if (nil? (evSym X)) @ (let (P (push 0 (xName @) NIL) C (symChar ...
; # (evSym X)
  %4 = call i64 @evSym(i64 %3)
; # (nil? (evSym X))
  %5 = icmp eq i64 %4, ptrtoint (i8* getelementptr (i8, i8* bitcast ([896 x i64]* @SymTab to i8*), i32 8) to i64)
  br i1 %5, label %$2, label %$3
$2:
  %6 = phi i64 [%0, %$1] ; # Exe
  %7 = phi i64 [%3, %$1] ; # X
  br label %$4
$3:
  %8 = phi i64 [%0, %$1] ; # Exe
  %9 = phi i64 [%3, %$1] ; # X
; # (let (P (push 0 (xName @) NIL) C (symChar P)) (while (> SNXBASE C...
; # (xName @)
  %10 = call i64 @xName(i64 %4)
; # (push 0 (xName @) NIL)
  %11 = alloca i64, i64 3, align 16
  store i64 0, i64* %11
  %12 = getelementptr i64, i64* %11, i32 1
  store i64 %10, i64* %12
; # (symChar P)
  %13 = call i32 @symChar(i64* %11)
; # (while (> SNXBASE C) (unless (setq C (symChar P)) (ret $Nil)))
  br label %$5
$5:
  %14 = phi i64 [%8, %$3], [%29, %$9] ; # Exe
  %15 = phi i64 [%9, %$3], [%30, %$9] ; # X
  %16 = phi i64* [%11, %$3], [%31, %$9] ; # P
  %17 = phi i32 [%13, %$3], [%32, %$9] ; # C
; # (> SNXBASE C)
  %18 = icmp sgt i32 48, %17
  br i1 %18, label %$6, label %$7
$6:
  %19 = phi i64 [%14, %$5] ; # Exe
  %20 = phi i64 [%15, %$5] ; # X
  %21 = phi i64* [%16, %$5] ; # P
  %22 = phi i32 [%17, %$5] ; # C
; # (unless (setq C (symChar P)) (ret $Nil))
; # (symChar P)
  %23 = call i32 @symChar(i64* %21)
  %24 = icmp ne i32 %23, 0
  br i1 %24, label %$9, label %$8
$8:
  %25 = phi i64 [%19, %$6] ; # Exe
  %26 = phi i64 [%20, %$6] ; # X
  %27 = phi i64* [%21, %$6] ; # P
  %28 = phi i32 [%23, %$6] ; # C
; # (ret $Nil)
  ret i64 ptrtoint (i8* getelementptr (i8, i8* bitcast ([896 x i64]* @SymTab to i8*), i32 8) to i64)
$9:
  %29 = phi i64 [%19, %$6] ; # Exe
  %30 = phi i64 [%20, %$6] ; # X
  %31 = phi i64* [%21, %$6] ; # P
  %32 = phi i32 [%23, %$6] ; # C
  br label %$5
$7:
  %33 = phi i64 [%14, %$5] ; # Exe
  %34 = phi i64 [%15, %$5] ; # X
  %35 = phi i64* [%16, %$5] ; # P
  %36 = phi i32 [%17, %$5] ; # C
; # (let (Q (link (ofs P 1) T) R (push 4 NIL ZERO NIL) N (if (pair (s...
; # (ofs P 1)
  %37 = getelementptr i64, i64* %35, i32 1
; # (link (ofs P 1) T)
  %38 = ptrtoint i64* %37 to i64
  %39 = inttoptr i64 ptrtoint (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 0) to i64) to i64*
  %40 = load i64, i64* %39
  %41 = inttoptr i64 %38 to i64*
  %42 = getelementptr i64, i64* %41, i32 1
  store i64 %40, i64* %42
  %43 = inttoptr i64 ptrtoint (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 0) to i64) to i64*
  store i64 %38, i64* %43
; # (push 4 NIL ZERO NIL)
  %44 = alloca i64, i64 4, align 16
  store i64 4, i64* %44
  %45 = getelementptr i64, i64* %44, i32 2
  store i64 2, i64* %45
; # (if (pair (shift X)) (evCnt Exe X) 24)
; # (shift X)
  %46 = inttoptr i64 %34 to i64*
  %47 = getelementptr i64, i64* %46, i32 1
  %48 = load i64, i64* %47
; # (pair (shift X))
  %49 = and i64 %48, 15
  %50 = icmp eq i64 %49, 0
  br i1 %50, label %$10, label %$11
$10:
  %51 = phi i64 [%33, %$7] ; # Exe
  %52 = phi i64 [%48, %$7] ; # X
  %53 = phi i64* [%35, %$7] ; # P
  %54 = phi i32 [%36, %$7] ; # C
  %55 = phi i64 [%38, %$7] ; # Q
  %56 = phi i64* [%44, %$7] ; # R
; # (evCnt Exe X)
  %57 = call i64 @evCnt(i64 %51, i64 %52)
  br label %$12
$11:
  %58 = phi i64 [%33, %$7] ; # Exe
  %59 = phi i64 [%48, %$7] ; # X
  %60 = phi i64* [%35, %$7] ; # P
  %61 = phi i32 [%36, %$7] ; # C
  %62 = phi i64 [%38, %$7] ; # Q
  %63 = phi i64* [%44, %$7] ; # R
  br label %$12
$12:
  %64 = phi i64 [%51, %$10], [%58, %$11] ; # Exe
  %65 = phi i64 [%52, %$10], [%59, %$11] ; # X
  %66 = phi i64* [%53, %$10], [%60, %$11] ; # P
  %67 = phi i32 [%54, %$10], [%61, %$11] ; # C
  %68 = phi i64 [%55, %$10], [%62, %$11] ; # Q
  %69 = phi i64* [%56, %$10], [%63, %$11] ; # R
  %70 = phi i64 [%57, %$10], [24, %$11] ; # ->
; # (ofs R 2)
  %71 = getelementptr i64, i64* %69, i32 2
; # (link (ofs R 2))
  %72 = ptrtoint i64* %71 to i64
  %73 = inttoptr i64 ptrtoint (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 0) to i64) to i64*
  %74 = load i64, i64* %73
  %75 = inttoptr i64 %72 to i64*
  %76 = getelementptr i64, i64* %75, i32 1
  store i64 %74, i64* %76
  %77 = inttoptr i64 ptrtoint (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 0) to i64) to i64*
  store i64 %72, i64* %77
; # (when (or (and (>= C (char "a")) (>= (char "z") C)) (== C 128) (a...
; # (or (and (>= C (char "a")) (>= (char "z") C)) (== C 128) (and (>=...
; # (and (>= C (char "a")) (>= (char "z") C))
; # (>= C (char "a"))
  %78 = icmp sge i32 %67, 97
  br i1 %78, label %$15, label %$14
$15:
  %79 = phi i64 [%64, %$12] ; # Exe
  %80 = phi i64 [%65, %$12] ; # X
  %81 = phi i64* [%66, %$12] ; # P
  %82 = phi i32 [%67, %$12] ; # C
  %83 = phi i64 [%68, %$12] ; # Q
  %84 = phi i64* [%69, %$12] ; # R
  %85 = phi i64 [%70, %$12] ; # N
; # (>= (char "z") C)
  %86 = icmp sge i32 122, %82
  br label %$14
$14:
  %87 = phi i64 [%64, %$12], [%79, %$15] ; # Exe
  %88 = phi i64 [%65, %$12], [%80, %$15] ; # X
  %89 = phi i64* [%66, %$12], [%81, %$15] ; # P
  %90 = phi i32 [%67, %$12], [%82, %$15] ; # C
  %91 = phi i64 [%68, %$12], [%83, %$15] ; # Q
  %92 = phi i64* [%69, %$12], [%84, %$15] ; # R
  %93 = phi i64 [%70, %$12], [%85, %$15] ; # N
  %94 = phi i1 [0, %$12], [%86, %$15] ; # ->
  br i1 %94, label %$13, label %$16
$16:
  %95 = phi i64 [%87, %$14] ; # Exe
  %96 = phi i64 [%88, %$14] ; # X
  %97 = phi i64* [%89, %$14] ; # P
  %98 = phi i32 [%90, %$14] ; # C
  %99 = phi i64 [%91, %$14] ; # Q
  %100 = phi i64* [%92, %$14] ; # R
  %101 = phi i64 [%93, %$14] ; # N
; # (== C 128)
  %102 = icmp eq i32 %98, 128
  br i1 %102, label %$13, label %$17
$17:
  %103 = phi i64 [%95, %$16] ; # Exe
  %104 = phi i64 [%96, %$16] ; # X
  %105 = phi i64* [%97, %$16] ; # P
  %106 = phi i32 [%98, %$16] ; # C
  %107 = phi i64 [%99, %$16] ; # Q
  %108 = phi i64* [%100, %$16] ; # R
  %109 = phi i64 [%101, %$16] ; # N
; # (and (>= C 224) (>= 255 C))
; # (>= C 224)
  %110 = icmp sge i32 %106, 224
  br i1 %110, label %$19, label %$18
$19:
  %111 = phi i64 [%103, %$17] ; # Exe
  %112 = phi i64 [%104, %$17] ; # X
  %113 = phi i64* [%105, %$17] ; # P
  %114 = phi i32 [%106, %$17] ; # C
  %115 = phi i64 [%107, %$17] ; # Q
  %116 = phi i64* [%108, %$17] ; # R
  %117 = phi i64 [%109, %$17] ; # N
; # (>= 255 C)
  %118 = icmp sge i32 255, %114
  br label %$18
$18:
  %119 = phi i64 [%103, %$17], [%111, %$19] ; # Exe
  %120 = phi i64 [%104, %$17], [%112, %$19] ; # X
  %121 = phi i64* [%105, %$17], [%113, %$19] ; # P
  %122 = phi i32 [%106, %$17], [%114, %$19] ; # C
  %123 = phi i64 [%107, %$17], [%115, %$19] ; # Q
  %124 = phi i64* [%108, %$17], [%116, %$19] ; # R
  %125 = phi i64 [%109, %$17], [%117, %$19] ; # N
  %126 = phi i1 [0, %$17], [%118, %$19] ; # ->
  br label %$13
$13:
  %127 = phi i64 [%87, %$14], [%95, %$16], [%119, %$18] ; # Exe
  %128 = phi i64 [%88, %$14], [%96, %$16], [%120, %$18] ; # X
  %129 = phi i64* [%89, %$14], [%97, %$16], [%121, %$18] ; # P
  %130 = phi i32 [%90, %$14], [%98, %$16], [%122, %$18] ; # C
  %131 = phi i64 [%91, %$14], [%99, %$16], [%123, %$18] ; # Q
  %132 = phi i64* [%92, %$14], [%100, %$16], [%124, %$18] ; # R
  %133 = phi i64 [%93, %$14], [%101, %$16], [%125, %$18] ; # N
  %134 = phi i1 [1, %$14], [1, %$16], [%126, %$18] ; # ->
  br i1 %134, label %$20, label %$21
$20:
  %135 = phi i64 [%127, %$13] ; # Exe
  %136 = phi i64 [%128, %$13] ; # X
  %137 = phi i64* [%129, %$13] ; # P
  %138 = phi i32 [%130, %$13] ; # C
  %139 = phi i64 [%131, %$13] ; # Q
  %140 = phi i64* [%132, %$13] ; # R
  %141 = phi i64 [%133, %$13] ; # N
; # (& C -33)
  %142 = and i32 %138, -33
  br label %$21
$21:
  %143 = phi i64 [%127, %$13], [%135, %$20] ; # Exe
  %144 = phi i64 [%128, %$13], [%136, %$20] ; # X
  %145 = phi i64* [%129, %$13], [%137, %$20] ; # P
  %146 = phi i32 [%130, %$13], [%142, %$20] ; # C
  %147 = phi i64 [%131, %$13], [%139, %$20] ; # Q
  %148 = phi i64* [%132, %$13], [%140, %$20] ; # R
  %149 = phi i64 [%133, %$13], [%141, %$20] ; # N
; # (charSym C R)
  call void @charSym(i32 %146, i64* %148)
; # (let Last C (loop (? (=0 (setq C (symChar P)))) (when (> C 32) (c...
; # (loop (? (=0 (setq C (symChar P)))) (when (> C 32) (cond ((or (lt...
  br label %$22
$22:
  %150 = phi i64 [%143, %$21], [%260, %$26] ; # Exe
  %151 = phi i64 [%144, %$21], [%261, %$26] ; # X
  %152 = phi i64* [%145, %$21], [%262, %$26] ; # P
  %153 = phi i32 [%146, %$21], [%263, %$26] ; # C
  %154 = phi i64 [%147, %$21], [%264, %$26] ; # Q
  %155 = phi i64* [%148, %$21], [%265, %$26] ; # R
  %156 = phi i64 [%149, %$21], [%266, %$26] ; # N
  %157 = phi i32 [%146, %$21], [%267, %$26] ; # Last
; # (? (=0 (setq C (symChar P))))
; # (symChar P)
  %158 = call i32 @symChar(i64* %152)
; # (=0 (setq C (symChar P)))
  %159 = icmp eq i32 %158, 0
  br i1 %159, label %$24, label %$23
$23:
  %160 = phi i64 [%150, %$22] ; # Exe
  %161 = phi i64 [%151, %$22] ; # X
  %162 = phi i64* [%152, %$22] ; # P
  %163 = phi i32 [%158, %$22] ; # C
  %164 = phi i64 [%154, %$22] ; # Q
  %165 = phi i64* [%155, %$22] ; # R
  %166 = phi i64 [%156, %$22] ; # N
  %167 = phi i32 [%157, %$22] ; # Last
; # (when (> C 32) (cond ((or (lt0 (dec 'C SNXBASE)) (>= C SNXSIZE) (...
; # (> C 32)
  %168 = icmp sgt i32 %163, 32
  br i1 %168, label %$25, label %$26
$25:
  %169 = phi i64 [%160, %$23] ; # Exe
  %170 = phi i64 [%161, %$23] ; # X
  %171 = phi i64* [%162, %$23] ; # P
  %172 = phi i32 [%163, %$23] ; # C
  %173 = phi i64 [%164, %$23] ; # Q
  %174 = phi i64* [%165, %$23] ; # R
  %175 = phi i64 [%166, %$23] ; # N
  %176 = phi i32 [%167, %$23] ; # Last
; # (cond ((or (lt0 (dec 'C SNXBASE)) (>= C SNXSIZE) (=0 (setq C (i32...
; # (or (lt0 (dec 'C SNXBASE)) (>= C SNXSIZE) (=0 (setq C (i32 (val (...
; # (dec 'C SNXBASE)
  %177 = sub i32 %172, 48
; # (lt0 (dec 'C SNXBASE))
  %178 = icmp slt i32 %177, 0
  br i1 %178, label %$28, label %$29
$29:
  %179 = phi i64 [%169, %$25] ; # Exe
  %180 = phi i64 [%170, %$25] ; # X
  %181 = phi i64* [%171, %$25] ; # P
  %182 = phi i32 [%177, %$25] ; # C
  %183 = phi i64 [%173, %$25] ; # Q
  %184 = phi i64* [%174, %$25] ; # R
  %185 = phi i64 [%175, %$25] ; # N
  %186 = phi i32 [%176, %$25] ; # Last
; # (>= C SNXSIZE)
  %187 = icmp sge i32 %182, 194
  br i1 %187, label %$28, label %$30
$30:
  %188 = phi i64 [%179, %$29] ; # Exe
  %189 = phi i64 [%180, %$29] ; # X
  %190 = phi i64* [%181, %$29] ; # P
  %191 = phi i32 [%182, %$29] ; # C
  %192 = phi i64 [%183, %$29] ; # Q
  %193 = phi i64* [%184, %$29] ; # R
  %194 = phi i64 [%185, %$29] ; # N
  %195 = phi i32 [%186, %$29] ; # Last
; # (ofs $SnxTab C)
  %196 = getelementptr i8, i8* bitcast ([194 x i8]* @$SnxTab to i8*), i32 %191
; # (val (ofs $SnxTab C))
  %197 = load i8, i8* %196
; # (i32 (val (ofs $SnxTab C)))
  %198 = zext i8 %197 to i32
; # (=0 (setq C (i32 (val (ofs $SnxTab C)))))
  %199 = icmp eq i32 %198, 0
  br label %$28
$28:
  %200 = phi i64 [%169, %$25], [%179, %$29], [%188, %$30] ; # Exe
  %201 = phi i64 [%170, %$25], [%180, %$29], [%189, %$30] ; # X
  %202 = phi i64* [%171, %$25], [%181, %$29], [%190, %$30] ; # P
  %203 = phi i32 [%177, %$25], [%182, %$29], [%198, %$30] ; # C
  %204 = phi i64 [%173, %$25], [%183, %$29], [%192, %$30] ; # Q
  %205 = phi i64* [%174, %$25], [%184, %$29], [%193, %$30] ; # R
  %206 = phi i64 [%175, %$25], [%185, %$29], [%194, %$30] ; # N
  %207 = phi i32 [%176, %$25], [%186, %$29], [%195, %$30] ; # Last
  %208 = phi i1 [1, %$25], [1, %$29], [%199, %$30] ; # ->
  br i1 %208, label %$32, label %$31
$32:
  %209 = phi i64 [%200, %$28] ; # Exe
  %210 = phi i64 [%201, %$28] ; # X
  %211 = phi i64* [%202, %$28] ; # P
  %212 = phi i32 [%203, %$28] ; # C
  %213 = phi i64 [%204, %$28] ; # Q
  %214 = phi i64* [%205, %$28] ; # R
  %215 = phi i64 [%206, %$28] ; # N
  %216 = phi i32 [%207, %$28] ; # Last
  br label %$27
$31:
  %217 = phi i64 [%200, %$28] ; # Exe
  %218 = phi i64 [%201, %$28] ; # X
  %219 = phi i64* [%202, %$28] ; # P
  %220 = phi i32 [%203, %$28] ; # C
  %221 = phi i64 [%204, %$28] ; # Q
  %222 = phi i64* [%205, %$28] ; # R
  %223 = phi i64 [%206, %$28] ; # N
  %224 = phi i32 [%207, %$28] ; # Last
; # (<> C Last)
  %225 = icmp ne i32 %220, %224
  br i1 %225, label %$34, label %$33
$34:
  %226 = phi i64 [%217, %$31] ; # Exe
  %227 = phi i64 [%218, %$31] ; # X
  %228 = phi i64* [%219, %$31] ; # P
  %229 = phi i32 [%220, %$31] ; # C
  %230 = phi i64 [%221, %$31] ; # Q
  %231 = phi i64* [%222, %$31] ; # R
  %232 = phi i64 [%223, %$31] ; # N
  %233 = phi i32 [%224, %$31] ; # Last
; # (? (=0 (dec 'N)))
; # (dec 'N)
  %234 = sub i64 %232, 1
; # (=0 (dec 'N))
  %235 = icmp eq i64 %234, 0
  br i1 %235, label %$24, label %$35
$35:
  %236 = phi i64 [%226, %$34] ; # Exe
  %237 = phi i64 [%227, %$34] ; # X
  %238 = phi i64* [%228, %$34] ; # P
  %239 = phi i32 [%229, %$34] ; # C
  %240 = phi i64 [%230, %$34] ; # Q
  %241 = phi i64* [%231, %$34] ; # R
  %242 = phi i64 [%234, %$34] ; # N
  %243 = phi i32 [%233, %$34] ; # Last
; # (charSym (setq Last C) R)
  call void @charSym(i32 %239, i64* %241)
  br label %$27
$33:
  %244 = phi i64 [%217, %$31] ; # Exe
  %245 = phi i64 [%218, %$31] ; # X
  %246 = phi i64* [%219, %$31] ; # P
  %247 = phi i32 [%220, %$31] ; # C
  %248 = phi i64 [%221, %$31] ; # Q
  %249 = phi i64* [%222, %$31] ; # R
  %250 = phi i64 [%223, %$31] ; # N
  %251 = phi i32 [%224, %$31] ; # Last
  br label %$27
$27:
  %252 = phi i64 [%209, %$32], [%236, %$35], [%244, %$33] ; # Exe
  %253 = phi i64 [%210, %$32], [%237, %$35], [%245, %$33] ; # X
  %254 = phi i64* [%211, %$32], [%238, %$35], [%246, %$33] ; # P
  %255 = phi i32 [%212, %$32], [%239, %$35], [%247, %$33] ; # C
  %256 = phi i64 [%213, %$32], [%240, %$35], [%248, %$33] ; # Q
  %257 = phi i64* [%214, %$32], [%241, %$35], [%249, %$33] ; # R
  %258 = phi i64 [%215, %$32], [%242, %$35], [%250, %$33] ; # N
  %259 = phi i32 [0, %$32], [%239, %$35], [%251, %$33] ; # Last
  br label %$26
$26:
  %260 = phi i64 [%160, %$23], [%252, %$27] ; # Exe
  %261 = phi i64 [%161, %$23], [%253, %$27] ; # X
  %262 = phi i64* [%162, %$23], [%254, %$27] ; # P
  %263 = phi i32 [%163, %$23], [%255, %$27] ; # C
  %264 = phi i64 [%164, %$23], [%256, %$27] ; # Q
  %265 = phi i64* [%165, %$23], [%257, %$27] ; # R
  %266 = phi i64 [%166, %$23], [%258, %$27] ; # N
  %267 = phi i32 [%167, %$23], [%259, %$27] ; # Last
  br label %$22
$24:
  %268 = phi i64 [%150, %$22], [%226, %$34] ; # Exe
  %269 = phi i64 [%151, %$22], [%227, %$34] ; # X
  %270 = phi i64* [%152, %$22], [%228, %$34] ; # P
  %271 = phi i32 [%158, %$22], [%229, %$34] ; # C
  %272 = phi i64 [%154, %$22], [%230, %$34] ; # Q
  %273 = phi i64* [%155, %$22], [%231, %$34] ; # R
  %274 = phi i64 [%156, %$22], [%234, %$34] ; # N
  %275 = phi i32 [%157, %$22], [%233, %$34] ; # Last
  %276 = phi i64 [0, %$22], [0, %$34] ; # ->
; # (val 3 R)
  %277 = getelementptr i64, i64* %273, i32 2
  %278 = load i64, i64* %277
; # (consStr (val 3 R))
  %279 = call i64 @consStr(i64 %278)
; # (drop *Safe)
  %280 = inttoptr i64 %38 to i64*
  %281 = getelementptr i64, i64* %280, i32 1
  %282 = load i64, i64* %281
  %283 = inttoptr i64 ptrtoint (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 0) to i64) to i64*
  store i64 %282, i64* %283
  br label %$4
$4:
  %284 = phi i64 [%6, %$2], [%268, %$24] ; # Exe
  %285 = phi i64 [%7, %$2], [%269, %$24] ; # X
  %286 = phi i64 [%4, %$2], [%279, %$24] ; # ->
  ret i64 %286
}

define i64 @FD(i64) align 8 {
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
  %8 = phi i64 [%5, %$1] ; # X
  br label %$2
$3:
  %9 = phi i64 [%5, %$1] ; # X
  %10 = and i64 %9, 8
  %11 = icmp ne i64 %10, 0
  br i1 %11, label %$6, label %$5
$6:
  %12 = phi i64 [%9, %$3] ; # X
  %13 = inttoptr i64 %12 to i64*
  %14 = load i64, i64* %13
  br label %$2
$5:
  %15 = phi i64 [%9, %$3] ; # X
  %16 = call i64 @evList(i64 %15)
  br label %$2
$2:
  %17 = phi i64 [%8, %$4], [%12, %$6], [%15, %$5] ; # X
  %18 = phi i64 [%8, %$4], [%14, %$6], [%16, %$5] ; # ->
; # (when (ge0 (i32 (xCnt Exe @))) (initInFile @ null) (initOutFile @...
; # (xCnt Exe @)
  %19 = call i64 @xCnt(i64 %0, i64 %18)
; # (i32 (xCnt Exe @))
  %20 = trunc i64 %19 to i32
; # (ge0 (i32 (xCnt Exe @)))
  %21 = icmp sge i32 %20, 0
  br i1 %21, label %$7, label %$8
$7:
  %22 = phi i64 [%0, %$2] ; # Exe
; # (initInFile @ null)
  %23 = call i8* @initInFile(i32 %20, i8* null)
; # (initOutFile @)
  %24 = call i8* @initOutFile(i32 %20)
  br label %$8
$8:
  %25 = phi i64 [%0, %$2], [%22, %$7] ; # Exe
  ret i64 %18
}
@$Chr64 = constant [65 x i8] c"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/\00"
@$Stat64 = global i32 0
@$Next64 = global i32 0

define i64 @Base64(i64) align 8 {
$1:
; # (let X (cdr Exe) (cond ((atom X) (let C (val $Chr) (while (and (g...
; # (cdr Exe)
  %1 = inttoptr i64 %0 to i64*
  %2 = getelementptr i64, i64* %1, i32 1
  %3 = load i64, i64* %2
; # (cond ((atom X) (let C (val $Chr) (while (and (ge0 C) (>= (char "...
; # (atom X)
  %4 = and i64 %3, 15
  %5 = icmp ne i64 %4, 0
  br i1 %5, label %$4, label %$3
$4:
  %6 = phi i64 [%0, %$1] ; # Exe
  %7 = phi i64 [%3, %$1] ; # X
; # (let C (val $Chr) (while (and (ge0 C) (>= (char " ") C)) (setq C ...
; # (val $Chr)
  %8 = load i32, i32* bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 168) to i32*)
; # (while (and (ge0 C) (>= (char " ") C)) (setq C (call $Get)))
  br label %$5
$5:
  %9 = phi i64 [%6, %$4], [%21, %$8] ; # Exe
  %10 = phi i64 [%7, %$4], [%22, %$8] ; # X
  %11 = phi i32 [%8, %$4], [%25, %$8] ; # C
; # (and (ge0 C) (>= (char " ") C))
; # (ge0 C)
  %12 = icmp sge i32 %11, 0
  br i1 %12, label %$7, label %$6
$7:
  %13 = phi i64 [%9, %$5] ; # Exe
  %14 = phi i64 [%10, %$5] ; # X
  %15 = phi i32 [%11, %$5] ; # C
; # (>= (char " ") C)
  %16 = icmp sge i32 32, %15
  br label %$6
$6:
  %17 = phi i64 [%9, %$5], [%13, %$7] ; # Exe
  %18 = phi i64 [%10, %$5], [%14, %$7] ; # X
  %19 = phi i32 [%11, %$5], [%15, %$7] ; # C
  %20 = phi i1 [0, %$5], [%16, %$7] ; # ->
  br i1 %20, label %$8, label %$9
$8:
  %21 = phi i64 [%17, %$6] ; # Exe
  %22 = phi i64 [%18, %$6] ; # X
  %23 = phi i32 [%19, %$6] ; # C
; # (call $Get)
  %24 = load i32()*, i32()** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 96) to i32()**)
  %25 = call i32 %24()
  br label %$5
$9:
  %26 = phi i64 [%17, %$6] ; # Exe
  %27 = phi i64 [%18, %$6] ; # X
  %28 = phi i32 [%19, %$6] ; # C
; # (if (strchr $Chr64 C) (let N (i32 (- @ $Chr64)) (setq C (call $Ge...
; # (strchr $Chr64 C)
  %29 = call i8* @strchr(i8* bitcast ([65 x i8]* @$Chr64 to i8*), i32 %28)
  %30 = icmp ne i8* %29, null
  br i1 %30, label %$10, label %$11
$10:
  %31 = phi i64 [%26, %$9] ; # Exe
  %32 = phi i64 [%27, %$9] ; # X
  %33 = phi i32 [%28, %$9] ; # C
; # (let N (i32 (- @ $Chr64)) (setq C (call $Get)) (case (val $Stat64...
; # (- @ $Chr64)
  %34 = ptrtoint i8* %29 to i64
  %35 = ptrtoint i8* bitcast ([65 x i8]* @$Chr64 to i8*) to i64
  %36 = sub i64 %34, %35
; # (i32 (- @ $Chr64))
  %37 = trunc i64 %36 to i32
; # (call $Get)
  %38 = load i32()*, i32()** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 96) to i32()**)
  %39 = call i32 %38()
; # (case (val $Stat64) (0 (unless (strchr $Chr64 C) (set $Stat64 0) ...
; # (val $Stat64)
  %40 = load i32, i32* @$Stat64
  switch i32 %40, label %$13 [
    i32 0, label %$15
    i32 1, label %$16
  ]
$15:
  %41 = phi i64 [%31, %$10] ; # Exe
  %42 = phi i64 [%32, %$10] ; # X
  %43 = phi i32 [%39, %$10] ; # C
  %44 = phi i32 [%37, %$10] ; # N
; # (unless (strchr $Chr64 C) (set $Stat64 0) (ret $Nil))
; # (strchr $Chr64 C)
  %45 = call i8* @strchr(i8* bitcast ([65 x i8]* @$Chr64 to i8*), i32 %43)
  %46 = icmp ne i8* %45, null
  br i1 %46, label %$18, label %$17
$17:
  %47 = phi i64 [%41, %$15] ; # Exe
  %48 = phi i64 [%42, %$15] ; # X
  %49 = phi i32 [%43, %$15] ; # C
  %50 = phi i32 [%44, %$15] ; # N
; # (set $Stat64 0)
  store i32 0, i32* @$Stat64
; # (ret $Nil)
  ret i64 ptrtoint (i8* getelementptr (i8, i8* bitcast ([896 x i64]* @SymTab to i8*), i32 8) to i64)
$18:
  %51 = phi i64 [%41, %$15] ; # Exe
  %52 = phi i64 [%42, %$15] ; # X
  %53 = phi i32 [%43, %$15] ; # C
  %54 = phi i32 [%44, %$15] ; # N
; # (set $Next64 (i32 (- @ $Chr64)))
; # (- @ $Chr64)
  %55 = ptrtoint i8* %45 to i64
  %56 = ptrtoint i8* bitcast ([65 x i8]* @$Chr64 to i8*) to i64
  %57 = sub i64 %55, %56
; # (i32 (- @ $Chr64))
  %58 = trunc i64 %57 to i32
  store i32 %58, i32* @$Next64
; # (call $Get)
  %59 = load i32()*, i32()** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 96) to i32()**)
  %60 = call i32 %59()
; # (set $Stat64 (inc (val $Stat64)))
; # (val $Stat64)
  %61 = load i32, i32* @$Stat64
; # (inc (val $Stat64))
  %62 = add i32 %61, 1
  store i32 %62, i32* @$Stat64
; # (shl N 2)
  %63 = shl i32 %54, 2
; # (val $Next64)
  %64 = load i32, i32* @$Next64
; # (shr (val $Next64) 4)
  %65 = lshr i32 %64, 4
; # (| (shl N 2) (shr (val $Next64) 4))
  %66 = or i32 %63, %65
; # (i64 (| (shl N 2) (shr (val $Next64) 4)))
  %67 = sext i32 %66 to i64
; # (cnt (i64 (| (shl N 2) (shr (val $Next64) 4))))
  %68 = shl i64 %67, 4
  %69 = or i64 %68, 2
  br label %$14
$16:
  %70 = phi i64 [%31, %$10] ; # Exe
  %71 = phi i64 [%32, %$10] ; # X
  %72 = phi i32 [%39, %$10] ; # C
  %73 = phi i32 [%37, %$10] ; # N
; # (prog1 (cnt (i64 (| (shl (& (val $Next64) 15) 4) (shr N 2)))) (se...
; # (val $Next64)
  %74 = load i32, i32* @$Next64
; # (& (val $Next64) 15)
  %75 = and i32 %74, 15
; # (shl (& (val $Next64) 15) 4)
  %76 = shl i32 %75, 4
; # (shr N 2)
  %77 = lshr i32 %73, 2
; # (| (shl (& (val $Next64) 15) 4) (shr N 2))
  %78 = or i32 %76, %77
; # (i64 (| (shl (& (val $Next64) 15) 4) (shr N 2)))
  %79 = sext i32 %78 to i64
; # (cnt (i64 (| (shl (& (val $Next64) 15) 4) (shr N 2))))
  %80 = shl i64 %79, 4
  %81 = or i64 %80, 2
; # (set $Next64 N $Stat64 (inc (val $Stat64)))
  store i32 %73, i32* @$Next64
; # (val $Stat64)
  %82 = load i32, i32* @$Stat64
; # (inc (val $Stat64))
  %83 = add i32 %82, 1
  store i32 %83, i32* @$Stat64
  br label %$14
$13:
  %84 = phi i64 [%31, %$10] ; # Exe
  %85 = phi i64 [%32, %$10] ; # X
  %86 = phi i32 [%39, %$10] ; # C
  %87 = phi i32 [%37, %$10] ; # N
; # (set $Stat64 0)
  store i32 0, i32* @$Stat64
; # (val $Next64)
  %88 = load i32, i32* @$Next64
; # (& (val $Next64) 3)
  %89 = and i32 %88, 3
; # (shl (& (val $Next64) 3) 6)
  %90 = shl i32 %89, 6
; # (| (shl (& (val $Next64) 3) 6) N)
  %91 = or i32 %90, %87
; # (i64 (| (shl (& (val $Next64) 3) 6) N))
  %92 = sext i32 %91 to i64
; # (cnt (i64 (| (shl (& (val $Next64) 3) 6) N)))
  %93 = shl i64 %92, 4
  %94 = or i64 %93, 2
  br label %$14
$14:
  %95 = phi i64 [%51, %$18], [%70, %$16], [%84, %$13] ; # Exe
  %96 = phi i64 [%52, %$18], [%71, %$16], [%85, %$13] ; # X
  %97 = phi i32 [%53, %$18], [%72, %$16], [%86, %$13] ; # C
  %98 = phi i32 [%54, %$18], [%73, %$16], [%87, %$13] ; # N
  %99 = phi i64 [%69, %$18], [%81, %$16], [%94, %$13] ; # ->
  br label %$12
$11:
  %100 = phi i64 [%26, %$9] ; # Exe
  %101 = phi i64 [%27, %$9] ; # X
  %102 = phi i32 [%28, %$9] ; # C
; # (when (== C (char "=")) (call $Get) (when (== (val $Stat64) 1) (c...
; # (== C (char "="))
  %103 = icmp eq i32 %102, 61
  br i1 %103, label %$19, label %$20
$19:
  %104 = phi i64 [%100, %$11] ; # Exe
  %105 = phi i64 [%101, %$11] ; # X
  %106 = phi i32 [%102, %$11] ; # C
; # (call $Get)
  %107 = load i32()*, i32()** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 96) to i32()**)
  %108 = call i32 %107()
; # (when (== (val $Stat64) 1) (call $Get))
; # (val $Stat64)
  %109 = load i32, i32* @$Stat64
; # (== (val $Stat64) 1)
  %110 = icmp eq i32 %109, 1
  br i1 %110, label %$21, label %$22
$21:
  %111 = phi i64 [%104, %$19] ; # Exe
  %112 = phi i64 [%105, %$19] ; # X
  %113 = phi i32 [%106, %$19] ; # C
; # (call $Get)
  %114 = load i32()*, i32()** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 96) to i32()**)
  %115 = call i32 %114()
  br label %$22
$22:
  %116 = phi i64 [%104, %$19], [%111, %$21] ; # Exe
  %117 = phi i64 [%105, %$19], [%112, %$21] ; # X
  %118 = phi i32 [%106, %$19], [%113, %$21] ; # C
  br label %$20
$20:
  %119 = phi i64 [%100, %$11], [%116, %$22] ; # Exe
  %120 = phi i64 [%101, %$11], [%117, %$22] ; # X
  %121 = phi i32 [%102, %$11], [%118, %$22] ; # C
; # (set $Stat64 0)
  store i32 0, i32* @$Stat64
  br label %$12
$12:
  %122 = phi i64 [%95, %$14], [%119, %$20] ; # Exe
  %123 = phi i64 [%96, %$14], [%120, %$20] ; # X
  %124 = phi i32 [%97, %$14], [%121, %$20] ; # C
  %125 = phi i64 [%99, %$14], [ptrtoint (i8* getelementptr (i8, i8* bitcast ([896 x i64]* @SymTab to i8*), i32 8) to i64), %$20] ; # ->
  br label %$2
$3:
  %126 = phi i64 [%0, %$1] ; # Exe
  %127 = phi i64 [%3, %$1] ; # X
; # (car X)
  %128 = inttoptr i64 %127 to i64*
  %129 = load i64, i64* %128
; # (eval (car X))
  %130 = and i64 %129, 6
  %131 = icmp ne i64 %130, 0
  br i1 %131, label %$25, label %$24
$25:
  %132 = phi i64 [%129, %$3] ; # X
  br label %$23
$24:
  %133 = phi i64 [%129, %$3] ; # X
  %134 = and i64 %133, 8
  %135 = icmp ne i64 %134, 0
  br i1 %135, label %$27, label %$26
$27:
  %136 = phi i64 [%133, %$24] ; # X
  %137 = inttoptr i64 %136 to i64*
  %138 = load i64, i64* %137
  br label %$23
$26:
  %139 = phi i64 [%133, %$24] ; # X
  %140 = call i64 @evList(i64 %139)
  br label %$23
$23:
  %141 = phi i64 [%132, %$25], [%136, %$27], [%139, %$26] ; # X
  %142 = phi i64 [%132, %$25], [%138, %$27], [%140, %$26] ; # ->
; # (nil? (eval (car X)))
  %143 = icmp eq i64 %142, ptrtoint (i8* getelementptr (i8, i8* bitcast ([896 x i64]* @SymTab to i8*), i32 8) to i64)
  br i1 %143, label %$29, label %$28
$29:
  %144 = phi i64 [%126, %$23] ; # Exe
  %145 = phi i64 [%127, %$23] ; # X
  br label %$2
$28:
  %146 = phi i64 [%126, %$23] ; # Exe
  %147 = phi i64 [%127, %$23] ; # X
; # (let N (xCnt Exe @) (call $Put (val (ofs $Chr64 (shr N 2)))) (whe...
; # (xCnt Exe @)
  %148 = call i64 @xCnt(i64 %146, i64 %142)
; # (shr N 2)
  %149 = lshr i64 %148, 2
; # (ofs $Chr64 (shr N 2))
  %150 = getelementptr i8, i8* bitcast ([65 x i8]* @$Chr64 to i8*), i64 %149
; # (val (ofs $Chr64 (shr N 2)))
  %151 = load i8, i8* %150
; # (call $Put (val (ofs $Chr64 (shr N 2))))
  %152 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**)
  call void %152(i8 %151)
; # (when (nil? (eval (car (shift X)))) (call $Put (val (ofs $Chr64 (...
; # (shift X)
  %153 = inttoptr i64 %147 to i64*
  %154 = getelementptr i64, i64* %153, i32 1
  %155 = load i64, i64* %154
; # (car (shift X))
  %156 = inttoptr i64 %155 to i64*
  %157 = load i64, i64* %156
; # (eval (car (shift X)))
  %158 = and i64 %157, 6
  %159 = icmp ne i64 %158, 0
  br i1 %159, label %$32, label %$31
$32:
  %160 = phi i64 [%157, %$28] ; # X
  br label %$30
$31:
  %161 = phi i64 [%157, %$28] ; # X
  %162 = and i64 %161, 8
  %163 = icmp ne i64 %162, 0
  br i1 %163, label %$34, label %$33
$34:
  %164 = phi i64 [%161, %$31] ; # X
  %165 = inttoptr i64 %164 to i64*
  %166 = load i64, i64* %165
  br label %$30
$33:
  %167 = phi i64 [%161, %$31] ; # X
  %168 = call i64 @evList(i64 %167)
  br label %$30
$30:
  %169 = phi i64 [%160, %$32], [%164, %$34], [%167, %$33] ; # X
  %170 = phi i64 [%160, %$32], [%166, %$34], [%168, %$33] ; # ->
; # (nil? (eval (car (shift X))))
  %171 = icmp eq i64 %170, ptrtoint (i8* getelementptr (i8, i8* bitcast ([896 x i64]* @SymTab to i8*), i32 8) to i64)
  br i1 %171, label %$35, label %$36
$35:
  %172 = phi i64 [%146, %$30] ; # Exe
  %173 = phi i64 [%155, %$30] ; # X
  %174 = phi i64 [%148, %$30] ; # N
; # (& N 3)
  %175 = and i64 %174, 3
; # (shl (& N 3) 4)
  %176 = shl i64 %175, 4
; # (ofs $Chr64 (shl (& N 3) 4))
  %177 = getelementptr i8, i8* bitcast ([65 x i8]* @$Chr64 to i8*), i64 %176
; # (val (ofs $Chr64 (shl (& N 3) 4)))
  %178 = load i8, i8* %177
; # (call $Put (val (ofs $Chr64 (shl (& N 3) 4))))
  %179 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**)
  call void %179(i8 %178)
; # (call $Put (char "="))
  %180 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**)
  call void %180(i8 61)
; # (call $Put (char "="))
  %181 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**)
  call void %181(i8 61)
; # (ret $Nil)
  ret i64 ptrtoint (i8* getelementptr (i8, i8* bitcast ([896 x i64]* @SymTab to i8*), i32 8) to i64)
$36:
  %182 = phi i64 [%146, %$30] ; # Exe
  %183 = phi i64 [%155, %$30] ; # X
  %184 = phi i64 [%148, %$30] ; # N
; # (let M (xCnt Exe @) (call $Put (val (ofs $Chr64 (| (shl (& N 3) 4...
; # (xCnt Exe @)
  %185 = call i64 @xCnt(i64 %182, i64 %170)
; # (& N 3)
  %186 = and i64 %184, 3
; # (shl (& N 3) 4)
  %187 = shl i64 %186, 4
; # (shr M 4)
  %188 = lshr i64 %185, 4
; # (| (shl (& N 3) 4) (shr M 4))
  %189 = or i64 %187, %188
; # (ofs $Chr64 (| (shl (& N 3) 4) (shr M 4)))
  %190 = getelementptr i8, i8* bitcast ([65 x i8]* @$Chr64 to i8*), i64 %189
; # (val (ofs $Chr64 (| (shl (& N 3) 4) (shr M 4))))
  %191 = load i8, i8* %190
; # (call $Put (val (ofs $Chr64 (| (shl (& N 3) 4) (shr M 4)))))
  %192 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**)
  call void %192(i8 %191)
; # (when (nil? (eval (cadr X))) (call $Put (val (ofs $Chr64 (shl (& ...
; # (cadr X)
  %193 = inttoptr i64 %183 to i64*
  %194 = getelementptr i64, i64* %193, i32 1
  %195 = load i64, i64* %194
  %196 = inttoptr i64 %195 to i64*
  %197 = load i64, i64* %196
; # (eval (cadr X))
  %198 = and i64 %197, 6
  %199 = icmp ne i64 %198, 0
  br i1 %199, label %$39, label %$38
$39:
  %200 = phi i64 [%197, %$36] ; # X
  br label %$37
$38:
  %201 = phi i64 [%197, %$36] ; # X
  %202 = and i64 %201, 8
  %203 = icmp ne i64 %202, 0
  br i1 %203, label %$41, label %$40
$41:
  %204 = phi i64 [%201, %$38] ; # X
  %205 = inttoptr i64 %204 to i64*
  %206 = load i64, i64* %205
  br label %$37
$40:
  %207 = phi i64 [%201, %$38] ; # X
  %208 = call i64 @evList(i64 %207)
  br label %$37
$37:
  %209 = phi i64 [%200, %$39], [%204, %$41], [%207, %$40] ; # X
  %210 = phi i64 [%200, %$39], [%206, %$41], [%208, %$40] ; # ->
; # (nil? (eval (cadr X)))
  %211 = icmp eq i64 %210, ptrtoint (i8* getelementptr (i8, i8* bitcast ([896 x i64]* @SymTab to i8*), i32 8) to i64)
  br i1 %211, label %$42, label %$43
$42:
  %212 = phi i64 [%182, %$37] ; # Exe
  %213 = phi i64 [%183, %$37] ; # X
  %214 = phi i64 [%184, %$37] ; # N
  %215 = phi i64 [%185, %$37] ; # M
; # (& M 15)
  %216 = and i64 %215, 15
; # (shl (& M 15) 2)
  %217 = shl i64 %216, 2
; # (ofs $Chr64 (shl (& M 15) 2))
  %218 = getelementptr i8, i8* bitcast ([65 x i8]* @$Chr64 to i8*), i64 %217
; # (val (ofs $Chr64 (shl (& M 15) 2)))
  %219 = load i8, i8* %218
; # (call $Put (val (ofs $Chr64 (shl (& M 15) 2))))
  %220 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**)
  call void %220(i8 %219)
; # (call $Put (char "="))
  %221 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**)
  call void %221(i8 61)
; # (ret $Nil)
  ret i64 ptrtoint (i8* getelementptr (i8, i8* bitcast ([896 x i64]* @SymTab to i8*), i32 8) to i64)
$43:
  %222 = phi i64 [%182, %$37] ; # Exe
  %223 = phi i64 [%183, %$37] ; # X
  %224 = phi i64 [%184, %$37] ; # N
  %225 = phi i64 [%185, %$37] ; # M
; # (xCnt Exe @)
  %226 = call i64 @xCnt(i64 %222, i64 %210)
; # (& M 15)
  %227 = and i64 %225, 15
; # (shl (& M 15) 2)
  %228 = shl i64 %227, 2
; # (shr N 6)
  %229 = lshr i64 %226, 6
; # (| (shl (& M 15) 2) (shr N 6))
  %230 = or i64 %228, %229
; # (ofs $Chr64 (| (shl (& M 15) 2) (shr N 6)))
  %231 = getelementptr i8, i8* bitcast ([65 x i8]* @$Chr64 to i8*), i64 %230
; # (val (ofs $Chr64 (| (shl (& M 15) 2) (shr N 6))))
  %232 = load i8, i8* %231
; # (call $Put (val (ofs $Chr64 (| (shl (& M 15) 2) (shr N 6)))))
  %233 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**)
  call void %233(i8 %232)
; # (& N 63)
  %234 = and i64 %226, 63
; # (ofs $Chr64 (& N 63))
  %235 = getelementptr i8, i8* bitcast ([65 x i8]* @$Chr64 to i8*), i64 %234
; # (val (ofs $Chr64 (& N 63)))
  %236 = load i8, i8* %235
; # (call $Put (val (ofs $Chr64 (& N 63))))
  %237 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**)
  call void %237(i8 %236)
  br label %$2
$2:
  %238 = phi i64 [%122, %$12], [%144, %$29], [%222, %$43] ; # Exe
  %239 = phi i64 [%123, %$12], [%145, %$29], [%223, %$43] ; # X
  %240 = phi i64 [%125, %$12], [%142, %$29], [ptrtoint (i8* getelementptr (i8, i8* bitcast ([896 x i64]* @SymTab to i8*), i32 280) to i64), %$43] ; # ->
  ret i64 %240
}

