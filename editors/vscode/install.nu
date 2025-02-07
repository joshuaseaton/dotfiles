# Applies and updates our VSCode configuration.

use log.nu
use vscode.nu

cd $env.FILE_PWD

# Install any extensions listed in extensions.json that are not already
# installed.

let installed = vscode installed-extensions | get name
open extensions.json |
    where not ($it in $installed) |
    each { |ext|
        log info $"Installing VSCode extension: ($ext)"
        ^code --install-extension $ext
    }

exit
