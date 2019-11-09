package model

type User struct {
	Email string
	Name string
	Password string
	Loginmethod string
	Frog Frog
}

type Frog struct {
	Name string
}