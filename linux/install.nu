use apt.nu

cd $env.DOTFILES

if (which apt | is-not-empty) {
    open linux/apt.toml | get package.name | do { apt install ...$in }
}
