use apt.nu

if (which apt | is-not-empty) {
    open $"($env.DOTFILES)/linux/apt.json" |
        do { apt install ...$in }
}
