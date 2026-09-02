.DEFAULT_GOAL := help

.PHONY: help setup db-migrate db-rollback lint run test

HOST_UID := $(shell id -u)
HOST_GID := $(shell id -g)
COMPOSE := LOCAL_UID=$(HOST_UID) LOCAL_GID=$(HOST_GID) docker compose

help:
	@printf '%s\n' \
		'Available commands:' \
		'  make setup        Build the environment and prepare the database' \
		'  make db-migrate   Run pending database migrations' \
		'  make db-rollback  Roll back the latest database migration' \
		'  make test         Run the complete test suite' \
		'  make lint         Check Ruby and RSpec style' \
		'  make run          Run the example application'

setup:
	$(COMPOSE) build
	$(COMPOSE) up --detach --wait db
	$(COMPOSE) run --rm --no-deps app bundle exec rake db:create db:migrate

db-migrate:
	$(COMPOSE) run --rm app bundle exec rake db:migrate

db-rollback:
	$(COMPOSE) run --rm app bundle exec rake db:rollback

lint:
	$(COMPOSE) run --rm app bundle exec rubocop

run:
	$(COMPOSE) run --rm app bundle exec ruby app.rb

test:
	$(COMPOSE) run --rm app bundle exec rspec
