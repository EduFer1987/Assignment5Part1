//------------------------------------------------------------------------
//------------------------------------------------------------------------
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <syslog.h>
#include <libgen.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

char *file_dir;
int  file_desc;


//------------------------------------------------------------------------
int main (int argc, char *argv[])
{
  int   i;
  int   path_str_lnth;
  char *file_path;


  if (3 != argc)  
  {
    
    openlog("", LOG_CONS | LOG_PERROR, LOG_USER);
    syslog(LOG_ERR, "Calling this script it must input two parameters.\n");
    return 1;
  }
  else
  {    
    path_str_lnth = strlen (argv[1]);
    file_path = malloc(path_str_lnth);
    for (i = 0; i < path_str_lnth; i++)
    {
      file_path[i] = argv[1][i];
    }

    file_desc = open(file_path, O_RDWR | O_CREAT);
    file_dir = dirname(argv[1]);
    if (-1 == open(file_dir, O_DIRECTORY))
    {
      openlog("", LOG_CONS | LOG_PERROR, LOG_USER);
      syslog(LOG_ERR, "Wrong directory.\n");
      return 1;
    }
    else
    {
      if (-1 == file_desc)
      {
        openlog("", LOG_CONS | LOG_PERROR, LOG_USER);
        syslog(LOG_ERR, "File creation error.\n");
        return 1;
      }
      else
      {
        if (-1 == write(file_desc, argv[2], strlen (argv[2])))
        {
          openlog("", LOG_CONS | LOG_PERROR, LOG_USER);
          syslog(LOG_ERR, "Error writing to file.\n");
          return 1;
        }
        else
        {
          openlog("", LOG_CONS, LOG_USER);
          syslog(LOG_DEBUG, "Writing %s to %s", argv[2], file_path);
          return 0;         
        }
      }
    }
  }

  return 1;
}
//------------------------------------------------------------------------
//------------------------------------------------------------------------
