#include "process_files.h"

#include "windows.h"
#include "stdio.h"
#include "stdbool.h"

long file_count = 0;

BOOL GetErrorMessage(DWORD dwErrorCode, char * pBuffer, DWORD cchBufferLength)
{
    char tempBuffer[1024];
    
    if (cchBufferLength == 0)
    {
        return FALSE;
    }

    DWORD cchMsg = FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
        NULL,  /* (not used with FORMAT_MESSAGE_FROM_SYSTEM) */
        dwErrorCode,
        MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
        tempBuffer,
        cchBufferLength,
        NULL);
    
    // convert this stupid string into UTF-8
    int j = 0;
    for (int i = 0; i < 1024; i+=2)
    {
        pBuffer[j] = tempBuffer[i];
        j++;
    }
    pBuffer[j] = '\0';
    return (cchMsg > 0);
}

int ProcessFiles(const char *sDir)
{
    WIN32_FIND_DATA fdFile;
    HANDLE hFind = NULL;

    char sPath[2048];

    // Specify a file mask. *.* = We want everything!
    sprintf(sPath, "%s\\*.*", sDir);

    if ((hFind = FindFirstFileA(&sPath, &fdFile)) == INVALID_HANDLE_VALUE)
    {
        int error = GetLastError();

        HRESULT result = HRESULT_FROM_WIN32(error);
        
        char errorMessage[1024];
        if ( GetErrorMessage(result, errorMessage, 1024) )
        {
            printf("Path: [%s]\n%s\n", sPath, errorMessage);
        }

        return -1;
    }

    do
    {
        // Find first file will always return "."
        //     and ".." as the first two directories.
        if (strcmp(fdFile.cFileName, "." ) != 0 && 
            strcmp(fdFile.cFileName, "..") != 0)
        {
            // Build up our file path using the passed in
            //   [sDir] and the file/foldername we just found:
            sprintf(sPath, "%s\\%s", sDir, fdFile.cFileName);

            // Is the entity a File or Folder?
            if (fdFile.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)
            {
                printf("Directory: %s\n", sPath);
                ProcessFiles(sPath);
            }
            else
            {
                //printf("File: %s\n", sPath);
                file_count++;
            }
        }
    } while (FindNextFile(hFind, &fdFile)); // Find the next file.

    FindClose(hFind); // Always, Always, clean things up!

    return file_count;
}