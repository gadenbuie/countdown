# Define the source directory for assets
SRC_DIR := lib
JS_FILES := $(wildcard $(SRC_DIR)/*.js)
CSS_FILES := $(wildcard $(SRC_DIR)/*.css)
MP3_FILES := $(wildcard $(SRC_DIR)/*.mp3)

# Read version from version distribution file
VERSION_FILE := $(SRC_DIR)/version.txt
VERSION := $(shell grep '^Version:' $(VERSION_FILE) | awk '{print $$2}')

# Define the destination directories for different languages
SYNC_DEST_PYTHON := python/countdown/assets
SYNC_DEST_R := r/inst/countdown
SYNC_DEST_QUARTO := quarto/_extensions/countdown/assets

# Set the default target to sync
.DEFAULT_GOAL := sync

# Define the sync target
sync: sync-python sync-r sync-quarto

# Rule to copy assets to Python directory
sync-python:
	@echo "Syncing assets to Python directory..."
	mkdir -p $(SYNC_DEST_PYTHON)
	cp -r $(JS_FILES) $(CSS_FILES) $(MP3_FILES) $(SYNC_DEST_PYTHON)
	echo "countdown_embedded = '$(VERSION)'" > python/countdown/config.py

# Rule to copy assets to R directory
sync-r:
	@echo "Syncing assets to R directory..."
	mkdir -p $(SYNC_DEST_R)
	cp -r $(JS_FILES) $(CSS_FILES) $(MP3_FILES) $(SYNC_DEST_R)
	echo "countdown_embedded <- '$(VERSION)'" > r/R/config.R
	

# Rule to copy assets to Quarto directory
sync-quarto:
	@echo "Syncing assets to Quarto directory..."
	mkdir -p $(SYNC_DEST_QUARTO)
	cp -r $(JS_FILES) $(CSS_FILES) $(MP3_FILES) $(SYNC_DEST_QUARTO)
	echo "local countdown_embedded = '$(VERSION)'\n\nreturn { countdownEmbedded = countdown_embedded }" > quarto/_extensions/countdown/config.lua
