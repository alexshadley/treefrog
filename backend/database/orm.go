package database

import (
	"errors"
	"fmt"
	"math/big"
	"reflect"
	"strings"
	"time"
)

type PropertyType string

type session struct {
	vertices []reflect.Value
	client OrientClient
}

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

func CreateSession(client OrientClient) session {
	return session{client: client}
}

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
		"mandatory": "MANDATORY" }

	val, ok := m[param]
	if ok {
		return val, nil
	} else {
		return val, errors.New("Invalid parameter.")
	}
}

func parseTag(tag string) (map[string]string, error) {
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

func makeValueTypes(classes []interface{}, client OrientClient) (error) {
	for i := range classes {
		class := reflect.TypeOf(classes[i])
		
		// All classes will be vertices for now
		err := client.CreateClass(class.Name(), "V")
		if err != nil {
			return err
		}

		for j := 0; j < class.NumField(); j++ {
			tag := string(class.Field(j).Tag)
			tagMap, err := parseTag(tag)

			propType, err := goTypeToValueType(class.Field(j).Type)

			// The property is not a value type. These will be created later
			// Link properties can't be created now because the linked class
			// might not exist.
			if err != nil {
				continue
			}

			err = client.AddProperty(class.Name(), class.Field(j).Name, propType, "", tagMap)
			if err != nil {
				return err
			}
		}
	}

	return nil
}

func makeLinkTypes(classes []interface{}, client OrientClient) (error) {
	for i := range classes {
		class := reflect.TypeOf(classes[i])
		for j := 0; j < class.NumField(); j++ {
			tag := string(class.Field(j).Tag)
			tagMap, err := parseTag(tag)

			propType, linkType, err := goTypeToLinkType(class.Field(j).Type)

			// It's a value type, so we already added it.
			if err != nil {
				continue
			}

			err = client.AddProperty(class.Name(), class.Field(j).Name, propType, linkType.Name(), tagMap)
			if err != nil {
				return err
			}
		}
	}

	return nil
}

func CreateSchema(classes []interface{}, client OrientClient) (error) {
	err := makeValueTypes(classes, client)
	if err != nil {
		return err
	}

	err = makeLinkTypes(classes, client)
	return err
}

func (s *session) CreateVertex(v interface{}) {
	s.vertices = append(s.vertices, reflect.ValueOf(v))
}

func (s *session) indexOf(v reflect.Value) int {
	for i := 0; i < len(s.vertices); i++ {
		if reflect.DeepEqual(v.Interface(), s.vertices[i].Interface()) {
			return i
		}
	}

	return -1
}

/* NOTE: This assumes there are no reference cycles */
func (s *session) commitVertex(value reflect.Value, visited []bool) string {
	visited[s.indexOf(value)] = true
	t := value.Type()
	jsonString := "{"

	for i := 0; i < value.NumField(); i++ {
		field := value.Field(i)
		name := t.Field(i).Name
		kind := field.Kind()

		if i > 0 {
			jsonString += ", "
		}
		jsonString += "\"" + name + "\": "

		if kind == reflect.Ptr {
			rid := s.commitVertex(field.Elem(), visited)
			jsonString += rid
		} else if kind == reflect.Map && field.Elem().Kind() != reflect.Bool {
			iter := field.MapRange()
			mapString := "{"
			for end := iter.Next(); end; {
				rid := s.commitVertex(iter.Value().Elem(), visited)
				if len(mapString) > 1 {
					mapString += ", "
				}
				mapString += "\"" + iter.Key().String() + "\": " + rid
			}
			jsonString += mapString + "}"
		} else if kind == reflect.Slice || kind == reflect.Array {
			listString := "["
			for i := 0; i < field.Len(); i++ {
				rid := s.commitVertex(field.Index(i).Elem(), visited)
				if len(listString) > 1 {
					listString += ", "
				}
				listString += rid
			}
			jsonString += listString + "]"
		} else if kind == reflect.Map {
			setString := "["
			iter := field.MapRange()
			for end := iter.Next(); end; {
				rid := s.commitVertex(iter.Key().Elem(), visited)
				if len(setString) > 1 {
					setString += ", "
				}
				setString += rid
			}
			jsonString += setString + "]"
		} else {
			if field.Type().Kind() == reflect.String {
				jsonString += "\"" + fmt.Sprint(field) + "\""
			} else {
				jsonString += fmt.Sprint(field)
			}
		}
	}
	jsonString += "}"

	rid, err := s.client.CreateVertex(t.Name(), jsonString)
	if err != nil {
		fmt.Println(err)
	}

	return rid
}

/* NOTE: This assumes there are no reference cycles */
func (s *session) Commit() {
	visited := make([]bool, len(s.vertices), len(s.vertices))
	for i := 0; i < len(s.vertices); i++ {
		if !visited[i] {
			s.commitVertex(s.vertices[i], visited)
		}
	}
}