# Applies and updates our VSCode configuration.

use log.nu


#
# settings.json
#

# Install any extensions listed in extensions.json that are not already
# installed.
let installed = ^code --list-extensions --show-versions | lines
let extensions_json = $"($env.DOTFILES)/vscode/extensions.json" 
open $extensions_json |
    where { |ext| not ($ext in $installed) } |
    each { |ext| ^code --install-extension $ext }

exit
