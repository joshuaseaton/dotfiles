# A convenient Nu-wrapper around Homebrew.

# Generates a table of the installed casks and formulae.
export def list [] {
    let casks = ^brew list --versions --casks |
        lines |
        each {
            |ext|
            let tokens = $ext | split row ' '
            {name: $tokens.0, version: $tokens.1, type: cask }
        }
    let formulae = ^brew list --versions --formulae |
        lines |
        each {
            |ext|
            let tokens = $ext | split row ' '
            {name: $tokens.0, version: $tokens.1, type: formula}
        }
    $casks | append $formulae | sort-by name
}