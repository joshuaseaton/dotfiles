# shellcheck shell=sh

# This file contains POSIX-compliant shell utilities for use across shell
# scripts


# Set the PATH as configured in Nushell.
set_path_from_nu () {
    nu="${HOME}/.cargo/bin/nu"
    if [ -f "${nu}" ]; then
        PATH="$("${nu}" --login --commands "do \$env.ENV_CONVERSIONS.PATH.to_string \$env.PATH")"
        export PATH
    fi
}
