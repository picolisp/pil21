/* 02sep25 Software Lab. Alexander Burger
 * $ cc -o soTest soTest.c lib/picolisp.so
 */

#include <stdio.h>
#include <stdlib.h>

void picolisp(char*, int, int, char**);
char *evaluate(char*);
void stoplisp(void);

int main(int ac, char *av[]) {
   static char *init[] = {"picolisp", "lib.l"};
   char stack[1000000];

   picolisp(stack, sizeof(stack), (int)(sizeof(init)/sizeof(char*)), init);
   while (--ac) {
      char *res = evaluate(*++av);

      printf("-> %s\n", res);
      free(res);
   }
   stoplisp();
   return 0;
}

#if 0

$ ./soTest "(* 3 4)" *Pid *Dbg
-> 12
-> 16943
-> T

# Starting 2 corouines 'a' and 'b'
$ ./soTest "(co 'a (loop (yield (inc (0)))))" "(co 'a T)" "(co 'b (loop (yield (inc (0)))))" "(co 'a T)" "(co 'b T)"
-> 1
-> 2
-> 1
-> 3
-> 2

#endif
