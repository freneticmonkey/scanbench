
go-all:
	make -C go all

go-build:
	make -C go go-scanner

go-run:
	make -C go run

go-run-prof:
	make -C go run-prof

c-build:
	make -C c c-scanner

c-all-debug:
	make -C c all-debug

c-run:
	make -C c run

v-build:
	make -C v v-scanner

v-run:
	make -C v run

zig-build:
	make -C zig zig-scanner

zig-run:
	make -C zig run

rust-build:
	make -C rust rust-scanner

rust-run:
	make -C rust run

build-all: go-build c-build v-build zig-build rust-build

run-all: c-run go-run v-run zig-run rust-run
	
generate-data:
	make -C go generate

setup: go-all generate-data
	
