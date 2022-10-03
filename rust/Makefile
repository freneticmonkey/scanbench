
rust-scanner:
	@echo "Building Rust Scanner"
	mkdir -p ../build/rust
	cd scanner && cargo build && rustc src/main.rs -o ../../build/rust/rust-scanner

all: rust-scanner

run:
	../build/rust/rust-scanner ../data