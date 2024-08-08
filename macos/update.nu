# Performs any macOS-specific updating of installations.

use brew.nu
use log.nu

cd $env.DOTFILES

#
# Homebrew-installed packages
#

log info "Updating Homebrew casks and formulae..."

let installed_before = brew installed
^brew update
let installed_after = brew installed

$installed_before |
    join $installed_after name |
    select name version version_ |
    each { |pkg|
        if $pkg.version != $pkg.version_ {
            log info $"Homebrew: updated ($pkg.name): ($pkg.version) -> ($pkg.version_)"
        }
    }

# Homebrew doesn't allow installation by version, so capturing a given version
# in brew.json is not practical.
$installed_after | reject version | to json | save --force macos/brew.json

# Upgrade and tidy anything outdated.
if (^brew outdated | complete | get stdout | is-not-empty) {
    ^brew upgrade
}
^brew cleanup
