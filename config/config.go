package config

import (
	"time"
)

type Config struct {
	Port         int           `env:"PORT" envDefault:"8000"`
	MongoURL     string        `env:"MONGO_URL,required"`
	MongoDBName  string        `env:"MONGO_DB_NAME" envDefault:"payments"`
	MongoColName string        `env:"MONGO_COL_NAME" envDefault:"payments"`
	MongoTimeout time.Duration `env:"MONGO_TIMEOUT" envDefault:"100ms"`
}
