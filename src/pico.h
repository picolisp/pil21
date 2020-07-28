// 28jul20 Software Lab. Alexander Burger

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
#include <readline/readline.h>
#include <readline/history.h>

typedef void (*sighandler_t)(int);

// Lisp data access
#define cnt(x) ((x) & 2)
#define big(x) ((x) & 4)
#define num(x) ((x) & 6)
#define sym(x) ((x) & 8)
#define atom(x) ((x) & 15)

#define car(x) (*(int64_t*)(x))
#define cdr(x) (*(int64_t*)((x) + 8))
#define set(p,x) (*(int64_t*)(p) = (x))
#define val(x) (*(int64_t*)(x))
#define dig(x) ((x) - 4)
#define tail(x) ((x) - 8)

int64_t name(int64_t);
int64_t number(int64_t);
int64_t length(int64_t);

extern int64_t SymTab[];
#define Nil (0+1)
// Sync src/glob.l 'T'
#define T (11*2+1)
#define N (12*2+1)
#define C (13*2+1)
#define S (14*2+1)
#define B (15*2+1)
#define I (16*2+1)
#define P (17*2+1)
#define W (18*2+1)

int32_t bufSize(int64_t);
char *bufString(int64_t, char*);
int64_t natBuf(int64_t, char*);
int64_t natRetBuf(int64_t, char**);
void err(int64_t, int64_t, char*, char*) __attribute__ ((noreturn));
