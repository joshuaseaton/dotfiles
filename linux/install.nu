use apt.nu

cd $env.FILE_PWD

let packages = open package.toml | get package
if (which apt | is-not-empty) {
    apt install ...($packages | get apt)
}
