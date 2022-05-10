// 10may22 Software Lab. Alexander Burger

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <ctype.h>
#include <string.h>
#include <signal.h>
#include <time.h>
#include <pwd.h>
#include <sys/time.h>
#include <sys/stat.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/socket.h>

#include <openssl/pem.h>
#include <openssl/ssl.h>
#include <openssl/err.h>

typedef enum {NO,YES} bool;

typedef struct name {
   char *key, *ins;
   struct name *less, *more;
   int port;
   uid_t uid;
   gid_t gid;
   char *dir, *log, *ev[5], *av[1];
} name;

static bool Hup;
static name *Names;
static char *Config;
static int CliSock, SrvSock;
static char Ciphers[] = "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";

static char Head_302[] =
   "HTTP/1.0 302 Found\r\n"
   "Server: PicoLisp\r\n"
   "Location: %s\r\n"
   "\r\n";

static char Head_410[] =
   "HTTP/1.0 410 Gone\r\n"
   "Server: PicoLisp\r\n"
   "Content-Type: text/html; charset=utf-8\r\n"
   "\r\n";

static void giveup(char *msg) {
   fprintf(stderr, "httpGate: %s\n", msg);
   exit(1);
}

static int readNames(void) {
   FILE *fp;
   name *np, **t;
   int port, cnt;
   struct passwd *pw;
   char *p, *q, *ps, line[4096];
   static char delim[] = " \n";

   if (!(fp = fopen(Config, "r")))     // Lines ordered by
      giveup("Can't open name file");  // bin/balance -sort
   port = 8080;
   while (p = fgets(line, 4096, fp)) {
      while (*p == ' ')
         ++p;
      if (*p  &&  *p != '\n'  &&  *p != '#') {
         np = malloc(sizeof(name));
         np->less = np->more = NULL;
         p = strtok(p, delim);
         np->ins = NULL;
         if (q = strchr(p, '/')) {
            *q++ = '\0';
            np->ins = strdup(q);
         }
         np->key = strdup(p);
         if ((np->port = atoi(ps = strtok(NULL, delim))) == 0)
            np->dir = strdup(strtok(NULL, delim));
         else {
            if (!(pw = getpwnam(strtok(NULL, delim))) || pw->pw_uid == 0 || pw->pw_gid == 0) {
               free(np->key);
               free(np);
               continue;
            }
            np->uid = pw->pw_uid;
            np->gid = pw->pw_gid;
            p = np->ev[0] = malloc(5 + strlen(np->key) + 1);
            strcpy(p, "NAME="), strcpy(p+5, np->key);
            p = np->ev[1] = malloc(5 + strlen(pw->pw_dir) + 1);
            strcpy(p, "HOME="), strcpy(p+5, pw->pw_dir);
            p = np->ev[2] = malloc(5 + strlen(ps) + 1);
            strcpy(p, "PORT="), strcpy(p+5, ps);
            p = np->ev[3] = malloc(5 + strlen(q = getenv("LANG")) + 1);
            strcpy(p, "LANG="), strcpy(p+5, q);
            np->ev[4] = NULL;
            np->dir = strdup(strtok(NULL, delim));
            np->log = *(p = strtok(NULL, delim)) == '^'? NULL : strdup(p);
            cnt = 0;
            while (p = strtok(NULL, delim)) {
               if (*p == '^')
                  np->av[cnt] = strdup("");
               else {
                  p = np->av[cnt] = strdup(p);
                  while (p = strchr(p, '^'))
                     *p++ = ' ';
               }
               np = realloc(np, sizeof(name) + ++cnt * sizeof(char*));
            }
            np->av[cnt] = NULL;
         }
         p = np->key;
         if (!Names  ||  p[0] == '@' && p[1] == '\0')
            port = np->port;
         for (t = &Names;  *t;  t = strcasecmp(p, (*t)->key) >= 0? &(*t)->more : &(*t)->less);
         *t = np;
      }
   }
   fclose(fp);
   return port;
}

static void freeNames(name *np) {
   int i;

   free(np->key);
   if (np->less)
      freeNames(np->less);
   if (np->more)
      freeNames(np->more);
   free(np->dir);
   if (np->port) {
      free(np->log);
      for (i = 0; i < 4; ++i)
         free(np->ev[i]);
      for (i = 0; np->av[i]; ++i)
         free(np->av[i]);
   }
   free(np);
}

static name *findName(char *p, char *q) {
   name *np;
   int n, c;

   if (p == q) {
      if (Names && !Names->more && !Names->less)
         return Names;
      p = "@";
   }
   c = *q,  *q = '\0';
   for (np = Names;  np;  np = n > 0? np->more : np->less)
      if ((n = strcasecmp(p, np->key)) == 0) {
         *q = c;
         return np;
      }
   *q = c;
   return NULL;
}

static inline bool pre(char *p, char *s) {
   while (*s)
      if (*p++ != *s++)
         return NO;
   return YES;
}

static int slow(SSL *ssl, int fd, char *p, int cnt) {
   int n;

   while ((n = ssl? SSL_read(ssl, p, cnt) : read(fd, p, cnt)) < 0)
      if (errno != EINTR)
         return 0;
   return n;
}

static int rdLine(SSL *ssl, int fd, char *p, int cnt) {
   int n, len;

   for (len = 0;;) {
      if ((n = ssl? SSL_read(ssl, p, cnt) : read(fd, p, cnt)) <= 0) {
         if (!n || errno != EINTR)
            return 0;
      }
      else {
         len += n;
         if (memchr(p, '\n', n))
            return len;
         p += n;
         if ((cnt -= n) == 0)
            return 0;
      }
   }
}

static void wrBytes(int fd, char *p, int cnt) {
   int n;

   do
      if ((n = write(fd, p, cnt)) >= 0)
         p += n, cnt -= n;
      else if (errno != EINTR)
         exit(1);
   while (cnt);
}

static void sslWrite(SSL *ssl, void *p, int cnt) {
   if (SSL_write(ssl, p, cnt) <= 0)
      exit(1);
}

static bool setDH(SSL_CTX *ctx) {
   EC_KEY *ecdh;

   if (!(ecdh = EC_KEY_new_by_curve_name(NID_X9_62_prime256v1)))
      return NO;
   if (!SSL_CTX_set_tmp_ecdh(ctx, ecdh))
      return NO;
   EC_KEY_free(ecdh);
   SSL_CTX_set_cipher_list(ctx, Ciphers);
   return YES;
}

static int gatePort(unsigned short port) {
   int sd, n;
   struct sockaddr_in6 addr;

   if ((sd = socket(AF_INET6, SOCK_STREAM, 0)) < 0)
      exit(1);
   n = 0;
#ifndef __OpenBSD__
   if (setsockopt(sd, IPPROTO_IPV6, IPV6_V6ONLY, &n, sizeof(n)) < 0)
      exit(1);
#endif
   memset(&addr, 0, sizeof(addr));
   addr.sin6_family = AF_INET6;
   addr.sin6_addr = in6addr_any;
   n = 1;
   if (setsockopt(sd, SOL_SOCKET, SO_REUSEADDR, &n, sizeof(n)) < 0)
      exit(1);
   addr.sin6_port = htons(port);
   if (bind(sd, (struct sockaddr*)&addr, sizeof(addr)) < 0)
      exit(1);
   if (listen(sd,5) < 0)
      exit(1);
   return sd;
}

static int gateConnect(int port, name *np) {
   int sd;
   struct sockaddr_in6 addr;

   if ((sd = socket(AF_INET6, SOCK_STREAM, 0)) < 0)
      exit(1);
   memset(&addr, 0, sizeof(addr));
   addr.sin6_family = AF_INET6;
   addr.sin6_addr = in6addr_loopback;
   addr.sin6_port = htons((unsigned short)port);
   if (connect(sd, (struct sockaddr*)&addr, sizeof(addr)) >= 0)
      return sd;
   if (np) {
      int fd;
      pid_t pid;

      if (np->log) {
         struct flock fl;
         char log[strlen(np->dir) + 1 + strlen(np->log) + 1];

         if (np->log[0] == '/')
            strcat(log, np->log);
         else
            sprintf(log, "%s/%s", np->dir, np->log);
         if ((fd = open(log, O_RDWR)) >= 0) {
            fl.l_type = F_WRLCK;
            fl.l_whence = SEEK_SET;
            fl.l_start = 0;
            fl.l_len = 0;
            if (fcntl(fd, F_SETLK, &fl) < 0) {
               if (errno != EACCES  &&  errno != EAGAIN  ||
                           fcntl(fd, F_SETLKW, &fl) < 0  ||
                           connect(sd, (struct sockaddr*)&addr, sizeof(addr)) < 0)
                  return -1;
               close(fd);
               return sd;
            }
         }
      }
      if ((pid = fork()) == 0) {
         if (setgid(np->gid) == 0 && setuid(np->uid) == 0 && chdir(np->dir) == 0) {
            setpgid(0,0);
            if (np->log)
               freopen(np->log, "a", stdout);
            dup2(STDOUT_FILENO, STDERR_FILENO);
            execve(np->av[0], np->av, np->ev);
            exit(1);
         }
      }
      if (pid > 0) {
         setpgid(pid,0);
         int i = 200;
         do {
            usleep(100000);  // 100 ms
            if (connect(sd, (struct sockaddr*)&addr, sizeof(addr)) >= 0) {
               if (np->log  &&  fd >= 0)
                  close(fd);
               return sd;
            }
         } while (--i);
      }
   }
   return -1;
}


static pid_t Buddy;

static void doSigAlarm(int n __attribute__((unused))) {
   kill(Buddy, SIGTERM);
   shutdown(CliSock, SHUT_RDWR);
   shutdown(SrvSock, SHUT_RDWR);
   exit(0);
}

static void doSigUsr1(int n __attribute__((unused))) {
   alarm(420);
}

static void doSigHup(int n __attribute__((unused))) {
   Hup = YES;
}

static void iSignal(int n, void (*foo)(int)) {
   struct sigaction act;

   act.sa_handler = foo;
   sigemptyset(&act.sa_mask);
   act.sa_flags = 0;
   sigaction(n, &act, NULL);
}

int main(int ac, char *av[]) {
   int cnt = ac>4? ac-3 : 1, ports[cnt], n, sd;
   struct sockaddr_in6 addr;
   char s[INET6_ADDRSTRLEN];
   char *p, *q, *gate;
   SSL_CTX *ctx;
   SSL *ssl;

   if (ac < 3)
      giveup("port dflt [pem [deny ..]]");
   sd = gatePort(atoi(av[1]));  // e.g. 80 or 443
   ports[0] = (int)strtol(p = av[2], &q, 10);  // e.g. 8080
   if (q == p  ||  *q != '\0')
      Config = p,  ports[0] = readNames();
   if (ac == 3 || *av[3] == '\0')
      ssl = NULL,  gate = "X-Pil: *Gate=http\r\nX-Pil: *Adr=%s\r\n";
   else {
      SSL_library_init();
      SSL_load_error_strings();
      if (p = strchr(av[3], ','))
         *p++ = '\0';
      else
         p = av[3];
      if (!(ctx = SSL_CTX_new(SSLv23_server_method())) ||
         !SSL_CTX_use_PrivateKey_file(ctx, av[3], SSL_FILETYPE_PEM) ||
            !SSL_CTX_use_certificate_chain_file(ctx, p) ||
               !SSL_CTX_check_private_key(ctx) || !setDH(ctx) ) {
         ERR_print_errors_fp(stderr);
         giveup("SSL init");
      }
      SSL_CTX_set_options(ctx,
         SSL_OP_NO_SSLv2 | SSL_OP_NO_SSLv3 | SSL_OP_NO_TLSv1 | SSL_OP_NO_TLSv1_1 |
         SSL_OP_ALL | SSL_OP_CIPHER_SERVER_PREFERENCE | SSL_OP_NO_COMPRESSION );
      ssl = SSL_new(ctx),  gate = "X-Pil: *Gate=https\r\nX-Pil: *Adr=%s\r\n";
   }
   for (n = 1; n < cnt; ++n)
      ports[n] = atoi(av[n+3]);
   signal(SIGCHLD, SIG_IGN);  /* Prevent zombies */
   if ((n = fork()) < 0)
      giveup("detach");
   if (n)
      return 0;
   setsid();
   if (Config)
      iSignal(SIGHUP, doSigHup);
   else
      signal(SIGHUP, SIG_IGN);
   for (;;) {
      if (Hup) {
         Hup = NO;
         freeNames(Names);
         Names = NULL;
         ports[0] = readNames();
      }
      socklen_t len = sizeof(addr);
      if ((CliSock = accept(sd, (struct sockaddr*)&addr, &len)) >= 0 && (n = fork()) >= 0) {
         if (!n) {
            name *np;
            int fd, port, i;
            char buf[4096], buf2[64];

            close(sd);

            alarm(420);
            if (ssl) {
               SSL_set_fd(ssl, CliSock);
               if (SSL_accept(ssl) < 0)
                  return 1;
            }
            n = rdLine(ssl, CliSock, buf, sizeof(buf));
            alarm(0);
            if (n < 6)
               return 1;

            /* "GET /url HTTP/1.x"
             * "GET /8080/url HTTP/1.x"
             * "POST /url HTTP/1.x"
             * "POST /8080/url HTTP/1.x"
             */
            if (pre(buf, "GET /"))
               p = buf + 5;
            else if (pre(buf, "POST /"))
               p = buf + 6;
            else if (pre(buf, "PUT /"))
               p = buf + 5;
            else if (pre(buf, "PATCH /"))
               p = buf + 7;
            else if (pre(buf, "DELETE /"))
               p = buf + 8;
            else
               return 1;

            np = NULL;
            port = (int)strtol(p, &q, 10);
            if (q == p  ||  *q != ' ' && *q != '/' && *q != '?') {
               if ((q = strpbrk(p, " /?")) && (np = findName(p, q)))
                  port = np->port;
               else
                  q = p,  port = (np = findName(p, q))? np->port : ports[0];  // "@"?
            }
            else if (port < 1024) {
               if (np = findName(p, q))
                  port = np->port;
               else
                  return 1;
            }
            else
               for (i = 1; i < cnt; ++i)
                  if (port == ports[i])
                     return 1;

            if (np && port == 0) {
               i = sprintf(buf, Head_302, np->dir);
               if (ssl)
                  sslWrite(ssl, buf, i);
               else
                  wrBytes(CliSock, buf, i);
               return 0;
            }
            if ((SrvSock = gateConnect(port, np)) < 0) {
               if (!memchr(q,'~', buf + n - q))
                  return 1;
               if ((fd = open("void", O_RDONLY)) < 0)
                  return 1;
               alarm(420);
               if (ssl)
                  sslWrite(ssl, Head_410, strlen(Head_410));
               else
                  wrBytes(CliSock, Head_410, strlen(Head_410));
               alarm(0);
               while ((n = read(fd, buf, sizeof(buf))) > 0) {
                  alarm(420);
                  if (ssl)
                     sslWrite(ssl, buf, n);
                  else
                     wrBytes(CliSock, buf, n);
                  alarm(0);
               }
               return 0;
            }

            wrBytes(SrvSock, buf, p - buf);
            if (np  &&  (p = np->ins))
               wrBytes(SrvSock, p, strlen(p));
            else if (*q == '/')
               ++q;
            p = q;
            while (*p++ != '\n')
               if (p >= buf + n)
                  return 1;
            wrBytes(SrvSock, q, p - q);
            inet_ntop(AF_INET6, &addr.sin6_addr, s, INET6_ADDRSTRLEN);
            wrBytes(SrvSock, buf2, sprintf(buf2, gate, s));
            if (ssl)
               wrBytes(SrvSock, buf2, sprintf(buf2, "X-Pil: *Cipher=%s\r\n", SSL_get_cipher(ssl)));
            wrBytes(SrvSock, p, buf + n - p);

            iSignal(SIGALRM, doSigAlarm);
            iSignal(SIGUSR1, doSigUsr1);
            if (Buddy = fork()) {
               for (;;) {
                  alarm(420);
                  n = slow(ssl, CliSock, buf, sizeof(buf));
                  alarm(0);
                  if (!n)
                     break;
                  wrBytes(SrvSock, buf, n);
               }
               shutdown(CliSock, SHUT_RD);
               shutdown(SrvSock, SHUT_WR);
            }
            else {
               Buddy = getppid();
               while ((n = read(SrvSock, buf, sizeof(buf))) > 0) {
                  kill(Buddy, SIGUSR1);
                  alarm(420);
                  if (ssl)
                     sslWrite(ssl, buf, n);
                  else
                     wrBytes(CliSock, buf, n);
                  alarm(0);
               }
               shutdown(SrvSock, SHUT_RD);
               shutdown(CliSock, SHUT_WR);
            }
            return 0;
         }
         close(CliSock);
      }
   }
}
