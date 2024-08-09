# klingon_deps/dependency_manager.py

import logging
import subprocess
import platform


class DependencyManager:
    def __init__(self, verbose=False):
        self.verbose = verbose
        self.logger = self._setup_logger()

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

    def install_dependencies(self):
        os_type = (
            "macos" if platform.system() == "Darwin" else "linux"
        )  # Simplified OS detection
        self.logger.info(f"Starting github-linguist {os_type} installation")
        self.logger.info("Checking for dependencies")

        dependencies = [
            ("rbenv", "rbenv --version"),
            ("Ruby", "ruby --version"),
            ("github-linguist", "github-linguist --version"),
        ]

        for dep_name, check_cmd in dependencies:
            try:
                result = subprocess.run(
                    check_cmd,
                    shell=True,
                    check=True,
                    capture_output=True,
                    text=True,
                )
                self.logger.info(
                    f"Installing {dep_name}: {result.stdout.strip()}"
                )
            except subprocess.CalledProcessError:
                self.logger.error(
                    f"Failed to verify {dep_name}. Please install it manually."
                )
                return False

        self.logger.info("All dependencies installed successfully")
        return True
