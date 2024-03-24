# Performs any macOS-specific updating of installations.

use brew.nu
use log.nu

#
# Homebrew and installed packages
#

log newline
log info $"(ansi wb)Updating Homebrew casks and formulae...(ansi reset)"

^brew update

let installed = brew list | get name
open $"($env.DOTFILES)/packages.json"
| get brew
| where {|pkg| not ($pkg in $installed)}
| each { |pkg| ^brew install $pkg }
