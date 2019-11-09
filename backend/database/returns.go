package database

import (
	"github.com/alexshadley/treefrog/model"
)

type userReturn struct {
	op []struct {
		Email string
		Name string
		Password string
		Loginmethod string
		Frog []struct {
			Name string
		}
	}
}

func (ur userReturn) ToUser() model.User {
	res := ur.op[0]
	var frog model.Frog = res.Frog[0]
	var user model.User = model.User{
		Email: res.Email,
		Name: res.Name,
		Password: res.Password,
		Loginmethod: res.Loginmethod,
		Frog: frog }

	return user
}

