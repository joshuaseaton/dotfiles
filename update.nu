# The main update entrypoint.

use cargo.nu
use go.nu
use log.nu

cd $env.DOTFILES

# VSCode
run ([vscode update.nu] | path join)

# Rust
log info "Updating Rust installations..."

^rustup update

^cargo install-update --all

cargo installed |
    reject binaries |
    to json |
    save --force ([installs cargo.json] | path join)

# OS-specific updates.
run ([$nu.os-info.name update.nu] | path join)

# Update Go binaries after OS-specific package updates, as an updated version of
# Go will result in installations being recompiled.
let go_version = go version | get version
go installed |
    each { |bin|
        let latest = go latest-stable-version $bin.module
        let local = [$env.GOBIN $bin.name] | path join
        let context = if $bin.version != $latest {
            $"Updating ($bin.name) \(($bin.path)\): ($bin.version) -> ($latest)..."
        } else if (go build-info $local | get go_version) != $go_version {
            $"Recompiling ($bin.name) \(($bin.path)@($latest)\) at new Go version ($go_version)..."
        }
        if $context != null {
            log info $context
            ^go install $"($bin.path)@($latest)"
        }
    }

go installed | to json | save --force ([installs go.json] | path join)
