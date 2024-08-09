# Klingon Deps

Klingon Deps is a powerful Python library for managing project dependencies across multiple programming languages. It leverages GitHub Linguist to detect languages in your project and provides an interactive interface for enabling or disabling language-specific dependencies.

## Features

- Automatic language detection using GitHub Linguist
- Interactive language activation/deactivation
- Support for multiple programming languages
- Customizable dependency configuration
- Git repository awareness

## Installation

You can install Klingon Deps using pip:

```bash
pip install klingon-deps
```

## Requirements

- Python 3.7+
- GitHub Linguist
- GitPython

## Quick Start

1. Install Klingon Deps in your project:

```bash
pip install klingon-deps
```

2. Run the Klingon Deps command to detect languages and set up dependencies:

```bash
klingon-deps
```

3. Follow the interactive prompts to enable or disable detected languages.

## Usage

### Command Line Interface

The primary way to use Klingon Deps is through its command-line interface:

```bash
klingon-deps [options]
```

Options:
- `--verbose`: Enable verbose logging
- `--scan`: Scan the repository for languages (default behavior)

### As a Python Library

You can also use Klingon Deps as a Python library in your scripts:

```python
from klingon_deps import LanguageDetector, ConfigManager

# Initialize the config manager and language detector
config_manager = ConfigManager()
detector = LanguageDetector(verbose=True, config_manager=config_manager)

# Detect languages
detected_languages = detector.detect_languages()

# Print detected languages
print("Detected Languages:")
for lang, percentage in detected_languages:
    print(f"{lang}: {percentage}")

# Prompt user for language activation
language_status = detector.prompt_user_for_languages(detected_languages)

# Print language activation status
detector.print_language_activation_status(language_status)
```

## Configuration

### .klingon_pkg_dep.yaml

This file defines the dependencies for each supported language. Klingon Deps looks for this file in the following locations, in order:

1. In the `klingon_deps` directory of the installed package
2. In the root of your Git repository

Example `.klingon_pkg_dep.yaml`:

```yaml
dependencies:
  - name: github-linguist
    type: tool
    install:
      macos:
        - brew install github-linguist
      ubuntu:
        - sudo apt-get install -y github-linguist

  - name: python
    type: language
    install:
      macos:
        - brew install python
      ubuntu:
        - sudo apt-get install -y python3

  # Add more language-specific dependencies here
```

### .klingon_user.yaml

This file stores user-specific configurations, including enabled and disabled languages. It's typically located in the root of your project.

Example `.klingon_user.yaml`:

```yaml
enabled_languages:
  - Python
  - JavaScript

disabled_languages:
  - Ruby
```

## Examples

### Scanning a Repository

To scan your current repository for languages and set up dependencies:

```bash
cd /path/to/your/repo
klingon-deps
```

This will detect languages, prompt you to enable/disable them, and update your `.klingon_user.yaml` file.

### Using a Custom Dependency File

If you have a custom dependency file location:

```bash
klingon-deps --pkgdep /path/to/custom/.klingon_pkg_dep.yaml
```

### Verbose Output

For more detailed logging:

```bash
klingon-deps --verbose
```

## Contributing

We welcome contributions to Klingon Deps! Please see our [Contributing Guide](CONTRIBUTING.md) for more details.

## License

Klingon Deps is released under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Support

If you encounter any issues or have questions, please file an issue on the [GitHub issue tracker](https://github.com/yourusername/klingon_deps/issues).

## Acknowledgements

Klingon Deps makes use of the excellent [GitHub Linguist](https://github.com/github/linguist) tool for language detection.
