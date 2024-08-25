# The main update entrypoint.

cd $env.FILE_PWD

[ editors installs terminal ] |
    each {|dir| run ([$dir update.nu] | path join) }

exit
