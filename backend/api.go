package main

import (
	"fmt"
	"net/http"
	"regexp"
	"strings"
)

type handler = func(http.ResponseWriter, *http.Request, ...string)

type handlerEntry struct {
	path     *regexp.Regexp
	function handler
}

var handlerTable []handlerEntry

func makeURLRegex(url string) string {
	// syntax for url params is {}
	reg := strings.Replace(url, "{}", "([A-Za-z]*)", -1)
	// escape slashes in url for regex processing
	reg = strings.Replace(reg, "/", "\\/", -1)
	return reg
}

func register(url string, f handler) {
	newEntry := handlerEntry{path: regexp.MustCompile(makeURLRegex(url)), function: f}
	handlerTable = append(handlerTable, newEntry)
}

func landing(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello, world!")
}

func globalHandler(w http.ResponseWriter, r *http.Request) {
	for _, entry := range handlerTable {
		if matches := entry.path.FindSubmatch([]byte(r.URL.Path)); matches != nil {
			args := make([]string, len(matches)-1)
			for i, v := range matches[1:] {
				args[i] = string(v)
			}
			entry.function(w, r, args...)
		}
	}
}

func userHandler(w http.ResponseWriter, r *http.Request, args ...string) {
	fmt.Fprintf(w, "Hello, %s", args[0])
}

func main() {
	register("/users/{}", userHandler)

	http.HandleFunc("/", globalHandler)
	http.ListenAndServe(":8080", nil)
}
