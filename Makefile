# Install Hugo (if not already installed)
install-hugo:
	@if ! command -v hugo >/dev/null 2>&1; then \
	  echo "Hugo not found. Installing..."; \
	  HUGO_VERSION=0.155.3; \
	  OS=$(shell uname -s | tr '[:upper:]' '[:lower:]'); \
	  ARCH=$(shell uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/'); \
	  FILENAME=hugo_extended_$$HUGO_VERSION_$$OS-$$ARCH.deb; \
	  URL="https://github.com/gohugoio/hugo/releases/download/v$$HUGO_VERSION/$$FILENAME"; \
	  echo "Downloading $$URL"; \
	  curl -L -o /tmp/$$FILENAME $$URL; \
		sudo dpkg -i /tmp/$$FILENAME; \
	  rm /tmp/hugo /tmp/$$FILENAME; \
	  echo "Hugo installed."; \
	else \
	  echo "Hugo is already installed."; \
	fi

install: install-hugo
	npm ci
	go get -u ./...

build:
	hugo --printI18nWarnings --printPathWarnings --printUnusedTemplates

start:
	hugo server -D
