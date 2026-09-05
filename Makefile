# Local developer gates — mirror what CI runs in .github/workflows/android_release.yml.
#
#   make lint-workflows    Lint workflow files with the pinned actionlint
#                          (same binary + invocation as the CI syntax-gate job)
#   make lint-local        Run every CI syntax-gate locally: actionlint + the
#                          three Node checks (Dart balance, signing template,
#                          private-key scan)
#   make install-hooks     Enable the versioned pre-push hook (core.hooksPath):
#                          runs the CI gates scoped to what the push touches
#   make uninstall-hooks   Disable the pre-push hook

.PHONY: lint-workflows lint-local install-hooks uninstall-hooks

lint-workflows:
	bash tools/lint_workflows.sh

lint-local:
	bash tools/lint_workflows.sh
	node tools/check_dart_syntax.js
	node tools/check_signing_template.js
	node tools/check_no_private_keys.js

install-hooks:
	git config core.hooksPath .githooks
	@echo "pre-push hook enabled — on push, the CI syntax-gate runs scoped to"
	@echo "changed files (actionlint, Dart balance, signing template, private keys)."
	@echo "Run 'make uninstall-hooks' to disable."

uninstall-hooks:
	git config --unset core.hooksPath
	@echo "pre-push hook disabled."
