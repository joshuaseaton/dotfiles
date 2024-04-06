# Lists the installed cargo crates.
export def installed [] {
    ^cargo install --list |
        lines |
        where ($it | str ends-with ":")
        | parse "{name} v{version}:"
}
