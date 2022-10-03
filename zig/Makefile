
zig-scanner:
	@echo "Building Zig Scanner"
	mkdir -p ../build/zig
	cd scanner; zig build-exe -OReleaseFast --cache-dir ../../build/zig/zig-cache scanner.zig 
	mv scanner/scanner ../build/zig/zig-scanner

all: zig-scanner

run:
	../build/zig/zig-scanner --path=../data