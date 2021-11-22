PORT = 8050
PYTHON = python3

.PHONY: help http

.DEFAULT_GOAL := help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

http: ## Run http server
	$(PYTHON) -m http.server $(PORT)
