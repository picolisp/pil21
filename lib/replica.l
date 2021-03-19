# 17oct20 Software Lab. Alexander Burger

# <path>/bin/picolisp <path>/lib.l @lib/replica.l <port|num> <keyFile> <journal> <dbFile> <blob/app/> [dbs1 ..]
# <path>/bin/ssl <host> 443 '<port|name>/!replica' <keyFile> <journal> <blob/app/> 20 [60]

(argv *Arg1 *KeyFile *Journal *Pool *Blob . *Dbs)
(unless (info *KeyFile)
   (bye) )

(pool *Pool (mapcar format *Dbs) *Journal)
(when (lock)
   (bye) )

(load "@lib/net.l" "@lib/misc.l" "@lib/http.l")

(allow "!replica")

(setq
   *Arg1 (format *Arg1)
   *Port (or (format (sys "PORT")) *Arg1)
   *SSLKey (in *KeyFile (line T))
   *Replica (tmp 'replica) )

(de replicate (N)
   (and
      (out *Replica (echo N))
      (= N (car (info *Replica)))
      (= "T" (prin (peek)))
      (flush)
      (char)
      (eof) ) )

(de replica ()
   (when (= (line T) *SSLKey)
      (let? X (line T)
         (if (format X)
            (when (replicate @)                    # Journal
               (protect (journal *Replica)) )
            (let Blob (pack *Blob X)               # Blob
               (call 'mkdir "-p" (dirname Blob))
               (and
                  (format (line T))
                  (replicate @)
                  (protect (call "mv" *Replica Blob)) ) ) ) ) ) )

(retire *Arg1)

# Non-forking server
(let P (port *Port)
   (loop
      (let S (listen P)
         (http S)
         (close S) ) ) )
