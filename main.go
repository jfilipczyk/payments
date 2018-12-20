package main

import (
	"github.com/caarlos0/env"
	"github.com/jfilipczyk/payments/config"
	"github.com/jfilipczyk/payments/model"
	"github.com/jfilipczyk/payments/server"
)

func main() {
	cfg := &config.Config{}
	err := env.Parse(cfg)
	if err != nil {
		panic(err)
	}
	repo, err := model.NewMongoRepository(cfg)
	if err != nil {
		panic(err)
	}
	defer repo.Close()

	srv := server.NewServer(repo, cfg)
	srv.Run()
}
