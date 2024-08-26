# The main update entrypoint.

use brew.nu
use cargo.nu
use go.nu
use log.nu
use pipx.nu

cd $env.FILE_PWD

# OS-specifc or Homebrew updates could affect these versions, so capture them
# now.
let go_version_before = go version | get version
let python_version_before = (^python3 --version)

# OS-specific updates.
match $nu.os-info.name {
    linux => { run ([ linux update.nu ] | path join) }
}

#
# Homebrew-installed packages
#

log info "Updating Homebrew casks and formulae..."

if (which brew | is-not-empty) {
    let brew_installed_before = brew installed
    ^brew update
    let brew_installed_after = brew installed

    $brew_installed_before |
        join $brew_installed_after name |
        select name version version_ |
        each { |pkg|
            if $pkg.version != $pkg.version_ {
                log info $"Homebrew: updated ($pkg.name): ($pkg.version) -> ($pkg.version_)"
            }
        }

    # Homebrew doesn't allow installation by version, so capturing a given version
    # in brew.json is not practical.
    let brew_json = ([$nu.os-info.name brew.json] | path join)
    $brew_installed_after | reject version | to json | save --force $brew_json

    # Upgrade and tidy anything outdated.
    if (^brew outdated | complete | get stdout | is-not-empty) {
        ^brew upgrade
    }
    ^brew cleanup
}

# Rust
log info "Updating Rust installations..."

def rustc-version [] { rustc --version | parse "rustc {version} {metadata}" | get 0.version }

let rustc_version_before = rustc-version
^rustup update
let rustc_version_after = rustc-version

if $rustc_version_after == $rustc_version_before {
    ^cargo install-update --all
} else {
    log info $"New version of rustc; recompiling installations: \(($rustc_version_before) -> ($rustc_version_after)\)..."
    ^cargo install-update --force --all
}

cargo installed | reject binaries | to json | save --force cargo.json

# Update Go binaries after OS-specific updates, so that an updated version of Go
# can result in installations being recompiled.
let go_version_after = go version | get version
go installed |
    each { |bin|
        let latest = go latest-stable-version $bin.module
        let local = [$env.GOBIN $bin.name] | path join
        let context = if $bin.version != $latest {
            $"Updating ($bin.name) \(($bin.path)\): ($bin.version) -> ($latest)..."
        } else if $go_version_after != $go_version_before {
            $"Recompiling ($bin.name) \(($bin.path)@($latest)\) at new Go version ($go_version_after)..."
        }
        if $context != null {
            log info $context
            ^go install $"($bin.path)@($latest)"
        }
    }

go installed | to json | save --force go.json

# Ditto for Python and pipx packages
log info "Updating pipx installations..."
let python_version_after = (^python3 --version)
if $python_version_after != $python_version_before {
    ^pipx reinstall-all
}
^pipx upgrade-all

pipx installed | to json | save --force pipx.json
