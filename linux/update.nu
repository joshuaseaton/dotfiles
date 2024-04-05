use apt.nu
use log.nu

log info "Updating apt package info..."
apt update

if (which apt | is-not-empty) {
    open $"($env.DOTFILES)/linux/apt.json" |
        do { apt upgrade ...$in }
}
