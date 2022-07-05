package main

import (
	"fmt"
	"log"
	"math/rand"
	"os"
	"sync"
)

const (
	pathchars string = "0123456789ABCDEF"
	// exp       int    = 2 // 16 ^ exp = num folders & num files in each folder
)

var lorum_ipsum string = `Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis porttitor, tellus eu eleifend congue, mauris dui varius metus, maximus euismod arcu ligula ultricies tortor. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer imperdiet malesuada mauris id egestas. Sed id consectetur metus. Vestibulum non tellus et urna consectetur egestas. Nullam aliquet vel sapien quis porta. Duis eu dolor enim. Nam interdum mattis dolor, sit amet posuere urna viverra non. Duis vestibulum ornare ante, non ultricies ipsum ultrices non. Ut eget eleifend mauris, at eleifend neque. Mauris ac posuere felis. Maecenas placerat interdum euismod. Pellentesque malesuada id eros ac volutpat. Nulla et erat lobortis, sodales orci ac, tempus odio. Vivamus varius feugiat blandit. Donec dui sapien, lacinia sed maximus non, scelerisque vel nulla.

Sed ornare erat libero, vitae iaculis orci faucibus molestie. Nunc porta velit nec felis luctus, vitae molestie leo vulputate. In hac habitasse platea dictumst. In aliquet porta sem, eget lobortis dui placerat ut. Nullam consectetur at massa a ultricies. Curabitur ornare suscipit lacus, sed viverra neque egestas eu. Mauris in arcu vitae ex congue iaculis a id urna. Integer ac purus id ligula tristique facilisis.

Donec non congue nisi. Ut ultricies consequat lectus, vitae varius sem sagittis a. Ut non ipsum tincidunt, lacinia tellus a, dapibus leo. Mauris dapibus dapibus lectus, ac ullamcorper neque feugiat bibendum. Phasellus quis eros sed sapien maximus cursus vel nec ipsum. Integer nec dictum sem. Donec id leo hendrerit, condimentum mauris nec, posuere nunc. Aenean semper libero varius, convallis nisi sed, vehicula elit. Ut leo velit, semper sed elementum sed, malesuada at tellus. Ut nec dolor felis. Proin odio mi, lobortis ut mattis eu, vestibulum nec est. Suspendisse suscipit ultricies ultrices. Nam ac congue risus. Ut dignissim congue erat sed egestas. Ut ultricies dui sit amet lorem scelerisque, eget sagittis elit aliquet. Etiam lorem nibh, hendrerit sed velit sed, tristique molestie massa.

Maecenas rutrum enim in mollis lacinia. Curabitur eu massa ante. Etiam dui odio, laoreet pharetra elementum ut, porttitor sit amet mi. Duis ligula lacus, venenatis eget turpis nec, gravida tincidunt nibh. Pellentesque imperdiet venenatis velit, eu viverra nunc maximus non. Mauris luctus risus ipsum, mattis finibus orci ultricies ut. Curabitur fermentum pellentesque semper. Pellentesque et finibus tellus, in ornare mauris.

Etiam ullamcorper mi justo, vel lacinia mi malesuada non. Donec fermentum lectus eu turpis elementum, id ullamcorper risus venenatis. Praesent cursus, eros a mollis luctus, turpis massa sollicitudin eros, et tempus mi nisl ac ante. Sed id felis ut nulla iaculis hendrerit tempor eget orci. Sed vel maximus quam, dapibus venenatis augue. Curabitur rutrum tristique tellus, quis condimentum purus feugiat vitae. Duis tincidunt sed nisi vel sagittis. Nunc at augue dapibus, dictum ligula eu, convallis ex. Maecenas at eros sed lorem consectetur elementum. Mauris fringilla arcu a mi condimentum, nec varius metus tincidunt. Donec a volutpat dolor, ac mollis tortor. Sed eget porta nibh.`

var lorum_ipsum_bytes []byte
var lorum_ipsum_len int = len(lorum_ipsum_bytes)

func generate_file_content() []byte {
	return lorum_ipsum_bytes[:rand.Intn(lorum_ipsum_len)]
}

func generate_file(wg *sync.WaitGroup, pwd string, base rune) error {
	defer wg.Done()

	log.Printf("Generating subpath: %c/\n", base)
	for i := 0; i < len(pathchars); i++ {
		char := pathchars[i]
		folder_path := fmt.Sprintf("%s/%c/%c", pwd, base, char)

		err := os.MkdirAll(folder_path, 0700)

		if err != nil {
			log.Printf("Path Create Failed: %v", err)
			return err
		}

		for j := 0; j < 4096; j++ {
			path := fmt.Sprintf("%s/%d.txt", folder_path, j)
			content := generate_file_content()
			// log.Printf("Generating file: [%s] of [%d] bytes\n", path, len(content))

			err = os.WriteFile(path, content, 0644)

			if err != nil {
				log.Printf("Write Failed: %v", err)
				return err
			}
		}
	}
	log.Printf("Subpath: %c/ Generation Complete\n", base)
	return nil
}

func main() {
	cwd, err := os.Getwd()

	if err != nil {
		log.Fatalf("%v", err)
	}

	lorum_ipsum_bytes = []byte(lorum_ipsum)
	lorum_ipsum_len = len(lorum_ipsum_bytes)

	cwd += "/data"

	log.Printf("Starting File Generation in path: %s\n", cwd)

	var wg sync.WaitGroup

	for _, dir := range pathchars {
		log.Printf("Generating subpath: %c/\n", dir)
		wg.Add(1)
		go func(d rune) {
			err = generate_file(&wg, cwd, d)

			if err != nil {
				log.Fatalf("Generate Failed: %v", err)
			}
		}(dir)
	}
	wg.Wait()
}
