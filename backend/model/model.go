package model


type LoginMethod string

type User struct {
	FirstName string "?notnull=true&mandatory=true"
	LastName string "?notnull=true&mandatory=true"
	Email string "?notnull=true&mandatory=true"
	Password string "?notnull=true&mandatory=true"
	Frog *Frog "?notnull=true&mandatory=true"
	LoginMethod string "?notnull=true&mandatory=true"
}

type Frog struct {
	Name string "?notnull=true&mandatory=true"
}