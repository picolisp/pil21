# 21nov20 Software Lab. Alexander Burger

.SILENT:

CC = clang
ASM = opt -O3  # llvm-as
MAIN = -rdynamic -lc -lm -ldl -lreadline -lffi
SHARED = -shared
OS = $(shell uname)
CPU = $(shell uname -m)

BIN = ../bin
LIB = ../lib

INC = lib/llvm.l vers.l defs.l glob.l dec.l
SRC = main.l gc.l big.l sym.l io.l db.l apply.l flow.l subr.l

all: $(LIB)/sysdefs $(BIN)/picolisp $(LIB)/ext.so $(LIB)/ht.so $(BIN)/balance $(BIN)/ssl $(BIN)/httpGate

# System definitions
$(LIB)/sysdefs: sysdefs.c
	$(CC) -w -D_OS='"$(OS)"' -D_CPU='"$(CPU)"' sysdefs.c  &&  ./a.out > $(LIB)/sysdefs  &&  rm ./a.out

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
	mv base.map $(LIB)/map

lib.bc: pico.h lib.c
	$(CC) -O3 -w -c -D_OS='"$(OS)"' -D_CPU='"$(CPU)"' `pkg-config --cflags libffi` -emit-llvm lib.c

# Extension libraries
$(LIB)/ext.so: ext.bc
	llc ext.bc -relocation-model=pic -o ext.s
	$(CC) ext.s -o $(LIB)/ext.so $(SHARED)

ext.bc: ext.ll
	$(ASM) -o ext.bc ext.ll

ext.ll: $(INC) ext.l
	../pil lib/llvm.l ext.l -bye > ext.ll

$(LIB)/ht.so: ht.bc
	llc ht.bc -relocation-model=pic -o ht.s
	$(CC) ht.s -o $(LIB)/ht.so $(SHARED)

ht.bc: ht.ll
	$(ASM) -o ht.bc ht.ll

ht.ll: $(INC) ht.l
	../pil lib/llvm.l ht.l -bye > ht.ll

# Tools
$(BIN)/balance: balance.c
	$(CC) -O3 -w -o $(BIN)/balance balance.c

# Gate
$(BIN)/ssl: ssl.c
	$(CC) -O3 -w -o $(BIN)/ssl ssl.c -lssl -lcrypto

$(BIN)/httpGate: httpGate.c
	$(CC) -O3 -w -o $(BIN)/httpGate httpGate.c -lssl -lcrypto

# Clean up
clean:
	rm -f *.ll *.bc *.s
