
include ../MakeSetup

c-scanner-gen: details
	${TOOL_PATH}/premake5 ${TOOL_BUILD} platform=${TOOL_PLATFORM} --file=scanner/premake5.lua
	@echo "Gen Finished: Commit: ${COMMIT} Branch: ${BRANCH}"

c-scanner: c-scanner-gen
	@echo "Building C Scanner"
ifeq (${THIS_OS},windows)
	msbuild.exe ./scanner/projects/scanner.sln -p:Platform="windows";Configuration=Release -target:c-scanner
endif
ifeq (${THIS_OS},darwin)
	xcodebuild -configuration "Release" ARCHS="x86_64" -destination 'platform=macOS' -project "scanner/projects/c-scanner.xcodeproj" -target c-scanner
endif
ifeq (${THIS_OS},linux)
	make -C scanner/projects c-scanner config=release_linux64
endif
	mv scanner/build ..

all: c-scanner-gen c-scanner