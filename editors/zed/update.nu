use zed.nu

cd $env.FILE_PWD

# Zed is only distributed for macOS at the moment.
if $nu.os-info.name != macos {
    return
}

zed installed-extensions | to json | save --force extensions.json
