-- Auto-generates annotations for all installed Spoons.
hs.loadSpoon("EmmyLua")

-- <Control><Alt>T: Launch a new Alacritty instance if none are running, or else
-- focus an existing one.
hs.hotkey.bind({ "ctrl", "alt" }, "T", function()
    hs.application.launchOrFocus("alacritty")
end)

-- <Control><Alt>B: Launch a new browser instance if none are running, or else
-- focus an existing one.
hs.hotkey.bind({ "ctrl", "alt" }, "B", function()
    hs.application.launchOrFocus("Brave Browser")
end)

-- <Control><Alt>Return: Maximize window
hs.hotkey.bind({ "ctrl", "alt" }, "Return", function()
    hs.window.focusedWindow():maximize(0)
end)

hs.hotkey.bind({ "ctrl", "alt" }, "P", function()
    hs.window.focusedWindow():minimize()
end)

--[=====[
The following bindings give the equivalent of GNOME's "push tile" window
management behaviour.
--]=====]

-- <Control><Alt>Left: Push window left
hs.hotkey.bind({ "ctrl", "alt" }, "Left", function()
    local window = hs.window.focusedWindow()
    local frame = window:frame()
    local max = window:screen():frame()

    if frame.x1 == max.x1 then
        frame.w = max.w / 2
    else
        frame.x1 = max.x1
        frame.w = max.w
    end
    window:setFrame(frame, 0)
end)

-- <Control><Alt>Right: Push window right
hs.hotkey.bind({ "ctrl", "alt" }, "Right", function()
    local window = hs.window.focusedWindow()
    local frame = window:frame()
    local max = window:screen():frame()

    if frame.x2 == max.x2 then
        frame.x1 = max.x1 + max.w / 2
        frame.w = max.w / 2
    else
        frame.w = max.w
    end
    window:setFrame(frame, 0)
end)

-- <Control><Alt>Up: Push window up
hs.hotkey.bind({ "ctrl", "alt" }, "Up", function()
    local window = hs.window.focusedWindow()
    local frame = window:frame()
    local max = window:screen():frame()

    if frame.y1 == max.y1 then
        frame.h = max.h / 2
    else
        frame.y1 = max.y1
        frame.h = max.h
    end
    window:setFrame(frame, 0)
end)

-- <Control><Alt>Down: Push window down
hs.hotkey.bind({ "ctrl", "alt" }, "Down", function()
    local window = hs.window.focusedWindow()
    local frame = window:frame()
    local max = window:screen():frame()

    if frame.y2 == max.y2 then
        frame.y1 = max.y1 + max.h / 2
        frame.h = max.h / 2
    else
        frame.h = max.h
    end
    window:setFrame(frame, 0)
end)
