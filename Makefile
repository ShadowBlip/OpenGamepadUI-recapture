PLUGIN_NAME ?= $(shell grep 'plugin\.id' plugin.json | awk '{print $$2}' | grep -o '"[^"]\+"' | sed 's/"//g')

OPENGAMEPAD_UI_BASE ?= ../OpenGamepadUI
PLUGINS_DIR := $(OPENGAMEPAD_UI_BASE)/plugins
BUILD_DIR := $(OPENGAMEPAD_UI_BASE)/build
INSTALL_DIR := $(HOME)/.local/share/opengamepadui/plugins

##@ General

# The help target prints out all targets with their descriptions organized
# beneath their categories. The categories are represented by '##@' and the
# target descriptions by '##'. The awk commands is responsible for reading the
# entire set of makefiles included in this invocation, looking for lines of the
# file as xyz: ## something, and then pretty-format the target and help. Then,
# if there's a line with ##@ something, that gets pretty-printed as a category.
# More info on the usage of ANSI control characters for terminal formatting:
# https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_parameters
# More info on the awk command:
# http://linuxcommand.org/lc3_adv_awk.php

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Development

.PHONY: dist
dist: build ## Build and package plugin
	mkdir -p dist
	touch dist/.gdignore
	cp $(BUILD_DIR)/plugins.zip dist/$(PLUGIN_NAME).zip

.PHONY: build
build: $(PLUGINS_DIR)/$(PLUGIN_NAME) ## Build the plugin
	@echo "Exporting plugin package"
	cd $(OPENGAMEPAD_UI_BASE) && $(MAKE) plugins

.PHONY: install
install: dist ## Installs the plugin
	cp -r dist/* "$(INSTALL_DIR)"
	@echo "Installed plugin to $(INSTALL_DIR)"

$(PLUGINS_DIR)/$(PLUGIN_NAME):
	ln -s $(PWD) $(PLUGINS_DIR)/$(PLUGIN_NAME)

