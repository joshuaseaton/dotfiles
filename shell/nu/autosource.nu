# The OS-agnostic, custom module imports, completions, and aliases that would be
# handy to have always present in a terminal context. This file is symlinked by
# bootstrap/nu.sh into a user autoload directory.

#
# Imports
#

use boc.nu
use brew.nu
use cargo.nu
use clipboard.nu
use df.nu
use dict.nu
use file.nu
use git.nu
use go.nu
use into.nu
use pipx.nu

#
# Aliases
#

alias cat = ^bat
alias make = ^compiledb make  # Autogenerate a compile_commands.json
alias stat = file stat
