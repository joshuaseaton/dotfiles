# The OS-agnostic, custom module imports, completions, and aliases that would be
# handy to have always present in a terminal context. This file is symlinked by
# bootstrap/nu.sh into a vendor autoload directory.

#
# Imports
#

use brew.nu
use cargo.nu
use clipboard.nu
use df.nu
use dict.nu
use file.nu
use go.nu
use into.nu
use pipx.nu

#
# Completions
#

source completions/git.nu

#
# Aliases
#

alias cat = bat
alias stat = file stat
