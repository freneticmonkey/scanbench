
rust-scanner:
	@echo "Building Rust Scanner"
	mkdir -p ../build/rust
	cd scanner && cargo build --release && cp target/release/rust-scanner ../../build/rust/rust-scanner

all: rust-scanner

run:
	../build/rust/rust-scanner --path=../data --mode=all