source_filename = "ht.l"

declare {i64, i1} @llvm.uadd.with.overflow.i64(i64, i64)
declare {i64, i1} @llvm.usub.with.overflow.i64(i64, i64)
declare i64 @llvm.fshl.i64(i64, i64, i64)
declare i64 @llvm.fshr.i64(i64, i64, i64)
declare void @llvm.memcpy.p0i8.p0i8.i64(i8*, i8*, i64, i1)
declare void @llvm.memset.p0i8.i64(i8*, i8, i64, i1)
declare i8* @llvm.stacksave()
declare void @llvm.stackrestore(i8*)

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
@$Current = external global i8*
@$Coroutines = external global i8*
@$StkBrk = external global i8*
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
@$InFile = external global i8*
@$OutFile = external global i8*
@$Chr = external global i32
@$IoCnt = external global i32
@$IoIx = external global i64
@$IoChar = external global i64
@$Put = external global void(i8)*
@$Get = external global i32()*
@$PutBin = external global void(i8)*
@$GetBin = external global i32()*
@$OutFDs = external global i32
@$Nfds = external global i32
@$Poll = external global i64*
@$SeedL = external global i64
@$SeedH = external global i64
@$USec = external global i64
@$TickU = external global i64
@$TickS = external global i64
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
@SymTab = external global [876 x i64]
@gcData = external global [53 x i64]
@cbFuns = external global [24 x i64]
@env = external global [18 x i64]
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
declare void @sigUnblock(i32)
declare void @iSignal(i32, i8*)
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
declare i64 @fileInfo(i1, i8*, i64*)
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
declare i8* @dlOpen(i8*)
declare i8* @ffiPrep(i8*, i8*, i64)
declare i64 @ffiCall(i8*, i64)
declare i64 @boxFloat(i32, i64)
declare i64 @boxFlt()
declare i64 @boxDouble(i64, i64)
declare i64 @boxDbl()
declare void @bufFloat(i64, i64, i8*)
declare void @bufDouble(i64, i64, i8*)
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
declare i1 @subStr(i64, i64)
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
  %4 = phi i64 [%3, %$1], [%88, %$35] ; # X
; # (let Y (eval (car X)) (unless (nil? Y) (if (or (num? Y) (pair Y) ...
; # (car X)
  %5 = inttoptr i64 %4 to i64*
  %6 = load i64, i64* %5
; # (eval (car X))
  %7 = and i64 %6, 6
  %8 = icmp ne i64 %7, 0
  br i1 %8, label %$5, label %$4
$5:
  br label %$3
$4:
  %9 = and i64 %6, 8
  %10 = icmp ne i64 %9, 0
  br i1 %10, label %$7, label %$6
$7:
  %11 = inttoptr i64 %6 to i64*
  %12 = load i64, i64* %11
  br label %$3
$6:
  %13 = call i64 @evList(i64 %6)
  br label %$3
$3:
  %14 = phi i64 [%6, %$5], [%12, %$7], [%13, %$6] ; # ->
; # (unless (nil? Y) (if (or (num? Y) (pair Y) (sym? (val (tail Y))))...
; # (nil? Y)
  %15 = icmp eq i64 %14, ptrtoint (i8* getelementptr (i8, i8* bitcast ([876 x i64]* @SymTab to i8*), i32 8) to i64)
  br i1 %15, label %$9, label %$8
$8:
  %16 = phi i64 [%4, %$3] ; # X
; # (if (or (num? Y) (pair Y) (sym? (val (tail Y)))) (prin Y) (let P ...
; # (or (num? Y) (pair Y) (sym? (val (tail Y))))
; # (num? Y)
  %17 = and i64 %14, 6
  %18 = icmp ne i64 %17, 0
  br i1 %18, label %$10, label %$11
$11:
  %19 = phi i64 [%16, %$8] ; # X
; # (pair Y)
  %20 = and i64 %14, 15
  %21 = icmp eq i64 %20, 0
  br i1 %21, label %$10, label %$12
$12:
  %22 = phi i64 [%19, %$11] ; # X
; # (tail Y)
  %23 = add i64 %14, -8
; # (val (tail Y))
  %24 = inttoptr i64 %23 to i64*
  %25 = load i64, i64* %24
; # (sym? (val (tail Y)))
  %26 = and i64 %25, 8
  %27 = icmp ne i64 %26, 0
  br label %$10
$10:
  %28 = phi i64 [%16, %$8], [%19, %$11], [%22, %$12] ; # X
  %29 = phi i1 [1, %$8], [1, %$11], [%27, %$12] ; # ->
  br i1 %29, label %$13, label %$14
$13:
  %30 = phi i64 [%28, %$10] ; # X
; # (prin Y)
  call void @prin(i64 %14)
  br label %$15
$14:
  %31 = phi i64 [%28, %$10] ; # X
; # (let P (push 0 (name (val (tail Y)))) (while (symByte P) (case @ ...
; # (tail Y)
  %32 = add i64 %14, -8
; # (val (tail Y))
  %33 = inttoptr i64 %32 to i64*
  %34 = load i64, i64* %33
; # (name (val (tail Y)))
  br label %$16
$16:
  %35 = phi i64 [%34, %$14], [%41, %$17] ; # Tail
  %36 = and i64 %35, 6
  %37 = icmp ne i64 %36, 0
  br i1 %37, label %$18, label %$17
$17:
  %38 = phi i64 [%35, %$16] ; # Tail
  %39 = inttoptr i64 %38 to i64*
  %40 = getelementptr i64, i64* %39, i32 1
  %41 = load i64, i64* %40
  br label %$16
$18:
  %42 = phi i64 [%35, %$16] ; # Tail
; # (push 0 (name (val (tail Y))))
  %43 = alloca i64, i64 2, align 16
  store i64 0, i64* %43
  %44 = getelementptr i64, i64* %43, i32 1
  store i64 %42, i64* %44
; # (while (symByte P) (case @ ((char "<") (outString ($ "&lt;"))) ((...
  br label %$19
$19:
  %45 = phi i64 [%31, %$18], [%78, %$23] ; # X
; # (symByte P)
  %46 = call i8 @symByte(i64* %43)
  %47 = icmp ne i8 %46, 0
  br i1 %47, label %$20, label %$21
$20:
  %48 = phi i64 [%45, %$19] ; # X
; # (case @ ((char "<") (outString ($ "&lt;"))) ((char ">") (outStrin...
  switch i8 %46, label %$22 [
    i8 60, label %$24
    i8 62, label %$25
    i8 38, label %$26
    i8 34, label %$27
    i8 255, label %$28
  ]
$24:
  %49 = phi i64 [%48, %$20] ; # X
; # (outString ($ "&lt;"))
  call void @outString(i8* bitcast ([5 x i8]* @$1 to i8*))
  br label %$23
$25:
  %50 = phi i64 [%48, %$20] ; # X
; # (outString ($ "&gt;"))
  call void @outString(i8* bitcast ([5 x i8]* @$2 to i8*))
  br label %$23
$26:
  %51 = phi i64 [%48, %$20] ; # X
; # (outString ($ "&amp;"))
  call void @outString(i8* bitcast ([6 x i8]* @$3 to i8*))
  br label %$23
$27:
  %52 = phi i64 [%48, %$20] ; # X
; # (outString ($ "&quot;"))
  call void @outString(i8* bitcast ([7 x i8]* @$4 to i8*))
  br label %$23
$28:
  %53 = phi i64 [%48, %$20] ; # X
; # (call $Put (hex "F7"))
  %54 = load void(i8)*, void(i8)** @$Put
  call void %54(i8 247)
; # (call $Put (hex "BF"))
  %55 = load void(i8)*, void(i8)** @$Put
  call void %55(i8 191)
; # (call $Put (hex "BF"))
  %56 = load void(i8)*, void(i8)** @$Put
  call void %56(i8 191)
; # (call $Put (hex "BF"))
  %57 = load void(i8)*, void(i8)** @$Put
  call void %57(i8 191)
  br label %$23
$22:
  %58 = phi i64 [%48, %$20] ; # X
; # (let B @ (call $Put B) (when (& B (hex "80")) (call $Put (symByte...
; # (call $Put B)
  %59 = load void(i8)*, void(i8)** @$Put
  call void %59(i8 %46)
; # (when (& B (hex "80")) (call $Put (symByte P)) (when (& B (hex "2...
; # (& B (hex "80"))
  %60 = and i8 %46, 128
  %61 = icmp ne i8 %60, 0
  br i1 %61, label %$29, label %$30
$29:
  %62 = phi i64 [%58, %$22] ; # X
; # (symByte P)
  %63 = call i8 @symByte(i64* %43)
; # (call $Put (symByte P))
  %64 = load void(i8)*, void(i8)** @$Put
  call void %64(i8 %63)
; # (when (& B (hex "20")) (call $Put (symByte P)) (when (& B (hex "1...
; # (& B (hex "20"))
  %65 = and i8 %46, 32
  %66 = icmp ne i8 %65, 0
  br i1 %66, label %$31, label %$32
$31:
  %67 = phi i64 [%62, %$29] ; # X
; # (symByte P)
  %68 = call i8 @symByte(i64* %43)
; # (call $Put (symByte P))
  %69 = load void(i8)*, void(i8)** @$Put
  call void %69(i8 %68)
; # (when (& B (hex "10")) (call $Put (symByte P)))
; # (& B (hex "10"))
  %70 = and i8 %46, 16
  %71 = icmp ne i8 %70, 0
  br i1 %71, label %$33, label %$34
$33:
  %72 = phi i64 [%67, %$31] ; # X
; # (symByte P)
  %73 = call i8 @symByte(i64* %43)
; # (call $Put (symByte P))
  %74 = load void(i8)*, void(i8)** @$Put
  call void %74(i8 %73)
  br label %$34
$34:
  %75 = phi i64 [%67, %$31], [%72, %$33] ; # X
  br label %$32
$32:
  %76 = phi i64 [%62, %$29], [%75, %$34] ; # X
  br label %$30
$30:
  %77 = phi i64 [%58, %$22], [%76, %$32] ; # X
  br label %$23
$23:
  %78 = phi i64 [%49, %$24], [%50, %$25], [%51, %$26], [%52, %$27], [%53, %$28], [%77, %$30] ; # X
  br label %$19
$21:
  %79 = phi i64 [%45, %$19] ; # X
  br label %$15
$15:
  %80 = phi i64 [%30, %$13], [%79, %$21] ; # X
  br label %$9
$9:
  %81 = phi i64 [%4, %$3], [%80, %$15] ; # X
; # (? (atom (shift X)) Y)
; # (shift X)
  %82 = inttoptr i64 %81 to i64*
  %83 = getelementptr i64, i64* %82, i32 1
  %84 = load i64, i64* %83
; # (atom (shift X))
  %85 = and i64 %84, 15
  %86 = icmp ne i64 %85, 0
  br i1 %86, label %$37, label %$35
$37:
  %87 = phi i64 [%84, %$9] ; # X
  br label %$36
$35:
  %88 = phi i64 [%84, %$9] ; # X
  br label %$2
$36:
  %89 = phi i64 [%87, %$37] ; # X
  %90 = phi i64 [%14, %$37] ; # ->
  ret i64 %90
}

define void @putHex(i8) align 8 {
$1:
; # (call $Put (char "%"))
  %1 = load void(i8)*, void(i8)** @$Put
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
; # (+ @ 7)
  %5 = add i8 %3, 7
  br label %$4
$3:
  br label %$4
$4:
  %6 = phi i8 [%5, %$2], [%3, %$3] ; # ->
; # (+ (if (> (& (shr B 4) 15) 9) (+ @ 7) @) (char "0"))
  %7 = add i8 %6, 48
; # (call $Put (+ (if (> (& (shr B 4) 15) 9) (+ @ 7) @) (char "0")))
  %8 = load void(i8)*, void(i8)** @$Put
  call void %8(i8 %7)
; # (if (> (& B 15) 9) (+ @ 7) @)
; # (& B 15)
  %9 = and i8 %0, 15
; # (> (& B 15) 9)
  %10 = icmp ugt i8 %9, 9
  br i1 %10, label %$5, label %$6
$5:
; # (+ @ 7)
  %11 = add i8 %9, 7
  br label %$7
$6:
  br label %$7
$7:
  %12 = phi i8 [%11, %$5], [%9, %$6] ; # ->
; # (+ (if (> (& B 15) 9) (+ @ 7) @) (char "0"))
  %13 = add i8 %12, 48
; # (call $Put (+ (if (> (& B 15) 9) (+ @ 7) @) (char "0")))
  %14 = load void(i8)*, void(i8)** @$Put
  call void %14(i8 %13)
  ret void
}

define void @htEncode(i8, i64*) align 8 {
$1:
; # (while B (if (strchr ($ " \"#%&:;<=>?\\_") (i32 B)) (putHex B) (c...
  br label %$2
$2:
  %2 = phi i8 [%0, %$1], [%30, %$7] ; # B
  %3 = icmp ne i8 %2, 0
  br i1 %3, label %$3, label %$4
$3:
  %4 = phi i8 [%2, %$2] ; # B
; # (if (strchr ($ " \"#%&:;<=>?\\_") (i32 B)) (putHex B) (call $Put ...
; # (i32 B)
  %5 = zext i8 %4 to i32
; # (strchr ($ " \"#%&:;<=>?\\_") (i32 B))
  %6 = call i8* @strchr(i8* bitcast ([14 x i8]* @$5 to i8*), i32 %5)
  %7 = icmp ne i8* %6, null
  br i1 %7, label %$5, label %$6
$5:
  %8 = phi i8 [%4, %$3] ; # B
; # (putHex B)
  call void @putHex(i8 %8)
  br label %$7
$6:
  %9 = phi i8 [%4, %$3] ; # B
; # (call $Put B)
  %10 = load void(i8)*, void(i8)** @$Put
  call void %10(i8 %9)
; # (when (& B (hex "80")) (call $Put (symByte P)) (when (& B (hex "2...
; # (& B (hex "80"))
  %11 = and i8 %9, 128
  %12 = icmp ne i8 %11, 0
  br i1 %12, label %$8, label %$9
$8:
  %13 = phi i8 [%9, %$6] ; # B
; # (symByte P)
  %14 = call i8 @symByte(i64* %1)
; # (call $Put (symByte P))
  %15 = load void(i8)*, void(i8)** @$Put
  call void %15(i8 %14)
; # (when (& B (hex "20")) (call $Put (symByte P)) (when (& B (hex "1...
; # (& B (hex "20"))
  %16 = and i8 %13, 32
  %17 = icmp ne i8 %16, 0
  br i1 %17, label %$10, label %$11
$10:
  %18 = phi i8 [%13, %$8] ; # B
; # (symByte P)
  %19 = call i8 @symByte(i64* %1)
; # (call $Put (symByte P))
  %20 = load void(i8)*, void(i8)** @$Put
  call void %20(i8 %19)
; # (when (& B (hex "10")) (call $Put (symByte P)))
; # (& B (hex "10"))
  %21 = and i8 %18, 16
  %22 = icmp ne i8 %21, 0
  br i1 %22, label %$12, label %$13
$12:
  %23 = phi i8 [%18, %$10] ; # B
; # (symByte P)
  %24 = call i8 @symByte(i64* %1)
; # (call $Put (symByte P))
  %25 = load void(i8)*, void(i8)** @$Put
  call void %25(i8 %24)
  br label %$13
$13:
  %26 = phi i8 [%18, %$10], [%23, %$12] ; # B
  br label %$11
$11:
  %27 = phi i8 [%13, %$8], [%26, %$13] ; # B
  br label %$9
$9:
  %28 = phi i8 [%9, %$6], [%27, %$11] ; # B
  br label %$7
$7:
  %29 = phi i8 [%8, %$5], [%28, %$9] ; # B
; # (symByte P)
  %30 = call i8 @symByte(i64* %1)
  br label %$2
$4:
  %31 = phi i8 [%2, %$2] ; # B
  ret void
}

define void @htFmt(i64) align 8 {
$1:
; # (cond ((nil? X)) ((num? X) (call $Put (char "+")) (prin X)) ((pai...
; # (nil? X)
  %1 = icmp eq i64 %0, ptrtoint (i8* getelementptr (i8, i8* bitcast ([876 x i64]* @SymTab to i8*), i32 8) to i64)
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
  %6 = load void(i8)*, void(i8)** @$Put
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
  %12 = load void(i8)*, void(i8)** @$Put
  call void %12(i8 95)
; # (++ X)
  %13 = inttoptr i64 %11 to i64*
  %14 = load i64, i64* %13
  %15 = getelementptr i64, i64* %13, i32 1
  %16 = load i64, i64* %15
; # (htFmt (++ X))
  call void @htFmt(i64 %14)
; # (? (atom X))
; # (atom X)
  %17 = and i64 %16, 15
  %18 = icmp ne i64 %17, 0
  br i1 %18, label %$10, label %$9
$9:
  %19 = phi i64 [%16, %$8] ; # X
  br label %$8
$10:
  %20 = phi i64 [%16, %$8] ; # X
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
  %29 = load void(i8)*, void(i8)** @$Put
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
; # (call $Put (char "$"))
  %57 = load void(i8)*, void(i8)** @$Put
  call void %57(i8 36)
; # (htEncode B P)
  call void @htEncode(i8 %52, i64* %50)
  br label %$20
$21:
  %58 = phi i64 [%49, %$19] ; # X
; # (or (== B (char "$")) (== B (char "+")) (== B (char "-")))
; # (== B (char "$"))
  %59 = icmp eq i8 %52, 36
  br i1 %59, label %$23, label %$24
$24:
  %60 = phi i64 [%58, %$21] ; # X
; # (== B (char "+"))
  %61 = icmp eq i8 %52, 43
  br i1 %61, label %$23, label %$25
$25:
  %62 = phi i64 [%60, %$24] ; # X
; # (== B (char "-"))
  %63 = icmp eq i8 %52, 45
  br label %$23
$23:
  %64 = phi i64 [%58, %$21], [%60, %$24], [%62, %$25] ; # X
  %65 = phi i1 [1, %$21], [1, %$24], [%63, %$25] ; # ->
  br i1 %65, label %$27, label %$26
$27:
  %66 = phi i64 [%64, %$23] ; # X
; # (putHex B)
  call void @putHex(i8 %52)
; # (symByte P)
  %67 = call i8 @symByte(i64* %50)
; # (htEncode (symByte P) P)
  call void @htEncode(i8 %67, i64* %50)
  br label %$20
$26:
  %68 = phi i64 [%64, %$23] ; # X
; # (htEncode B P)
  call void @htEncode(i8 %52, i64* %50)
  br label %$20
$20:
  %69 = phi i64 [%56, %$22], [%66, %$27], [%68, %$26] ; # X
  br label %$2
$2:
  %70 = phi i64 [%0, %$1], [%5, %$5], [%20, %$10], [%28, %$15], [%39, %$18], [%69, %$20] ; # X
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
  %6 = phi i64 [%3, %$1], [%22, %$8] ; # X
; # (prog2 (tglString P) (eval (car X)) (tglString P))
; # (tglString P)
  call void @tglString(i64* %4)
; # (car X)
  %7 = inttoptr i64 %6 to i64*
  %8 = load i64, i64* %7
; # (eval (car X))
  %9 = and i64 %8, 6
  %10 = icmp ne i64 %9, 0
  br i1 %10, label %$5, label %$4
$5:
  br label %$3
$4:
  %11 = and i64 %8, 8
  %12 = icmp ne i64 %11, 0
  br i1 %12, label %$7, label %$6
$7:
  %13 = inttoptr i64 %8 to i64*
  %14 = load i64, i64* %13
  br label %$3
$6:
  %15 = call i64 @evList(i64 %8)
  br label %$3
$3:
  %16 = phi i64 [%8, %$5], [%14, %$7], [%15, %$6] ; # ->
; # (tglString P)
  call void @tglString(i64* %4)
; # (htFmt (prog2 (tglString P) (eval (car X)) (tglString P)))
  call void @htFmt(i64 %16)
; # (? (atom (shift X)))
; # (shift X)
  %17 = inttoptr i64 %6 to i64*
  %18 = getelementptr i64, i64* %17, i32 1
  %19 = load i64, i64* %18
; # (atom (shift X))
  %20 = and i64 %19, 15
  %21 = icmp ne i64 %20, 0
  br i1 %21, label %$9, label %$8
$8:
  %22 = phi i64 [%19, %$3] ; # X
; # (call $Put (char "&"))
  %23 = load void(i8)*, void(i8)** @$Put
  call void %23(i8 38)
  br label %$2
$9:
  %24 = phi i64 [%19, %$3] ; # X
  %25 = phi i64 [0, %$3] ; # ->
; # (endString)
  %26 = call i64 @endString()
  ret i64 %26
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
; # (& @ (hex "DF"))
  %4 = and i8 %2, 223
; # (- (& @ (hex "DF")) 7)
  %5 = sub i8 %4, 7
  br label %$4
$3:
  br label %$4
$4:
  %6 = phi i8 [%5, %$2], [%2, %$3] ; # ->
  ret i8 %6
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
  %7 = load i64, i64* %6
  %8 = getelementptr i64, i64* %6, i32 1
  %9 = load i64, i64* %8
; # (firstByte (++ Lst))
  %10 = call i8 @firstByte(i64 %7)
; # (<> B (firstByte (++ Lst)))
  %11 = icmp ne i8 %5, %10
  br i1 %11, label %$5, label %$3
$5:
  %12 = phi i8* [%3, %$2] ; # S
  %13 = phi i64 [%9, %$2] ; # Lst
  %14 = phi i8 [%5, %$2] ; # B
  br label %$4
$3:
  %15 = phi i8* [%3, %$2] ; # S
  %16 = phi i64 [%9, %$2] ; # Lst
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
  %5 = load i64, i64* %4
  %6 = getelementptr i64, i64* %4, i32 1
  %7 = load i64, i64* %6
; # (eval (++ X))
  %8 = and i64 %5, 6
  %9 = icmp ne i64 %8, 0
  br i1 %9, label %$4, label %$3
$4:
  br label %$2
$3:
  %10 = and i64 %5, 8
  %11 = icmp ne i64 %10, 0
  br i1 %11, label %$6, label %$5
$6:
  %12 = inttoptr i64 %5 to i64*
  %13 = load i64, i64* %12
  br label %$2
$5:
  %14 = call i64 @evList(i64 %5)
  br label %$2
$2:
  %15 = phi i64 [%5, %$4], [%13, %$6], [%14, %$5] ; # ->
; # (save (eval (++ X)))
  %16 = inttoptr i64 ptrtoint (i8* getelementptr (i8, i8* bitcast ([18 x i64]* @env to i8*), i32 0) to i64) to i64*
  %17 = load i64, i64* %16
  %18 = alloca i64, i64 2, align 16
  %19 = ptrtoint i64* %18 to i64
  %20 = inttoptr i64 %19 to i64*
  store i64 %15, i64* %20
  %21 = add i64 %19, 8
  %22 = inttoptr i64 %21 to i64*
  store i64 %17, i64* %22
  %23 = inttoptr i64 ptrtoint (i8* getelementptr (i8, i8* bitcast ([18 x i64]* @env to i8*), i32 0) to i64) to i64*
  store i64 %19, i64* %23
; # (car X)
  %24 = inttoptr i64 %7 to i64*
  %25 = load i64, i64* %24
; # (eval (car X))
  %26 = and i64 %25, 6
  %27 = icmp ne i64 %26, 0
  br i1 %27, label %$9, label %$8
$9:
  br label %$7
$8:
  %28 = and i64 %25, 8
  %29 = icmp ne i64 %28, 0
  br i1 %29, label %$11, label %$10
$11:
  %30 = inttoptr i64 %25 to i64*
  %31 = load i64, i64* %30
  br label %$7
$10:
  %32 = call i64 @evList(i64 %25)
  br label %$7
$7:
  %33 = phi i64 [%25, %$9], [%31, %$11], [%32, %$10] ; # ->
; # (nil? (eval (car X)))
  %34 = icmp eq i64 %33, ptrtoint (i8* getelementptr (i8, i8* bitcast ([876 x i64]* @SymTab to i8*), i32 8) to i64)
; # (push 4 NIL ZERO NIL NIL NIL)
  %35 = alloca i64, i64 6, align 16
  store i64 4, i64* %35
  %36 = getelementptr i64, i64* %35, i32 2
  store i64 2, i64* %36
; # (begString (push 4 NIL ZERO NIL NIL NIL))
  call void @begString(i64* %35)
; # (while (pair Lst) (let (C (++ Lst) B (firstByte C)) (cond ((== B ...
  br label %$12
$12:
  %37 = phi i64 [%15, %$7], [%159, %$15] ; # Lst
; # (pair Lst)
  %38 = and i64 %37, 15
  %39 = icmp eq i64 %38, 0
  br i1 %39, label %$13, label %$14
$13:
  %40 = phi i64 [%37, %$12] ; # Lst
; # (let (C (++ Lst) B (firstByte C)) (cond ((== B (char "%")) (call ...
; # (++ Lst)
  %41 = inttoptr i64 %40 to i64*
  %42 = load i64, i64* %41
  %43 = getelementptr i64, i64* %41, i32 1
  %44 = load i64, i64* %43
; # (firstByte C)
  %45 = call i8 @firstByte(i64 %42)
; # (cond ((== B (char "%")) (call $Put (if Flg B (| (shl (getHex (++...
; # (== B (char "%"))
  %46 = icmp eq i8 %45, 37
  br i1 %46, label %$17, label %$16
$17:
  %47 = phi i64 [%44, %$13] ; # Lst
; # (if Flg B (| (shl (getHex (++ Lst)) 4) (getHex (++ Lst))))
  br i1 %34, label %$18, label %$19
$18:
  %48 = phi i64 [%47, %$17] ; # Lst
  br label %$20
$19:
  %49 = phi i64 [%47, %$17] ; # Lst
; # (++ Lst)
  %50 = inttoptr i64 %49 to i64*
  %51 = load i64, i64* %50
  %52 = getelementptr i64, i64* %50, i32 1
  %53 = load i64, i64* %52
; # (getHex (++ Lst))
  %54 = call i8 @getHex(i64 %51)
; # (shl (getHex (++ Lst)) 4)
  %55 = shl i8 %54, 4
; # (++ Lst)
  %56 = inttoptr i64 %53 to i64*
  %57 = load i64, i64* %56
  %58 = getelementptr i64, i64* %56, i32 1
  %59 = load i64, i64* %58
; # (getHex (++ Lst))
  %60 = call i8 @getHex(i64 %57)
; # (| (shl (getHex (++ Lst)) 4) (getHex (++ Lst)))
  %61 = or i8 %55, %60
  br label %$20
$20:
  %62 = phi i64 [%48, %$18], [%59, %$19] ; # Lst
  %63 = phi i8 [%45, %$18], [%61, %$19] ; # ->
; # (call $Put (if Flg B (| (shl (getHex (++ Lst)) 4) (getHex (++ Lst...
  %64 = load void(i8)*, void(i8)** @$Put
  call void %64(i8 %63)
  br label %$15
$16:
  %65 = phi i64 [%44, %$13] ; # Lst
; # (<> B (char "&"))
  %66 = icmp ne i8 %45, 38
  br i1 %66, label %$22, label %$21
$22:
  %67 = phi i64 [%65, %$16] ; # Lst
; # (prSym C)
  call void @prSym(i64 %42)
  br label %$15
$21:
  %68 = phi i64 [%65, %$16] ; # Lst
; # (head ($ "lt;") Lst)
  %69 = call i64 @head(i8* bitcast ([4 x i8]* @$6 to i8*), i64 %68)
  %70 = icmp ne i64 %69, 0
  br i1 %70, label %$24, label %$23
$24:
  %71 = phi i64 [%68, %$21] ; # Lst
; # (call $Put (char "<"))
  %72 = load void(i8)*, void(i8)** @$Put
  call void %72(i8 60)
  br label %$15
$23:
  %73 = phi i64 [%68, %$21] ; # Lst
; # (head ($ "gt;") Lst)
  %74 = call i64 @head(i8* bitcast ([4 x i8]* @$7 to i8*), i64 %73)
  %75 = icmp ne i64 %74, 0
  br i1 %75, label %$26, label %$25
$26:
  %76 = phi i64 [%73, %$23] ; # Lst
; # (call $Put (char ">"))
  %77 = load void(i8)*, void(i8)** @$Put
  call void %77(i8 62)
  br label %$15
$25:
  %78 = phi i64 [%73, %$23] ; # Lst
; # (head ($ "amp;") Lst)
  %79 = call i64 @head(i8* bitcast ([5 x i8]* @$8 to i8*), i64 %78)
  %80 = icmp ne i64 %79, 0
  br i1 %80, label %$28, label %$27
$28:
  %81 = phi i64 [%78, %$25] ; # Lst
; # (call $Put (char "&"))
  %82 = load void(i8)*, void(i8)** @$Put
  call void %82(i8 38)
  br label %$15
$27:
  %83 = phi i64 [%78, %$25] ; # Lst
; # (head ($ "quot;") Lst)
  %84 = call i64 @head(i8* bitcast ([6 x i8]* @$9 to i8*), i64 %83)
  %85 = icmp ne i64 %84, 0
  br i1 %85, label %$30, label %$29
$30:
  %86 = phi i64 [%83, %$27] ; # Lst
; # (call $Put (char "\""))
  %87 = load void(i8)*, void(i8)** @$Put
  call void %87(i8 34)
  br label %$15
$29:
  %88 = phi i64 [%83, %$27] ; # Lst
; # (head ($ "nbsp;") Lst)
  %89 = call i64 @head(i8* bitcast ([6 x i8]* @$10 to i8*), i64 %88)
  %90 = icmp ne i64 %89, 0
  br i1 %90, label %$32, label %$31
$32:
  %91 = phi i64 [%88, %$29] ; # Lst
; # (call $Put (char " "))
  %92 = load void(i8)*, void(i8)** @$Put
  call void %92(i8 32)
  br label %$15
$31:
  %93 = phi i64 [%88, %$29] ; # Lst
; # (car Lst)
  %94 = inttoptr i64 %93 to i64*
  %95 = load i64, i64* %94
; # (firstByte (car Lst))
  %96 = call i8 @firstByte(i64 %95)
; # (== (firstByte (car Lst)) (char "#"))
  %97 = icmp eq i8 %96, 35
  br i1 %97, label %$34, label %$33
$34:
  %98 = phi i64 [%93, %$31] ; # Lst
; # (let (L (shift Lst) D (firstByte (++ L)) N (i32 (- D (char "0")))...
; # (shift Lst)
  %99 = inttoptr i64 %98 to i64*
  %100 = getelementptr i64, i64* %99, i32 1
  %101 = load i64, i64* %100
; # (++ L)
  %102 = inttoptr i64 %101 to i64*
  %103 = load i64, i64* %102
  %104 = getelementptr i64, i64* %102, i32 1
  %105 = load i64, i64* %104
; # (firstByte (++ L))
  %106 = call i8 @firstByte(i64 %103)
; # (- D (char "0"))
  %107 = sub i8 %106, 48
; # (i32 (- D (char "0")))
  %108 = zext i8 %107 to i32
; # (loop (? (or (> (char "0") D) (> D (char "9"))) (call $Put (char ...
  br label %$35
$35:
  %109 = phi i64 [%101, %$34], [%145, %$41] ; # Lst
  %110 = phi i64 [%105, %$34], [%146, %$41] ; # L
  %111 = phi i8 [%106, %$34], [%147, %$41] ; # D
  %112 = phi i32 [%108, %$34], [%152, %$41] ; # N
; # (? (or (> (char "0") D) (> D (char "9"))) (call $Put (char "&")) ...
; # (or (> (char "0") D) (> D (char "9")))
; # (> (char "0") D)
  %113 = icmp ugt i8 48, %111
  br i1 %113, label %$36, label %$37
$37:
  %114 = phi i64 [%109, %$35] ; # Lst
  %115 = phi i64 [%110, %$35] ; # L
  %116 = phi i8 [%111, %$35] ; # D
  %117 = phi i32 [%112, %$35] ; # N
; # (> D (char "9"))
  %118 = icmp ugt i8 %116, 57
  br label %$36
$36:
  %119 = phi i64 [%109, %$35], [%114, %$37] ; # Lst
  %120 = phi i64 [%110, %$35], [%115, %$37] ; # L
  %121 = phi i8 [%111, %$35], [%116, %$37] ; # D
  %122 = phi i32 [%112, %$35], [%117, %$37] ; # N
  %123 = phi i1 [1, %$35], [%118, %$37] ; # ->
  br i1 %123, label %$40, label %$38
$40:
  %124 = phi i64 [%119, %$36] ; # Lst
  %125 = phi i64 [%120, %$36] ; # L
  %126 = phi i8 [%121, %$36] ; # D
  %127 = phi i32 [%122, %$36] ; # N
; # (call $Put (char "&"))
  %128 = load void(i8)*, void(i8)** @$Put
  call void %128(i8 38)
; # (call $Put (char "#"))
  %129 = load void(i8)*, void(i8)** @$Put
  call void %129(i8 35)
  br label %$39
$38:
  %130 = phi i64 [%119, %$36] ; # Lst
  %131 = phi i64 [%120, %$36] ; # L
  %132 = phi i8 [%121, %$36] ; # D
  %133 = phi i32 [%122, %$36] ; # N
; # (? (== (setq D (firstByte (++ L))) (char ";")) (prSym (mkChar N))...
; # (++ L)
  %134 = inttoptr i64 %131 to i64*
  %135 = load i64, i64* %134
  %136 = getelementptr i64, i64* %134, i32 1
  %137 = load i64, i64* %136
; # (firstByte (++ L))
  %138 = call i8 @firstByte(i64 %135)
; # (== (setq D (firstByte (++ L))) (char ";"))
  %139 = icmp eq i8 %138, 59
  br i1 %139, label %$42, label %$41
$42:
  %140 = phi i64 [%130, %$38] ; # Lst
  %141 = phi i64 [%137, %$38] ; # L
  %142 = phi i8 [%138, %$38] ; # D
  %143 = phi i32 [%133, %$38] ; # N
; # (mkChar N)
  %144 = call i64 @mkChar(i32 %143)
; # (prSym (mkChar N))
  call void @prSym(i64 %144)
  br label %$39
$41:
  %145 = phi i64 [%130, %$38] ; # Lst
  %146 = phi i64 [%137, %$38] ; # L
  %147 = phi i8 [%138, %$38] ; # D
  %148 = phi i32 [%133, %$38] ; # N
; # (* N 10)
  %149 = mul i32 %148, 10
; # (- D (char "0"))
  %150 = sub i8 %147, 48
; # (i32 (- D (char "0")))
  %151 = zext i8 %150 to i32
; # (+ (* N 10) (i32 (- D (char "0"))))
  %152 = add i32 %149, %151
  br label %$35
$39:
  %153 = phi i64 [%124, %$40], [%141, %$42] ; # Lst
  %154 = phi i64 [%125, %$40], [%141, %$42] ; # L
  %155 = phi i8 [%126, %$40], [%142, %$42] ; # D
  %156 = phi i32 [%127, %$40], [%143, %$42] ; # N
  br label %$15
$33:
  %157 = phi i64 [%93, %$31] ; # Lst
; # (call $Put (char "&"))
  %158 = load void(i8)*, void(i8)** @$Put
  call void %158(i8 38)
  br label %$15
$15:
  %159 = phi i64 [%62, %$20], [%67, %$22], [%69, %$24], [%74, %$26], [%79, %$28], [%84, %$30], [%89, %$32], [%153, %$39], [%157, %$33] ; # Lst
  br label %$12
$14:
  %160 = phi i64 [%37, %$12] ; # Lst
; # (endString)
  %161 = call i64 @endString()
; # (drop *Safe)
  %162 = inttoptr i64 %19 to i64*
  %163 = getelementptr i64, i64* %162, i32 1
  %164 = load i64, i64* %163
  %165 = inttoptr i64 ptrtoint (i8* getelementptr (i8, i8* bitcast ([18 x i64]* @env to i8*), i32 0) to i64) to i64*
  store i64 %164, i64* %165
  ret i64 %161
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
  %5 = load i32, i32* @$Chr
; # (if (or (le0 N) (and (=0 C) (lt0 (setq C (call $Get))))) $Nil (le...
; # (or (le0 N) (and (=0 C) (lt0 (setq C (call $Get)))))
; # (le0 N)
  %6 = icmp sle i64 %4, 0
  br i1 %6, label %$2, label %$3
$3:
  %7 = phi i64 [%4, %$1] ; # N
  %8 = phi i32 [%5, %$1] ; # C
; # (and (=0 C) (lt0 (setq C (call $Get))))
; # (=0 C)
  %9 = icmp eq i32 %8, 0
  br i1 %9, label %$5, label %$4
$5:
  %10 = phi i64 [%7, %$3] ; # N
  %11 = phi i32 [%8, %$3] ; # C
; # (call $Get)
  %12 = load i32()*, i32()** @$Get
  %13 = call i32 %12()
; # (lt0 (setq C (call $Get)))
  %14 = icmp slt i32 %13, 0
  br label %$4
$4:
  %15 = phi i64 [%7, %$3], [%10, %$5] ; # N
  %16 = phi i32 [%8, %$3], [%13, %$5] ; # C
  %17 = phi i1 [0, %$3], [%14, %$5] ; # ->
  br label %$2
$2:
  %18 = phi i64 [%4, %$1], [%15, %$4] ; # N
  %19 = phi i32 [%5, %$1], [%16, %$4] ; # C
  %20 = phi i1 [1, %$1], [%17, %$4] ; # ->
  br i1 %20, label %$6, label %$7
$6:
  %21 = phi i64 [%18, %$2] ; # N
  %22 = phi i32 [%19, %$2] ; # C
  br label %$8
$7:
  %23 = phi i64 [%18, %$2] ; # N
  %24 = phi i32 [%19, %$2] ; # C
; # (let C (getChar C) (when (>= C (hex "80")) (dec 'N) (when (>= C (...
; # (getChar C)
  %25 = call i32 @getChar(i32 %24)
; # (when (>= C (hex "80")) (dec 'N) (when (>= C (hex "800")) (dec 'N...
; # (>= C (hex "80"))
  %26 = icmp sge i32 %25, 128
  br i1 %26, label %$9, label %$10
$9:
  %27 = phi i64 [%23, %$7] ; # N
  %28 = phi i32 [%25, %$7] ; # C
; # (dec 'N)
  %29 = sub i64 %27, 1
; # (when (>= C (hex "800")) (dec 'N) (when (>= C (hex "10000")) (dec...
; # (>= C (hex "800"))
  %30 = icmp sge i32 %28, 2048
  br i1 %30, label %$11, label %$12
$11:
  %31 = phi i64 [%29, %$9] ; # N
  %32 = phi i32 [%28, %$9] ; # C
; # (dec 'N)
  %33 = sub i64 %31, 1
; # (when (>= C (hex "10000")) (dec 'N))
; # (>= C (hex "10000"))
  %34 = icmp sge i32 %32, 65536
  br i1 %34, label %$13, label %$14
$13:
  %35 = phi i64 [%33, %$11] ; # N
  %36 = phi i32 [%32, %$11] ; # C
; # (dec 'N)
  %37 = sub i64 %35, 1
  br label %$14
$14:
  %38 = phi i64 [%33, %$11], [%37, %$13] ; # N
  %39 = phi i32 [%32, %$11], [%36, %$13] ; # C
  br label %$12
$12:
  %40 = phi i64 [%29, %$9], [%38, %$14] ; # N
  %41 = phi i32 [%28, %$9], [%39, %$14] ; # C
  br label %$10
$10:
  %42 = phi i64 [%23, %$7], [%40, %$12] ; # N
  %43 = phi i32 [%25, %$7], [%41, %$12] ; # C
; # (if (lt0 (dec 'N)) $Nil (let (X (cons (mkChar C) $Nil) R (save X)...
; # (dec 'N)
  %44 = sub i64 %42, 1
; # (lt0 (dec 'N))
  %45 = icmp slt i64 %44, 0
  br i1 %45, label %$15, label %$16
$15:
  %46 = phi i64 [%44, %$10] ; # N
  %47 = phi i32 [%43, %$10] ; # C
  br label %$17
$16:
  %48 = phi i64 [%44, %$10] ; # N
  %49 = phi i32 [%43, %$10] ; # C
; # (let (X (cons (mkChar C) $Nil) R (save X)) (loop (? (=0 N) (set $...
; # (mkChar C)
  %50 = call i64 @mkChar(i32 %49)
; # (cons (mkChar C) $Nil)
  %51 = call i64 @cons(i64 %50, i64 ptrtoint (i8* getelementptr (i8, i8* bitcast ([876 x i64]* @SymTab to i8*), i32 8) to i64))
; # (save X)
  %52 = inttoptr i64 ptrtoint (i8* getelementptr (i8, i8* bitcast ([18 x i64]* @env to i8*), i32 0) to i64) to i64*
  %53 = load i64, i64* %52
  %54 = alloca i64, i64 2, align 16
  %55 = ptrtoint i64* %54 to i64
  %56 = inttoptr i64 %55 to i64*
  store i64 %51, i64* %56
  %57 = add i64 %55, 8
  %58 = inttoptr i64 %57 to i64*
  store i64 %53, i64* %58
  %59 = inttoptr i64 ptrtoint (i8* getelementptr (i8, i8* bitcast ([18 x i64]* @env to i8*), i32 0) to i64) to i64*
  store i64 %55, i64* %59
; # (loop (? (=0 N) (set $Chr 0) R) (? (lt0 (setq C (call $Get))) $Ni...
  br label %$18
$18:
  %60 = phi i64 [%48, %$16], [%109, %$30] ; # N
  %61 = phi i32 [%49, %$16], [%110, %$30] ; # C
  %62 = phi i64 [%51, %$16], [%113, %$30] ; # X
; # (? (=0 N) (set $Chr 0) R)
; # (=0 N)
  %63 = icmp eq i64 %60, 0
  br i1 %63, label %$21, label %$19
$21:
  %64 = phi i64 [%60, %$18] ; # N
  %65 = phi i32 [%61, %$18] ; # C
  %66 = phi i64 [%62, %$18] ; # X
; # (set $Chr 0)
  store i32 0, i32* @$Chr
  br label %$20
$19:
  %67 = phi i64 [%60, %$18] ; # N
  %68 = phi i32 [%61, %$18] ; # C
  %69 = phi i64 [%62, %$18] ; # X
; # (? (lt0 (setq C (call $Get))) $Nil)
; # (call $Get)
  %70 = load i32()*, i32()** @$Get
  %71 = call i32 %70()
; # (lt0 (setq C (call $Get)))
  %72 = icmp slt i32 %71, 0
  br i1 %72, label %$23, label %$22
$23:
  %73 = phi i64 [%67, %$19] ; # N
  %74 = phi i32 [%71, %$19] ; # C
  %75 = phi i64 [%69, %$19] ; # X
  br label %$20
$22:
  %76 = phi i64 [%67, %$19] ; # N
  %77 = phi i32 [%71, %$19] ; # C
  %78 = phi i64 [%69, %$19] ; # X
; # (getChar C)
  %79 = call i32 @getChar(i32 %77)
; # (when (>= C (hex "80")) (dec 'N) (when (>= C (hex "800")) (dec 'N...
; # (>= C (hex "80"))
  %80 = icmp sge i32 %79, 128
  br i1 %80, label %$24, label %$25
$24:
  %81 = phi i64 [%76, %$22] ; # N
  %82 = phi i32 [%79, %$22] ; # C
  %83 = phi i64 [%78, %$22] ; # X
; # (dec 'N)
  %84 = sub i64 %81, 1
; # (when (>= C (hex "800")) (dec 'N) (when (>= C (hex "10000")) (dec...
; # (>= C (hex "800"))
  %85 = icmp sge i32 %82, 2048
  br i1 %85, label %$26, label %$27
$26:
  %86 = phi i64 [%84, %$24] ; # N
  %87 = phi i32 [%82, %$24] ; # C
  %88 = phi i64 [%83, %$24] ; # X
; # (dec 'N)
  %89 = sub i64 %86, 1
; # (when (>= C (hex "10000")) (dec 'N))
; # (>= C (hex "10000"))
  %90 = icmp sge i32 %87, 65536
  br i1 %90, label %$28, label %$29
$28:
  %91 = phi i64 [%89, %$26] ; # N
  %92 = phi i32 [%87, %$26] ; # C
  %93 = phi i64 [%88, %$26] ; # X
; # (dec 'N)
  %94 = sub i64 %91, 1
  br label %$29
$29:
  %95 = phi i64 [%89, %$26], [%94, %$28] ; # N
  %96 = phi i32 [%87, %$26], [%92, %$28] ; # C
  %97 = phi i64 [%88, %$26], [%93, %$28] ; # X
  br label %$27
$27:
  %98 = phi i64 [%84, %$24], [%95, %$29] ; # N
  %99 = phi i32 [%82, %$24], [%96, %$29] ; # C
  %100 = phi i64 [%83, %$24], [%97, %$29] ; # X
  br label %$25
$25:
  %101 = phi i64 [%76, %$22], [%98, %$27] ; # N
  %102 = phi i32 [%79, %$22], [%99, %$27] ; # C
  %103 = phi i64 [%78, %$22], [%100, %$27] ; # X
; # (? (lt0 (dec 'N)) $Nil)
; # (dec 'N)
  %104 = sub i64 %101, 1
; # (lt0 (dec 'N))
  %105 = icmp slt i64 %104, 0
  br i1 %105, label %$31, label %$30
$31:
  %106 = phi i64 [%104, %$25] ; # N
  %107 = phi i32 [%102, %$25] ; # C
  %108 = phi i64 [%103, %$25] ; # X
  br label %$20
$30:
  %109 = phi i64 [%104, %$25] ; # N
  %110 = phi i32 [%102, %$25] ; # C
  %111 = phi i64 [%103, %$25] ; # X
; # (set 2 X (cons (mkChar C) $Nil))
; # (mkChar C)
  %112 = call i64 @mkChar(i32 %110)
; # (cons (mkChar C) $Nil)
  %113 = call i64 @cons(i64 %112, i64 ptrtoint (i8* getelementptr (i8, i8* bitcast ([876 x i64]* @SymTab to i8*), i32 8) to i64))
  %114 = inttoptr i64 %111 to i64*
  %115 = getelementptr i64, i64* %114, i32 1
  store i64 %113, i64* %115
  br label %$18
$20:
  %116 = phi i64 [%64, %$21], [%73, %$23], [%106, %$31] ; # N
  %117 = phi i32 [%65, %$21], [%74, %$23], [%107, %$31] ; # C
  %118 = phi i64 [%66, %$21], [%75, %$23], [%108, %$31] ; # X
  %119 = phi i64 [%51, %$21], [ptrtoint (i8* getelementptr (i8, i8* bitcast ([876 x i64]* @SymTab to i8*), i32 8) to i64), %$23], [ptrtoint (i8* getelementptr (i8, i8* bitcast ([876 x i64]* @SymTab to i8*), i32 8) to i64), %$31] ; # ->
; # (drop *Safe)
  %120 = inttoptr i64 %55 to i64*
  %121 = getelementptr i64, i64* %120, i32 1
  %122 = load i64, i64* %121
  %123 = inttoptr i64 ptrtoint (i8* getelementptr (i8, i8* bitcast ([18 x i64]* @env to i8*), i32 0) to i64) to i64*
  store i64 %122, i64* %123
  br label %$17
$17:
  %124 = phi i64 [%46, %$15], [%116, %$20] ; # N
  %125 = phi i32 [%47, %$15], [%117, %$20] ; # C
  %126 = phi i64 [ptrtoint (i8* getelementptr (i8, i8* bitcast ([876 x i64]* @SymTab to i8*), i32 8) to i64), %$15], [%119, %$20] ; # ->
  br label %$8
$8:
  %127 = phi i64 [%21, %$6], [%124, %$17] ; # N
  %128 = phi i32 [%22, %$6], [%24, %$17] ; # C
  %129 = phi i64 [ptrtoint (i8* getelementptr (i8, i8* bitcast ([876 x i64]* @SymTab to i8*), i32 8) to i64), %$6], [%126, %$17] ; # ->
  ret i64 %129
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
; # (let C (val $Chr) (unless C (setq C (call $SvGet))) (when (ge0 (s...
; # (val $Chr)
  %0 = load i32, i32* @$Chr
; # (unless C (setq C (call $SvGet)))
  %1 = icmp ne i32 %0, 0
  br i1 %1, label %$3, label %$2
$2:
  %2 = phi i32 [%0, %$1] ; # C
; # (call $SvGet)
  %3 = load i32()*, i32()** @$SvGet
  %4 = call i32 %3()
  br label %$3
$3:
  %5 = phi i32 [%0, %$1], [%4, %$2] ; # C
; # (when (ge0 (set $CnkCnt (chrHex C))) (while (ge0 (chrHex (setq C ...
; # (set $CnkCnt (chrHex C))
; # (chrHex C)
  %6 = call i32 @chrHex(i32 %5)
  store i32 %6, i32* @$CnkCnt
; # (ge0 (set $CnkCnt (chrHex C)))
  %7 = icmp sge i32 %6, 0
  br i1 %7, label %$4, label %$5
$4:
  %8 = phi i32 [%5, %$3] ; # C
; # (while (ge0 (chrHex (setq C (call $SvGet)))) (set $CnkCnt (| @ (s...
  br label %$6
$6:
  %9 = phi i32 [%8, %$4], [%14, %$7] ; # C
; # (call $SvGet)
  %10 = load i32()*, i32()** @$SvGet
  %11 = call i32 %10()
; # (chrHex (setq C (call $SvGet)))
  %12 = call i32 @chrHex(i32 %11)
; # (ge0 (chrHex (setq C (call $SvGet))))
  %13 = icmp sge i32 %12, 0
  br i1 %13, label %$7, label %$8
$7:
  %14 = phi i32 [%11, %$6] ; # C
; # (set $CnkCnt (| @ (shl (val $CnkCnt) 4)))
; # (val $CnkCnt)
  %15 = load i32, i32* @$CnkCnt
; # (shl (val $CnkCnt) 4)
  %16 = shl i32 %15, 4
; # (| @ (shl (val $CnkCnt) 4))
  %17 = or i32 %12, %16
  store i32 %17, i32* @$CnkCnt
  br label %$6
$8:
  %18 = phi i32 [%11, %$6] ; # C
; # (loop (? (== C (char "^J")) (call $SvGet) (when (=0 (val $CnkCnt)...
  br label %$9
$9:
  %19 = phi i32 [%18, %$8], [%34, %$15] ; # C
; # (? (== C (char "^J")) (call $SvGet) (when (=0 (val $CnkCnt)) (cal...
; # (== C (char "^J"))
  %20 = icmp eq i32 %19, 10
  br i1 %20, label %$12, label %$10
$12:
  %21 = phi i32 [%19, %$9] ; # C
; # (call $SvGet)
  %22 = load i32()*, i32()** @$SvGet
  %23 = call i32 %22()
; # (when (=0 (val $CnkCnt)) (call $SvGet) (set $Chr 0))
; # (val $CnkCnt)
  %24 = load i32, i32* @$CnkCnt
; # (=0 (val $CnkCnt))
  %25 = icmp eq i32 %24, 0
  br i1 %25, label %$13, label %$14
$13:
  %26 = phi i32 [%21, %$12] ; # C
; # (call $SvGet)
  %27 = load i32()*, i32()** @$SvGet
  %28 = call i32 %27()
; # (set $Chr 0)
  store i32 0, i32* @$Chr
  br label %$14
$14:
  %29 = phi i32 [%21, %$12], [%26, %$13] ; # C
  br label %$11
$10:
  %30 = phi i32 [%19, %$9] ; # C
; # (? (lt0 C))
; # (lt0 C)
  %31 = icmp slt i32 %30, 0
  br i1 %31, label %$11, label %$15
$15:
  %32 = phi i32 [%30, %$10] ; # C
; # (call $SvGet)
  %33 = load i32()*, i32()** @$SvGet
  %34 = call i32 %33()
  br label %$9
$11:
  %35 = phi i32 [%29, %$14], [%30, %$10] ; # C
  br label %$5
$5:
  %36 = phi i32 [%5, %$3], [%35, %$11] ; # C
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
  store i32 -1, i32* @$Chr
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
  %10 = load i32, i32* @$Chr
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
  %5 = load i64, i64* %4
  %6 = getelementptr i64, i64* %4, i32 1
  %7 = load i64, i64* %6
; # (eval (++ X))
  %8 = and i64 %5, 6
  %9 = icmp ne i64 %8, 0
  br i1 %9, label %$4, label %$3
$4:
  br label %$2
$3:
  %10 = and i64 %5, 8
  %11 = icmp ne i64 %10, 0
  br i1 %11, label %$6, label %$5
$6:
  %12 = inttoptr i64 %5 to i64*
  %13 = load i64, i64* %12
  br label %$2
$5:
  %14 = call i64 @evList(i64 %5)
  br label %$2
$2:
  %15 = phi i64 [%5, %$4], [%13, %$6], [%14, %$5] ; # ->
; # (nil? (eval (++ X)))
  %16 = icmp eq i64 %15, ptrtoint (i8* getelementptr (i8, i8* bitcast ([876 x i64]* @SymTab to i8*), i32 8) to i64)
  br i1 %16, label %$7, label %$8
$7:
  %17 = phi i64 [%7, %$2] ; # X
; # (run X)
  br label %$10
$10:
  %18 = phi i64 [%17, %$7], [%40, %$19] ; # Prg
  %19 = inttoptr i64 %18 to i64*
  %20 = load i64, i64* %19
  %21 = getelementptr i64, i64* %19, i32 1
  %22 = load i64, i64* %21
  %23 = and i64 %22, 15
  %24 = icmp ne i64 %23, 0
  br i1 %24, label %$13, label %$11
$13:
  %25 = phi i64 [%22, %$10] ; # Prg
  %26 = and i64 %20, 6
  %27 = icmp ne i64 %26, 0
  br i1 %27, label %$16, label %$15
$16:
  br label %$14
$15:
  %28 = and i64 %20, 8
  %29 = icmp ne i64 %28, 0
  br i1 %29, label %$18, label %$17
$18:
  %30 = inttoptr i64 %20 to i64*
  %31 = load i64, i64* %30
  br label %$14
$17:
  %32 = call i64 @evList(i64 %20)
  br label %$14
$14:
  %33 = phi i64 [%20, %$16], [%31, %$18], [%32, %$17] ; # ->
  br label %$12
$11:
  %34 = phi i64 [%22, %$10] ; # Prg
  %35 = and i64 %20, 15
  %36 = icmp eq i64 %35, 0
  br i1 %36, label %$20, label %$19
$20:
  %37 = phi i64 [%34, %$11] ; # Prg
  %38 = call i64 @evList(i64 %20)
  %39 = icmp ne i64 %38, 0
  br label %$19
$19:
  %40 = phi i64 [%34, %$11], [%37, %$20] ; # Prg
  %41 = phi i1 [0, %$11], [%39, %$20] ; # ->
  br label %$10
$12:
  %42 = phi i64 [%25, %$14] ; # Prg
  %43 = phi i64 [%33, %$14] ; # ->
  br label %$9
$8:
  %44 = phi i64 [%7, %$2] ; # X
; # (set (i8** $SvGet) (val (i8** $Get)) $Get (fun (i32) getChunked))...
; # (i8** $SvGet)
  %45 = bitcast i32()** @$SvGet to i8**
; # (i8** $Get)
  %46 = bitcast i32()** @$Get to i8**
; # (val (i8** $Get))
  %47 = load i8*, i8** %46
  store i8* %47, i8** %45
; # (fun (i32) getChunked)
  store i32()* @getChunked, i32()** @$Get
; # (chunkSize)
  call void @chunkSize()
; # (prog1 (run X) (set (i8** $Get) (val (i8** $SvGet))) (set $Chr 0)...
; # (run X)
  br label %$21
$21:
  %48 = phi i64 [%44, %$8], [%70, %$30] ; # Prg
  %49 = inttoptr i64 %48 to i64*
  %50 = load i64, i64* %49
  %51 = getelementptr i64, i64* %49, i32 1
  %52 = load i64, i64* %51
  %53 = and i64 %52, 15
  %54 = icmp ne i64 %53, 0
  br i1 %54, label %$24, label %$22
$24:
  %55 = phi i64 [%52, %$21] ; # Prg
  %56 = and i64 %50, 6
  %57 = icmp ne i64 %56, 0
  br i1 %57, label %$27, label %$26
$27:
  br label %$25
$26:
  %58 = and i64 %50, 8
  %59 = icmp ne i64 %58, 0
  br i1 %59, label %$29, label %$28
$29:
  %60 = inttoptr i64 %50 to i64*
  %61 = load i64, i64* %60
  br label %$25
$28:
  %62 = call i64 @evList(i64 %50)
  br label %$25
$25:
  %63 = phi i64 [%50, %$27], [%61, %$29], [%62, %$28] ; # ->
  br label %$23
$22:
  %64 = phi i64 [%52, %$21] ; # Prg
  %65 = and i64 %50, 15
  %66 = icmp eq i64 %65, 0
  br i1 %66, label %$31, label %$30
$31:
  %67 = phi i64 [%64, %$22] ; # Prg
  %68 = call i64 @evList(i64 %50)
  %69 = icmp ne i64 %68, 0
  br label %$30
$30:
  %70 = phi i64 [%64, %$22], [%67, %$31] ; # Prg
  %71 = phi i1 [0, %$22], [%69, %$31] ; # ->
  br label %$21
$23:
  %72 = phi i64 [%55, %$25] ; # Prg
  %73 = phi i64 [%63, %$25] ; # ->
; # (set (i8** $Get) (val (i8** $SvGet)))
; # (i8** $Get)
  %74 = bitcast i32()** @$Get to i8**
; # (i8** $SvGet)
  %75 = bitcast i32()** @$SvGet to i8**
; # (val (i8** $SvGet))
  %76 = load i8*, i8** %75
  store i8* %76, i8** %74
; # (set $Chr 0)
  store i32 0, i32* @$Chr
  br label %$9
$9:
  %77 = phi i64 [%17, %$12], [%44, %$23] ; # X
  %78 = phi i64 [%43, %$12], [%73, %$23] ; # ->
  ret i64 %78
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
; # (set $CnkCnt @)
  store i32 %3, i32* @$CnkCnt
  br label %$4
$3:
; # (wrChunk @)
  call void @wrChunk(i32 %3)
; # (set $CnkCnt 0)
  store i32 0, i32* @$CnkCnt
  br label %$4
$4:
  %5 = phi i32 [%3, %$2], [0, %$3] ; # ->
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
  %5 = load i64, i64* %4
  %6 = getelementptr i64, i64* %4, i32 1
  %7 = load i64, i64* %6
; # (eval (++ X))
  %8 = and i64 %5, 6
  %9 = icmp ne i64 %8, 0
  br i1 %9, label %$4, label %$3
$4:
  br label %$2
$3:
  %10 = and i64 %5, 8
  %11 = icmp ne i64 %10, 0
  br i1 %11, label %$6, label %$5
$6:
  %12 = inttoptr i64 %5 to i64*
  %13 = load i64, i64* %12
  br label %$2
$5:
  %14 = call i64 @evList(i64 %5)
  br label %$2
$2:
  %15 = phi i64 [%5, %$4], [%13, %$6], [%14, %$5] ; # ->
; # (if (nil? F) (setq X (run X)) (set $CnkCnt 0 (i8** $SvPut) (val (...
; # (nil? F)
  %16 = icmp eq i64 %15, ptrtoint (i8* getelementptr (i8, i8* bitcast ([876 x i64]* @SymTab to i8*), i32 8) to i64)
  br i1 %16, label %$7, label %$8
$7:
  %17 = phi i64 [%7, %$2] ; # X
; # (run X)
  br label %$10
$10:
  %18 = phi i64 [%17, %$7], [%40, %$19] ; # Prg
  %19 = inttoptr i64 %18 to i64*
  %20 = load i64, i64* %19
  %21 = getelementptr i64, i64* %19, i32 1
  %22 = load i64, i64* %21
  %23 = and i64 %22, 15
  %24 = icmp ne i64 %23, 0
  br i1 %24, label %$13, label %$11
$13:
  %25 = phi i64 [%22, %$10] ; # Prg
  %26 = and i64 %20, 6
  %27 = icmp ne i64 %26, 0
  br i1 %27, label %$16, label %$15
$16:
  br label %$14
$15:
  %28 = and i64 %20, 8
  %29 = icmp ne i64 %28, 0
  br i1 %29, label %$18, label %$17
$18:
  %30 = inttoptr i64 %20 to i64*
  %31 = load i64, i64* %30
  br label %$14
$17:
  %32 = call i64 @evList(i64 %20)
  br label %$14
$14:
  %33 = phi i64 [%20, %$16], [%31, %$18], [%32, %$17] ; # ->
  br label %$12
$11:
  %34 = phi i64 [%22, %$10] ; # Prg
  %35 = and i64 %20, 15
  %36 = icmp eq i64 %35, 0
  br i1 %36, label %$20, label %$19
$20:
  %37 = phi i64 [%34, %$11] ; # Prg
  %38 = call i64 @evList(i64 %20)
  %39 = icmp ne i64 %38, 0
  br label %$19
$19:
  %40 = phi i64 [%34, %$11], [%37, %$20] ; # Prg
  %41 = phi i1 [0, %$11], [%39, %$20] ; # ->
  br label %$10
$12:
  %42 = phi i64 [%25, %$14] ; # Prg
  %43 = phi i64 [%33, %$14] ; # ->
  br label %$9
$8:
  %44 = phi i64 [%7, %$2] ; # X
; # (set $CnkCnt 0 (i8** $SvPut) (val (i8** $Put)) $Put (fun (void i8...
  store i32 0, i32* @$CnkCnt
; # (i8** $SvPut)
  %45 = bitcast void(i8)** @$SvPut to i8**
; # (i8** $Put)
  %46 = bitcast void(i8)** @$Put to i8**
; # (val (i8** $Put))
  %47 = load i8*, i8** %46
  store i8* %47, i8** %45
; # (fun (void i8) putChunked)
  store void(i8)* @putChunked, void(i8)** @$Put
; # (run X)
  br label %$21
$21:
  %48 = phi i64 [%44, %$8], [%70, %$30] ; # Prg
  %49 = inttoptr i64 %48 to i64*
  %50 = load i64, i64* %49
  %51 = getelementptr i64, i64* %49, i32 1
  %52 = load i64, i64* %51
  %53 = and i64 %52, 15
  %54 = icmp ne i64 %53, 0
  br i1 %54, label %$24, label %$22
$24:
  %55 = phi i64 [%52, %$21] ; # Prg
  %56 = and i64 %50, 6
  %57 = icmp ne i64 %56, 0
  br i1 %57, label %$27, label %$26
$27:
  br label %$25
$26:
  %58 = and i64 %50, 8
  %59 = icmp ne i64 %58, 0
  br i1 %59, label %$29, label %$28
$29:
  %60 = inttoptr i64 %50 to i64*
  %61 = load i64, i64* %60
  br label %$25
$28:
  %62 = call i64 @evList(i64 %50)
  br label %$25
$25:
  %63 = phi i64 [%50, %$27], [%61, %$29], [%62, %$28] ; # ->
  br label %$23
$22:
  %64 = phi i64 [%52, %$21] ; # Prg
  %65 = and i64 %50, 15
  %66 = icmp eq i64 %65, 0
  br i1 %66, label %$31, label %$30
$31:
  %67 = phi i64 [%64, %$22] ; # Prg
  %68 = call i64 @evList(i64 %50)
  %69 = icmp ne i64 %68, 0
  br label %$30
$30:
  %70 = phi i64 [%64, %$22], [%67, %$31] ; # Prg
  %71 = phi i1 [0, %$22], [%69, %$31] ; # ->
  br label %$21
$23:
  %72 = phi i64 [%55, %$25] ; # Prg
  %73 = phi i64 [%63, %$25] ; # ->
; # (when (val $CnkCnt) (wrChunk @))
; # (val $CnkCnt)
  %74 = load i32, i32* @$CnkCnt
  %75 = icmp ne i32 %74, 0
  br i1 %75, label %$32, label %$33
$32:
  %76 = phi i64 [%73, %$23] ; # X
; # (wrChunk @)
  call void @wrChunk(i32 %74)
  br label %$33
$33:
  %77 = phi i64 [%73, %$23], [%76, %$32] ; # X
; # (set (i8** $Put) (val (i8** $SvPut)))
; # (i8** $Put)
  %78 = bitcast void(i8)** @$Put to i8**
; # (i8** $SvPut)
  %79 = bitcast void(i8)** @$SvPut to i8**
; # (val (i8** $SvPut))
  %80 = load i8*, i8** %79
  store i8* %80, i8** %78
; # (unless (t? F) (outString ($ "0^M^J^M^J")))
; # (t? F)
  %81 = icmp eq i64 %15, ptrtoint (i8* getelementptr (i8, i8* bitcast ([876 x i64]* @SymTab to i8*), i32 280) to i64)
  br i1 %81, label %$35, label %$34
$34:
  %82 = phi i64 [%77, %$33] ; # X
; # (outString ($ "0^M^J^M^J"))
  call void @outString(i8* bitcast ([6 x i8]* @$11 to i8*))
  br label %$35
$35:
  %83 = phi i64 [%77, %$33], [%82, %$34] ; # X
  br label %$9
$9:
  %84 = phi i64 [%43, %$12], [%83, %$35] ; # X
; # (val $OutFile)
  %85 = load i8*, i8** @$OutFile
; # (flush (val $OutFile))
  %86 = call i1 @flush(i8* %85)
  ret i64 %84
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
