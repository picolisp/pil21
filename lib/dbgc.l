# 22sep20 Software Lab. Alexander Burger

### DB Garbage Collection ###

(private) (markData markExt)

(de markExt (S)
   (unless (mark S T)
      (markData (val S))
      (maps markData S)
      (wipe S) ) )

(de markData (X)
   (while (pair X)
      (markData (++ X)) )
   (and (ext? X) (markExt X)) )

(let Cnt 0
   (dbSync)
   (markExt *DB)
   (for L *ExtDBs  # ("path/" <cnt> <ofs>)
      (let ((P N E) L  Lck)
         (for I N
            (let (Fd (open (pack P (hax (dec I))))  (Cnt . Siz) (blk Fd 0))
               (and (=1 I) (setq Lck Fd))
               (for Blk (dec Cnt)
                  (mapc markExt
                     (fish ext? (ext E (blk Fd Blk Siz Lck))) ) )
               (close Fd) ) ) ) )
   (finally (mark 0)
      (for (F . @) (or *Dbs (2))
         (for (S (seq F)  S  (seq S))
            (unless (mark S)
               (inc 'Cnt)
               (and (isa '+Entity S) (zap> S))
               (zap S) ) ) ) )
   (when *Blob
      (use (@S @R F S)
         (let Pat (conc (chop *Blob) '(@S "." @R))
            (in (list 'find *Blob "-type" "f")
               (while (setq F (line))
                  (when (match Pat F)
                     (unless
                        (and
                           (setq S (extern (pack (replace @S '/))))
                           (get S (intern (pack @R))) )
                        (inc 'Cnt)
                        (%@ "unlink" NIL (pack F)) )
                     (wipe S) ) ) ) ) ) )
   (commit)
   (gt0 Cnt) )
