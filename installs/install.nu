use brew.nu
use cargo.nu
use go.nu
use log.nu
use pipx.nu

cd $env.FILE_PWD

# Be sure to do system package installations early, as things below might rely
# upon them.

# OS-specific set-up.
match $nu.os-info.name {
    linux => { run ([ linux install.nu ] | path join) }
}


#
# Homebrew-installed packages
#

if (which brew | is-not-empty) {
    let installed = brew installed | get name
    open ([$nu.os-info.name brew.json] | path join) |
        where not ($it.name in $installed) |
        each {|pkg|
                log info $"Installing Homebrew ($pkg.type): ($pkg.name)"
                let args = if ($pkg.name == "alacritty") { [ --no-quarantine ] } else { [] }
                ^brew install $"--($pkg.type)" ...$args $pkg.name
        }
}

# Cargo installations.
let cargo_installed = cargo installed |
    each {|crate| {$crate.name: $crate.version}} |
    reduce {|crate, record| $record | merge $crate }
open cargo.json |
    where ($cargo_installed | get --ignore-errors $it.name) != $it.version |
    each {|crate|
        log info $"Installing crate: ($crate.name)@($crate.version)"
        ^cargo install --version $crate.version $crate.name
    }

# Go binaries.
open go.json |
    each { |bin|
        let local = [$env.GOBIN $bin.name] | path join
        if not ($local | path exists) or ((go build-info $local | get main.version) != $bin.version) {
            log info $"Installing ($bin.name) \(($bin.path)@($bin.version)\)..."
            ^go install $"($bin.path)@($bin.version)"
        }
    }

# pipx installations.
let python_version = ^python3 --version
open pipx.json |
    each { |pkg|
        let local = ([$nu.home-path .local bin $pkg.name] | path join)
        if not ($local | path exists) or ((pipx metadata $pkg.name | get python_version) != $python_version) {
            log info $"pipx: Installing ($pkg.name) \(($pkg.name)@($pkg.version)\)..."
            ^pipx install $"($pkg.name)==($pkg.version)"
        }
    }

exit
