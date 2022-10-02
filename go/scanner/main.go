package main

import (
	"context"
	"flag"
	"io/fs"
	"log"
	"os"
	"path/filepath"
	"runtime/pprof"
	"runtime/trace"
	"sync"
	"time"
)

var wg sync.WaitGroup
var num_files int
var num_files_mut sync.Mutex

func walkDir(ctx context.Context, dir string) {

	wg.Add(1)
	defer wg.Done()

	ctx, task := trace.NewTask(ctx, "walkDir")
	trace.Log(ctx, "path", dir)
	defer task.End()

	file_count := 0

	visitDir := func(path string, d fs.DirEntry, err error) error {
		if d.IsDir() && path != dir {
			// go walkDir(ctx, path)
			walkDir(ctx, path)
			return filepath.SkipDir
		}

		// for now don't do anything with each file
		if d.Type().IsRegular() {
			file_count++
		}
		return nil
	}

	filepath.WalkDir(dir, visitDir)

	// num_files_mut.Lock()
	num_files += file_count
	// num_files_mut.Unlock()
}

func main() {

	var (
		root      string
		profile   string
		traceFile string
		err       error
	)

	flag.StringVar(&root, "path", "", "path of directory to scan.  Uses current working directory if not provided")
	flag.StringVar(&profile, "cpu-profile", "", "write cpu profile to file")
	flag.StringVar(&traceFile, "trace", "", "write trace to file")
	flag.Parse()

	if profile != "" {
		f, err := os.Create(profile)
		if err != nil {
			log.Fatal(err)
		}
		defer f.Close()

		pprof.StartCPUProfile(f)
		defer pprof.StopCPUProfile()
	}

	if traceFile != "" {
		f, err := os.Create(traceFile)
		if err != nil {
			log.Fatal(err)
		}
		defer f.Close()

		trace.Start(f)
		defer trace.Stop()
	}

	if root == "" {
		root, err = os.Getwd()

		if err != nil {
			log.Fatalf("%v", err)
		}
	}

	log.Printf("Scanning path: %s", root)

	pctx := context.Background()

	_, err = os.Stat(root)

	if err != nil {
		log.Fatalf("%v", err)
	}

	start := time.Now()

	walkDir(pctx, root)

	wg.Wait()

	elapsed := time.Since(start)

	log.Printf("Go filewalk took: %s", elapsed)
	log.Printf("Num files read:   %d", num_files)
	log.Println("Num files expected: 1048576")
}
