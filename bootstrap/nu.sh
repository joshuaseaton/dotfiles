#!/bin/sh

#
# The primary job of this script is to install Nushell (via cargo) and our
# custom configuration for it, and register it as the default terminal shell.
#

set -e

BREW=/opt/homebrew/bin/brew
OS="$(uname -o)"
NU_ENV_CONFIG="${HOME}/.dotfiles/nu/config/env.nu"
readonly BREW OS NU_ENV_CONFIG

# This is also the most convenient spot to install Homebrew, which is intended
# to be done with bash.
if [ "${OS}" = Darwin ] && [ ! -f "${BREW}" ]; then
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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
