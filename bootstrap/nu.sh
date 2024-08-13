#!/bin/sh

# POSIX-compliancy checked with shellcheck.

#
# The primary job of this script is to install Nushell (via cargo) and our
# custom configuration for it.
#

set -e

BREW_LINUX=/home/linuxbrew/.linuxbrew/bin/brew
BREW_MAC=/opt/homebrew/bin/brew
CARGO_BIN_DIR="${HOME}/.cargo/bin"
DOTFILES="${HOME}/.dotfiles"
DOTFILES_ACTUAL="$(dirname "$(dirname "$(realpath "$0")")")"
OS="$(uname -o)"
NU_ENV_CONFIG="${DOTFILES}/nu/config/env.nu"
readonly BREW_LINUX BREW_MAC CARGO_BIN_DIR DOTFILES DOTFILES_ACTUAL OS NU_ENV_CONFIG

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
    if [ ! -f "${BREW_MAC}" ]; then
        install_homebrew
    fi
elif [ "${OS}" = GNU/Linux ]; then
    if [ ! -f "${BREW_LINUX}" ]; then
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
    else
        echo "Warning: Unsupported package manager"
    fi
fi

if [ ! -f "${CARGO_BIN_DIR}/cargo" ]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi


if [ ! -f "${CARGO_BIN_DIR}/nu" ]; then
    "${CARGO_BIN_DIR}/cargo" install nu
fi

# Now finish our bootstrap in the richer Nushell environment.
"${CARGO_BIN_DIR}/nu" --env-config "${NU_ENV_CONFIG}" "${DOTFILES}/bootstrap/nu.nu"
