# Scan Bench

A small suite of tests to compare the performance of different disk scanning implementations in the standard libraries of various languages.

## Rationale
I was looking for a small project to get a feel for various languages that I hadn't used before and this was something that I had recently been thinking about in relation to another project. While my intention was to stick to the standard library, I have made an exception for some languages (rust) because I was suprised by the performance of the features available in the standard library.


## Implementation Note:
While I have spent some time with C and Go, the other languages are all new to me and as such there may be some issues with their implementations which have an impact on their performance.  If you spot any issues, please let me know and I will try to fix them.

## Testing Strategy
I have implemented a generator (go/generator) which creates a folder structure in the target directory two levels deep and writes into each directory 4096 files, which are filled with random slices of lorum ipsum text.  While the files themselves aren't read (another test perhaps), the directory structure is scanned and total files counted.

## Results

Test Hardware: 2021 M1 MacBook Pro (10 core, 16Gb RAM)

Total Files: 1048576

| Language | Time (ms) |
|----------|-----------|
| Zig | 465 ms |
| C | 730 ms |
| Go | 843 ms |
| V - Walk | 26099 ms |
| V - Parallel | 11865 ms |
| Rust - Linear | 26897ms |
| Rust - Parallel* | 6238ms |
| Rust - Walk* | 1694ms |

\* The rust implementation is using walkdir for Walk and work-queue for Parallel.  The walkdir implementation is using the default settings for the walker, while the work-queue implementation is using 10 threads.