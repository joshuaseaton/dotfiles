use apt.nu
use log.nu

cd $env.FILE_PWD

let packages = open package.toml | get package
if (which apt | is-not-empty) {
    log info "Updating apt package info..."
    apt update
    apt upgrade ...($packages | get apt)
}
