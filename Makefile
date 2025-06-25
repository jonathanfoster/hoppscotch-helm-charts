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

.PHONY: lint
lint: lint-charts ## Run all linters

.PHONY: lint-charts
lint-charts: ## Lint charts
	ct lint
