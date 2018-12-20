# Payments

Provides REST API for CRUD operations on payment entities

## Configuration

Application expects configuration provided as environment variables, available vars:

* `PORT` - app listen port, default `8000`
* `MONGO_URL` - URL to mongodb, **required**
* `MONGO_DB_NAME`, default `payments`
* `MONGO_COL_NAME`, default `payments`
* `MONGO_TIMEOUT`, default `100ms`
* `GIN_MODE`, default `debug`

## Run application

The easies way to start the app is to follow steps:

1. `docker-compose up -d`; starts mongodb server
2. `dep ensure`; installs dependencies
3. `MONGO_URL=mongodb://root:example@localhost:27017/admin go run main.go`; starts app on port 8000

To stop mongo `docker-compose stop`
To stop and remove container (and remove data) `docker-compose down`

## Run acceptance tests

To run acceptance tests follow steps:

1. `docker-compose up -d`; starts mongodb server
2. `dep ensure`; installs dependencies
3. `MONGO_URL=mongodb://root:example@localhost:27017/admin MONGO_DB_NAME=payments_test go test`; runs tests using `payments_test` database

## API spec

API specification can be found in `api/openapi.yml` and viewed with https://editor.swagger.io/