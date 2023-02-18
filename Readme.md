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
| Rust - Linear - old debug | 26897ms |
| Rust - Linear Optimised (no file stat) | 672ms |
| Rust - Parallel* | 355ms |
| Rust - Walk* | 717ms |

\* The rust implementation is using walkdir for Walk and work-queue for Parallel.  The walkdir implementation is using the default settings for the walker, while the work-queue implementation is using 10 threads.

## Implementation Notes

### Go

I originally implemented using filepath.Walk, then switched to filepath.WalkDir which was added in go 1.16 and significantly faster as it avoids calling Lstat on every file.  I haven't looked into how this is implemented but I expect that the other tested languages which are signficantly slower would benefit from a similar optimisation.  I also experimented with using goroutines to parallelise the walk, but this was slower than the current implementation using WalkDir and iterating.  In addition I was able to do some high level profiling which clearly showed that the majority of the time was spent in the Lstat call.




## Setup notes

Build the Go tooling and generate the data set
    `make setup`

Run the tests
    `make run-all`