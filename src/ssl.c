// 14apr21 Software Lab. Alexander Burger

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <dirent.h>
#include <errno.h>
#include <string.h>
#include <signal.h>
#include <sys/stat.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/socket.h>

#include <openssl/pem.h>
#include <openssl/ssl.h>
#include <openssl/err.h>
#include <openssl/x509v3.h>

typedef enum {NO,YES} bool;

static bool Safe, Hold, Done;

static char Node[40];  // 0000:0000:0000:0000:0000:0000:0000:0000

static char Ciphers[] = "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";

static char Get[] =
   "GET /%s HTTP/1.0\r\n"
   "User-Agent: PicoLisp\r\n"
   "Host: %s:%s\r\n"
   "Accept-Charset: utf-8\r\n\r\n";

static void giveup(char *msg) {
   fprintf(stderr, "ssl: %s", msg);
   putc('\n',stderr);
   exit(1);
}

static int sslConnect(SSL *ssl, char *node, char *service) {
   struct addrinfo hints, *lst, *p;
   int n, fd, sd;
   char *q;

   if (strchr(node, '/')  &&  (fd = open(node, O_RDONLY)) >= 0) {
      if ((n = read(fd, Node, sizeof(Node))) > 0) {
         if ((q = strchr(Node, '\n')) && q < Node+n)
            *q = '\0';
         node = Node;
      }
      close(fd);
   }
   memset(&hints, 0, sizeof(hints));
   hints.ai_family = AF_UNSPEC;
   hints.ai_socktype = SOCK_STREAM;
   if (getaddrinfo(node, service, &hints, &lst) == 0) {
      for (p = lst; p; p = p->ai_next) {
         if ((sd = socket(p->ai_family, p->ai_socktype, 0)) >= 0) {
            if (connect(sd, p->ai_addr, p->ai_addrlen) == 0) {
               SSL_set_fd(ssl, sd);
               if (SSL_connect(ssl) == 1) {
                  X509 *cert;

                  freeaddrinfo(lst);
                  if (Safe)
                     return sd;
                  if (cert = SSL_get_peer_certificate(ssl)) {
                     X509_free(cert);
                     if (SSL_get_verify_result(ssl) == X509_V_OK)
                        return sd;
                  }
                  return -1;
               }
            }
            close(sd);
         }
      }
      freeaddrinfo(lst);
   }
   return -1;
}

static void sslClose(SSL *ssl, int sd) {
   SSL_shutdown(ssl);
   SSL_clear(ssl);
   close(sd);
}

static bool sslFile(SSL *ssl, char *file) {
   int fd, n;
   char buf[BUFSIZ];

   if (file[0] == '-') {
      if (file[1] != '\0')
         return SSL_write(ssl, file+1, strlen(file)-1) >= 0;
      fd = STDIN_FILENO;
   }
   else if ((fd = open(file, O_RDONLY)) < 0)
      return NO;
   while ((n = read(fd, buf, sizeof(buf))) > 0)
      if (SSL_write(ssl, buf, n) < 0) {
         close(fd);
         return NO;
      }
   close(fd);
   return n == 0;
}

static off_t lockFile(int fd) {
   struct flock fl;
   struct stat st;

   fl.l_type = F_WRLCK;
   fl.l_whence = SEEK_SET;
   fl.l_start = 0;
   fl.l_len = 0;
   if (fcntl(fd, F_SETLKW, &fl) < 0)
      giveup("Can't lock");
   if (fstat(fd, &st) < 0)
      giveup("Can't access");
   if (st.st_size == 0)
      giveup("Size error");
   return st.st_size;
}

static void doSigTerm(int n __attribute__((unused))) {
   if (Hold)
      Done = YES;
   else
      exit(0);
}

static void iSigTerm(int n) {
   struct sigaction act;

   act.sa_handler = doSigTerm;
   sigemptyset(&act.sa_mask);
   act.sa_flags = 0;
   sigaction(n, &act, NULL);
}

// ssl host port [url key file]
// ssl host port url key file dir sec [min] [dir ..]
int main(int ac, char *av[]) {
   bool dbg;
   SSL_CTX *ctx;
   SSL *ssl;
   int i, n, sec, lim, getLen, lenLen, fd, sd;
   char *file, *dir, *data;
   DIR *dp;
   struct dirent *p;
   struct stat st;
   off_t size, size2;
   char get[1024], buf[4096], nm[4096], len[64];

   if (dbg = strcmp(av[ac-1], "+") == 0)
      --ac;
   if (!(ac >= 3 && ac <= 6  ||  ac >= 8))
      giveup("host port [url key file] | host port url key file dir sec [min] [dir ..]");
   if (*av[2] == '-')
      ++av[2],  Safe = YES;
   if (ac <= 3  ||  *av[3] == '\0')
      getLen = 0;
   else {
      if (strlen(Get)+strlen(av[1])+strlen(av[2])+strlen(av[3]) >= sizeof(get))
         giveup("Names too long");
      getLen = sprintf(get, Get, av[3], av[1], av[2]);
   }

   SSL_library_init();
   SSL_load_error_strings();
   if (!(ctx = SSL_CTX_new(SSLv23_client_method())) || !SSL_CTX_set_default_verify_paths(ctx)) {
      ERR_print_errors_fp(stderr);
      giveup("SSL init");
   }
   SSL_CTX_set_options(ctx,
      SSL_OP_NO_SSLv2 | SSL_OP_NO_SSLv3 | SSL_OP_NO_TLSv1 |
      SSL_OP_NO_TLSv1_1 | SSL_OP_ALL | SSL_OP_NO_COMPRESSION );
   SSL_CTX_set_cipher_list(ctx, Ciphers);
   ssl = SSL_new(ctx);
   SSL_set_tlsext_host_name(ssl, av[1]);
   if (!Safe) {
      X509_VERIFY_PARAM *par = SSL_get0_param(ssl);
      X509_VERIFY_PARAM_set_hostflags(par, X509_CHECK_FLAG_NO_PARTIAL_WILDCARDS);
      X509_VERIFY_PARAM_set1_host(par, av[1], 0);
      SSL_set_verify(ssl, SSL_VERIFY_PEER, NULL);
   }

   signal(SIGCHLD,SIG_IGN);  /* Prevent zombies */
   signal(SIGPIPE, SIG_IGN);
   if (ac <= 6) {
      if (sslConnect(ssl, av[1], av[2]) < 0) {
         ERR_print_errors_fp(stderr);
         giveup("Can't connect");
      }
      if (getLen  &&  SSL_write(ssl, get, getLen) < 0) {
         ERR_print_errors_fp(stderr);
         giveup("SSL GET");
      }
      if (ac > 4) {
         if (*av[4]  &&  !sslFile(ssl,av[4]))
            giveup("Can't send");
         if (ac > 5  &&  *av[5]  &&  !sslFile(ssl,av[5]))
            giveup("Can't send");
      }
      if (!getLen  &&  !fork()) {
         while ((n = read(STDIN_FILENO, buf, sizeof(buf))) > 0)
            SSL_write(ssl, buf, n);
         return 0;
      }
      while ((n = SSL_read(ssl, buf, sizeof(buf))) > 0)
         write(STDOUT_FILENO, buf, n);
      if (dbg)
         ERR_print_errors_fp(stderr);
      return 0;
   }
   if (!dbg) {
      if ((n = fork()) < 0)
         giveup("Can't detach");
      if (n)
         return 0;
      setsid();
   }
   file = av[5];
   dir = av[6];
   sec = atoi(av[7]);
   iSigTerm(SIGINT);
   iSigTerm(SIGTERM);
   lim = 0;
   if (ac >= 9 && *av[8]) {
      if ((lim = atoi(av[8])) == 0) {
         printf("%d\n", getpid());
         fflush(stdout);
      }
      else {
         iSigTerm(SIGALRM);
         alarm(lim *= 60);
      }
   }
   for (;;) {
      if (*file && (fd = open(file, O_RDWR)) >= 0) {
         if (fstat(fd,&st) < 0  ||  st.st_size == 0)
            close(fd);
         else {
            lenLen = sprintf(len, "%ld\n", size = lockFile(fd));
            if ((data = malloc(size)) == NULL)
               giveup("Can't alloc");
            if (read(fd, data, size) != size)
               giveup("Can't read");
            close(fd);
            alarm(0);
            for (nm[0] = '\0', i = 9;  i < ac;  ++i) {
               if (dp = opendir(av[i])) {
                  int max = -1;
                  char *q;

                  while (p = readdir(dp))
                     if ((n = (int)strtol(p->d_name, &q, 10)) > max  &&  !*q)
                        max = n;
                  if (max >= 0) {
                     if (nm[0]) {
                        snprintf(buf, sizeof(buf), "%s/%d", av[i], max + 1);
                        link(nm, buf);
                     }
                     else {
                        snprintf(nm, sizeof(nm), "%s/%d", av[i], max + 1);
                        if ((fd = open(nm, O_CREAT|O_EXCL|O_WRONLY, 0666)) < 0)
                           nm[0] = '\0';
                        else {
                           write(fd, data, size);
                           close(fd);
                        }
                     }
                  }
                  closedir(dp);
               }
            }
            if (!*av[4])
               goto truncate;
            for (;;) {
               if ((sd = sslConnect(ssl, av[1], av[2])) >= 0) {
                  if (SSL_write(ssl, get, getLen) == getLen  &&
                        sslFile(ssl,av[4])  &&                    // key
                        SSL_write(ssl, len, lenLen) == lenLen  && // length
                        SSL_write(ssl, data, size) == size  &&    // data
                        SSL_write(ssl, "T", 1) == 1  &&           // ack
                        SSL_read(ssl, buf, 1) == 1  &&  buf[0] == 'T' ) {
                     sslClose(ssl,sd);
                  truncate:
                     if ((fd = open(file, O_RDWR)) < 0)
                        giveup("Can't re-open");
                     if (size2 = lockFile(fd) - size) {
                        if ((data = realloc(data, size2)) == NULL)
                           giveup("Can't re-alloc");
                        if (pread(fd, data, size2, size) != size2)
                           giveup("Can't re-read");
                        Hold = YES;
                        if (pwrite(fd, data, size2, 0) != size2)
                           giveup("Can't re-write");
                     }
                     if (ftruncate(fd, size2) < 0)
                        giveup("Can't truncate");
                     close(fd);
                     Hold = NO;
                     if (Done)
                        exit(0);
                     break;
                  }
                  sslClose(ssl,sd);
               }
               if (dbg)
                  ERR_print_errors_fp(stderr);
               sleep(sec);
            }
            alarm(lim);
            free(data);
         }
      }
      if (*av[4] && *dir && (dp = opendir(dir))) {
         while (p = readdir(dp)) {
            if (p->d_name[0] == '=') {
               snprintf(nm, sizeof(nm), "%s%s", dir, p->d_name);
               if ((n = readlink(nm, buf, sizeof(buf))) > 0  &&  stat(nm, &st) >= 0) {
                  lenLen = sprintf(len, "%ld\n", st.st_size);
                  buf[n++] = '\n';
                  alarm(lim);
                  if ((sd = sslConnect(ssl, av[1], av[2])) >= 0) {
                     if (SSL_write(ssl, get, getLen) == getLen  &&
                           sslFile(ssl,av[4])  &&                    // key
                           SSL_write(ssl, buf, n) == n  &&           // path
                           SSL_write(ssl, len, lenLen) == lenLen  && // length
                           sslFile(ssl, nm)  &&                      // file
                           SSL_write(ssl, "T", 1) == 1  &&           // ack
                           SSL_read(ssl, buf, 1) == 1  &&  buf[0] == 'T' )
                        unlink(nm);
                     sslClose(ssl,sd);
                  }
                  if (dbg)
                     ERR_print_errors_fp(stderr);
               }
            }
         }
         closedir(dp);
      }
      sleep(sec);
   }
}
