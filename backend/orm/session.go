package orm

import (
	"fmt"
	"reflect"
	"time"
)

type session struct {
	objects []reflect.Value
	client Client
}

func CreateSession(client Client) session {
	return session{client: client}
}

func (s *session) CreateObject(v interface{}) {
	s.objects = append(s.objects, reflect.ValueOf(v))
}

/* NOTE: This assumes there are no reference cycles */
func (s *session) Commit() error {
	rids := make([]string, len(s.objects), len(s.objects))
	for i := 0; i < len(s.objects); i++ {
		if rids[i] == "" {
			t, err := getEmbeddedType(s.objects[i].Type())
			if err != nil {
				return err
			} else if t == reflect.TypeOf(Vertex{}) {
				s.commitVertex(s.objects[i], rids)
			} else {
				s.commitEdge(s.objects[i], rids)
			}
		}
	}

	return nil
}

/* NOTE: This assumes there are no reference cycles */
func (s *session) commitVertex(value reflect.Value, rids []string) string {
	jsonString := s.jsonifyProperties(value, rids, []string{})
	rid, err := s.client.CreateVertex(value.Type().Name(), jsonString)
	if err != nil {
		fmt.Println(err)
	}

	rids[s.indexOf(value)] = rid
	return rid
}

func (s *session) commitEdge(value reflect.Value, rids []string) string {
	jsonString := s.jsonifyProperties(value, rids, []string{"from_vertex", "to_vertex"})
	from, to := "", ""

	for i := 0; i < value.NumField(); i++ {
		tagMap, _ := parseTag(string(value.Type().Field(i).Tag))

		if val, ok := tagMap["from_vertex"]; val == "TRUE" && ok {
			from = rids[s.indexOf(value.Field(i).Elem())]
			if from == "" {
				from = s.commitVertex(value.Field(i).Elem(), rids)
			}
		} else if val, ok := tagMap["to_vertex"]; val == "TRUE" && ok {
			to = rids[s.indexOf(value.Field(i).Elem())]
			if to == "" {
				to = s.commitVertex(value.Field(i).Elem(), rids)
			}
		}
	}

	rid, err := s.client.CreateEdge(value.Type().Name(), from, to, jsonString)
	if err != nil {
		fmt.Println(err)
	}

	rids[s.indexOf(value)] = rid
	return rid
}

func (s *session) jsonifyProperties(value reflect.Value, rids []string, ignoreTags []string) string {
	if index := s.indexOf(value); rids[index] != "" {
		return rids[index]
	}

	t := value.Type()
	jsonString := "{"

	for i := 0; i < value.NumField(); i++ {
		field := value.Field(i)
		name := t.Field(i).Name
		kind := field.Kind()

		if t.Field(i).Anonymous || shouldIgnore(string(t.Field(i).Tag), ignoreTags) {
			continue
		}

		if len(jsonString) > 1 {
			jsonString += ", "
		}
		jsonString += "\"" + name + "\": "

		switch kind {
			case reflect.Ptr:
				jsonString += s.commitPtr(field, rids)
			case reflect.Map:
				if field.Elem().Kind() != reflect.Bool {
					jsonString += s.commitMap(field, rids)
				} else {
					jsonString += s.commitSet(field, rids)
				}
			case reflect.Array:
				fallthrough
			case reflect.Slice:
				jsonString += s.commitList(field, rids)
			default:
				if needsQuote(field.Type()) {
					jsonString += "\"" + fmt.Sprint(field) + "\""
				} else {
					jsonString += fmt.Sprint(field)
				}
		}
	}

	return jsonString + "}"
}

func (s *session) indexOf(v reflect.Value) int {
	for i := 0; i < len(s.objects); i++ {
		if reflect.DeepEqual(v.Interface(), s.objects[i].Interface()) {
			return i
		}
	}

	return -1
}

func (s *session) commitPtr(m reflect.Value, rids []string) string {
	rid := rids[s.indexOf(m.Elem())]
	if rid == "" {
		rid = s.commitVertex(m.Elem(), rids)
	}

	return rid
}

func (s *session) commitMap(m reflect.Value, rids []string) string {
	iter := m.MapRange()
	mapString := "{"
	for end := iter.Next(); end; {
		rid := rids[s.indexOf(iter.Value().Elem())]

		if rid == "" {
			rid = s.commitVertex(iter.Value().Elem(), rids)
		}
		
		if len(mapString) > 1 {
			mapString += ", "
		}
		mapString += "\"" + iter.Key().String() + "\": " + rid
	}
	return mapString + "}"
}

func (s* session) commitList(l reflect.Value, rids []string) string {
	listString := "["
	for i := 0; i < l.Len(); i++ {
		rid := rids[s.indexOf(l.Index(i).Elem())]
		if rid == "" {
			rid = s.commitVertex(l.Index(i).Elem(), rids)
		}
		
		if len(listString) > 1 {
			listString += ", "
		}
		listString += rid
	}
	return listString + "]"
}

func (s *session) commitSet(set reflect.Value, rids []string) string {
	setString := "["
	iter := set.MapRange()
	for end := iter.Next(); end; {
		rid := rids[s.indexOf(iter.Key().Elem())]
		if rid == "" {
			s.commitVertex(iter.Key().Elem(), rids)
		}

		if len(setString) > 1 {
			setString += ", "
		}
		setString += rid
	}
	return setString + "]"
}

func needsQuote(t reflect.Type) bool {
	var timeVal time.Time
	var stringVal string
	return t == reflect.TypeOf(timeVal) || t == reflect.TypeOf(stringVal)
}

func shouldIgnore(tag string, ignoreTags []string) bool {
	tagMap, _ := parseTag(tag)
	for i := 0; i < len(ignoreTags); i++ {
		if _, ok := tagMap[ignoreTags[i]]; ok {
			return true
		}
	}

	return false
}