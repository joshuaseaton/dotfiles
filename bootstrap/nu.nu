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
mkdir $nu.default-config-dir
[config.nu env.nu login.nu] |
    each { |config|
        let source = $"($env.DOTFILES)/nu/config/($config)"
        let target = $"($nu.default-config-dir)/($config)"
        ^ln -sf $source $target
        log info $"Linked: ($source) ->\n\t ($target)"
    }

# Set Nushell as the default terminal shell.
let nu_cmd = $"($nu.current-exe) --login"
let os = sys | get host.name
if $os == Darwin {
    defaults write --verbose com.apple.Terminal "Window Settings".Basic.CommandString $nu_cmd
} else if ("GNU/Linux" in $os) {
    if (which gsettings | is-not-empty) {  # GNOME
        let uuid = ^gsettings get org.gnome.Terminal.ProfilesList default | str trim --char "'"
        let schema = $"org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:($uuid)/"
        ^gsettings set $schema custom-command $nu_cmd
        ^gsettings set $schema use-custom-command true
        
        # Dark mode too while we're at it.
        ^gsettings set $schema use-theme-colors false
        ^gsettings set $schema background-color "rgb(23,20,33)"
        ^gsettings set $schema foreground-color "rgb(208,207,204)"
    } else {
        log error "Unknown Linux desktop environment: unable to set Nushell as the default terminal shell"
    }
} else {
    log error $"Unknown operating system ($os): unable to set Nushell as the default terminal shell"
}
