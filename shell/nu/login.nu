# Reattaches to the last detached zellij session, if available.
def zellij_start [] {
    let sessions = ^zellij list-sessions --short | lines
    if ($sessions | is-empty) {
        ^zellij
    } else {
        ^zellij attach ($sessions | first)
    }
}
