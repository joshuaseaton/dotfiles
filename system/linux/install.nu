cd $env.FILE_PWD

match $env.DESKTOP_SESSION {
    cinnamon => { open cinnamon.dconf | ^dconf load / }
    _ => {
        error make --unspanned {
            msg: $"Unsupported desktop environment: ($env.DESKTOP_SESSION)"
        }
    }
}

