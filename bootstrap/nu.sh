#!/bin/sh

#
# The sole job of this script is to install Nushell (via cargo) and our custom
# configuration for it, and register it as the default terminal shell.
#

readonly OS="$(uname -o)"
readonly NU_ENV_CONFIG="${HOME}/.dotfiles/nu/config/env.nu"

if [[ -z "$(which cargo)" ]]; then
    if [[ "${OS}" == Darwin ]]; then
        if [[ -z "$(which brew)" ]]; then
            curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
        fi
        brew install rust
    else
        echo "Unsupported OS: ${OS}"
        exit 1
    fi
fi

if [[ -z "$(which nu)" ]]; then
    cargo install nu
fi

# Now finish our bootstrap in the richer Nushell environment.
$"${HOME}/.cargo/bin/nu" --env-config "${NU_ENV_CONFIG}" "${HOME}/.dotfiles/bootstrap/nu.nu"
