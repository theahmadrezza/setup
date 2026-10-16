# Post-Install Setup

![Shell](https://img.shields.io/badge/built%20with-Shell-4EAA25?style=flat-square&logo=gnubash&logoColor=white)
![License](https://img.shields.io/github/license/theahmadrezza/Sh-Lab?style=flat-square)
![Personal Setup](https://img.shields.io/badge/setup-personal-blue?style=flat-square)

> ***Fresh install. Familiar environment. Less repetition.***

A personal collection of shell scripts and configuration files for setting up a freshly installed operating system — downloading useful files, installing command-line tools, and applying preferred settings.

![Project banner](assets/banner.png)

## About

Every fresh OS installation used to come with the same checklist: download files, install tools, and configure the environment.

This repository turns that routine into a scripted workflow. The main setup lives in [`src/main.sh`](src/main.sh), alongside personal configuration files, wallpapers, supporting data, and utility scripts.

This is a personal setup, not a universal installer. Review the scripts and adapt them to your system before running them.

## Project Structure

    .
    ├── .vscode
    │   └── settings.json
    ├── assets
    │   ├── misc
    │   │   ├── data-backup.json
    │   │   └── links.txt
    │   ├── wallpapers
    │   │   └── 1.png
    │   └── banner.jpg
    ├── configs
    │   ├── .gitconfig
    │   ├── .sqliterc
    │   └── .wezterm.lua
    ├── db
    │   └── data.json
    ├── scripts
    │   ├── create_python_app.sh
    │   └── git_squash_all_history.sh
    ├── src
    │   └── main.sh
    ├── .editorconfig
    ├── .gitignore
    ├── .shellcheckrc
    ├── LICENSE
    └── README.md

## Getting Started

### 1. Get the Repository

Clone the repository and open its root directory:

    git clone https://github.com/theahmadrezza/setup.git
    cd setup

Alternatively, download and extract the source archive from GitHub.

### 2. Review and Customize

Open `src/main.sh` and adjust the tools, paths, and settings to suit your needs.

### 3. Make the Entry Point Executable

    chmod +x src/main.sh

### 4. Run the Setup

From the repository root:

    ./src/main.sh

Running from the repository root helps preserve any relative paths used by the script.

## Contributing

This repository reflects my personal workflow, but bug reports, corrections, and suggestions are welcome.

Before submitting a change:

1. Keep changes focused and explain their purpose.
2. Document any new dependencies or system requirements.
3. Clearly describe commands that modify existing configuration or require elevated privileges.
4. Check modified scripts with ShellCheck and shfmt.
5. Update documentation when changing file paths or setup behavior.

## License

See [LICENSE](LICENSE) for the terms of use.
