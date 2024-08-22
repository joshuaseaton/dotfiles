# Returns a table of the installed extensions and their metadata.
export def installed-extensions [] {
    let config_dir = match $nu.os-info.name {
        "macos" => ([$env.HOME Library "Application Support" Zed] | path join)
        _ => { return (error make --unspanned {msg: $"Unsupported OS: ($nu.os-info.name)"}) }
    }
    open ([$config_dir extensions index.json] | path join) |
        get extensions |
        values |
        flatten manifest |
        select id name version description repository
}
