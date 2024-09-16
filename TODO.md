# TODO

## General
* Try to redirect auto-generated history files away from the root of the home
  directory and possibly in a more conventional config location.
* "save to file if contents are different" 

## Linux
* Make `<Control><Alt>T` open alacritty (ideally refocusing an existing instance)
* Make `<Control><Alt>B` open the browser (ideally refocusing an existing
  instance)
* Make `<Control><Alt>E` open VSCode (or current editor of choice)?

## macOS
* Make `<Command><Alt>(Left|Right)` move between workspaces (with quick
  transitions). Figure out some other workspace-related keybindings.

## Windows
* Basic support

## Bugs to file
* zellij: ability to open last detached session or open a new one
* nushell: with `sync_on_enter: false`, history won't actually be synced on
  macOS with `<Cmd>Q`
* nushell: option to keep view at beginning of output
* nushell: match block with multiple patterns
* nushell: `$record | sort` should be recursive for inner records?
