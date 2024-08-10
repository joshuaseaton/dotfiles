export def installed [] {
    ^pipx list --json |
        from json |
        get venvs |
        transpose name metadata |
        each { |entry|
            let pkg = $entry.metadata.metadata.main_package
            {
                name: $entry.name
                version: $pkg.package_version
            }
        }
}

export def metadata [pkg: string] {
    let metadata = ([ $nu.home-path .local pipx venvs $pkg pipx_metadata.json ] | path join)
    if not ($metadata | path exists) {
        return null
    }
    open $metadata
}
