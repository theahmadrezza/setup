#!/usr/bin/env bash

set -Eeuo pipefail

create_python_app() {

    local working_directory
    local python_app_name

    read -rei "Py_Lab" -p "? Type Python app name: " python_app_name

    working_directory="${HOME}/Documents/${python_app_name}"

    if [[ -e "${working_directory}" ]]; then
        printf "E: The Python project path already exists: %s\n" "${working_directory}" >&2
        return 1
    fi

    uv init --no-package "${working_directory}"

    mkdir -p "${working_directory}"/{.vscode,src}
    touch "${working_directory}"/{.vscode/settings.json,README.md,LICENSE}

    if [[ -f "${working_directory}/main.py" ]]; then
        mv "${working_directory}/main.py" "${working_directory}/src/main.py" || true
    fi

    clear
    printf "The Python project '%s' was created successfully at '%s'.\n" "${python_app_name}" "${working_directory}"

}

create_python_app
