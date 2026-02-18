# Variables
HUGO_VERSION := 0.155.3
SITES_DIR := sites
BUILD_DIR := build
REPOS := bash-compiler bash-tools bash-tools-framework bash-dev-env

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
NC := \033[0m # No Color

.PHONY: help install install-hugo install-yq clean link-repos unlink-repos build-all build-site start test-all

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

# Install Hugo (if not already installed)
install-hugo:
	@if ! command -v hugo >/dev/null 2>&1; then \
	  echo "$(YELLOW)Hugo not found. Installing...$(NC)"; \
	  HUGO_VERSION=$(HUGO_VERSION); \
	  OS=$$(uname -s | tr '[:upper:]' '[:lower:]'); \
	  ARCH=$$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/'); \
	  if [ "$$OS" = "linux" ]; then \
	    FILENAME=hugo_extended_$$HUGO_VERSION\_$$OS-$$ARCH.deb; \
	    URL="https://github.com/gohugoio/hugo/releases/download/v$$HUGO_VERSION/$$FILENAME"; \
	    echo "Downloading $$URL"; \
	    curl -L -o /tmp/$$FILENAME $$URL; \
	    sudo dpkg -i /tmp/$$FILENAME; \
	    rm /tmp/$$FILENAME; \
	  else \
	    echo "$(YELLOW)Please install Hugo manually from https://gohugo.io/installation/$(NC)"; \
	    exit 1; \
	  fi; \
	  echo "$(GREEN)Hugo installed.$(NC)"; \
	else \
	  echo "$(GREEN)Hugo is already installed: $$(hugo version)$(NC)"; \
	fi

# Install yq (YAML processor)
install-yq:
	@if ! command -v yq >/dev/null 2>&1; then \
	  echo "$(YELLOW)yq not found. Installing...$(NC)"; \
	  sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64; \
	  sudo chmod +x /usr/local/bin/yq; \
	  echo "$(GREEN)yq installed: $$(yq --version)$(NC)"; \
	else \
	  echo "$(GREEN)yq is already installed: $$(yq --version)$(NC)"; \
	fi

install: install-hugo install-yq
	@echo "$(BLUE)Installing dependencies...$(NC)"
	npm ci
	go get -u ./...
	go mod tidy
	@echo "$(GREEN)✅ All dependencies installed$(NC)"

# Link other repositories for local testing
link-repos:
	@echo "$(BLUE)Creating symlinks to other repositories...$(NC)"
	@mkdir -p $(SITES_DIR)
	@for repo in $(REPOS); do \
	  if [ -d "../$$repo" ]; then \
	    if [ -L "$(SITES_DIR)/$$repo" ]; then \
	      echo "  $(YELLOW)✓$(NC) $(SITES_DIR)/$$repo already linked"; \
	    else \
	      ln -sf "../../$$repo" "$(SITES_DIR)/$$repo"; \
	      echo "  $(GREEN)✓$(NC) Linked $(SITES_DIR)/$$repo → ../$$repo"; \
	    fi; \
	  else \
	    echo "  $(YELLOW)⚠$(NC)  ../$$repo not found (clone it to enable)"; \
	  fi; \
	done
	@echo "$(GREEN)✅ Symlinks created$(NC)"

# Remove symlinks
unlink-repos:
	@echo "$(BLUE)Removing symlinks...$(NC)"
	@for repo in $(REPOS); do \
	  if [ -L "$(SITES_DIR)/$$repo" ]; then \
	    rm "$(SITES_DIR)/$$repo"; \
	    echo "  $(GREEN)✓$(NC) Removed $(SITES_DIR)/$$repo"; \
	  fi; \
	done
	@[ -d "$(SITES_DIR)" ] && rmdir "$(SITES_DIR)" 2>/dev/null || true
	@echo "$(GREEN)✅ Symlinks removed$(NC)"

# Build a specific site
build-site:
	@if [ -z "$(SITE)" ]; then \
	  echo "$(YELLOW)Usage: make build-site SITE=bash-compiler$(NC)"; \
	  exit 1; \
	fi
	@echo "$(BLUE)Building $(SITE)...$(NC)"
	@mkdir -p $(BUILD_DIR)/$(SITE)
	@# Copy shared resources
	@cp -r shared/* $(BUILD_DIR)/$(SITE)/ 2>/dev/null || true
	@# Copy site content
	@if [ -d "$(SITES_DIR)/$(SITE)/content" ]; then \
	  cp -r $(SITES_DIR)/$(SITE)/content $(BUILD_DIR)/$(SITE)/; \
	  [ -d "$(SITES_DIR)/$(SITE)/static" ] && cp -r $(SITES_DIR)/$(SITE)/static $(BUILD_DIR)/$(SITE)/ || true; \
	  yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' \
	    configs/_base.yaml configs/$(SITE).yaml > $(BUILD_DIR)/$(SITE)/hugo.yaml; \
	  cd $(BUILD_DIR)/$(SITE) && \
	    go mod init github.com/fchastanet/$(SITE) 2>/dev/null || true && \
	    go get -u github.com/google/docsy@v0.14.2 && \
	    go get -u github.com/google/docsy/dependencies@v0.7.2 && \
	    go mod tidy && \
	    hugo --minify; \
	  echo "$(GREEN)✅ $(SITE) built successfully$(NC)"; \
	  echo "  Output: $(BUILD_DIR)/$(SITE)/public/"; \
	else \
	  echo "$(YELLOW)⚠  $(SITES_DIR)/$(SITE) not found. Run 'make link-repos' first.$(NC)"; \
	  exit 1; \
	fi

# Build all sites
build-all: link-repos
	@echo "$(BLUE)Building all sites...$(NC)"
	@# Build my-documents
	@echo "$(BLUE)Building my-documents...$(NC)"
	@yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' \
	  configs/_base.yaml configs/my-documents.yaml > hugo.yaml.tmp
	@mv hugo.yaml.tmp hugo.yaml
	@go mod tidy
	@hugo --minify
	@echo "$(GREEN)✅ my-documents built$(NC)"
	@# Build other sites
	@for repo in $(REPOS); do \
	  if [ -d "$(SITES_DIR)/$$repo" ]; then \
	    $(MAKE) build-site SITE=$$repo; \
	  fi; \
	done
	@echo "$(GREEN)✅ All sites built successfully$(NC)"

# Test all built sites
test-all: build-all
	@echo "$(BLUE)Testing all sites with curl...$(NC)"
	@# Test my-documents
	@echo "  Testing my-documents..."
	@hugo server -D --port 1313 > /dev/null 2>&1 & \
	  SERVER_PID=$$!; \
	  sleep 2; \
	  if curl -s -o /dev/null -w "%{http_code}" http://localhost:1313/my-documents/ | grep -q "200"; then \
	    echo "    $(GREEN)✓$(NC) my-documents: http://localhost:1313/my-documents/"; \
	  else \
	    echo "    $(YELLOW)✗$(NC) my-documents failed"; \
	  fi; \
	  kill $$SERVER_PID 2>/dev/null || true
	@# Test other sites
	@for repo in $(REPOS); do \
	  if [ -d "$(BUILD_DIR)/$$repo/public" ]; then \
	    echo "  Testing $$repo..."; \
	    cd $(BUILD_DIR)/$$repo && \
	    hugo server -D --port 1314 > /dev/null 2>&1 & \
	    SERVER_PID=$$!; \
	    sleep 2; \
	    if curl -s -o /dev/null -w "%{http_code}" http://localhost:1314/$$repo/ | grep -q "200"; then \
	      echo "    $(GREEN)✓$(NC) $$repo: http://localhost:1314/$$repo/"; \
	    else \
	      echo "    $(YELLOW)✗$(NC) $$repo failed"; \
	    fi; \
	    kill $$SERVER_PID 2>/dev/null || true; \
	    cd ../..; \
	  fi; \
	done
	@echo "$(GREEN)✅ All tests complete$(NC)"

build:
	@echo "$(BLUE)Building my-documents...$(NC)"
	@yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' \
	  configs/_base.yaml configs/my-documents.yaml > hugo.yaml.tmp && \
	  mv hugo.yaml.tmp hugo.yaml
	@hugo --printI18nWarnings --printPathWarnings --printUnusedTemplates --minify
	@echo "$(GREEN)✅ Build complete$(NC)"

start:
	@echo "$(BLUE)Starting Hugo dev server...$(NC)"
	@yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' \
	  configs/_base.yaml configs/my-documents.yaml > hugo.yaml.tmp && \
	  mv hugo.yaml.tmp hugo.yaml
	hugo server -D

clean:
	@echo "$(BLUE)Cleaning build artifacts...$(NC)"
	rm -rf $(BUILD_DIR) public resources/_gen hugo.yaml.tmp
	@echo "$(GREEN)✅ Clean complete$(NC)"
