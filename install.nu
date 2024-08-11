 # The main installation entrypoint. This script should be idempotent.

use cargo.nu
use file.nu
use go.nu
use log.nu
use pipx.nu

cd $env.DOTFILES

# Linked configuration files.
open links.json |
    append (open ([$nu.os-info.name links.json] | path join)) |
    each { |link|
        let source = [$env.HOME $link.source] | path join
        let target = [$env.HOME $link.target] | path join
        file symlink $source $target
    }

# OS-specific set-up.
#
# Be sure to do this early, as things below might rely upon OS-specific
# installations.
run ([$nu.os-info.name install.nu] | path join)

# VSCode
run ([vscode install.nu] | path join)

# Cargo installations.
let cargo_installed = cargo installed |
    each {|crate| {$crate.name: $crate.version}} |
    reduce {|crate, record| $record | merge $crate }
open ([installs cargo.json] | path join)|
    where ($cargo_installed | get --ignore-errors $it.name) != $it.version |
    each {|crate|
        log info $"Installing crate: ($crate.name)@($crate.version)"
        ^cargo install --version $crate.version $crate.name
    }

# Go binaries.
open ([installs go.json] | path join) |
    each { |bin|
        let local = [$env.GOBIN $bin.name] | path join
        if not ($local | path exists) or ((go build-info $local | get main.version) != $bin.version) {
            log info $"Installing ($bin.name) \(($bin.path)@($bin.version)\)..."
            ^go install $"($bin.path)@($bin.version)"
        }
    }

# pipx installations.
let python_version = ^python3 --version
open ([installs pipx.json] | path join) |
    each { |pkg|
        let local = ([$nu.home-path .local bin $pkg.name] | path join)
        if not ($local | path exists) or ((pipx metadata $pkg.name | get python_version) != $python_version) {
            log info $"pipx: Installing ($pkg.name) \(($pkg.name)@($pkg.version)\)..."
            ^pipx install $"($pkg.name)==($pkg.version)"
        }
    }

exit
