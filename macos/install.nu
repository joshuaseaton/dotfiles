# Performs the macOS-specific portion of the installation and configuration. 

use brew.nu
use defaults.nu
use log.nu

#
# Homebrew and installed packages
#

log newline
log info $"(ansi wb)Updating Homebrew casks and formulae..."

^brew update

let installed = brew list | get name
open $"($env.DOTFILES)/packages.json"
| get brew
| where {|pkg| not ($pkg in $installed)}
| each { |pkg| ^brew install $pkg }

#
# System settings
#

log newline
log info $"(ansi wb)Applying macOS system settings..."

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

# Register CMD + SPACE as a shortcut for Launchpad (much nicer than Spotlight).
# Since this is already the default Spotlight shortcut, we need to disable the
# latter as well. Trial and error demonstrates that this has to be committed
# separately from the Launchpad shortcut registration, as then the latter
# doesn't take. Committing the change unfortunately involves calling the
# activateSettings tool, which commits these values to the I/O Registry, which
# is the HID driver's source of truth. This is all obsure magic.
defaults write --verbose com.apple.symbolichotkeys AppleSymbolicHotKeys."64".enabled false
defaults write --verbose com.apple.symbolichotkeys AppleSymbolicHotKeys."64".value.parameters [65535 65535 0]
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
defaults write --verbose com.apple.symbolichotkeys AppleSymbolicHotKeys."160".enabled true
defaults write --verbose com.apple.symbolichotkeys AppleSymbolicHotKeys."160".value.parameters [32, 49, 1048576]
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

#
# Dock
#

# Disable launch animations.
defaults write --verbose --force com.apple.dock launchanim false

# Don't show recently opened applications.
defaults write --verbose --force com.apple.dock show-recents false

# Only show open applications in the dock.
defaults write --verbose --force com.apple.dock static-only true

# Do not show the "open application" indicator, as it's redundant with the last
# setting.
defaults write --verbose com.apple.dock show-process-indicators false

# Minimize windows into their application’s icon.
defaults write --verbose --force com.apple.dock minimize-to-application true

# Change the minimize/maximize window effect.
defaults write --verbose --force com.apple.dock mineffect "scale"

# Don’t group windows by application in Mission Control.
defaults write --verbose --force com.apple.dock expose-group-by-app false

# Enable auto-hiding of the dock and make it reappear quickly.
defaults write --verbose --force com.apple.dock autohide true
defaults write --verbose --force com.apple.dock autohide-delay 0.0

# Force the changes to take effect by restarting the Dock.
^killall Dock

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
