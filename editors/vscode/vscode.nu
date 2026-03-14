# Returns the installed extensions as a sorted list of names.
export def installed-extensions [] {
    ^code --list-extensions | lines | sort
}
