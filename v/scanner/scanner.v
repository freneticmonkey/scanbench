import os
import time

fn path_scan(path string, mut file_count &int, do_walk bool) {
	// mut fc := 0
	// mut fc_ref := &fc
	
	
	if do_walk {
		visit := fn [mut file_count] (path string) {
			// println(path)
			if os.is_dir(path) {
				
			} else {
				(*file_count)++
			}
		}

		os.walk(path, visit)
	} else {
		mut dirs := []string{}
		
		items := os.ls(path) or {
			return
		}

		for pathitem in items {
			// println("pathitem: $pathitem")
			full := os.join_path(path, pathitem)
			if os.is_dir(full) {
				dirs << full
			} else {
				file_count++
			}
		}

		mut threads := []thread{}
		for dir in dirs {
			threads << go path_scan(dir, mut file_count, false)
		}
		threads.wait()
	}

}

fn main() {
	mut file_count := 0

	folder := "data"
	
	
	if false {
		println("Walk Scanning: $folder")

		start := time.now()

		path_scan(folder, mut &file_count, true)

		elapsed := time.since(start)

		println("Walk Scan completed in: $elapsed")
		println("Found file count: $file_count")
		println("")
		file_count = 0
	}

	println("Concurrent Scanning: $folder")

	c_start := time.now()

	path_scan(folder, mut &file_count, false)

	c_elapsed := time.since(c_start)

	println("Concurrent Scan completed in: $c_elapsed")
	println("Found file count: $file_count")

}