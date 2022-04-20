# 20apr22 Software Lab. Alexander Burger

(symbols 'svg 'pico)

(local) (*A4-DX *A4-DY *StrokeWidth *FontSize *FontFamily *FontStyle *FontWeight)

(de *A4-DX . 598)
(de *A4-DY . 842)
(de *A3-DX . 842)
(de *A3-DY . 1188)

(default
   *StrokeWidth 1
   *FontSize 12
   *FontFamily "serif"
   *FontStyle "normal"
   *FontWeight "normal" )

# *Style htStyle dfltCss htPrin (lib/xhtml.l or lib/htm.l)

(local) (<svg> *DX *DY *Pos)
(private) (DX DY X Y Z Prg)

# SVG Element
(de <svg> (*DX *DY Z . Prg)
   (prin
      "<svg version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink"
      "\" width=\"" (if (num? Z) (* @ *DX) (pack *DX Z))
      "\" height=\"" (if (num? Z) (* @ *DY) (pack *DY Z))
      "\" viewBox=\"0 0 " *DX " " *DY "\"" )
   (dfltCss "svg")
   (prinl ">")
   (let *Pos 0
      (prog1
         (run Prg)
         (prinl "</svg>") ) ) )

(local) (rect circle polyline polygon image xlink)

# Graphics
(de rect (X Y DX DY Fill Stroke)
   (prin
      "<rect x=\"" X
      "\" y=\"" Y
      "\" width=\"" DX
      "\" height=\"" DY
      "\" fill=\"" (or Fill "none")
      "\" stroke=\"" (or Stroke (if Fill "none" "black"))
      "\" stroke-width=\"" *StrokeWidth "\"" )
   (and *Style (htStyle @))
   (prinl "/>") )

(de circle (X Y R Fill Stroke)
   (prin
      "<circle cx=\"" X
      "\" cy=\"" Y
      "\" r=\"" R
      "\" fill=\"" (or Fill "none")
      "\" stroke=\"" (or Stroke (if Fill "none" "black"))
      "\" stroke-width=\"" *StrokeWidth "\"" )
   (and *Style (htStyle @))
   (prinl "/>") )

(de polyline (Stroke . @)
   (prin "<polyline fill=\"none\" stroke=\"" Stroke "\" stroke-width=\"" *StrokeWidth "\" points=\"" (next))
   (while (args)
      (prin " " (next)) )
   (prin "\"")
   (and *Style (htStyle @))
   (prinl "/>") )

(de polygon (Fill . @)
   (prin "<polygon fill=\"" Fill "\" points=\"" (next))
   (while (args)
      (prin " " (next)) )
   (prin "\"")
   (and *Style (htStyle @))
   (prinl "/>") )

(de image (Img Typ X Y SX SY)
   (prinl "<image xlink:href=\"data:" Typ ";base64,")
   (in Img (prBase64 18))
   (prin
      "\" x=\"" X
      "\" y=\"" Y
      "\" width=\"" (or SX "100%")
      "\" height=\"" (or SY SX "100%") "\"" )
   (and *Style (htStyle @))
   (prinl "/>") )

(private) (Url Prg)

(de xlink (Url . Prg)
   (prinl "<a xlink:href=\"" Url "\">")
   (run Prg)
   (prinl "</a>") )

# Text
(local) (<faces> <text> font width italic bold indent rotate window ps height)
(private) (A N X Y Prg)

(de <faces> (Lst)
   (prinl "<style type=\"text/css\">")
   (for L Lst
      (prin
         "@font-face {font-family: '" (car L)
         "'; src: url('" (srcUrl (cadr L)) "')" )
      (for S (cddr L)
         (prin ", url('" (srcUrl S) "')") )
      (prinl "}") )
   (prinl "</style>") )

(de <text> (X Y . Prg)
   (prin "<text x=\"" X "\" y=\"" Y
      "\" font-size=\"" *FontSize
      "\" font-family=\"" *FontFamily
      "\" font-style=\"" *FontStyle
      "\" font-weight=\"" *FontWeight "\"" )
   (and *Style (htStyle @))
   (prin ">")
   (htPrin Prg 2)
   (prinl "</text>") )

(de font (X . Prg)
   (ifn Prg
      (cond
         ((num? X) (setq *FontSize X))
         ((sym? X) (setq *FontFamily X))
         (T (setq *FontSize (car X)  *FontFamily (fin X))) )
      (cond
         ((num? X)
            (let *FontSize X
               (run Prg 1) ) )
         ((sym? X)
            (let *FontFamily X
               (run Prg 1) ) )
         (T
            (let (*FontSize (car X)  *FontFamily (fin X))
               (run Prg 1) ) ) ) ) )

(de width (N . Prg)
   (ifn Prg
      (setq *StrokeWidth N)
      (let *StrokeWidth N
         (run Prg 1) ) ) )

(de italic Prg
   (let *FontStyle 'italic
      (run Prg) ) )

(de bold Prg
   (let *FontWeight 'bold
      (run Prg) ) )

(de indent (X . Prg)
   (prinl "<g transform=\"translate(" X ",0)\">")
   (dec '*DX X)
   (prog1
      (run Prg)
      (prinl "</g>") ) )

(de rotate (A . Prg)
   (prinl "<g transform=\"rotate(" A ")\">")
   (prog1
      (run Prg)
      (prinl "</g>") ) )

(de window (X Y *DX *DY . Prg)
   (prinl "<g transform=\"translate(" X "," Y ")\">")
   (let *Pos 0
      (prog1
         (run Prg)
         (prinl "</g>") ) ) )

(de ps @
   (let A (arg 1)
      (if (memq A (0 NIL T))
         (next)
         (off A) )
      (prin
         "<text x=\"" (case A (NIL 0) (0 (/ *DX 2)) (T *DX))
         "\" y=\"" (inc '*Pos *FontSize)
         "\" text-anchor=\"" (case A (NIL "start") (0 "middle") (T "end"))
         "\" font-size=\"" *FontSize
         "\" font-family=\"" *FontFamily
         "\" font-style=\"" *FontStyle
         "\" font-weight=\"" *FontWeight "\"" ) )
   (and *Style (htStyle @))
   (prin ">")
   (let H NIL
      (while (args)
         (let X (next)
            (cond
               ((pair X)
                  (casq (++ X)
                     (B  # Bold
                        (prin (if X "<tspan font-weight=\"bold\">" "</tspan>")) )
                     (I  # Italic
                        (prin (if X "<tspan font-style=\"italic\">" "</tspan>")) )
                     (S  # Superscript
                        (prin (if X "<tspan baseline-shift=\"super\">" "</tspan>")) )
                     (U  # Underline
                        (prin (if X "<tspan text-decoration=\"underline\">" "</tspan>")) )
                     (L  # Line through
                        (prin (if X "<tspan text-decoration=\"line-through\">" "</tspan>")) )
                     (C  # Color
                        (if X
                           (prin "<tspan fill=\"" X "\">")
                           (prin "</tspan>") ) ) ) )
               ((=0 X)  # Newline
                  (prin
                     "<tspan x=\"" (case A (NIL 0) (0 (/ *DX 2)) (T *DX))
                     "\" y=\"" (inc '*Pos *FontSize)
                     "\">\8203\</tspan>" ) )  # ZERO WIDTH SPACE
               ((=T X)  # Horizontal line
                  (push 'H (- *Pos (/ *FontSize 2)))
                  (prin
                     "<tspan x=\"" (case A (NIL 0) (0 (/ *DX 2)) (T *DX))
                     "\" y=\"" (inc '*Pos (*/ *FontSize 2 3))
                     "\">\8203\</tspan>" ) )  # ZERO WIDTH SPACE
               (T (ht:Prin X)) ) ) )
      (prinl "</text>")
      (for Y H
         (polyline "black" 0 Y *DX Y) ) ) )

(de height @
   (let H *FontSize
      (while (args)
         (let X (next)
            (cond
               ((=0 X) (inc 'H *FontSize))  # Newline
               ((=T X) (inc 'H (*/ *FontSize 2 3))) ) ) )  # Horizontal line
      H ) )

(local) (down table hline vline)
(private) (Fmt Prg)

(de down (N)
   (inc '*Pos (or N *FontSize)) )

(de table (Fmt . Prg)
   (let (PosX 0  Max *FontSize)
      (ifn (=T Fmt)
         (mapc
            '((N Exe)
               (when
                  (or
                     (nT (car (pair Exe)))
                     (setq Exe (run (cdr Exe) 2)) )
                  (window PosX *Pos N Max
                     (if (atom Exe)
                        (ps NIL (eval Exe 3))
                        (eval Exe 3) )
                     (inc 'PosX N)
                     (setq Max (max *Pos Max)) ) ) )
            Fmt
            Prg )
         (for
            (N (co 'table (run Prg) (yield))
               N
               (window PosX *Pos N Max
                  (prog1
                     (co 'table T)
                     (inc 'PosX N)
                     (setq Max (max *Pos Max)) ) ) ) )
         (co 'table) )
      (inc '*Pos Max) ) )

(de hline (Y X2 X1)
   (inc 'Y *Pos)
   (polyline "black" (or X2 *DX) Y (or X1 0) Y) )

(de vline (X Y2 Y1)
   (polyline "black" X (or Y2 *DY) X (or Y1 0)) )

(local) brief
(private) (Flg Font Abs Prg)

(de brief (Flg Font Abs . Prg)
   (when Flg
      (polyline "black" 10 265  19 265)         # Faltmarken
      (polyline "black" 10 421  19 421) )
   (polyline "black" 50 106  50 103  53 103)    # Fenstermarken
   (polyline "black" 50 222  50 225  53 225)
   (polyline "black" 288 103  291 103  291 106)
   (polyline "black" 288 225  291 225  291 222)
   (polyline "black" 50 114  291 114)           # Absender
   (window 60 102 220 10
      (font Font (ps 0 Abs)) )
   (window 65 125 210 90
      (run Prg 2) ) )

(local) (svgOut svgPages page.svg svgPdf pdf)
(private) (Src Dst Prg Prg2)

# Direct SVG display
(de svgOut Prg
   (httpHead "image/svg+xml" 0)
   (ht:Out *Chunked (run Prg)) )

# Multipage SVG
(de svgPages (*DX *DY Dst . Prg)
   (zero *Page)
   (out Dst
      (let page
         '(Prg2
            (prin "<" (inc '*Page) ">")
            (<svg> *DX *DY "pt"
               (run Prg2) ) )
         (run Prg) ) )
   Dst )

(de page.svg (File N)
   (in File
      (from (pack "<" N ">"))
      (echo (pack "<" (inc N) ">")) ) )

# Convert to PDF
(de svgPdf (Dst . Prg)
   (let Src (tmp "pdf.svg")
      (out Src (run Prg))
      (call "rsvg-convert" "-f" "pdf" "-o" Dst Src) )
   Dst )

# Multipage PDF
# (pdf "src" "dst")
# (pdf 'dx 'dy "dst" . prg)
(de pdf (*DX *DY Dst . Prg)
   (if Dst
      (let page  # Generate SVG files
         '(Prg2
            (out (tmp "page" (inc '*Page) ".svg")
               (<svg> *DX *DY "pt"
                  (run Prg2) ) ) )
         (zero *Page)
         (run Prg) )
      (in *DX  # Multipage SVG file
         (when (echo (pack "<" (one *Page) ">"))
            (while
               (out (tmp "page" *Page ".svg")
                  (when (echo (pack "<" (inc *Page) ">"))
                     (inc '*Page) ) ) ) ) )
      (setq Dst *DY) )
   (apply call
      (make
         (for I *Page
            (link (tmp "page" I ".svg")) ) )
      "rsvg-convert"
      "--dpi-x" 72
      "--dpi-y" 72
      "-f" "pdf"
      "-o" Dst )
   Dst )

### Debug ###
`*Dbg

(noLint 'svgPages 'page)
(noLint 'pdf 'page)
