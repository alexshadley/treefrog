package database

import (
	"errors"
	"fmt"
	"io"
	"io/ioutil"
	"net/http"
	"net/url"
	"regexp"
	"strings"
)

type OrientClient struct {
	BaseUrl string
	Client http.Client
	Username string
	Password string
	Database string
}

var ridRegex *regexp.Regexp = regexp.MustCompile("\"@rid\":\"([#:\\d]+)\"")

func (o *OrientClient) makeReq(method, url string, body io.Reader, successResp int) (*http.Response, error) {
	req, err := http.NewRequest(method, url, body)
	if err != nil {
		return nil, err
	}
	req.SetBasicAuth(o.Username, o.Password)
	resp, err := o.Client.Do(req)

	if err == nil && resp.StatusCode != successResp {
		err = errors.New("Non-success response " + resp.Status)
	}

	return resp, err
}

func NewOrientClient(baseurl, database, username, password string) (OrientClient, error) {
	if !strings.HasPrefix(baseurl, "http://") {
		baseurl = "http://" + baseurl
	}

	client := http.Client{}

	url := fmt.Sprintf("%s/connect/%s", baseurl, database)
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return OrientClient{}, err
	}

	req.SetBasicAuth(username, password)
	resp, err := client.Do(req)

	orientClient := OrientClient{BaseUrl: baseurl, Client: client, Username: username, Password: password, Database: database}

	if err != nil || resp.StatusCode != 204 {
		err = orientClient.CreateDatabase("plocal")
		if err != nil {
			return orientClient, errors.New("Can't connect to database")
		}
	}
	
	return orientClient, nil
}

func (o *OrientClient) CreateDatabase(storagetype string) error {
	storagetype = strings.ToLower(storagetype)
	if storagetype != "plocal" && storagetype != "memory" {
		return errors.New("Invalid storage type")
	}

	url := fmt.Sprintf("%s/database/%s/%s", o.BaseUrl, o.Database, storagetype)
	_, err := o.makeReq("POST", url, nil, 200)
	return err
}

func (o *OrientClient) CreateClass(name, superclass string) error {
	var command string
	if superclass == "" {
		command = fmt.Sprintf("CREATE CLASS %s", name)
	} else {
		command = fmt.Sprintf("CREATE CLASS %s EXTENDS %s", name, superclass)
	}
	
	url := fmt.Sprintf("%s/command/%s/sql/%s", o.BaseUrl, o.Database, command)
	fmt.Println(command)
	_, err := o.makeReq("POST", url, nil, 200)
	return err
}

func (o *OrientClient) AlterClass(name, attribute, attributeValue string) error {
	command := fmt.Sprintf("ALTER CLASS %s %s %s", name, attribute, attributeValue)
	fmt.Println(command)
	url := fmt.Sprintf("%s/command/%s/sql/%s", o.BaseUrl, o.Database, command)
	_, err := o.makeReq("POST", url, nil, 200)
	return err
}

func (o *OrientClient) AddProperty(class, name string, propertyType PropertyType, linkType string, constraints map[string]string) error {
	iscontainer := strings.HasPrefix(string(propertyType), "LINK") || strings.HasPrefix(string(propertyType), "LINK")
	if iscontainer && linkType == "" {
		return errors.New("Must supply linkType for container-type properties")
	}

	command := fmt.Sprintf("CREATE PROPERTY %s.%s %s", class, name, propertyType)
	if iscontainer {
		command += " " + linkType
	}

	first := true
	for k, v := range constraints {
		if first {
			command += " (" + k + " " + v
			first = false
		} else {
			command += ", " + k + " " + v
		}
	}
	
	if len(constraints) > 0 {
		command += ")"
	}

	url := fmt.Sprintf("%s/command/%s/sql/%s", o.BaseUrl, o.Database, command)
	_, err := o.makeReq("POST", url, nil, 200)
	return err
}

func findRid(response string) string {
	return ridRegex.FindStringSubmatch(response)[1]
}

func (o *OrientClient) CreateVertex(class string, properties string) (string, error) {
	command := fmt.Sprintf("CREATE VERTEX %s CONTENT %s", class, properties)
	cmdUrl := fmt.Sprintf("%s/command/%s/sql/%s", o.BaseUrl, o.Database, url.PathEscape(command))
	resp, err := o.makeReq("POST", cmdUrl, nil, 200)

	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}

	return findRid(string(body)), nil
}