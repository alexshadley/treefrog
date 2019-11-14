package database

import (
	"errors"
	"math/big"
	"reflect"
	"strings"
	"time"
)

type PropertyType string

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
			// reflect.TypeOf(false) is just an arbitrary return value
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

/*func linkTypeToGoType(propType PropertyType, linkName string, classes map[string]reflect.Type) (reflect.Type, error) {
	linkStruct, ok := classes[linkName]
	if !ok {
		// reflect.TypeOf(false) is just an arbitrary return value
		return reflect.TypeOf(false), errors.New("Invalid type link type " + linkName + ".")
	}

	linkType := reflect.PtrTo(reflect.TypeOf(linkStruct))

	switch propType {
		case LINK:
			return linkType, nil
		case LINKLIST:
			return reflect.SliceOf(linkType), nil
		case LINKSET:
			return reflect.MapOf(linkType, reflect.TypeOf(false)), nil
		case LINKMAP:
			return reflect.MapOf(reflect.TypeOf(""), linkType), nil
		default:
			// reflect.TypeOf(false) is just an arbitrary return value
			return reflect.TypeOf(false), errors.New("Invalid property type " + string(propType))
	}
}*/

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