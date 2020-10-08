# 13jan16 Software Lab. Alexander Burger

# "boss" *Boss

(unless (info (tmp "+"))
   (call "mkfifo" (setq "boss" (tmp "+")))
   (call "mkfifo" (setq *Boss (tmp "-"))) )
(hear (open "boss"))

# (boss 'sym ['any ..])
(de boss @
   (out "boss" (pr (rest))) )

(de reply Exe  #> any
   (out *Boss (pr (eval Exe))) )
