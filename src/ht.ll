source_filename = "ht.l"

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
@SymTab = external global [892 x i64]
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
declare void @bufFloat(i64, i64, i8*)
declare void @bufDouble(i64, i64, i8*)
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
declare void @prin(i64)
declare i8 @symByte(i64*)
declare void @prExt(i64)
declare void @begString(i64*)
declare void @tglString(i64*)
declare i64 @endString()
declare i1 @findSym(i64, i64, i64)
declare void @prSym(i64)
declare i64 @mkChar(i32)
declare i64 @evCnt(i64, i64)
declare i32 @getChar(i32)

define i64 @Prin(i64) align 8 {
$1:
; # (let X (cdr Exe) (loop (let Y (eval (car X)) (unless (nil? Y) (if...
; # (cdr Exe)
  %1 = inttoptr i64 %0 to i64*
  %2 = getelementptr i64, i64* %1, i32 1
  %3 = load i64, i64* %2
; # (loop (let Y (eval (car X)) (unless (nil? Y) (if (or (num? Y) (pa...
  br label %$2
$2:
  %4 = phi i64 [%0, %$1], [%166, %$35] ; # Exe
  %5 = phi i64 [%3, %$1], [%167, %$35] ; # X
; # (let Y (eval (car X)) (unless (nil? Y) (if (or (num? Y) (pair Y) ...
; # (car X)
  %6 = inttoptr i64 %5 to i64*
  %7 = load i64, i64* %6
; # (eval (car X))
  %8 = and i64 %7, 6
  %9 = icmp ne i64 %8, 0
  br i1 %9, label %$5, label %$4
$5:
  %10 = phi i64 [%7, %$2] ; # X
  br label %$3
$4:
  %11 = phi i64 [%7, %$2] ; # X
  %12 = and i64 %11, 8
  %13 = icmp ne i64 %12, 0
  br i1 %13, label %$7, label %$6
$7:
  %14 = phi i64 [%11, %$4] ; # X
  %15 = inttoptr i64 %14 to i64*
  %16 = load i64, i64* %15
  br label %$3
$6:
  %17 = phi i64 [%11, %$4] ; # X
  %18 = call i64 @evList(i64 %17)
  br label %$3
$3:
  %19 = phi i64 [%10, %$5], [%14, %$7], [%17, %$6] ; # X
  %20 = phi i64 [%10, %$5], [%16, %$7], [%18, %$6] ; # ->
; # (unless (nil? Y) (if (or (num? Y) (pair Y) (sym? (val (tail Y))))...
; # (nil? Y)
  %21 = icmp eq i64 %20, ptrtoint (i8* getelementptr (i8, i8* bitcast ([892 x i64]* @SymTab to i8*), i32 8) to i64)
  br i1 %21, label %$9, label %$8
$8:
  %22 = phi i64 [%4, %$3] ; # Exe
  %23 = phi i64 [%5, %$3] ; # X
  %24 = phi i64 [%20, %$3] ; # Y
; # (if (or (num? Y) (pair Y) (sym? (val (tail Y)))) (prin Y) (let P ...
; # (or (num? Y) (pair Y) (sym? (val (tail Y))))
; # (num? Y)
  %25 = and i64 %24, 6
  %26 = icmp ne i64 %25, 0
  br i1 %26, label %$10, label %$11
$11:
  %27 = phi i64 [%22, %$8] ; # Exe
  %28 = phi i64 [%23, %$8] ; # X
  %29 = phi i64 [%24, %$8] ; # Y
; # (pair Y)
  %30 = and i64 %29, 15
  %31 = icmp eq i64 %30, 0
  br i1 %31, label %$10, label %$12
$12:
  %32 = phi i64 [%27, %$11] ; # Exe
  %33 = phi i64 [%28, %$11] ; # X
  %34 = phi i64 [%29, %$11] ; # Y
; # (tail Y)
  %35 = add i64 %34, -8
; # (val (tail Y))
  %36 = inttoptr i64 %35 to i64*
  %37 = load i64, i64* %36
; # (sym? (val (tail Y)))
  %38 = and i64 %37, 8
  %39 = icmp ne i64 %38, 0
  br label %$10
$10:
  %40 = phi i64 [%22, %$8], [%27, %$11], [%32, %$12] ; # Exe
  %41 = phi i64 [%23, %$8], [%28, %$11], [%33, %$12] ; # X
  %42 = phi i64 [%24, %$8], [%29, %$11], [%34, %$12] ; # Y
  %43 = phi i1 [1, %$8], [1, %$11], [%39, %$12] ; # ->
  br i1 %43, label %$13, label %$14
$13:
  %44 = phi i64 [%40, %$10] ; # Exe
  %45 = phi i64 [%41, %$10] ; # X
  %46 = phi i64 [%42, %$10] ; # Y
; # (prin Y)
  call void @prin(i64 %46)
  br label %$15
$14:
  %47 = phi i64 [%40, %$10] ; # Exe
  %48 = phi i64 [%41, %$10] ; # X
  %49 = phi i64 [%42, %$10] ; # Y
; # (let P (push 0 (name (val (tail Y)))) (while (symByte P) (case @ ...
; # (tail Y)
  %50 = add i64 %49, -8
; # (val (tail Y))
  %51 = inttoptr i64 %50 to i64*
  %52 = load i64, i64* %51
; # (name (val (tail Y)))
  br label %$16
$16:
  %53 = phi i64 [%52, %$14], [%59, %$17] ; # Tail
  %54 = and i64 %53, 6
  %55 = icmp ne i64 %54, 0
  br i1 %55, label %$18, label %$17
$17:
  %56 = phi i64 [%53, %$16] ; # Tail
  %57 = inttoptr i64 %56 to i64*
  %58 = getelementptr i64, i64* %57, i32 1
  %59 = load i64, i64* %58
  br label %$16
$18:
  %60 = phi i64 [%53, %$16] ; # Tail
; # (push 0 (name (val (tail Y))))
  %61 = alloca i64, i64 2, align 16
  store i64 0, i64* %61
  %62 = getelementptr i64, i64* %61, i32 1
  store i64 %60, i64* %62
; # (while (symByte P) (case @ ((char "<") (outString ($ "&lt;"))) ((...
  br label %$19
$19:
  %63 = phi i64 [%47, %$18], [%144, %$23] ; # Exe
  %64 = phi i64 [%48, %$18], [%145, %$23] ; # X
  %65 = phi i64 [%49, %$18], [%146, %$23] ; # Y
  %66 = phi i64* [%61, %$18], [%147, %$23] ; # P
; # (symByte P)
  %67 = call i8 @symByte(i64* %66)
  %68 = icmp ne i8 %67, 0
  br i1 %68, label %$20, label %$21
$20:
  %69 = phi i64 [%63, %$19] ; # Exe
  %70 = phi i64 [%64, %$19] ; # X
  %71 = phi i64 [%65, %$19] ; # Y
  %72 = phi i64* [%66, %$19] ; # P
; # (case @ ((char "<") (outString ($ "&lt;"))) ((char ">") (outStrin...
  switch i8 %67, label %$22 [
    i8 60, label %$24
    i8 62, label %$25
    i8 38, label %$26
    i8 34, label %$27
    i8 255, label %$28
  ]
$24:
  %73 = phi i64 [%69, %$20] ; # Exe
  %74 = phi i64 [%70, %$20] ; # X
  %75 = phi i64 [%71, %$20] ; # Y
  %76 = phi i64* [%72, %$20] ; # P
; # (outString ($ "&lt;"))
  call void @outString(i8* bitcast ([5 x i8]* @$1 to i8*))
  br label %$23
$25:
  %77 = phi i64 [%69, %$20] ; # Exe
  %78 = phi i64 [%70, %$20] ; # X
  %79 = phi i64 [%71, %$20] ; # Y
  %80 = phi i64* [%72, %$20] ; # P
; # (outString ($ "&gt;"))
  call void @outString(i8* bitcast ([5 x i8]* @$2 to i8*))
  br label %$23
$26:
  %81 = phi i64 [%69, %$20] ; # Exe
  %82 = phi i64 [%70, %$20] ; # X
  %83 = phi i64 [%71, %$20] ; # Y
  %84 = phi i64* [%72, %$20] ; # P
; # (outString ($ "&amp;"))
  call void @outString(i8* bitcast ([6 x i8]* @$3 to i8*))
  br label %$23
$27:
  %85 = phi i64 [%69, %$20] ; # Exe
  %86 = phi i64 [%70, %$20] ; # X
  %87 = phi i64 [%71, %$20] ; # Y
  %88 = phi i64* [%72, %$20] ; # P
; # (outString ($ "&quot;"))
  call void @outString(i8* bitcast ([7 x i8]* @$4 to i8*))
  br label %$23
$28:
  %89 = phi i64 [%69, %$20] ; # Exe
  %90 = phi i64 [%70, %$20] ; # X
  %91 = phi i64 [%71, %$20] ; # Y
  %92 = phi i64* [%72, %$20] ; # P
; # (call $Put (hex "F7"))
  %93 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**)
  call void %93(i8 247)
; # (call $Put (hex "BF"))
  %94 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**)
  call void %94(i8 191)
; # (call $Put (hex "BF"))
  %95 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**)
  call void %95(i8 191)
; # (call $Put (hex "BF"))
  %96 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**)
  call void %96(i8 191)
  br label %$23
$22:
  %97 = phi i64 [%69, %$20] ; # Exe
  %98 = phi i64 [%70, %$20] ; # X
  %99 = phi i64 [%71, %$20] ; # Y
  %100 = phi i64* [%72, %$20] ; # P
; # (let B @ (call $Put B) (when (& B (hex "80")) (call $Put (symByte...
; # (call $Put B)
  %101 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**)
  call void %101(i8 %67)
; # (when (& B (hex "80")) (call $Put (symByte P)) (when (& B (hex "2...
; # (& B (hex "80"))
  %102 = and i8 %67, 128
  %103 = icmp ne i8 %102, 0
  br i1 %103, label %$29, label %$30
$29:
  %104 = phi i64 [%97, %$22] ; # Exe
  %105 = phi i64 [%98, %$22] ; # X
  %106 = phi i64 [%99, %$22] ; # Y
  %107 = phi i64* [%100, %$22] ; # P
  %108 = phi i8 [%67, %$22] ; # B
; # (symByte P)
  %109 = call i8 @symByte(i64* %107)
; # (call $Put (symByte P))
  %110 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**)
  call void %110(i8 %109)
; # (when (& B (hex "20")) (call $Put (symByte P)) (when (& B (hex "1...
; # (& B (hex "20"))
  %111 = and i8 %108, 32
  %112 = icmp ne i8 %111, 0
  br i1 %112, label %$31, label %$32
$31:
  %113 = phi i64 [%104, %$29] ; # Exe
  %114 = phi i64 [%105, %$29] ; # X
  %115 = phi i64 [%106, %$29] ; # Y
  %116 = phi i64* [%107, %$29] ; # P
  %117 = phi i8 [%108, %$29] ; # B
; # (symByte P)
  %118 = call i8 @symByte(i64* %116)
; # (call $Put (symByte P))
  %119 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**)
  call void %119(i8 %118)
; # (when (& B (hex "10")) (call $Put (symByte P)))
; # (& B (hex "10"))
  %120 = and i8 %117, 16
  %121 = icmp ne i8 %120, 0
  br i1 %121, label %$33, label %$34
$33:
  %122 = phi i64 [%113, %$31] ; # Exe
  %123 = phi i64 [%114, %$31] ; # X
  %124 = phi i64 [%115, %$31] ; # Y
  %125 = phi i64* [%116, %$31] ; # P
  %126 = phi i8 [%117, %$31] ; # B
; # (symByte P)
  %127 = call i8 @symByte(i64* %125)
; # (call $Put (symByte P))
  %128 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**)
  call void %128(i8 %127)
  br label %$34
$34:
  %129 = phi i64 [%113, %$31], [%122, %$33] ; # Exe
  %130 = phi i64 [%114, %$31], [%123, %$33] ; # X
  %131 = phi i64 [%115, %$31], [%124, %$33] ; # Y
  %132 = phi i64* [%116, %$31], [%125, %$33] ; # P
  %133 = phi i8 [%117, %$31], [%126, %$33] ; # B
  br label %$32
$32:
  %134 = phi i64 [%104, %$29], [%129, %$34] ; # Exe
  %135 = phi i64 [%105, %$29], [%130, %$34] ; # X
  %136 = phi i64 [%106, %$29], [%131, %$34] ; # Y
  %137 = phi i64* [%107, %$29], [%132, %$34] ; # P
  %138 = phi i8 [%108, %$29], [%133, %$34] ; # B
  br label %$30
$30:
  %139 = phi i64 [%97, %$22], [%134, %$32] ; # Exe
  %140 = phi i64 [%98, %$22], [%135, %$32] ; # X
  %141 = phi i64 [%99, %$22], [%136, %$32] ; # Y
  %142 = phi i64* [%100, %$22], [%137, %$32] ; # P
  %143 = phi i8 [%67, %$22], [%138, %$32] ; # B
  br label %$23
$23:
  %144 = phi i64 [%73, %$24], [%77, %$25], [%81, %$26], [%85, %$27], [%89, %$28], [%139, %$30] ; # Exe
  %145 = phi i64 [%74, %$24], [%78, %$25], [%82, %$26], [%86, %$27], [%90, %$28], [%140, %$30] ; # X
  %146 = phi i64 [%75, %$24], [%79, %$25], [%83, %$26], [%87, %$27], [%91, %$28], [%141, %$30] ; # Y
  %147 = phi i64* [%76, %$24], [%80, %$25], [%84, %$26], [%88, %$27], [%92, %$28], [%142, %$30] ; # P
  br label %$19
$21:
  %148 = phi i64 [%63, %$19] ; # Exe
  %149 = phi i64 [%64, %$19] ; # X
  %150 = phi i64 [%65, %$19] ; # Y
  %151 = phi i64* [%66, %$19] ; # P
  br label %$15
$15:
  %152 = phi i64 [%44, %$13], [%148, %$21] ; # Exe
  %153 = phi i64 [%45, %$13], [%149, %$21] ; # X
  %154 = phi i64 [%46, %$13], [%150, %$21] ; # Y
  br label %$9
$9:
  %155 = phi i64 [%4, %$3], [%152, %$15] ; # Exe
  %156 = phi i64 [%5, %$3], [%153, %$15] ; # X
  %157 = phi i64 [%20, %$3], [%154, %$15] ; # Y
; # (? (atom (shift X)) Y)
; # (shift X)
  %158 = inttoptr i64 %156 to i64*
  %159 = getelementptr i64, i64* %158, i32 1
  %160 = load i64, i64* %159
; # (atom (shift X))
  %161 = and i64 %160, 15
  %162 = icmp ne i64 %161, 0
  br i1 %162, label %$37, label %$35
$37:
  %163 = phi i64 [%155, %$9] ; # Exe
  %164 = phi i64 [%160, %$9] ; # X
  %165 = phi i64 [%157, %$9] ; # Y
  br label %$36
$35:
  %166 = phi i64 [%155, %$9] ; # Exe
  %167 = phi i64 [%160, %$9] ; # X
  %168 = phi i64 [%157, %$9] ; # Y
  br label %$2
$36:
  %169 = phi i64 [%163, %$37] ; # Exe
  %170 = phi i64 [%164, %$37] ; # X
  %171 = phi i64 [%165, %$37] ; # ->
  ret i64 %171
}

define void @putHex(i8) align 8 {
$1:
; # (call $Put (char "%"))
  %1 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**)
  call void %1(i8 37)
; # (if (> (& (shr B 4) 15) 9) (+ @ 7) @)
; # (shr B 4)
  %2 = lshr i8 %0, 4
; # (& (shr B 4) 15)
  %3 = and i8 %2, 15
; # (> (& (shr B 4) 15) 9)
  %4 = icmp ugt i8 %3, 9
  br i1 %4, label %$2, label %$3
$2:
  %5 = phi i8 [%0, %$1] ; # B
; # (+ @ 7)
  %6 = add i8 %3, 7
  br label %$4
$3:
  %7 = phi i8 [%0, %$1] ; # B
  br label %$4
$4:
  %8 = phi i8 [%5, %$2], [%7, %$3] ; # B
  %9 = phi i8 [%6, %$2], [%3, %$3] ; # ->
; # (+ (if (> (& (shr B 4) 15) 9) (+ @ 7) @) (char "0"))
  %10 = add i8 %9, 48
; # (call $Put (+ (if (> (& (shr B 4) 15) 9) (+ @ 7) @) (char "0")))
  %11 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**)
  call void %11(i8 %10)
; # (if (> (& B 15) 9) (+ @ 7) @)
; # (& B 15)
  %12 = and i8 %8, 15
; # (> (& B 15) 9)
  %13 = icmp ugt i8 %12, 9
  br i1 %13, label %$5, label %$6
$5:
  %14 = phi i8 [%8, %$4] ; # B
; # (+ @ 7)
  %15 = add i8 %12, 7
  br label %$7
$6:
  %16 = phi i8 [%8, %$4] ; # B
  br label %$7
$7:
  %17 = phi i8 [%14, %$5], [%16, %$6] ; # B
  %18 = phi i8 [%15, %$5], [%12, %$6] ; # ->
; # (+ (if (> (& B 15) 9) (+ @ 7) @) (char "0"))
  %19 = add i8 %18, 48
; # (call $Put (+ (if (> (& B 15) 9) (+ @ 7) @) (char "0")))
  %20 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**)
  call void %20(i8 %19)
  ret void
}

define void @htEncode(i8, i64*) align 8 {
$1:
; # (while B (if (strchr ($ " \"#%&:;<=>?\\_") (i32 B)) (putHex B) (c...
  br label %$2
$2:
  %2 = phi i8 [%0, %$1], [%41, %$7] ; # B
  %3 = phi i64* [%1, %$1], [%40, %$7] ; # P
  %4 = icmp ne i8 %2, 0
  br i1 %4, label %$3, label %$4
$3:
  %5 = phi i8 [%2, %$2] ; # B
  %6 = phi i64* [%3, %$2] ; # P
; # (if (strchr ($ " \"#%&:;<=>?\\_") (i32 B)) (putHex B) (call $Put ...
; # (i32 B)
  %7 = zext i8 %5 to i32
; # (strchr ($ " \"#%&:;<=>?\\_") (i32 B))
  %8 = call i8* @strchr(i8* bitcast ([14 x i8]* @$5 to i8*), i32 %7)
  %9 = icmp ne i8* %8, null
  br i1 %9, label %$5, label %$6
$5:
  %10 = phi i8 [%5, %$3] ; # B
  %11 = phi i64* [%6, %$3] ; # P
; # (putHex B)
  call void @putHex(i8 %10)
  br label %$7
$6:
  %12 = phi i8 [%5, %$3] ; # B
  %13 = phi i64* [%6, %$3] ; # P
; # (call $Put B)
  %14 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**)
  call void %14(i8 %12)
; # (when (& B (hex "80")) (call $Put (symByte P)) (when (& B (hex "2...
; # (& B (hex "80"))
  %15 = and i8 %12, 128
  %16 = icmp ne i8 %15, 0
  br i1 %16, label %$8, label %$9
$8:
  %17 = phi i8 [%12, %$6] ; # B
  %18 = phi i64* [%13, %$6] ; # P
; # (symByte P)
  %19 = call i8 @symByte(i64* %18)
; # (call $Put (symByte P))
  %20 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**)
  call void %20(i8 %19)
; # (when (& B (hex "20")) (call $Put (symByte P)) (when (& B (hex "1...
; # (& B (hex "20"))
  %21 = and i8 %17, 32
  %22 = icmp ne i8 %21, 0
  br i1 %22, label %$10, label %$11
$10:
  %23 = phi i8 [%17, %$8] ; # B
  %24 = phi i64* [%18, %$8] ; # P
; # (symByte P)
  %25 = call i8 @symByte(i64* %24)
; # (call $Put (symByte P))
  %26 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**)
  call void %26(i8 %25)
; # (when (& B (hex "10")) (call $Put (symByte P)))
; # (& B (hex "10"))
  %27 = and i8 %23, 16
  %28 = icmp ne i8 %27, 0
  br i1 %28, label %$12, label %$13
$12:
  %29 = phi i8 [%23, %$10] ; # B
  %30 = phi i64* [%24, %$10] ; # P
; # (symByte P)
  %31 = call i8 @symByte(i64* %30)
; # (call $Put (symByte P))
  %32 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**)
  call void %32(i8 %31)
  br label %$13
$13:
  %33 = phi i8 [%23, %$10], [%29, %$12] ; # B
  %34 = phi i64* [%24, %$10], [%30, %$12] ; # P
  br label %$11
$11:
  %35 = phi i8 [%17, %$8], [%33, %$13] ; # B
  %36 = phi i64* [%18, %$8], [%34, %$13] ; # P
  br label %$9
$9:
  %37 = phi i8 [%12, %$6], [%35, %$11] ; # B
  %38 = phi i64* [%13, %$6], [%36, %$11] ; # P
  br label %$7
$7:
  %39 = phi i8 [%10, %$5], [%37, %$9] ; # B
  %40 = phi i64* [%11, %$5], [%38, %$9] ; # P
; # (symByte P)
  %41 = call i8 @symByte(i64* %40)
  br label %$2
$4:
  %42 = phi i8 [%2, %$2] ; # B
  %43 = phi i64* [%3, %$2] ; # P
  ret void
}

define void @htFmt(i64) align 8 {
$1:
; # (cond ((nil? X)) ((num? X) (call $Put (char "+")) (prin X)) ((pai...
; # (nil? X)
  %1 = icmp eq i64 %0, ptrtoint (i8* getelementptr (i8, i8* bitcast ([892 x i64]* @SymTab to i8*), i32 8) to i64)
  br i1 %1, label %$2, label %$3
$3:
  %2 = phi i64 [%0, %$1] ; # X
; # (num? X)
  %3 = and i64 %2, 6
  %4 = icmp ne i64 %3, 0
  br i1 %4, label %$5, label %$4
$5:
  %5 = phi i64 [%2, %$3] ; # X
; # (call $Put (char "+"))
  %6 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**)
  call void %6(i8 43)
; # (prin X)
  call void @prin(i64 %5)
  br label %$2
$4:
  %7 = phi i64 [%2, %$3] ; # X
; # (pair X)
  %8 = and i64 %7, 15
  %9 = icmp eq i64 %8, 0
  br i1 %9, label %$7, label %$6
$7:
  %10 = phi i64 [%7, %$4] ; # X
; # (loop (call $Put (char "_")) (htFmt (++ X)) (? (atom X)))
  br label %$8
$8:
  %11 = phi i64 [%10, %$7], [%19, %$9] ; # X
; # (call $Put (char "_"))
  %12 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**)
  call void %12(i8 95)
; # (++ X)
  %13 = inttoptr i64 %11 to i64*
  %14 = getelementptr i64, i64* %13, i32 1
  %15 = load i64, i64* %14
  %16 = load i64, i64* %13
; # (htFmt (++ X))
  call void @htFmt(i64 %16)
; # (? (atom X))
; # (atom X)
  %17 = and i64 %15, 15
  %18 = icmp ne i64 %17, 0
  br i1 %18, label %$10, label %$9
$9:
  %19 = phi i64 [%15, %$8] ; # X
  br label %$8
$10:
  %20 = phi i64 [%15, %$8] ; # X
  %21 = phi i64 [0, %$8] ; # ->
  br label %$2
$6:
  %22 = phi i64 [%7, %$4] ; # X
; # (tail X)
  %23 = add i64 %22, -8
; # (val (tail X))
  %24 = inttoptr i64 %23 to i64*
  %25 = load i64, i64* %24
; # (sym? (val (tail X)))
  %26 = and i64 %25, 8
  %27 = icmp ne i64 %26, 0
  br i1 %27, label %$12, label %$11
$12:
  %28 = phi i64 [%22, %$6] ; # X
; # (call $Put (char "-"))
  %29 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**)
  call void %29(i8 45)
; # (& @ -9)
  %30 = and i64 %25, -9
; # (name (& @ -9))
  br label %$13
$13:
  %31 = phi i64 [%30, %$12], [%37, %$14] ; # Tail
  %32 = and i64 %31, 6
  %33 = icmp ne i64 %32, 0
  br i1 %33, label %$15, label %$14
$14:
  %34 = phi i64 [%31, %$13] ; # Tail
  %35 = inttoptr i64 %34 to i64*
  %36 = getelementptr i64, i64* %35, i32 1
  %37 = load i64, i64* %36
  br label %$13
$15:
  %38 = phi i64 [%31, %$13] ; # Tail
; # (prExt (name (& @ -9)))
  call void @prExt(i64 %38)
  br label %$2
$11:
  %39 = phi i64 [%22, %$6] ; # X
; # (name @)
  br label %$16
$16:
  %40 = phi i64 [%25, %$11], [%46, %$17] ; # Tail
  %41 = and i64 %40, 6
  %42 = icmp ne i64 %41, 0
  br i1 %42, label %$18, label %$17
$17:
  %43 = phi i64 [%40, %$16] ; # Tail
  %44 = inttoptr i64 %43 to i64*
  %45 = getelementptr i64, i64* %44, i32 1
  %46 = load i64, i64* %45
  br label %$16
$18:
  %47 = phi i64 [%40, %$16] ; # Tail
; # (== (name @) ZERO)
  %48 = icmp eq i64 %47, 2
  br i1 %48, label %$2, label %$19
$19:
  %49 = phi i64 [%39, %$18] ; # X
; # (let (Nm @ P (push 0 Nm) B (symByte P)) (cond ((findSym X Nm (val...
; # (push 0 Nm)
  %50 = alloca i64, i64 2, align 16
  store i64 0, i64* %50
  %51 = getelementptr i64, i64* %50, i32 1
  store i64 %47, i64* %51
; # (symByte P)
  %52 = call i8 @symByte(i64* %50)
; # (cond ((findSym X Nm (val $Intern)) (call $Put (char "$")) (htEnc...
; # (val $Intern)
  %53 = inttoptr i64 ptrtoint (i8* getelementptr (i8, i8* bitcast ([53 x i64]* @gcData to i8*), i32 0) to i64) to i64*
  %54 = load i64, i64* %53
; # (findSym X Nm (val $Intern))
  %55 = call i1 @findSym(i64 %49, i64 %47, i64 %54)
  br i1 %55, label %$22, label %$21
$22:
  %56 = phi i64 [%49, %$19] ; # X
  %57 = phi i64 [%47, %$19] ; # Nm
  %58 = phi i64* [%50, %$19] ; # P
  %59 = phi i8 [%52, %$19] ; # B
; # (call $Put (char "$"))
  %60 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**)
  call void %60(i8 36)
; # (htEncode B P)
  call void @htEncode(i8 %59, i64* %58)
  br label %$20
$21:
  %61 = phi i64 [%49, %$19] ; # X
  %62 = phi i64 [%47, %$19] ; # Nm
  %63 = phi i64* [%50, %$19] ; # P
  %64 = phi i8 [%52, %$19] ; # B
; # (or (== B (char "$")) (== B (char "+")) (== B (char "-")))
; # (== B (char "$"))
  %65 = icmp eq i8 %64, 36
  br i1 %65, label %$23, label %$24
$24:
  %66 = phi i64 [%61, %$21] ; # X
  %67 = phi i64 [%62, %$21] ; # Nm
  %68 = phi i64* [%63, %$21] ; # P
  %69 = phi i8 [%64, %$21] ; # B
; # (== B (char "+"))
  %70 = icmp eq i8 %69, 43
  br i1 %70, label %$23, label %$25
$25:
  %71 = phi i64 [%66, %$24] ; # X
  %72 = phi i64 [%67, %$24] ; # Nm
  %73 = phi i64* [%68, %$24] ; # P
  %74 = phi i8 [%69, %$24] ; # B
; # (== B (char "-"))
  %75 = icmp eq i8 %74, 45
  br label %$23
$23:
  %76 = phi i64 [%61, %$21], [%66, %$24], [%71, %$25] ; # X
  %77 = phi i64 [%62, %$21], [%67, %$24], [%72, %$25] ; # Nm
  %78 = phi i64* [%63, %$21], [%68, %$24], [%73, %$25] ; # P
  %79 = phi i8 [%64, %$21], [%69, %$24], [%74, %$25] ; # B
  %80 = phi i1 [1, %$21], [1, %$24], [%75, %$25] ; # ->
  br i1 %80, label %$27, label %$26
$27:
  %81 = phi i64 [%76, %$23] ; # X
  %82 = phi i64 [%77, %$23] ; # Nm
  %83 = phi i64* [%78, %$23] ; # P
  %84 = phi i8 [%79, %$23] ; # B
; # (putHex B)
  call void @putHex(i8 %84)
; # (symByte P)
  %85 = call i8 @symByte(i64* %83)
; # (htEncode (symByte P) P)
  call void @htEncode(i8 %85, i64* %83)
  br label %$20
$26:
  %86 = phi i64 [%76, %$23] ; # X
  %87 = phi i64 [%77, %$23] ; # Nm
  %88 = phi i64* [%78, %$23] ; # P
  %89 = phi i8 [%79, %$23] ; # B
; # (htEncode B P)
  call void @htEncode(i8 %89, i64* %88)
  br label %$20
$20:
  %90 = phi i64 [%56, %$22], [%81, %$27], [%86, %$26] ; # X
  %91 = phi i64 [%57, %$22], [%82, %$27], [%87, %$26] ; # Nm
  %92 = phi i64* [%58, %$22], [%83, %$27], [%88, %$26] ; # P
  %93 = phi i8 [%59, %$22], [%84, %$27], [%89, %$26] ; # B
  br label %$2
$2:
  %94 = phi i64 [%0, %$1], [%5, %$5], [%20, %$10], [%28, %$15], [%39, %$18], [%90, %$20] ; # X
  ret void
}

define i64 @Fmt(i64) align 8 {
$1:
; # (let (X (cdr Exe) P (push 4 NIL ZERO NIL NIL NIL)) (begString P) ...
; # (cdr Exe)
  %1 = inttoptr i64 %0 to i64*
  %2 = getelementptr i64, i64* %1, i32 1
  %3 = load i64, i64* %2
; # (push 4 NIL ZERO NIL NIL NIL)
  %4 = alloca i64, i64 6, align 16
  store i64 4, i64* %4
  %5 = getelementptr i64, i64* %4, i32 2
  store i64 2, i64* %5
; # (begString P)
  call void @begString(i64* %4)
; # (loop (htFmt (prog2 (tglString P) (eval (car X)) (tglString P))) ...
  br label %$2
$2:
  %6 = phi i64 [%0, %$1], [%29, %$8] ; # Exe
  %7 = phi i64 [%3, %$1], [%30, %$8] ; # X
  %8 = phi i64* [%4, %$1], [%31, %$8] ; # P
; # (prog2 (tglString P) (eval (car X)) (tglString P))
; # (tglString P)
  call void @tglString(i64* %8)
; # (car X)
  %9 = inttoptr i64 %7 to i64*
  %10 = load i64, i64* %9
; # (eval (car X))
  %11 = and i64 %10, 6
  %12 = icmp ne i64 %11, 0
  br i1 %12, label %$5, label %$4
$5:
  %13 = phi i64 [%10, %$2] ; # X
  br label %$3
$4:
  %14 = phi i64 [%10, %$2] ; # X
  %15 = and i64 %14, 8
  %16 = icmp ne i64 %15, 0
  br i1 %16, label %$7, label %$6
$7:
  %17 = phi i64 [%14, %$4] ; # X
  %18 = inttoptr i64 %17 to i64*
  %19 = load i64, i64* %18
  br label %$3
$6:
  %20 = phi i64 [%14, %$4] ; # X
  %21 = call i64 @evList(i64 %20)
  br label %$3
$3:
  %22 = phi i64 [%13, %$5], [%17, %$7], [%20, %$6] ; # X
  %23 = phi i64 [%13, %$5], [%19, %$7], [%21, %$6] ; # ->
; # (tglString P)
  call void @tglString(i64* %8)
; # (htFmt (prog2 (tglString P) (eval (car X)) (tglString P)))
  call void @htFmt(i64 %23)
; # (? (atom (shift X)))
; # (shift X)
  %24 = inttoptr i64 %7 to i64*
  %25 = getelementptr i64, i64* %24, i32 1
  %26 = load i64, i64* %25
; # (atom (shift X))
  %27 = and i64 %26, 15
  %28 = icmp ne i64 %27, 0
  br i1 %28, label %$9, label %$8
$8:
  %29 = phi i64 [%6, %$3] ; # Exe
  %30 = phi i64 [%26, %$3] ; # X
  %31 = phi i64* [%8, %$3] ; # P
; # (call $Put (char "&"))
  %32 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**)
  call void %32(i8 38)
  br label %$2
$9:
  %33 = phi i64 [%6, %$3] ; # Exe
  %34 = phi i64 [%26, %$3] ; # X
  %35 = phi i64* [%8, %$3] ; # P
  %36 = phi i64 [0, %$3] ; # ->
; # (endString)
  %37 = call i64 @endString()
  ret i64 %37
}

define i8 @getHex(i64) align 8 {
$1:
; # (if (> (- (firstByte Sym) (char "0")) 9) (- (& @ (hex "DF")) 7) @...
; # (firstByte Sym)
  %1 = call i8 @firstByte(i64 %0)
; # (- (firstByte Sym) (char "0"))
  %2 = sub i8 %1, 48
; # (> (- (firstByte Sym) (char "0")) 9)
  %3 = icmp ugt i8 %2, 9
  br i1 %3, label %$2, label %$3
$2:
  %4 = phi i64 [%0, %$1] ; # Sym
; # (& @ (hex "DF"))
  %5 = and i8 %2, 223
; # (- (& @ (hex "DF")) 7)
  %6 = sub i8 %5, 7
  br label %$4
$3:
  %7 = phi i64 [%0, %$1] ; # Sym
  br label %$4
$4:
  %8 = phi i64 [%4, %$2], [%7, %$3] ; # Sym
  %9 = phi i8 [%6, %$2], [%2, %$3] ; # ->
  ret i8 %9
}

define i64 @head(i8*, i64) align 8 {
$1:
; # (let B (val S) (loop (? (<> B (firstByte (++ Lst))) 0) (? (=0 (se...
; # (val S)
  %2 = load i8, i8* %0
; # (loop (? (<> B (firstByte (++ Lst))) 0) (? (=0 (setq B (val (inc ...
  br label %$2
$2:
  %3 = phi i8* [%0, %$1], [%24, %$6] ; # S
  %4 = phi i64 [%1, %$1], [%25, %$6] ; # Lst
  %5 = phi i8 [%2, %$1], [%26, %$6] ; # B
; # (? (<> B (firstByte (++ Lst))) 0)
; # (++ Lst)
  %6 = inttoptr i64 %4 to i64*
  %7 = getelementptr i64, i64* %6, i32 1
  %8 = load i64, i64* %7
  %9 = load i64, i64* %6
; # (firstByte (++ Lst))
  %10 = call i8 @firstByte(i64 %9)
; # (<> B (firstByte (++ Lst)))
  %11 = icmp ne i8 %5, %10
  br i1 %11, label %$5, label %$3
$5:
  %12 = phi i8* [%3, %$2] ; # S
  %13 = phi i64 [%8, %$2] ; # Lst
  %14 = phi i8 [%5, %$2] ; # B
  br label %$4
$3:
  %15 = phi i8* [%3, %$2] ; # S
  %16 = phi i64 [%8, %$2] ; # Lst
  %17 = phi i8 [%5, %$2] ; # B
; # (? (=0 (setq B (val (inc 'S)))) Lst)
; # (inc 'S)
  %18 = getelementptr i8, i8* %15, i32 1
; # (val (inc 'S))
  %19 = load i8, i8* %18
; # (=0 (setq B (val (inc 'S))))
  %20 = icmp eq i8 %19, 0
  br i1 %20, label %$7, label %$6
$7:
  %21 = phi i8* [%18, %$3] ; # S
  %22 = phi i64 [%16, %$3] ; # Lst
  %23 = phi i8 [%19, %$3] ; # B
  br label %$4
$6:
  %24 = phi i8* [%18, %$3] ; # S
  %25 = phi i64 [%16, %$3] ; # Lst
  %26 = phi i8 [%19, %$3] ; # B
  br label %$2
$4:
  %27 = phi i8* [%12, %$5], [%21, %$7] ; # S
  %28 = phi i64 [%13, %$5], [%22, %$7] ; # Lst
  %29 = phi i8 [%14, %$5], [%23, %$7] ; # B
  %30 = phi i64 [0, %$5], [%22, %$7] ; # ->
  ret i64 %30
}

define i64 @Pack(i64) align 8 {
$1:
; # (let (X (cdr Exe) Lst (save (eval (++ X))) Flg (nil? (eval (car X...
; # (cdr Exe)
  %1 = inttoptr i64 %0 to i64*
  %2 = getelementptr i64, i64* %1, i32 1
  %3 = load i64, i64* %2
; # (++ X)
  %4 = inttoptr i64 %3 to i64*
  %5 = getelementptr i64, i64* %4, i32 1
  %6 = load i64, i64* %5
  %7 = load i64, i64* %4
; # (eval (++ X))
  %8 = and i64 %7, 6
  %9 = icmp ne i64 %8, 0
  br i1 %9, label %$4, label %$3
$4:
  %10 = phi i64 [%7, %$1] ; # X
  br label %$2
$3:
  %11 = phi i64 [%7, %$1] ; # X
  %12 = and i64 %11, 8
  %13 = icmp ne i64 %12, 0
  br i1 %13, label %$6, label %$5
$6:
  %14 = phi i64 [%11, %$3] ; # X
  %15 = inttoptr i64 %14 to i64*
  %16 = load i64, i64* %15
  br label %$2
$5:
  %17 = phi i64 [%11, %$3] ; # X
  %18 = call i64 @evList(i64 %17)
  br label %$2
$2:
  %19 = phi i64 [%10, %$4], [%14, %$6], [%17, %$5] ; # X
  %20 = phi i64 [%10, %$4], [%16, %$6], [%18, %$5] ; # ->
; # (save (eval (++ X)))
  %21 = inttoptr i64 ptrtoint (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 0) to i64) to i64*
  %22 = load i64, i64* %21
  %23 = alloca i64, i64 2, align 16
  %24 = ptrtoint i64* %23 to i64
  %25 = inttoptr i64 %24 to i64*
  store i64 %20, i64* %25
  %26 = add i64 %24, 8
  %27 = inttoptr i64 %26 to i64*
  store i64 %22, i64* %27
  %28 = inttoptr i64 ptrtoint (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 0) to i64) to i64*
  store i64 %24, i64* %28
; # (car X)
  %29 = inttoptr i64 %6 to i64*
  %30 = load i64, i64* %29
; # (eval (car X))
  %31 = and i64 %30, 6
  %32 = icmp ne i64 %31, 0
  br i1 %32, label %$9, label %$8
$9:
  %33 = phi i64 [%30, %$2] ; # X
  br label %$7
$8:
  %34 = phi i64 [%30, %$2] ; # X
  %35 = and i64 %34, 8
  %36 = icmp ne i64 %35, 0
  br i1 %36, label %$11, label %$10
$11:
  %37 = phi i64 [%34, %$8] ; # X
  %38 = inttoptr i64 %37 to i64*
  %39 = load i64, i64* %38
  br label %$7
$10:
  %40 = phi i64 [%34, %$8] ; # X
  %41 = call i64 @evList(i64 %40)
  br label %$7
$7:
  %42 = phi i64 [%33, %$9], [%37, %$11], [%40, %$10] ; # X
  %43 = phi i64 [%33, %$9], [%39, %$11], [%41, %$10] ; # ->
; # (nil? (eval (car X)))
  %44 = icmp eq i64 %43, ptrtoint (i8* getelementptr (i8, i8* bitcast ([892 x i64]* @SymTab to i8*), i32 8) to i64)
; # (push 4 NIL ZERO NIL NIL NIL)
  %45 = alloca i64, i64 6, align 16
  store i64 4, i64* %45
  %46 = getelementptr i64, i64* %45, i32 2
  store i64 2, i64* %46
; # (begString (push 4 NIL ZERO NIL NIL NIL))
  call void @begString(i64* %45)
; # (while (pair Lst) (let (C (++ Lst) B (firstByte C)) (cond ((== B ...
  br label %$12
$12:
  %47 = phi i64 [%0, %$7], [%310, %$15] ; # Exe
  %48 = phi i64 [%6, %$7], [%311, %$15] ; # X
  %49 = phi i64 [%20, %$7], [%312, %$15] ; # Lst
  %50 = phi i1 [%44, %$7], [%313, %$15] ; # Flg
; # (pair Lst)
  %51 = and i64 %49, 15
  %52 = icmp eq i64 %51, 0
  br i1 %52, label %$13, label %$14
$13:
  %53 = phi i64 [%47, %$12] ; # Exe
  %54 = phi i64 [%48, %$12] ; # X
  %55 = phi i64 [%49, %$12] ; # Lst
  %56 = phi i1 [%50, %$12] ; # Flg
; # (let (C (++ Lst) B (firstByte C)) (cond ((== B (char "%")) (call ...
; # (++ Lst)
  %57 = inttoptr i64 %55 to i64*
  %58 = getelementptr i64, i64* %57, i32 1
  %59 = load i64, i64* %58
  %60 = load i64, i64* %57
; # (firstByte C)
  %61 = call i8 @firstByte(i64 %60)
; # (cond ((== B (char "%")) (call $Put (if Flg B (| (shl (getHex (++...
; # (== B (char "%"))
  %62 = icmp eq i8 %61, 37
  br i1 %62, label %$17, label %$16
$17:
  %63 = phi i64 [%53, %$13] ; # Exe
  %64 = phi i64 [%54, %$13] ; # X
  %65 = phi i64 [%59, %$13] ; # Lst
  %66 = phi i1 [%56, %$13] ; # Flg
  %67 = phi i64 [%60, %$13] ; # C
  %68 = phi i8 [%61, %$13] ; # B
; # (if Flg B (| (shl (getHex (++ Lst)) 4) (getHex (++ Lst))))
  br i1 %66, label %$18, label %$19
$18:
  %69 = phi i64 [%63, %$17] ; # Exe
  %70 = phi i64 [%64, %$17] ; # X
  %71 = phi i64 [%65, %$17] ; # Lst
  %72 = phi i1 [%66, %$17] ; # Flg
  %73 = phi i64 [%67, %$17] ; # C
  %74 = phi i8 [%68, %$17] ; # B
  br label %$20
$19:
  %75 = phi i64 [%63, %$17] ; # Exe
  %76 = phi i64 [%64, %$17] ; # X
  %77 = phi i64 [%65, %$17] ; # Lst
  %78 = phi i1 [%66, %$17] ; # Flg
  %79 = phi i64 [%67, %$17] ; # C
  %80 = phi i8 [%68, %$17] ; # B
; # (++ Lst)
  %81 = inttoptr i64 %77 to i64*
  %82 = getelementptr i64, i64* %81, i32 1
  %83 = load i64, i64* %82
  %84 = load i64, i64* %81
; # (getHex (++ Lst))
  %85 = call i8 @getHex(i64 %84)
; # (shl (getHex (++ Lst)) 4)
  %86 = shl i8 %85, 4
; # (++ Lst)
  %87 = inttoptr i64 %83 to i64*
  %88 = getelementptr i64, i64* %87, i32 1
  %89 = load i64, i64* %88
  %90 = load i64, i64* %87
; # (getHex (++ Lst))
  %91 = call i8 @getHex(i64 %90)
; # (| (shl (getHex (++ Lst)) 4) (getHex (++ Lst)))
  %92 = or i8 %86, %91
  br label %$20
$20:
  %93 = phi i64 [%69, %$18], [%75, %$19] ; # Exe
  %94 = phi i64 [%70, %$18], [%76, %$19] ; # X
  %95 = phi i64 [%71, %$18], [%89, %$19] ; # Lst
  %96 = phi i1 [%72, %$18], [%78, %$19] ; # Flg
  %97 = phi i64 [%73, %$18], [%79, %$19] ; # C
  %98 = phi i8 [%74, %$18], [%80, %$19] ; # B
  %99 = phi i8 [%74, %$18], [%92, %$19] ; # ->
; # (call $Put (if Flg B (| (shl (getHex (++ Lst)) 4) (getHex (++ Lst...
  %100 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**)
  call void %100(i8 %99)
  br label %$15
$16:
  %101 = phi i64 [%53, %$13] ; # Exe
  %102 = phi i64 [%54, %$13] ; # X
  %103 = phi i64 [%59, %$13] ; # Lst
  %104 = phi i1 [%56, %$13] ; # Flg
  %105 = phi i64 [%60, %$13] ; # C
  %106 = phi i8 [%61, %$13] ; # B
; # (<> B (char "&"))
  %107 = icmp ne i8 %106, 38
  br i1 %107, label %$22, label %$21
$22:
  %108 = phi i64 [%101, %$16] ; # Exe
  %109 = phi i64 [%102, %$16] ; # X
  %110 = phi i64 [%103, %$16] ; # Lst
  %111 = phi i1 [%104, %$16] ; # Flg
  %112 = phi i64 [%105, %$16] ; # C
  %113 = phi i8 [%106, %$16] ; # B
; # (prSym C)
  call void @prSym(i64 %112)
  br label %$15
$21:
  %114 = phi i64 [%101, %$16] ; # Exe
  %115 = phi i64 [%102, %$16] ; # X
  %116 = phi i64 [%103, %$16] ; # Lst
  %117 = phi i1 [%104, %$16] ; # Flg
  %118 = phi i64 [%105, %$16] ; # C
  %119 = phi i8 [%106, %$16] ; # B
; # (head ($ "lt;") Lst)
  %120 = call i64 @head(i8* bitcast ([4 x i8]* @$6 to i8*), i64 %116)
  %121 = icmp ne i64 %120, 0
  br i1 %121, label %$24, label %$23
$24:
  %122 = phi i64 [%114, %$21] ; # Exe
  %123 = phi i64 [%115, %$21] ; # X
  %124 = phi i64 [%116, %$21] ; # Lst
  %125 = phi i1 [%117, %$21] ; # Flg
  %126 = phi i64 [%118, %$21] ; # C
  %127 = phi i8 [%119, %$21] ; # B
; # (call $Put (char "<"))
  %128 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**)
  call void %128(i8 60)
  br label %$15
$23:
  %129 = phi i64 [%114, %$21] ; # Exe
  %130 = phi i64 [%115, %$21] ; # X
  %131 = phi i64 [%116, %$21] ; # Lst
  %132 = phi i1 [%117, %$21] ; # Flg
  %133 = phi i64 [%118, %$21] ; # C
  %134 = phi i8 [%119, %$21] ; # B
; # (head ($ "gt;") Lst)
  %135 = call i64 @head(i8* bitcast ([4 x i8]* @$7 to i8*), i64 %131)
  %136 = icmp ne i64 %135, 0
  br i1 %136, label %$26, label %$25
$26:
  %137 = phi i64 [%129, %$23] ; # Exe
  %138 = phi i64 [%130, %$23] ; # X
  %139 = phi i64 [%131, %$23] ; # Lst
  %140 = phi i1 [%132, %$23] ; # Flg
  %141 = phi i64 [%133, %$23] ; # C
  %142 = phi i8 [%134, %$23] ; # B
; # (call $Put (char ">"))
  %143 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**)
  call void %143(i8 62)
  br label %$15
$25:
  %144 = phi i64 [%129, %$23] ; # Exe
  %145 = phi i64 [%130, %$23] ; # X
  %146 = phi i64 [%131, %$23] ; # Lst
  %147 = phi i1 [%132, %$23] ; # Flg
  %148 = phi i64 [%133, %$23] ; # C
  %149 = phi i8 [%134, %$23] ; # B
; # (head ($ "amp;") Lst)
  %150 = call i64 @head(i8* bitcast ([5 x i8]* @$8 to i8*), i64 %146)
  %151 = icmp ne i64 %150, 0
  br i1 %151, label %$28, label %$27
$28:
  %152 = phi i64 [%144, %$25] ; # Exe
  %153 = phi i64 [%145, %$25] ; # X
  %154 = phi i64 [%146, %$25] ; # Lst
  %155 = phi i1 [%147, %$25] ; # Flg
  %156 = phi i64 [%148, %$25] ; # C
  %157 = phi i8 [%149, %$25] ; # B
; # (call $Put (char "&"))
  %158 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**)
  call void %158(i8 38)
  br label %$15
$27:
  %159 = phi i64 [%144, %$25] ; # Exe
  %160 = phi i64 [%145, %$25] ; # X
  %161 = phi i64 [%146, %$25] ; # Lst
  %162 = phi i1 [%147, %$25] ; # Flg
  %163 = phi i64 [%148, %$25] ; # C
  %164 = phi i8 [%149, %$25] ; # B
; # (head ($ "quot;") Lst)
  %165 = call i64 @head(i8* bitcast ([6 x i8]* @$9 to i8*), i64 %161)
  %166 = icmp ne i64 %165, 0
  br i1 %166, label %$30, label %$29
$30:
  %167 = phi i64 [%159, %$27] ; # Exe
  %168 = phi i64 [%160, %$27] ; # X
  %169 = phi i64 [%161, %$27] ; # Lst
  %170 = phi i1 [%162, %$27] ; # Flg
  %171 = phi i64 [%163, %$27] ; # C
  %172 = phi i8 [%164, %$27] ; # B
; # (call $Put (char "\""))
  %173 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**)
  call void %173(i8 34)
  br label %$15
$29:
  %174 = phi i64 [%159, %$27] ; # Exe
  %175 = phi i64 [%160, %$27] ; # X
  %176 = phi i64 [%161, %$27] ; # Lst
  %177 = phi i1 [%162, %$27] ; # Flg
  %178 = phi i64 [%163, %$27] ; # C
  %179 = phi i8 [%164, %$27] ; # B
; # (head ($ "nbsp;") Lst)
  %180 = call i64 @head(i8* bitcast ([6 x i8]* @$10 to i8*), i64 %176)
  %181 = icmp ne i64 %180, 0
  br i1 %181, label %$32, label %$31
$32:
  %182 = phi i64 [%174, %$29] ; # Exe
  %183 = phi i64 [%175, %$29] ; # X
  %184 = phi i64 [%176, %$29] ; # Lst
  %185 = phi i1 [%177, %$29] ; # Flg
  %186 = phi i64 [%178, %$29] ; # C
  %187 = phi i8 [%179, %$29] ; # B
; # (call $Put (char " "))
  %188 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**)
  call void %188(i8 32)
  br label %$15
$31:
  %189 = phi i64 [%174, %$29] ; # Exe
  %190 = phi i64 [%175, %$29] ; # X
  %191 = phi i64 [%176, %$29] ; # Lst
  %192 = phi i1 [%177, %$29] ; # Flg
  %193 = phi i64 [%178, %$29] ; # C
  %194 = phi i8 [%179, %$29] ; # B
; # (car Lst)
  %195 = inttoptr i64 %191 to i64*
  %196 = load i64, i64* %195
; # (firstByte (car Lst))
  %197 = call i8 @firstByte(i64 %196)
; # (== (firstByte (car Lst)) (char "#"))
  %198 = icmp eq i8 %197, 35
  br i1 %198, label %$34, label %$33
$34:
  %199 = phi i64 [%189, %$31] ; # Exe
  %200 = phi i64 [%190, %$31] ; # X
  %201 = phi i64 [%191, %$31] ; # Lst
  %202 = phi i1 [%192, %$31] ; # Flg
  %203 = phi i64 [%193, %$31] ; # C
  %204 = phi i8 [%194, %$31] ; # B
; # (let (L (shift Lst) D (firstByte (++ L)) N (i32 (- D (char "0")))...
; # (shift Lst)
  %205 = inttoptr i64 %201 to i64*
  %206 = getelementptr i64, i64* %205, i32 1
  %207 = load i64, i64* %206
; # (++ L)
  %208 = inttoptr i64 %207 to i64*
  %209 = getelementptr i64, i64* %208, i32 1
  %210 = load i64, i64* %209
  %211 = load i64, i64* %208
; # (firstByte (++ L))
  %212 = call i8 @firstByte(i64 %211)
; # (- D (char "0"))
  %213 = sub i8 %212, 48
; # (i32 (- D (char "0")))
  %214 = zext i8 %213 to i32
; # (loop (? (or (> (char "0") D) (> D (char "9"))) (call $Put (char ...
  br label %$35
$35:
  %215 = phi i64 [%199, %$34], [%281, %$41] ; # Exe
  %216 = phi i64 [%200, %$34], [%282, %$41] ; # X
  %217 = phi i64 [%207, %$34], [%283, %$41] ; # Lst
  %218 = phi i1 [%202, %$34], [%284, %$41] ; # Flg
  %219 = phi i64 [%203, %$34], [%285, %$41] ; # C
  %220 = phi i8 [%204, %$34], [%286, %$41] ; # B
  %221 = phi i64 [%210, %$34], [%287, %$41] ; # L
  %222 = phi i8 [%212, %$34], [%288, %$41] ; # D
  %223 = phi i32 [%214, %$34], [%293, %$41] ; # N
; # (? (or (> (char "0") D) (> D (char "9"))) (call $Put (char "&")) ...
; # (or (> (char "0") D) (> D (char "9")))
; # (> (char "0") D)
  %224 = icmp ugt i8 48, %222
  br i1 %224, label %$36, label %$37
$37:
  %225 = phi i64 [%215, %$35] ; # Exe
  %226 = phi i64 [%216, %$35] ; # X
  %227 = phi i64 [%217, %$35] ; # Lst
  %228 = phi i1 [%218, %$35] ; # Flg
  %229 = phi i64 [%219, %$35] ; # C
  %230 = phi i8 [%220, %$35] ; # B
  %231 = phi i64 [%221, %$35] ; # L
  %232 = phi i8 [%222, %$35] ; # D
  %233 = phi i32 [%223, %$35] ; # N
; # (> D (char "9"))
  %234 = icmp ugt i8 %232, 57
  br label %$36
$36:
  %235 = phi i64 [%215, %$35], [%225, %$37] ; # Exe
  %236 = phi i64 [%216, %$35], [%226, %$37] ; # X
  %237 = phi i64 [%217, %$35], [%227, %$37] ; # Lst
  %238 = phi i1 [%218, %$35], [%228, %$37] ; # Flg
  %239 = phi i64 [%219, %$35], [%229, %$37] ; # C
  %240 = phi i8 [%220, %$35], [%230, %$37] ; # B
  %241 = phi i64 [%221, %$35], [%231, %$37] ; # L
  %242 = phi i8 [%222, %$35], [%232, %$37] ; # D
  %243 = phi i32 [%223, %$35], [%233, %$37] ; # N
  %244 = phi i1 [1, %$35], [%234, %$37] ; # ->
  br i1 %244, label %$40, label %$38
$40:
  %245 = phi i64 [%235, %$36] ; # Exe
  %246 = phi i64 [%236, %$36] ; # X
  %247 = phi i64 [%237, %$36] ; # Lst
  %248 = phi i1 [%238, %$36] ; # Flg
  %249 = phi i64 [%239, %$36] ; # C
  %250 = phi i8 [%240, %$36] ; # B
  %251 = phi i64 [%241, %$36] ; # L
  %252 = phi i8 [%242, %$36] ; # D
  %253 = phi i32 [%243, %$36] ; # N
; # (call $Put (char "&"))
  %254 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**)
  call void %254(i8 38)
; # (call $Put (char "#"))
  %255 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**)
  call void %255(i8 35)
  br label %$39
$38:
  %256 = phi i64 [%235, %$36] ; # Exe
  %257 = phi i64 [%236, %$36] ; # X
  %258 = phi i64 [%237, %$36] ; # Lst
  %259 = phi i1 [%238, %$36] ; # Flg
  %260 = phi i64 [%239, %$36] ; # C
  %261 = phi i8 [%240, %$36] ; # B
  %262 = phi i64 [%241, %$36] ; # L
  %263 = phi i8 [%242, %$36] ; # D
  %264 = phi i32 [%243, %$36] ; # N
; # (? (== (setq D (firstByte (++ L))) (char ";")) (prSym (mkChar N))...
; # (++ L)
  %265 = inttoptr i64 %262 to i64*
  %266 = getelementptr i64, i64* %265, i32 1
  %267 = load i64, i64* %266
  %268 = load i64, i64* %265
; # (firstByte (++ L))
  %269 = call i8 @firstByte(i64 %268)
; # (== (setq D (firstByte (++ L))) (char ";"))
  %270 = icmp eq i8 %269, 59
  br i1 %270, label %$42, label %$41
$42:
  %271 = phi i64 [%256, %$38] ; # Exe
  %272 = phi i64 [%257, %$38] ; # X
  %273 = phi i64 [%258, %$38] ; # Lst
  %274 = phi i1 [%259, %$38] ; # Flg
  %275 = phi i64 [%260, %$38] ; # C
  %276 = phi i8 [%261, %$38] ; # B
  %277 = phi i64 [%267, %$38] ; # L
  %278 = phi i8 [%269, %$38] ; # D
  %279 = phi i32 [%264, %$38] ; # N
; # (mkChar N)
  %280 = call i64 @mkChar(i32 %279)
; # (prSym (mkChar N))
  call void @prSym(i64 %280)
  br label %$39
$41:
  %281 = phi i64 [%256, %$38] ; # Exe
  %282 = phi i64 [%257, %$38] ; # X
  %283 = phi i64 [%258, %$38] ; # Lst
  %284 = phi i1 [%259, %$38] ; # Flg
  %285 = phi i64 [%260, %$38] ; # C
  %286 = phi i8 [%261, %$38] ; # B
  %287 = phi i64 [%267, %$38] ; # L
  %288 = phi i8 [%269, %$38] ; # D
  %289 = phi i32 [%264, %$38] ; # N
; # (* N 10)
  %290 = mul i32 %289, 10
; # (- D (char "0"))
  %291 = sub i8 %288, 48
; # (i32 (- D (char "0")))
  %292 = zext i8 %291 to i32
; # (+ (* N 10) (i32 (- D (char "0"))))
  %293 = add i32 %290, %292
  br label %$35
$39:
  %294 = phi i64 [%245, %$40], [%271, %$42] ; # Exe
  %295 = phi i64 [%246, %$40], [%272, %$42] ; # X
  %296 = phi i64 [%247, %$40], [%277, %$42] ; # Lst
  %297 = phi i1 [%248, %$40], [%274, %$42] ; # Flg
  %298 = phi i64 [%249, %$40], [%275, %$42] ; # C
  %299 = phi i8 [%250, %$40], [%276, %$42] ; # B
  %300 = phi i64 [%251, %$40], [%277, %$42] ; # L
  %301 = phi i8 [%252, %$40], [%278, %$42] ; # D
  %302 = phi i32 [%253, %$40], [%279, %$42] ; # N
  br label %$15
$33:
  %303 = phi i64 [%189, %$31] ; # Exe
  %304 = phi i64 [%190, %$31] ; # X
  %305 = phi i64 [%191, %$31] ; # Lst
  %306 = phi i1 [%192, %$31] ; # Flg
  %307 = phi i64 [%193, %$31] ; # C
  %308 = phi i8 [%194, %$31] ; # B
; # (call $Put (char "&"))
  %309 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**)
  call void %309(i8 38)
  br label %$15
$15:
  %310 = phi i64 [%93, %$20], [%108, %$22], [%122, %$24], [%137, %$26], [%152, %$28], [%167, %$30], [%182, %$32], [%294, %$39], [%303, %$33] ; # Exe
  %311 = phi i64 [%94, %$20], [%109, %$22], [%123, %$24], [%138, %$26], [%153, %$28], [%168, %$30], [%183, %$32], [%295, %$39], [%304, %$33] ; # X
  %312 = phi i64 [%95, %$20], [%110, %$22], [%120, %$24], [%135, %$26], [%150, %$28], [%165, %$30], [%180, %$32], [%296, %$39], [%305, %$33] ; # Lst
  %313 = phi i1 [%96, %$20], [%111, %$22], [%125, %$24], [%140, %$26], [%155, %$28], [%170, %$30], [%185, %$32], [%297, %$39], [%306, %$33] ; # Flg
  %314 = phi i64 [%97, %$20], [%112, %$22], [%126, %$24], [%141, %$26], [%156, %$28], [%171, %$30], [%186, %$32], [%298, %$39], [%307, %$33] ; # C
  %315 = phi i8 [%98, %$20], [%113, %$22], [%127, %$24], [%142, %$26], [%157, %$28], [%172, %$30], [%187, %$32], [%299, %$39], [%308, %$33] ; # B
  br label %$12
$14:
  %316 = phi i64 [%47, %$12] ; # Exe
  %317 = phi i64 [%48, %$12] ; # X
  %318 = phi i64 [%49, %$12] ; # Lst
  %319 = phi i1 [%50, %$12] ; # Flg
; # (endString)
  %320 = call i64 @endString()
; # (drop *Safe)
  %321 = inttoptr i64 %24 to i64*
  %322 = getelementptr i64, i64* %321, i32 1
  %323 = load i64, i64* %322
  %324 = inttoptr i64 ptrtoint (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 0) to i64) to i64*
  store i64 %323, i64* %324
  ret i64 %320
}

define i64 @Read(i64) align 8 {
$1:
; # (let (N (evCnt Exe (cdr Exe)) C (val $Chr)) (if (or (le0 N) (and ...
; # (cdr Exe)
  %1 = inttoptr i64 %0 to i64*
  %2 = getelementptr i64, i64* %1, i32 1
  %3 = load i64, i64* %2
; # (evCnt Exe (cdr Exe))
  %4 = call i64 @evCnt(i64 %0, i64 %3)
; # (val $Chr)
  %5 = load i32, i32* bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 168) to i32*)
; # (if (or (le0 N) (and (=0 C) (lt0 (setq C (call $Get))))) $Nil (le...
; # (or (le0 N) (and (=0 C) (lt0 (setq C (call $Get)))))
; # (le0 N)
  %6 = icmp sle i64 %4, 0
  br i1 %6, label %$2, label %$3
$3:
  %7 = phi i64 [%0, %$1] ; # Exe
  %8 = phi i64 [%4, %$1] ; # N
  %9 = phi i32 [%5, %$1] ; # C
; # (and (=0 C) (lt0 (setq C (call $Get))))
; # (=0 C)
  %10 = icmp eq i32 %9, 0
  br i1 %10, label %$5, label %$4
$5:
  %11 = phi i64 [%7, %$3] ; # Exe
  %12 = phi i64 [%8, %$3] ; # N
  %13 = phi i32 [%9, %$3] ; # C
; # (call $Get)
  %14 = load i32()*, i32()** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 96) to i32()**)
  %15 = call i32 %14()
; # (lt0 (setq C (call $Get)))
  %16 = icmp slt i32 %15, 0
  br label %$4
$4:
  %17 = phi i64 [%7, %$3], [%11, %$5] ; # Exe
  %18 = phi i64 [%8, %$3], [%12, %$5] ; # N
  %19 = phi i32 [%9, %$3], [%15, %$5] ; # C
  %20 = phi i1 [0, %$3], [%16, %$5] ; # ->
  br label %$2
$2:
  %21 = phi i64 [%0, %$1], [%17, %$4] ; # Exe
  %22 = phi i64 [%4, %$1], [%18, %$4] ; # N
  %23 = phi i32 [%5, %$1], [%19, %$4] ; # C
  %24 = phi i1 [1, %$1], [%20, %$4] ; # ->
  br i1 %24, label %$6, label %$7
$6:
  %25 = phi i64 [%21, %$2] ; # Exe
  %26 = phi i64 [%22, %$2] ; # N
  %27 = phi i32 [%23, %$2] ; # C
  br label %$8
$7:
  %28 = phi i64 [%21, %$2] ; # Exe
  %29 = phi i64 [%22, %$2] ; # N
  %30 = phi i32 [%23, %$2] ; # C
; # (let C (getChar C) (when (>= C (hex "80")) (dec 'N) (when (>= C (...
; # (getChar C)
  %31 = call i32 @getChar(i32 %30)
; # (when (>= C (hex "80")) (dec 'N) (when (>= C (hex "800")) (dec 'N...
; # (>= C (hex "80"))
  %32 = icmp sge i32 %31, 128
  br i1 %32, label %$9, label %$10
$9:
  %33 = phi i64 [%28, %$7] ; # Exe
  %34 = phi i64 [%29, %$7] ; # N
  %35 = phi i32 [%31, %$7] ; # C
; # (dec 'N)
  %36 = sub i64 %34, 1
; # (when (>= C (hex "800")) (dec 'N) (when (>= C (hex "10000")) (dec...
; # (>= C (hex "800"))
  %37 = icmp sge i32 %35, 2048
  br i1 %37, label %$11, label %$12
$11:
  %38 = phi i64 [%33, %$9] ; # Exe
  %39 = phi i64 [%36, %$9] ; # N
  %40 = phi i32 [%35, %$9] ; # C
; # (dec 'N)
  %41 = sub i64 %39, 1
; # (when (>= C (hex "10000")) (dec 'N))
; # (>= C (hex "10000"))
  %42 = icmp sge i32 %40, 65536
  br i1 %42, label %$13, label %$14
$13:
  %43 = phi i64 [%38, %$11] ; # Exe
  %44 = phi i64 [%41, %$11] ; # N
  %45 = phi i32 [%40, %$11] ; # C
; # (dec 'N)
  %46 = sub i64 %44, 1
  br label %$14
$14:
  %47 = phi i64 [%38, %$11], [%43, %$13] ; # Exe
  %48 = phi i64 [%41, %$11], [%46, %$13] ; # N
  %49 = phi i32 [%40, %$11], [%45, %$13] ; # C
  br label %$12
$12:
  %50 = phi i64 [%33, %$9], [%47, %$14] ; # Exe
  %51 = phi i64 [%36, %$9], [%48, %$14] ; # N
  %52 = phi i32 [%35, %$9], [%49, %$14] ; # C
  br label %$10
$10:
  %53 = phi i64 [%28, %$7], [%50, %$12] ; # Exe
  %54 = phi i64 [%29, %$7], [%51, %$12] ; # N
  %55 = phi i32 [%31, %$7], [%52, %$12] ; # C
; # (if (lt0 (dec 'N)) $Nil (let (X (cons (mkChar C) $Nil) R (save X)...
; # (dec 'N)
  %56 = sub i64 %54, 1
; # (lt0 (dec 'N))
  %57 = icmp slt i64 %56, 0
  br i1 %57, label %$15, label %$16
$15:
  %58 = phi i64 [%53, %$10] ; # Exe
  %59 = phi i64 [%56, %$10] ; # N
  %60 = phi i32 [%55, %$10] ; # C
  br label %$17
$16:
  %61 = phi i64 [%53, %$10] ; # Exe
  %62 = phi i64 [%56, %$10] ; # N
  %63 = phi i32 [%55, %$10] ; # C
; # (let (X (cons (mkChar C) $Nil) R (save X)) (loop (? (=0 N) (set $...
; # (mkChar C)
  %64 = call i64 @mkChar(i32 %63)
; # (cons (mkChar C) $Nil)
  %65 = call i64 @cons(i64 %64, i64 ptrtoint (i8* getelementptr (i8, i8* bitcast ([892 x i64]* @SymTab to i8*), i32 8) to i64))
; # (save X)
  %66 = inttoptr i64 ptrtoint (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 0) to i64) to i64*
  %67 = load i64, i64* %66
  %68 = alloca i64, i64 2, align 16
  %69 = ptrtoint i64* %68 to i64
  %70 = inttoptr i64 %69 to i64*
  store i64 %65, i64* %70
  %71 = add i64 %69, 8
  %72 = inttoptr i64 %71 to i64*
  store i64 %67, i64* %72
  %73 = inttoptr i64 ptrtoint (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 0) to i64) to i64*
  store i64 %69, i64* %73
; # (loop (? (=0 N) (set $Chr 0) R) (? (lt0 (setq C (call $Get))) $Ni...
  br label %$18
$18:
  %74 = phi i64 [%61, %$16], [%147, %$30] ; # Exe
  %75 = phi i64 [%62, %$16], [%148, %$30] ; # N
  %76 = phi i32 [%63, %$16], [%149, %$30] ; # C
  %77 = phi i64 [%65, %$16], [%153, %$30] ; # X
  %78 = phi i64 [%65, %$16], [%151, %$30] ; # R
; # (? (=0 N) (set $Chr 0) R)
; # (=0 N)
  %79 = icmp eq i64 %75, 0
  br i1 %79, label %$21, label %$19
$21:
  %80 = phi i64 [%74, %$18] ; # Exe
  %81 = phi i64 [%75, %$18] ; # N
  %82 = phi i32 [%76, %$18] ; # C
  %83 = phi i64 [%77, %$18] ; # X
  %84 = phi i64 [%78, %$18] ; # R
; # (set $Chr 0)
  store i32 0, i32* bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 168) to i32*)
  br label %$20
$19:
  %85 = phi i64 [%74, %$18] ; # Exe
  %86 = phi i64 [%75, %$18] ; # N
  %87 = phi i32 [%76, %$18] ; # C
  %88 = phi i64 [%77, %$18] ; # X
  %89 = phi i64 [%78, %$18] ; # R
; # (? (lt0 (setq C (call $Get))) $Nil)
; # (call $Get)
  %90 = load i32()*, i32()** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 96) to i32()**)
  %91 = call i32 %90()
; # (lt0 (setq C (call $Get)))
  %92 = icmp slt i32 %91, 0
  br i1 %92, label %$23, label %$22
$23:
  %93 = phi i64 [%85, %$19] ; # Exe
  %94 = phi i64 [%86, %$19] ; # N
  %95 = phi i32 [%91, %$19] ; # C
  %96 = phi i64 [%88, %$19] ; # X
  %97 = phi i64 [%89, %$19] ; # R
  br label %$20
$22:
  %98 = phi i64 [%85, %$19] ; # Exe
  %99 = phi i64 [%86, %$19] ; # N
  %100 = phi i32 [%91, %$19] ; # C
  %101 = phi i64 [%88, %$19] ; # X
  %102 = phi i64 [%89, %$19] ; # R
; # (getChar C)
  %103 = call i32 @getChar(i32 %100)
; # (when (>= C (hex "80")) (dec 'N) (when (>= C (hex "800")) (dec 'N...
; # (>= C (hex "80"))
  %104 = icmp sge i32 %103, 128
  br i1 %104, label %$24, label %$25
$24:
  %105 = phi i64 [%98, %$22] ; # Exe
  %106 = phi i64 [%99, %$22] ; # N
  %107 = phi i32 [%103, %$22] ; # C
  %108 = phi i64 [%101, %$22] ; # X
  %109 = phi i64 [%102, %$22] ; # R
; # (dec 'N)
  %110 = sub i64 %106, 1
; # (when (>= C (hex "800")) (dec 'N) (when (>= C (hex "10000")) (dec...
; # (>= C (hex "800"))
  %111 = icmp sge i32 %107, 2048
  br i1 %111, label %$26, label %$27
$26:
  %112 = phi i64 [%105, %$24] ; # Exe
  %113 = phi i64 [%110, %$24] ; # N
  %114 = phi i32 [%107, %$24] ; # C
  %115 = phi i64 [%108, %$24] ; # X
  %116 = phi i64 [%109, %$24] ; # R
; # (dec 'N)
  %117 = sub i64 %113, 1
; # (when (>= C (hex "10000")) (dec 'N))
; # (>= C (hex "10000"))
  %118 = icmp sge i32 %114, 65536
  br i1 %118, label %$28, label %$29
$28:
  %119 = phi i64 [%112, %$26] ; # Exe
  %120 = phi i64 [%117, %$26] ; # N
  %121 = phi i32 [%114, %$26] ; # C
  %122 = phi i64 [%115, %$26] ; # X
  %123 = phi i64 [%116, %$26] ; # R
; # (dec 'N)
  %124 = sub i64 %120, 1
  br label %$29
$29:
  %125 = phi i64 [%112, %$26], [%119, %$28] ; # Exe
  %126 = phi i64 [%117, %$26], [%124, %$28] ; # N
  %127 = phi i32 [%114, %$26], [%121, %$28] ; # C
  %128 = phi i64 [%115, %$26], [%122, %$28] ; # X
  %129 = phi i64 [%116, %$26], [%123, %$28] ; # R
  br label %$27
$27:
  %130 = phi i64 [%105, %$24], [%125, %$29] ; # Exe
  %131 = phi i64 [%110, %$24], [%126, %$29] ; # N
  %132 = phi i32 [%107, %$24], [%127, %$29] ; # C
  %133 = phi i64 [%108, %$24], [%128, %$29] ; # X
  %134 = phi i64 [%109, %$24], [%129, %$29] ; # R
  br label %$25
$25:
  %135 = phi i64 [%98, %$22], [%130, %$27] ; # Exe
  %136 = phi i64 [%99, %$22], [%131, %$27] ; # N
  %137 = phi i32 [%103, %$22], [%132, %$27] ; # C
  %138 = phi i64 [%101, %$22], [%133, %$27] ; # X
  %139 = phi i64 [%102, %$22], [%134, %$27] ; # R
; # (? (lt0 (dec 'N)) $Nil)
; # (dec 'N)
  %140 = sub i64 %136, 1
; # (lt0 (dec 'N))
  %141 = icmp slt i64 %140, 0
  br i1 %141, label %$31, label %$30
$31:
  %142 = phi i64 [%135, %$25] ; # Exe
  %143 = phi i64 [%140, %$25] ; # N
  %144 = phi i32 [%137, %$25] ; # C
  %145 = phi i64 [%138, %$25] ; # X
  %146 = phi i64 [%139, %$25] ; # R
  br label %$20
$30:
  %147 = phi i64 [%135, %$25] ; # Exe
  %148 = phi i64 [%140, %$25] ; # N
  %149 = phi i32 [%137, %$25] ; # C
  %150 = phi i64 [%138, %$25] ; # X
  %151 = phi i64 [%139, %$25] ; # R
; # (set 2 X (cons (mkChar C) $Nil))
; # (mkChar C)
  %152 = call i64 @mkChar(i32 %149)
; # (cons (mkChar C) $Nil)
  %153 = call i64 @cons(i64 %152, i64 ptrtoint (i8* getelementptr (i8, i8* bitcast ([892 x i64]* @SymTab to i8*), i32 8) to i64))
  %154 = inttoptr i64 %150 to i64*
  %155 = getelementptr i64, i64* %154, i32 1
  store i64 %153, i64* %155
  br label %$18
$20:
  %156 = phi i64 [%80, %$21], [%93, %$23], [%142, %$31] ; # Exe
  %157 = phi i64 [%81, %$21], [%94, %$23], [%143, %$31] ; # N
  %158 = phi i32 [%82, %$21], [%95, %$23], [%144, %$31] ; # C
  %159 = phi i64 [%83, %$21], [%96, %$23], [%145, %$31] ; # X
  %160 = phi i64 [%84, %$21], [%97, %$23], [%146, %$31] ; # R
  %161 = phi i64 [%84, %$21], [ptrtoint (i8* getelementptr (i8, i8* bitcast ([892 x i64]* @SymTab to i8*), i32 8) to i64), %$23], [ptrtoint (i8* getelementptr (i8, i8* bitcast ([892 x i64]* @SymTab to i8*), i32 8) to i64), %$31] ; # ->
; # (drop *Safe)
  %162 = inttoptr i64 %69 to i64*
  %163 = getelementptr i64, i64* %162, i32 1
  %164 = load i64, i64* %163
  %165 = inttoptr i64 ptrtoint (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 0) to i64) to i64*
  store i64 %164, i64* %165
  br label %$17
$17:
  %166 = phi i64 [%58, %$15], [%156, %$20] ; # Exe
  %167 = phi i64 [%59, %$15], [%157, %$20] ; # N
  %168 = phi i32 [%60, %$15], [%158, %$20] ; # C
  %169 = phi i64 [ptrtoint (i8* getelementptr (i8, i8* bitcast ([892 x i64]* @SymTab to i8*), i32 8) to i64), %$15], [%161, %$20] ; # ->
  br label %$8
$8:
  %170 = phi i64 [%25, %$6], [%166, %$17] ; # Exe
  %171 = phi i64 [%26, %$6], [%167, %$17] ; # N
  %172 = phi i32 [%27, %$6], [%30, %$17] ; # C
  %173 = phi i64 [ptrtoint (i8* getelementptr (i8, i8* bitcast ([892 x i64]* @SymTab to i8*), i32 8) to i64), %$6], [%169, %$17] ; # ->
  ret i64 %173
}
@$CnkCnt = global i32 0
@$SvGet = global i32()* null
@$SvPut = global void(i8)* null
@$CnkBuf = global [4000 x i8] zeroinitializer

define i32 @chrHex(i32) align 8 {
$1:
; # (cond ((and (>= C (char "0")) (>= (char "9") C)) (- C 48)) ((and ...
; # (and (>= C (char "0")) (>= (char "9") C))
; # (>= C (char "0"))
  %1 = icmp sge i32 %0, 48
  br i1 %1, label %$4, label %$3
$4:
  %2 = phi i32 [%0, %$1] ; # C
; # (>= (char "9") C)
  %3 = icmp sge i32 57, %2
  br label %$3
$3:
  %4 = phi i32 [%0, %$1], [%2, %$4] ; # C
  %5 = phi i1 [0, %$1], [%3, %$4] ; # ->
  br i1 %5, label %$6, label %$5
$6:
  %6 = phi i32 [%4, %$3] ; # C
; # (- C 48)
  %7 = sub i32 %6, 48
  br label %$2
$5:
  %8 = phi i32 [%4, %$3] ; # C
; # (and (>= (setq C (& C (hex "DF"))) (char "A")) (>= (char "F") C))...
; # (& C (hex "DF"))
  %9 = and i32 %8, 223
; # (>= (setq C (& C (hex "DF"))) (char "A"))
  %10 = icmp sge i32 %9, 65
  br i1 %10, label %$8, label %$7
$8:
  %11 = phi i32 [%9, %$5] ; # C
; # (>= (char "F") C)
  %12 = icmp sge i32 70, %11
  br label %$7
$7:
  %13 = phi i32 [%9, %$5], [%11, %$8] ; # C
  %14 = phi i1 [0, %$5], [%12, %$8] ; # ->
  br i1 %14, label %$10, label %$9
$10:
  %15 = phi i32 [%13, %$7] ; # C
; # (- C 55)
  %16 = sub i32 %15, 55
  br label %$2
$9:
  %17 = phi i32 [%13, %$7] ; # C
  br label %$2
$2:
  %18 = phi i32 [%6, %$6], [%15, %$10], [%17, %$9] ; # C
  %19 = phi i32 [%7, %$6], [%16, %$10], [-1, %$9] ; # ->
  ret i32 %19
}

define void @chunkSize() align 8 {
$1:
; # (let C (if (val $Chr) @ (call $SvGet)) (when (ge0 (set $CnkCnt (c...
; # (if (val $Chr) @ (call $SvGet))
; # (val $Chr)
  %0 = load i32, i32* bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 168) to i32*)
  %1 = icmp ne i32 %0, 0
  br i1 %1, label %$2, label %$3
$2:
  br label %$4
$3:
; # (call $SvGet)
  %2 = load i32()*, i32()** @$SvGet
  %3 = call i32 %2()
  br label %$4
$4:
  %4 = phi i32 [%0, %$2], [%3, %$3] ; # ->
; # (when (ge0 (set $CnkCnt (chrHex C))) (while (ge0 (chrHex (setq C ...
; # (set $CnkCnt (chrHex C))
; # (chrHex C)
  %5 = call i32 @chrHex(i32 %4)
  store i32 %5, i32* @$CnkCnt
; # (ge0 (set $CnkCnt (chrHex C)))
  %6 = icmp sge i32 %5, 0
  br i1 %6, label %$5, label %$6
$5:
  %7 = phi i32 [%4, %$4] ; # C
; # (while (ge0 (chrHex (setq C (call $SvGet)))) (set $CnkCnt (| @ (s...
  br label %$7
$7:
  %8 = phi i32 [%7, %$5], [%13, %$8] ; # C
; # (call $SvGet)
  %9 = load i32()*, i32()** @$SvGet
  %10 = call i32 %9()
; # (chrHex (setq C (call $SvGet)))
  %11 = call i32 @chrHex(i32 %10)
; # (ge0 (chrHex (setq C (call $SvGet))))
  %12 = icmp sge i32 %11, 0
  br i1 %12, label %$8, label %$9
$8:
  %13 = phi i32 [%10, %$7] ; # C
; # (set $CnkCnt (| @ (shl (val $CnkCnt) 4)))
; # (val $CnkCnt)
  %14 = load i32, i32* @$CnkCnt
; # (shl (val $CnkCnt) 4)
  %15 = shl i32 %14, 4
; # (| @ (shl (val $CnkCnt) 4))
  %16 = or i32 %11, %15
  store i32 %16, i32* @$CnkCnt
  br label %$7
$9:
  %17 = phi i32 [%10, %$7] ; # C
; # (loop (? (== C (char "^J")) (call $SvGet) (when (=0 (val $CnkCnt)...
  br label %$10
$10:
  %18 = phi i32 [%17, %$9], [%33, %$16] ; # C
; # (? (== C (char "^J")) (call $SvGet) (when (=0 (val $CnkCnt)) (cal...
; # (== C (char "^J"))
  %19 = icmp eq i32 %18, 10
  br i1 %19, label %$13, label %$11
$13:
  %20 = phi i32 [%18, %$10] ; # C
; # (call $SvGet)
  %21 = load i32()*, i32()** @$SvGet
  %22 = call i32 %21()
; # (when (=0 (val $CnkCnt)) (call $SvGet) (set $Chr 0))
; # (val $CnkCnt)
  %23 = load i32, i32* @$CnkCnt
; # (=0 (val $CnkCnt))
  %24 = icmp eq i32 %23, 0
  br i1 %24, label %$14, label %$15
$14:
  %25 = phi i32 [%20, %$13] ; # C
; # (call $SvGet)
  %26 = load i32()*, i32()** @$SvGet
  %27 = call i32 %26()
; # (set $Chr 0)
  store i32 0, i32* bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 168) to i32*)
  br label %$15
$15:
  %28 = phi i32 [%20, %$13], [%25, %$14] ; # C
  br label %$12
$11:
  %29 = phi i32 [%18, %$10] ; # C
; # (? (lt0 C))
; # (lt0 C)
  %30 = icmp slt i32 %29, 0
  br i1 %30, label %$12, label %$16
$16:
  %31 = phi i32 [%29, %$11] ; # C
; # (call $SvGet)
  %32 = load i32()*, i32()** @$SvGet
  %33 = call i32 %32()
  br label %$10
$12:
  %34 = phi i32 [%28, %$15], [%29, %$11] ; # C
  br label %$6
$6:
  %35 = phi i32 [%4, %$4], [%34, %$12] ; # C
  ret void
}

define i32 @getChunked() align 8 {
$1:
; # (if (le0 (val $CnkCnt)) (set $Chr -1) (call $SvGet) (when (=0 (se...
; # (val $CnkCnt)
  %0 = load i32, i32* @$CnkCnt
; # (le0 (val $CnkCnt))
  %1 = icmp sle i32 %0, 0
  br i1 %1, label %$2, label %$3
$2:
; # (set $Chr -1)
  store i32 -1, i32* bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 168) to i32*)
  br label %$4
$3:
; # (call $SvGet)
  %2 = load i32()*, i32()** @$SvGet
  %3 = call i32 %2()
; # (when (=0 (set $CnkCnt (dec @))) (call $SvGet) (call $SvGet) (chu...
; # (set $CnkCnt (dec @))
; # (dec @)
  %4 = sub i32 %0, 1
  store i32 %4, i32* @$CnkCnt
; # (=0 (set $CnkCnt (dec @)))
  %5 = icmp eq i32 %4, 0
  br i1 %5, label %$5, label %$6
$5:
; # (call $SvGet)
  %6 = load i32()*, i32()** @$SvGet
  %7 = call i32 %6()
; # (call $SvGet)
  %8 = load i32()*, i32()** @$SvGet
  %9 = call i32 %8()
; # (chunkSize)
  call void @chunkSize()
  br label %$6
$6:
; # (val $Chr)
  %10 = load i32, i32* bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 168) to i32*)
  br label %$4
$4:
  %11 = phi i32 [-1, %$2], [%10, %$6] ; # ->
  ret i32 %11
}

define i64 @In(i64) align 8 {
$1:
; # (let X (cdr Exe) (if (nil? (eval (++ X))) (run X) (set (i8** $SvG...
; # (cdr Exe)
  %1 = inttoptr i64 %0 to i64*
  %2 = getelementptr i64, i64* %1, i32 1
  %3 = load i64, i64* %2
; # (if (nil? (eval (++ X))) (run X) (set (i8** $SvGet) (val (i8** $G...
; # (++ X)
  %4 = inttoptr i64 %3 to i64*
  %5 = getelementptr i64, i64* %4, i32 1
  %6 = load i64, i64* %5
  %7 = load i64, i64* %4
; # (eval (++ X))
  %8 = and i64 %7, 6
  %9 = icmp ne i64 %8, 0
  br i1 %9, label %$4, label %$3
$4:
  %10 = phi i64 [%7, %$1] ; # X
  br label %$2
$3:
  %11 = phi i64 [%7, %$1] ; # X
  %12 = and i64 %11, 8
  %13 = icmp ne i64 %12, 0
  br i1 %13, label %$6, label %$5
$6:
  %14 = phi i64 [%11, %$3] ; # X
  %15 = inttoptr i64 %14 to i64*
  %16 = load i64, i64* %15
  br label %$2
$5:
  %17 = phi i64 [%11, %$3] ; # X
  %18 = call i64 @evList(i64 %17)
  br label %$2
$2:
  %19 = phi i64 [%10, %$4], [%14, %$6], [%17, %$5] ; # X
  %20 = phi i64 [%10, %$4], [%16, %$6], [%18, %$5] ; # ->
; # (nil? (eval (++ X)))
  %21 = icmp eq i64 %20, ptrtoint (i8* getelementptr (i8, i8* bitcast ([892 x i64]* @SymTab to i8*), i32 8) to i64)
  br i1 %21, label %$7, label %$8
$7:
  %22 = phi i64 [%0, %$2] ; # Exe
  %23 = phi i64 [%6, %$2] ; # X
; # (run X)
  br label %$10
$10:
  %24 = phi i64 [%23, %$7], [%54, %$19] ; # Prg
  %25 = inttoptr i64 %24 to i64*
  %26 = getelementptr i64, i64* %25, i32 1
  %27 = load i64, i64* %26
  %28 = load i64, i64* %25
  %29 = and i64 %27, 15
  %30 = icmp ne i64 %29, 0
  br i1 %30, label %$13, label %$11
$13:
  %31 = phi i64 [%27, %$10] ; # Prg
  %32 = phi i64 [%28, %$10] ; # X
  %33 = and i64 %32, 6
  %34 = icmp ne i64 %33, 0
  br i1 %34, label %$16, label %$15
$16:
  %35 = phi i64 [%32, %$13] ; # X
  br label %$14
$15:
  %36 = phi i64 [%32, %$13] ; # X
  %37 = and i64 %36, 8
  %38 = icmp ne i64 %37, 0
  br i1 %38, label %$18, label %$17
$18:
  %39 = phi i64 [%36, %$15] ; # X
  %40 = inttoptr i64 %39 to i64*
  %41 = load i64, i64* %40
  br label %$14
$17:
  %42 = phi i64 [%36, %$15] ; # X
  %43 = call i64 @evList(i64 %42)
  br label %$14
$14:
  %44 = phi i64 [%35, %$16], [%39, %$18], [%42, %$17] ; # X
  %45 = phi i64 [%35, %$16], [%41, %$18], [%43, %$17] ; # ->
  br label %$12
$11:
  %46 = phi i64 [%27, %$10] ; # Prg
  %47 = phi i64 [%28, %$10] ; # X
  %48 = and i64 %47, 15
  %49 = icmp eq i64 %48, 0
  br i1 %49, label %$20, label %$19
$20:
  %50 = phi i64 [%46, %$11] ; # Prg
  %51 = phi i64 [%47, %$11] ; # X
  %52 = call i64 @evList(i64 %51)
  %53 = icmp ne i64 %52, 0
  br label %$19
$19:
  %54 = phi i64 [%46, %$11], [%50, %$20] ; # Prg
  %55 = phi i64 [%47, %$11], [%51, %$20] ; # X
  %56 = phi i1 [0, %$11], [%53, %$20] ; # ->
  br label %$10
$12:
  %57 = phi i64 [%31, %$14] ; # Prg
  %58 = phi i64 [%45, %$14] ; # ->
  br label %$9
$8:
  %59 = phi i64 [%0, %$2] ; # Exe
  %60 = phi i64 [%6, %$2] ; # X
; # (set (i8** $SvGet) (val (i8** $Get)) $Get (fun (i32) getChunked))...
; # (i8** $SvGet)
  %61 = bitcast i32()** @$SvGet to i8**
; # (i8** $Get)
  %62 = bitcast i32()** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 96) to i32()**) to i8**
; # (val (i8** $Get))
  %63 = load i8*, i8** %62
  store i8* %63, i8** %61
; # (fun (i32) getChunked)
  store i32()* @getChunked, i32()** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 96) to i32()**)
; # (chunkSize)
  call void @chunkSize()
; # (prog1 (run X) (set (i8** $Get) (val (i8** $SvGet))) (set $Chr 0)...
; # (run X)
  br label %$21
$21:
  %64 = phi i64 [%60, %$8], [%94, %$30] ; # Prg
  %65 = inttoptr i64 %64 to i64*
  %66 = getelementptr i64, i64* %65, i32 1
  %67 = load i64, i64* %66
  %68 = load i64, i64* %65
  %69 = and i64 %67, 15
  %70 = icmp ne i64 %69, 0
  br i1 %70, label %$24, label %$22
$24:
  %71 = phi i64 [%67, %$21] ; # Prg
  %72 = phi i64 [%68, %$21] ; # X
  %73 = and i64 %72, 6
  %74 = icmp ne i64 %73, 0
  br i1 %74, label %$27, label %$26
$27:
  %75 = phi i64 [%72, %$24] ; # X
  br label %$25
$26:
  %76 = phi i64 [%72, %$24] ; # X
  %77 = and i64 %76, 8
  %78 = icmp ne i64 %77, 0
  br i1 %78, label %$29, label %$28
$29:
  %79 = phi i64 [%76, %$26] ; # X
  %80 = inttoptr i64 %79 to i64*
  %81 = load i64, i64* %80
  br label %$25
$28:
  %82 = phi i64 [%76, %$26] ; # X
  %83 = call i64 @evList(i64 %82)
  br label %$25
$25:
  %84 = phi i64 [%75, %$27], [%79, %$29], [%82, %$28] ; # X
  %85 = phi i64 [%75, %$27], [%81, %$29], [%83, %$28] ; # ->
  br label %$23
$22:
  %86 = phi i64 [%67, %$21] ; # Prg
  %87 = phi i64 [%68, %$21] ; # X
  %88 = and i64 %87, 15
  %89 = icmp eq i64 %88, 0
  br i1 %89, label %$31, label %$30
$31:
  %90 = phi i64 [%86, %$22] ; # Prg
  %91 = phi i64 [%87, %$22] ; # X
  %92 = call i64 @evList(i64 %91)
  %93 = icmp ne i64 %92, 0
  br label %$30
$30:
  %94 = phi i64 [%86, %$22], [%90, %$31] ; # Prg
  %95 = phi i64 [%87, %$22], [%91, %$31] ; # X
  %96 = phi i1 [0, %$22], [%93, %$31] ; # ->
  br label %$21
$23:
  %97 = phi i64 [%71, %$25] ; # Prg
  %98 = phi i64 [%85, %$25] ; # ->
; # (set (i8** $Get) (val (i8** $SvGet)))
; # (i8** $Get)
  %99 = bitcast i32()** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 96) to i32()**) to i8**
; # (i8** $SvGet)
  %100 = bitcast i32()** @$SvGet to i8**
; # (val (i8** $SvGet))
  %101 = load i8*, i8** %100
  store i8* %101, i8** %99
; # (set $Chr 0)
  store i32 0, i32* bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 168) to i32*)
  br label %$9
$9:
  %102 = phi i64 [%22, %$12], [%59, %$23] ; # Exe
  %103 = phi i64 [%23, %$12], [%60, %$23] ; # X
  %104 = phi i64 [%58, %$12], [%98, %$23] ; # ->
  ret i64 %104
}

define void @outHex(i32) align 8 {
$1:
; # (when (> N 15) (outHex (shr N 4)) (setq N (& N 15)))
; # (> N 15)
  %1 = icmp sgt i32 %0, 15
  br i1 %1, label %$2, label %$3
$2:
  %2 = phi i32 [%0, %$1] ; # N
; # (shr N 4)
  %3 = lshr i32 %2, 4
; # (outHex (shr N 4))
  call void @outHex(i32 %3)
; # (& N 15)
  %4 = and i32 %2, 15
  br label %$3
$3:
  %5 = phi i32 [%0, %$1], [%4, %$2] ; # N
; # (when (> N 9) (setq N (+ N 39)))
; # (> N 9)
  %6 = icmp sgt i32 %5, 9
  br i1 %6, label %$4, label %$5
$4:
  %7 = phi i32 [%5, %$3] ; # N
; # (+ N 39)
  %8 = add i32 %7, 39
  br label %$5
$5:
  %9 = phi i32 [%5, %$3], [%8, %$4] ; # N
; # (i8 N)
  %10 = trunc i32 %9 to i8
; # (+ (i8 N) (char "0"))
  %11 = add i8 %10, 48
; # (call $SvPut (+ (i8 N) (char "0")))
  %12 = load void(i8)*, void(i8)** @$SvPut
  call void %12(i8 %11)
  ret void
}

define void @wrChunk(i32) align 8 {
$1:
; # (outHex Cnt)
  call void @outHex(i32 %0)
; # (call $SvPut (char "^M"))
  %1 = load void(i8)*, void(i8)** @$SvPut
  call void %1(i8 13)
; # (call $SvPut (char "^J"))
  %2 = load void(i8)*, void(i8)** @$SvPut
  call void %2(i8 10)
; # (let P $CnkBuf (loop (call $SvPut (val P)) (? (=0 (dec 'Cnt))) (i...
; # (loop (call $SvPut (val P)) (? (=0 (dec 'Cnt))) (inc 'P))
  br label %$2
$2:
  %3 = phi i32 [%0, %$1], [%9, %$3] ; # Cnt
  %4 = phi i8* [bitcast ([4000 x i8]* @$CnkBuf to i8*), %$1], [%11, %$3] ; # P
; # (val P)
  %5 = load i8, i8* %4
; # (call $SvPut (val P))
  %6 = load void(i8)*, void(i8)** @$SvPut
  call void %6(i8 %5)
; # (? (=0 (dec 'Cnt)))
; # (dec 'Cnt)
  %7 = sub i32 %3, 1
; # (=0 (dec 'Cnt))
  %8 = icmp eq i32 %7, 0
  br i1 %8, label %$4, label %$3
$3:
  %9 = phi i32 [%7, %$2] ; # Cnt
  %10 = phi i8* [%4, %$2] ; # P
; # (inc 'P)
  %11 = getelementptr i8, i8* %10, i32 1
  br label %$2
$4:
  %12 = phi i32 [%7, %$2] ; # Cnt
  %13 = phi i8* [%4, %$2] ; # P
  %14 = phi i64 [0, %$2] ; # ->
; # (call $SvPut (char "^M"))
  %15 = load void(i8)*, void(i8)** @$SvPut
  call void %15(i8 13)
; # (call $SvPut (char "^J"))
  %16 = load void(i8)*, void(i8)** @$SvPut
  call void %16(i8 10)
  ret void
}

define void @putChunked(i8) align 8 {
$1:
; # (let I (val $CnkCnt) (set (ofs $CnkBuf I) B) (ifn (== (inc I) CHU...
; # (val $CnkCnt)
  %1 = load i32, i32* @$CnkCnt
; # (set (ofs $CnkBuf I) B)
; # (ofs $CnkBuf I)
  %2 = getelementptr i8, i8* bitcast ([4000 x i8]* @$CnkBuf to i8*), i32 %1
  store i8 %0, i8* %2
; # (ifn (== (inc I) CHUNK) (set $CnkCnt @) (wrChunk @) (set $CnkCnt ...
; # (inc I)
  %3 = add i32 %1, 1
; # (== (inc I) CHUNK)
  %4 = icmp eq i32 %3, 4000
  br i1 %4, label %$3, label %$2
$2:
  %5 = phi i8 [%0, %$1] ; # B
  %6 = phi i32 [%1, %$1] ; # I
; # (set $CnkCnt @)
  store i32 %3, i32* @$CnkCnt
  br label %$4
$3:
  %7 = phi i8 [%0, %$1] ; # B
  %8 = phi i32 [%1, %$1] ; # I
; # (wrChunk @)
  call void @wrChunk(i32 %3)
; # (set $CnkCnt 0)
  store i32 0, i32* @$CnkCnt
  br label %$4
$4:
  %9 = phi i8 [%5, %$2], [%7, %$3] ; # B
  %10 = phi i32 [%6, %$2], [%8, %$3] ; # I
  %11 = phi i32 [%3, %$2], [0, %$3] ; # ->
  ret void
}

define i64 @Out(i64) align 8 {
$1:
; # (let (X (cdr Exe) F (eval (++ X))) (if (nil? F) (setq X (run X)) ...
; # (cdr Exe)
  %1 = inttoptr i64 %0 to i64*
  %2 = getelementptr i64, i64* %1, i32 1
  %3 = load i64, i64* %2
; # (++ X)
  %4 = inttoptr i64 %3 to i64*
  %5 = getelementptr i64, i64* %4, i32 1
  %6 = load i64, i64* %5
  %7 = load i64, i64* %4
; # (eval (++ X))
  %8 = and i64 %7, 6
  %9 = icmp ne i64 %8, 0
  br i1 %9, label %$4, label %$3
$4:
  %10 = phi i64 [%7, %$1] ; # X
  br label %$2
$3:
  %11 = phi i64 [%7, %$1] ; # X
  %12 = and i64 %11, 8
  %13 = icmp ne i64 %12, 0
  br i1 %13, label %$6, label %$5
$6:
  %14 = phi i64 [%11, %$3] ; # X
  %15 = inttoptr i64 %14 to i64*
  %16 = load i64, i64* %15
  br label %$2
$5:
  %17 = phi i64 [%11, %$3] ; # X
  %18 = call i64 @evList(i64 %17)
  br label %$2
$2:
  %19 = phi i64 [%10, %$4], [%14, %$6], [%17, %$5] ; # X
  %20 = phi i64 [%10, %$4], [%16, %$6], [%18, %$5] ; # ->
; # (if (nil? F) (setq X (run X)) (set $CnkCnt 0 (i8** $SvPut) (val (...
; # (nil? F)
  %21 = icmp eq i64 %20, ptrtoint (i8* getelementptr (i8, i8* bitcast ([892 x i64]* @SymTab to i8*), i32 8) to i64)
  br i1 %21, label %$7, label %$8
$7:
  %22 = phi i64 [%0, %$2] ; # Exe
  %23 = phi i64 [%6, %$2] ; # X
  %24 = phi i64 [%20, %$2] ; # F
; # (run X)
  br label %$10
$10:
  %25 = phi i64 [%23, %$7], [%55, %$19] ; # Prg
  %26 = inttoptr i64 %25 to i64*
  %27 = getelementptr i64, i64* %26, i32 1
  %28 = load i64, i64* %27
  %29 = load i64, i64* %26
  %30 = and i64 %28, 15
  %31 = icmp ne i64 %30, 0
  br i1 %31, label %$13, label %$11
$13:
  %32 = phi i64 [%28, %$10] ; # Prg
  %33 = phi i64 [%29, %$10] ; # X
  %34 = and i64 %33, 6
  %35 = icmp ne i64 %34, 0
  br i1 %35, label %$16, label %$15
$16:
  %36 = phi i64 [%33, %$13] ; # X
  br label %$14
$15:
  %37 = phi i64 [%33, %$13] ; # X
  %38 = and i64 %37, 8
  %39 = icmp ne i64 %38, 0
  br i1 %39, label %$18, label %$17
$18:
  %40 = phi i64 [%37, %$15] ; # X
  %41 = inttoptr i64 %40 to i64*
  %42 = load i64, i64* %41
  br label %$14
$17:
  %43 = phi i64 [%37, %$15] ; # X
  %44 = call i64 @evList(i64 %43)
  br label %$14
$14:
  %45 = phi i64 [%36, %$16], [%40, %$18], [%43, %$17] ; # X
  %46 = phi i64 [%36, %$16], [%42, %$18], [%44, %$17] ; # ->
  br label %$12
$11:
  %47 = phi i64 [%28, %$10] ; # Prg
  %48 = phi i64 [%29, %$10] ; # X
  %49 = and i64 %48, 15
  %50 = icmp eq i64 %49, 0
  br i1 %50, label %$20, label %$19
$20:
  %51 = phi i64 [%47, %$11] ; # Prg
  %52 = phi i64 [%48, %$11] ; # X
  %53 = call i64 @evList(i64 %52)
  %54 = icmp ne i64 %53, 0
  br label %$19
$19:
  %55 = phi i64 [%47, %$11], [%51, %$20] ; # Prg
  %56 = phi i64 [%48, %$11], [%52, %$20] ; # X
  %57 = phi i1 [0, %$11], [%54, %$20] ; # ->
  br label %$10
$12:
  %58 = phi i64 [%32, %$14] ; # Prg
  %59 = phi i64 [%46, %$14] ; # ->
  br label %$9
$8:
  %60 = phi i64 [%0, %$2] ; # Exe
  %61 = phi i64 [%6, %$2] ; # X
  %62 = phi i64 [%20, %$2] ; # F
; # (set $CnkCnt 0 (i8** $SvPut) (val (i8** $Put)) $Put (fun (void i8...
  store i32 0, i32* @$CnkCnt
; # (i8** $SvPut)
  %63 = bitcast void(i8)** @$SvPut to i8**
; # (i8** $Put)
  %64 = bitcast void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**) to i8**
; # (val (i8** $Put))
  %65 = load i8*, i8** %64
  store i8* %65, i8** %63
; # (fun (void i8) putChunked)
  store void(i8)* @putChunked, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**)
; # (run X)
  br label %$21
$21:
  %66 = phi i64 [%61, %$8], [%96, %$30] ; # Prg
  %67 = inttoptr i64 %66 to i64*
  %68 = getelementptr i64, i64* %67, i32 1
  %69 = load i64, i64* %68
  %70 = load i64, i64* %67
  %71 = and i64 %69, 15
  %72 = icmp ne i64 %71, 0
  br i1 %72, label %$24, label %$22
$24:
  %73 = phi i64 [%69, %$21] ; # Prg
  %74 = phi i64 [%70, %$21] ; # X
  %75 = and i64 %74, 6
  %76 = icmp ne i64 %75, 0
  br i1 %76, label %$27, label %$26
$27:
  %77 = phi i64 [%74, %$24] ; # X
  br label %$25
$26:
  %78 = phi i64 [%74, %$24] ; # X
  %79 = and i64 %78, 8
  %80 = icmp ne i64 %79, 0
  br i1 %80, label %$29, label %$28
$29:
  %81 = phi i64 [%78, %$26] ; # X
  %82 = inttoptr i64 %81 to i64*
  %83 = load i64, i64* %82
  br label %$25
$28:
  %84 = phi i64 [%78, %$26] ; # X
  %85 = call i64 @evList(i64 %84)
  br label %$25
$25:
  %86 = phi i64 [%77, %$27], [%81, %$29], [%84, %$28] ; # X
  %87 = phi i64 [%77, %$27], [%83, %$29], [%85, %$28] ; # ->
  br label %$23
$22:
  %88 = phi i64 [%69, %$21] ; # Prg
  %89 = phi i64 [%70, %$21] ; # X
  %90 = and i64 %89, 15
  %91 = icmp eq i64 %90, 0
  br i1 %91, label %$31, label %$30
$31:
  %92 = phi i64 [%88, %$22] ; # Prg
  %93 = phi i64 [%89, %$22] ; # X
  %94 = call i64 @evList(i64 %93)
  %95 = icmp ne i64 %94, 0
  br label %$30
$30:
  %96 = phi i64 [%88, %$22], [%92, %$31] ; # Prg
  %97 = phi i64 [%89, %$22], [%93, %$31] ; # X
  %98 = phi i1 [0, %$22], [%95, %$31] ; # ->
  br label %$21
$23:
  %99 = phi i64 [%73, %$25] ; # Prg
  %100 = phi i64 [%87, %$25] ; # ->
; # (when (val $CnkCnt) (wrChunk @))
; # (val $CnkCnt)
  %101 = load i32, i32* @$CnkCnt
  %102 = icmp ne i32 %101, 0
  br i1 %102, label %$32, label %$33
$32:
  %103 = phi i64 [%60, %$23] ; # Exe
  %104 = phi i64 [%100, %$23] ; # X
  %105 = phi i64 [%62, %$23] ; # F
; # (wrChunk @)
  call void @wrChunk(i32 %101)
  br label %$33
$33:
  %106 = phi i64 [%60, %$23], [%103, %$32] ; # Exe
  %107 = phi i64 [%100, %$23], [%104, %$32] ; # X
  %108 = phi i64 [%62, %$23], [%105, %$32] ; # F
; # (set (i8** $Put) (val (i8** $SvPut)))
; # (i8** $Put)
  %109 = bitcast void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 88) to void(i8)**) to i8**
; # (i8** $SvPut)
  %110 = bitcast void(i8)** @$SvPut to i8**
; # (val (i8** $SvPut))
  %111 = load i8*, i8** %110
  store i8* %111, i8** %109
; # (unless (t? F) (outString ($ "0^M^J^M^J")))
; # (t? F)
  %112 = icmp eq i64 %108, ptrtoint (i8* getelementptr (i8, i8* bitcast ([892 x i64]* @SymTab to i8*), i32 280) to i64)
  br i1 %112, label %$35, label %$34
$34:
  %113 = phi i64 [%106, %$33] ; # Exe
  %114 = phi i64 [%107, %$33] ; # X
  %115 = phi i64 [%108, %$33] ; # F
; # (outString ($ "0^M^J^M^J"))
  call void @outString(i8* bitcast ([6 x i8]* @$11 to i8*))
  br label %$35
$35:
  %116 = phi i64 [%106, %$33], [%113, %$34] ; # Exe
  %117 = phi i64 [%107, %$33], [%114, %$34] ; # X
  %118 = phi i64 [%108, %$33], [%115, %$34] ; # F
  br label %$9
$9:
  %119 = phi i64 [%22, %$12], [%116, %$35] ; # Exe
  %120 = phi i64 [%59, %$12], [%117, %$35] ; # X
  %121 = phi i64 [%24, %$12], [%118, %$35] ; # F
; # (val $OutFile)
  %122 = load i8*, i8** bitcast (i8* getelementptr (i8, i8* bitcast ([25 x i64]* @env to i8*), i32 80) to i8**)
; # (flush (val $OutFile))
  %123 = call i1 @flush(i8* %122)
  ret i64 %120
}

@$11 = private constant [6 x i8] c"0\0D\0A\0D\0A\00"
@$10 = private constant [6 x i8] c"nbsp;\00"
@$9 = private constant [6 x i8] c"quot;\00"
@$8 = private constant [5 x i8] c"amp;\00"
@$7 = private constant [4 x i8] c"gt;\00"
@$6 = private constant [4 x i8] c"lt;\00"
@$5 = private constant [14 x i8] c" \22#%&:;<=>?\_\00"
@$4 = private constant [7 x i8] c"&quot;\00"
@$3 = private constant [6 x i8] c"&amp;\00"
@$2 = private constant [5 x i8] c"&gt;\00"
@$1 = private constant [5 x i8] c"&lt;\00"
