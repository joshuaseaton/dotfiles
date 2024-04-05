# The main update entrypoint.

use log.nu

# VSCode
run $"($env.DOTFILES)/vscode/update.nu"

# Rust

log info "Updating Rust installations..."

^rustup update

# TODO: When we have multiple cargo-managed installations, parse the list from
# cargo install --list.
^cargo install nu

# OS-specific updates.
run $"($env.DOTFILES)/($nu.os-info.name)/update.nu"
