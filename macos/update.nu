# Performs any macOS-specific updating of installations.

use log.nu

#
# Homebrew-installed packages
#

log newline
log info $"(ansi wb)Updating Homebrew casks and formulae...(ansi reset)"

^brew update
