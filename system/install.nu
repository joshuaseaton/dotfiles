cd $env.FILE_PWD

match $nu.os-info.name {
    macos => { run ([ macos install.nu ] | path join) }
}
