source_filename = "ht.l"

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
@$OutFiles = external global i8**
@$InFDs = external global i32
@$OutFDs = external global i32
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
declare i32 @gPoll(i64*, i64, i64)
declare i1 @readyIn(i64*, i32)
declare i1 @readyOut(i64*, i32)
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
declare void @prin(i64)
declare i8 @symByte(i64*)
declare void @prExt(i64)
declare void @begString(i64*)
declare void @tglString(i64*)
declare i64 @endString()
declare i64 @isLstIntern(i64, i64)

define i64 @Prin(i64) {
$1:
; # (let X (cdr Exe) (loop (let Y (eval (car X)) (if (or (num? Y) (pa...
; # (cdr Exe)
  %1 = inttoptr i64 %0 to i64*
  %2 = getelementptr i64, i64* %1, i32 1
  %3 = load i64, i64* %2
; # (loop (let Y (eval (car X)) (if (or (num? Y) (pair Y) (sym? (val ...
  br label %$2
$2:
  %4 = phi i64 [%3, %$1], [%85, %$33] ; # X
; # (let Y (eval (car X)) (if (or (num? Y) (pair Y) (sym? (val (tail ...
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
; # (if (or (num? Y) (pair Y) (sym? (val (tail Y)))) (prin Y) (let P ...
; # (or (num? Y) (pair Y) (sym? (val (tail Y))))
; # (num? Y)
  %15 = and i64 %14, 6
  %16 = icmp ne i64 %15, 0
  br i1 %16, label %$8, label %$9
$9:
  %17 = phi i64 [%4, %$3] ; # X
; # (pair Y)
  %18 = and i64 %14, 15
  %19 = icmp eq i64 %18, 0
  br i1 %19, label %$8, label %$10
$10:
  %20 = phi i64 [%17, %$9] ; # X
; # (tail Y)
  %21 = add i64 %14, -8
; # (val (tail Y))
  %22 = inttoptr i64 %21 to i64*
  %23 = load i64, i64* %22
; # (sym? (val (tail Y)))
  %24 = and i64 %23, 8
  %25 = icmp ne i64 %24, 0
  br label %$8
$8:
  %26 = phi i64 [%4, %$3], [%17, %$9], [%20, %$10] ; # X
  %27 = phi i1 [1, %$3], [1, %$9], [%25, %$10] ; # ->
  br i1 %27, label %$11, label %$12
$11:
  %28 = phi i64 [%26, %$8] ; # X
; # (prin Y)
  call void @prin(i64 %14)
  br label %$13
$12:
  %29 = phi i64 [%26, %$8] ; # X
; # (let P (push 0 (name (val (tail Y)))) (while (symByte P) (case @ ...
; # (tail Y)
  %30 = add i64 %14, -8
; # (val (tail Y))
  %31 = inttoptr i64 %30 to i64*
  %32 = load i64, i64* %31
; # (name (val (tail Y)))
  br label %$14
$14:
  %33 = phi i64 [%32, %$12], [%39, %$15] ; # Tail
  %34 = and i64 %33, 6
  %35 = icmp ne i64 %34, 0
  br i1 %35, label %$16, label %$15
$15:
  %36 = phi i64 [%33, %$14] ; # Tail
  %37 = inttoptr i64 %36 to i64*
  %38 = getelementptr i64, i64* %37, i32 1
  %39 = load i64, i64* %38
  br label %$14
$16:
  %40 = phi i64 [%33, %$14] ; # Tail
; # (push 0 (name (val (tail Y))))
  %41 = alloca i64, i64 2, align 16
  store i64 0, i64* %41
  %42 = getelementptr i64, i64* %41, i32 1
  store i64 %40, i64* %42
; # (while (symByte P) (case @ ((char "<") (outString ($ "&lt;"))) ((...
  br label %$17
$17:
  %43 = phi i64 [%29, %$16], [%76, %$21] ; # X
; # (symByte P)
  %44 = call i8 @symByte(i64* %41)
  %45 = icmp ne i8 %44, 0
  br i1 %45, label %$18, label %$19
$18:
  %46 = phi i64 [%43, %$17] ; # X
; # (case @ ((char "<") (outString ($ "&lt;"))) ((char ">") (outStrin...
  switch i8 %44, label %$20 [
    i8 60, label %$22
    i8 62, label %$23
    i8 38, label %$24
    i8 34, label %$25
    i8 255, label %$26
  ]
$22:
  %47 = phi i64 [%46, %$18] ; # X
; # (outString ($ "&lt;"))
  call void @outString(i8* bitcast ([5 x i8]* @$1 to i8*))
  br label %$21
$23:
  %48 = phi i64 [%46, %$18] ; # X
; # (outString ($ "&gt;"))
  call void @outString(i8* bitcast ([5 x i8]* @$2 to i8*))
  br label %$21
$24:
  %49 = phi i64 [%46, %$18] ; # X
; # (outString ($ "&amp;"))
  call void @outString(i8* bitcast ([6 x i8]* @$3 to i8*))
  br label %$21
$25:
  %50 = phi i64 [%46, %$18] ; # X
; # (outString ($ "&quot;"))
  call void @outString(i8* bitcast ([7 x i8]* @$4 to i8*))
  br label %$21
$26:
  %51 = phi i64 [%46, %$18] ; # X
; # (call $Put (hex "F7"))
  %52 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 80) to void(i8)**)
  call void %52(i8 247)
; # (call $Put (hex "BF"))
  %53 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 80) to void(i8)**)
  call void %53(i8 191)
; # (call $Put (hex "BF"))
  %54 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 80) to void(i8)**)
  call void %54(i8 191)
; # (call $Put (hex "BF"))
  %55 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 80) to void(i8)**)
  call void %55(i8 191)
  br label %$21
$20:
  %56 = phi i64 [%46, %$18] ; # X
; # (let B @ (call $Put B) (when (& B (hex "80")) (call $Put (symByte...
; # (call $Put B)
  %57 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 80) to void(i8)**)
  call void %57(i8 %44)
; # (when (& B (hex "80")) (call $Put (symByte P)) (when (& B (hex "2...
; # (& B (hex "80"))
  %58 = and i8 %44, 128
  %59 = icmp ne i8 %58, 0
  br i1 %59, label %$27, label %$28
$27:
  %60 = phi i64 [%56, %$20] ; # X
; # (symByte P)
  %61 = call i8 @symByte(i64* %41)
; # (call $Put (symByte P))
  %62 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 80) to void(i8)**)
  call void %62(i8 %61)
; # (when (& B (hex "20")) (call $Put (symByte P)) (when (& B (hex "1...
; # (& B (hex "20"))
  %63 = and i8 %44, 32
  %64 = icmp ne i8 %63, 0
  br i1 %64, label %$29, label %$30
$29:
  %65 = phi i64 [%60, %$27] ; # X
; # (symByte P)
  %66 = call i8 @symByte(i64* %41)
; # (call $Put (symByte P))
  %67 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 80) to void(i8)**)
  call void %67(i8 %66)
; # (when (& B (hex "10")) (call $Put (symByte P)))
; # (& B (hex "10"))
  %68 = and i8 %44, 16
  %69 = icmp ne i8 %68, 0
  br i1 %69, label %$31, label %$32
$31:
  %70 = phi i64 [%65, %$29] ; # X
; # (symByte P)
  %71 = call i8 @symByte(i64* %41)
; # (call $Put (symByte P))
  %72 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 80) to void(i8)**)
  call void %72(i8 %71)
  br label %$32
$32:
  %73 = phi i64 [%65, %$29], [%70, %$31] ; # X
  br label %$30
$30:
  %74 = phi i64 [%60, %$27], [%73, %$32] ; # X
  br label %$28
$28:
  %75 = phi i64 [%56, %$20], [%74, %$30] ; # X
  br label %$21
$21:
  %76 = phi i64 [%47, %$22], [%48, %$23], [%49, %$24], [%50, %$25], [%51, %$26], [%75, %$28] ; # X
  br label %$17
$19:
  %77 = phi i64 [%43, %$17] ; # X
  br label %$13
$13:
  %78 = phi i64 [%28, %$11], [%77, %$19] ; # X
; # (? (atom (shift X)) Y)
; # (shift X)
  %79 = inttoptr i64 %78 to i64*
  %80 = getelementptr i64, i64* %79, i32 1
  %81 = load i64, i64* %80
; # (atom (shift X))
  %82 = and i64 %81, 15
  %83 = icmp ne i64 %82, 0
  br i1 %83, label %$35, label %$33
$35:
  %84 = phi i64 [%81, %$13] ; # X
  br label %$34
$33:
  %85 = phi i64 [%81, %$13] ; # X
  br label %$2
$34:
  %86 = phi i64 [%84, %$35] ; # X
  %87 = phi i64 [%14, %$35] ; # ->
  ret i64 %87
}

define void @putHex(i8) {
$1:
; # (call $Put (char "%"))
  %1 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 80) to void(i8)**)
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
  %8 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 80) to void(i8)**)
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
  %14 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 80) to void(i8)**)
  call void %14(i8 %13)
  ret void
}

define void @htFmt(i64) {
$1:
; # (cond ((nil? X)) ((num? X) (call $Put (char "+")) (prin X)) ((pai...
; # (nil? X)
  %1 = icmp eq i64 %0, ptrtoint (i8* getelementptr (i8, i8* bitcast ([840 x i64]* @SymTab to i8*), i32 8) to i64)
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
  %6 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 80) to void(i8)**)
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
  %12 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 80) to void(i8)**)
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
  %29 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 80) to void(i8)**)
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
; # (let (Nm @ P (push 0 Nm) B (symByte P)) (if (== X (isLstIntern Nm...
; # (push 0 Nm)
  %50 = alloca i64, i64 2, align 16
  store i64 0, i64* %50
  %51 = getelementptr i64, i64* %50, i32 1
  store i64 %47, i64* %51
; # (symByte P)
  %52 = call i8 @symByte(i64* %50)
; # (if (== X (isLstIntern Nm (val $Intern))) (call $Put (char "$")) ...
; # (val $Intern)
  %53 = inttoptr i64 ptrtoint (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 120) to i64) to i64*
  %54 = load i64, i64* %53
; # (isLstIntern Nm (val $Intern))
  %55 = call i64 @isLstIntern(i64 %47, i64 %54)
; # (== X (isLstIntern Nm (val $Intern)))
  %56 = icmp eq i64 %49, %55
  br i1 %56, label %$20, label %$21
$20:
  %57 = phi i64 [%49, %$19] ; # X
  %58 = phi i8 [%52, %$19] ; # B
; # (call $Put (char "$"))
  %59 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 80) to void(i8)**)
  call void %59(i8 36)
  br label %$22
$21:
  %60 = phi i64 [%49, %$19] ; # X
  %61 = phi i8 [%52, %$19] ; # B
; # (if (or (== B (char "$")) (== B (char "+")) (== B (char "-"))) (p...
; # (or (== B (char "$")) (== B (char "+")) (== B (char "-")))
; # (== B (char "$"))
  %62 = icmp eq i8 %61, 36
  br i1 %62, label %$23, label %$24
$24:
  %63 = phi i64 [%60, %$21] ; # X
  %64 = phi i8 [%61, %$21] ; # B
; # (== B (char "+"))
  %65 = icmp eq i8 %64, 43
  br i1 %65, label %$23, label %$25
$25:
  %66 = phi i64 [%63, %$24] ; # X
  %67 = phi i8 [%64, %$24] ; # B
; # (== B (char "-"))
  %68 = icmp eq i8 %67, 45
  br label %$23
$23:
  %69 = phi i64 [%60, %$21], [%63, %$24], [%66, %$25] ; # X
  %70 = phi i8 [%61, %$21], [%64, %$24], [%67, %$25] ; # B
  %71 = phi i1 [1, %$21], [1, %$24], [%68, %$25] ; # ->
  br i1 %71, label %$26, label %$27
$26:
  %72 = phi i64 [%69, %$23] ; # X
  %73 = phi i8 [%70, %$23] ; # B
; # (putHex B)
  call void @putHex(i8 %73)
  br label %$28
$27:
  %74 = phi i64 [%69, %$23] ; # X
  %75 = phi i8 [%70, %$23] ; # B
; # (call $Put B)
  %76 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 80) to void(i8)**)
  call void %76(i8 %75)
  br label %$28
$28:
  %77 = phi i64 [%72, %$26], [%74, %$27] ; # X
  %78 = phi i8 [%73, %$26], [%75, %$27] ; # B
; # (symByte P)
  %79 = call i8 @symByte(i64* %50)
  br label %$22
$22:
  %80 = phi i64 [%57, %$20], [%77, %$28] ; # X
  %81 = phi i8 [%58, %$20], [%79, %$28] ; # B
; # (while B (if (strchr ($ " \"#%&:;<=>?\\_") (i32 B)) (putHex B) (c...
  br label %$29
$29:
  %82 = phi i64 [%80, %$22], [%119, %$34] ; # X
  %83 = phi i8 [%81, %$22], [%121, %$34] ; # B
  %84 = icmp ne i8 %83, 0
  br i1 %84, label %$30, label %$31
$30:
  %85 = phi i64 [%82, %$29] ; # X
  %86 = phi i8 [%83, %$29] ; # B
; # (if (strchr ($ " \"#%&:;<=>?\\_") (i32 B)) (putHex B) (call $Put ...
; # (i32 B)
  %87 = zext i8 %86 to i32
; # (strchr ($ " \"#%&:;<=>?\\_") (i32 B))
  %88 = call i8* @strchr(i8* bitcast ([14 x i8]* @$5 to i8*), i32 %87)
  %89 = icmp ne i8* %88, null
  br i1 %89, label %$32, label %$33
$32:
  %90 = phi i64 [%85, %$30] ; # X
  %91 = phi i8 [%86, %$30] ; # B
; # (putHex B)
  call void @putHex(i8 %91)
  br label %$34
$33:
  %92 = phi i64 [%85, %$30] ; # X
  %93 = phi i8 [%86, %$30] ; # B
; # (call $Put B)
  %94 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 80) to void(i8)**)
  call void %94(i8 %93)
; # (when (& B (hex "80")) (call $Put (symByte P)) (when (& B (hex "2...
; # (& B (hex "80"))
  %95 = and i8 %93, 128
  %96 = icmp ne i8 %95, 0
  br i1 %96, label %$35, label %$36
$35:
  %97 = phi i64 [%92, %$33] ; # X
  %98 = phi i8 [%93, %$33] ; # B
; # (symByte P)
  %99 = call i8 @symByte(i64* %50)
; # (call $Put (symByte P))
  %100 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 80) to void(i8)**)
  call void %100(i8 %99)
; # (when (& B (hex "20")) (call $Put (symByte P)) (when (& B (hex "1...
; # (& B (hex "20"))
  %101 = and i8 %98, 32
  %102 = icmp ne i8 %101, 0
  br i1 %102, label %$37, label %$38
$37:
  %103 = phi i64 [%97, %$35] ; # X
  %104 = phi i8 [%98, %$35] ; # B
; # (symByte P)
  %105 = call i8 @symByte(i64* %50)
; # (call $Put (symByte P))
  %106 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 80) to void(i8)**)
  call void %106(i8 %105)
; # (when (& B (hex "10")) (call $Put (symByte P)))
; # (& B (hex "10"))
  %107 = and i8 %104, 16
  %108 = icmp ne i8 %107, 0
  br i1 %108, label %$39, label %$40
$39:
  %109 = phi i64 [%103, %$37] ; # X
  %110 = phi i8 [%104, %$37] ; # B
; # (symByte P)
  %111 = call i8 @symByte(i64* %50)
; # (call $Put (symByte P))
  %112 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 80) to void(i8)**)
  call void %112(i8 %111)
  br label %$40
$40:
  %113 = phi i64 [%103, %$37], [%109, %$39] ; # X
  %114 = phi i8 [%104, %$37], [%110, %$39] ; # B
  br label %$38
$38:
  %115 = phi i64 [%97, %$35], [%113, %$40] ; # X
  %116 = phi i8 [%98, %$35], [%114, %$40] ; # B
  br label %$36
$36:
  %117 = phi i64 [%92, %$33], [%115, %$38] ; # X
  %118 = phi i8 [%93, %$33], [%116, %$38] ; # B
  br label %$34
$34:
  %119 = phi i64 [%90, %$32], [%117, %$36] ; # X
  %120 = phi i8 [%91, %$32], [%118, %$36] ; # B
; # (symByte P)
  %121 = call i8 @symByte(i64* %50)
  br label %$29
$31:
  %122 = phi i64 [%82, %$29] ; # X
  %123 = phi i8 [%83, %$29] ; # B
  br label %$2
$2:
  %124 = phi i64 [%0, %$1], [%5, %$5], [%20, %$10], [%28, %$15], [%39, %$18], [%122, %$31] ; # X
  ret void
}

define i64 @Fmt(i64) {
$1:
; # (let (X (cdr Exe) P (push 4 NIL ZERO NIL NIL)) (begString P) (loo...
; # (cdr Exe)
  %1 = inttoptr i64 %0 to i64*
  %2 = getelementptr i64, i64* %1, i32 1
  %3 = load i64, i64* %2
; # (push 4 NIL ZERO NIL NIL)
  %4 = alloca i64, i64 5, align 16
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
  %23 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 80) to void(i8)**)
  call void %23(i8 38)
  br label %$2
$9:
  %24 = phi i64 [%19, %$3] ; # X
  %25 = phi i64 [0, %$3] ; # ->
; # (endString)
  %26 = call i64 @endString()
  ret i64 %26
}

define i64 @Pack(i64) {
$1:
  ret i64 %0
}

define i64 @Read(i64) {
$1:
  ret i64 %0
}

define i64 @In(i64) {
$1:
  ret i64 %0
}

define i64 @Out(i64) {
$1:
  ret i64 %0
}

@$5 = private constant [14 x i8] c" \22#%&:;<=>?\_\00"
@$4 = private constant [7 x i8] c"&quot;\00"
@$3 = private constant [6 x i8] c"&amp;\00"
@$2 = private constant [5 x i8] c"&gt;\00"
@$1 = private constant [5 x i8] c"&lt;\00"
