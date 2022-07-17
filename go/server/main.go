package main

import (
	"flag"
	"log"
	"os"
)

func main() {
	flag.Parse()

	wd, err := os.Getwd()

	if err != nil {
		log.Fatalf("%v", err)
	}

	log.Printf("Running server in path: %s", wd)

}
