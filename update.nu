# The main update entrypoint.

use log.nu

# VSCode
run $"($env.DOTFILES)/vscode/update.nu"

# Rust

log newline
log info $"(ansi wb)Updating Rust installations...(ansi reset)"

^rustup update

# TODO: When we have multiple cargo-managed installations, parse the list from
# cargo install --list.
^cargo install nu

# OS-specific set-up.
match $nu.os-info.name {
    macos => (run $"($env.DOTFILES)/macos/update.nu")
}

exit
