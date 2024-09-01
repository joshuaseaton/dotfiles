

def set-dconf [keybindings_path: string] {
    # We intentionally disable any settings that will interfere with being able
    # to toggle maximizing the window or snapping it around. The snap
    # keybindings are made to coincide with the familiar macOS Rectangle ones.
    let dconf = [
        $"[($keybindings_path)]",
        "maximize=@as []",
        "move-to-side-e=@as []",
        "move-to-side-n=@as []",
        "move-to-side-s=@as []",
        "move-to-side-w=@as []",
        "push-snap-down=@as []",
        "push-snap-left=@as []",
        "push-snap-right=@as []",
        "push-snap-up=@as []",
        "push-tile-down=['<Control><Alt>Down']",
        "push-tile-left=['<Control><Alt>Left']",
        "push-tile-right=['<Control><Alt>Right']",
        "push-tile-up=['<Control><Alt>Up']",
        "switch-to-workspace-down=['<Super><Alt>Up']",
        "switch-to-workspace-left=['<Super><Alt>Left']",
        "switch-to-workspace-right=['<Super><Alt>Right']",
        "switch-to-workspace-up=['<Super><Alt>Down']",
        "toggle-maximized=['<Control><Alt>Return']",
        "unmaximize=@as []",
    ]

    $dconf | str join "\n" | ^dconf load /
}


match $env.DESKTOP_SESSION {
    cinnamon => (set-dconf org/cinnamon/desktop/keybindings/wm)
    _ => {
        error make --unspanned {
            msg: $"Unsupported desktop environment: ($env.DESKTOP_SESSION)"
        }
    }
}

