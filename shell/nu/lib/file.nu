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

# A nushell `stat` wrapper.
export def stat [source: string] {
    if not ($source | path exists) {
        log error $"Source ($source) does not exist"
        return
    }
    let info = ^stat -f `{
        size: %Uz,    
        perms: %Up,
        user: %Su,
        group: %Sg,
        accessed: %a,
        modified: %m,
        device: %Sd,
    }` $source | from nuon

    {
        size: ($info.size | into filesize), 
        user: $info.user,
        group: $info.group,
        mode: {
            user: (perms ($info.perms | bits shr 6)),
            group: (perms ($info.perms | bits shr 3)),
            others: (perms $info.perms),
        },
        accessed: ($info.accessed | into datetime --format "%s"),
        modified: ($info.modified | into datetime --format "%s"),
        device: $info.device,
    }
}

def perms [raw: int] string {
    [
        {mask: 0b100, perm: "r"},
        {mask: 0b010, perm: "w"},
        {mask: 0b001, perm: "x"},
    ] | reduce --fold "" {
        |it, acc|
        if ($raw | bits and $it.mask) != 0 { $acc + $it.perm } else { $acc}
    }
}
