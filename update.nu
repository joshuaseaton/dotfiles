# The main update entrypoint.

use cargo.nu
use go.nu
use log.nu
use pipx.nu

cd $env.DOTFILES

# Editors
run ([vscode update.nu] | path join)
run ([zed update.nu] | path join)

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

cargo installed |
    reject binaries |
    to json |
    save --force ([installs cargo.json] | path join)

# OS-specifc updates could affect these versions, so capture them now.
let go_version_before = go version | get version
let python_version_before = (^python3 --version)

# OS-specific updates.
run ([$nu.os-info.name update.nu] | path join)

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

go installed | to json | save --force ([ installs go.json ] | path join)

# Ditto for Python and pipx packages
log info "Updating pipx installations..."
let python_version_after = (^python3 --version)
if $python_version_after != $python_version_before {
    ^pipx reinstall-all
}
^pipx upgrade-all

pipx installed | to json | save --force ([ installs pipx.json ] | path join)
