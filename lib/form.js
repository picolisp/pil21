/* 05apr22 Software Lab. Alexander Burger */

var FormReq = new XMLHttpRequest();
FormReq.upload.addEventListener("progress", dropProgress, false);
FormReq.upload.addEventListener("load", dropLoad, false);

var Btn = [];
var Queue = [];
var Busy, SesId, Key, InBtn, Auto, Chg, Post, Drop, Hint, Hints, Item, Beg, End;

function inBtn(btn,flg) {InBtn = flg;}

function formKey(event) {
   Key = event.keyCode;
   if (Hint  &&  event.charCode == 0  &&  Hint.style.visibility == "visible") {
      if ((Item >= 0 && Key == 13) || Key == 38 || Key == 40)
         return false;
      if (Key == 13) {
         Hint.style.visibility = "hidden";
         return true;
      }
      if (Key == 27) {
         Hint.style.visibility = "hidden";
         return false;
      }
   }
   if (event.charCode || Key == 8)
      Chg = true;
   return true;
}

function fldChg(field) {
   Chg = true;
   if (!InBtn && (Key != 13 || field.type == "textarea")) {
      post(field.form, false, null, null);
      Key = 0;
   }
   return true;
}

function doBtn(btn) {
   Btn.push(btn);
   return true;
}

function doDrag(event) {
   event.stopPropagation();
   event.preventDefault();
}

function doDrop(btn, event) {
   doDrag(event);
   if (event.dataTransfer.files.length != 0) {
      Btn.push(Drop = btn);
      btn.value = "0 %";
      post(btn.form, false, null, event.dataTransfer.files[0]);
   }
}

function dropProgress(event) {
   if (Drop)
      Drop.value = event.lengthComputable?
         Math.round((event.loaded * 100) / event.total) + " %" : "(?) %";
}

function dropLoad(event) {
   Drop = null;
}

function hasElement(form, name) {
   for (var i = 0; i < form.elements.length; ++i)
      if (form.elements[i].name == name)
         return true;
   return false;
}

function setHref(fld, url) {
   var i = url.indexOf("~");

   if (url.charAt(i = i>=0? i+1 : 0) == "+")  {
      url = url.substr(0,i) + url.substr(i+1);
      fld.target = "_blank";
   }
   fld.href = decodeURIComponent(url);
}

function idFocus(fld) {
   try {
      document.createEvent("TouchEvent");
      return true;
   } catch (e) {}
   setTimeout(function() {document.getElementById(fld).focus()}, 420);
}

function setCheck(fld, val) {
   var lst = document.getElementsByName(fld.name);

   for (var i = 1;  i < lst.length; ++i)
      if (lst[i] == fld)
         return lst[i - 1] = val;
}

/*** Form submit ***/
function doPost(form) {
   for (var i = 0; ; ++i) {
      if (i == Btn.length)
         return true;
      if (Btn[i].form == form)
         return post(form, false, null, null);
   }
}

function post(form, auto, exe, file) {
   var i, data;

   if (!FormReq || !hasElement(form,"*Get") || (i = form.action.indexOf("~")) <= 0)
      return true;
   if (Busy) {
      Queue.push([form, auto, exe, file]);
      return false;
   }
   Busy = true;
   form.style.cursor = "wait";
   try {FormReq.open("POST", SesId + "!jsForm?" + form.action.substr(i+1));}
   catch (e) {return true;}
   FormReq.onload = function() {
      if (FormReq.responseText == "T") {
         Queue.length = 0;
         form.submit();
      }
      else {
         var txt = FormReq.responseText.split("&");

         if (txt[0]) {
            var r = txt[0].split(":");

            if (Auto)
               clearTimeout(Auto);
            if (!r[1])
               Auto = null;
            else {
               Auto = setTimeout(function() {
                  if (Chg)
                     Auto = setTimeout(arguments.callee, r[1]);
                  else {
                     Btn.push(document.getElementById(r[0]));
                     post(form, true, null, null);
                  }
               }, r[1] );
            }
         }
         if (!auto || !Chg) {
            var i, j;

            for (i = 1; i < txt.length;) {
               var fld = txt[i++];
               var val = decodeURIComponent(txt[i++]);

               if (!fld) {
                  window[txt[i++]](val);
                  continue;
               }
               if (!(fld = document.getElementById(fld)))
                  continue;
               if (fld.tagName == "SPAN") {
                  if (i != txt.length && txt[i].charAt(0) == "=")
                     ++i;
                  if (i == txt.length || txt[i].charAt(0) != "+") {
                     if (fld.firstChild.tagName != "A")
                        fld.firstChild.data = val? val : "\u00A0";
                     else
                        fld.replaceChild(document.createTextNode(val? val : "\u00A0"), fld.firstChild);
                  }
                  else {
                     var a = document.createElement("A");

                     setHref(a, txt[i++].substr(1));
                     a.appendChild(document.createTextNode(val));
                     fld.replaceChild(a, fld.firstChild);
                  }
               }
               else if (fld.tagName == "A") {
                  if (i != txt.length && txt[i].charAt(0) == "=")
                     ++i;
                  if (i == txt.length || txt[i].charAt(0) != "+") {
                     fld.replaceChild(document.createTextNode(val? val : "\u00A0"), fld.firstChild);
                     fld.removeAttribute("href");
                  }
                  else {
                     fld.firstChild.data = val;
                     setHref(fld, txt[i++].substr(1));
                  }
               }
               else if (fld.tagName == "IMG") {
                  var parent = fld.parentNode;

                  fld.src = val;
                  fld.alt = txt[i++];
                  if (parent.tagName == "A") {
                     if (txt[i])
                        setHref(parent, txt[i]);
                     else {
                        var grand = parent.parentNode;

                        grand.removeChild(parent);
                        grand.appendChild(fld);
                     }
                  }
                  else if (txt[i]) {
                     var a = document.createElement("A");

                     parent.removeChild(fld);
                     parent.appendChild(a);
                     a.appendChild(fld);
                     setHref(a, txt[i]);
                  }
                  ++i;
               }
               else {
                  if (fld.type == "checkbox") {
                     fld.checked = val != "";
                     setCheck(fld, "");
                  }
                  else if (fld.type == "select-one") {
                     for (j = 0; j < fld.options.length; ++j) {
                        if (fld.options[j].text == val)
                           fld.selectedIndex = j;
                        fld.options[j].disabled = false;
                     }
                  }
                  else if (fld.type == "radio") {
                     fld.value = val;
                     fld.checked = txt[i++].charAt(0) != "";
                  }
                  else if (fld.type == "image")
                     fld.src = val;
                  else if (fld.value != val) {
                     fld.value = val;
                     if (fld.pilSetValue)
                        fld.pilSetValue(val);
                     fld.scrollTop = fld.scrollHeight;
                  }
                  fld.disabled = false;
                  if (i < txt.length && txt[i].charAt(0) == "=") {
                     if (fld.type == "select-one") {
                        for (j = 0; j < fld.options.length; ++j)
                           if (fld.options[j].text != val)
                              fld.options[j].disabled = true;
                     }
                     fld.disabled = true;
                     InBtn = 0;  // 'onblur' on won't come when disabled
                     if (fld.type == "checkbox"  &&  fld.checked)
                        setCheck(fld, "T");
                     ++i;
                  }
                  if (fld.pilDisable)
                     fld.pilDisable(fld.disabled);
               }
               while (i < txt.length && (j = "#*?".indexOf(txt[i].charAt(0))) >= 0) {
                  switch (j) {

                  case 0:  // '#'
                     fld.setAttribute("class", txt[i++].substr(1));
                     break;

                  case 1:  // '*'
                     var node = fld.parentNode.parentNode.lastChild;
                     var img = document.createElement("IMG");

                     if (!node.firstChild)
                        node = fld.parentNode.parentNode.parentNode.lastChild;
                     node.removeChild(node.firstChild);
                     img.src = txt[i++].substr(1);
                     if (!txt[i])
                        node.appendChild(img);
                     else {
                        var a = document.createElement("A");

                        setHref(a, txt[i]);
                        a.appendChild(img);
                        node.appendChild(a);
                     }
                     ++i;
                     break;

                  case 2:  // '?'
                     fld.title = decodeURIComponent(txt[i++].substr(1));
                     break;
                  }
               }
            }
            if (Post)
               Post();
            Chg = false;
         }
      }
      Busy = false;
      form.style.cursor = "";
      if (Queue.length > 0) {
         var a = Queue.shift();
         post(a[0], a[1], a[2], a[3]);
      }
   };
   if (!exe)
      data = "";
   else {
      data = "*Gui:0=" + exe[0];
      for (var i = 1; i < exe.length; ++i)
         data += "&*JsArgs:" + i + "=" + exe[i];
   }
   for (i = 0; i < Btn.length;)
      if (Btn[i].form != form)
         ++i;
      else {
         data += "&" + Btn[i].name + "=" + encodeURIComponent(Btn[i].type == "submit"? Btn[i].value : Btn[i].src);
         Btn.splice(i,1);
      }
   for (i = 0; i < form.elements.length; ++i) {
      var fld = form.elements[i];

      if (fld.name  &&  fld.type != "submit") {   // "image" won't come :-(
         var val;

         if (fld.type == "checkbox")
            val = fld.checked? "T" : "";
         else if (fld.type == "select-one")
            val = fld.options[fld.selectedIndex].text;
         else if (fld.type == "radio" && !fld.checked)
            continue;
         else
            val = fld.value;
         data += "&" + fld.name + "=" + encodeURIComponent(val.replace(/ +$/,""));
      }
   }
   try {
      if (!file)
         FormReq.send(data);
      else {
         var rd = new FileReader();
         rd.readAsBinaryString(file);
         rd.onload = function() {
            FormReq.setRequestHeader("X-Pil", "*ContL=T");
            FormReq.sendAsBinary(data + "&*Drop=" +
               encodeURIComponent(file.name) + "=" +
               file.size + "\n" + rd.result );
         }
      }
   }
   catch (e) {
      FormReq.abort();
      return true;
   }
   return false;
}

/*** Hints ***/
function doHint(field) {
   if (!Hint) {
      Hint = document.createElement("div");
      Hint.setAttribute("class", "hint");
      Hint.style.visibility = "hidden";
      Hint.style.position = "absolute";
      Hint.style.zIndex = 9999;
      Hint.style.textAlign = "left";
      Hints = document.createElement("div");
      Hints.setAttribute("class", "hints");
      Hints.style.position = "relative";
      Hints.style.top = "-2px";
      Hints.style.left = "-3px";
      Hint.appendChild(Hints);
   }
   field.parentNode.appendChild(Hint);
   field.onblur = function() {
      Hint.style.visibility = "hidden";
   }
   var top = field.offsetHeight;
   var left = 0;
   for (var obj = field;  obj && obj.style.position != "absolute";  obj = obj.offsetParent) {
      top += obj.offsetTop;
      left += obj.offsetLeft;
   }
   Hint.style.top = top + "px";
   Hint.style.left = left + "px";
}

function hintKey(field, event, tok, coy) {
   var i, data;

   if (event.keyCode == 9 || event.keyCode == 27)
      return false;
   if (event.charCode == 0  &&  Hint.style.visibility == "visible") {
      if (Item >= 0 && event.keyCode == 13) {
         setHint(field, Hints.childNodes[Item]);
         return false;
      }
      if (event.keyCode == 38) {  // Up
         if (Item > 0) {
            hintOff(Item);
            hintOn(--Item);
         }
         return false;
      }
      if (event.keyCode == 40) {  // Down
         if (Item < (lst = Hints.childNodes).length-1) {
            if (Item >= 0)
               hintOff(Item);
            hintOn(++Item);
         }
         return false;
      }
   }
   if (event.keyCode == 13)
      return true;
   var req = new XMLHttpRequest();
   if (tok) {
      for (Beg = field.selectionStart;  Beg > 0 && !field.value.charAt(Beg-1).match(/\s/);  --Beg);
      End = field.selectionEnd;
   }
   else {
      Beg = 0;
      End = field.value.length;
   }
   if (event.keyCode != 45) {  // INS
      if (Beg == End) {
         Hint.style.visibility = "hidden";
         return false;
      }
      if (coy && Hint.style.visibility == "hidden")
         return false;
   }
   try {
      req.open("POST", (SesId? SesId : "") +
         ((i = field.id.lastIndexOf("-")) < 0?
            "!jsHint?$" + field.id : "!jsHint?+" + field.id.substr(i+1) ) );
   }
   catch (e) {return true;}
   req.onload = function() {
      var i, n, lst, str;

      if ((str = req.responseText).length == 0)
         Hint.style.visibility = "hidden";
      else {
         lst = str.split("&");
         while (Hints.hasChildNodes())
            Hints.removeChild(Hints.firstChild);
         for (i = 0, n = 7; i < lst.length; ++i) {
            addHint(i, field, str = decodeURIComponent(lst[i]));
            if (str.length > n)
               n = str.length;
         }
         Hints.style.width = n + 3 + "ex";
         Hint.style.width = n + 4 + "ex";
         Hint.style.visibility = "visible";
         Item = -1;
      }
   }
   var data = "*JsHint=" + encodeURIComponent(field.value.substring(Beg,End));
   for (i = 0; i < field.form.elements.length; ++i) {
      var fld = field.form.elements[i];

      if (fld.name == "*Get")
         data += "&*Get=" + fld.value;
      else if (fld.name == "*Form")
         data += "&*Form=" + fld.value;
   }
   try {req.send(data);}
   catch (e) {
      req.abort();
      return true;
   }
   return (event.keyCode != 45);  // INS
}

function addHint(i, field, str) {
   var item = document.createElement("div");
   item.appendChild(document.createTextNode(str));
   item.onmouseover = function() {
      if (Item >= 0)
         hintOff(Item);
      hintOn(i);
      field.onblur = false;
      field.onchange = false;
      Item = i;
   }
   item.onmouseout = function() {
      hintOff(Item);
      field.onblur = function() {
         Hint.style.visibility = "hidden";
      }
      field.onchange = function() {
         return fldChg(field);
      };
      Item = -1;
   }
   item.onclick = function() {
      setHint(field, item);
   }
   Hints.appendChild(item);
}

function setHint(field, item) {
   Hint.style.visibility = "hidden";
   field.value = field.value.substr(0,Beg) + item.firstChild.nodeValue + field.value.substr(End);
   Chg = true;
   post(field.form, false, null, null);
   field.setSelectionRange(Beg + item.firstChild.nodeValue.length, field.value.length);
   field.focus();
   field.onchange = function() {
      return fldChg(field)
   };
}

function hintOn(i) {
   var s = Hints.childNodes[i].style;
   s.background = "black";
   s.color= "white";
}

function hintOff(i) {
   var s = Hints.childNodes[i].style;
   s.background = "white";
   s.color= "black";
}

/*** Scroll/touch ***/
var TblY;

function tblTouch(event) {
   if (event.touches.length == 1)
      TblY = event.touches[0].pageY;
   return true;
}

function tblMove(table, event) {
   if (event.touches.length == 1) {
      var dy = event.touches[0].pageY - TblY;

      if (dy < -12 || dy > +12) {
         TblY = event.touches[0].pageY;
         for (var obj = table.parentNode;  obj;  obj = obj.parentNode)
            if (obj.tagName == "FORM")
               return post(obj, false,
                  [dy > 6? "jsUp" : "jsDn", "+" + table.getAttribute("chart")],
                  null );
      }
      return false;
   }
   return true;
}

/*** Lisp calls ***/
function lisp(form, fun) {
   if (form) {
      var exe = [fun];

      for (var i = 2; i < arguments.length; ++i)
         if (typeof arguments[i] === "number")
            exe[i-1] = "+" + arguments[i];
         else
            exe[i-1] = "." + encodeURIComponent(arguments[i]);
      return post(form, false, exe, null);
   }
   if (arguments.length > 2) {
      fun += "?" + lispVal(arguments[2]);
      for (var i = 3; i < arguments.length; ++i)
         fun += "&" + lispVal(arguments[i]);
   }
   var req = new XMLHttpRequest();
   try {req.open("GET", SesId + "!" + fun);}
   catch (e) {return true;}
   req.onload = function() {
      if (req.responseText)
         eval(req.responseText);
   }
   try {req.send(null);}
   catch (e) {
      req.abort();
      return true;
   }
   return false;
}

function lispVal(x) {
   if (typeof x === "number")
      return "+" + x;
   if (x.charAt(0) == "-")
      return "%2D" + encodeURIComponent(x.substr(1));
   return encodeURIComponent(x);
}

function ping(min) {
   if (SesId)
      setTimeout(function() {ping1(min)}, 20000);
}

function ping1(min) {
   lisp(null, "ping", min);
   setTimeout(function() {ping1(min)}, 20000);
}
