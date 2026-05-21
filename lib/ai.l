# 20may26 Software Lab. Alexander Burger

(symbols 'ai 'pico)

# https://developers.openai.com/api/reference/overview
# https://dialog.deutschlandgpt.de/platform-api

(local) (*ApiUrl *ApiKey *Max *Result curl result res api models completions)

(de curl (Res . @)
   (pass list
      "curl" "-s"
      (pack "https://" *ApiUrl Res)
      "-H" (pack "Authorization: Bearer " *ApiKey) ) )

(de result @
   (when (setq *Result (readJson))
      (pass res) ) )

(de res @
   (let (Rest *Result  Lst (rest))
      (recur (Lst Rest)
         (loop
            (NIL Lst Rest)
            (setq Rest (get Rest (++ Lst)))
            (T (and (pair Rest) (pair (caar @)))
               (mapcar
                  '((Rest) (recurse Lst Rest))
                  Rest ) ) ) ) ) )

# (api 'file)
(de api (File)
   (in File
      (setq *ApiUrl (line T)  *ApiKey (line T))
      (line T) ) )

# (models)
(de models ()
   (in (curl "models")
      (result 'data 'id) ) )

# (completions 'model 'role 'text 'temp ['role 'text 'temp ..]
(de completions (Model . @)
   (pipe
      (out (curl "chat/completions" "--json" "@-")
         (printJson
            (list
               (cons 'model Model)
               (make
                  (link 'messages T)
                  (while (args)
                     (link
                        (make
                           (link
                              (cons 'role (next))
                              (cons 'content (next)) )
                           (and (next) (link (cons 'temperature @)))
                           (and *Max (link (cons 'max_tokens @))) ) ) ) ) ) ) )
      (result 'choices 'message 'content) ) )
