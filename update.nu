# The main update entrypoint.

use log.nu

# VSCode
run $"($env.DOTFILES)/vscode/update.nu"

# OS-specific set-up.
match (sys | get host.name) {
    Darwin => (run $"($env.DOTFILES)/macos/update.nu")
}

# OS-specific set-up will have ensured that cargo is up-to-date, at which point
# we can update the cargo-managed installations.
#
# TODO: When we have multiple cargo-managed installations, parse the list from
# cargo install --list.
log newline
log info $"(ansi wb)Updating cargo installations...(ansi reset)"

^cargo install nu
