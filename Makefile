.PHONY: setup lint run test

HOST_UID := $(shell id -u)
HOST_GID := $(shell id -g)
COMPOSE := LOCAL_UID=$(HOST_UID) LOCAL_GID=$(HOST_GID) docker compose

setup:
	$(COMPOSE) build

lint:
	$(COMPOSE) run --rm app bundle exec rubocop

run:
	$(COMPOSE) run --rm app bundle exec ruby app.rb

test:
	$(COMPOSE) run --rm app bundle exec rspec
