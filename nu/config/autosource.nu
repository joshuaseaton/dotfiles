# The OS-agnostic, custom modules and completions that it would be handy to have
# always present in a terminal context. This file is symlinked by
# bootstrap/nu.sh into a vendor autoload directory.

use cargo.nu
use clipboard.nu
use dict.nu
use file.nu
use go.nu
use into.nu

source completions/git.nu
