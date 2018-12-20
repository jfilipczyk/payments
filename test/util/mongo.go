package util

import (
	"time"

	"github.com/globalsign/mgo"
	"github.com/globalsign/mgo/bson"
)

type MongoClient struct {
	ses *mgo.Session
	db  *mgo.Database
}

func (m *MongoClient) InsertJSON(col, json string) (err error) {
	var bdoc interface{}
	err = bson.UnmarshalJSON([]byte(json), &bdoc)
	if err != nil {
		return
	}
	err = m.db.C(col).Insert(&bdoc)
	return
}

func (m *MongoClient) Count(col string) (int, error) {
	return m.db.C(col).Count()
}

func (m *MongoClient) Drop(col string) error {
	colNames, err := m.db.CollectionNames()
	if err != nil {
		return err
	}
	for _, name := range colNames {
		if name == col {
			return m.db.C(col).DropCollection()
		}
	}
	return nil
}

func (m *MongoClient) GetJSON(col, id string) (string, error) {
	var doc interface{}
	err := m.db.C(col).FindId(id).One(&doc)
	if err != nil {
		return "", err
	}
	json, err := bson.MarshalJSON(doc)
	if err != nil {
		return "", err
	}
	return string(json), nil
}

func (m *MongoClient) Close() {
	m.ses.Close()
}

func NewMongoClient(url, dbName string, timeout time.Duration) (*MongoClient, error) {
	ses, err := mgo.DialWithTimeout(url, timeout)
	if err != nil {
		return nil, err
	}
	db := ses.DB(dbName)
	return &MongoClient{ses, db}, nil
}
