# Returns the build info of a given Go binary (à la runtime/debug.BuildInfo).
export def build-info [binary: string] {
    let info = ^go version -m $binary |
        lines |
        each {|| str trim --left }
    let go_version = $info |
        first |
        parse $"($binary): go{version}" |
        get version.0
    let path = $info |
        get 1 |
        parse --regex '^path\s+(?<path>.*)' |
        get path.0
    let main = $info |
        where ($it | str starts-with "mod") |
        if ($in | is-not-empty) {
            $in |
            get 0 |
            parse --regex '^mod\s+(?<module>.*)\s+(?<version>.*)\s+(?<sum>.*)' |
            get 0
        }
    let deps = $info |
        where ($it | str starts-with "dep") |
        parse --regex '^dep\s+(?<module>.*)\s+(?<version>.*)\s+(?<sum>.*)'
    let settings = $info |
        where ($it | str starts-with "build") |
        parse --regex '^build\s+(?<key>(-|_|[a-z]|[A-Z])+)=(?<value>.*)' |
        select key value |
        sort-by key
    {
        go_version: $go_version,
        path: $path,
        main: $main,
        deps: $deps,
        settings: $settings,
    }
}

# Outputs a table of the installed Go binaries in $env.GOBIN.
export def installed [] {
    ls $env.GOBIN |
        get name |
        sort |
        each { |bin|
            let info = build-info $bin
            {
                name: ($bin | path basename),
                module: $info.main.module,
                path: $info.path,
                version: $info.main.version,
            }
        }
}

# Returns the latest, known stable version of the module.
export def latest-stable-version [module: string] {
   versions $module | where not ('-' in $it) | first
}

# Outputs the installed go version as a table.
export def version [] {
    ^go version |
        parse --regex 'go version go(?<version>.*)\s(?<os>\w+)/(?<arch>\w+)' |
        into record
}

# Returns the list of available versions in reverse order.
export def versions [module: string] {
    ^go list -versions -m $module |
        split row ' ' |
        drop nth 0 |
        reverse
}
