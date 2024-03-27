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
| default true quarantine
| where {|pkg| not ($pkg.name in $installed)}
| each { |pkg|
    log info $"Installing ($pkg.name)"
    let args = if $pkg.quarantine { [] } else { [ --no-quarantine ]} 
    ^brew install $pkg.name ...$args
  }
