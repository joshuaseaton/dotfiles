# This script is expected to be called in bootstrap/nu.sh with our custom
# environment explicitly specified.
#
# It finishes the job of bootstrap/nu.sh in installing our custom Nushell
# configuration and registering Nushell as the default terminal shell.

use defaults.nu
use log.nu

# Install via symlink our custom configuration in the default configuration
# directory. This ensures that running `nu` in its interactive mode (as the
# terminal will do) will implicitly execute with our configuration.
[config.nu env.nu login.nu] |
    each { |config|
        let source = $"($env.DOTFILES)/nu/config/($config)"
        let target = $"($nu.default-config-dir)/($config)"
        ^ln -sf $source $target
        log info $"Linked: ($source) ->\n\t ($target)"
    }

# Set Nushell as the default terminal shell.
let nupath = which nu | get path.0
if (sys | get host.name) == Darwin {
    defaults write --verbose com.apple.Terminal "Window Settings".Basic.CommandString $"($nupath) --login"
}
