# 02mar21 Software Lab. Alexander Burger

# Exit on error
(de *Err
   ~(as trail
      (for ("L" (trail T)  "L")
         (cond
            ((pair (car "L"))
               (println (++ "L")) )
            ((== '"L" (car "L"))
               (setq "L" (cddr "L")) )
            (T
               (space 3)
               (println (++ "L") (++ "L")) ) ) )
      (println '====) )
   (prinl *Pid " ! " (stamp) " [" *Adr " " (host *Adr) "] " *Agent)
   (show This)
   (for "X" '(*Agent *Host *Port *Url *SesId *ConId *Tab *Gui *Btn *Get *ID)
      (println "X" (val "X")) )
   (println '*PRG *PRG (val *PRG))
   (for "X" (env)
      (unless (== (car "X") (cdr "X"))
         (println (car "X") (cdr "X")) ) )
   (rollback) )

# User identification
(de user (Pid1 Pid2 Nm To)
   (nond
      (Pid1 (tell 'user *Pid))
      (Pid2
         (tell 'user Pid1 *Pid (get *Login 'nm)
            (/ (- *Timeout (cadr (assoc -1 *Run))) 60000) ) )
      ((<> *Pid Pid1) (println Pid2 Nm To)) ) )

# Timestamp
(msg *Pid " + " (stamp))
(flush)

# Extend 'app' function
(conc (last app)
   '((msg *Pid " + " (stamp) " [" *Adr " " (host *Adr) (and *Cipher (pack " / " @)) "] " *Agent)) )

# Bye message
(push '*Fork
   '(push '*Bye
      '(and *SesId (msg *Pid " - " (stamp))) ) )
