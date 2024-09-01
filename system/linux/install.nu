

def set-dconf-settings [] {
    # We use dconf over gsettings as the latter doesn't seem to take
    # instantaneously.
    let keybindings_path = match $env.DESKTOP_SESSION {
        cinnamon => "/org/cinnamon/desktop/keybindings/wm"
        gnome => "/org/gnome/desktop/wm/keybindings"
        _ => (error make --unspanned {msg: $"unsupported desktop environment: ($env.DESKTOP_SESSION)"})
    }

    # We intentionally disable any settings that will interfere with being able
    # to toggle maximizing the window or snapping it around. The snap
    # keybindings are made to coincide with the familiar macOS Rectangle ones.
    {
        "maximize": "@as []",
        "move-to-side-e": "@as []",
        "move-to-side-n": "@as []",
        "move-to-side-s": "@as []",
        "move-to-side-w": "@as []",
        "push-snap-down": "@as []",
        "push-snap-left": "@as []",
        "push-snap-right": "@as []",
        "push-snap-up": "@as []",
        "push-tile-down": "['<Control><Alt>Down']",
        "push-tile-left": "['<Control><Alt>Left']",
        "push-tile-right": "['<Control><Alt>Right']",
        "push-tile-up": "['<Control><Alt>Up']",
        "switch-to-workspace-down": "@as []",
        "switch-to-workspace-left": "['<Super><Alt>Left']",
        "switch-to-workspace-right": "['<Super><Alt>Right']",
        "switch-to-workspace-up": "@as []",
        "toggle-maximized": "['<Control><Alt>Return']",
        "unmaximize": "@as []",
    } | transpose key value |
        each { |entry|
            ^dconf write $"($keybindings_path)/($entry.key)" $entry.value
        }
}


if (which dconf | is-not-empty) {
    set-dconf-settings
}

