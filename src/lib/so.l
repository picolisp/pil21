# 02sep25 Software Lab. Alexander Burger

(symbols '(llvm))

(exclude
   # Signals
   $Signal iSignal sigChk sig sigTerm sighandler signals
   # Readline
   initReadline rlHide rlShow _History
   # Native FFI
   fetchChar natBuf natErr natRetFloat natRetDouble natRetBuf ffi _Nat _Native _Struct
   # Memory
   _Byte
   # Library
   main )

(patch
   (_getStdin (T . @X) (T -1)) )
