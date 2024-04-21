# This script is expected to be called in bootstrap/nu.sh with our custom
# environment explicitly specified.
#
# It finishes the job of bootstrap/nu.sh in installing our custom Nushell
# configuration.

use file.nu
use log.nu

# Install via symlink our custom configuration in the default configuration
# directory. This ensures that running `nu` in its interactive mode (as the
# terminal will do) will implicitly execute with our configuration.
mkdir $nu.default-config-dir
[config.nu env.nu login.nu] |
    each { |config|
        let source = $"($env.DOTFILES)/nu/config/($config)"
        let target = $"($nu.default-config-dir)/($config)"
        file symlink $source $target
    }

exit 0
