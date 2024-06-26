# Applies and updates our VSCode configuration.

use log.nu
use vscode.nu

# Install any extensions listed in extensions.json that are not already
# installed.

let installed = vscode installed-extensions |
    each {|ext| {$ext.name: $ext.version}} |
    reduce {|ext, acc| $acc | merge $ext}

open ([$env.DOTFILES vscode extensions.json] | path join) |
    where ($installed | get --ignore-errors $it.name) != $it.version |
    each { |ext|
        let ext = $"($ext.name)@($ext.version)"
        log info $"Installing VSCode extension: ($ext)"
        ^code --install-extension $ext
    }

exit
