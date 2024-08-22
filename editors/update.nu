cd ([$env.DOTFILES editors] | path join)

run ([vscode update.nu] | path join)
run ([zed update.nu] | path join)
