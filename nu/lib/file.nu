use log.nu

# Symlinks $source to $target.
export def symlink [source: string, target: string] {
    if not ($target | path exists) or (ls --long $target | get 0.target) != $source {
        mkdir ($target | path dirname)
        ^ln -sf $source $target
        log info $"Linked: ($source) -> ($target)"
    }
}
