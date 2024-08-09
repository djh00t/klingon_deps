# klingon_deps/language_detector.py

import subprocess
import logging
from typing import List, Dict, Tuple
from .config_manager import ConfigManager
from tabulate import tabulate


class LanguageDetector:
    def __init__(
        self,
        repo_path: str = ".",
        verbose: bool = False,
        config_manager: ConfigManager = None,
    ):
        self.repo_path = repo_path
        self.verbose = verbose
        self.logger = self._setup_logger()
        self.config_manager = config_manager or ConfigManager()
        self.detected_languages = []

    def _setup_logger(self):
        logger = logging.getLogger(__name__)
        logger.setLevel(logging.DEBUG if self.verbose else logging.INFO)
        if not logger.handlers:
            handler = logging.StreamHandler()
            formatter = logging.Formatter(
                "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
            )
            handler.setFormatter(formatter)
            logger.addHandler(handler)
        return logger

    def _log_table(self, message):
        """Log a message without timestamp and logger info."""
        print(message)

    def detect_languages(self) -> List[Tuple[str, str]]:
        self.logger.info("Checking languages in repository")
        try:
            result = subprocess.run(
                ["github-linguist", self.repo_path],
                capture_output=True,
                text=True,
                check=True,
            )
            self.detected_languages = []
            for line in result.stdout.splitlines():
                parts = line.strip().split()
                if len(parts) >= 2:
                    percentage = parts[0]
                    language = parts[
                        -1
                    ]  # Take the last part as the language name
                    self.detected_languages.append((language, percentage))
                else:
                    self.logger.warning(f"Unexpected output format: {line}")

            self._print_detected_languages_table()
            return self.detected_languages
        except subprocess.CalledProcessError as e:
            self.logger.error(f"Failed to run github-linguist: {e}")
            return []

    def _print_detected_languages_table(self):
        if not self.detected_languages:
            return

        self.logger.info("Detected languages:")
        headers = ["Language", "Percentage"]
        table = tabulate(
            self.detected_languages, headers=headers, tablefmt="fancy_grid"
        )
        self._log_table(table)

    def prompt_user_for_languages(
        self, detected_languages: List[Tuple[str, str]]
    ) -> Dict[str, bool]:
        """Prompt user to activate/deactivate detected languages if not in
        config."""
        enabled_languages = set(self.config_manager.get_enabled_languages())
        disabled_languages = set(self.config_manager.get_disabled_languages())

        language_status = {}
        for lang, _ in detected_languages:
            if lang in enabled_languages:
                language_status[lang] = True
                self.logger.info(f"{lang} is already enabled")
            elif lang in disabled_languages:
                language_status[lang] = False
                self.logger.info(f"{lang} is already disabled")
            else:
                response = input(f"Enable {lang}? (y/n): ").lower().strip()
                language_status[lang] = response == "y"
                self.config_manager.update_language(
                    lang, language_status[lang]
                )
                status = "enabled" if language_status[lang] else "disabled"
                self.logger.info(f"{lang} has been {status}")

        return language_status

    def print_language_activation_status(
        self, language_status: Dict[str, bool]
    ):
        headers = ["Language", "Status"]
        table_data = [
            (lang, "Activated" if status else "Deactivated")
            for lang, status in language_status.items()
        ]
        table = tabulate(table_data, headers=headers, tablefmt="fancy_grid")
        self._log_table("Language Activation Status:")
        self._log_table(table)


# The main function can be removed if it's no longer needed here
