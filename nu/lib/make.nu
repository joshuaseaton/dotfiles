# A simple wrapper for autogenerating a compile_commands.json in the current
# working directory.
export def main [...args: string] {
    ^compiledb make ...$args
}
