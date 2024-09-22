use log.nu

# Ensures usability of the apt module on an apt-based system.
export def ensure [] {
    if (which aptitude | is-empty) {
        log info "apt: Installing aptitude"
        ^sudo apt-get install aptitude
    }
}

# Outputs a table of the installed packages, and their current and available
# versions, and descriptions.
export def installed [] {
    ^aptitude search --display-format="%p %v %V %d" "?installed" |
        lines |
        parse "{name} {installed} {available} {description}"
}

# Installs the provided apt packages, if not already installed.
export def install [...pkgs: string] {
    let one_of = $pkgs | each { $"?name\(($in)\)" } | str join ", "
    let already_installed = ^aptitude search --display-format="%p" $"?installed ?or\(($one_of)\)" |
        lines
    $pkgs |
        where not ($it in $already_installed) |
        do {
            if ($in | is-not-empty) {
                log info $'Installing apt packages: ($in | str join ", ")...'
                ^sudo apt-get install --yes ...$in
            }
        }
}

# Uninstalls the provided apt packages.
export def remove [...pkgs: string@"nu-complete apt installed"] {
    ^sudo apt-get remove --yes ...$pkgs
}

# Updates package info.
export def update [] {
    # Slightly less verbose than `apt update` and `apt-get update`.
    ^sudo aptitude update -y
}

# Upgrades the provided apt packages, if not already at the most recent
# available versions.
export def upgrade [...pkgs: string@"nu-complete apt installed"] {
    let one_of = $pkgs | each { $"?name\(($in)\)" } | str join ", "
    ^aptitude search --display-format="%p %v %V" $"?installed ?or\(($one_of)\)" |
        lines |
        collect { parse "{name} {installed} {available}" } |
        where $it.available != "<none>" and $it.installed != $it.available |
        do {
            if ($in | is-not-empty) {
                print $in
                log info $'Upgrading apt packages: ($in.name | str join ", ")...'
                ^sudo apt-get upgrade --yes ...($in.name)
            }
        }
}

# An order of magnitude faster than `apt installed | get name`.
def "nu-complete apt installed" [] {
    ^dpkg --get-selections |
        lines |
        parse --regex '^(?<name>(\w|\+|-|_|\.)+)'
        | get name
}
