# 02nov25 Software Lab. Alexander Burger

(default *Xxh64
   (native "libxxhash.so" "XXH64_createState" 'P) )

(de xxh64 (File)
   (native "libxxhash.so" "XXH64_reset" 'I *Xxh64 0)
   (buf Buf 32768
      (in File
         (while (gt0 (%@ "read" 'I (fd) Buf 32768))
            (native "libxxhash.so" "XXH64_update" 'I *Xxh64 Buf @) ) ) )
   (native "libxxhash.so" "XXH64_digest" 'N *Xxh64) )
