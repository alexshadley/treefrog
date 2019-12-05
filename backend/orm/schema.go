package orm

import (
	"errors"
	"math/big"
	"reflect"
	"strings"
	"time"
)

type PropertyType string

type Vertex struct {}
type Edge struct {}

const (
	BOOLEAN PropertyType = "BOOLEAN"
	SHORT = "SHORT"
	DATETIME = "DATETIME"
	BYTE = "BYTE"
	INTEGER = "INTEGER"
	LONG = "LONG"
	STRING = "STRING"
	LINK = "LINK"
	DECIMAL = "DECIMAL"
	DOUBLE = "DOUBLE"
	FLOAT = "FLOAT"
	BINARY = "BINARY"
	LINKLIST = "LINKLIST"
	LINKSET = "LINKSET"
	LINKMAP = "LINKMAP"
)

func goTypeToValueType(propType reflect.Type) (PropertyType, error) {
	var int16Val int16
	var timeVal time.Time
	var int8Val int8
	var int32Val int32
	var int64Val int64
	var stringVal string
	var bigFloatVal big.Float
	var float64Val float64
	var float32Val float32
	var binaryVal []byte
	switch propType {
		case reflect.TypeOf(false):
			return BOOLEAN, nil
		case reflect.TypeOf(int16Val):
			return SHORT, nil
		case reflect.TypeOf(timeVal):
			return DATETIME, nil
		case reflect.TypeOf(int8Val):
			return BYTE, nil
		case reflect.TypeOf(int32Val):
			return INTEGER, nil
		case reflect.TypeOf(int64Val):
			return LONG, nil
		case reflect.TypeOf(stringVal):
			return STRING, nil
		case reflect.TypeOf(bigFloatVal):
			return DECIMAL, nil
		case reflect.TypeOf(float64Val):
			return DOUBLE, nil
		case reflect.TypeOf(float32Val):
			return FLOAT, nil
		case reflect.TypeOf(binaryVal):
			return BINARY, nil
		default:
			return "", errors.New("Invalid type")
	}
}

func goTypeToLinkType(propType reflect.Type) (PropertyType, reflect.Type, error) {
	switch propType.Kind() {
		case reflect.Array:
			fallthrough
		case reflect.Slice:
			return LINKLIST, propType.Elem(), nil
		case reflect.Map:
			valueType := propType.Elem()
			if valueType == reflect.TypeOf(false) {
				return LINKSET, propType.Key(), nil
			} else {
				return LINKMAP, propType.Elem(), nil
			}
		case reflect.Ptr:
			return LINK, propType.Elem(), nil
		default:
			return "", reflect.TypeOf(false), errors.New("Invalid link type")
	}
}

func paramToDbProperty(param string) (string, error) {
	param = strings.ToLower(param)
	m := map[string]string{
		"notnull": "NOTNULL",
		"min": "MIN",
		"max": "MAX",
		"regex": "REGEXP",
		"mandatory": "MANDATORY",
		"from_vertex": "from_vertex",
		"to_vertex": "to_vertex" }

	val, ok := m[param]
	if ok {
		return val, nil
	} else {
		return val, errors.New("Invalid parameter.")
	}
}

func parseTag(tag string) (map[string]string, error) {
	if len(tag) == 0 {
		return make(map[string]string), errors.New("No tag present on field")
	}

	split := strings.Split(tag[1:], "&")
	params := make(map[string]string)

	for i := range split {
		s := strings.Split(split[i], "=")
		if len(s) < 2 {
			return params, errors.New("Invalid tag format")
		}

		if prop, err := paramToDbProperty(s[0]); err != nil {
			return params, err
		} else {
			params[prop] = strings.ToUpper(s[1])
		}
	}

	return params, nil
}

func makeValueTypes(classes []interface{}, client Client) error {
	for i := range classes {
		class := reflect.TypeOf(classes[i])
		
		t, err := getEmbeddedType(class)
		if err != nil {
			return err
		}

		t_string := "V"
		if t == reflect.TypeOf(Edge{}) {
			t_string = "E"
		}

		err = client.CreateClass(class.Name(), t_string)
		if err != nil {
			return err
		}

		for j := 0; j < class.NumField(); j++ {
			tag := string(class.Field(j).Tag)
			tagMap, err := parseTag(tag)

			if err != nil && class.Field(j).Anonymous {
				// this is the embedded type
				continue
			}

			propType, err := goTypeToValueType(class.Field(j).Type)

			// The property is not a value type. These will be created later
			// Link properties can't be created now because the linked class
			// might not exist.
			if err != nil {
				continue
			}

			err = client.AddProperty(class.Name(), class.Field(j).Name, string(propType), "", tagMap)
			if err != nil {
				return err
			}
		}
	}

	return nil
}

func makeLinkTypes(classes []interface{}, client Client) (error) {
	for i := range classes {
		class := reflect.TypeOf(classes[i])
		for j := 0; j < class.NumField(); j++ {
			tag := string(class.Field(j).Tag)
			tagMap, err := parseTag(tag)
			propType, linkType, err := goTypeToLinkType(class.Field(j).Type)

			// It's a value type, so we already added it.
			if err != nil {
				continue
			} else if val, ok := tagMap["from_vertex"]; val == "TRUE" && ok {
				continue
			} else if val, ok := tagMap["to_vertex"]; val == "TRUE" && ok {
				continue
			}

			err = client.AddProperty(class.Name(), class.Field(j).Name, string(propType), linkType.Name(), tagMap)
			if err != nil {
				return err
			}
		}
	}

	return nil
}

func CreateSchema(classes []interface{}, client Client) (error) {
	err := makeValueTypes(classes, client)
	if err != nil {
		return err
	}

	err = makeLinkTypes(classes, client)
	return err
}

func getEmbeddedType(t reflect.Type) (reflect.Type, error) {
	for i := 0; i < t.NumField(); i++ {
		if t.Field(i).Type == reflect.TypeOf(Vertex{}) {
			return reflect.TypeOf(Vertex{}), nil
		} else if t.Field(i).Type == reflect.TypeOf(Edge{}) {
			return reflect.TypeOf(Edge{}), nil
		}
	}

	// reflect.TypeOf("") is arbitrary
	return reflect.TypeOf(""), errors.New("No embedded type present")
}