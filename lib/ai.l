# 01sep26 Software Lab. Alexander Burger
# https://developers.openai.com/api/reference/overview

(symbols 'ai 'pico)

(local) (*ApiUrl *ApiKey *Result curl result res api models completions
chat agent search)

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

# (completions 'res 'model 'lst ['lst ..])
(de completions (Res Model . @)
   (pipe
      (out (curl "chat/completions" "--json" "@-")
         (printJson
            (cons
               (cons 'model Model)
               (make
                  (while (args)
                     (and (next) (link @)) ) ) ) ) )
      (apply result Res) ) )

# (chat 'model 'max 'role 'text ['role 'text ..])
(de chat (Model Max . @)
   (completions '(choices message content) Model
      (and Max (cons 'max_completion_tokens @))
      (make
         (link 'messages T)
         (while (args)
            (link
               (list
                  (cons 'role (next))
                  (cons 'content (next)) ) ) ) ) ) )

# (agent 'model 'text 'fun 'args 'text ..)
(de agent (Model Text . @)
   (let
      (Msg
         (list 'messages T
            (list '(role . "user") (cons 'content Text)) )
         Allowed )
      (completions NIL Model Msg
         (make
            (link 'tools T)
            (while (args)
               (link
                  (list
                     '(type . "function")
                     (list 'function
                        (cons 'name (name (push 'Allowed (next))))
                        (list 'parameters
                           (cons 'type "object")
                           (cons 'properties (next)) )
                        (cons 'description (next)) ) ) ) ) ) )
      (while (get (res 'choices 'message) 1 'tool_calls)
         (completions NIL Model
            (let Lst @
               (conc Msg
                  (list
                     (list '(role . "assistant") (cons 'tool_calls T Lst)) )
                  (mapcar
                     '((L)
                        (let Fun (intern (get L 'function 'name))
                           (unless (memq Fun Allowed)
                              (quit "Bad tool call" Fun) )
                           (list
                              '(role . "tool")
                              (cons 'tool_call_id (get L 'id))
                              (cons 'content
                                 (let R
                                    (apply Fun
                                       (mapcar cdr (parseJson (get L 'function 'arguments))) )
                                    (or (str? R) (sym R)) ) ) ) ) )
                     Lst ) ) ) ) )
      (res 'choices 'message 'content) ) )

# (search 'text ['cnt 'ctry 'lang 'model])
(de search (Txt Cnt Ctry Lang Model)
   (pipe
      (out (curl "search" "--json" "@-")
         (printJson
            (make
               (link (cons 'query Txt))
               (and Cnt (link (cons 'count @)))
               (when (or Ctry *Ctry)
                  (link (cons 'country @)) )
               (when (or Lang *Lang)
                  (link (cons 'search_lang @)) )
               (and Model (link (cons 'model @))) ) ) )
      (mapcar
         '((R) (mapcar cdr R))
         (result 'data) ) ) )
