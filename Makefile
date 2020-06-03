# COLORS
TARGET_MAX_CHAR_NUM := 10
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)

# The binary to build (just the basename).
BIN ?= haproxy-configuration-builder

ORG ?= vbouchaud

# This version-strategy uses git tags to set the version string
GIT_TAG := $(shell git describe --tags --always --dirty || echo unsupported)
GIT_COMMIT := $(shell git rev-parse --short HEAD || echo unsupported)
GIT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD 2>/dev/null)
GIT_BRANCH_CLEAN := $(shell echo $(GIT_BRANCH) | sed -e "s/[^[:alnum:]]/-/g")
BUILDTIME := $(shell date -u +"%FT%TZ%:z")

TAG ?= $(GIT_TAG)

.PHONY: docker tag push help
default: help

## Build the docker image
docker:
	@docker build \
		--pull \
		--tag "$(ORG)/$(BIN):latest" \
		.

## Tag image
tag: docker
	@docker tag "$(ORG)/$(BIN):latest" "$(ORG)/$(BIN):$(TAG)"

## Push the latest and current version tags to registry
push: tag
	@docker push "$(ORG)/$(BIN):latest"
	@docker push "$(ORG)/$(BIN):$(TAG)"

## Run the latest built image
run: docker
	@docker run \
		-it \
		--rm \
		"$(ORG)/$(BIN):latest"

## Run a shell on the latest built image
run-shell: docker
	@docker run \
		-it \
		--rm \
		"$(ORG)/$(BIN):latest" sh

## Same as push
all: push

## Print this help message
help:
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  ${YELLOW}%-$(TARGET_MAX_CHAR_NUM)s${RESET} ${GREEN}%s${RESET}\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)
