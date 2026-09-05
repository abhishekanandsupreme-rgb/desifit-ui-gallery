# Local developer gates — mirror what CI runs in .github/workflows/android_release.yml.
#
#   make lint-workflows     Lint workflow files with the pinned actionlint
#                           (same binary + invocation as the CI syntax-gate job)
#   make lint-local         Run every CI syntax-gate locally: actionlint + the
#                           Node checks (Dart balance, signing template,
#                           private-key scan, Flutter pin)
#   make bootstrap-flutter  Install the pinned stable Flutter SDK (from
#                           .flutter-version) into .sdk/flutter/<version>
#   make test-desifit       pub get + flutter test for desifit (auto-bootstraps the SDK)
#   make test-aurasync      pub get + flutter test for AuraSync (auto-bootstraps the SDK)
#   make install-hooks      Enable the versioned pre-push hook (core.hooksPath):
#                           runs the CI gates scoped to what the push touches
#   make uninstall-hooks    Disable the pre-push hook

.PHONY: lint-workflows lint-local bootstrap-flutter test-desifit test-aurasync install-hooks uninstall-hooks

# Pinned SDK (single source of truth: .flutter-version — the same pin CI uses).
FLUTTER_VERSION := $(shell tr -d '[:space:]' < .flutter-version 2>/dev/null || echo MISSING)
FLUTTER_BIN := $(CURDIR)/.sdk/flutter/$(FLUTTER_VERSION)/bin/flutter

lint-workflows:
	bash tools/lint_workflows.sh

lint-local:
	bash tools/lint_workflows.sh
	node tools/check_dart_syntax.js
	node tools/check_signing_template.js
	node tools/check_no_private_keys.js
	node tools/check_flutter_pin.js

bootstrap-flutter:
	bash tools/bootstrap_flutter.sh

test-desifit: bootstrap-flutter
	cd desifit && "$(FLUTTER_BIN)" pub get && "$(FLUTTER_BIN)" test

test-aurasync: bootstrap-flutter
	cd AuraSync && "$(FLUTTER_BIN)" pub get && "$(FLUTTER_BIN)" test

install-hooks:
	git config core.hooksPath .githooks
	@echo "pre-push hook enabled — on push, the CI syntax-gate runs scoped to"
	@echo "changed files (actionlint, Dart balance, signing template, private keys)."
	@echo "Run 'make uninstall-hooks' to disable."

uninstall-hooks:
	git config --unset core.hooksPath
	@echo "pre-push hook disabled."
