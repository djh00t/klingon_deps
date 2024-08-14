#!/bin/bash

# Run semantic-release
echo "Running semantic-release..."
npx semantic-release

# Check if semantic-release was successful
if [ $? -eq 0 ]; then
    echo "semantic-release completed successfully"

    # Extract the new version from package.json
    NEW_VERSION=$(grep '"version":' package.json | sed 's/.*"version": "\(.*\)",/\1/')
    echo "New version: $NEW_VERSION"

    # Update the version in pyproject.toml
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Detected macOS"
        sed -i '' -e "s/^version = \".*\"/version = \"$NEW_VERSION\"/" ./pyproject.toml
    else
        echo "Detected Linux"
        sed -i -e "s/^version = \".*\"/version = \"$NEW_VERSION\"/" ./pyproject.toml
    fi

    # Commit and push the changes
    git config --local user.email "github-actions[bot]@users.noreply.github.com"
    git config --local user.name "github-actions[bot]"
    git add pyproject.toml
    git commit -m "chore: update pyproject.toml to $NEW_VERSION [skip ci]"
    git push
else
    echo "semantic-release failed"
    exit 1
fi
