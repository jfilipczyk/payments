package main_test

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/caarlos0/env"
	"github.com/tidwall/gjson"

	"github.com/DATA-DOG/godog"
	"github.com/DATA-DOG/godog/gherkin"

	"github.com/jfilipczyk/gomatch"
	"github.com/jfilipczyk/payments/config"
	"github.com/jfilipczyk/payments/model"
	"github.com/jfilipczyk/payments/server"
	"github.com/jfilipczyk/payments/test/util"
)

// server under test configuration
var cfg *config.Config

// server under tests
var srv *server.Server

// repository handle required for closing connection session
var repo *model.MongoRepository

// util for setup database state and the state assertions
var mongoClient *util.MongoClient

func TestMain(m *testing.M) {
	cfg = &config.Config{}
	err := env.Parse(cfg)
	if err != nil {
		log.Fatalf("Could not parse configuration: %s", err.Error())
	}

	repo, err := model.NewMongoRepository(cfg)
	if err != nil {
		log.Fatalf("Could not init mongo repository: %s", err.Error())
	}
	defer repo.Close()

	srv = server.NewServer(repo, cfg)

	mongoClient, err = util.NewMongoClient(cfg.MongoURL, cfg.MongoDBName, cfg.MongoTimeout)
	if err != nil {
		log.Fatalf("Could not init mongo client: %s", err.Error())
	}
	defer mongoClient.Close()

	status := godog.RunWithOptions("godog", func(s *godog.Suite) {
		HttpClientContext(s)
		DatabaseContext(s)
	}, godog.Options{
		Format: "pretty",
		Paths:  []string{"features"},
	})

	if st := m.Run(); st > status {
		status = st
	}
	os.Exit(status)
}

type httpClientContext struct {
	resp *httptest.ResponseRecorder
}

func (h *httpClientContext) resetResponse(interface{}) {
	h.resp = httptest.NewRecorder()
}

func (h *httpClientContext) iSendRequestTo(method, endpoint string) (err error) {
	req, err := http.NewRequest(method, endpoint, nil)
	if err != nil {
		return
	}

	// handle panic
	defer func() {
		switch t := recover().(type) {
		case string:
			err = fmt.Errorf(t)
		case error:
			err = t
		}
	}()

	srv.ServeHTTP(h.resp, req)
	return
}

func (h *httpClientContext) iSendRequestToWithBody(method, endpoint string, body *gherkin.DocString) (err error) {
	req, err := http.NewRequest(method, endpoint, strings.NewReader(body.Content))
	if err != nil {
		return
	}

	// handle panic
	defer func() {
		switch t := recover().(type) {
		case string:
			err = fmt.Errorf(t)
		case error:
			err = t
		}
	}()

	srv.ServeHTTP(h.resp, req)
	return
}

func (h *httpClientContext) responseCodeShouldBe(code int) error {
	if code != h.resp.Code {
		return fmt.Errorf("expected response code to be: %d, but actual is: %d", code, h.resp.Code)
	}
	return nil
}

func (h *httpClientContext) responseShouldMatchJSON(body *gherkin.DocString) error {
	actual := h.resp.Body.Bytes()
	expected := body.Content
	matcher := gomatch.NewDefaultJSONMatcher()
	ok, err := matcher.Match(string(expected), string(actual))
	if !ok {
		return err
	}
	return nil
}

func resetDatabase(interface{}) {
	if err := mongoClient.Drop(cfg.MongoColName); err != nil {
		panic(cfg.MongoColName)
	}
}

func databaseShouldHaveRecord(num int) (err error) {
	n, err := mongoClient.Count(cfg.MongoColName)
	if err != nil {
		return
	}
	if n != num {
		err = fmt.Errorf("expected %d record(s) but actual %d", num, n)
		return
	}
	return
}

func databaseContainsPayments(ids *gherkin.DataTable) error {
	err := mongoClient.Drop(cfg.MongoColName)
	if err != nil {
		return err
	}
	for _, r := range ids.Rows {
		for _, c := range r.Cells {
			path, err := filepath.Abs("./test/fixture/" + c.Value + ".json")
			if err != nil {
				return err
			}
			json, err := ioutil.ReadFile(path)
			if err != nil {
				return err
			}
			err = mongoClient.InsertJSON(cfg.MongoColName, string(json))
			if err != nil {
				return err
			}
		}
	}
	return nil
}

func databaseShouldHaveRecordWithIdAndValueUnderPath(id, value, path string) error {
	json, err := mongoClient.GetJSON(cfg.MongoColName, id)
	if err != nil {
		return fmt.Errorf("expected document with id %s to exist in database", id)
	}
	actual := gjson.Get(json, path).String()
	if actual != value {
		return fmt.Errorf("expected document with id %s to have value %s under path %s, but actual value: %s", id, value, path, actual)
	}
	return nil
}

func HttpClientContext(s *godog.Suite) {
	c := &httpClientContext{}

	s.BeforeScenario(c.resetResponse)

	s.Step(`^I send "(GET|PUT|DELETE)" request to "([^"]*)"$`, c.iSendRequestTo)
	s.Step(`^the response code should be (\d+)$`, c.responseCodeShouldBe)
	s.Step(`^the response body should match json:$`, c.responseShouldMatchJSON)
	s.Step(`^I send "([^"]*)" request to "([^"]*)" with body:$`, c.iSendRequestToWithBody)
}

func DatabaseContext(s *godog.Suite) {
	s.BeforeScenario(resetDatabase)

	s.Step(`^the database should have (\d+) records?$`, databaseShouldHaveRecord)
	s.Step(`^the database contains payments:$`, databaseContainsPayments)
	s.Step(`^the database should have record with id "([^"]*)" and value "([^"]*)" under path "([^"]*)"$`, databaseShouldHaveRecordWithIdAndValueUnderPath)
}
