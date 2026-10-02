#!/usr/bin/env bash

# Enable strict mode
set -euo pipefail

PROJECT_ROOT="$(realpath "$(dirname -- "${BASH_SOURCE[0]}")/..")"
export PATH="${PROJECT_ROOT}/bin:${PATH}"

RESET=$(tput sgr0)
BOLD=$(tput bold)

check_prerequisites() {

    local -a prerequisites=("git")
    local item

    printf "info: ${BOLD}%s${RESET}\n" "Checking prerequisites..."

    for item in "${prerequisites[@]}"; do
        if ! command -v "${item}" &>/dev/null; then
            printf "error: %s%s%s\n" "${BOLD}" "${item} is missing." "${RESET}" >&2
            return 1
        fi
    done

    printf "info: %s%s%s\n" "${BOLD}" "All prerequisites met." "${RESET}"
    return 0

}

sync_configurations() {

    printf "info: %s%s%s\n" "${BOLD}" "Syncing configurations..." "${RESET}"
    printf "info: %s%s%s\n" "${BOLD}" "All configurations synced." "${RESET}"
    return 0

}

manage_cli_tools() {

    local DB_PATH="${PROJECT_ROOT}/db/database.db"

    printf "info: %s%s%s\n" "${BOLD}" "Managing CLI tools..." "${RESET}"
    printf "%b" "\n"

    info() {

        if [[ -z $1 ]]; then
            printf "warn: %s%s%s\n" "${BOLD}" "Argument can not be empty." "${RESET}"
            return 1
        fi

        printf "info: %s%s%s\n" "${BOLD}" "$1" "${RESET}"
    }

    ensure_database_ready() {

        local query="SELECT COUNT(*) FROM Utilities;"
        local result

        if [[ ! -f "${DB_PATH}" ]]; then
            info "The database file doesn't exist."
            return 1
        fi

        result=$(sqlite3 -noinit -noheader -batch -list "${DB_PATH}" "${query}")

        if [[ "${result}" -eq 0 ]]; then
            info "The database is empty."
            return 1
        fi

        return 0

    }

    create() {

        local query="CREATE TABLE IF NOT EXISTS Utilities(id INTEGER PRIMARY KEY AUTOINCREMENT, url TEXT NOT NULL UNIQUE, owner TEXT NOT NULL, repo TEXT NOT NULL);"

        if [[ ! -f "${DB_PATH}" ]]; then
            mkdir -p "${PROJECT_ROOT}/db"
            sqlite3 -noinit -noheader -batch -list "${DB_PATH}" "${query}"
            info "Successfully created and initialized the database."
            return 0
        fi

        info "The database file already exists."
        return 1

    }

    add() {

        local cli_tool_github_url
        local exists
        local query
        local owner
        local repo

        if [[ ! -f "${DB_PATH}" ]]; then
            info "The database file doesn't exist."
            return 1
        fi

        read -rp "${BOLD}Please type the CLI tool GitHub URL: ${RESET}" cli_tool_github_url

        if [[ ! "${cli_tool_github_url}" =~ ^https://github\.com/([A-Za-z0-9_.-]+)/([A-Za-z0-9_.-]+)$ ]]; then
            info "Invalid GitHub URL."
            return 1
        fi

        owner="${BASH_REMATCH[1]}"
        repo="${BASH_REMATCH[2]}"

        query="SELECT 1 FROM Utilities WHERE url = '${cli_tool_github_url}' LIMIT 1;"
        exists=$(sqlite3 -noinit -noheader -batch -list "${DB_PATH}" "${query}")

        if [[ -n "${exists}" ]]; then
            info "Already exists."
            return 1
        fi

        query="INSERT INTO Utilities (url, owner, repo) VALUES ('${cli_tool_github_url}', '${owner}', '${repo}');"
        sqlite3 -noinit -noheader -batch -list "${DB_PATH}" "${query}"

        info "Successfully added to the database."

    }

    readd() {

        local query="SELECT * FROM Utilities;"

        ensure_database_ready
        sqlite3 -noinit "${DB_PATH}" "${query}"

        return 0

    }

    update() {

        local new_cli_tool_github_url
        local new_owner
        local new_repo
        local target
        local query
        local id

        ensure_database_ready
        read -rp "${BOLD}Please type the CLI tool id: ${RESET}" id

        if [[ ! "${id}" =~ ^[0-9]+$ ]]; then
            info "Invalid id."
            return 1
        fi

        query="SELECT 1 FROM Utilities WHERE id = '${id}' LIMIT 1;"
        target=$(sqlite3 -noinit -noheader -batch -list "${DB_PATH}" "${query}")

        if [[ -z "${target}" ]]; then
            info "Not found."
            return 1
        fi

        read -rp "${BOLD}Please type the new CLI tool GitHub URL: ${RESET}" new_cli_tool_github_url

        if [[ ! "${new_cli_tool_github_url}" =~ ^https://github\.com/([A-Za-z0-9_.-]+)/([A-Za-z0-9_.-]+)$ ]]; then
            info "Invalid GitHub URL."
            return 1
        fi

        new_owner="${BASH_REMATCH[1]}"
        new_repo="${BASH_REMATCH[2]}"
        query="UPDATE Utilities SET url = '${new_cli_tool_github_url}', owner = '${new_owner}', repo = '${new_repo}' WHERE id = ${id};"
        sqlite3 -noinit -noheader -batch -list "${DB_PATH}" "${query}"
        info "Successfully updated in database."

    }

    delete() {

        local target
        local query
        local id

        ensure_database_ready
        read -rp "${BOLD}Please type the CLI tool id: ${RESET}" id

        if [[ ! "${id}" =~ ^[0-9]+$ ]]; then
            info "Invalid id."
            return 1
        fi

        query="SELECT 1 FROM Utilities WHERE id = ${id} LIMIT 1;"
        target=$(sqlite3 -noinit -noheader -batch -list "${DB_PATH}" "${query}")

        if [[ -z "${target}" ]]; then
            info "Not found."
            return 1
        fi

        query="DELETE FROM Utilities WHERE id = ${id};"
        sqlite3 -noinit -noheader -batch -list "${DB_PATH}" "${query}"
        info "Successfully deleted from database."

    }

    installl() {

        local browser_download_url
        local owner_repo_arr
        local choice
        local query
        local data
        local item
        local res

        ensure_database_ready

        query="SELECT CONCAT(owner, '/', repo) FROM Utilities ORDER BY id ASC;"
        res=$(sqlite3 -noinit -noheader -batch -list "${DB_PATH}" "${query}")
        mapfile -t owner_repo_arr <<<"${res}"

        for item in "${owner_repo_arr[@]}"; do
            data=$(xh GET "https://api.github.com/repos/${item}/releases/latest")
            jq -r '.assets[].name' <<<"${data}"
            printf "%b" "\n"
            read -rp "${BOLD}Please choose a pattern: ${RESET}" choice
            browser_download_url=$(jq -r --arg selection "${choice}" '.assets[] | select(.name == $selection) | .browser_download_url' <<<"${data}")

            if [[ -z "${browser_download_url}" ]]; then
                info "Invalid input."
                return 1
            fi

            kget -aqO "${PROJECT_ROOT}/Downloads" "${browser_download_url}"
            clear
        done

        printf "info: %s%s%s\n" "${BOLD}" "Successfully install all CLI tools." "${RESET}"
        return 0

    }

    menu() {

        local options
        local choice
        local index

        options=("Create" "Add" "Read" "Update" "Delete" "Install")

        for index in "${!options[@]}"; do
            if [[ "${index}" != 5 ]] && [[ "${index}" != 1 ]]; then
                printf "%s. %s%-8s%s %s\n" "$((index + 1))" "${BOLD}" "${options[${index}]}" "CLI tools Database" "${RESET}"
                continue
            fi

            printf "%s. %s%-8s%s %s\n" "$((index + 1))" "${BOLD}" "${options[${index}]}" "CLI tools" "${RESET}"
        done

        printf "%b" "\n"

        read -rp "${BOLD}? Please select an options: ${RESET}" choice

        clear

        case "${choice}" in
        "1")
            create
            ;;
        "2")
            add
            ;;
        "3")
            readd
            ;;
        "4")
            update
            ;;
        "5")
            delete
            ;;
        "6")
            installl
            ;;
        *)
            printf "%s\n" "Invalid input"
            return 1
            ;;
        esac

    }

    menu

}

main() {

    check_prerequisites
    printf "%b" "\n"
    sync_configurations
    printf "%b" "\n"
    manage_cli_tools

}

main
