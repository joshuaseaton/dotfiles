# The main installation entrypoint. This script should be idempotent.

use log.nu

# Ensure package order for readability.
open $"($env.DOTFILES)/packages.json" |
    sort-by name |
    save --force $"($env.DOTFILES)/packages.json"

# Git
log info $"(ansi wb)Installing Git configuration...(ansi reset)"

let gitconfig = $"($env.HOME)/.gitconfig"
^ln -sf $"($env.DOTFILES)/.gitconfig" $gitconfig
log info $"Linked: ($env.DOTFILES)/.gitconfig ->\n\t($gitconfig)"

# VSCode
run $"($env.DOTFILES)/vscode/install.nu"

# OS-specific set-up.
match (sys | get host.name) {
    Darwin => (run $"($env.DOTFILES)/macos/install.nu")
}
