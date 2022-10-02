import os

fn path_scan(path string) {
	dirs := []string{}
	files := os.ls(path) or {
		println(err)
		return
	}
	
	for file in files {
		if os.is_file(file) {
			println(file)
		}
		else if os.is_dir(file) {
			append(dirs, file)
		}
	}

	for dir in dirs {
		path_scan(dir)
	}
}

fn main() {
	println("Hello from v!")
	path_scan("../data")
}