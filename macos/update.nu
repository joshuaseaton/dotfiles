# Performs any macOS-specific updating of installations.

use brew.nu
use file.nu
use log.nu

cd $env.DOTFILES

#
# Homebrew-installed packages
#

log info "Updating Homebrew casks and formulae..."

^brew update
brew installed | to json | file save-with-newline macos/brew.json

# Upgrade anything outdated.
if (^brew outdated | complete | get stdout | is-not-empty) {
    ^brew upgrade
}
