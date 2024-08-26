# Applies and updates our VSCode configuration.

use log.nu
use vscode.nu

cd $env.FILE_PWD

# Install any extensions listed in extensions.json that are not already
# installed.

let installed = vscode installed-extensions |
    each {|ext| {$ext.name: $ext.version}} |
    if ($in | is-not-empty) {
        $in | reduce {|ext, acc| $acc | merge $ext}
    } else {
        []
    }

open extensions.json |
    where ($installed | get --ignore-errors $it.name) != $it.version |
    each { |ext|
        let ext = $"($ext.name)@($ext.version)"
        log info $"Installing VSCode extension: ($ext)"
        ^code --install-extension $ext
    }
