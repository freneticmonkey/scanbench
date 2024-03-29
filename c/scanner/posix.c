#include "process_files.h"

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>

#ifndef _WIN32
#include <sys/dir.h>
#include <sys/param.h>
#include <unistd.h>
#endif

extern int alphasort();


char item_type;

int file_select(const struct direct *entry)
{
    if ((strcmp(entry->d_name, ".") == 0) || (strcmp(entry->d_name, "..") == 0))
        return 0;
    else
        return 1;
}

long ProcessFiles(const char * pathname)
{
    int count, i = 0;
    struct direct **files;

    // printf("Current Working Directory = %s\n", pathname);
    count = scandir(pathname, &files, file_select, alphasort);

    if (count <= 0)
    {
        // printf("No files in this directory\n");
        return 0;
    }
    int file_count = 0;
    for (i = 1; i < count + 1; ++i)
    {
        struct direct *file = files[i - 1];
        item_type = (file->d_type & DT_DIR) ? 'd' : 'f';
        if ( file->d_type & DT_DIR )
        {
            // printf("%c  %s  \n", item_type, file->d_name);
            char new_path[MAXPATHLEN];
            sprintf(new_path, "%s/%s", pathname, file->d_name);
            file_count += ProcessFiles(new_path);
        }
        else
        {
            file_count++;
        }
    }
    // printf("Number of files = %d\n", file_count);
    fflush(stdout);

    return file_count;
}