/* 17sep25 Software Lab. Alexander Burger
 * $ cc -o soTest soTest.c lib/picolisp.so lib/ext.so lib/ht.so
 */

#include <stdio.h>
#include <stdlib.h>

int picolisp(char*, int, int, char**);
char *evaluate(char*);
void reflect(void*, char*);
void stoplisp(void);

int main(int ac, char *av[]) {
   static char *init[] = {"picolisp", "lib.l"};
   char stack[1000000];
   char *line = NULL;
   size_t len = 0;
   char *res;

   if (!picolisp(stack, sizeof(stack), (int)(sizeof(init)/sizeof(char*)), init))
      return 1;
   while (--ac) {
      printf("-> %s\n", res = evaluate(*++av));
      free(res);
   }
   for (;;) {
      printf(": ");
      if (getline(&line, &len, stdin) < 0)
         break;
      printf("-> %s\n", res = evaluate(line));
      free(res);
   }
   putchar('\n');
   free(line);
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
