GOSCRIPT_DIR ?= $(abspath ../goscript)
GD ?= $(GOSCRIPT_DIR)/build/bin/gd

.PHONY: test
test:
	GOSCRIPT_SHARE_DIR=$(GOSCRIPT_DIR)/lib $(GD) tests/foundation.gjs
	cd .. && GOSCRIPT_SHARE_DIR=$(GOSCRIPT_DIR)/lib $(GD) curse/tests/package.gjs
