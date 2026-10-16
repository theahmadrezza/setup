#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(realpath "$(dirname -- "${BASH_SOURCE[0]}")/..")"
DB_PATH="${PROJECT_ROOT}/db/data.json"

check_prerequisites() {

    local -a prerequisites=("bash" "wget" "git" "jq")
    local item

    for item in "${prerequisites[@]}"; do
        if ! command -v "${item}" &>/dev/null; then
            printf "info: %s missing.\n" "${item}" >&2
            return 1
        fi
    done

    if [[ ! -r "${DB_PATH}" ]]; then
        printf "info: Database file missing or unreadable: %s\n" "${DB_PATH}" >&2
        return 1
    fi

    printf "info: %s\n" "All prerequisites met."

}

sync_configs() {

    mkdir -p "${HOME}/.local/share/wallpapers"
    mkdir -p "${HOME}/.local/share/fonts"
    mkdir -p "${HOME}/.local/bin"

    cp "${PROJECT_ROOT}/scripts/create_python_app.sh" "${HOME}/.local/bin/create_python_app"
    cp "${PROJECT_ROOT}/assets/wallpapers/1.png" "${HOME}/.local/share/wallpapers"
    cp "${PROJECT_ROOT}/configs/.wezterm.lua" "${HOME}"
    cp "${PROJECT_ROOT}/configs/.gitconfig" "${HOME}"
    cp "${PROJECT_ROOT}/configs/.sqliterc" "${HOME}"

    chmod +x "${HOME}/.local/bin/create_python_app"

    printf "info: %s\n" "All configuration files synchronized."

}

fetch_utilities() {

    local -a owner_repo_arr
    local owner_repo
    local raw_json
    local pattern
    local item

    owner_repo=$(jq -r '.[].url | ltrimstr("https://github.com/")' "${DB_PATH}")
    mapfile -t owner_repo_arr <<<"${owner_repo}"

    for item in "${owner_repo_arr[@]}"; do
        raw_json=$(wget -qO- "https://api.github.com/repos/${item}/releases/latest") || true
        jq -r '.assets[]?.browser_download_url' <<<"${raw_json}"
        printf "%b" "\n"
        read -rp "Please type the pattern: " pattern
        wget -nv -nc -c -t 0 -T 15 -P ~/Downloads/setup "${pattern}"
        clear
    done

}

main() {
    check_prerequisites
    sync_configs
    printf "%b" "\n"
    fetch_utilities
}

main
