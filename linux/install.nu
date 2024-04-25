use apt.nu

cd $env.DOTFILES

let packages = open linux/package.toml | get package
if (which apt | is-not-empty) {
    apt install ...($packages | get apt)
}
