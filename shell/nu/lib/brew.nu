# A convenient Nu-wrapper around Homebrew.

# Generates a table of the explicitly installed casks and formulae (not
# dependencies).
export def installed [] {
    let info = ^brew info --installed --json=v2 | from json
    let casks = $info.casks |
        each {|cask|
        {
            name: ($cask.token),
            type: cask,
        }
    }
    let formulae = $info.formulae |
        where $it.installed.0.installed_on_request == true |
        each {|formula|
        {
            name: ($formula.name),
            type: formula,
        }
    }
    $casks | append $formulae | sort-by name
}
