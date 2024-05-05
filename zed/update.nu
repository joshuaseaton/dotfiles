use zed.nu

zed installed-extensions |
    to json |
    save --force ([$env.DOTFILES zed extensions.json] | path join)
