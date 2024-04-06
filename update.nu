# The main update entrypoint.

use cargo.nu
use log.nu

cd $env.DOTFILES

# VSCode
run vscode/update.nu

# Rust

log info "Updating Rust installations..."

^rustup update

^cargo install-update --all
cargo installed | to json | save --force cargo-installs.json

# OS-specific updates.
run $"($nu.os-info.name)/update.nu"
