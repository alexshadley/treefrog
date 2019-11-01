package main

import (
	"fmt"
	"net/http"
)

func landing(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello, world!")
}

func main() {
	http.HandleFunc("/", landing)
	http.ListenAndServe(":8080", nil)
}