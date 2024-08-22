# Udates VSCode extensions.

use log.nu
use vscode.nu

log info "Updating VSCode extensions..."

# Update all installed extensions and dump the now up-to-date last back out to
# extensions.json.
^code --update-extensions

vscode installed-extensions |
    to json |
    save --force ([$env.DOTFILES editors vscode extensions.json] | path join)
