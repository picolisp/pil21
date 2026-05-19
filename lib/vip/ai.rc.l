# 16may26 Software Lab. Alexander Burger

(symbols '(pico)
   (load "@lib/json.l" "@lib/ai.l") )

(symbols '(ai vip pico))

(cmd "models" (L Lst Cnt)
   (symbols '(ai vip pico)
      (api "~/.ai")
      (prCmd
         (sort
            (extract
               '((S) (chop (pre? L S)))
               (models) ) ) ) ) )

(cmd "ai" (L Lst Cnt)
   (symbols '(ai vip pico)
      (api "~/.ai")
      (let
         (Lst
            (split
               (make
                  (for L (: buffer text)
                     (when
                        (or
                           (= '("+" "+" "+") L)
                           (and
                              (head '("+" "+" "+" " ") L)
                              (format (cadr (split L " "))) )
                           (= '("=" "=" "=") L) )
                        (link 0) )
                     (link L) ) )
               0 )
            L (split (caar Lst) " ") )
         (setq
            *Model (pack (car L))
            *Max (format (cadr L)) )
         (let? R
            (or
               (mapcan
                  '((S) (split (chop S) "\n"))
                  (apply completions
                     (mapcan
                        '((L)
                           (let? S (glue "\n" (cdr L))
                              (cond
                                 ((head '("+" "+" "+") (setq L (car L)))
                                    (list "user" S (format (cadr (split L " ")))) )
                                 ((head '("=" "=" "=") L)
                                    (list  "assistant" S NIL) )
                                 (T (list  "system" S NIL)) ) ) )
                        Lst )
                     *Model ) )
               (mapcar
                  '((X) (chop (cdr X)))
                  (fish
                     '((X)
                        (and
                           (pair X)
                           (memq (car X) '(error message))
                           (str? (cdr X)) ) )
                     *Result ) ) )
            (move 'goAbs 1 T)
            (paste
               (make
                  (link T (chop (if (res 'error) "???" "===")))
                  (chain R)
                  (unless (res 'error)
                     (and (last R) (link NIL))
                     (link (chop "+++") NIL)
                     (evCmd
                        (cons
                           (res 'usage 'total_tokens)
                           (res 'choices 'finish_reason) ) ) ) )
               1 )
            (=: buffer fmt *Columns) ) ) ) )

(cmd "ai?" (L Lst Cnt)
   (symbols '(ai vip pico)
      (evCmd (pretty *Result)) ) )
