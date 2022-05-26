# 26may22 Software Lab. Alexander Burger

(allow "!jsDraw" )
(push1 '*JS (allow "@lib/plio.js") (allow "@lib/canvas.js"))

# Draw   (drawCanvas Id Dly)
# Click  (drawCanvas Id Dly 1 X Y)
# Double (drawCanvas Id Dly 2 X Y)
# Start  (drawCanvas Id Dly 0 X Y X2 Y2)
# Move   (drawCanvas Id Dly -1 X Y X2 Y2)
(de jsDraw (Id Dly F X Y X2 Y2)
   (http1 "application/octet-stream" 0)
   (let Lst (drawCanvas Id Dly F X Y X2 Y2)
      (prinl "Content-Length: " (bytes Lst) "\r\n\r")
      (pr Lst) ) )

# Canvas Commands
(for (Opc . L)
   (quote  # In sync with "@lib/canvas.js"
      ### Functions ###
      (csFont Str)
      (csFillText Str X Y)
      (csStrokeLine X1 Y1 X2 Y2)
      (csClearRect X Y DX DY)
      (csStrokeRect X Y DX DY)
      (csFillRect X Y DX DY)
      (csBeginPath)
      (csClosePath)
      (csMoveTo X Y)
      (csLineTo X Y)
      (csBezierCurveTo X1 Y1 X2 Y2 X Y)
      (csQuadraticCurveTo X1 Y1 X2 Y2)
      (csLine X1 Y1 X2 Y2)
      (csRect X Y DX DY)
      (csArc X Y R A B F)
      (csStroke)
      (csFill)
      (csClip)
      (csDef Key DX DY Lst)
      (csDraw Key X Y)
      (csDrawDots DX DY Lst)
      (csDrawImage Img X Y Lst DX DY)
      (csTranslate X Y)
      (csRotate A)
      (csScale X Y)
      (csSave)
      (csRestore)
      ### Variables ###
      (csCursor Lst)
      (csFillStyle V)
      (csStrokeStyle V)
      (csGlobalAlpha V)
      (csLineWidth V)
      (csLineCap V)
      (csLineJoin V)
      (csMiterLimit V)
      (csGlobalCompositeOperation V)
      (csDelay N)
      (csPost) )
   (def (car L)
      (list
         (cdr L)
         (list 'link
            (if (cdr L)
               (cons 'list Opc @)
               (list Opc) ) ) ) ) )

(de <canvas> (Id DX DY Alt)
   (prin
      "<canvas id=\"" Id
      "\" width=\"" DX
      "\" height=\"" DY
      "\" onmousedown=\"csMouseDn(this, event)"
      "\" ontouchstart=\"csTouchDn(this, event)"
      "\" onmousemove=\"csMouseMv(this, event)"
      "\" ontouchmove=\"csTouchMv(this, event)"
      "\" onmouseup=\"csMouseUp(this)"
      "\" ontouchend=\"csTouchEnd(this)"
      "\" onmouseout=\"csLeave(this)"
      "\" ontouchleave=\"csLeave(this)\"" )
   (dfltCss "canvas")
   (prinl ">" Alt "</canvas>" ) )

### Debug ###
`*Dbg

(noLint 'drawCanvas)
