# Copy text to the clipboard if specified on stdin, or else pastes from the
# clipboard to stdout.
export def main [] {
    match $nu.os-info.name {
        linux => {
            if $in == null {
                ^xclip -o
            } else {
                $in | ^xclip -selection clipboard
            }
        }
        macos => {
            if $in == null {
                ^pbpaste
            } else {
                $in | ^pbcopy
            }
        }
        _ => { error make --unspanned $"Unsupported OS: ($nu.os-info.name)" }
    }
}
