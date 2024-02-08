# Define the source directory for assets
SRC_DIR := lib

# Define the languages being used:
LANG_VARIANTS := python r quarto

# Define the corresponding destination directories for each language
LANG_DEST := python/countdown/assets r/inst/countdown quarto/_extensions/countdown/assets

# Convert LANG_VARIANTS to a list of sync targets, e.g. make sync-r, sync-python
SYNC_TARGETS := $(addprefix sync-, $(LANG_VARIANTS))

# Set the default target to sync
.DEFAULT_GOAL := sync

# Define the sync target
sync: $(SYNC_TARGETS)

# Rule to create directories and copy assets based on LANG_DEST
sync-%:
	@echo "Syncing assets to $(filter $*%, $(LANG_DEST)) directory..."
	mkdir -p $(filter $*%, $(LANG_DEST))
	cp -r $(SRC_DIR)/*.js $(SRC_DIR)/*.css $(SRC_DIR)/*.mp3 $(filter $*%, $(LANG_DEST))
