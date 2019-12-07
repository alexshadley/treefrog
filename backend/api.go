package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"regexp"
	"strings"

	"github.com/alexshadley/treefrog/orm"
	"github.com/alexshadley/treefrog/orm/orient"
	"github.com/alexshadley/treefrog/model"
)

// a handler that takes params in the path
type varHandler = func(http.ResponseWriter, *http.Request, ...string)

type handlerEntry struct {
	path     *regexp.Regexp
	function varHandler
}

type varMux struct {
	handlerTable []handlerEntry
}

func (mux *varMux) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	for _, entry := range mux.handlerTable {
		if matches := entry.path.FindSubmatch([]byte(r.URL.Path)); matches != nil {
			args := make([]string, len(matches)-1)
			for i, v := range matches[1:] {
				args[i] = string(v)
			}
			entry.function(w, r, args...)
			return
		}
	}

	// TODO: make actual 404 response
	fmt.Fprintf(w, "Path not found")
}

func (mux *varMux) handleFunc(url string, f varHandler) {
	newEntry := handlerEntry{path: regexp.MustCompile(makeURLRegex(url)), function: f}
	mux.handlerTable = append(mux.handlerTable, newEntry)
}

func makeURLRegex(url string) string {
	// syntax for url params is {}
	reg := strings.Replace(url, "{}", "([A-Za-z]*)", -1)
	// escape slashes in url for regex processing
	reg = strings.Replace(reg, "/", "\\/", -1)
	// force regex to match strings going from start to end
	reg = "^" + reg + "$"
	return reg
}

func userHandler(w http.ResponseWriter, r *http.Request, args ...string) {
	fmt.Fprintf(w, "Hello, %s", args[0])
}

func main() {
	args := os.Args[1:]
	config, err := LoadConfig()
	
	if err != nil {
		fmt.Println(err)
		return
	}

	client, err := orient.NewClient(config.DbUrl, config.Database, config.DbUsername, config.DbPassword)
	if err != nil {
		fmt.Println(err)
		return
	}

	if len(args) == 1 && args[0] == "initdb" {
		classes := make([]interface{}, 0)
		classes = append(classes, model.User{})
		classes = append(classes, model.Frog{})
		classes = append(classes, model.Transfer{})

		err := orm.CreateSchema(classes, client)
		if err != nil {
			fmt.Println(err)
		} else {
			fmt.Println("Schema Created")
		}
	} else {
		f := new(varMux)
		f.handleFunc("/users/{}", userHandler)
		log.Fatal(http.ListenAndServe(":5000", f))
	}

}
