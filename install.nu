# The main installation entrypoint.

cd $env.FILE_PWD

[ editors installs system ] |
    each {|dir| run ([$dir install.nu] | path join) }

exit
