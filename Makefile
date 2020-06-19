SHELL := /usr/bin/env bash

# see https://devcenter.heroku.com/articles/heroku-cli to install
.PHONY: setup
setup:
	heroku login
	heroku stack:set container -a $(APP)

.PHONY: push
push:
	heroku container:login
	docker build -t registry.heroku.com/$(APP)/web .
	docker push registry.heroku.com/$(APP)/web
	heroku container:release web -a $(APP)