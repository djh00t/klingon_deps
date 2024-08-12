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
			curl -sL https://deb.nodesource.com/setup_$$(cat .latest_node_version | cut -d'.' -f1).x | bash -; \
			apt-get install -y nodejs; \
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
	@echo "Removing temporary files.................................................... 🧹"
	@find . -type f -name '*.pyc' -delete
	@if [ -f requirements.txt ]; then \
		echo "Resetting requirements.txt to empty state................................... ✅"; \
		rm -rf requirements.txt; \
		touch requirements.txt; \
	fi
	@if [ -f requirements-dev.txt ]; then \
		echo "Resetting requirements-dev.txt to empty state............................... ✅"; \
		rm -rf requirements-dev.txt; \
		touch requirements-dev.txt; \
	fi
	@echo "Removed temporary files..................................................... ✅"

# Check for required pip packages and requirements.txt, install if missing
check-packages:
	@echo "Installing pip-tools..."
	@pip install pip-tools
	@echo "Compiling requirements.txt..."
	@pip-compile requirements.in
	@echo "Checking for required pip packages and requirements.txt..."
	@if [ ! -f requirements.txt ]; then \
		echo "requirements.txt not found. Please add it to the project root."; \
		exit 1; \
	fi
	@echo "Installing missing packages from requirements.txt..."
	@pip install -r requirements.txt
	@pre-commit install --overwrite

# Create a source distribution package
sdist: clean
	python setup.py sdist

# Create a wheel distribution package
wheel: clean
	python setup.py sdist bdist_wheel

# Upload to TestPyPI
upload-test: test wheel
	@echo "Uploading Version $$NEW_VERSION to TestPyPI..."
	twine upload --repository-url https://test.pypi.org/legacy/ --username $(TWINE_USERNAME) --password $(TEST_TWINE_PASSWORD) dist/*

# Upload to PyPI
upload: test wheel
	@echo "Uploading Version $$NEW_VERSION to PyPI..."
	twine upload --username $(TWINE_USERNAME) --password $(PYPI_TWINE_PASSWORD) dist/*

# Install the package locally
install:
	@echo "Checking for requirements..."
	@make check-packages
	@echo "Installing $$APP_NAME..."
	@pip install -e .

# Install the package locally using pip
install-pip:
	pip install $(APP_NAME)

# Install the package locally using pip from TestPyPI
install-pip-test:
	pip install --index-url https://test.pypi.org/simple/ --extra-index-url https://pypi.org/simple $(APP_NAME)

# Uninstall the local package
uninstall:
	pip uninstall $(APP_NAME)

# Run tests
test:
	@echo "Running unit tests..."
	@make poetry-test
#	pytest -v --tb=short tests/
#	pytest --no-header --no-summary -v --disable-warnings tests/

# Perform a semantic release
release: ensure-node ensure-semantic-release
	@echo "Starting semantic release..."
	@semantic-release

# Generate a pyproject.toml file
generate-pyproject:
	@echo "[build-system]" > pyproject.toml
	@echo "requires = ['setuptools', 'wheel']" >> pyproject.toml
	@echo "build-backend = 'setuptools.build_meta'" >> pyproject.toml

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

.PHONY: clean check-packages sdist wheel upload-test upload install uninstall test release ensure-node ensure-semantic-release install-latest-nvm generate-pyproject install-poetry develop poetry-test poetry-build
