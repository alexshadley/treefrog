package model

import (
	"time"

	"github.com/alexshadley/treefrog/orm"
)

type LoginMethod string

type User struct {
	orm.Vertex
	FirstName string "?notnull=true&mandatory=true"
	LastName string "?notnull=true&mandatory=true"
	Email string "?notnull=true&mandatory=true"
	Password string "?notnull=true&mandatory=true"
	Frog *Frog "?notnull=true&mandatory=true"
	LoginMethod string "?notnull=true&mandatory=true"
}

type Frog struct {
	orm.Vertex
	Name string "?notnull=true&mandatory=true"
}

type Transfer struct {
	orm.Edge
	Date time.Time "?notnull=true&mandatory=true"
	Initiator *User "?from_vertex=true&mandatory=true"
	Acceptor *User "?to_vertex=true&mandatory=true"
}