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
