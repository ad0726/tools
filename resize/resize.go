package main

import (
	"github.com/nfnt/resize"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"io"
	"image/jpeg"
	"archive/zip"
)

type Options struct {
	Quality int
}

func main() {
	path := os.Args[1]
	output := "done.zip"

	files, err := ioutil.ReadDir(path)
	if err != nil {
		log.Fatal(err)
	}

	newZipFile, err := os.Create(output)
    if err != nil {
        log.Fatal(err)
    }
    defer newZipFile.Close()

    zipWriter := zip.NewWriter(newZipFile)
	defer zipWriter.Close()

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

		AddFileToZip(zipWriter, filename)
	}	
}

func AddFileToZip(zipWriter *zip.Writer, filename string) error {

    fileToZip, err := os.Open(filename)
    if err != nil {
        return err
    }
    defer fileToZip.Close()

    // Get the file information
    info, err := fileToZip.Stat()
    if err != nil {
        return err
    }

    header, err := zip.FileInfoHeader(info)
    if err != nil {
        return err
    }

    // Using FileInfoHeader() above only uses the basename of the file. If we want
    // to preserve the folder structure we can overwrite this with the full path.
    header.Name = filename

    // Change to deflate to gain better compression
    // see http://golang.org/pkg/archive/zip/#pkg-constants
    header.Method = zip.Deflate

    writer, err := zipWriter.CreateHeader(header)
    if err != nil {
        return err
	}

    _, err = io.Copy(writer, fileToZip)
    return err
}