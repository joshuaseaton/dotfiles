# The main update entrypoint.

cd $env.FILE_PWD

# Program installations first, as other parts of the installation might
# reasonably rely on those (e.g., editor extensions on editors).
run ([installs update.nu] | path join)
run ([editors update.nu] | path join)
run ([terminal update.nu] | path join)
