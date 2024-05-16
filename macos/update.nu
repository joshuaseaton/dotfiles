# Performs any macOS-specific updating of installations.

use brew.nu
use log.nu

cd $env.DOTFILES

#
# Homebrew-installed packages
#

log info "Updating Homebrew casks and formulae..."

^brew update
brew installed | to json | save --force macos/brew.json

# Upgrade and tidy anything outdated.
if (^brew outdated | complete | get stdout | is-not-empty) {
    ^brew upgrade
}
^brew cleanup
