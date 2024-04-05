# Logging convenience utilities.

# Logs information.
export def info [msg: string] {
    print --stderr $"(ansi blue_bold)Info:(ansi reset) ($msg)"
}

# Logs a warning.
export def warning [msg: string] {
    print --stderr $"(ansi yellow_bold)Warning:(ansi reset) ($msg)"
}

# Logs an error.
export def error [msg: string] {
    print --stderr $"(ansi red_bold)Error:(ansi reset) ($msg)"
}
