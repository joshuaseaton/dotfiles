# The OS-agnostic, custom module imports, completions, and aliases that would be
# handy to have always present in a terminal context. This file is symlinked by
# bootstrap/nu.sh into a user autoload directory.

# autoloading can't be turned off, so this ensures that nushell with a custom
# config works.
if ($env.NU_LIB_DIRS | is-empty) {
    return
}

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
# Aliases
#

alias cat = ^bat
alias make = ^compiledb make  # Autogenerate a compile_commands.json
alias stat = file stat
