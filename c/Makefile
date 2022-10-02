
include ../MakeSetup

COMPILER:=
ifeq (${THIS_OS},linux)
	COMPILER=--cc=clang
endif

c-scanner-gen: details
	@echo "Generating Project: C Scanner"
	${TOOL_PATH}/premake5 ${TOOL_BUILD} platform=${TOOL_PLATFORM} --file=scanner/premake5.lua ${COMPILER}
	@echo "Gen Finished: Commit: ${COMMIT} Branch: ${BRANCH} ${COMPILER}"

c-scanner: c-scanner-gen
	@echo "Building C Scanner"
ifeq (${THIS_OS},windows)
	msbuild.exe ../projects/scanner.sln -p:Platform="windows";Configuration=Release -target:c-scanner
endif
ifeq (${THIS_OS},darwin)
	xcodebuild -configuration "Release" ARCHS="${BUILD_ARCH}" -destination 'platform=macOS' -project "../projects/c-scanner.xcodeproj" -target c-scanner
endif
ifeq (${THIS_OS},linux)
	make -C ../projects c-scanner config=release_linux64
endif

c-scanner-debug: c-scanner-gen
	@echo "Building C Scanner"
ifeq (${THIS_OS},windows)
	msbuild.exe ../projects/scanner.sln -p:Platform="windows";Configuration=Debug -target:c-scanner
endif
ifeq (${THIS_OS},darwin)
	xcodebuild -configuration "Debug" ARCHS="${BUILD_ARCH}" -destination 'platform=macOS' -project "../projects/c-scanner.xcodeproj" -target c-scanner
endif
ifeq (${THIS_OS},linux)
	make -C ../projects c-scanner config=debug_linux64
endif

run:
	../build/c/c-scanner ../data

all: c-scanner-gen c-scanner

all-debug: c-scanner-debug