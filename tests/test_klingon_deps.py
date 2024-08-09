import pytest
from unittest.mock import patch, MagicMock
from klingon_deps.cli import main


@pytest.fixture
def mock_dependencies():
    with (
        patch("klingon_deps.cli.ConfigManager") as mock_config,
        patch("klingon_deps.cli.DependencyManager") as mock_dep,
        patch("klingon_deps.cli.LanguageDetector") as mock_detector,
    ):

        mock_config_instance = MagicMock()
        mock_dep_instance = MagicMock()
        mock_detector_instance = MagicMock()

        mock_config.return_value = mock_config_instance
        mock_dep.return_value = mock_dep_instance
        mock_detector.return_value = mock_detector_instance

        mock_dep_instance.install_dependencies.return_value = True
        mock_detector_instance.detect_languages.return_value = [
            ("Python", "100.00%")
        ]
        mock_detector_instance.prompt_user_for_languages.return_value = {
            "Python": True
        }

        yield mock_config_instance, mock_dep_instance, mock_detector_instance


def test_main_runs_without_error(mock_dependencies):
    mock_config, mock_dep, mock_detector = mock_dependencies

    with patch("sys.argv", ["klingon-deps"]):
        main()

    assert mock_dep.install_dependencies.called
    assert mock_detector.detect_languages.called
    assert mock_detector.prompt_user_for_languages.called
    assert mock_detector.print_language_activation_status.called


def test_main_handles_dependency_installation_failure(mock_dependencies):
    mock_config, mock_dep, mock_detector = mock_dependencies
    mock_dep.install_dependencies.return_value = False

    with patch("sys.argv", ["klingon-deps"]):
        with pytest.raises(SystemExit):
            main()

    assert not mock_detector.detect_languages.called


def test_main_handles_no_languages_detected(mock_dependencies):
    mock_config, mock_dep, mock_detector = mock_dependencies
    mock_detector.detect_languages.return_value = []

    with patch("sys.argv", ["klingon-deps"]):
        main()

    assert mock_detector.detect_languages.called
    assert not mock_detector.prompt_user_for_languages.called
    assert not mock_detector.print_language_activation_status.called
