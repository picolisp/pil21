// 24apr22 Software Lab. Alexander Burger

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
#include <sys/ioctl.h>
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
   struct winsize term;
   struct sockaddr_in6 addr;
   struct addrinfo ai;

   printf("# %s\n", __VERSION__);
   printf("# %s\n", _OS);
   printf("# %s\n", _CPU);

   ttl("errno");
   num("EINTR", EINTR);
   num("EAGAIN", EAGAIN);
   num("EACCES", EACCES);

   ttl("stdio");
   num("BUFSIZ", BUFSIZ);

   ttl("unistd");
   num("PIPE_BUF", PIPE_BUF);
   num("PATH_MAX", PATH_MAX);

   ttl("terminal");
   num("TIOCGWINSZ", TIOCGWINSZ);
   num("TIOCSWINSZ", TIOCSWINSZ);
   num("winsize", sizeof(struct winsize));
   num("ws_row", (char*)&term.ws_row - (char*)&term);
   num("ws_col", (char*)&term.ws_col - (char*)&term);

   ttl("networking");
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
   num("socklen_t", sizeof(socklen_t));
   num("ai_addrlen", (char*)&ai.ai_addrlen - (char*)&ai);
   num("ai_addr", (char*)&ai.ai_addr - (char*)&ai);
   num("ai_next", (char*)&ai.ai_next - (char*)&ai);
   num("AF_UNSPEC", AF_UNSPEC);

   return 0;
}
