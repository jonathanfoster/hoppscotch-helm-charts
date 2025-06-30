.DEFAULT_GOAL := help

.PHONY: clean
clean: ## Clean up chart release packages
	rm -rf .cr-release-packages

.PHONY: help
help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Available Targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: install-deps-macos
install-deps-macos: ## Install dependencies for MacOS
	brew install chart-releaser
	brew install chart-testing
	brew install kind
	brew install shellcheck

.PHONY: install-deps-linux
install-deps-linux: ## Install dependencies for Linux
	@echo "Installing Helm..."
	curl -fsSL https://get.helm.sh/helm-v3.17.0-linux-amd64.tar.gz | tar xz && sudo mv linux-amd64/helm /usr/local/bin/ && rm -rf linux-amd64
	@echo "Installing chart-testing..."
	curl -fsSLo ct.tar.gz https://github.com/helm/chart-testing/releases/download/v3.10.1/chart-testing_3.10.1_linux_amd64.tar.gz && tar -xzf ct.tar.gz && sudo mv ct /usr/local/bin/ && rm ct.tar.gz
	@echo "Installing chart-releaser..."
	curl -fsSLo cr.tar.gz https://github.com/helm/chart-releaser/releases/download/v1.6.0/chart-releaser_1.6.0_linux_amd64.tar.gz && tar -xzf cr.tar.gz && sudo mv cr /usr/local/bin/ && rm cr.tar.gz
	@echo "Installing kind..."
	[ $$(uname -m) = x86_64 ] && curl -fsSLo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64 || curl -fsSLo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-arm64
	chmod +x ./kind && sudo mv ./kind /usr/local/bin/kind
	@echo "Installing shellcheck..."
	sudo apt-get update && sudo apt-get install -y shellcheck || (echo "Please install shellcheck manually for your Linux distribution" && exit 1)
	@echo "Installing yamllint and yamale..."
	sudo apt-get install -y python3-yamllint python3-yamale || (echo "Failed to install via apt, trying pipx..." && sudo apt-get install -y pipx && pipx install yamllint && pipx install yamale)
	@echo "Installing chart-testing configuration..."
	sudo mkdir -p /etc/ct
	curl -fsSLo /tmp/chart_schema.yaml https://raw.githubusercontent.com/helm/chart-testing/main/etc/chart_schema.yaml
	sudo mv /tmp/chart_schema.yaml /etc/ct/chart_schema.yaml
	@echo "All dependencies installed successfully!"

.PHONY: install-deps
install-deps: ## Install dependencies (auto-detect OS)
	@if [ "$$(uname)" = "Darwin" ]; then \
		$(MAKE) install-deps-macos; \
	elif [ "$$(uname)" = "Linux" ]; then \
		$(MAKE) install-deps-linux; \
	else \
		echo "Unsupported operating system: $$(uname)"; \
		exit 1; \
	fi

.PHONY: lint
lint: lint-charts lint-shell ## Run all linters

.PHONY: lint-charts
lint-charts: ## Lint charts
	ct lint --config ct.yaml --lint-conf lintconf.yaml

.PHONY: lint-shell
lint-shell: ## Lint shell scripts
	find . -type f -name "*.sh" | xargs shellcheck

.PHONY: package
package: clean ## Package charts
	cr package charts/*

.PHONY: test-e2e
test-e2e: ## Run end-to-end tests
	./test/test-e2e.sh
