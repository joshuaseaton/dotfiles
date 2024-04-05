# The main installation entrypoint. This script should be idempotent.

use log.nu

# Linked configuration files.
open $"($env.DOTFILES)/links.json" |
    append (open $"($env.DOTFILES)/($nu.os-info.name)/links.json")
    | each { |link|
        let target = $"($env.HOME)/($link.target)"
        mkdir ($target | path dirname)
        ^ln -sf $"($env.HOME)/($link.source)" $target
        log info $"Linked: ($link.source) -> ($link.target)"
    } 

# VSCode
run $"($env.DOTFILES)/vscode/install.nu"

# OS-specific set-up.
run $"($env.DOTFILES)/($nu.os-info.name)/install.nu"
