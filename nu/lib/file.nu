use log.nu

# Symlinks $source to $target.
export def symlink [source: string, target: string] {
    if not ($target | path exists) or (ls --long $target | get 0.target) != $source {
        mkdir ($target | path dirname)
        ^ln -sf $source $target
        log info $"Linked: ($source) -> ($target)"
    }
}

# Saves the stdin contents to the provided file with an added newline.
export def save-with-newline [file: string] {
    $in | save --force $file
    (char newline) | save --append $file
}
