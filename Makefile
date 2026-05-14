# SPDX-FileCopyrightText: 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

export PROJECT_ROOT ?= $(shell pwd)
MAKEFLAGS += --warn-undefined-variables

# PDK variant
export PDK ?= sky130A
export PDK_ROOT ?= $(PDK_ROOT)

# Include OpenLane Makefile Targets
include $(PROJECT_ROOT)/openlane/Makefile

# IPM Package Configuration
IP_NAME := CF_SRAM_16384x32
YAML_FILE := $(IP_NAME).yaml
JSON_FILE := $(IP_NAME).json
VERSION := $(shell python3 -c "import yaml; f=open('$(YAML_FILE)'); d=yaml.safe_load(f); print(d['info']['version']); f.close()")
TARBALL := $(VERSION).tar.gz
PACKAGE_DIR := package-$(VERSION)
GITHUB_REPO := chipfoundry/$(IP_NAME)

# Files/directories to exclude from package (used in package target)

.PHONY: help
help:
	@echo "Available targets:"
	@echo "  make CF_SRAM_16384x32  - Build the SRAM wrapper macro"
	@echo "  make list                         - List available designs"
	@echo "  make librelane                    - Setup LibreLane environment"
	@echo "  make json                         - Regenerate JSON from YAML"
	@echo "  make package                      - Prepare IPM package directory"
	@echo "  make tarball                      - Create IPM package tarball"
	@echo "  make github-release               - Create GitHub release with tarball"
	@echo "  make release                      - Full release (package + tarball + github-release)"
	@echo ""
	@echo "Environment variables:"
	@echo "  PROJECT_ROOT  - Project root directory (default: current directory)"
	@echo "  PDK           - PDK variant (default: sky130A)"
	@echo "  PDK_ROOT      - Path to PDK root (must be set)"
	@echo "  CF_LIBRELANE_TAG - LibreLane tag (default: CI2511)"
	@echo "  GITHUB_TOKEN - GitHub token for creating releases (required for github-release)"

.PHONY: json
json: $(JSON_FILE)

$(JSON_FILE): $(YAML_FILE) yaml_to_json.py
	@echo "Regenerating $(JSON_FILE) from $(YAML_FILE)..."
	@python3 yaml_to_json.py $(YAML_FILE) $(JSON_FILE)

.PHONY: package
package: json clean-package
	@echo "Preparing IPM package for $(VERSION)..."
	@mkdir -p $(PACKAGE_DIR)
	@if command -v rsync > /dev/null; then \
		rsync -av --progress \
			--exclude='.git' \
			--exclude='.gitignore' \
			--exclude='.DS_Store' \
			--exclude='*.tar.gz' \
			--exclude='package-*' \
			--exclude='openlane' \
			--exclude='Makefile' \
			--exclude='*.log' \
			--exclude='*.tmp' \
			--exclude='__pycache__' \
			--exclude='*.pyc' \
			--exclude='.idea' \
			--exclude='.vscode' \
			$(PROJECT_ROOT)/ $(PACKAGE_DIR)/; \
	else \
		echo "rsync not found, using tar method..."; \
		find $(PROJECT_ROOT) -type f \
			! -path '$(PROJECT_ROOT)/.git/*' \
			! -path '$(PROJECT_ROOT)/package-*' \
			! -path '$(PROJECT_ROOT)/openlane/*' \
			! -name 'Makefile' \
			! -name '*.tar.gz' \
			! -name '*.log' \
			! -name '*.tmp' \
			! -name '*.pyc' \
			! -name '.DS_Store' \
			! -name '.gitignore' \
			-print0 | tar czf $(PACKAGE_DIR)/temp.tar.gz --null -T - -C $(PROJECT_ROOT); \
		cd $(PACKAGE_DIR) && tar xzf temp.tar.gz && rm temp.tar.gz; \
	fi
	@echo "Package prepared in $(PACKAGE_DIR)/"

.PHONY: tarball
tarball: package
	@echo "Creating tarball $(TARBALL)..."
	@cd $(PACKAGE_DIR) && tar czf ../$(TARBALL) *
	@echo "Tarball created: $(TARBALL)"
	@ls -lh $(TARBALL)

.PHONY: github-release
github-release: tarball
	@echo "Creating GitHub release $(VERSION) for $(GITHUB_REPO)..."
	@if command -v gh > /dev/null; then \
		if [ -n "$(GITHUB_TOKEN)" ]; then \
			export GITHUB_TOKEN=$(GITHUB_TOKEN); \
		fi; \
		gh release create $(IP_NAME)-$(VERSION) \
			--repo $(GITHUB_REPO) \
			--title "$(IP_NAME)-$(VERSION)" \
			--notes "Release $(VERSION) of $(IP_NAME)" \
			$(TARBALL) || \
		(echo "Note: If authentication failed, run 'gh auth login' or set GITHUB_TOKEN"; exit 1); \
	else \
		echo "Error: GitHub CLI (gh) not found."; \
		echo "Install it with: brew install gh (macOS) or see https://cli.github.com/"; \
		echo ""; \
		echo "Alternatively, create the release manually:"; \
		echo "  1. Go to: https://github.com/$(GITHUB_REPO)/releases/new"; \
		echo "  2. Tag: $(IP_NAME)-$(VERSION)"; \
		echo "  3. Title: $(IP_NAME)-$(VERSION)"; \
		echo "  4. Upload: $(TARBALL)"; \
		exit 1; \
	fi
	@echo "GitHub release created successfully!"

.PHONY: release
release: github-release
	@echo "Release $(VERSION) completed successfully!"
	@echo "Tarball: $(TARBALL)"
	@echo "GitHub release: https://github.com/$(GITHUB_REPO)/releases/tag/$(VERSION)"

.PHONY: clean-package
clean-package:
	@echo "Cleaning package directory..."
	@rm -rf $(PACKAGE_DIR)
	@echo "Package directory cleaned."

.PHONY: clean-tarball
clean-tarball:
	@echo "Cleaning tarball..."
	@rm -f $(TARBALL)
	@echo "Tarball cleaned."

.PHONY: clean-release
clean-release: clean-package clean-tarball
	@echo "Release artifacts cleaned."

