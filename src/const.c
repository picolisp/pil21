// 26jul20 Software Lab. Alexander Burger

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <limits.h>
#include <errno.h>
#include <fcntl.h>
#include <dirent.h>
#include <signal.h>
#include <dlfcn.h>
#include <time.h>
#include <poll.h>
#include <termios.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/times.h>
#include <sys/resource.h>
#include <netdb.h>
#include <sys/socket.h>
#include <netinet/in.h>

static void num(char *sym, long val) {
   printf("%s\t%ld\n", sym, val);
}

static void str(char *sym, char *val) {
   printf("%s\t\"%s\"\n", sym, val);
}

int main(void) {
   struct sockaddr_in6 addr;

   printf("%sSystem Constants\n", __VERSION__);
   // Networking
   num("SOCK_STREAM", SOCK_STREAM);
   num("SOCK_DGRAM", SOCK_DGRAM);
   num("AF_INET6", AF_INET6);
   num("IPPROTO_IPV6", IPPROTO_IPV6);
   num("IPV6_V6ONLY", IPV6_V6ONLY);
   num("sockaddr_in6", sizeof(struct sockaddr_in6));
   num("sin6_family",  (char*)&addr.sin6_family - (char*)&addr);
   num("sin6_addr", (char*)&addr.sin6_addr - (char*)&addr);
   num("sin6_port", (char*)&addr.sin6_port - (char*)&addr);
   return 0;
}
