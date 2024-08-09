# klingon_deps/config_manager.py

import yaml
import os
import git


class ConfigManager:
    def __init__(self, user_config_path=".klingon_user.yaml"):
        self.user_config_path = user_config_path
        self.pkg_dep_paths = [
            os.path.join(
                os.path.dirname(__file__), ".klingon_pkg_deps.yaml"
            ),  # In klingon_deps directory
            self._find_git_root_config(),  # In git repo root
        ]

    def _find_git_root_config(self):
        try:
            repo = git.Repo(os.getcwd(), search_parent_directories=True)
            git_root = repo.git.rev_parse("--show-toplevel")
            return os.path.join(git_root, ".klingon_pkg_deps.yaml")
        except git.InvalidGitRepositoryError:
            return None

    def read_user_config(self):
        """Read the user configuration file."""
        try:
            with open(self.user_config_path, "r") as f:
                return yaml.safe_load(f) or {}
        except FileNotFoundError:
            return {}

    def write_user_config(self, config):
        """Write the user configuration file."""
        with open(self.user_config_path, "w") as f:
            yaml.dump(config, f)

    def read_pkg_dep(self):
        """Read the package dependency file."""
        for path in self.pkg_dep_paths:
            if path and os.path.exists(path):
                with open(path, "r") as f:
                    return yaml.safe_load(f) or {}
        return {}

    def get_enabled_languages(self):
        """Get the list of enabled languages."""
        config = self.read_user_config()
        return config.get("enabled_languages", [])

    def get_disabled_languages(self):
        """Get the list of disabled languages."""
        config = self.read_user_config()
        return config.get("disabled_languages", [])

    def update_language(self, language, enabled):
        """Update the status of a language in the user config."""
        config = self.read_user_config()
        enabled_languages = config.setdefault("enabled_languages", [])
        disabled_languages = config.setdefault("disabled_languages", [])

        if enabled:
            if language not in enabled_languages:
                enabled_languages.append(language)
            if language in disabled_languages:
                disabled_languages.remove(language)
        else:
            if language not in disabled_languages:
                disabled_languages.append(language)
            if language in enabled_languages:
                enabled_languages.remove(language)

        self.write_user_config(config)
