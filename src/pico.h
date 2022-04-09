// 09apr22 Software Lab. Alexander Burger

#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <limits.h>
#include <stdio.h>
#include <errno.h>
#include <fcntl.h>
#include <poll.h>
#include <math.h>
#include <signal.h>
#include <setjmp.h>
#include <dirent.h>
#include <termios.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/time.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <sys/resource.h>

typedef void (*sighandler_t)(int);

// Lisp data access
typedef uint64_t any;

#define cnt(x) ((x) & 2)
#define num(x) ((x) & 6)
#define sym(x) ((x) & 8)
#define sign(x) ((x) & 8)
#define atom(x) ((x) & 15)

#define car(x) (*(uint64_t*)(x))
#define cdr(x) (*(uint64_t*)((x) + 8))
#define set(p,x) (*(uint64_t*)(p) = (x))
#define val(x) (*(uint64_t*)(x))
#define dig(x) ((x) - 4)
#define big(x) ((x) + 4)
#define tail(x) ((x) - 8)

any name(any);
any number(any);
any length(any);
any box64(any);

extern uint64_t SymTab[];
#define Nil (0+1)
// Sync src/glob.l 'T'
#define T (17*2+1)
#define N (18*2+1)
#define C (19*2+1)
#define S (20*2+1)
#define B (21*2+1)
#define I (22*2+1)
#define P (23*2+1)
#define W (24*2+1)

uint64_t boxNum(uint64_t);
int32_t bufSize(uint64_t);
char *bufString(uint64_t, char*);
uint64_t natBuf(uint64_t, char*);
uint64_t natRetBuf(uint64_t, char**);

void argErr(uint64_t, uint64_t) __attribute__ ((noreturn));
void err(uint64_t, uint64_t, char*, char*) __attribute__ ((noreturn));
