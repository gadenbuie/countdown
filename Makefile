.PHONY: help debug sync-all sync-python sync-quarto sync-r
.DEFAULT_GOAL := help

help:  ## Show help messages for make targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(firstword $(MAKEFILE_LIST)) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-18s\033[0m %s\n", $$1, $$2}'

# Define the source directory for assets
SRC_DIR := lib
SRC_FILES := $(wildcard $(SRC_DIR)/*.js)
SRC_FILES += $(wildcard $(SRC_DIR)/*.css)
SRC_FILES += $(wildcard $(SRC_DIR)/*.mp3)

# Read version from version distribution file
VERSION_FILE := $(SRC_DIR)/version.txt
VERSION := $(shell grep '^Version:' $(VERSION_FILE) | awk '{print $$2}')

# Define the destination directories for different languages
SYNC_DEST_PYTHON := python/countdown/assets
SYNC_DEST_R := r/inst/countdown
SYNC_DEST_QUARTO := quarto/_extensions/countdown/assets

sync-all: sync-python sync-r sync-quarto ## Sync web assets to all subpackages

sync-python: ## Sync web assets to Python package
	@echo "Syncing web assets to the Python package..."
	@test -d $(SYNC_DEST_PYTHON) || mkdir -p $(SYNC_DEST_PYTHON)
	cp -r $(SRC_FILES) $(SYNC_DEST_PYTHON)
	echo "countdown_version = '$(VERSION)'" > python/countdown/config.py

sync-r: ## Sync web assets to R package
	@echo "Syncing web assets to R directory..."
	@test -d $(SYNC_DEST_R) || mkdir -p $(SYNC_DEST_R)
	cp -r $(SRC_FILES) $(SYNC_DEST_R)
	echo "countdown_version <- '$(VERSION)'" > r/R/config.R


sync-quarto:  ## Sync web assets to Quarto extension
	@echo "Syncing web assets to Quarto directory..."
	@test -d $(SYNC_DEST_QUARTO) || mkdir -p $(SYNC_DEST_QUARTO)
	cp -r $(SRC_FILES) $(SYNC_DEST_QUARTO)
	echo "local countdown_version = '$(VERSION)'\n\nreturn { countdownVersion = countdown_version }" > quarto/_extensions/countdown/config.lua

.PHONY: js-format
js-format: ## Format JavaScript files using prettier
	npx standard --fix $(wildcard $(SRC_DIR)/*.js)

debug: ## Print all variables for debugging
	@printf "\033[32m%-18s\033[0m %s\n" "VERSION" "$(VERSION)"
	@printf "\033[32m%-18s\033[0m %s\n" "SRC_DIR" "$(SRC_DIR)"
	@printf "\033[32m%-18s\033[0m %s\n" "SRC_FILES" "$(SRC_FILES)"
	@printf "\033[32m%-18s\033[0m %s\n" "VERSION_FILE" "$(VERSION_FILE)"
	@printf "\033[32m%-18s\033[0m %s\n" "SYNC_DEST_PYTHON" "$(SYNC_DEST_PYTHON)"
	@printf "\033[32m%-18s\033[0m %s\n" "SYNC_DEST_R" "$(SYNC_DEST_R)"
	@printf "\033[32m%-18s\033[0m %s\n" "SYNC_DEST_QUARTO" "$(SYNC_DEST_QUARTO)"
