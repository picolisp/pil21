# 14sep20 Software Lab. Alexander Burger

(and (=0 *Scl) (scl 6))                # Default scale 6

(setq                                  # Global constants
   pi    3.1415926535897932
   pi/2  1.5707963267948966
   "Dbl1" (0 . 1.0)
   "Dbl2" (0 . 1.0) )

(de pow (X Y)
   (set "Dbl1" X  "Dbl2" Y)
   (%@ "pow" 1.0 "Dbl1" "Dbl2") )

(de exp (X)
   (set "Dbl1" X)
   (%@ "exp" 1.0 "Dbl1") )

(de log (X)
   (when (gt0 (set "Dbl1" X))
      (%@ "log" 1.0 "Dbl1") ) )

(de sin (A)
   (set "Dbl1" A)
   (%@ "sin" 1.0 "Dbl1") )

(de cos (A)
   (set "Dbl1" A)
   (%@ "cos" 1.0 "Dbl1") )

(de tan (A)
   (set "Dbl1" A)
   (%@ "tan" 1.0 "Dbl1") )

(de asin (A)
   (set "Dbl1" A)
   (%@ "asin" 1.0 "Dbl1") )

(de acos (A)
   (set "Dbl1" A)
   (%@ "acos" 1.0 "Dbl1") )

(de atan (A)
   (set "Dbl1" A)
   (%@ "atan" 1.0 "Dbl1") )

(de atan2 (X Y)
   (set "Dbl1" X  "Dbl2" Y)
   (%@ "atan2" 1.0 "Dbl1" "Dbl2") )
