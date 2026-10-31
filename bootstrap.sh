#!/usr/bin/env bash

set -euo pipefail

fail() {
    printf 'Fehler: %s\n' "$1" >&2
    exit 1
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

ensure_homebrew() {
    if command_exists brew; then
        return 0
    fi

    local candidate installer shellenv
    for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        if [[ -x "$candidate" ]]; then
            shellenv="$("$candidate" shellenv)" || fail "Homebrew konnte nicht initialisiert werden."
            eval "$shellenv"
            command_exists brew || fail "Homebrew ist weiterhin nicht im PATH."
            return 0
        fi
    done

    installer="$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" ||
        fail "Der Homebrew-Installer konnte nicht heruntergeladen werden."
    /bin/bash -c "$installer" || fail "Die Homebrew-Installation ist fehlgeschlagen."

    for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        if [[ -x "$candidate" ]]; then
            shellenv="$("$candidate" shellenv)" || fail "Homebrew konnte nicht initialisiert werden."
            eval "$shellenv"
            command_exists brew || fail "Homebrew ist weiterhin nicht im PATH."
            return 0
        fi
    done
    fail "Homebrew wurde an keinem Standardpfad gefunden."
}

main() {
    [[ "$(uname -s)" == Darwin ]] || fail "Dieses Startskript ist für macOS gedacht."
    [[ "$EUID" -ne 0 ]] || fail "Als normaler Benutzer starten, ohne sudo."
    [[ $# -le 2 ]] || fail "Verwendung: $0 [OWNER/REPO] [work|personal]"

    local repository="${1:-}" profile="${2:-}" destination="$HOME/dotfiles"
    printf '\nMac-Grundausstattung einrichten\n\n'

    if [[ -z "$repository" ]]; then
        read -r -p "Privates GitHub-Repository (OWNER/REPO): " repository ||
            fail "Kein Repository angegeben."
    fi
    [[ "$repository" =~ ^[a-zA-Z0-9][a-zA-Z0-9-]*/[a-zA-Z0-9_.-]+$ ]] ||
        fail "Repository als OWNER/REPO angeben."
    case "$profile" in
        "" | work | personal) ;;
        *) fail "Unbekanntes Profil: $profile" ;;
    esac

    if [[ -e "$destination" || -L "$destination" ]]; then
        fail "Unter $destination liegt bereits etwas. Vorhandenes Repo dort prüfen und den Installer direkt starten."
    fi

    if ! xcode-select -p >/dev/null 2>&1; then
        printf 'Apple Command Line Tools fehlen. Bitte die Installation im macOS-Dialog abschließen.\n'
        xcode-select --install || fail "Die Installation der Command Line Tools konnte nicht gestartet werden."
        printf 'Danach dieses Startskript erneut ausführen.\n'
        return 1
    fi

    printf '[1/4] Homebrew bereitstellen\n'
    ensure_homebrew

    printf '\n[2/4] GitHub CLI und Anmeldung\n'
    if ! command_exists gh; then
        brew install gh || fail "Die GitHub CLI konnte nicht installiert werden."
    fi
    if ! gh auth status --hostname github.com >/dev/null 2>&1; then
        gh auth login --hostname github.com --git-protocol https --web ||
            fail "Die GitHub-Anmeldung ist fehlgeschlagen."
    fi

    printf '\n[3/4] Dotfiles nach %s klonen\n' "$destination"
    gh repo clone "https://github.com/$repository.git" "$destination" ||
        fail "Klonen fehlgeschlagen. Account und Repository-Zugriff prüfen."
    [[ -f "$destination/install.sh" ]] || fail "Das Repository enthält keine install.sh."

    printf '\n[4/4] Dotfiles einrichten\n'
    if [[ -n "$profile" ]]; then
        /bin/bash "$destination/install.sh" "$profile"
    else
        /bin/bash "$destination/install.sh"
    fi
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
