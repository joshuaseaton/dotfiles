use zed.nu

# Zed is only distributed for macOS at the moment.
if $nu.os-info.name != macos {
    return
}

zed installed-extensions |
    to json |
    save --force ([$env.DOTFILES zed extensions.json] | path join)
