# The Linux-specific, custom modules and completions that it would be handy to
# have always present in a terminal context. When on a Linux host, this file is
# symlinked by bootstrap/nu.sh into a vendor autoload directory.

# autoloading can't be turned off, so this ensures that nushell with a custom
# config works.
if ($env.NU_LIB_DIRS | is-empty) {
    return
}

use apt.nu
