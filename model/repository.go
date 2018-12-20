package model

import (
	"errors"
)

var ErrNotFound = errors.New("payment not found")

type Repository interface {
	Upsert(payment *Payment) error
	GetByID(id string) (*Payment, error)
	GetList() ([]*Payment, error)
	Delete(id string) error
}
