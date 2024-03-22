#!/bin/sh

#
# The sole job of this script is to install Nushell and our custom configuration
# for it, and register it as the default terminal shell.
#

readonly OS="$(uname -o)"
readonly NU_ENV_CONFIG="${HOME}/.dotfiles/nu/config/env.nu"

if [[ "${OS}" == Darwin ]]; then
    if [[ -z "$(which brew)" ]]; then
        curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
    fi

    if [[ -z "$(which nu)" ]]; then
        brew install nushell
    fi
else
    echo "Unsupported OS: ${OS}"
    exit 1
fi

# Now finish our bootstrap in the richer Nushell environment.
nu --env-config "${NU_ENV_CONFIG}" "${HOME}/.dotfiles/bootstrap/nu.nu"
