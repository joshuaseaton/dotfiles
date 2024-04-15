use apt.nu
use log.nu

cd $env.DOTFILES

log info "Updating apt package info..."
apt update

if (which apt | is-not-empty) {
    open linux/apt.toml | get package.name | do { apt upgrade ...$in }
}
