workspace "scanner"
   configurations { 
      "Debug", 
      "Release" 
   }
   platforms {
      "windows",
      "macosx",
      "macosxARM",
      "linux64",
      "linuxARM64",
      -- etc.
   }

   -- enable tracing for debug builds
   filter "configurations:Debug"
      symbols "On"
      defines { 
         "_DEBUG"
      }

   filter "configurations:Release"
      optimize "On"
      defines { "NDEBUG" }
   
   filter {}

   -- Architecture is x86_64 by default
   architecture "x86_64"

   filter "system:windows"
      defines {
         "PLATFORM_WINDOWS",
         "WIN32",
         "_WIN32"
      }

   filter "system:macosx"
      defines {
         "PLATFORM_MACOS"
      }
   
   filter "platforms:macosxARM or linuxARM64"
      architecture "ARM"
      defines {
         "PLATFORM_ARM"
      }

   filter "system:linux"
      buildoptions {}
      defines {
         "PLATFORM_LINUX"
      }

solution "scanner"
   filename "scanner"
   location "../../projects"

   startproject "c-scanner"

project "dill"
   kind "SharedLib"
   language "C"
   targetdir( "../../build/c" )

   objdir "../../build/c/obj"
   
   includedirs {
      "c/ext/libdill-2.14"
   }

   filter { "system:linux or macosx" }
      files {
         "../ext/libdill-2.14/dns/*",
         -- "../ext/libdill-2.14/perf/*",
         "../ext/libdill-2.14/*.h",
         "../ext/libdill-2.14/*.c",
         "../ext/libdill-2.14/*.inc"
      }
   
   filter { "system:macosx" } 
      sysincludedirs {
         "/opt/homebrew/opt/openssl@3/include"
      }
      libdirs {
         "/opt/homebrew/opt/openssl@3/lib"
      }

      linkoptions {
         "-lssl",
         "-lcrypto",
      }
      -- links {
      --    "ssl",
      --    "crypto"
      -- }
   
   -- filter "configurations:Debug"
   --    defines { "DEBUG" }
   --    symbols "On"
   --    links {
   --       "scanner-lib-d"
   --    }
   -- filter "configurations:Release"
   --    defines { "NDEBUG" }
   --    optimize "On"
   --    links {
   --       "scanner-lib"
   --    }
   -- filter {}

project "c-scanner"
   kind "ConsoleApp"
   language "C"
   targetdir( "../../build/c" )
   debugargs { "" }
   debugdir "."

   filter {}
      libdirs {
        "../../build/c"
      }

      sysincludedirs {
        "c/scanner"
      }

      includedirs {
        "c/scanner"
      }

      files { 
        "**.h",
        "main.c"
      }

    -- enable tracing for debug builds
    --    filter "configurations:Debug" {}
    --   defines {
    --      "TRACY_ENABLE"
    --   }
      
   if os.host() == "linux" then
      libdirs {}
      links {
         "dill",
         -- note, when building openssl /usr/local/lib64 needs to be added to /etc/ld.so.conf.d/libc.conf
         "ssl",
         "crypto"
      }
      files {
         "posix.c"
      }

   elseif os.host() == "windows" then
      files {
         "windows.c"
      }
      defines {
         "_CRT_SECURE_NO_WARNINGS"
      }
      disablewarnings { 
         "4005"
      }
      -- Turn off edit and continue
      editAndContinue "Off"

   elseif os.host() == "macosx" then
      files {
         "posix.c"
      }
      links {
         "dill"
      }
      filter "files:c/scanner/main.c"
         compileas "Objective-C"
   end
      