# Klingon Deps

Klingon Deps is a dependency management library for multi-language projects.

## Features

- Scan repositories for programming languages
- Manage language configurations in `.klingon_user.yaml`
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

Install dependencies:
```
klingon_deps
```

## Configuration Files

### 1. `.klingon_pkg_deps.yaml`

This is the main dependency configuration file. It should be located in the root of the repository by default.

### 2. `.klingon_user.yaml`

This file contains user-specific configurations, including enabled languages.

## Dependency Resolution Process

1. The tool first looks for `.klingon_pkg_deps.yaml` in the root of the repository.
2. If not found, it checks for a file specified by the `--pkgdep` argument.
3. If neither is found, it looks for `.klingon_user.yaml` in the root of the repository.
4. If none of the above files are found, it runs a scan process over the current repository to generate a configuration.

## `.klingon_pkg_deps.yaml` File Format

The `.klingon_pkg_deps.yaml` file specifies project dependencies. It supports OS-specific, language-specific, and general dependencies. Here's the format:

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

### Example `.klingon_pkg_deps.yaml`:

```yaml
dependencies:
  - name: requests
    version: ">=2.25.1"
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

## `.klingon_user.yaml` File Format

This file contains user-specific configurations, including enabled languages.

```yaml
enabled_languages:
  - python
  - javascript
  - rust

user_preferences:
  default_package_manager: pip
  auto_update: true
```

The `klingon_deps` tool will process these files and install the dependencies based on the current operating system, specified languages, and other criteria.

## License

This project is licensed under the MIT License.
