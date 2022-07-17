#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/dir.h>
#include <sys/param.h>
#include <unistd.h>
 
extern  int alphasort();
 
char pathname[MAXPATHLEN];

int file_select(const struct direct *entry)
{
    if ((strcmp(entry->d_name, ".") == 0) || (strcmp(entry->d_name, "..") == 0))
        return 0;
    else
        return 1;
}

int main()   
{ 
    int count, i = 0;
    struct direct **files;

    if (getwd(pathname) == NULL )
    { 
        printf("Error getting path\n");
        exit(0);
    }

    printf("Current Working Directory = %s\n",pathname);
    count = scandir(pathname, &files, file_select, alphasort);

    /* If no files found, make a non-selectable menu item */
    if (count <= 0)
    {		 
        printf("No files in this directory\n");
        exit(0);
    }
    printf("Number of files = %d\n",count);
    for (i=1;i<count+1;++i)
    {
        printf("%s  \n",files[i-1]->d_name);
    }
    printf("\n"); /* flush buffer */

    return 0;
}
