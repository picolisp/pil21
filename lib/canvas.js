/* 22nov21 Software Lab. Alexander Burger */

function renderCanvas(cvs, lst) {
   var ctx = cvs.getContext("2d");
   var cmd, i, j;

   for (i = 0; i < lst.length; ++i) {
      switch ((cmd = lst[i])[0]) {  // Sync with "@lib/canvas.l"
      /*** Functions ***/
      case 1:  // (csFont Str)
         ctx.font = cmd[1];
      case 2:  // (csFillText Str X Y)
         ctx.fillText(cmd[1], cmd[2], cmd[3]);
         break;
      case 3:  // (csStrokeLine X1 Y1 X2 Y2)
         ctx.beginPath();
         ctx.moveTo(cmd[1], cmd[2]);
         ctx.lineTo(cmd[3], cmd[4]);
         ctx.closePath();
         ctx.stroke();
         break;
      case 4:  // (csClearRect X Y DX DY)
         ctx.clearRect(cmd[1], cmd[2], cmd[3], cmd[4]);
         break;
      case 5:  // (csStrokeRect X Y DX DY)
         ctx.strokeRect(cmd[1], cmd[2], cmd[3], cmd[4]);
         break;
      case 6:  // (csFillRect X Y DX DY)
         ctx.fillRect(cmd[1], cmd[2], cmd[3], cmd[4]);
         break;
      case 7:  // (csBeginPath)
         ctx.beginPath();
         break;
      case 8:  // (csClosePath)
         ctx.closePath();
         break;
      case 9:  // (csMoveTo X Y)
         ctx.moveTo(cmd[1], cmd[2]);
         break;
      case 10:  // (csLineTo X Y)
         ctx.lineTo(cmd[1], cmd[2]);
         break;
      case 11:  // (csBezierCurveTo X1 Y1 X2 Y2 X Y)
         ctx.bezierCurveTo(cmd[1], cmd[2], cmd[3], cmd[4], cmd[5], cmd[6]);
         break;
      case 12:  // (csQuadraticCurveTo X1 Y1 X2 Y2)
         ctx.quadraticCurveTo(cmd[1], cmd[2], cmd[3], cmd[4]);
         break;
      case 13:  // (csLine X1 Y1 X2 Y2)
         ctx.moveTo(cmd[1], cmd[2]);
         ctx.lineTo(cmd[3], cmd[4]);
         break;
      case 14:  // (csRect X Y DX DY)
         ctx.rect(cmd[1], cmd[2], cmd[3], cmd[4]);
         break;
      case 15:  // (csArc X Y R A B F)
         ctx.arc(cmd[1], cmd[2], cmd[3], cmd[4], cmd[5], cmd[6]);
         break;
      case 16:  // (csStroke)
         ctx.stroke();
         break;
      case 17:  // (csFill)
         ctx.fill();
         break;
      case 18:  // (csClip)
         ctx.clip();
         break;
      case 19:  // (csDef Key DX DY Lst), (csDef Key)
         if (!cvs.pre)
            cvs.pre = new Array();
         var buf = cvs.pre[cmd[1]] = document.createElement('canvas');
         if (cmd[2]) {
            buf.width = cmd[2];
            buf.height = cmd[3];
            renderCanvas(buf, cmd[4]);
         }
         else {
            buf.width = cvs.width;
            buf.height = cvs.height;
            buf.getContext("2d").drawImage(cvs, 0, 0);
         }
         break;
      case 20:  // (csDraw Key X Y)
         var buf = cvs.pre[cmd[1]];
         ctx.clearRect(cmd[2], cmd[3], buf.width, buf.height);
         ctx.drawImage(buf, cmd[2], cmd[3]);
         break;
      case 21:  // (csDrawDots DX DY Lst)
         if (cmd[3])
            for (j = 0; j < cmd[3].length; j += 2)
               ctx.fillRect(cmd[3][j], cmd[3][j+1], cmd[1], cmd[2]);
         break;
      case 22:  // (csDrawImage Img X Y Lst DX DY)
         var img = new Image();
         img.src = cmd[1];
         (function (img, cmd) {
            img.onload = function() {
               if (cmd[5])
                  ctx.drawImage(img, cmd[2], cmd[3], cmd[5], cmd[6]);
               else
                  ctx.drawImage(img, cmd[2], cmd[3]);
               if (cmd[4])
                  renderCanvas(cvs, cmd[4]);
            } } )(img, cmd);
         break;
      case 23:  // (csTranslate X Y)
         ctx.translate(cmd[1], cmd[2]);
         break;
      case 24:  // (csRotate A)
         ctx.rotate(cmd[1]);
         break;
      case 25:  // (csScale X Y)
         ctx.scale(cmd[1], cmd[2]);
         break;
      case 26:  // (csSave)
         ctx.save();
         break;
      case 27:  // (csRestore)
         ctx.restore();
         break;
      /*** Variables ***/
      case 28:  // (csCursor Lst)
         cvs.curs = cmd[1];
         break;
      case 29:  // (csFillStyle V)
         ctx.fillStyle = cmd[1];
         break;
      case 30:  // (csStrokeStyle V)
         ctx.strokeStyle = cmd[1];
         break;
      case 31:  // (csGlobalAlpha V)
         ctx.globalAlpha = cmd[1];
         break;
      case 32:  // (csLineWidth V)
         ctx.lineWidth = cmd[1];
         break;
      case 33:  // (csLineCap V)
         ctx.lineCap = cmd[1];
         break;
      case 34:  // (csLineJoin V)
         ctx.lineJoin = cmd[1];
         break;
      case 35:  // (csMiterLimit V)
         ctx.miterLimit = cmd[1];
         break;
      case 36:  // (csGlobalCompositeOperation V)
         ctx.globalCompositeOperation = cmd[1];
         break;
      case 37:  // (csDelay N)
         cvs.dly = cmd[1];
         break;
      case 38:  // (csPost)
         cvs.post = true;
         break;
      }
   }
}

function drawCanvas(id, dly) {
   var req = new XMLHttpRequest();
   var url = document.getElementsByTagName("BASE")[0].href + SesId + "!jsDraw?" + id + "&+" + dly;
   var len = arguments.length;

   for (var i = 2; i < len; ++i) {
      if (typeof arguments[i] == "undefined")
         return true;
      if (typeof arguments[i] === "number")
         url += "&+" + arguments[i];
      else
         url += "&" + arguments[i];
   }
   try {req.open("POST", url);}
   catch (e) {return true;}
   req.responseType = "arraybuffer";
   req.onload = function() {
      var ele = document.getElementById(id);

      ele.dly = dly;
      renderCanvas(ele, plio(new Uint8Array(req.response)));
      if (ele.post) {
         ele.post = false;
         while (ele = ele.parentNode) {
            if (ele.tagName == "FORM") {
               post(ele, false, null, null);
               break;
            }
         }
      }
      if (ele.dly == 0)
         requestAnimationFrame(function() {drawCanvas(id, dly)});
      else if (ele.dly > 0)
         setTimeout(function() {drawCanvas(id, dly)}, ele.dly);
      ele.dly = dly;
   }
   try {req.send(null);}
   catch (e) {
      req.abort();
      return true;
   }
   return false;
}

function doCsDn(cvs, x, y) {
   var r = cvs.getBoundingClientRect();

   cvs.csDn = true;
   cvs.csDnX = x - r.left;
   cvs.csDnY = y - r.top;
   cvs.csMv = false;
   return false;
}

function csMouseDn(cvs, event) {
   return doCsDn(cvs, event.clientX, event.clientY);
}

function csTouchDn(cvs, event) {
   return doCsDn(cvs, event.touches[0].clientX, event.touches[0].clientY);
}

function doCsMv(cvs, x, y) {
   var r = cvs.getBoundingClientRect();

   if (cvs.curs)
      csCursor(cvs, x - r.left, y - r.top);
   if (!cvs.csDn)
      return true;
   if (drawCanvas(cvs.id, cvs.dly, cvs.csMv? -1 : 0, cvs.csDnX, cvs.csDnY, x - r.left, y - r.top))
      return true;
   cvs.csMv = true;
   return false;
}

function csMouseMv(cvs, event) {
   return doCsMv(cvs, event.clientX, event.clientY);
}

function csTouchMv(cvs, event) {
   if (event.targetTouches.length == 1) {
      event.preventDefault();
      return doCsMv(cvs, event.touches[0].clientX, event.touches[0].clientY);
   }
   return false;
}

function csMouseUp(cvs) {
   cvs.csDn = false;
   if (cvs.clicked) {
      clearTimeout(cvs.clicked);
      cvs.clicked = false;
      return drawCanvas(cvs.id, cvs.dly, 2, cvs.csDnX, cvs.csDnY);
   }
   if (cvs.csMv)
      return drawCanvas(cvs.id, cvs.dly);
   cvs.clicked = setTimeout(
      function() {
         cvs.clicked = false;
         drawCanvas(cvs.id, cvs.dly, 1, cvs.csDnX, cvs.csDnY);
      },
      200 );
   return false;
}

function csTouchEnd(cvs) {
   cvs.csDn = false;
   if (cvs.csMv)
      return drawCanvas(cvs.id, cvs.dly);
   return false;
}

function csLeave(cvs) {
   cvs.style.cursor = "";
   cvs.csDn = cvs.csMv = false;
   if (cvs.clicked) {
      clearTimeout(cvs.clicked);
      cvs.clicked = false;
   }
   return drawCanvas(cvs.id, cvs.dly);
}

function csCursor(cvs, x, y) {
   var a;

   for (var i = 0; i < cvs.curs.length; ++i) {
      if (typeof (a = cvs.curs[i]) === "string") {
         cvs.style.cursor = a;
         return;
      }
      for (var j = 1; j < a.length; j += 4) {
         if (a[j] <= x && x <= a[j+2] && a[j+1] <= y && y <= a[j+3]) {
            cvs.style.cursor = a[0];
            return;
         }
      }
   }
   cvs.style.cursor = "";
}
