# Klingon Deps

Klingon Deps is a dependency management library for multi-language projects.

## Features

- Scan repositories for programming languages
- Manage language configurations in `.kdepsrc`
- Install dependencies from YAML configuration files

## Installation

```
pip install klingon_deps
```

## Usage

Scan repository and configure languages:
```
klingon_deps --scan
```

Install dependencies from YAML file:
```
klingon_deps --pkgdep dependencies.yaml
```

## Dependencies YAML File Format

The `dependencies.yaml` file specifies project dependencies. It supports OS-specific, language-specific, and general dependencies. Here's the format:

```yaml
dependencies:
  - name: dependency_name
    version: version_specifier
    type: dependency_type
    os: operating_system
    language: programming_language
    manager: package_manager
    command: install_command

```

### Fields:

- `name`: (Required) Name of the dependency.
- `version`: (Optional) Version specifier (e.g., ">=1.0.0", "==2.1.0").
- `type`: (Optional) Type of dependency (e.g., "library", "tool", "framework").
- `os`: (Optional) Operating system (e.g., "linux", "macos", "windows", "all").
- `language`: (Optional) Programming language (e.g., "python", "javascript", "rust").
- `manager`: (Optional) Package manager to use (e.g., "pip", "npm", "cargo").
- `command`: (Optional) Custom install command if the standard package manager command doesn't suffice.

### Example `dependencies.yaml`:

```yaml
dependencies:
  - name: requests
    version: ">=2.25.1"
    type: library
    language: python
    manager: pip

  - name: numpy
    version: "==1.21.0"
    type: library
    language: python
    manager: pip

  - name: nodejs
    version: "14.x"
    type: runtime
    os: linux
    command: |
      curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash -
      sudo apt-get install -y nodejs

  - name: rust
    type: language
    os: all
    command: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

  - name: docker
    type: tool
    os: macos
    command: brew install docker

  - name: gcc
    type: compiler
    os: linux
    command: sudo apt-get install build-essential

  - name: react
    version: "^17.0.2"
    type: framework
    language: javascript
    manager: npm

  - name: sqlalchemy
    version: ">=1.4.0"
    type: library
    language: python
    manager: pip
    os: all
```

This example includes various types of dependencies:
- Language-specific libraries (requests, numpy, react, sqlalchemy)
- Runtime environments (nodejs)
- Programming languages (rust)
- Development tools (docker, gcc)

The `klingon_deps` tool will process this file and install the dependencies based on the current operating system, specified languages, and other criteria.

## License

This project is licensed under the MIT License.
