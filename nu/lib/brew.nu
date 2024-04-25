# A convenient Nu-wrapper around Homebrew.

# Generates a table of the installed casks and formulae.
export def installed [] {
    let info = ^brew info --installed --json=v2 | from json
    let casks = $info.casks |
        each {|cask|
        {
            name: ($cask | get token),
            description: ($cask | get desc),
            type: cask,
            version: ($cask | get installed),
        }
    }
    let formulae = $info.formulae |
        each {|formula|
        {
            name: ($formula | get name),
            description: ($formula | get desc),
            type: formula,
            version: ($formula | get installed.version.0),
        }
    }
    $casks | append $formulae | sort-by name
}
