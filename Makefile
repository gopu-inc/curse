GOSCRIPT_DIR ?= $(abspath ../goscript)
GD ?= $(GOSCRIPT_DIR)/build/bin/gd
CURSE_DIR ?= $(abspath .)

.PHONY: test golem

golem:
	cd "$(CURSE_DIR)" && PATH="$(GOSCRIPT_DIR)/build/bin:$$PATH" GOSCRIPT_SHARE_DIR="$(GOSCRIPT_DIR)/lib" "$(GOSCRIPT_DIR)/golem" build
	cd "$(CURSE_DIR)" && mkdir -p modules/curse && cp __self__.gjs README.md Manifest.toml LICENSE main.gjs modules/curse/ && cp -r src docs examples tests modules/curse/

test:
	GOSCRIPT_SHARE_DIR=$(GOSCRIPT_DIR)/lib $(GD) tests/foundation.gjs
	cd .. && GOSCRIPT_SHARE_DIR=$(GOSCRIPT_DIR)/lib $(GD) curse/tests/package.gjs
