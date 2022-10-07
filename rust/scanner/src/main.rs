use std::env;
use std::fs;
use std::time::Instant;

use std::sync::Arc;
use std::sync::atomic::{AtomicUsize, Ordering};
use work_queue::{Queue};
use walkdir::WalkDir;

static NTHREADS: usize = 10;

fn linear(dir: String) -> u64 {
    let mut total_files: u64 = 0;
    let mut stack: Vec<String> = Vec::new();
    stack.push(dir);

    // walk path
    while !stack.is_empty() {
        let current_path = stack.pop().unwrap();
        let mut dir = match fs::read_dir(current_path) {
            Ok(dir) => dir,
            Err(_) => continue,
        };
        while let Some(entry) = dir.next() {
            let entry = match entry {
                Ok(entry) => entry,
                Err(_) => continue,
            };
            let path = entry.path();
            if path.is_dir() {
                let path_str = path.to_str().unwrap().to_string();
                stack.push(path_str);
            } else {
                total_files += 1;
            }
        }
    }

    return total_files;
}

fn walk(dir:String) -> u64 {

    // use walkdir::WalkDir to walk the directory
    let mut total_files: u64 = 0;
    for entry in WalkDir::new(dir) {
        let entry = match entry {
            Ok(entry) => entry,
            Err(_) => continue,
        };
        if entry.file_type().is_file() {
            total_files += 1;
        }
    }

    return total_files;
}

fn parallel(dir: String) -> usize {
    let total_files = Arc::new(AtomicUsize::new(0));

    // create a queue and enqueue the root path
    let queue = Queue::<String>::new(NTHREADS, 128);
    queue.push(dir);

    // Spawn threads to complete the tasks.
    let handles: Vec<_> = queue
        .local_queues()
        .map(|mut local_queue| {
            let count = total_files.clone();

            std::thread::spawn(move || {
                while let Some(path) = local_queue.pop() {
                    
                    let mut dir = match fs::read_dir(path) {
                        Ok(dir) => dir,
                        Err(_) => continue,
                    };

                    while let Some(entry) = dir.next() {
                        let entry = match entry {
                            Ok(entry) => entry,
                            Err(_) => continue,
                        };
                        let path = entry.path();
                        if path.is_dir() {
                            let path_str = path.to_str().unwrap().to_string();
                            local_queue.push(path_str);
                        } else {
                            count.fetch_add(1, Ordering::SeqCst);
                        }
                    }
                }
            })
        })
        .collect();

    for handle in handles {
        handle.join().unwrap();
    }

    return total_files.load(Ordering::SeqCst);
}

// read a path parameter and scan it for files
// and directories
fn main() {
    println!("Starting Rust Scan");
    let args: Vec<String> = env::args().collect();
    let path = &args[1];
    
    
    println!("Linear Scan");
    // get current time
    let mut start = Instant::now();
    let mut total_files: u64 = linear(path.to_string());

    // Get elapsed time
    let mut elapsed = start.elapsed();

    println!("Total Files: {}", total_files);
    println!("Time Elapsed: {}ms", elapsed.as_millis());
    println!("");

    println!("Parallel Scan");

    // get current time
    let parallel_start = Instant::now();
    let parallel_files: usize = parallel(path.to_string());

    // Get elapsed time
    let parallel_elapsed = parallel_start.elapsed();

    // print results
    println!("Total Files: {}", parallel_files);
    println!("Time Elapsed: {}ms", parallel_elapsed.as_millis());
    println!("");

    println!("Walk Scan");
    // get current time
    start = Instant::now();
    total_files = walk(path.to_string());

    // Get elapsed time
    elapsed = start.elapsed();

    println!("Total Files: {}", total_files);
    println!("Time Elapsed: {}ms", elapsed.as_millis());
    println!("");
}