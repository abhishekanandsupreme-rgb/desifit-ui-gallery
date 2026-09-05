# Local developer gates — mirror what CI runs in .github/workflows/android_release.yml.
#
#   make lint-workflows    Lint workflow files with the pinned actionlint
#                          (same binary + invocation as the CI syntax-gate job)
#   make install-hooks     Enable the versioned pre-push hook (core.hooksPath)
#   make uninstall-hooks   Disable the pre-push hook

.PHONY: lint-workflows install-hooks uninstall-hooks

lint-workflows:
	bash tools/lint_workflows.sh

install-hooks:
	git config core.hooksPath .githooks
	@echo "pre-push hook enabled (workflow files are linted on push when they change)."
	@echo "Run 'make uninstall-hooks' to disable."

uninstall-hooks:
	git config --unset core.hooksPath
	@echo "pre-push hook disabled."
