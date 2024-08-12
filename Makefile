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
	@make push-prep
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

# Pre-push cleanup target
push-prep:
	@echo "Running poetry lock........................................................... 🔒"
	@poetry lock
	@echo "Removing temporary files.................................................... 🧹"
	@find . -type f -name '*.pyc' -delete
	@echo "Removed temporary files..................................................... ✅"

# Check for required pip packages and install if missing
check-packages:
	@echo "Checking for Poetry installation..."
	@if ! command -v poetry &> /dev/null; then \
		echo "Poetry not found. Installing Poetry."; \
		curl -sSL https://install.python-poetry.org | python3 -; \
	fi
	@echo "Poetry is installed. Checking dependencies..."
	@poetry install

# Create a source distribution package
sdist: clean
	@echo "Creating source distribution..."
	@poetry build --format sdist

# Create a wheel distribution package
wheel: clean
	@echo "Creating wheel distribution..."
	@poetry build --format wheel

# Upload to TestPyPI
upload-test: test wheel
	@echo "Uploading Version to TestPyPI..."
	@poetry publish --repository testpypi --username $(TWINE_USERNAME) --password $(TEST_TWINE_PASSWORD)

# Upload to PyPI
upload: test wheel
	@echo "Uploading Version to PyPI..."
	@poetry publish --username $(TWINE_USERNAME) --password $(PYPI_TWINE_PASSWORD)

# Install the package locally
install:
	@echo "Installing dependencies..."
	@poetry install

# Uninstall the local package
uninstall:
	@echo "Uninstalling $(APP_NAME)..."
	@poetry remove $(APP_NAME)

# Run tests
test:
	@echo "Running unit tests..."
	@poetry run pytest

# Get developer information
get-developer-info:
	@echo "Fetching commit author information..."
	@COMMIT_AUTHOR=$$(git log -1 --pretty=format:'%an')
	@echo "This code was committed by $$COMMIT_AUTHOR"

# Perform a semantic release
release: ensure-node ensure-semantic-release
	@echo "Starting semantic release..."
	@semantic-release

.PHONY: clean check-packages sdist wheel upload-test upload install uninstall test push-prep get-developer-info release
