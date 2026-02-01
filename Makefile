SHELL := $(shell which bash)

.DEFAULT_GOAL := help

.PHONY: clean-test test build run-backend run-frontend run-solution

help:
	@echo -e ""
	@echo -e "Make commands:"
	@grep -E '^[a-zA-Z_-]+:.*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":"}; {printf "\t\033[36m%-30s\033[0m\n", $$1}'
	@echo -e ""

# #########################
# Base commands
# #########################

clean-tests:
	go clean -testcache

tests: clean-tests
	go test ./...

slow-tests: clean-tests
	@docker compose -f docker/docker-compose.yml build
	@docker compose -f docker/docker-compose.yml up -d
	@go test ./integrationTests/... -v -timeout 40m
	@docker compose -f docker/docker-compose.yml down -v

binary-crypto-payments = crypto-payments-server

build-crypto-payments:
	go build -v \
	-o ${binary-crypto-payments} \
	-ldflags="-X main.appVersion=$(shell git describe --tags --long --dirty) -X main.commitID=$(shell git rev-parse HEAD)"

run-crypto-payments: build-crypto-payments
	./${binary-crypto-payments} --log-level="*:DEBUG"

lint-install:
ifeq (,$(wildcard test -f bin/golangci-lint))
	@echo "Installing golint"
	curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s
endif

run-lint:
	@echo "Running golint"
	bin/golangci-lint run --max-issues-per-linter 0 --max-same-issues 0 --timeout=2m
