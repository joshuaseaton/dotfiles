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

# Alacritty
log newline
log info $"(ansi wb)Installing Alacritty configuration...(ansi reset)"
let alacritty_toml = $"($env.HOME)/.config/alacritty/alacritty.toml"
^ln -sf $"($env.DOTFILES)/alacritty.toml" $alacritty_toml
log info $"Linked: ($env.DOTFILES)/alacritty.toml ->\n\t($alacritty_toml)"

# VSCode
run $"($env.DOTFILES)/vscode/install.nu"

# OS-specific set-up.
match $nu.os-info.name {
    macos => (run $"($env.DOTFILES)/macos/install.nu")
}
