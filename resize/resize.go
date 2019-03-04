package main

import (
	"github.com/nfnt/resize"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"image/jpeg"
)

func main() {
	path := os.Args[1]

	files, err := ioutil.ReadDir(path)

	if err != nil {
		log.Fatal(err)
	}

	for _, file := range files {
		filename := file.Name()
		file, _ := os.Open(filename)
		// if err != nil {
		// 	log.Fatal(err)
		// }

		// decode jpeg into image.Image
		img, _ := jpeg.Decode(file)
		// if err != nil {
		// 	log.Fatal(err)
		// }
		if img != nil {
			fmt.Printf(filename+"\n")
		}
		file.Close()
		// resize to height 1920 using Lanczos resampling
		// and preserve aspect ratio
		m := resize.Resize(0, 1920, img, resize.Lanczos3)

		out, err := os.Create(filename)
		if err != nil {
			log.Fatal(err)
		}
		defer out.Close()

		// write new image to file
		jpeg.Encode(out, m, &jpeg.Options{Quality: 60})
	}
}

type Options struct {
	Quality int
}