#include <stdlib.h>
#include <stdbool.h>
#include <stdio.h>
#include <time.h>
#include <string.h>

#include "process_files.h"

#define MAXPATHLEN 260

#ifdef _WIN32
#include <windows.h>
#define getwd GetCurrentDirectory
#else
#include <unistd.h>
#endif

char pathname[MAXPATHLEN];

bool get_cwd(char* pathname)
{
#ifdef _WIN32
    return (getwd(MAXPATHLEN, &pathname) > 0);
#else
    return getcwd(pathname, MAXPATHLEN) != NULL;
#endif
    return false;
}


int main(int argc, char *argv[])
{
    // if a path has been supplied
    if (argc == 2)
    {
        strncpy(pathname, argv[1], MAXPATHLEN);
    }
    else if (!get_cwd(&pathname[0]))
    {
        printf("Error determining the current working path\n");
        exit(0);
    }

    clock_t begin = clock();
    
    // This will be compile to a platform specific implementation
    long file_count = ProcessFiles(pathname);

    clock_t end = clock();

    if (file_count == -1)
    {
        printf("Error while searching the file count. Error: %lu\n", file_count);
        exit(0);
    }

    double time_spent = (double)(end - begin) / CLOCKS_PER_SEC;

    printf("Total Files: %lu\n", file_count);

    printf("Time elapsed: %fms\n", time_spent * 1000.0);

}
