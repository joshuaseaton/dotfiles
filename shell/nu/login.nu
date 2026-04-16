# Reattaches to the last detached zellij session, if available.
def zellij-start [] {
    let sessions = ^zellij list-sessions --short
        | complete
        | get stdout
        | lines
    if ($sessions | is-empty) {
        ^zellij
    } else {
        ^zellij attach ($sessions | first)
    }
}
