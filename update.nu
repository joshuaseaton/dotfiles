# The main update entrypoint.

use cargo.nu
use log.nu

# VSCode
run $"($env.DOTFILES)/vscode/update.nu"

# Rust

log info "Updating Rust installations..."

^rustup update

^cargo install-update --all
cargo installed | to json | save --force $"($env.DOTFILES)/cargo-installs.json"

# OS-specific updates.
run $"($env.DOTFILES)/($nu.os-info.name)/update.nu"
