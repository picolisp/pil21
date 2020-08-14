# 14aug20 Software Lab. Alexander Burger

.SILENT:

CC = clang
ASM = llvm-as  # opt -O3
MAIN = -rdynamic -lc -lm -ldl -lffi -lreadline
SHARED = -shared
OS = $(shell uname)
CPU = $(shell uname -m)

BIN = ../bin
LIB = ../lib

INC = lib/llvm.l vers.l defs.l glob.l dec.l
SRC = main.l gc.l big.l sym.l io.l db.l apply.l flow.l subr.l

all: $(LIB)/sysdefs $(BIN)/picolisp $(LIB)/ext.so

# System definitions
$(LIB)/sysdefs: sysdefs.c
	$(CC) sysdefs.c  &&  ./a.out > $(LIB)/sysdefs  &&  rm ./a.out

# Base system
$(BIN)/picolisp: picolisp.bc
	mkdir -p $(BIN) $(LIB)
	llc picolisp.bc -relocation-model=pic -o picolisp.s
	$(CC) picolisp.s -o $(BIN)/picolisp $(MAIN)

picolisp.bc: base.bc lib.bc
	llvm-link -o picolisp.bc base.bc lib.bc

base.bc: base.ll
	$(ASM) -o base.bc base.ll

base.ll: $(INC) $(SRC)
	../pil lib/llvm.l main.l -bye > base.ll

lib.bc: pico.h lib.c
	$(CC) -c -O3 -D_OS='"$(OS)"' -D_CPU='"$(CPU)"' `pkg-config --cflags libffi` -emit-llvm lib.c

# Extension library
$(LIB)/ext.so: ext.bc
	llc ext.bc -relocation-model=pic -o ext.s
	$(CC) ext.s -o $(LIB)/ext.so $(SHARED)

ext.bc: ext.ll
	$(ASM) -o ext.bc ext.ll

ext.ll: $(INC) ext.l
	../pil lib/llvm.l ext.l -bye > ext.ll

# Clean up
clean:
	rm -f *.ll *.bc *.s
