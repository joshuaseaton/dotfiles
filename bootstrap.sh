#!/bin/sh

# POSIX-compliancy checked with shellcheck.

#
# The primary job of this script is to install Nushell (via cargo) and our
# custom configuration for it.
#

set -e

BREW_LINUX=/home/linuxbrew/.linuxbrew/bin/brew
BREW_MAC=/opt/homebrew/bin/brew
CARGO="${HOME}/.cargo/bin/cargo"
DOTFILES="${HOME}/.dotfiles"
DOTFILES_ACTUAL="$(dirname "$(realpath "$0")")"
OS="$(uname -o)"
NU="${HOME}/.cargo/bin/nu"
readonly BREW_LINUX BREW_MAC CARGO DOTFILES DOTFILES_ACTUAL OS NU

USE_HOMEBREW=1
while [ $# -gt 0 ]; do
    case "$1" in
        --no-homebrew)
        USE_HOMEBREW=0
        shift
        ;;
    *)
        echo "Unknown flag: $1"
        exit 1
        ;;
    esac
done

# This script is also the most convenient spot to install Homebrew, which is
# intended to be done with bash.
install_homebrew () {
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

if [ "${DOTFILES_ACTUAL}" !=  "${DOTFILES}" ]; then
    echo "ERROR: dotfiles.git must be cloned to ${DOTFILES}; not ${DOTFILES_ACTUAL}"
    exit 1
fi

if [ "${OS}" = Darwin ]; then
    if [ $USE_HOMEBREW -eq 1 ] && [ ! -f "${BREW_MAC}" ]; then
        install_homebrew
    fi
elif [ "${OS}" = GNU/Linux ]; then
    if [ $USE_HOMEBREW -eq 1 ] && [ ! -f "${BREW_LINUX}" ]; then
        install_homebrew
    fi

    # Building Nushell on Linux has some dependencies that might need to be
    # downloaded.
    if [ "$(which apt)" ]; then
        if ! apt-cache show pkg-config >/dev/null 2>&1; then
            sudo apt-get install pkg-config
        fi
        if ! apt-cache show libssl-dev >/dev/null 2>&1; then
            sudo apt-get install libssl-dev
        fi

        # Not a Nushell dependency, this is the most convenient spot to install
        # `aptitude`, which the apt module depends on.
        if ! apt-cache show aptitude >/dev/null 2>&1; then
            sudo apt-get install aptitude
        fi
    else
        echo "Warning: Unsupported package manager"
    fi
fi

if [ ! -f "${CARGO}" ]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi

if [ ! -f "${NU}" ]; then
    "${CARGO}" install nu
fi

# Now finish our bootstrap by going through the official installation endpoint.
cd "${DOTFILES}"
"${NU}" --env-config shell/nu/env.nu install.nu
