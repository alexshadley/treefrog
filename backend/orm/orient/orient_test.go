package orient

import (
	"fmt"
	"net/http"
	"net/http/httptest"
	"regexp"
	"testing"
)

type requestHandler struct {
	Requests []request
	index int
}

type request struct {
	Method string
	PathRegex string
	ResponseCode int
	ResponseBody string
}

const dbName string = "treefrog"
const connectPath string = "/connect/" + dbName

func (r *requestHandler) HandleRequest(t *testing.T, request *http.Request, w http.ResponseWriter) {
	index := r.index
	r.index += 1

	if r.index > len(r.Requests) {
		t.Errorf("Too many requests made; expected %d", len(r.Requests))
	}

	if r.Requests[index].PathRegex[0] != '^' {
		r.Requests[index].PathRegex = "^" + r.Requests[index].PathRegex
	}
	if r.Requests[index].PathRegex[0] != '$' {
		r.Requests[index].PathRegex += "$"
	}

	regex, err := regexp.Compile(r.Requests[index].PathRegex)
	if err != nil {
		t.Errorf("Invalid path regex %s", r.Requests[index-1].PathRegex)
	}

	assert(t, request.Method == r.Requests[index].Method, "Expected Method %s, got %s", r.Requests[index].Method, request.Method)
	assert(t, regex.MatchString(request.URL.Path), "Expected Path matching %s, got %s", r.Requests[index].PathRegex, request.URL.Path)

	if r.Requests[index].ResponseCode > 0 {
		w.WriteHeader(r.Requests[index].ResponseCode)
		w.Write([]byte(r.Requests[index].ResponseBody))
	}
}

func (r *requestHandler) Close(t *testing.T) {
	assert(t, r.index == len(r.Requests), "Not all requests received; only got %d", r.index)
}

func assert(t *testing.T, pass bool, format string, args ...interface{}) {
	if !pass {
		t.Errorf(format, args...)
	}
}

func makeServer(t *testing.T, h *requestHandler) *httptest.Server {
	return httptest.NewServer(http.HandlerFunc(func (w http.ResponseWriter, request *http.Request) {
		h.HandleRequest(t, request, w)
	}))
}

func TestCreateDatabase(t *testing.T) {
	createPath := fmt.Sprintf("/database/%s/plocal", dbName)

	requests := []request{
		{Method: "GET", PathRegex: connectPath, ResponseCode: http.StatusNotFound}, // connect; return failure
		{Method: "POST", PathRegex: createPath, ResponseCode: http.StatusOK}} // create database; return success
	handler := requestHandler{Requests: requests}
	defer handler.Close(t)

	server := makeServer(t, &handler)

	_, err := NewClient(server.URL, dbName, "test", "test")
	assert(t, err == nil, "Error encountered while creating client")
}

func TestFailedCreateDatabase(t *testing.T) {
	createPath := fmt.Sprintf("/database/%s/plocal", dbName)

	requests := []request{
		{Method: "GET", PathRegex: connectPath, ResponseCode: http.StatusNotFound}, // connect; return failure
		{Method: "POST", PathRegex: createPath, ResponseCode: http.StatusInternalServerError}} // create database; return failure
	handler := requestHandler{Requests: requests}
	defer handler.Close(t)

	server := makeServer(t, &handler)

	_, err := NewClient(server.URL, dbName, "test", "test")
	assert(t, err != nil, "No error occurred while creating client")
}

func TestConnectToDatabase(t *testing.T) {
	requests := []request{
		{Method: "GET", PathRegex: connectPath, ResponseCode: http.StatusNoContent}} // connect; return success
	handler := requestHandler{Requests: requests}
	defer handler.Close(t)

	server := makeServer(t, &handler)

	_, err := NewClient(server.URL, dbName, "test", "test")
	assert(t, err == nil, "Error encountered while creating client")
}

func TestCreateClassNoSuperclass(t *testing.T) {
	className := "Testing"
	createPath := fmt.Sprintf("/command/%s/sql/CREATE CLASS %s", dbName, className)

	requests := []request{
		{Method: "GET", PathRegex: connectPath, ResponseCode: http.StatusNoContent}, // connect; return success
		{Method: "POST", PathRegex: createPath, ResponseCode: http.StatusOK}} // create class; return success
	handler := requestHandler{Requests: requests}
	defer handler.Close(t)

	server := makeServer(t, &handler)

	client, err := NewClient(server.URL, dbName, "test", "test")
	assert(t, err == nil, "Error encountered while creating client: %s", err)

	err = client.CreateClass(className, "")
	assert(t, err == nil, "Error encountered while creating class: %s", err)
}

func TestCreateClassWithSuperclass(t *testing.T) {
	className := "Testing"
	superclass := "V"
	createPath := fmt.Sprintf("/command/%s/sql/CREATE CLASS %s EXTENDS %s", dbName, className, superclass)

	requests := []request{
		{Method: "GET", PathRegex: connectPath, ResponseCode: http.StatusNoContent}, // connect; return success
		{Method: "POST", PathRegex: createPath, ResponseCode: http.StatusOK}} // create class; return success
	handler := requestHandler{Requests: requests}
	defer handler.Close(t)

	server := makeServer(t, &handler)

	client, err := NewClient(server.URL, dbName, "test", "test")
	assert(t, err == nil, "Error encountered while creating client: %s", err)

	err = client.CreateClass(className, superclass)
	assert(t, err == nil, "Error encountered while creating class: %s", err)
}

func TestAlterClass(t *testing.T) {
	className := "Testing"
	superclass := "V"
	alterPath := fmt.Sprintf("/command/%s/sql/ALTER CLASS %s SUPERCLASS %s", dbName, className, superclass)

	requests := []request{
		{Method: "GET", PathRegex: connectPath, ResponseCode: http.StatusNoContent}, // connect; return success
		{Method: "POST", PathRegex: alterPath, ResponseCode: http.StatusOK}} // create class; return success
	handler := requestHandler{Requests: requests}
	defer handler.Close(t)

	server := makeServer(t, &handler)

	client, err := NewClient(server.URL, dbName, "test", "test")
	assert(t, err == nil, "Error encountered while creating client: %s", err)

	err = client.AlterClass(className, "SUPERCLASS", superclass)
	assert(t, err == nil, "Error encountered while creating class: %s", err)
}

func TestAddPropertyRequiresLinkType(t *testing.T) {
	requests := []request{
		{Method: "GET", PathRegex: connectPath, ResponseCode: http.StatusNoContent}} // connect; return success
	handler := requestHandler{Requests: requests}
	defer handler.Close(t)

	server := makeServer(t, &handler)

	client, err := NewClient(server.URL, dbName, "test", "test")
	assert(t, err == nil, "Error encountered while creating client")

	err = client.CreateProperty("Testing", "Property", "LINK", "", make(map[string]string))
	assert(t, err != nil, "No error for type LINK")
	err = client.CreateProperty("Testing", "Property", "LINKLIST", "", make(map[string]string))
	assert(t, err != nil, "No error for type LINKLIST")
	err = client.CreateProperty("Testing", "Property", "LINKSET", "", make(map[string]string))
	assert(t, err != nil, "No error for type LINKSET")
	err = client.CreateProperty("Testing", "Property", "LINKMAP", "", make(map[string]string))
	assert(t, err != nil, "No error for type LINKMAP")
}

func TestCreatePropertyNoConstraints(t *testing.T) {
	className := "Testing"
	propName := "Prop1"
	propType := "STRING"
	addPath := fmt.Sprintf("/command/%s/sql/CREATE PROPERTY %s.%s %s", dbName, className, propName, propType)
	
	requests := []request{
		{Method: "GET", PathRegex: connectPath, ResponseCode: http.StatusNoContent}, // connect; return success
		{Method: "POST", PathRegex: addPath, ResponseCode: http.StatusOK}} // create property; return success
	handler := requestHandler{Requests: requests}
	defer handler.Close(t)

	server := makeServer(t, &handler)

	client, err := NewClient(server.URL, dbName, "test", "test")
	assert(t, err == nil, "Error encountered while creating client")

	err = client.CreateProperty(className, propName, propType, "", make(map[string]string))
	assert(t, err == nil, "Error encountered while creating property: %s", err)
}	

func TestCreateProperty(t *testing.T) {
	className := "Testing"
	propName := "Prop1"
	propType := "STRING"
	oneConstraint := map[string]string{"MANDATORY": "TRUE"}
	moreConstraints := map[string]string{"MANDATORY": "TRUE", "NOTNULL": "TRUE"}
	addPath1 := fmt.Sprintf("/command/%s/sql/CREATE PROPERTY %s\\.%s %s \\(MANDATORY TRUE\\)", dbName, className, propName, propType)
	addPath2 := fmt.Sprintf("^/command/%s/sql/CREATE PROPERTY %s\\.%s %s \\(((MANDATORY TRUE, NOTNULL TRUE)|(NOTNULL TRUE, MANDATORY TRUE))\\)$", dbName, className, propName, propType)
	
	requests := []request{
		{Method: "GET", PathRegex: connectPath, ResponseCode: http.StatusNoContent}, // connect; return success
		{Method: "POST", PathRegex: addPath1, ResponseCode: http.StatusOK}, // create property 1; return success
		{Method: "POST", PathRegex: addPath2, ResponseCode: http.StatusOK}} // create property 2; return success 
	handler := requestHandler{Requests: requests}
	defer handler.Close(t)

	server := makeServer(t, &handler)

	client, err := NewClient(server.URL, dbName, "test", "test")
	assert(t, err == nil, "Error encountered while creating client")

	err = client.CreateProperty(className, propName, propType, "", oneConstraint)
	assert(t, err == nil, "Error encountered while creating property 1: %s", err)
	err = client.CreateProperty(className, propName, propType, "", moreConstraints)
	assert(t, err == nil, "Error encountered while creating property 2: %s", err)
}

func TestCreateVertex(t *testing.T) {
	className := "Testing"
	properties := "{\"Prop1\": \"Hello\"}"
	rid := "#21:0"
	responseBody := fmt.Sprintf("{\"@rid\": \"%s\"}", rid)
	createPath := fmt.Sprintf("/command/%s/sql/CREATE VERTEX %s CONTENT %s", dbName, className, properties)

	requests := []request{
		{Method: "GET", PathRegex: connectPath, ResponseCode: http.StatusNoContent}, // connect; return success
		{Method: "POST", PathRegex: createPath, ResponseCode: http.StatusOK, ResponseBody: responseBody}} // create vertex; return success
	handler := requestHandler{Requests: requests}
	defer handler.Close(t)

	server := makeServer(t, &handler)
	
	client, err := NewClient(server.URL, dbName, "test", "test")
	assert(t, err == nil, "Error encountered while creating client: %s", err)

	createdRid, err := client.CreateVertex(className, properties)
	assert(t, err == nil, "Error encountered while creating client: %s", err)
	assert(t, createdRid == rid, "Expected rid %s, got %s", rid, createdRid)
}

func TestCreateVertexNoProps(t *testing.T) {
	className := "Testing"
	rid := "#21:0"
	responseBody := fmt.Sprintf("{\"@rid\": \"%s\"}", rid)
	createPath := fmt.Sprintf("/command/%s/sql/CREATE VERTEX %s", dbName, className)

	requests := []request{
		{Method: "GET", PathRegex: connectPath, ResponseCode: http.StatusNoContent}, // connect; return success
		{Method: "POST", PathRegex: createPath, ResponseCode: http.StatusOK, ResponseBody: responseBody}} // create vertex; return success
	handler := requestHandler{Requests: requests}
	defer handler.Close(t)

	server := makeServer(t, &handler)
	
	client, err := NewClient(server.URL, dbName, "test", "test")
	assert(t, err == nil, "Error encountered while creating client: %s", err)

	createdRid, err := client.CreateVertex(className, "")
	assert(t, err == nil, "Error encountered while creating client: %s", err)
	assert(t, createdRid == rid, "Expected rid %s, got %s", rid, createdRid)
}

func TestCreateEdge(t *testing.T) {
	className := "Testing"
	properties := "{\"Prop1\": \"Hello\"}"
	rid := "#21:0"
	from, to := "#20:0", "#22:0"
	responseBody := fmt.Sprintf("{\"@rid\": \"%s\"}", rid)
	createPath := fmt.Sprintf("/command/%s/sql/CREATE EDGE %s FROM %s TO %s CONTENT %s", dbName, className, from, to, properties)

	requests := []request{
		{Method: "GET", PathRegex: connectPath, ResponseCode: http.StatusNoContent}, // connect; return success
		{Method: "POST", PathRegex: createPath, ResponseCode: http.StatusOK, ResponseBody: responseBody}} // create vertex; return success
	handler := requestHandler{Requests: requests}
	defer handler.Close(t)

	server := makeServer(t, &handler)

	client, err := NewClient(server.URL, dbName, "test", "test")
	assert(t, err == nil, "Error encountered while creating client: %s", err)

	createdRid, err := client.CreateEdge(className, from, to, properties)
	assert(t, err == nil, "Error encountered while creating client: %s", err)
	assert(t, createdRid == rid, "Expected rid %s, got %s", rid, createdRid)
}

func TestCreateEdgeNoProps(t *testing.T) {
	className := "Testing"
	rid := "#21:0"
	from, to := "#20:0", "#22:0"
	responseBody := fmt.Sprintf("{\"@rid\": \"%s\"}", rid)
	createPath := fmt.Sprintf("/command/%s/sql/CREATE EDGE %s FROM %s TO %s", dbName, className, from, to)

	requests := []request{
		{Method: "GET", PathRegex: connectPath, ResponseCode: http.StatusNoContent}, // connect; return success
		{Method: "POST", PathRegex: createPath, ResponseCode: http.StatusOK, ResponseBody: responseBody}} // create vertex; return success
	handler := requestHandler{Requests: requests}
	defer handler.Close(t)

	server := makeServer(t, &handler)

	client, err := NewClient(server.URL, dbName, "test", "test")
	assert(t, err == nil, "Error encountered while creating client: %s", err)

	createdRid, err := client.CreateEdge(className, from, to, "")
	assert(t, err == nil, "Error encountered while creating client: %s", err)
	assert(t, createdRid == rid, "Expected rid %s, got %s", rid, createdRid)
}