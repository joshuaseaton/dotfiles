cd $env.FILE_PWD

use log.nu

# This may not be set if in an SSH shell.
if ($env | get --optional DESKTOP_SESSION | is-empty) {
    log warning "Could not install system settings: $DESKTOP_SESSION not set"
    return;
}

match $env.DESKTOP_SESSION {
    cinnamon => { open cinnamon.dconf | ^dconf load / }
    _ => {
        error make --unspanned {
            msg: $"Unsupported desktop environment: ($env.DESKTOP_SESSION)"
        }
    }
}

