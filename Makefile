.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Available Targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: install-deps-macos
install-deps-macos: ## Install dependencies for MacOS
	brew install chart-testing
	brew install kind
	brew install shellcheck

.PHONY: lint
lint: lint-charts lint-shell ## Run all linters

.PHONY: lint-charts
lint-charts: ## Lint charts
	ct lint

.PHONY: lint-shell
lint-shell: ## Lint shell scripts
	find . -type f -name "*.sh" | xargs shellcheck

.PHONY: test-e2e
test-e2e: ## Run end-to-end tests
	./test/test-e2e.sh
