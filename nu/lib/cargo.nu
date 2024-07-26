# Lists the installed cargo crates and their binaries.
export def installed [] {
    ^cargo install --list |
        lines |
        reduce --fold null {|line, table|
            if ($line | str ends-with ":") {
                $table | append ($line | parse "{name} v{version}:" | insert binaries [])
            } else {
                let last_row = ($table | length) - 1
                $table | upsert ([$last_row binaries] | into cell-path) {|| append ($line | str trim)}
            }
        }
}
