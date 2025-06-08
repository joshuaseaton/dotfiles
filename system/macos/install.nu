# Performs the macOS-specific portion of the installation and configuration.

use defaults.nu

#
# System settings
#
# Largely cribbed from https://github.com/mathiasbynens/dotfiles/blob/main/.macos.
#

#
# General
#

# Disable auto-correct and automatic capitalization.
defaults write --verbose --force NSGlobalDomain NSAutomaticSpellingCorrectionEnabled false
defaults write --verbose --force NSGlobalDomain NSAutomaticCapitalizationEnabled false

#
# Touchpad
#

# Disable two-finger right click.
defaults write --verbose com.apple.AppleMultitouchTrackpad TrackpadRightClick false
defaults write --verbose com.apple.AppleMultitouchTrackpad TrackpadCornerSecondaryClick 0

# Disable annoying force click feature.
defaults write --verbose NSGlobalDomain "com.apple.trackpad.forceClick" false
defaults write --verbose com.apple.AppleMultitouchTrackpad ForceSuppressed true

#
# Keyboard
#

# Committing these changes unfortunately involves calling the activateSettings
# tool, which commits these values to the I/O Registry, which is the HID
# driver's source of truth. This is all obsure magic.

# We register space + cmd as a shortcut for Launchpad below, but by default this
# the keybinding for Spotlight. Trial and error reveals that we first need to
# unregister the Spotlight keybinding and commit it before we can register the
# Launchpad keybinding.
defaults write --verbose com.apple.symbolichotkeys AppleSymbolicHotKeys."64".enabled false
defaults write --verbose com.apple.symbolichotkeys AppleSymbolicHotKeys."64".value.parameters [65535 65535 0]
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

[
    # Launchpad: space + cmd
    #
    # Launchpad is so much nicer than Spotlight, which binds space + cmd by
    # default.
    {
        id: 160,
        parameters: [
            0x20, # ASCII output: space
            0x31, # primary key: spacebar
            0x100000, # modfier: cmd
        ],
    },
    # Move left a desktop space: left + ctrl + cmd
    #
    # By default this is left + ctrl, which we want for moving left by a word
    # in the terminal.
    {
        id: 79,
        parameters: [
            0xffff, # ASCII output: none
            0x7b, # primary key: left arrow
            0x140000, # modfier: ctrl + cmd
        ],
    },
    # Move right a desktop space: right + ctrl + cmd
    #
    # By default this is right + ctrl, which we want for moving right by a word
    # in the terminal.
    {
        id: 80,
        parameters: [
            0xffff, # ASCII output: none
            0x7c, # primary key: right arrow
            0x140000, # modfier: ctrl + cmd
        ],
    },
] | each { |key|
    (
        defaults write --verbose
            com.apple.symbolichotkeys
            ([AppleSymbolicHotKeys, $"($key.id)", enabled] | into cell-path)
            true
    )
    (
        defaults write --verbose
        com.apple.symbolichotkeys
        ([AppleSymbolicHotKeys, $"($key.id)", value parameters] | into cell-path)
        $key.parameters
    )
}

/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

#
# Dock
#

[
    # Disable launch animations.
    (defaults write --verbose --force com.apple.dock launchanim false),

    # Don't show recently opened applications.
    (defaults write --verbose --force com.apple.dock show-recents false),

    # Only show open applications in the dock.
    (defaults write --verbose --force com.apple.dock static-only true),

    # Do not show the "open application" indicator. We can CTRL+TAB through them
    # instead.
    (defaults write --verbose com.apple.dock show-process-indicators false),

    # Minimize windows into their application’s icon.
    (defaults write --verbose --force com.apple.dock minimize-to-application true),

    # Change the minimize/maximize window effect.
    (defaults write --verbose --force com.apple.dock mineffect "scale"),

    # Don’t group windows by application in Mission Control.
    (defaults write --verbose --force com.apple.dock expose-group-by-app false),

    # Enable auto-hiding of the dock and make it reappear quickly.
    (defaults write --verbose --force com.apple.dock autohide true),
    (defaults write --verbose --force com.apple.dock autohide-delay 0.0),
] |
    reduce {|result, changed| $changed or $result } |
    if $in {
        # Force the changes to take effect by restarting the Dock.
        ^killall Dock
    }

#
# Spotlight
#

# If we have to use Spotlight, best to neuter it and just have it search for
# applications.
const allowed_spotlight_items = [ APPLICATIONS ]
let spotlight_items = defaults read com.apple.spotlight orderedItems |
    each {
        |item|
        $item | merge {enabled: ($item.name in $allowed_spotlight_items)}
    }
defaults write --verbose com.apple.spotlight orderedItems $spotlight_items

#
# Messages
#

defaults write --verbose --force com.apple.messageshelper.MessageController SOInputLineSettings {
    # Disable automatic 'correction' of ASCII smiley faces to emojis.
    automaticEmojiSubstitutionEnablediMessage: false,

    # Disable spell check.
    continuousSpellCheckingEnabled: false,
}

#
# UnnaturalScrollWheels
#

defaults write --verbose com.theron.UnnaturalScrollWheels LaunchAtLogin true
defaults write --verbose com.theron.UnnaturalScrollWheels ScrollLines 4

#
# Hammerspoon
#

defaults write --verbose org.hammerspoon.Hammerspoon SUEnableAutomaticChecks true

exit
