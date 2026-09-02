.DEFAULT_GOAL := help

.PHONY: help setup lint run test

HOST_UID := $(shell id -u)
HOST_GID := $(shell id -g)
COMPOSE := LOCAL_UID=$(HOST_UID) LOCAL_GID=$(HOST_GID) docker compose

help:
	@printf '%s\n' \
		'Available commands:' \
		'  make setup  Build the development environment' \
		'  make test   Run the complete test suite' \
		'  make lint   Check Ruby and RSpec style' \
		'  make run    Run the example application'

setup:
	$(COMPOSE) build

lint:
	$(COMPOSE) run --rm app bundle exec rubocop

run:
	$(COMPOSE) run --rm app bundle exec ruby app.rb

test:
	$(COMPOSE) run --rm app bundle exec rspec
