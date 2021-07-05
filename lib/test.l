# 04jul21 Software Lab. Alexander Burger

### Unit Tests ###
# Local usage:
# ./pil lib/test.l -bye +

# Global usage:
# pil @lib/test.l -bye +

(unless *Dbg
   (quit "Needs debug mode '+'") )

(setq
   *CMD (cmd)
   *PWD (in '(pwd) (line T)) )

(load
   "@test/src/main.l"
   "@test/src/apply.l"
   "@test/src/flow.l"
   "@test/src/sym.l"
   "@test/src/subr.l"
   "@test/src/big.l"
   "@test/src/io.l"
   "@test/src/db.l"
   "@test/src/net.l"
   "@test/src/ext.l"
   "@test/src/ht.l" )

(load "@test/lib.l")
(load "@test/lib/db.l")
(load "@test/lib/misc.l")

(load "@test/lib/lint.l")

(load "@test/lib/math.l")

(msg 'OK)
