import sys
from .config_manager import ConfigManager
from .dependency_manager import DependencyManager
from .language_detector import LanguageDetector


def main():
    config_manager = ConfigManager()
    dep_manager = DependencyManager(verbose=True)  # Assume verbose for now
    detector = LanguageDetector(verbose=True, config_manager=config_manager)

    if not dep_manager.install_dependencies():
        print("Failed to install dependencies. Exiting.")
        sys.exit(1)  # This will raise SystemExit

    detected_languages = detector.detect_languages()

    if detected_languages:
        language_status = detector.prompt_user_for_languages(
            detected_languages
        )
        detector.print_language_activation_status(language_status)
    else:
        print(
            "No languages detected or there was an error in language "
            "detection."
        )


if __name__ == "__main__":
    main()
