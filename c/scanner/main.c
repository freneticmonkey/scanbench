#include <stdlib.h>
#include <stdbool.h>

#include "process_files.h"

#ifdef _WIN32
#include <windows.h>
#define MAXPATHLEN 260
#define getwd GetCurrentDirectory
#endif

char pathname[MAXPATHLEN];

bool get_cwd(char* pathname)
{
#ifdef _WIN32
    return (getwd(MAXPATHLEN, &pathname) > 0);
#else
    return getwd(pathname) != NULL;
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

    // This will be compile to a platform specific implementation
    ProcessFiles(pathname);

    return 0;
}
