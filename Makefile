
go-all:
	make -C go all

go-run:
	make -C go run

go-run-prof:
	make -C go run-prof

c-all:
	make -C c all

c-all-debug:
	make -C c all-debug

c-run:
	make -C c run

v-all:
	make -C v all

v-run:
	make -C v run

all: go-all c-all v-all

generate-data:
	make -C go generate

run: c-run go-run v-run
	

