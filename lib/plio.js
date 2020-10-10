/* 21apr14abu
 * (c) Software Lab. Alexander Burger
 */

function plio(lst) {
   var NIX = 0;
   var BEG = 1;
   var DOT = 2;
   var END = 3;

   var NUMBER    = 0;
   var INTERN    = 1;
   var TRANSIENT = 2;

   var PlioPos = 1;
   var PlioLst = lst;
   var PlioCnt, PlioMore;

   function byte() {
      if (PlioCnt == 0) {
         if (!PlioMore || (PlioCnt = PlioLst[PlioPos++]) == 0)
            return -1;
         PlioMore = PlioCnt == 255;
      }
      --PlioCnt;
      return PlioLst[PlioPos++];
   }

   function expr(c) {
      if ((c & ~3) !== 0) {  // Atom
         PlioMore = (PlioCnt = c >> 2) === 63;
         if ((c & 3) === NUMBER) {
            c = byte();
            var n = c >> 1;
            var s = c & 1;
            var m = 128;
            while ((c = byte()) >= 0) {
               n += c * m;
               m *= 256;
            }
            return s == 0? n : -n;
         }
         var str = "";  // TRANSIENT
         while ((c = byte()) >= 0) {
            if ((c & 0x80) != 0) {
               if ((c & 0x20) == 0)
                  c &= 0x1F;
               else
                  c = (c & 0xF) << 6 | byte() & 0x3F;
               c = c << 6 | byte() & 0x3F;
            }
            str += String.fromCharCode(c);
         }
         return str;
      }
      if (c !== BEG)  // NIX, DOT or END
         return null;
      var i = 0;
      var lst = new Array();
      lst[0] = expr(PlioLst[PlioPos++]);
      while ((c = PlioLst[PlioPos++]) !== END  &&  c !== DOT)
         lst[++i] = expr(c);
      return lst;
   }

   return expr(PlioLst[0]);
}
