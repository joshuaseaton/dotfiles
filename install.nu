# The main installation entrypoint.

use file.nu

cd $env.FILE_PWD

# Linked configuration files.
[ "editors" "git" "shell" "system" "terminal" "third_party" ] |
    each { |dir|
        let file = $dir | path join links.json
        open $file |
            default $nu.os-info.name os |
            where os == $nu.os-info.name |
            each { |link|
                let source = [$env.HOME .dotfiles $dir $link.source] | path join
                let target = [$env.HOME $link.target] | path join
                file symlink $source $target
            }
    }

# Program installations first, as other parts of the installation might
# reasonably rely on those (e.g., editor extensions on editors).
run ([installs install.nu] | path join)
run ([editors install.nu] | path join)
run ([system install.nu] | path join)
