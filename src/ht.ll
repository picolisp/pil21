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
declare void @prin(i64)
declare i8 @symByte(i64*)
declare void @prExt(i64)
declare void @begString(i64*)
declare void @tglString(i64*)
declare i64 @endString()
declare i64 @isLstIntern(i64, i64)
declare void @outName(i64)
declare i64 @mkChar(i32)
declare i64 @evCnt(i64, i64)
declare i32 @getChar(i32)

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

define void @htEncode(i8, i64*) {
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
  %10 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 80) to void(i8)**)
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
  %15 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 80) to void(i8)**)
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
  %20 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 80) to void(i8)**)
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
  %25 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 80) to void(i8)**)
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
; # (let (Nm @ P (push 0 Nm) B (symByte P)) (cond ((== X (isLstIntern...
; # (push 0 Nm)
  %50 = alloca i64, i64 2, align 16
  store i64 0, i64* %50
  %51 = getelementptr i64, i64* %50, i32 1
  store i64 %47, i64* %51
; # (symByte P)
  %52 = call i8 @symByte(i64* %50)
; # (cond ((== X (isLstIntern Nm (val $Intern))) (call $Put (char "$"...
; # (val $Intern)
  %53 = inttoptr i64 ptrtoint (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 120) to i64) to i64*
  %54 = load i64, i64* %53
; # (isLstIntern Nm (val $Intern))
  %55 = call i64 @isLstIntern(i64 %47, i64 %54)
; # (== X (isLstIntern Nm (val $Intern)))
  %56 = icmp eq i64 %49, %55
  br i1 %56, label %$22, label %$21
$22:
  %57 = phi i64 [%49, %$19] ; # X
; # (call $Put (char "$"))
  %58 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 80) to void(i8)**)
  call void %58(i8 36)
; # (htEncode B P)
  call void @htEncode(i8 %52, i64* %50)
  br label %$20
$21:
  %59 = phi i64 [%49, %$19] ; # X
; # (or (== B (char "$")) (== B (char "+")) (== B (char "-")))
; # (== B (char "$"))
  %60 = icmp eq i8 %52, 36
  br i1 %60, label %$23, label %$24
$24:
  %61 = phi i64 [%59, %$21] ; # X
; # (== B (char "+"))
  %62 = icmp eq i8 %52, 43
  br i1 %62, label %$23, label %$25
$25:
  %63 = phi i64 [%61, %$24] ; # X
; # (== B (char "-"))
  %64 = icmp eq i8 %52, 45
  br label %$23
$23:
  %65 = phi i64 [%59, %$21], [%61, %$24], [%63, %$25] ; # X
  %66 = phi i1 [1, %$21], [1, %$24], [%64, %$25] ; # ->
  br i1 %66, label %$27, label %$26
$27:
  %67 = phi i64 [%65, %$23] ; # X
; # (putHex B)
  call void @putHex(i8 %52)
; # (symByte P)
  %68 = call i8 @symByte(i64* %50)
; # (htEncode (symByte P) P)
  call void @htEncode(i8 %68, i64* %50)
  br label %$20
$26:
  %69 = phi i64 [%65, %$23] ; # X
; # (htEncode B P)
  call void @htEncode(i8 %52, i64* %50)
  br label %$20
$20:
  %70 = phi i64 [%57, %$22], [%67, %$27], [%69, %$26] ; # X
  br label %$2
$2:
  %71 = phi i64 [%0, %$1], [%5, %$5], [%20, %$10], [%28, %$15], [%39, %$18], [%70, %$20] ; # X
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

define i8 @getHex(i64) {
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

define i64 @head(i8*, i64) {
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

define i64 @Pack(i64) {
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
  %16 = alloca i64, i64 2, align 16
  %17 = ptrtoint i64* %16 to i64
  %18 = inttoptr i64 %17 to i64*
  store i64 %15, i64* %18
  %19 = inttoptr i64 ptrtoint (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 0) to i64) to i64*
  %20 = load i64, i64* %19
  %21 = inttoptr i64 %17 to i64*
  %22 = getelementptr i64, i64* %21, i32 1
  store i64 %20, i64* %22
  %23 = inttoptr i64 ptrtoint (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 0) to i64) to i64*
  store i64 %17, i64* %23
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
  %34 = icmp eq i64 %33, ptrtoint (i8* getelementptr (i8, i8* bitcast ([840 x i64]* @SymTab to i8*), i32 8) to i64)
; # (push 4 NIL ZERO NIL NIL)
  %35 = alloca i64, i64 5, align 16
  store i64 4, i64* %35
  %36 = getelementptr i64, i64* %35, i32 2
  store i64 2, i64* %36
; # (begString (push 4 NIL ZERO NIL NIL))
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
  %64 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 80) to void(i8)**)
  call void %64(i8 %63)
  br label %$15
$16:
  %65 = phi i64 [%44, %$13] ; # Lst
; # (<> B (char "&"))
  %66 = icmp ne i8 %45, 38
  br i1 %66, label %$22, label %$21
$22:
  %67 = phi i64 [%65, %$16] ; # Lst
; # (outName C)
  call void @outName(i64 %42)
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
  %72 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 80) to void(i8)**)
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
  %77 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 80) to void(i8)**)
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
  %82 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 80) to void(i8)**)
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
  %87 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 80) to void(i8)**)
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
  %92 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 80) to void(i8)**)
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
  %128 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 80) to void(i8)**)
  call void %128(i8 38)
; # (call $Put (char "#"))
  %129 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 80) to void(i8)**)
  call void %129(i8 35)
  br label %$39
$38:
  %130 = phi i64 [%119, %$36] ; # Lst
  %131 = phi i64 [%120, %$36] ; # L
  %132 = phi i8 [%121, %$36] ; # D
  %133 = phi i32 [%122, %$36] ; # N
; # (? (== (setq D (firstByte (++ L))) (char ";")) (outName (mkChar N...
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
; # (outName (mkChar N))
  call void @outName(i64 %144)
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
  %158 = load void(i8)*, void(i8)** bitcast (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 80) to void(i8)**)
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
  %162 = inttoptr i64 %17 to i64*
  %163 = getelementptr i64, i64* %162, i32 1
  %164 = load i64, i64* %163
  %165 = inttoptr i64 ptrtoint (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 0) to i64) to i64*
  store i64 %164, i64* %165
  ret i64 %161
}

define i64 @Read(i64) {
$1:
; # (let (N (evCnt Exe (cdr Exe)) C (val $Chr)) (if (or (le0 N) (and ...
; # (cdr Exe)
  %1 = inttoptr i64 %0 to i64*
  %2 = getelementptr i64, i64* %1, i32 1
  %3 = load i64, i64* %2
; # (evCnt Exe (cdr Exe))
  %4 = call i64 @evCnt(i64 %0, i64 %3)
; # (val $Chr)
  %5 = load i32, i32* bitcast (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 72) to i32*)
; # (if (or (le0 N) (and (=0 C) (lt0 (setq C (call $Get))))) $Nil (mk...
; # (or (le0 N) (and (=0 C) (lt0 (setq C (call $Get)))))
; # (le0 N)
  %6 = icmp sle i64 %4, 0
  br i1 %6, label %$2, label %$3
$3:
  %7 = phi i32 [%5, %$1] ; # C
; # (and (=0 C) (lt0 (setq C (call $Get))))
; # (=0 C)
  %8 = icmp eq i32 %7, 0
  br i1 %8, label %$5, label %$4
$5:
  %9 = phi i32 [%7, %$3] ; # C
; # (call $Get)
  %10 = load i32()*, i32()** bitcast (i8* getelementptr (i8, i8* bitcast ([24 x i64]* @env to i8*), i32 88) to i32()**)
  %11 = call i32 %10()
; # (lt0 (setq C (call $Get)))
  %12 = icmp slt i32 %11, 0
  br label %$4
$4:
  %13 = phi i32 [%7, %$3], [%11, %$5] ; # C
  %14 = phi i1 [0, %$3], [%12, %$5] ; # ->
  br label %$2
$2:
  %15 = phi i32 [%5, %$1], [%13, %$4] ; # C
  %16 = phi i1 [1, %$1], [%14, %$4] ; # ->
  br i1 %16, label %$6, label %$7
$6:
  %17 = phi i32 [%15, %$2] ; # C
  br label %$8
$7:
  %18 = phi i32 [%15, %$2] ; # C
; # (getChar C)
  %19 = call i32 @getChar(i32 %18)
; # (mkChar (getChar C))
  %20 = call i64 @mkChar(i32 %19)
  br label %$8
$8:
  %21 = phi i32 [%17, %$6], [%18, %$7] ; # C
  %22 = phi i64 [ptrtoint (i8* getelementptr (i8, i8* bitcast ([840 x i64]* @SymTab to i8*), i32 8) to i64), %$6], [%20, %$7] ; # ->
  ret i64 %22
}

define i64 @In(i64) {
$1:
  ret i64 %0
}

define i64 @Out(i64) {
$1:
  ret i64 %0
}

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
