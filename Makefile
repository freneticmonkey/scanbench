
go-all:
	make -C go all

go-run:
	make -C go run

c-all:
	make -C c all

c-all-debug:
	make -C c all-debug

c-run:
	make -C c run

all: go-all c-all

generate-data:
	make -C go generate

run: c-run go-run
	

