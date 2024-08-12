#!/bin/bash

# List of packages to check
PACKAGES=(
  GitPython
  PyYAML
  tabulate
  pytest
  pytest-mock
  black
  flake8
  pylint
  yapf
  mypy
  pre-commit
  pip-tools
  twine
  wheel
  poetry
  klingon_tools
  jinja2
)

# Function to get the latest version of a PyPI package
get_latest_pypi_version() {
  PACKAGE_NAME=$1
  LATEST_VERSION=$(curl -s https://pypi.org/pypi/$PACKAGE_NAME/json | jq -r .info.version)
  if [ -z "$LATEST_VERSION" ]; then
    echo "Package $PACKAGE_NAME not found on PyPI."
  else
    echo "$PACKAGE_NAME = \">=$LATEST_VERSION\""
  fi
}

# Loop through the list of packages and get their latest versions
for PACKAGE in "${PACKAGES[@]}"; do
  get_latest_pypi_version "$PACKAGE"
done
