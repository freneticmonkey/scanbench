COMMIT=$(shell git rev-parse HEAD)
BRANCH=$(shell git rev-parse --abbrev-ref HEAD)
BUILD_TIME=$(shell date)

THIS_OS=windows
THIS_ARCH=x86

TOOL_PATH=.\tools\windows\x86
TOOL_BUILD=vs2019
TOOL_PLATFORM=windows

ifeq ($(OS),Windows_NT)
	THIS_OS=windows
else
	UNAME_S := $(shell uname -s)
	THIS_ARCH=$(shell uname -m)
	ifeq ($(UNAME_S),Linux)
		THIS_OS=linux
	endif
	ifeq ($(UNAME_S),Darwin)
		THIS_OS=darwin
	endif
endif

ifeq (${THIS_OS},darwin)
	TOOL_BUILD=xcode4
	TOOL_PATH=./tools/osx/x86
	TOOL_PLATFORM=macosx
endif
ifeq (${THIS_OS},linux)
	TOOL_BUILD=gmake
	TOOL_PATH=./tools/unix/x86
	TOOL_PLATFORM=linux64
	ifeq (${THIS_ARCH},aarch64)
		TOOL_PATH=./tools/unix/arm
		TOOL_PLATFORM=linuxARM64
	endif
endif

details:
	@echo "Detected OS: ${THIS_OS}"
	@echo "Detected Arch: ${THIS_ARCH}"
	@echo "Commit: ${COMMIT}"
	@echo "Branch: ${BRANCH}"
	@echo "-----"

go-generator:
	@echo "Building Go Generator"
	go build -o build/go-generator go/generator/main.go

go-scanner:
	@echo "Building Go Scanner"
	go build -o build/go-scanner go/scanner/main.go

c-scanner-gen: details
	${TOOL_PATH}/premake5 ${TOOL_BUILD} platform=${TOOL_PLATFORM} --file=c/scanner/premake5.lua
	@echo "Gen Finished: Commit: ${COMMIT} Branch: ${BRANCH}"

c-scanner: c-scanner-gen
	@echo "Building C Scanner"
ifeq (${THIS_OS},windows)
	msbuild.exe ./c/scanner/projects/scanner.sln -p:Platform="windows";Configuration=Release -target:c-scanner
endif
ifeq (${THIS_OS},darwin)
	xcodebuild -configuration "Release" ARCHS="x86_64" -destination 'platform=macOS' -project "c/scanner/projects/c-scanner.xcodeproj" -target c-scanner
endif
ifeq (${THIS_OS},linux)
	make -C c/scanner/projects c-scanner config=release_linux64
endif





