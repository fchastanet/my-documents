# Variables
HUGO_VERSION := 0.155.3
SITES_DIR := sites
BUILD_DIR := build
REPOS := bash-compiler bash-tools bash-tools-framework bash-dev-env
SCRIPT_DIR := .github/scripts

# Colors for output (sourced from colors.sh)
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
NC := \033[0m # No Color

.PHONY: help install install-hugo install-yq clean link-repos unlink-repos build-all build-site start build test-all

# Default target
help:
	@echo "$(BLUE)Multi-Site Documentation Build Makefile$(NC)"
	@echo ""
	@echo "$(GREEN)Setup:$(NC)"
	@echo "  make install       - Install all dependencies (Hugo, yq, npm, Go modules)"
	@echo "  make install-hugo  - Install Hugo extended"
	@echo "  make install-yq    - Install yq (YAML processor)"
	@echo ""
	@echo "$(GREEN)Local Multi-Site Testing:$(NC)"
	@echo "  make link-repos    - Create symlinks to other repos for local testing"
	@echo "  make unlink-repos  - Remove symlinks"
	@echo "  make build-all     - Build all sites locally"
	@echo "  make build-site SITE=bash-compiler  - Build specific site"
	@echo "  make test-all      - Build all sites and test with curl"
	@echo ""
	@echo "$(GREEN)Development:$(NC)"
	@echo "  make start         - Start Hugo dev server (my-documents only)"
	@echo "  make build         - Build my-documents site"
	@echo "  make clean         - Remove build artifacts"
	@echo ""
	@echo "$(YELLOW)Note:$(NC) For multi-site testing, clone other repos to ../[repo-name]/"

# Install Hugo extended
install-hugo:
	@$(SCRIPT_DIR)/install-hugo.sh $(HUGO_VERSION)

# Install yq YAML processor
install-yq:
	@$(SCRIPT_DIR)/install-yq.sh

# Install all dependencies
install: install-hugo install-yq
	@echo "$(BLUE)Installing dependencies...$(NC)"
	npm ci
	go get -u ./...
	go mod tidy
	@echo "$(GREEN)✅ All dependencies installed$(NC)"

# Create symlinks to other repositories for local testing
link-repos:
	@$(SCRIPT_DIR)/link-repos.sh $(SITES_DIR) $(REPOS)

# Remove symlinks
unlink-repos:
	@$(SCRIPT_DIR)/unlink-repos.sh $(SITES_DIR) $(REPOS)

# Build a specific site
build-site:
	@if [ -z "$(SITE)" ]; then \
	  echo "$(YELLOW)Usage: make build-site SITE=bash-compiler$(NC)"; \
	  exit 1; \
	fi
	@$(SCRIPT_DIR)/build-site.sh $(SITES_DIR)/$(SITE) $(SITE) $(BUILD_DIR)

# Build all sites
build-all: link-repos
	@$(SCRIPT_DIR)/build-all.sh $(BUILD_DIR) $(SITES_DIR) $(REPOS)

# Test all sites
test-all: build-all
	@$(SCRIPT_DIR)/test-all.sh $(BUILD_DIR) $(SITES_DIR) $(REPOS)

# Build my-documents only
build:
	@$(SCRIPT_DIR)/build-site.sh . my-documents build

# Start Hugo dev server
start:
	@echo "$(BLUE)Starting Hugo dev server...$(NC)"
	@yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' \
	  configs/_base.yaml configs/site-config.yaml > hugo.yaml.tmp && \
	  mv hugo.yaml.tmp hugo.yaml
	hugo server -D

start-site: build-site
	@echo "$(BLUE)Starting Hugo dev server for $(SITE)...$(NC)"
	cd build/$(SITE) && hugo server -D

# Clean build artifacts
clean:
	@echo "$(BLUE)Cleaning build artifacts...$(NC)"
	rm -rf $(SITES_DIR) $(BUILD_DIR) resources/_gen hugo.yaml.tmp .hugo_build.lock
	@echo "$(GREEN)✅ Clean complete$(NC)"
