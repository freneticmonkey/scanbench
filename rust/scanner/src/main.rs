use std::env;
use std::fs;
use std::time::Instant;

// use std::sync::Mutex;
// use std::sync::Arc;
// use work_queue::{Queue, LocalQueue};
// static NTHREADS: usize = 10;

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

// fn processFolder(folder: String, queue: &Queue<String>) -> u64 {
//     let mut total_files: u64 = 0;
//     let mut dir = match fs::read_dir(folder) {
//         Ok(dir) => dir,
//         Err(_) => return 0,
//     };
//     while let Some(entry) = dir.next() {
//         let entry = match entry {
//             Ok(entry) => entry,
//             Err(_) => continue,
//         };
//         let path = entry.path();
//         if path.is_dir() {
//             let path_str = path.to_str().unwrap().to_string();
//             queue.push(path_str);
//         } else {
//             total_files += 1;   
//         }
//     }
//     return total_files;
// }

// fn parallel(dir: String) -> u64 {
//     // let mut total_files: u64 = 0;
//     let total_files = Arc::new(Mutex::new(0));

//     // create a queue and enqueue the root path
//     let queue: Queue<String> = Queue::new(NTHREADS, 128);
//     queue.push(dir);

//     // Spawn threads to complete the tasks.
//     let handles: Vec<_> = queue
//         .local_queues()
//         .map(|mut local_queue| {
//             std::thread::spawn(move || {
//                 while let Some(path) = local_queue.pop() {
//                     let found_files: u64 = processFolder(path, &queue);

//                     // atomically increment the total number of files
//                     let mut total_files = total_files.lock().unwrap();
//                     *total_files += found_files
//                 }
//             })
//         })
//         .collect();

//     for handle in handles {
//         handle.join().unwrap();
//     }

//     return total_files.lock().unwrap().clone();
// }

// read a path parameter and scan it for files
// and directories
fn main() {
    println!("Starting Rust Scan");
    let args: Vec<String> = env::args().collect();
    let path = &args[1];
    
    
    // get current time
    let start = Instant::now();

    let total_files: u64 = linear(path.to_string());

    // Get elapsed time
    let elapsed = start.elapsed();

    // print results
    println!("Total files: {}", total_files);
    // print time taken
    println!("Time taken: {}ms", elapsed.as_millis());
}