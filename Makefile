################################################################################
##                                   COMMANDS                                 ##
################################################################################

MAKE += --no-print-directory RECURSIVE=1

ifndef VERBOSE
COMPOSE := docker-compose 2>/dev/null
COMPOSE_BUILD := $(COMPOSE) build -q
else
COMPOSE := docker-compose
COMPOSE_BUILD := $(COMPOSE) build
endif

################################################################################
##                                   COLORS                                   ##
################################################################################

RES := \033[0m
MSG := \033[1;36m
ERR := \033[1;31m
SUC := \033[1;32m
WRN := \033[1;33m
NTE := \033[1;34m

################################################################################
##                                 AUXILIARY                                  ##
################################################################################

# Variable do allow is-empty and not-empty to work with ifdef/ifndef
export T := 1

define is-empty
$(strip $(if $(strip $1),,T))
endef

define not-empty
$(strip $(if $(strip $1),T))
endef

define message
printf "${MSG}%s${RES}\n" $(strip $1)
endef

define success
(printf "${SUC}%s${RES}\n" $(strip $1); exit 0)
endef

define warn
(printf "${WRN}%s${RES}\n" $(strip $1); exit 0)
endef

define failure
(printf "${ERR}%s${RES}\n" $(strip $1); exit 1)
endef

define note
(printf "${NTE}%s${RES}\n" $(strip $1); exit 0)
endef

################################################################################
##                                   AWS                                      ##
################################################################################

SHELL := /bin/bash

# Do not execute in recursive calls or within Jenkins
ifdef $(call is-empty,${RECURSIVE})
export AWS_ACCESS_KEY_ID := $(shell aws configure get aws_access_key_id)
export AWS_SECRET_ACCESS_KEY := $(shell aws configure get aws_secret_access_key)
export AWS_SESSION_TOKEN := $(shell aws configure get aws_session_token)
endif

################################################################################
##                                DOCKER BUILD                                ##
################################################################################

build-train:
	@$(call message,"Construindo imagem docker para trainamento")
	@$(COMPOSE_BUILD) train

build-api:
	@$(call message,"Construindo imagem docker para api")
	@$(COMPOSE_BUILD) api

build-metrics:
	@$(call message,"Construindo imagem docker para métricas")
	@$(COMPOSE_BUILD) metrics

build-tools:
	@$(call message,"Construindo imagem docker de ferramentas")
	@$(COMPOSE_BUILD) mlflow
	@$(COMPOSE_BUILD) kafka
	@$(COMPOSE_BUILD) schema-registry

build:
	@$(MAKE) build-train
	@$(MAKE) build-api
	@$(MAKE) build-metrics

build-all:
	@$(MAKE) build
	@$(MAKE) build-tools

# release-image:
# 	@$(MAKE) build-prod
# 	@$(call message,"Releasing version ${TAG} ")
# 	@docker image tag ${EXAMPLE_IMAGE}:${EXAMPLE_TAG} ${EXAMPLE_IMAGE}:${TAG}
# 	@docker push ${EXAMPLE_IMAGE}:${TAG}
	
# bump-and-release:
# 	@$(call message,"Bumping ${KIND} of example version")
# 	@(poetry version ${KIND})
# 	@$(MAKE) release-image TAG=${POETRY_VERSION}
# 	@git add pyproject.toml
# 	@git commit -m "Release version: v${POETRY_VERSION}"
# 	@git tag v${POETRY_VERSION}-ETL
# 	@git push origin HEAD --tags


################################################################################
##                               LINT & FORMAT                                ##
################################################################################


black:
	@$(call message,"Rodando black")
	@$(COMPOSE) run -T --rm --entrypoint black api .
	@$(COMPOSE) run -T --rm --entrypoint black train .
	@$(COMPOSE) run -T --rm --entrypoint black metrics .

ruff:
	@$(call message,"Rodando ruff")
	@$(COMPOSE) run -T --rm --entrypoint ruff api .
	@$(COMPOSE) run -T --rm --entrypoint ruff train .
	@$(COMPOSE) run -T --rm --entrypoint ruff metrics .

ruff-fix:
	@$(call message,"Rodando ruff com fix")
	@$(COMPOSE) run -T --rm --entrypoint ruff api . --fix
	@$(COMPOSE) run -T --rm --entrypoint ruff train . --fix
	@$(COMPOSE) run -T --rm --entrypoint ruff metrics . --fix

mypy:
	@$(call message,"Rodando mypy")
	@$(COMPOSE) run -T --rm --entrypoint mypy api .
	@$(COMPOSE) run -T --rm --entrypoint mypy train .
	@$(COMPOSE) run -T --rm --entrypoint mypy metrics .

lint:
	@$(MAKE) mypy
	@$(MAKE) ruff

format:
	@$(MAKE) black
	@$(MAKE) ruff-fix


################################################################################
##                                 TESTS                                      ##
################################################################################






################################################################################
##                                 TRAIN                                      ##
################################################################################

test-env:
	@$(COMPOSE) up -d db minio mc web 

clear-test-env:
	@$(COMPOSE) down 

step-tests:
	@$(COMPOSE) run --rm --entrypoint pytest dev -v tests/

run-ingest-step:
	@$(COMPOSE) run --rm --entrypoint "sh -c 'mlflow recipes run --step ingest --profile local'" train -v 

run-transform-step:
	@$(COMPOSE) run --rm --entrypoint "sh -c 'mlflow recipes run --step transform --profile local'" train -v 

run-split-step:
	@$(COMPOSE) run --rm --entrypoint "sh -c 'mlflow recipes run --step split --profile local'" train -v 

run-train-step:
	@$(COMPOSE) run --rm --entrypoint "sh -c 'mlflow recipes run --step train --profile local'" train -v 

run-custom-metrics-step:
	@$(COMPOSE) run --rm --entrypoint "sh -c 'mlflow recipes run --step custom_metrics --profile local'" train -v 

inspect-ingest-step:
	@$(COMPOSE) run --rm --entrypoint "sh -c 'mlflow recipes inspect --step ingest --profile local'" train -v 

inspect-transform-step:
	@$(COMPOSE) run --rm --entrypoint "sh -c 'mlflow recipes inspect --step transform --profile local'" train -v 

inspect-split-step:
	@$(COMPOSE) run --rm --entrypoint "sh -c 'mlflow recipes inspect --step split --profile local'" train -v 

inspect-train-step:
	@$(COMPOSE) run --rm --entrypoint "sh -c 'mlflow recipes inspect --step train --profile local'" train -v 

inspect-custom-metrics-step:
	@$(COMPOSE) run --rm --entrypoint "sh -c 'mlflow recipes inspect --step custom_metrics --profile local'" train -v 


check-ingest-step:
	@$(MAKE) run-ingest-step
	@$(MAKE) inspect-ingest-step

check-transform-step:
	@$(MAKE) run-transform-step
	@$(MAKE) inspect-transform-step

check-split-step:
	@$(MAKE) run-split-step
	@$(MAKE) inspect-split-step

check-train-step:
	@$(MAKE) run-train-step
	@$(MAKE) inspect-train-step

check-custom-metrics-step:
	@$(MAKE) run-custom-metrics-step
	@$(MAKE) inspect-custom-metrics-step

clear-steps-recipes:
	@$(COMPOSE) run --rm --entrypoint "sh -c 'mlflow recipes clean --profile=local'" train -v 


all-tests:
	@$(MAKE) build
	@$(MAKE) test-env
	@$(MAKE) step-tests
	@$(MAKE) clear-steps-recipes
	@$(MAKE) check-ingest-step
	@$(MAKE) check-transform-step
	@$(MAKE) check-split-step
	@$(MAKE) check-train-step
	@$(MAKE) check-custom-metrics-step
	@$(MAKE) clear-steps-recipes
	@$(MAKE) clear-test-env
	@$(call success,"Flawless test execution, congratulations")