package main

import (
	"google.golang.org/grpc/encoding/gzip"
	"context"
	"fmt"
	"github.com/dgraph-io/dgo/v2"
	"github.com/dgraph-io/dgo/v2/protos/api"
	"google.golang.org/grpc"
)

type DGraph struct {
	graph *dgo.Dgraph
}

func (g DGraph) CreateSchema() error {
	err := g.graph.Alter(context.Background(), &api.Operation{
		Schema: `
			type User {
				email: string
				displayname: string
				password: string
				frog: [Frog]
				loginmethod: string
			}

			type Frog {
				name: string
			}
			
			email: string @index(exact, fulltext) .
			frog: [uid] @reverse .
			`})
	return err
}

func MakeClient() DGraph {
	dialOpts := append([]grpc.DialOption{},
			grpc.WithInsecure(),
			grpc.WithDefaultCallOptions(grpc.UseCompressor(gzip.Name)))
	d, err := grpc.Dial("localhost:9080", dialOpts...)
	if err != nil {
		fmt.Println("Error opening dgraph connection")
	}

	return DGraph{dgo.NewDgraphClient(api.NewDgraphClient(d))}
}