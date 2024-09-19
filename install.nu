# The main installation entrypoint.

cd $env.FILE_PWD

# Program installations first, as other parts of the installation might
# reasonably rely on those (e.g., editor extensions on editors).
run ([installs install.nu] | path join)
run ([editors install.nu] | path join)
run ([system install.nu] | path join)
