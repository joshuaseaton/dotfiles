# The main installation entrypoint.

cd $env.FILE_PWD

# Program installations first, as other parts of the installation might
# reasonably rely on those (e.g., editor extensions on editors).
[ installs editors system ] |
    each {|dir| run ([$dir install.nu] | path join) }

exit
