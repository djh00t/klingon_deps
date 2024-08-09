# klingon_deps/cli.py

import argparse
from .config_manager import ConfigManager
from .language_detector import LanguageDetector
from .dependency_manager import DependencyManager


def main():
    parser = argparse.ArgumentParser(
        description="Klingon Deps - Dependency Management Tool"
    )
    parser.add_argument(
        "--verbose", action="store_true", help="Enable verbose logging"
    )
    parser.add_argument(
        "--scan", action="store_true", help="Scan the repository for languages"
    )
    args = parser.parse_args()

    config_manager = ConfigManager()

    dep_manager = DependencyManager(verbose=args.verbose)

    # Step 1: Install klingon_deps requirements
    if not dep_manager.install_dependencies():
        print("Failed to install dependencies. Exiting.")
        return

    if args.scan:
        # Step 2: Check the languages in the current repo
        detector = LanguageDetector(
            verbose=args.verbose, config_manager=config_manager
        )
        detected_languages = detector.detect_languages()

        if detected_languages:
            # Step 3: User interactive enable/disable prompt
            language_status = detector.prompt_user_for_languages(
                detected_languages
            )

            # Step 4: Print language activation status
            detector.print_language_activation_status(language_status)
        else:
            print(
                "No languages detected or there was an error in language "
                "detection."
            )


if __name__ == "__main__":
    main()
