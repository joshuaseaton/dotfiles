use apt.nu
use log.nu

cd $env.DOTFILES

let packages = open linux/package.toml | get package
if (which apt | is-not-empty) {
    log info "Updating apt package info..."
    apt update
    apt upgrade ...($packages | get apt)
}
