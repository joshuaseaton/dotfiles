# A convenient Nu-wrapper around Homebrew.

# Generates a table of the installed casks and formulae.
export def installed [] {
    let info = ^brew info --installed --json=v2 | from json
    let casks = $info.casks |
        each {|cask|
        {
            name: ($cask.token),
            description: ($cask.desc),
            type: cask,
            version: ($cask.version),
        }
    }
    let formulae = $info.formulae |
        each {|formula|
        let deps = $formula.dependencies
        {
            name: ($formula.name),
            description: ($formula.desc),
            type: formula,
            version: ($formula.installed.version.0),
        } | if ($deps | is-not-empty) {
            $in | insert dependencies $deps
        } else {
            $in
        }
    }
    $casks | append $formulae | sort-by name
}
