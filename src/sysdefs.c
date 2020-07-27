// 27jul20 Software Lab. Alexander Burger

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

static void ttl(char *nm) {
   printf("\n[%s]\n", nm);
}

static void num(char *sym, long val) {
   printf("%s\t%ld\n", sym, val);
}

static void str(char *sym, char *val) {
   printf("%s\t\"%s\"\n", sym, val);
}

int main(void) {
   struct sockaddr_in6 addr;
   struct addrinfo ai;

   printf("# %sSystem Definitions\n", __VERSION__);

   ttl("Networking");
   num("SOCK_STREAM", SOCK_STREAM);
   num("SOCK_DGRAM", SOCK_DGRAM);
   num("AF_INET6", AF_INET6);
   num("SOL_SOCKET", SOL_SOCKET);
   num("SO_REUSEADDR", SO_REUSEADDR);
   num("IPPROTO_IPV6", IPPROTO_IPV6);
   num("IPV6_V6ONLY", IPV6_V6ONLY);
   num("INET6_ADDRSTRLEN", INET6_ADDRSTRLEN);
   num("sockaddr_in6", sizeof(struct sockaddr_in6));
   num("sin6_family",  (char*)&addr.sin6_family - (char*)&addr);
   num("sin6_addr", (char*)&addr.sin6_addr - (char*)&addr);
   num("sin6_port", (char*)&addr.sin6_port - (char*)&addr);
   num("NI_MAXHOST", NI_MAXHOST);
   num("NI_NAMEREQD", NI_NAMEREQD);
   num("addrinfo", sizeof(struct addrinfo));
   num("ai_family", (char*)&ai.ai_family - (char*)&ai);
   num("ai_socktype", (char*)&ai.ai_socktype - (char*)&ai);

   return 0;
}