# The main update entrypoint.

cd $env.FILE_PWD

# Program installations first, as other parts of the installation might
# reasonably rely on those (e.g., editor extensions on editors).
[ installs editors terminal ] |
    each {|dir| run ([$dir update.nu] | path join) }

exit
