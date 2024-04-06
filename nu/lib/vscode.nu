# Returns a table of the installed extensions and their current versions.
export def installed-extensions [] {
    open $"($env.HOME)/.vscode/extensions/extensions.json" |
        flatten identifier |
        select id version |
        rename name |
        sort-by name
}
