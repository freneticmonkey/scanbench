
rust-scanner:
	@echo "Building Rust Scanner"
	mkdir -p ../build/rust
	cd scanner && cargo build && cp target/debug/scanner ../../build/rust/rust-scanner

all: rust-scanner

run:
	../build/rust/rust-scanner ../data