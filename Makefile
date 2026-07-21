# Makefile — release & preview tooling for the towfiq-ul/towfiq-ul profile README.
#
# Quick start:
#   make show              preview README.md rendered in the browser
#   make status            check for stray untracked files before releasing
#   make all               commit FILES, tag the next patch version, and push

SHELL       := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help

# --- Configuration (override on the command line, e.g. `make all FILES="README.md Makefile"`) ---
BRANCH_NAME ?= master
MD_FILE     ?= README.md
FILES       ?= README.md

# --- Derived version numbers (computed once per invocation, no state file needed) ---
CURRENT_TAG := $(shell git describe --tags --abbrev=0 2>/dev/null || echo v0.0.0)
NEXT_TAG    := $(shell echo $(CURRENT_TAG) | awk -F'[v.]' '{printf "v%d.%d.%d", $$2, $$3, $$4+1}')

.PHONY: all commit tag push version status show clean help

all: commit tag push ## Full release: commit FILES, tag the next patch version, and push branch + tags

commit: ## Stage FILES (default: README.md) and commit as "updated to <next tag>"
	@if git diff --quiet -- $(FILES) && git diff --cached --quiet -- $(FILES); then \
		echo "No changes in FILES=$(FILES); nothing to commit."; \
	else \
		git add $(FILES); \
		git commit -m "updated to $(NEXT_TAG)"; \
		echo "Committed as $(NEXT_TAG)."; \
	fi

tag: ## Create the next patch-version git tag on HEAD
	git tag "$(NEXT_TAG)"
	@echo "Tagged $(NEXT_TAG)."

push: ## Pull, push $(BRANCH_NAME), and push tags to origin
	git pull origin $(BRANCH_NAME)
	git push -u origin $(BRANCH_NAME)
	git push --tags
	@echo "Pushed $(BRANCH_NAME) and tags to origin."

version: ## Show the current tag and the next patch version (no side effects)
	@echo "Current tag: $(CURRENT_TAG)"
	@echo "Next tag:    $(NEXT_TAG)"

status: ## Show git status and flag untracked files 'make all' would NOT stage
	@git status
	@untracked=$$(git status --porcelain | grep '^??' | awk '{print $$2}' || true); \
	if [ -n "$$untracked" ]; then \
		echo ""; \
		echo "Untracked files present (only FILES=$(FILES) get committed by 'make all'):"; \
		echo "$$untracked" | sed 's/^/  /'; \
	fi

show: ## Render MD_FILE (default README.md) to HTML and open it in the browser
	@python3 -c "import markdown_it" 2>/dev/null || { echo "Missing dependency: pip install markdown-it-py"; exit 1; }
	python3 scripts/render_markdown.py $(MD_FILE)

clean: ## Soft-reset the working tree to HEAD (keeps untracked files untouched)
	git reset --soft HEAD

help: ## Show this help message
	@echo "Usage: make <target> [VAR=value ...]"
	@echo ""
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@echo ""
	@echo "Variables:"
	@echo "  BRANCH_NAME   target branch for push (default: master)"
	@echo "  FILES         files staged/committed by 'commit'/'all' (default: README.md)"
	@echo "  MD_FILE       markdown file rendered by 'show' (default: README.md)"
