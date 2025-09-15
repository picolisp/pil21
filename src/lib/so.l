# 15sep25 Software Lab. Alexander Burger

(symbols '(llvm))

#{
   For the "full" library
   -- In Makefile
      * Remove the -quiche option
      * Use lib.c instead of lib.so.c
      * Link with -lm -ldl -lreadline -lffi
   -- Below
      * Exclude only 'main'
      * Don't patch '_getStdin'
   -- In the main C program
      * evaluate("(load)") is possible
}#

(exclude
   # Signals
   $Signal iSignal sigChk sig sigTerm sighandler signals
   # Readline
   initReadline rlHide rlShow _History tabComplete
   # Native FFI
   fetchChar natBuf natErr natRetFloat natRetDouble natRetBuf ffi _Nat _Native _Struct
   # Memory
   _Byte
   # Library
   main )

(patch
   (_getStdin (T . @X) (T -1)) )
