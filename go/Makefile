go-generator:
	@echo "Building Go Generator"
	go build -o ../build/go/go-generator generator/main.go

go-scanner:
	@echo "Building Go Scanner"
	GOARCH=arm64 go build -o ../build/go/go-scanner scanner/main.go

go-server:
	@echo "Building Go Server"
	go build -o ../build/go/go-server server/main.go

run:
	../build/go/go-scanner --path=../data

run-prof:
	../build/go/go-scanner --path=../data --cpu-profile=cpu.prof --trace=trace.prof

all: go-generator go-scanner go-server