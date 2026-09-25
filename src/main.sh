#!/usr/bin/env bash

# Enable strict mode
set -euo pipefail

PROJECT_ROOT="$(git -C "$(dirname -- "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
export PATH="${PROJECT_ROOT}/bin:${PATH}"

RESET=$(tput sgr0)
BOLD=$(tput bold)

check_prerequisites() {

    local -a prerequisites=("git")
    local item

    printf "info: ${BOLD}%s${RESET}\n" "Checking prerequisites..."

    for item in "${prerequisites[@]}"; do
        if ! command -v "${item}" &> /dev/null; then
            printf "error: %s%s%s\n" "${BOLD}" "${item} is missing." "${RESET}" >&2
            return 1
        fi
    done

    printf "info: %s%s%s\n" "${BOLD}" "All prerequisites met." "${RESET}"
    return 0

}

sync_configurations() {

    local r b

    b=$(tput bold)
    r=$(tput sgr0)

    printf "info: ${b}%s${r}\n" "Sync configurations"
    return 0

}

manage_cli_tools() {

    local PROJECT_ROOT
    local DB_PATH
    local r
    local b

    PROJECT_ROOT="$(git -C "$(dirname -- "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
    # export PATH="${PROJECT_ROOT}/bin:${PATH}"
    DB_PATH="${PROJECT_ROOT}/db/database.db"

    b=$(tput bold)
    r=$(tput sgr0)

    create() {

        local query

        if [[ -f "${DB_PATH}" ]]; then
            printf "info: ${b}%s${r}\n" "The database already exists."
            return 1
        fi

        mkdir -p "${PROJECT_ROOT}/db"
        touch "${DB_PATH}"

        query="CREATE TABLE IF NOT EXISTS Utilities(id INTEGER PRIMARY KEY AUTOINCREMENT, url TEXT NOT NULL UNIQUE, owner TEXT NOT NULL, repo TEXT NOT NULL);"
        sqlite3 -noinit "${DB_PATH}" "${query}"

        printf "info: ${b}%s${r}\n" "Successfully create and initialize the database."
        return 0

    }

    add() {

        local cli_tool_github_url
        local exists
        local query
        local owner
        local repo

        if [[ ! -f "${DB_PATH}" ]]; then
            printf "info: ${b}%s${r}\n" "The database does not exist."
            return 1
        fi

        read -rp "${b}Please type the CLI tool GitHub URL: ${r}" cli_tool_github_url

        if [[ ! "${cli_tool_github_url}" =~ ^https://github\.com/([A-Za-z0-9_-]+)/([A-Za-z0-9_-]+)$ ]]; then
            printf "info: ${b}%s${r}\n" "Invalid URL."
            return 1
        fi

        owner="${BASH_REMATCH[1]}"
        repo="${BASH_REMATCH[2]}"

        query="SELECT 1 FROM Utilities WHERE url = '${cli_tool_github_url}' LIMIT 1;"
        exists=$(sqlite3 -noinit "${DB_PATH}" "${query}")

        if [[ -n "${exists}" ]]; then
            printf "info: ${b}%s${r}\n" "Already exists."
            return 1
        fi

        query="INSERT INTO Utilities (url, owner, repo) VALUES ('${cli_tool_github_url}', '${owner}', '${repo}');"
        sqlite3 -noinit "${DB_PATH}" "${query}"

        printf "info: ${b}%s${r}\n" "Successfully add to database."
        return 0

    }

    readd() {

        local query

        if [[ ! -f "${DB_PATH}" ]]; then
            printf "info: ${b}%s${r}\n" "The database does not exist."
            return 1
        fi

        query="SELECT * FROM Utilities;"
        sqlite3 -noinit "${DB_PATH}" "${query}"
        return 0

    }

    update() {

        local new_owner
        local new_repo
        local new_url
        local target
        local choice
        local query
        local parts
        local index
        local id

        if [[ ! -f "${DB_PATH}" ]]; then
            printf "info: ${b}%s${r}\n" "The database does not exist."
            return 1
        fi

        read -rp "${b}Please type the CLI tool id: ${r}" id

        query="SELECT 1 FROM Utilities WHERE id = '${id}' LIMIT 1;"
        target=$(sqlite3 -noinit "${DB_PATH}" "${query}")

        if [[ -z "${target}" ]]; then
            printf "info: ${b}%s${r}\n" "id not found."
            return 1
        fi

        printf "%b" "\n"

        parts=("url" "owner" "repo")

        for index in "${!parts[@]}"; do
            printf "%s. ${b}%s${r}\n" "$((index + 1))" "${parts[${index}]}"
        done

        printf "%b" "\n"

        read -rp "${b}Please select an option to update: ${r}" choice

        printf "%b" "\n"

        case "${choice}" in
            "1")
                read -rp "${b}Please type the new url: ${r}" new_url

                if [[ ! "${new_url}" =~ ^https://github\.com/[A-Za-z0-9_-]+/[A-Za-z0-9_-]+$ ]]; then
                    printf "info: ${b}%s${r}\n" "Invalid input."
                    return 1
                fi

                query="UPDATE Utilities SET url = '${new_url}' WHERE id = ${id};"
                sqlite3 -noinit "${DB_PATH}" "${query}"

                printf "info: ${b}%s${r}\n" "Successfully update database."
                return 0
                ;;
            "2")
                read -rp "${b}Please type the new owner: ${r}" new_owner

                if [[ ! "${new_owner}" =~ ^[A-Za-z0-9_-]+$ ]]; then
                    printf "info: ${b}%s${r}\n" "Invalid input."
                    return 1
                fi

                query="UPDATE Utilities SET owner = '${new_owner}' WHERE id = ${id};"
                sqlite3 -noinit "${DB_PATH}" "${query}"

                printf "info: ${b}%s${r}\n" "Successfully update database."
                return 0
                ;;
            "3")
                read -rp "${b}Please type the new repo: ${r}" new_repo

                if [[ ! "${new_repo}" =~ ^[A-Za-z0-9_-]+$ ]]; then
                    printf "info: ${b}%s${r}\n" "Invalid input."
                    return 1
                fi

                query="UPDATE Utilities SET repo = '${new_repo}' WHERE id = ${id};"
                sqlite3 -noinit "${DB_PATH}" "${query}"

                printf "info: ${b}%s${r}\n" "Successfully update database."
                return 0
                ;;

            *)
                printf "info: ${b}%s${r}\n" "Invalid input."
                return 1
                ;;
        esac

    }

    delete() {

        local target
        local query
        local id

        if [[ ! -f "${DB_PATH}" ]]; then
            printf "info: ${b}%s${r}\n" "The database does not exist."
            return 1
        fi

        read -rp "${b}Please type the CLI tool id: ${r}" id

        query="SELECT 1 FROM Utilities WHERE id = ${id} LIMIT 1;"
        target=$(sqlite3 -noinit "${DB_PATH}" "${query}")

        if [[ -z "${target}" ]]; then
            printf "info: ${b}%s${r}\n" "id not found."
            return 1
        fi

        query="DELETE FROM Utilities WHERE id = ${id};"
        sqlite3 -noinit "${DB_PATH}" "${query}"

        printf "info: ${b}%s${r}\n" "Successfully delete from database."
        return 0

    }

    installl() {

        local browser_download_url
        local owner_repo_arr
        local name_arr
        local choice
        local query
        local data
        local res
        local i

        if [[ ! -f "${DB_PATH}" ]]; then
            printf "info: ${b}%s${r}\n" "The database does not exist."
            return 1
        fi

        query="SELECT CONCAT(owner, '/', repo) FROM Utilities;"
        res=$(sqlite3 -noinit -noheader -list "${DB_PATH}" "${query}")
        mapfile -t owner_repo_arr <<< "${res}"

        query="SELECT repo FROM Utilities;"
        res=$(sqlite3 -noinit -noheader -list "${DB_PATH}" "${query}")
        mapfile -t name_arr <<< "${res}"

        for i in "${!owner_repo_arr[@]}"; do
            printf "${b}%s...${r}\n" "Start installing ${name_arr[${i}]}"
            printf "%b" "\n"

            data=$(xh GET "https://api.github.com/repos/${owner_repo_arr[${i}]}/releases/latest")
            jq -r '.assets[].name' <<< "${data}"

            printf "%b" "\n"

            read -rp "${b}Please choose a pattern: ${r}" choice

            browser_download_url=$(jq -r --arg selection "${choice}" '.assets[] | select(.name == $selection) | .browser_download_url' <<< "${data}")

            if [[ -z "${browser_download_url}" ]]; then
                printf "info: ${b}%s${r}\n" "Invalid input."
                return 1
            fi

            kget -aqO "${PROJECT_ROOT}/Downloads" "${browser_download_url}"

            clear
        done

        printf "info: ${b}%s${r}\n" "Successfully install all CLI tools."
        return 0

    }

    menu() {

        local options
        local choice
        local index

        options=("Create" "Add" "Read" "Update" "Delete" "Install")

        for index in "${!options[@]}"; do
            if [[ "${index}" != 5 ]] && [[ "${index}" != 1 ]]; then
                printf "%s. ${b}%-8s${r} %s\n" "$((index + 1))" "${options[${index}]}" "CLI tools Database"
                continue
            fi

            printf "%s. ${b}%-8s${r} %s\n" "$((index + 1))" "${options[${index}]}" "CLI tools"
        done

        printf "%b" "\n"

        read -rp "${b}? Please select an options: ${r}" choice

        clear

        case "${choice}" in
            "1")
                create
                return 0
                ;;
            "2")
                add
                return 0
                ;;
            "3")
                readd
                return 0
                ;;
            "4")
                update
                return 0
                ;;
            "5")
                delete
                return 0
                ;;
            "6")
                installl
                return 0
                ;;
            *)
                printf "%s\n" "Invalid input"
                return 1
                ;;
        esac

    }

    menu
    return 0

}

main() {

    check_prerequisites
    # sync_configurations
    # manage_cli_tools
    return 0

}

main
