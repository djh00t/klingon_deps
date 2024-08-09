from setuptools import setup, find_packages

setup(
    name="klingon_deps",
    version="0.1.0",
    packages=find_packages(),
    install_requires=[
        "pyyaml",
    ],
    entry_points={
        "console_scripts": [
            "klingon-deps=klingon_deps.cli:main",
        ],
    },
)
