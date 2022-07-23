go-generator:
	@echo "Building Go Generator"
	go build -o ../build/go/go-generator generator/main.go

go-scanner:
	@echo "Building Go Scanner"
	go build -o ../build/go/go-scanner scanner/main.go

go-server:
	@echo "Building Go Server"
	go build -o ../build/go/go-server server/main.go

run:
	../build/go/go-scanner --path=../data

generate:
	../build/go/go-generator

all: go-generator go-scanner go-server