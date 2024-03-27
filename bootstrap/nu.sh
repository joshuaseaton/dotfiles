#!/bin/sh

# POSIX-compliancy checked with shellcheck.

#
# The primary job of this script is to install Nushell (via cargo) and our
# custom configuration for it, and register it as the default terminal shell.
#

set -e

BREW=/opt/homebrew/bin/brew
OS="$(uname -o)"
NU_ENV_CONFIG="${HOME}/.dotfiles/nu/config/env.nu"
readonly BREW OS NU_ENV_CONFIG

if [ "${OS}" = Darwin ]; then
    # This is also the most convenient spot to install Homebrew, which is
    # intended to be done with bash.
    if [ ! -f "${BREW}" ]; then
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
elif [ "${OS}" = GNU/Linux ]; then
    # Building Nushell on Linux has some dependencies that might need to be
    # downloaded.
    if [ "$(which apt)" ]; then
        if ! apt-cache show pkg-config 2>&1 /dev/null; then
            sudo apt-get install pkg-config
        fi
        if ! apt-cache show libssl-dev 2>&1 /dev/null; then
            sudo apt-get install libssl-dev
        fi
    else
        echo "Warning: Unsupported package manager"
    fi
fi

if [ ! -f "${HOME}/.cargo/bin/cargo" ]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi
. "${HOME}/.cargo/env"

if [ -z "$(which nu)" ]; then
    cargo install nu
fi

# Now finish our bootstrap in the richer Nushell environment.
nu --env-config "${NU_ENV_CONFIG}" "${HOME}/.dotfiles/bootstrap/nu.nu"
