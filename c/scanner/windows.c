#include "process_files.h"

#include "windows.h"
#include "stdio.h"
#include "stdbool.h"

int ProcessFiles(const char *sDir)
{
    WIN32_FIND_DATA fdFile;
    HANDLE hFind = NULL;

    char sPath[2048];

    // Specify a file mask. *.* = We want everything!
    sprintf(sPath, "%s\\*.*", sDir);

    if ((hFind = FindFirstFile(sPath, &fdFile)) == INVALID_HANDLE_VALUE)
    {
        printf("Path not found: [%s]\n", sDir);
        return 1;
    }

    do
    {
        // Find first file will always return "."
        //     and ".." as the first two directories.
        if (strcmp(fdFile.cFileName, ".") != 0 && strcmp(fdFile.cFileName, "..") != 0)
        {
            // Build up our file path using the passed in
            //   [sDir] and the file/foldername we just found:
            sprintf(sPath, "%s\\%s", sDir, fdFile.cFileName);

            // Is the entity a File or Folder?
            if (fdFile.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)
            {
                printf("Directory: %s\n", sPath);
                ProcessFiles(sPath); // Recursion, I love it!
            }
            else
            {
                printf("File: %s\n", sPath);
            }
        }
    } while (FindNextFile(hFind, &fdFile)); // Find the next file.

    FindClose(hFind); // Always, Always, clean things up!

    return 0;
}

// ListDirectoryContents("C:\\Windows\\");