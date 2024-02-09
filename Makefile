# Define the source directory for assets
SRC_DIR := lib

# Define the destination directories for different languages
PYTHON_DEST := python/countdown/assets
R_DEST := r/inst/countdown
QUARTO_DEST := quarto/_extensions/countdown/assets

# Set the default target to sync
.DEFAULT_GOAL := sync

# Define the sync target
sync: sync-python sync-r sync-quarto

# Rule to copy assets to Python directory
sync-python:
	@echo "Syncing assets to Python directory..."
	mkdir -p $(PYTHON_DEST)
	cp -r $(SRC_DIR)/* $(PYTHON_DEST)

# Rule to copy assets to R directory
sync-r:
	@echo "Syncing assets to R directory..."
	mkdir -p $(R_DEST)
	cp -r $(SRC_DIR)/* $(R_DEST)

# Rule to copy assets to Quarto directory
sync-quarto:
	@echo "Syncing assets to Quarto directory..."
	mkdir -p $(QUARTO_DEST)
	cp -r $(SRC_DIR)/* $(QUARTO_DEST)
