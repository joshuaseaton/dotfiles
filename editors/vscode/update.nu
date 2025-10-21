# Udates VSCode extensions.

use log.nu
use vscode.nu

const BLACKLIST = [
    "ms-python.debugpy"
    "ms-python.vscode-pylance"
    "ms-python.vscode-python-envs"
]

cd $env.FILE_PWD

log info "Updating VSCode extensions..."

# Update all installed extensions and dump the now up-to-date last back out to
# extensions.json.
^code --update-extensions

vscode installed-extensions
    | get name
    | each {
        |ext|
        if $ext in $BLACKLIST {
            log warning $"Bleh! VSCode extension ($ext) was auto-reinstalled; uninstalling..."
            ^code --uninstall-extension $ext
            null
        } else {
            $ext
        }
    }
    | save --force extensions.json
