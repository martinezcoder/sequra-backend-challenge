.DEFAULT_GOAL := help

.PHONY: console help setup db-migrate db-rollback lint load-merchants run shell test

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
		'  make load-merchants FILE=path/to/merchants.csv' \
		'                    Import merchants from a CSV file' \
		'  make shell        Open a shell in the application container' \
		'  make console      Open a Ruby console with the application loaded' \
		'  make run          Run the example application'

console:
	$(COMPOSE) run --rm app bundle exec irb -r ./config/environment

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

load-merchants:
	@test -n "$(FILE)" || (printf '%s\n' 'FILE is required'; exit 1)
	$(COMPOSE) run --rm app bundle exec ruby bin/load_merchants "$(FILE)"

run:
	$(COMPOSE) run --rm app bundle exec ruby app.rb

shell:
	$(COMPOSE) run --rm app sh

test:
	$(COMPOSE) run --rm -e APP_ENV=test app sh -c 'bundle exec rake db:create db:migrate && bundle exec rspec'
