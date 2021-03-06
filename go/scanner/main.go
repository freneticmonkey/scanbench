package main

import (
	"flag"
	"log"
	"os"
	"path/filepath"
	"sync"
	"time"
)

var wg sync.WaitGroup
var num_files int
var num_files_mut sync.Mutex

func walkDir(dir string) {
	defer wg.Done()

	file_count := 0
	visit := func(path string, f os.FileInfo, err error) error {
		if f.IsDir() && path != dir {
			wg.Add(1)
			go walkDir(path)
			return filepath.SkipDir
		}

		// for now don't do anything with each file
		if f.Mode().IsRegular() {
			// fmt.Printf("Visited: %s File name: %s Size: %d bytes\n", path, f.Name(), f.Size())
			file_count++
		}
		return nil
	}

	filepath.Walk(dir, visit)
	num_files_mut.Lock()
	num_files += file_count
	num_files_mut.Unlock()
}

func main() {

	var (
		root string
		err  error
	)

	flag.StringVar(&root, "path", "", "path of directory to scan.  Uses current working directory if not provided")
	flag.Parse()

	if root == "" {
		root, err = os.Getwd()

		if err != nil {
			log.Fatalf("%v", err)
		}
	}

	log.Printf("Scanning path: %s", root)

	_, err = os.Stat(root)

	if err != nil {
		log.Fatalf("%v", err)
	}

	start := time.Now()

	wg.Add(1)
	walkDir(root)
	wg.Wait()

	elapsed := time.Since(start)

	log.Printf("Go filewalk took %s", elapsed)
	log.Printf("Num files read %d", num_files)
}
