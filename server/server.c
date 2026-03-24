#include <stdio.h>
#include <sys/socket.h>
#include <syslog.h>
#include <stdlib.h>
#include <netinet/in.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <string.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <signal.h>

#define PORT_NUMBER  9000
#define IN_DATA_FILE "/var/tmp/aesdsocketdata"

int sockfd = -1, newsockfd = -1;
int fd_content_file = -1;

void error(const char *msg)
{
  perror(msg);
  openlog("aesdsocket", LOG_PID, LOG_USER);
  syslog(LOG_ERR, "%s", msg);
  closelog();
  exit(1);
}

void handler(int num)
{
  openlog("aesdsocket", LOG_PID, LOG_USER);
  syslog(LOG_INFO, "Caught signal, exiting");
  closelog();
  // 1. Fermer le socket
  if(sockfd != -1)
  {
    close(sockfd);
    sockfd = -1;
  }
  if(newsockfd != -1)
  {
    close(newsockfd);
    newsockfd = -1;
  }
  // 2. Supprimer le fichier
  if(fd_content_file != -1)
  {
    close(fd_content_file);
    fd_content_file = -1;
  }
  int remove_return = remove(IN_DATA_FILE);
  if (remove_return)
  {
    openlog("aesdsocket", LOG_PID, LOG_USER);
    syslog(LOG_ERR, "Removing %s error with errno: %d", "IN_DATA_FILE", remove_return);
    closelog();
  }
  else
  {
    openlog("aesdsocket", LOG_PID, LOG_USER);
    syslog(LOG_ERR, "File %s erased correctly", IN_DATA_FILE);
    closelog();
  }
  // 3. Quitter
  exit(0);
}

int main(int argc, char **argv)
{
  struct sockaddr_in6 serv_addr, cli_addr;
  socklen_t          clilen;
  char               host[NI_MAXHOST]; // Pour stocker l'IP
  char               serv[NI_MAXSERV]; // Pour stocker le port (service)
  char* message_allocation;
  signal (SIGINT, handler);
  signal (SIGTERM, handler);
  
  if(argc > 2)
  {
    error("Amount of arguments passed must be either 1 or 0.");
  }
  else
  {
    if (argc == 2 && strcmp(argv[1], "-d") != 0)
    {
      openlog("aesdsocket", LOG_PID, LOG_USER);
      syslog(LOG_INFO, "Only the '-d' is allowed. Parameter passed ignored");
      closelog();
    }
    sockfd = socket(AF_INET6, SOCK_STREAM, 0);
    if ( sockfd < 0)
    {
      error("Error opening socket.");
    }
    else
    {
      if (setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &(int){1}, sizeof(int)) < 0)
        error("setsockopt(SO_REUSEADDR) failed");
    }
  
    memset(&serv_addr, 0, sizeof(serv_addr));
    serv_addr.sin6_family     = AF_INET6;
    serv_addr.sin6_addr = in6addr_any;
    serv_addr.sin6_port       = htons((uint16_t) PORT_NUMBER);
  
    if(bind(sockfd, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0)
    {
      error("Binding failure");
    }

    if (argc == 2 && strcmp(argv[1], "-d") == 0)
    {
      int fork_id = fork();
      if (fork_id != 0)
      {
        openlog("aesdsocket", LOG_PID, LOG_USER);
        syslog(LOG_INFO, "Killing parent process. Daemon continues");
        closelog();
        exit(0);
      }
      setsid();
    }
    
    listen(sockfd, 5);
    openlog("aesdsocket", LOG_PID, LOG_USER);
    syslog(LOG_INFO, "Listen succes");
    closelog();
    while(1)
    {
      int IP_info_result;
      clilen = sizeof(cli_addr);
      newsockfd = accept(sockfd, (struct sockaddr *) &cli_addr, &clilen);
      if (newsockfd < 0)
      {
        error("Accepting connection error");
      }
        
      IP_info_result = getnameinfo((struct sockaddr *)&cli_addr, clilen,
                                        host, sizeof(host),
                                        serv, sizeof(serv),
                                        NI_NUMERICHOST | NI_NUMERICSERV);
    
      if (IP_info_result == 0)
      {
        openlog("aesdsocket", LOG_PID, LOG_USER);
        syslog(LOG_INFO, "Client connecté : IP = %s, Port = %s\n", host, serv);
        closelog();
      } else
      {
        openlog("aesdsocket", LOG_PID, LOG_USER);
        syslog(LOG_INFO, "Erreur getnameinfo : %s\n", ((const char *)(gai_strerror(IP_info_result))));
        closelog();
      }
    
      openlog("aesdsocket", LOG_PID, LOG_USER);
      syslog(LOG_INFO, "Accepted connection from %s", host);
      closelog();
      
      fd_content_file = open(IN_DATA_FILE, O_RDWR | O_CREAT | O_APPEND, 0644);
      if(fd_content_file < 0)
      {
        error("Opening file error");
      }
      message_allocation = calloc(sizeof(char), 1024);
      if (message_allocation)
      {
        int read_return;
        openlog("aesdsocket", LOG_PID, LOG_USER);
        syslog(LOG_INFO, "Memory allocated");
        closelog();
          
        while((read_return = read(newsockfd, message_allocation, 1024)) > 0)
        { 
          openlog("aesdsocket", LOG_PID, LOG_USER);
          syslog(LOG_INFO, "There is content to read from newsockfd");
          closelog();
          char* memch_return;
          if ((memch_return = memchr(message_allocation, '\n', read_return)))
          {
            int distance = (memch_return - message_allocation) + 1;
            openlog("aesdsocket", LOG_PID, LOG_USER);
            syslog(LOG_INFO, "new line found");
            syslog(LOG_INFO, "distance %d", distance);
            closelog();
            int write_return = write(fd_content_file, message_allocation, distance);
            openlog("aesdsocket", LOG_PID, LOG_USER);
            syslog(LOG_INFO, "write_return: %d", write_return);
            closelog();
            free(message_allocation);
            message_allocation = NULL;
            //Send the file content
            struct stat st;
            if (fstat(fd_content_file, &st) == -1)
            {
              error("Stats error");
            }
            long taille_fichier = lseek(fd_content_file, 0, SEEK_END);
            openlog("aesdsocket", LOG_PID, LOG_USER);
            syslog(LOG_INFO, "taille_fichier: %d", (int)taille_fichier);
            closelog();
            
            char *buffer_complet = malloc(taille_fichier + 1); // +1 POUR LE '\0' FINAL
            if (buffer_complet == NULL)
            {
              error("Allocating memory for sending content error");
            }
            lseek(fd_content_file, 0, SEEK_SET);
            ssize_t octets_lus = read(fd_content_file, buffer_complet, taille_fichier);
            close(fd_content_file);
            fd_content_file = -1;
            if (octets_lus < 0)
            {
              error("Reading file before sending error");
            }
            buffer_complet[taille_fichier] = '\0';
            if((write(newsockfd, buffer_complet, taille_fichier)) < 0)
            {
              free(buffer_complet);
              error("Error sending file's content");
            }
            else
            {
              free(buffer_complet);
            }
            break;
          }
          else
          {
            openlog("aesdsocket", LOG_PID, LOG_USER);
            syslog(LOG_INFO, "new line not found");
            closelog();
            write(fd_content_file, message_allocation, read_return);
            free(message_allocation);
            message_allocation = NULL;
          }
          message_allocation = calloc(sizeof(char), 1024);
          if (!message_allocation)
          {
            error("Appending socket content error");
          }
        }
        if (message_allocation)
        {
          free(message_allocation);
          message_allocation = NULL;    
        }
         
        if(read_return < 0)
        {
          error("Reading socket error");
        }
      }
      else
      {
        error("Allocating socket content error");
      }
     
      close(newsockfd);
      newsockfd = -1;
    }
    close(sockfd);
    sockfd = -1;
  }
}


