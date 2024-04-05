# Udates VSCode extensions.

use log.nu

log info "Updating VSCode extensions..."

# Update all installed extensions and dump the now up-to-date last back out to
# extensions.json.
^code --update-extensions
^code --list-extensions --show-versions |
    lines |
    to json --indent 2 |
    save --force $"($env.DOTFILES)/vscode/extensions.json"
