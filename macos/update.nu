# Performs any macOS-specific updating of installations.

use log.nu

#
# Homebrew-installed packages
#

log info "Updating Homebrew casks and formulae..."

^brew update

# Upgrade anything outdated.
if (^brew outdated | complete | get stdout | is-empty) {
    ^brew upgrade
}
