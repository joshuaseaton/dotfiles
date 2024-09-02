use log.nu

# Symlinks $source to $target.
export def symlink [source: string, target: string] {
    if not ($source | path exists) {
        log error $"Symlink source ($source) does not exist"
        return
    }
    let is_dir = ($source | path type) == dir
    let do_link = not ($target | path exists) or (
        if ($is_dir) {
            (ls --long --directory $target | get 0.target) != $source
        } else {
            (ls --long $target | get 0.target) != $source
        })
    if $do_link {
        mkdir ($target | path dirname)
        ^ln -sf $source $target
        log info $"Linked: ($source) -> ($target)"
    }
}
