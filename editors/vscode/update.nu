# Udates VSCode extensions.

use log.nu
use vscode.nu

cd $env.FILE_PWD

# charliermarsh.ruff depends on ms-python.python, which keeps installing these.
const UNDESIRABLES = [
    ms-python.vscode-pylance
    ms-python.debugpy
]

log info "Updating VSCode extensions..."

# Update all installed extensions and dump the now up-to-date last back out to
# extensions.json.
^code --update-extensions

vscode installed-extensions |
    get name  |
    filter { |ext|
        let undesirable = $ext in $UNDESIRABLES
        if $undesirable {
            log warning $"Uninstalling undesired VSCode extension: ($ext)"
            ^code --uninstall-extension $ext
        }
        not $undesirable
    } |
    save --force extensions.json
