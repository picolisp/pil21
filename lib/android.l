# 19aug24 Software Lab. Alexander Burger

(ifn (info "UUID")
   (off *Uuid)
   (setq *Uuid (in "UUID" (line T)))
   (for F '("JAVA" "LISP" "RQST" "RPLY" "BOSS")
      (%@ "unlink" 'I F)
      (%@ "mkfifo" 'I F `(oct "600")) )
   (hear (open "BOSS")) )

(symbols 'android 'pico)

# SSL
(and *Uuid (sys "SSL_CERT_FILE" "tls/cert.pem"))

# Android Context
(local) (CONTEXT GUI Config javaExt)

(de CONTEXT . {H@@@40000000000})  # file 32768, obj (hex "100000000")

# (javaExt 'fun 'lst ..)
(de javaExt @
   (setq *Ext
      (sort
         (make
            (link (cons 32768 java))
            (while (next)
               (for N (next)
                  (link (cons N @)) ) ) ) ) ) )

# Java I/O
# (java "cls" 'T ['any ..]) -> obj         New object
# (java 'obj ['n] 'msg ['any ..]) -> any   Send message to object
# (java 'obj "fld" ['any]) -> any          Value of object field
# (java "cls" ['n] 'msg ['any ..]) -> any  Call method in class
# (java "cls" "fld" ['any]) -> any         Value of class field
# (java T "cls" ["cls" ..]) -> obj         Define interface
# (java 'obj) -> [lst ..]                  Reflect object
# (java "cls") -> cls                      Get class
# (java NIL 'obj) -> NIL                   Release reference to object
(local) (*Java *Lisp java1 java null)

(de java1 ()
   (unless *Java
      (setq *Java (open "JAVA")  *Lisp (open "LISP"))
      (let Rply (open "RPLY")
         (task (open "RQST")  Rply Rply
            (ext 32768
               (in @
                  (let (X (rd)  Obj (rd)  Lst (rd))
                     (nond
                        ((num? X)
                           (out Rply
                              (pr
                                 (and (get X Obj) (ext 0 (apply @ Lst))) ) ) )
                        ((get Obj 'catch)
                           (and *Dbg (tty (println Obj X Lst))) )
                        (NIL (ext 0 (apply @ Lst X))) ) ) ) ) )
         (push '*Fork
            '(off *Java *Lisp)
            (list 'mapc 'close (list Rply *Java *Lisp)) ) )
      (javaExt) ) )

(de java @
   (ext 32768
      (out *Java (pr (rest)))
      (in *Lisp
         (for (X (rd) X (rd))
            (and (=0 X) (quit (rd)))  # 0: Exception
            (let (Obj (rd)  Lst (rd))  # Callback
               (out *Java
                  (pr
                     (and (get X Obj) (ext 0 (apply @ Lst))) ) ) ) )
         (rd) ) ) )

(de null . null)

# Android device ID
(local) dev

(de dev ()
   (java "android.provider.Settings$Secure" 'getString
      (java CONTEXT 'getContentResolver)
      "android_id" ) )

# Push-Load
(local) (loadTxt loadUrl overview)

(de loadTxt @
   (java (; CONTEXT GUI) 'runOnUiThread
      (java (; CONTEXT GUI PilView) 0 'loadData
         (pack "<html><body>" (pass pack) "</body></html>")
         "text/html; charset=utf-8"
         null ) ) )

(de loadUrl @
   (java (; CONTEXT GUI) 'runOnUiThread
      (java (; CONTEXT GUI PilView) 0 'loadUrl (pass pack)) ) )

(de overview (Flg)
   (java (; CONTEXT GUI Config) 'setUseWideViewPort Flg)
   (java (; CONTEXT GUI Config) 'setLoadWithOverviewMode Flg) )

# Clear WebView history and cache
(local) (clearHistory clearCache)

(de clearHistory ()
   (java CONTEXT 'clearHistory) )

(de clearCache ()
   (java (; CONTEXT GUI) 'runOnUiThread
      (java (; CONTEXT GUI PilView) 0 'clearCache T) ) )

# Get permissions
(local) permit

(de permit (Str)
   (or
      (=0
         (java  "androidx.core.content.ContextCompat"
            'checkSelfPermission
            (; CONTEXT GUI)
            Str ) )
      (java  "androidx.core.app.ActivityCompat"
         'requestPermissions
         (; CONTEXT GUI)
         (list Str)
         0 ) ) )

# Wake lock
(local) (*Wake wake)

(de wake @  # (wake ['flg])
   (default *Wake  # PowerManager.WakeLock
      (java
         (java CONTEXT 'getSystemService "power")  # PowerManager
         'newWakeLock 1 "PilWake" ) )              # PARTIAL_WAKE_LOCK = 1
   (when (args)
      (cond
         ((next) (java *Wake 'acquire))
         ((java *Wake 'isHeld) (java *Wake 'release)) ) )
   (java *Wake 'isHeld) )

# Check if WIFI is active
(local) wifi?

(de wifi? ()
   (and
      (java
         (java CONTEXT 'getSystemService "connectivity")  # ConnectivityManager
         'getActiveNetworkInfo )  # NetworkInfo
      (=1 (java @ 'getType)) ) )  # onnectivityManager.TYPE_WIFI

# Generate file content URI
(local) fileUri

(de fileUri (File)
   (java "androidx.core.content.FileProvider" 'getUriForFile
      CONTEXT "de.software_lab.pilbox.fileprovider"
      (java "java.io.File" T File) ) )

# Update APK
(local) (update? update)

(de update? ()
   (gt0  # (java (java CONTEXT 'getPackageManager) 'canRequestPackageInstalls)
      (java "android.provider.Settings$Secure" 'getInt
         (java CONTEXT 'getContentResolver) "install_non_market_apps" ) ) )

(de update (File)
   (java (; CONTEXT GUI) 'startActivity
      (prog1
         (java "android.content.Intent" T "android.intent.action.INSTALL_PACKAGE")
         (java @ 'setFlags 1)  # Intent.FLAG_GRANT_READ_URI_PERMISSION
         (java @ 'setData (fileUri File)) ) ) )

# Toast
(local) toast

(de toast (X . @)
   (java CONTEXT 'toast (pass pack X))
   X )

# Notification
(local) (*Notify notify)

(de notify (Id Ttl Msg File Url)
   (let N (java CONTEXT 'getSystemService "notification")  # NotificationManager
      (ifn Ttl
         (java N 'cancel Id)
         (unless *Notify
            (java N 'createNotificationChannel
               (java "android.app.NotificationChannel" T "pil" "PilBox" 2) )  # IMPORTANCE_LOW = 2
            (on *Notify) )
         (let B (java "android.app.Notification$Builder" T CONTEXT "pil")
            (java B 'setSmallIcon (java "de.software_lab.pilbox.R$drawable" "notify"))
            (java B 'setContentTitle Ttl)
            (java B 'setContentText (or Msg null))
            (java B 'setAutoCancel T)
            (let Intent (java "android.content.Intent" T CONTEXT (java "de.software_lab.pilbox.PilBoxActivity"))  # Activity class
               (java Intent 'setFlags `(hex "24000000"))  # FLAG_ACTIVITY_SINGLE_TOP | FLAG_ACTIVITY_NEW_TASK
               (when File
                  (java Intent 'setAction "RPC")
                  (java Intent 'putExtra "UUID" *Uuid)
                  (java Intent 'putExtra "SRC" File)
                  (java Intent 'putExtra "ARG" Id)
                  (java Intent 'putExtra "URL" Url) )
               (java B 'setContentIntent
                  (java "android.app.PendingIntent" 'getActivity
                     CONTEXT 0 Intent `(hex "1C000000") ) ) )  # FLAG_ACTIVITY_NEW_TASK | FLAG_UPDATE_CURRENT | FLAG_IMMUTABLE
            (prog1
               (java B 'build)  # Notification
               (java N 'notify Id @) ) ) ) ) )

# Service foreground state
(local) (startForeground stopForeground)

(de startForeground (Ttl Msg Type)
   (java CONTEXT 'startForeground 1
      (notify 1 Ttl Msg)
      ~(as (>= (format (sys "SDK_INT")) 29) Type) ) )

(de stopForeground ()
   (java CONTEXT 'stopForeground T) )

# Start Activity for a result
(local) (*ResultProxy *ProxyResults startActivityForResult good bad)

(de startActivityForResult (Fun Action . @)
   (let Intent (java "android.content.Intent" T Action)
      (catch '("ActivityNotFound")
         (while (args)
            (let S (next)
               (if (str? S)
                  (java Intent 'putExtra S (next))
                  (java Intent S (next) (next)) ) ) )
         (unless *ResultProxy
            (setq *ResultProxy (java T "de.software_lab.pilbox.ResultProxy"))
            (def 'good *ResultProxy
               '((Req Intent)
                  (when (asoq Req *ProxyResults)
                     (del @ '*ProxyResults)
                     ((cdr @) Intent) ) ) )
            (def 'bad *ResultProxy
               '((Req Res)
                  (del (asoq Req *ProxyResults) '*ProxyResults) ) ) )
         (let Req (inc (0))
            (push '*ProxyResults (cons Req Fun))
            (java CONTEXT 'setResultProxy *ResultProxy)
            (java (; CONTEXT GUI) 'startActivityForResult Intent Req) ) ) ) )

# GPS access
(local) (*LocMan *GpsLsn *NetLsn location? gps)

(de location? ()
   (permit "android.permission.ACCESS_FINE_LOCATION") )

(de gps (Flg)
   (if Flg
      (when *LocMan
         (java *LocMan 'removeUpdates *GpsLsn)
         (java *LocMan 'removeUpdates *NetLsn)
         (off *LocMan) )
      (unless *LocMan
         (setq
            *LocMan (java CONTEXT 'getSystemService "location")
            *GpsLsn (java T "android.location.LocationListener")
            *NetLsn (java T "android.location.LocationListener") )
         (java *LocMan 'requestLocationUpdates "gps" (20000 . L) (100 . -1000) *GpsLsn)
         (java *LocMan 'requestLocationUpdates "network" (20000 . L) (100 . -1000) *NetLsn) )
      (and
         (or
            (and
               (java *LocMan 'isProviderEnabled "gps")
               (java *LocMan 'getLastKnownLocation "gps") )
            (and
               (java *LocMan 'isProviderEnabled "network")
               (java *LocMan 'getLastKnownLocation "network") ) )
         (cons
            (+ (java @ 'getLatitude) 90000000)
            (+ (java @ 'getLongitude) 180000000) ) ) ) )

# Camera access
(local) (camera? takePicture)

(de camera? ()
   (and
      (java (java CONTEXT 'getPackageManager) 'hasSystemFeature "android.hardware.camera")
      (permit "android.permission.CAMERA") ) )

## '((Intent)
##    (setq *Picture (tmp "img"))
##    (loadUrl (baseHRef) *SesId "app/camera.l") )
(de takePicture (Dst Fun)
   (out Dst)
   (startActivityForResult Fun
      "android.media.action.IMAGE_CAPTURE"
      "output" (fileUri Dst) ) )

# ZXing QR-Codes
## '((Intent)
##    (java Intent 'getStringExtra "SCAN_RESULT")
##    (java Intent 'getStringExtra "SCAN_RESULT_FORMAT") )
(local) scanQR

(de scanQR (Fun)
   (startActivityForResult Fun
      "com.google.zxing.client.android.SCAN"
      "SCAN_MODE" "QR_CODE_MODE" ) )

# Alarm
(local) (alarm? alarm)

(de alarm? ()
   ~(as (>= (format (sys "SDK_INT")) 31)
      (java (java CONTEXT 'getSystemService "alarm") 'canScheduleExactAlarms) )  # AlarmManager
   ~(as (> 31 (format (sys "SDK_INT"))) T) )

(de alarm (N When File Url)
   (let
      (Intent (java "android.content.Intent" T CONTEXT (java "de.software_lab.pilbox.Receiver"))
         Alarm (java CONTEXT 'getSystemService "alarm") )  # AlarmManager
      (ifn When
         (java Alarm 'cancel
            (java "android.app.PendingIntent" 'getBroadcast
               CONTEXT N Intent `(hex "1C000000") ) )  # FLAG_ACTIVITY_NEW_TASK | FLAG_UPDATE_CURRENT | FLAG_IMMUTABLE
         (java Intent 'putExtra "UUID" *Uuid)
         (java Intent 'putExtra "SRC" File)
         (java Intent 'putExtra "ARG" N)
         (java Intent 'putExtra "URL" Url)
         (java Alarm 'setExactAndAllowWhileIdle
            (if (atom When) 2 0)  # ELAPSED_REALTIME_WAKEUP RTC_WAKEUP
            (cons
               (if (atom When)
                  (+
                     (* 1000 When)
                     (java "android.os.SystemClock" 'elapsedRealtime) )
                  (let
                     (Dat (date (car When))
                        Tim (time (cdr When))
                        C (java "android.icu.util.Calendar" 'getInstance) )
                     (java C 'set
                        (car Dat) (dec (cadr Dat)) (caddr Dat)
                        (car Tim) (cadr Tim) (caddr Tim) )
                     (java C 'getTimeInMillis) ) )
               'L )
            (java "android.app.PendingIntent" 'getBroadcast
               CONTEXT N Intent `(hex "1C000000") ) ) ) ) )  # FLAG_ACTIVITY_NEW_TASK | FLAG_UPDATE_CURRENT | FLAG_IMMUTABLE

# Restart PilBox
(local) restart

(de restart ()
   (loadTxt)  # Blank screen
   (java (java (; CONTEXT GUI) 0 'restart) 'start)
   (wait) )

### Debug ###
`*Dbg

(noLint 'null)
