use apt.nu

cd $env.DOTFILES

if (which apt | is-not-empty) {
    open linux/apt.json | do { apt install ...$in }
}
