# 25jul20 Software Lab. Alexander Burger

.SILENT:

ASM = clang
MAIN = -rdynamic -lc -lm -ldl -lffi -lreadline
SHARED = -shared

BIN = ../bin
LIB = ../lib

INC = lib/llvm.l vers.l defs.l glob.l dec.l
SRC = main.l gc.l big.l sym.l io.l db.l apply.l flow.l subr.l

all: $(BIN)/picolisp $(LIB)/ext.so $(LIB)/const

# Base system
$(BIN)/picolisp: picolisp.bc
	mkdir -p $(BIN) $(LIB)
	llc picolisp.bc -relocation-model=pic -o picolisp.s
	$(ASM) picolisp.s -o $(BIN)/picolisp $(MAIN)

picolisp.bc: base.bc lib.bc
	llvm-link -o picolisp.bc base.bc lib.bc

base.bc: $(INC) $(SRC)
	../pil lib/llvm.l main.l -bye > base.ll
	llvm-as -o base.bc base.ll

lib.bc: pico.h lib.c
	clang -c -O3 `pkg-config --cflags libffi` -emit-llvm lib.c

# Extension library
$(LIB)/ext.so: ext.bc
	llc ext.bc -relocation-model=pic -o ext.s
	$(ASM) ext.s -o $(LIB)/ext.so $(SHARED)

ext.bc: $(INC) ext.l
	../pil lib/llvm.l ext.l -bye > ext.ll
	llvm-as -o ext.bc ext.ll

# System constants
$(LIB)/const: const.c
	clang const.c  &&  ./a.out > $(LIB)/const  &&  rm ./a.out

# Clean up
clean:
	rm -f *.ll *.bc *.s
