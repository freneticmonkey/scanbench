#include <stdlib.h>
#include <stdbool.h>
#include <stdio.h>
#include <time.h>

#include "process_files.h"

#define MAXPATHLEN 260

#ifdef _WIN32
#include <windows.h>
#define getwd GetCurrentDirectory
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
    else if (!get_cwd(&pathname))
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
        printf("Error while searching the file count. Error: %llu\n", file_count);
        exit(0);
    }

    double time_spent = (double)(end - begin) / CLOCKS_PER_SEC;

    printf("The search ran in %f seconds", time_spent);

    printf("Files Found: %llu\n", file_count);
}
