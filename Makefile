# Makefile for klingon-deps Python package

# Variables
APP_NAME = "klingon-deps"
TWINE_USERNAME ?= __token__
TEST_TWINE_PASSWORD ?= $(TEST_PYPI_USER_AGENT)
PYPI_TWINE_PASSWORD ?= $(PYPI_USER_AGENT)

# Fetch the latest Node.js version
fetch-latest-node-version:
	@echo "Fetching the latest Node.js version..."
	@curl -s https://nodejs.org/dist/index.json | grep '"version"' | head -1 | awk -F'"' '{print $$4}' > .latest_node_version
	@echo "Latest Node.js version fetched: $$(cat .latest_node_version)"

# Install the latest version of nvm
install-latest-nvm:
	@echo "Installing the latest version of nvm..."
	@LATEST_NVM_VERSION=$$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | grep -oE '"tag_name": "[^"]+"' | cut -d'"' -f4) && \
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$$LATEST_NVM_VERSION/install.sh | bash

# Ensure that the latest Node.js and npm are installed
ensure-node: fetch-latest-node-version install-latest-nvm
	@if [ "$$(uname)" = "Linux" ]; then \
		if [ -f /etc/debian_version ]; then \
			echo "Detected Debian-based Linux. Installing Node.js $$(cat .latest_node_version)..."; \
			curl -sL https://deb.nodesource.com/setup_$$(cat .latest_node_version | cut -d'.' -f1).x | sudo bash -; \
			sudo apt-get install -y nodejs; \
		else \
			echo "Unsupported Linux distribution. Exiting..."; \
			exit 1; \
		fi \
	elif [ "$$(uname)" = "Darwin" ]; then \
		echo "Detected macOS. Checking for Homebrew..."; \
		if ! command -v brew >/dev/null 2>&1; then \
			echo "Homebrew not found. Installing Homebrew..."; \
			/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
		fi; \
		NODE_MAJOR_VERSION=$$(cat .latest_node_version | cut -d'.' -f1 | tr -d 'v'); \
		if brew ls --versions node@$$NODE_MAJOR_VERSION > /dev/null; then \
			echo "Installing Node.js $$NODE_MAJOR_VERSION using Homebrew..."; \
			brew install node@$$NODE_MAJOR_VERSION; \
		else \
			echo "Specific Node.js version not available in Homebrew. Installing using nvm..."; \
			export NVM_DIR="$$HOME/.nvm"; \
			[ -s "$$NVM_DIR/nvm.sh" ] && \. "$$NVM_DIR/nvm.sh"; \
			nvm install $$(cat .latest_node_version); \
			nvm use $$(cat .latest_node_version); \
		fi; \
	else \
		echo "Unsupported OS. Exiting..."; \
		exit 1; \
	fi

# Ensure that semantic-release is installed
ensure-semantic-release:
	@npm list -g --depth=0 | grep semantic-release >/dev/null 2>&1 || { \
		echo >&2 "semantic-release is not installed. Installing..."; \
		npm install -g semantic-release; \
	}

# Clean the repository
clean:
	@echo "Cleaning up repo............................................................. 🧹"
	@pre-commit clean
	@find . -type f -name '*.pyc' -delete
	@find . -type d -name '__pycache__' -exec rm -rf {} +
	@find . -type f -name '.aider*' ! -path './.aider_logs/*' -delete
	@find . -type d -name '.aider*' ! -path './.aider_logs' -exec rm -rf {} +
	@rm -rf .coverage
	@rm -rf .mypy_cache
	@rm -rf .pytest_cache
	@rm -rf .tox
	@rm -rf *.egg-info
	@rm -rf build
	@rm -rf dist
	@rm -rf htmlcov
	@rm -rf node_modules
	@echo "Repo cleaned up............................................................... ✅"

# Check for required pip packages and install if missing
check-packages:
	@echo "Checking for required pip packages..."
	@poetry install

# Create a source distribution package
sdist: clean
	poetry build --format sdist

# Create a wheel distribution package
wheel: clean
	poetry build --format wheel

# Upload to TestPyPI
upload-test: test wheel
	@echo "Uploading Version $$NEW_VERSION to TestPyPI..."
	poetry publish --repository testpypi -u $(TWINE_USERNAME) -p $(TEST_TWINE_PASSWORD)

# Upload to PyPI
upload: test wheel
	@echo "Uploading Version $$NEW_VERSION to PyPI..."
	poetry publish -u $(TWINE_USERNAME) -p $(PYPI_TWINE_PASSWORD)

# Install the package locally
install:
	@echo "Checking for requirements..."
	@make check-packages
	@echo "Installing $$APP_NAME..."
	poetry install

# Uninstall the local package
uninstall:
	poetry remove $(APP_NAME)

# Run tests
test:
	@echo "Running unit tests..."
	poetry run pytest -v --tb=short tests/

# Perform a semantic release
release: ensure-node ensure-semantic-release
	@echo "Starting semantic release..."
	@semantic-release

# Generate a pyproject.toml file (if not present)
generate-pyproject:
	@echo "[build-system]" > pyproject.toml
	@echo "requires = ['setuptools', 'wheel']" >> pyproject.toml
	@echo "build-backend = 'setuptools.build_meta'" >> pyproject.toml

# Prepare for a push (tagging, etc.)
push-prep:
	@echo "Preparing for push..."
	@poetry version patch
	@git add pyproject.toml poetry.lock
	@git commit -m "Bump version"
	@git tag -a "v$$(poetry version --short)" -m "Release v$$(poetry version --short)"
	@git push origin main --tags

# Poetry specific targets
install-poetry:
	@poetry install

# Set up the project for development
develop:
	@poetry install
	@poetry shell

# Run tests using poetry
poetry-test:
	@poetry run pytest

# Build the project using poetry
poetry-build:
	@poetry build

.PHONY: clean check-packages sdist wheel upload-test upload install uninstall test release ensure-node ensure-semantic-release install-latest-nvm generate-pyproject push-prep install-poetry develop poetry-test poetry-build
