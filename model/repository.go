package model

import (
	"errors"
)

// ErrNotFound should be returned by any Repository implementation when requested payment does not exist
var ErrNotFound = errors.New("payment not found")

// Repository is an abstraction for payment persistance
type Repository interface {
	Upsert(payment *Payment) error
	GetByID(id string) (*Payment, error)
	GetList() ([]*Payment, error)
	Delete(id string) error
}
