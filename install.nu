# The main installation entrypoint. This script should be idempotent.

use cargo.nu
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

# Install Cargo crates after the package installations done in the OS-specific
# set-up.
let cargo_installed = cargo installed |
    each {|crate| {$crate.name: $crate.version}} |
    reduce {|crate, record| $record | merge $crate }
open $"($env.DOTFILES)/cargo-installs.json" |
    where ($cargo_installed | get --ignore-errors $it.name) != $it.version |
    each {|crate|
        log info $"Installing crate: ($crate.name)@($crate.version)"
        ^cargo install --version $crate.version $crate.name
    }

exit
