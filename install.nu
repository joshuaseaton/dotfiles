 # The main installation entrypoint. This script should be idempotent.

use cargo.nu
use log.nu

cd $env.DOTFILES

# Linked configuration files.
open links.json |
    default $nu.os-info.name os |
    where $it.os == $nu.os-info.name |
    each { |link|
        let source = $"($env.HOME)/($link.source)"
        let target = $"($env.HOME)/($link.target)"
        if not ($target | path exists) or (ls --long $target | get 0.target) != $source {
            mkdir ($target | path dirname)
            ^ln -sf $source $target
            log info $"Linked: ($link.source) -> ($link.target)"
        }
    }

# VSCode
run vscode/install.nu

# OS-specific set-up.
run $"($nu.os-info.name)/install.nu"

# Install Cargo crates after the package installations done in the OS-specific
# set-up.
let cargo_installed = cargo installed |
    each {|crate| {$crate.name: $crate.version}} |
    reduce {|crate, record| $record | merge $crate }
open cargo-installs.json |
    where ($cargo_installed | get --ignore-errors $it.name) != $it.version |
    each {|crate|
        log info $"Installing crate: ($crate.name)@($crate.version)"
        ^cargo install --version $crate.version $crate.name
    }

exit
