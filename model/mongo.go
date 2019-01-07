package model

import (
	"github.com/globalsign/mgo"
	"github.com/jfilipczyk/payments/config"
)

// MongoRepository is an implementation of Repository. It's an adapter for mgo.
type MongoRepository struct {
	ses *mgo.Session
	col *mgo.Collection
}

// NewMongoRepository creates new instance of a MongoRepository
func NewMongoRepository(cfg *config.Config) (*MongoRepository, error) {
	ses, err := mgo.DialWithTimeout(cfg.MongoURL, cfg.MongoTimeout)
	if err != nil {
		return nil, err
	}
	col := ses.DB(cfg.MongoDBName).C(cfg.MongoColName)
	return &MongoRepository{ses, col}, nil
}

// Close closes connection session
func (r *MongoRepository) Close() {
	r.ses.Close()
}

// Upsert adds/updates given payment
func (r *MongoRepository) Upsert(payment *Payment) error {
	_, err := r.col.UpsertId(payment.ID, payment)
	return err
}

// GetByID returns payment by given id. ErrNotFound is returned if payment does not exist.
func (r *MongoRepository) GetByID(id string) (*Payment, error) {
	payment := &Payment{}
	err := r.col.FindId(id).One(payment)
	if err == mgo.ErrNotFound {
		return nil, ErrNotFound
	}
	return payment, err
}

// GetList returns list of payments
func (r *MongoRepository) GetList() ([]*Payment, error) {
	list := make([]*Payment, 0)
	err := r.col.Find(nil).Sort("_id").All(&list)
	return list, err
}

// Delete deletes payment wth given id. Action is idempotent.
func (r *MongoRepository) Delete(id string) error {
	err := r.col.RemoveId(id)
	// delete is idempotent so "not found" is not an error
	if err == mgo.ErrNotFound {
		return nil
	}
	return err
}
