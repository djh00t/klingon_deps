import subprocess
import shutil


def test_simple():
    assert True


def test_pr_title_generate_command():
    # Check if the command exists
    assert (
        shutil.which("pr-title-generate") is not None
    ), "pr-title-generate command not found"

    # Run the command and check its output
    try:
        result = subprocess.run(
            ["pr-title-generate"], capture_output=True, text=True, check=True
        )
        assert (
            result.stdout.strip()
        ), "pr-title-generate command returned empty output"
    except subprocess.CalledProcessError as e:
        assert (
            False
        ), f"pr-title-generate command failed with error: {e.stderr}"
