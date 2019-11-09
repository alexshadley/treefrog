package database

import (
	"google.golang.org/grpc/encoding/gzip"
	"context"
	"encoding/json"
	"fmt"
	"github.com/dgraph-io/dgo/v2"
	"github.com/dgraph-io/dgo/v2/protos/api"
	"google.golang.org/grpc"
	"github.com/alexshadley/treefrog/model"
)

type Dgraph struct {
	graph *dgo.Dgraph
}

func (g Dgraph) CreateSchema() error {
	err := g.graph.Alter(context.Background(), &api.Operation{
		Schema: `
			type User {
				Email: string
				Name: string
				Password: string
				Frog: [Frog]
				Loginmethod: string
			}

			type Frog {
				Name: string
			}
			
			Email: string @index(exact, fulltext) .
			Frog: [uid] @reverse .
			`})
	return err
}

func (g Dgraph) AddUser(user model.User) error {
	txn := g.graph.NewTxn()
	defer txn.Discard(context.Background())

	encoded, err := json.Marshal(user)
	if err != nil {
		return err
	}

	_, err = txn.Mutate(context.Background(), &api.Mutation{SetJson: encoded, CommitNow: true})
	return err
}

func (g Dgraph) GetUser(email string) (model.User, error) {
	query := fmt.Sprintf(`
	{
		op(func: eq(Email, "%s")) {
			Email
			Name
			Password
			Loginmethod
			Frog {
				Name
			}
		}
	}
	`, email)

	txn := g.graph.NewReadOnlyTxn()
	resp, err := txn.Query(context.Background(), query)
	if err != nil {
		return model.User{}, err
	}

	res := userReturn{}
	err = json.Unmarshal(resp.GetJson(), &res)
	if err != nil {
		return model.User{}, err
	}
	return res.ToUser(), err
}

func MakeClient() (Dgraph, error) {
	dialOpts := append([]grpc.DialOption{},
			grpc.WithInsecure(),
			grpc.WithDefaultCallOptions(grpc.UseCompressor(gzip.Name)))
	d, err := grpc.Dial("localhost:9080", dialOpts...)
	if err != nil {
		return Dgraph{}, err
	}

	return Dgraph{graph: dgo.NewDgraphClient(api.NewDgraphClient(d))}, nil
}