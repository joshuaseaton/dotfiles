-- Auto-generates annotations for all installed Spoons.
hs.loadSpoon("EmmyLua")

hs.hotkey.bind({ "ctrl", "alt" }, "T", function()
    hs.application.launchOrFocus("alacritty")
end)
