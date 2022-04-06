# 06apr22 Software Lab. Alexander Burger

(symbols 'gis 'pico)

(push1 '*JS (allow "@lib/gis.js"))

(local) (lat lon fmt)

(de lat (Lat F)
   (dec 'Lat 90.0)
   (if F
      (format (*/ Lat 1000 1.0) 3)
      (format Lat `*Scl) ) )

(de lon (Lon F)
   (dec 'Lon 180.0)
   (if F
      (format (*/ Lon 1000 1.0) 3)
      (format Lon `*Scl) ) )

(de fmt (Lat Str Lon F)
   (when (or Lat Lon)
      (pack (lat Lat F) Str (lon Lon F)) ) )

# Short distance, assuming flat earth
(local) distance

(de distance (Lat1 Lon1 Lat2 Lon2)  # [m]
   (let
      (DX (*/ (- Lon2 Lon1) 6378000 pi 180.0)
         DY (*/ (cos (*/ Lat1 pi 180.0)) (- Lat2 Lat1) 6378000 pi `(* 1.0 180.0)) )
      (sqrt (+ (* DX DX) (* DY DY))) ) )

# Latitude Field
(local) +LatField

(class +LatField +Fmt +FixField)

(dm T @
   (pass super
      '((Num) (- Num 90.0))
      '((Lat) (+ Lat 90.0))
      `*Scl ) )

# Longitude Field
(local) +LonField

(class +LonField +Fmt +FixField)

(dm T @
   (pass super
      '((Num) (- Num 180.0))
      '((Lon) (+ Lon 180.0))
      `*Scl ) )

# Clickable position field
(local) +LatLonField

(class +LatLonField +TextField)

(dm T (Msg . @)
   (=: msg Msg)
   (pass super)
   (=: able) )

(dm set> (X Dn)
   (=: obj (car X))
   (=: lt (cadr X))
   (=: ln (cddr X))
   (super (fmt (: lt) ", " (: ln)) Dn) )

(dm js> ()
   (if (try (: msg) (: obj) (: lt) (: ln))
      (pack
         (fmt (: lt) ", " (: ln))
         "&+"
         (ht:Fmt (sesId (mkUrl @))) )
      (super) ) )

(dm val> ()
   (cons (: obj) (: lt) (: ln)) )

(dm show> ("Var")
   (showFld
      (if (try (: msg) (: obj) (: lt) (: ln))
         (<href>
            (fmt (: lt) ", " (: ln))
            (mkUrl @) )
         (super "Var") ) ) )

# OpenLayers / OpenStreetMap
# (val *Osm) -> ((lat1 . lat2) (lon1 . lon2) . zoom)
(local) (*Osm <osm> osmStat osmClick osmDrag <poi> <line>)

(mapc allow '(osmStat osmClick osmDrag osmHover))

(de <osm> (Lat Lon Zoom Click Upd)
   (<div> '(map (id . map)))
   (when (val *Osm)
      (setq
         Lat (*/ (+ (caar @) (cdar @)) 2)
         Lon (*/ (+ (caadr @) (cdadr @)) 2)
         Zoom (cddr @) ) )
   (with *Top
      (css "https://cdn.rawgit.com/openlayers/openlayers.github.io/master/en/v5.3.0/css/ol.css")
      (javascript "https://cdn.rawgit.com/openlayers/openlayers.github.io/master/en/v5.3.0/build/ol.js"
         "osm('map', " Lat ", " Lon ", " Zoom ", "
         (if2 Click (and Upd (: able)) 2 1 0 0) ")" )
      (=: osmClick Click) ) )

(de osmStat (Lat1 Lon1 Lat2 Lon2 Zoom)
   (when *Osm
      (set @
         (cons
            (cons Lat1 Lat2)
            (cons Lon1 Lon2)
            Zoom ) ) ) )

(de osmClick (Lat Lon)
   (with *Top
      (and (: osmClick) (@ Lat Lon)) ) )

(de osmDrag (Txt Lat Lon)
   (with *Top
      (and
         (: able)
         (assoc Txt (: osmDrag))
         ((cdr @) Txt Lat Lon) ) ) )

(de osmHover (Txt)
   (with *Top
      (and
         (assoc Txt (: osmHover))
         ((cdr @) Txt) ) ) )

(de <poi> (Lat Lon Img X Y Txt DY Col Url Drag Upd Hover)
   (with *Top
      (<javascript>
         "poi(" Lat ", " Lon ", '" (sesId Img) "', " X ", " Y ", '"
         (replace (chop Txt) "\\" "\\\\" "'" "\\'")
         "', " DY ", '" Col "', '" (and Url (sesId @)) "', "
         (if2 (and Drag (: able)) Upd 2 1 0 0) ")" )
      (and Drag (push (:: osmDrag) (cons Txt @)))
      (and Hover (push (:: osmHover) (cons Txt @))) ) )

(de <line> (Col Lat1 Lon1 Lat2 Lon2)
   (with *Top
      (<javascript>
         "line('" Col "', " Lat1 ", " Lon1 ", " Lat2 ", " Lon2 ")" ) ) )

# Google Maps
(local) (google <google>)

(de google (Ttl Lat Lon Zoom Tar)
   (<href> Ttl
      (pack "https://www.google.com/maps/@" (fmt Lat "," Lon) "," Zoom "z")
      Tar ) )

(de <google> (Lat Lon DX DY)
   (prinl
      "<iframe width=\"" DX "\" height=\"" DY "\" frameborder=\"3\" \
      src=\"https://www.google.com/maps?source=s_q&amp;q="
      (fmt Lat "," Lon)
      "&amp;output=embed\"></iframe>" ) )
