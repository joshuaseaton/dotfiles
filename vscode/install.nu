# Applies and updates our VSCode configuration.

use log.nu

def installed-extensions [] {
    ^code --list-extensions --show-versions | lines
} 

log newline
log info $"(ansi wb)Applying and updating VSCode configuration..."

#
# settings.json
#

let source_settings_json = $"($env.DOTFILES)/vscode/settings.json"

# See https://code.visualstudio.com/docs/getstarted/settings#_settings-file-locations
let target_settings_json = match (sys | get host.name)  {
    "Darwin" => $"($env.HOME)/Library/Application Support/Code/User/settings.json"
}

ln -sf $source_settings_json $target_settings_json
log info $"Linked: ($source_settings_json) ->\n\t($target_settings_json)"

#
# Extensions
#

# Install any extensions listed in extensions.json that are not already
# installed.
let installed = installed-extensions
let extensions_json = $"($env.DOTFILES)/vscode/extensions.json" 
open $extensions_json |
    where { |ext| not ($ext in $installed) } |
    each { |ext| ^code --install-extension $ext }

# Update all installed extensions and dump the now up-to-date last back out to
# extensions.json.
^code --update-extensions
installed-extensions |
    lines |
    to json --indent 2 |
    save --force $extensions_json
