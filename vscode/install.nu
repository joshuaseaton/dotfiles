# Applies and updates our VSCode configuration.

use log.nu

log newline
log info $"(ansi wb)Installing VSCode configuration...(ansi reset)"

#
# settings.json
#

let source_settings_json = $"($env.DOTFILES)/vscode/settings.json"

# See https://code.visualstudio.com/docs/getstarted/settings#_settings-file-locations
let target_settings_json = match $nu.os-info.name  {
    macos => $"($env.HOME)/Library/Application Support/Code/User/settings.json"
    linux => $"($env.HOME)/.config/Code/User/settings.json"
}

ln -sf $source_settings_json $target_settings_json
log info $"Linked: ($source_settings_json) ->\n\t($target_settings_json)"

#
# Extensions
#

# Install any extensions listed in extensions.json that are not already
# installed.
let installed = ^code --list-extensions --show-versions | lines
let extensions_json = $"($env.DOTFILES)/vscode/extensions.json" 
open $extensions_json |
    where { |ext| not ($ext in $installed) } |
    each { |ext| ^code --install-extension $ext }

exit
