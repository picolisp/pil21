# 26oct20 Software Lab. Alexander Burger
# 01sep15or
# 27jul10jk

(load "@lib/math.l")

### OpenGL library interface ###
(symbols 'openGl 'pico)

(local) (*GluLib *GlutLib)

(if (= *OS "Darwin")
   (default
      *GluLib "OpenGL.framework/OpenGL"
      *GlutLib "GLUT.framework/GLUT" )
   (default
      *GluLib "libGLU.so.1"
      *GlutLib "libglut.so.3" ) )

# Pre-consed fixpoint arguments
(local) (*Flt1 *Flt2 *Flt3 *Flt4 *Dbl1 *Dbl2 *Dbl3 *Dbl4 *Dbl5 *Dbl6)

(setq
   *Flt1 (0 . -1.0)
   *Flt2 (0 . -1.0)
   *Flt3 (0 . -1.0)
   *Flt4 (0 . -1.0)
   *Dbl1 (0 . 1.0)
   *Dbl2 (0 . 1.0)
   *Dbl3 (0 . 1.0)
   *Dbl4 (0 . 1.0)
   *Dbl5 (0 . 1.0)
   *Dbl6 (0 . 1.0) )

# Utilities
(local) (ivect fvect)

(de ivect (Lst)
   (mapcar '((N) (- -4294967296 N)) Lst) )

(de fvect (Lst)
   (mapcar
      '((N) (- -4294967296 (*/ 2147483647 N 1.0)))
      Lst ) )


### /usr/include/GL/gl.h ###
### Constant Definitions ###

# Data types
(local) (GL_BYTE GL_UNSIGNED_BYTE GL_SHORT GL_UNSIGNED_SHORT GL_INT
GL_UNSIGNED_INT GL_FLOAT GL_2_BYTES GL_3_BYTES GL_4_BYTES GL_DOUBLE)

(def 'GL_BYTE           (hex "1400"))
(def 'GL_UNSIGNED_BYTE  (hex "1401"))
(def 'GL_SHORT          (hex "1402"))
(def 'GL_UNSIGNED_SHORT (hex "1403"))
(def 'GL_INT            (hex "1404"))
(def 'GL_UNSIGNED_INT   (hex "1405"))
(def 'GL_FLOAT          (hex "1406"))
(def 'GL_2_BYTES        (hex "1407"))
(def 'GL_3_BYTES        (hex "1408"))
(def 'GL_4_BYTES        (hex "1409"))
(def 'GL_DOUBLE         (hex "140A"))

# Primitives
(local) (GL_POINTS GL_LINES GL_LINE_LOOP GL_LINE_STRIP GL_TRIANGLES
GL_TRIANGLE_STRIP GL_TRIANGLE_FAN GL_QUADS GL_QUAD_STRIP GL_POLYGON)

(def 'GL_POINTS         (hex "0000"))
(def 'GL_LINES          (hex "0001"))
(def 'GL_LINE_LOOP      (hex "0002"))
(def 'GL_LINE_STRIP     (hex "0003"))
(def 'GL_TRIANGLES      (hex "0004"))
(def 'GL_TRIANGLE_STRIP (hex "0005"))
(def 'GL_TRIANGLE_FAN   (hex "0006"))
(def 'GL_QUADS          (hex "0007"))
(def 'GL_QUAD_STRIP     (hex "0008"))
(def 'GL_POLYGON        (hex "0009"))

# Matrix Mode
(local) (GL_MATRIX_MODE GL_MODELVIEW GL_PROJECTION GL_TEXTURE)

(def 'GL_MATRIX_MODE    (hex "0BA0"))
(def 'GL_MODELVIEW      (hex "1700"))
(def 'GL_PROJECTION     (hex "1701"))
(def 'GL_TEXTURE        (hex "1702"))

# Points

# Lines
(local) GL_LINE_SMOOTH

(def 'GL_LINE_SMOOTH       (hex "00000B20"))

# Polygons
(local) (GL_FRONT GL_CULL_FACE)

(def 'GL_FRONT             (hex "0404"))
(def 'GL_CULL_FACE         (hex "00000B44"))

# Display Lists

# Depth buffer
(local) (GL_LESS GL_DEPTH_TEST)

(def 'GL_LESS              (hex "00000201"))
(def 'GL_DEPTH_TEST        (hex "00000B71"))

# Lighting
(local) (GL_LIGHTING GL_LIGHT0 GL_SPECULAR GL_SHININESS GL_POSITION
GL_AMBIENT_AND_DIFFUSE GL_FRONT_AND_BACK GL_FLAT GL_SMOOTH GL_COLOR_MATERIAL)

(def 'GL_LIGHTING             (hex "0B50"))
(def 'GL_LIGHT0               (hex "4000"))
(def 'GL_SPECULAR             (hex "1202"))
(def 'GL_SHININESS            (hex "1601"))
(def 'GL_POSITION             (hex "1203"))
(def 'GL_AMBIENT_AND_DIFFUSE  (hex "1602"))
(def 'GL_FRONT_AND_BACK       (hex "0408"))
(def 'GL_FLAT                 (hex "1D00"))
(def 'GL_SMOOTH               (hex "1D01"))
(def 'GL_COLOR_MATERIAL       (hex "0B57"))

# User clipping planes

# Accumulation buffer

# Alpha testing

# Blending
(local) (GL_BLEND GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA)

(def 'GL_BLEND                (hex "0BE2"))
(def 'GL_SRC_ALPHA            (hex "0302"))
(def 'GL_ONE_MINUS_SRC_ALPHA  (hex "0303"))

# Render Mode

# Feedback

# Selection

# Fog

# Logic Ops

# Stencil

# Buffers, Pixel Drawing/Reading

# Implementation limits

# Gets

# Evaluators

# Hints
(local) (GL_LINE_SMOOTH_HINT GL_NICEST)

(def 'GL_LINE_SMOOTH_HINT     (hex "0C52"))
(def 'GL_NICEST               (hex "1102"))

# Scissor box

# Pixel Mode / Transfer

# Texture mapping
(local) (GL_BGR GL_BGRA GL_RGB GL_RGBA GL_PROGRAM_POINT_SIZE)

(def 'GL_BGR                           (hex "80E0"))
(def 'GL_BGRA                          (hex "80E1"))
(def 'GL_RGB                           (hex "1907"))
(def 'GL_RGBA                          (hex "1908"))
(def 'GL_PROGRAM_POINT_SIZE            (hex "8642"))

(local) (GL_TEXTURE_1D GL_TEXTURE_2D GL_TEXTURE_3D GL_TEXTURE_1D_ARRAY
GL_TEXTURE_2D_ARRAY GL_TEXTURE_RECTANGLE GL_TEXTURE_CUBE_MAP
GL_TEXTURE_CUBE_MAP_ARRAY GL_TEXTURE_BUFFER GL_TEXTURE_2D_MULTISAMPLE
GL_TEXTURE_2D_MULTISAMPLE_ARRAY GL_TEXTURE_MAG_FILTER GL_TEXTURE_MIN_FILTER
GL_NEAREST GL_NEAREST_MIPMAP_NEAREST GL_NEAREST_MIPMAP_LINEAR GL_LINEAR
GL_LINEAR_MIPAP_NEAREST GL_LINEAR_MIPAP_LINEAR)

(def 'GL_TEXTURE_1D                    (hex "0DE0"))
(def 'GL_TEXTURE_2D                    (hex "0DE1"))
(def 'GL_TEXTURE_3D                    (hex "806F"))
(def 'GL_TEXTURE_1D_ARRAY              (hex "8C18"))
(def 'GL_TEXTURE_2D_ARRAY              (hex "8C1A"))
(def 'GL_TEXTURE_RECTANGLE             (hex "84F5"))
(def 'GL_TEXTURE_CUBE_MAP              (hex "8513"))
(def 'GL_TEXTURE_CUBE_MAP_ARRAY        (hex "9009"))
(def 'GL_TEXTURE_BUFFER                (hex "8C2A"))
(def 'GL_TEXTURE_2D_MULTISAMPLE        (hex "9100"))
(def 'GL_TEXTURE_2D_MULTISAMPLE_ARRAY  (hex "9102"))
(def 'GL_TEXTURE_MAG_FILTER            (hex "2800"))
(def 'GL_TEXTURE_MIN_FILTER            (hex "2801"))
(def 'GL_NEAREST                       (hex "2600"))
(def 'GL_NEAREST_MIPMAP_NEAREST        (hex "2700"))
(def 'GL_NEAREST_MIPMAP_LINEAR         (hex "2702"))
(def 'GL_LINEAR                        (hex "2601"))
(def 'GL_LINEAR_MIPAP_NEAREST          (hex "2701"))
(def 'GL_LINEAR_MIPAP_LINEAR           (hex "2703"))

# Utility

# Errors
(local) glGetError

(de glGetError ()
   (hex (native `*GlutLib "glGetError" 'N)) )

# glPush/PopAttrib bits
(local) (GL_CURRENT_BIT GL_POINT_BIT GL_LINE_BIT GL_POLYGON_BIT
GL_POLYGON_STIPPLE_BIT GL_PIXEL_MODE_BIT GL_LIGHTING_BIT GL_FOG_BIT
GL_DEPTH_BUFFER_BIT GL_ACCUM_BUFFER_BIT GL_STENCIL_BUFFER_BIT GL_VIEWPORT_BIT
GL_TRANSFORM_BIT GL_ENABLE_BIT GL_COLOR_BUFFER_BIT GL_HINT_BIT GL_EVAL_BIT
GL_LIST_BIT GL_TEXTURE_BIT GL_SCISSOR_BIT GL_ALL_ATTRIB_BITS)

(def 'GL_CURRENT_BIT          (hex "00000001"))
(def 'GL_POINT_BIT            (hex "00000002"))
(def 'GL_LINE_BIT             (hex "00000004"))
(def 'GL_POLYGON_BIT          (hex "00000008"))
(def 'GL_POLYGON_STIPPLE_BIT  (hex "00000010"))
(def 'GL_PIXEL_MODE_BIT       (hex "00000020"))
(def 'GL_LIGHTING_BIT         (hex "00000040"))
(def 'GL_FOG_BIT              (hex "00000080"))
(def 'GL_DEPTH_BUFFER_BIT     (hex "00000100"))
(def 'GL_ACCUM_BUFFER_BIT     (hex "00000200"))
(def 'GL_STENCIL_BUFFER_BIT   (hex "00000400"))
(def 'GL_VIEWPORT_BIT         (hex "00000800"))
(def 'GL_TRANSFORM_BIT        (hex "00001000"))
(def 'GL_ENABLE_BIT           (hex "00002000"))
(def 'GL_COLOR_BUFFER_BIT     (hex "00004000"))
(def 'GL_HINT_BIT             (hex "00008000"))
(def 'GL_EVAL_BIT             (hex "00010000"))
(def 'GL_LIST_BIT             (hex "00020000"))
(def 'GL_TEXTURE_BIT          (hex "00040000"))
(def 'GL_SCISSOR_BIT          (hex "00080000"))
(def 'GL_ALL_ATTRIB_BITS      (hex "000FFFFF"))

# Miscellaneous
(local) (glClearColor glClear glBlendFunc glLineWidth glEnable glDisable glFlush
glHint)

(de glClearColor (Red Green Blue Alpha)
   (set *Flt1 Red  *Flt2 Green  *Flt3 Blue  *Flt4 Alpha)
   (native `*GlutLib "glClearColor" NIL *Flt1 *Flt2 *Flt3 *Flt4) )

(de glClear (Mask)
   (native `*GlutLib "glClear" NIL Mask) )

(de glBlendFunc (SFactor DFactor)
   (native `*GlutLib "glBlendFunc" NIL SFactor DFactor) )

(de glLineWidth (Width)
   (set *Flt1 Width)
   (native `*GlutLib "glLineWidth" NIL *Flt1) )

(de glEnable (Num)
   (native `*GlutLib "glEnable" NIL Num) )

(de glDisable (Num)
   (native `*GlutLib "glDisable" NIL Num) )

(de glFlush ()
   (native `*GlutLib "glFlush") )

(de glHint (Target Mode)
   (native `*GlutLib "glHint" NIL Target Mode) )

# Depth Buffer
(local) (glClearDepth glDepthFunc)

(de glClearDepth (Depth)
   (set *Dbl1 Depth)
   (native `*GlutLib "glClearDepth" NIL *Dbl1) )

(de glDepthFunc (Num)
   (native `*GlutLib "glDepthFunc" NIL Num) )

# Accumulation Buffer

# Transformation
(local) (glMatrixMode glOrtho glViewport glPushMatrix glPopMatrix glLoadIdentity
glRotatef glTranslatef)

(de glMatrixMode (Mode)
   (native `*GlutLib "glMatrixMode" NIL Mode) )

(de glOrtho (Left Right Bottom Top Near Far)
   (set *Dbl1 Left  *Dbl2 Right  *Dbl3 Bottom  *Dbl4 Top  *Dbl5 Near  *Dbl6 Far)
   (native `*GlutLib "glOrtho" NIL *Dbl1 *Dbl2 *Dbl3 *Dbl4 *Dbl5 *Dbl6) )

(de glViewport (X Y Width Height)
   (native `*GlutLib "glViewport" NIL X Y Width Height) )

(de glPushMatrix ()
   (native `*GlutLib "glPushMatrix") )

(de glPopMatrix ()
   (native `*GlutLib "glPopMatrix") )

(de glLoadIdentity ()
   (native `*GlutLib "glLoadIdentity") )

(de glRotatef (A X Y Z)
   (set *Flt1 A  *Flt2 X  *Flt3 Y  *Flt4 Z)
   (native `*GlutLib "glRotatef" NIL *Flt1 *Flt2 *Flt3 *Flt4) )

(de glTranslatef (X Y Z)
   (set *Flt1 X  *Flt2 Y  *Flt3 Z)
   (native `*GlutLib "glTranslatef" NIL *Flt1 *Flt2 *Flt3) )

# Display Lists
(local) (GL_COMPILE GL_COMPILE_AND_EXECUTE)

(def 'GL_COMPILE              (hex "1300"))
(def 'GL_COMPILE_AND_EXECUTE  (hex "1301"))

# Drawing Functions
(local) (glBegin glEnd glVertex2f glVertex3f glNormal3f glColor3f glColor4f)

(de glBegin (Mode)
   (native `*GlutLib "glBegin" NIL Mode) )

(de glEnd ()
   (native `*GlutLib "glEnd") )

(de glVertex2f (X Y)
   (set *Flt1 X  *Flt2 Y)
   (native `*GlutLib "glVertex2f" NIL *Flt1 *Flt2) )

(de glVertex3f (X Y Z)
   (set *Flt1 X  *Flt2 Y  *Flt3 Z)
   (native `*GlutLib "glVertex3f" NIL *Flt1 *Flt2 *Flt3) )

(de glNormal3f (X Y Z)
   (set *Flt1 X  *Flt2 Y  *Flt3 Z)
   (native `*GlutLib "glNormal3f" NIL *Flt1 *Flt2 *Flt3) )

(de glColor3f (Red Green Blue)
   (set *Flt1 Red  *Flt2 Green  *Flt3 Blue)
   (native `*GlutLib "glColor3f" NIL *Flt1 *Flt2 *Flt3) )

(de glColor4f (Red Green Blue Alpha)
   (set *Flt1 Red  *Flt2 Green  *Flt3 Blue  *Flt4 Alpha)
   (native `*GlutLib "glColor4f" NIL *Flt1 *Flt2 *Flt3 *Flt4) )

# Vertex Arrays

# Lighting
(local) (glShadeModel glLightiv glMaterialf glMaterialfv glColorMaterial)

(de glShadeModel (Num)
   (native `*GlutLib "glShadeModel" NIL Num) )

(de glLightiv (Light Pname Params)
   (native `*GlutLib "glLightiv" NIL Light Pname
      (cons NIL (16) (ivect Params)) ) )

(de glMaterialf (Face Pname Param)
   (set *Flt1 Param)
   (native `*GlutLib "glMaterialf" NIL Face Pname *Flt1) )

(de glMaterialfv (Face Pname Params)  # Calls 'iv' internally!
   (native `*GlutLib "glMaterialiv" NIL Face Pname
      (cons NIL (16) (fvect Params)) ) )

(de glColorMaterial (Face Mode)
   (native `*GlutLib "glColorMaterial" NIL Face Mode) )

# Raster functions

# Stenciling

# Texture mapping
(local) (glBindTexture glIsTexture glGenTextures glTexCoord2f glTexImage2D
glBlendEquation glPointSize glTexParameterf glTexStorage2D glTexSubImage2D)

(de glBindTexture (Target Texture)
   (native `*GlutLib "glBindTexture" Target Texture) )

(de glIsTexture (Texture)
   (native `*GlutLib "glIsTexture" 'N Texture) )

#{ not working
(de glGenTextures (N Textures)
   (native `*GlutLib "glGenTextures" NIL N (list (cons (* 8 N) (cons 'N N)))) )

(de glGenTextures (N Textures)
   (eval (list 'setq Textures (tmpglgentex N))) )
}#

(de glTexCoord2f (X Y)
   (set *Flt1 X *Flt2 Y)
   (native `*GlutLib "glTexCoord2f" NIL *Flt1 *Flt2) )

(de glTexImage2D (Target Level InternalFormat Width Height Border Format Type Data)
   (native `*GlutLib "glTexImage2D"
      Target Level InternalFormat
      Width Height Border
      Format Type Data ) )

(de glBlendEquation (Mode)
   (native `*GlutLib "glBlendEquation" NIL Mode) )

(de glPointSize (Size)
   (set *Flt1 Size)
   (native `*GlutLib "glPointSize" NIL *Flt1) )

(de glTexParameterf (Target Pname Param)
   (native `*GlutLib "glTexParameterf" NIL Target Pname Param) )

(de glTexStorage2D (Target levels internalformat Width Height)
   (native `*GlutLib "glTexStorage2D" NIL
      Target levels
      internalformat Width Height) )

(de glTexSubImage2D (Target Level xoffset yoffset Width Height Format Type pixels)
   (native `*GlutLib "glTexSubImage2D"
      Target Level xoffset
      yoffset Width Height
      Format Type pixels ) )

# Evaluators

# Fog

# Selection and Feedback



### /usr/include/GL/glu.h ###
(local) gluPerspective

(de gluPerspective (Fovy Aspect ZNear ZFar)
   (set *Dbl1 Fovy  *Dbl2 Aspect  *Dbl3 ZNear  *Dbl4 ZFar)
   (native `*GluLib "gluPerspective" NIL *Dbl1 *Dbl2 *Dbl3 *Dbl4) )

### /usr/include/GL/freeglut_std.h ###

# Special key codes
(local) (GLUT_KEY_F1 GLUT_KEY_F2 GLUT_KEY_F3 GLUT_KEY_F4 GLUT_KEY_F5 GLUT_KEY_F6
GLUT_KEY_F7 GLUT_KEY_F8 GLUT_KEY_F9 GLUT_KEY_F10 GLUT_KEY_F11 GLUT_KEY_F12
GLUT_KEY_LEFT GLUT_KEY_UP GLUT_KEY_RIGHT GLUT_KEY_DOWN GLUT_KEY_PAGE_UP
GLUT_KEY_PAGE_DOWN GLUT_KEY_HOME GLUT_KEY_END GLUT_KEY_INSERT)

(def 'GLUT_KEY_F1          1)
(def 'GLUT_KEY_F2          2)
(def 'GLUT_KEY_F3          3)
(def 'GLUT_KEY_F4          4)
(def 'GLUT_KEY_F5          5)
(def 'GLUT_KEY_F6          6)
(def 'GLUT_KEY_F7          7)
(def 'GLUT_KEY_F8          8)
(def 'GLUT_KEY_F9          9)
(def 'GLUT_KEY_F10         10)
(def 'GLUT_KEY_F11         11)
(def 'GLUT_KEY_F12         12)
(def 'GLUT_KEY_LEFT        100)
(def 'GLUT_KEY_UP          101)
(def 'GLUT_KEY_RIGHT       102)
(def 'GLUT_KEY_DOWN        103)
(def 'GLUT_KEY_PAGE_UP     104)
(def 'GLUT_KEY_PAGE_DOWN   105)
(def 'GLUT_KEY_HOME        106)
(def 'GLUT_KEY_END         107)
(def 'GLUT_KEY_INSERT      108)

# Mouse state definitions
(local) (GLUT_LEFT_BUTTON GLUT_MIDDLE_BUTTON GLUT_RIGHT_BUTTON)

(def 'GLUT_LEFT_BUTTON     0)
(def 'GLUT_MIDDLE_BUTTON   1)
(def 'GLUT_RIGHT_BUTTON    2)

# Display mode definitions
(local) (GLUT_RGB GLUT_RGBA GLUT_INDEX GLUT_SINGLE GLUT_DOUBLE GLUT_ACCUM
GLUT_ALPHA GLUT_DEPTH GLUT_STENCIL GLUT_MULTISAMPLE GLUT_STEREO GLUT_LUMINANCE)

(def 'GLUT_RGB          (hex "0000"))
(def 'GLUT_RGBA         (hex "0000"))
(def 'GLUT_INDEX        (hex "0001"))
(def 'GLUT_SINGLE       (hex "0000"))
(def 'GLUT_DOUBLE       (hex "0002"))
(def 'GLUT_ACCUM        (hex "0004"))
(def 'GLUT_ALPHA        (hex "0008"))
(def 'GLUT_DEPTH        (hex "0010"))
(def 'GLUT_STENCIL      (hex "0020"))
(def 'GLUT_MULTISAMPLE  (hex "0080"))
(def 'GLUT_STEREO       (hex "0100"))
(def 'GLUT_LUMINANCE    (hex "0200"))

# Display Lists
(local) (glListBase glGenLists glCallList glCallLists glNewList glEndList
glDeleteLists)

(de glListBase (Base)
   (native `*GlutLib "glListBase" NIL Base) )

(de glGenLists (Range)
   (native `*GlutLib "glGenLists" 'N Range) )

(de glCallList (Lst)
   (native `*GlutLib "glCallList" NIL Lst) )

(de glCallLists (N Type Lists)
   (native `*GlutLib "glCallLists" NIL N Type Lists) )

(de glNewList (Lst Mode)
   (native `*GlutLib "glNewList" NIL Lst Mode) )

(de glEndList ()
   (native `*GlutLib "glEndList" NIL) )

(de glDeleteLists (Lst Range)
   (native `*GlutLib "glDeleteLists" NIL Lst Range) )

### Native functions ###

# Initialization functions
(local) (glutInit glutInitWindowPosition glutInitWindowSize glutInitDisplayMode)

(de glutInit ()
   (native `*GlutLib "glutInit" NIL '(NIL (8) . 0)) )

(de glutInitWindowPosition (Width Height)
   (native `*GlutLib "glutInitWindowPosition" NIL Width Height) )

(de glutInitWindowSize (Width Height)
   (native `*GlutLib "glutInitWindowSize" NIL Width Height) )

(de glutInitDisplayMode (N)
   (native `*GlutLib "glutInitDisplayMode" NIL N) )

# Process loop function
(local) glutMainLoop

(de glutMainLoop ()
   (native `*GlutLib "glutMainLoop") )

# Window management functions
(local) glutCreateWindow

(de glutCreateWindow (Name)
   (native `*GlutLib "glutCreateWindow" NIL Name) )

# Display-connected functions
(local) (glutPostRedisplay glutSwapBuffers)

(de glutPostRedisplay ()
   (native `*GlutLib "glutPostRedisplay") )

(de glutSwapBuffers ()
   (native `*GlutLib "glutSwapBuffers") )

# Mouse cursor functions

# Overlay stuff

# Menu stuff
(local) (createMenu glutAddMenuEntry glutAttachMenu)

(de createMenu (Fun)
   (native `*GlutLib "glutCreateMenu" NIL (lisp 'createMenu Fun)) )

(de glutAddMenuEntry (Name Val)
   (native `*GlutLib "glutAddMenuEntry" NIL Name Val) )

(de glutAttachMenu (Button)
   (native `*GlutLib "glutAttachMenu" NIL Button) )

# Global callback functions
(local) (timerFunc keyboardFunc specialFunc reshapeFunc displayPrg mouseFunc
motionFunc keyboardUp specialUp glutGetModifiers)

(de timerFunc (Msec Fun Val)
   (native `*GlutLib "glutTimerFunc" NIL Msec (lisp 'timerFunc Fun) Val) )

# Window-specific callback functions
(de keyboardFunc (Fun)
   (native `*GlutLib "glutKeyboardFunc" NIL (lisp 'keyboardFunc Fun)) )

(de specialFunc (Fun)
   (native `*GlutLib "glutSpecialFunc" NIL (lisp 'specialFunc Fun)) )

(de reshapeFunc (Fun)
   (native `*GlutLib "glutReshapeFunc" NIL (lisp 'reshapeFunc Fun)) )

(de displayPrg Prg
   (native `*GlutLib "glutDisplayFunc" NIL (lisp 'displayPrg (cons NIL Prg))) )

(de mouseFunc (Fun)
   (native `*GlutLib "glutMouseFunc" NIL (lisp 'mouseFunc Fun)) )

(de motionFunc (Fun)
   (native `*GlutLib "glutMotionFunc" NIL (lisp 'motionFunc Fun)) )

(de keyboardUp (Fun)
   (native `*GlutLib "glutKeyboardUpFunc" NIL (lisp 'keyboardUp Fun)) )

(de specialUp (Fun)
   (native `*GlutLib "glutSpecialUpFunc" NIL (lisp 'specialUp Fun)) )

# 1 shift, 2 ctrl, 4 alt
(de glutGetModifiers ()
   (native `*GlutLib "glutGetModifiers" 'I) )

# State setting and retrieval functions

# Font stuff

# Geometry functions
(local) (glutWireCube glutSolidCube glutWireSphere glutSolidSphere)

(de glutWireCube (Size)
   (set *Dbl1 Size)
   (native `*GlutLib "glutWireCube" NIL *Dbl1) )

(de glutSolidCube (Size)
   (set *Dbl1 Size)
   (native `*GlutLib "glutSolidCube" NIL *Dbl1) )

(de glutWireSphere (Radius Slices Stacks)
   (set *Dbl1 Radius)
   (native `*GlutLib "glutWireSphere" NIL *Dbl1 Slices Stacks) )

(de glutSolidSphere (Radius Slices Stacks)
   (set *Dbl1 Radius)
   (native `*GlutLib "glutSolidSphere" NIL *Dbl1 Slices Stacks) )

# Teapot rendering functions

# Game mode functions

# Video resize functions

# Colormap functions

# Misc keyboard and joystick functions

# Misc functions
(local) (glScalef glRasterPos2f glRasterPos2i)

(de glScalef (X Y Z)
   (set *Flt1 X *Flt2 Y *Flt3 Z) )

(de glRasterPos2f (X Y)
   (set *Flt1 X  *Flt2 Y)
   (native `*GlutLib "glRasterPos2f" NIL *Flt1 *Flt2) )

(de glRasterPos2i (X Y)
   (native `*GlutLib "glRasterPos2i" NIL X Y) )
