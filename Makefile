.DEFAULT_GOAL := help
SUBMAKE := $(MAKE) --no-print-directory

ifeq ($(OS),Windows_NT)
SHELL := cmd.exe
FVM_FLUTTER_SDK := $(wildcard $(CURDIR)\.fvm\flutter_sdk)
LOCAL_FLUTTER := $(if $(FVM_FLUTTER_SDK),$(FVM_FLUTTER_SDK)\bin\flutter.bat,flutter.bat)
LOCAL_DART := $(if $(FVM_FLUTTER_SDK),$(FVM_FLUTTER_SDK)\bin\dart.bat,dart.bat)
BLANK_LINE := @echo.
else
SHELL := /bin/bash
FVM_FLUTTER_SDK := $(wildcard $(CURDIR)/.fvm/flutter_sdk)
LOCAL_FLUTTER := $(if $(FVM_FLUTTER_SDK),$(FVM_FLUTTER_SDK)/bin/flutter,flutter)
LOCAL_DART := $(if $(FVM_FLUTTER_SDK),$(FVM_FLUTTER_SDK)/bin/dart,dart)
BLANK_LINE := @echo
endif

FLUTTER := $(LOCAL_FLUTTER)
DART := $(LOCAL_DART)
EXAMPLE_DIR := example

# Test output modes:
#   make test                         Human-readable output (default)
#   make test CI=1                    GitHub-compatible reporter
#   make test MACHINE_OUT=result.json Machine-readable JSON output
CI ?= 0
MACHINE_OUT ?=

.PHONY: help format format-check fix analyze analyze-example test \
	test-example publish-dry-run check aio

help:
	@echo "adaptive_actions — automation entrypoints"
	$(BLANK_LINE)
	@echo "  help          Show this help"
	@echo "  format        Format package and example Dart sources"
	@echo "  format-check  Verify that Dart sources are formatted"
	@echo "  fix           Apply Dart fixes, then format"
	@echo "  analyze       Run package static analysis"
	@echo "  analyze-example Run example static analysis"
	@echo "  test          Run package tests"
	@echo "  test-example  Run example tests"
	@echo "  publish-dry-run Validate the package for pub.dev"
	@echo "  check         Check package and example"
	@echo "  aio           Format, fix, analyze, and test all Dart sources"

format:
	@$(DART) format lib test $(EXAMPLE_DIR)/lib $(EXAMPLE_DIR)/test

format-check:
	@$(DART) format --output=none --set-exit-if-changed \
		lib test $(EXAMPLE_DIR)/lib $(EXAMPLE_DIR)/test

fix:
	@$(DART) fix --apply
	@$(SUBMAKE) format

analyze:
	@$(FLUTTER) analyze

analyze-example:
	@cd $(EXAMPLE_DIR) && $(FLUTTER) analyze

test:
ifneq ($(MACHINE_OUT),)
	@$(FLUTTER) pub get
	@$(FLUTTER) test --file-reporter=json:$(MACHINE_OUT)
else ifeq ($(CI),1)
	@$(FLUTTER) test --reporter github
else
	@$(FLUTTER) test
endif

test-example:
ifneq ($(MACHINE_OUT),)
	@cd $(EXAMPLE_DIR) && $(FLUTTER) pub get
	@cd $(EXAMPLE_DIR) && $(FLUTTER) test --file-reporter=json:$(MACHINE_OUT)
else ifeq ($(CI),1)
	@cd $(EXAMPLE_DIR) && $(FLUTTER) test --reporter github
else
	@cd $(EXAMPLE_DIR) && $(FLUTTER) test
endif

publish-dry-run:
	@$(DART) pub publish --dry-run

check: format-check analyze analyze-example test test-example

aio: format fix analyze analyze-example test test-example
