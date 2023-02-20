use std::fs;
use std::time::Instant;

use clap::Parser;

use std::sync::Arc;
use std::sync::atomic::{AtomicU64, Ordering};
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
            let ft = entry.file_type().unwrap();
            if ft.is_dir() {
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

fn parallel(dir: String) -> u64 {
    let total_files = Arc::new(AtomicU64::new(0));

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
                        if entry.file_type().unwrap().is_dir() {
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

#[derive(Parser)]
struct Opts {
    #[clap(short, long)]
    path: String,
    #[clap(short, long)]
    mode: String,
}   

fn run_scan(name: String, f: fn(String) -> u64, path:String) {
    println!("{} Scan", name);
            // get current time
            let start = Instant::now();
            let total_files: u64 = f(path);

            // Get elapsed time
            let elapsed = start.elapsed();

            println!("Total Files: {}", total_files);
            println!("Time Elapsed: {}ms", elapsed.as_millis());
            println!("");
}

// read a path parameter and scan it for files
// and directories
fn main() {

    let args = Opts::parse();   

    println!("Starting Rust Scan");
    // let args: Vec<String> = env::args().collect();
    let path = args.path.to_string();

    match args.mode.as_str() {
        "linear"=> {
            run_scan("Linear".to_string(), linear, path);
        },
        "parallel"=> {
            run_scan("Parallel".to_string(), parallel, path);
        },
        "walk"=> {
            run_scan("Walk".to_string(), walk, path);
        },
        _ => {
            println!("Running all scans");
            run_scan("Linear".to_string(), linear, path.clone());
            run_scan("Parallel".to_string(), parallel, path.clone());
            run_scan("Walk".to_string(), walk, path.clone());
        }
    }
}