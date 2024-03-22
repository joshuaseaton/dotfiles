# Nushell Environment Config File
#
# version = "0.91.1"

def create_left_prompt [] {
    let dir = match (do --ignore-shell-errors { $env.PWD | path relative-to $nu.home-path }) {
        null => $env.PWD
        '' => '~'
        $relative_pwd => ([~ $relative_pwd] | path join)
    }

    let path_color = ansi white
    let separator_color =  ansi white
    let path_segment = $"($path_color)($dir)"

    $path_segment | str replace --all (char path_sep) $"($separator_color)(char path_sep)($path_color)"
}

def create_right_prompt [] {
    # create a right prompt in magenta with green separators and am/pm underlined
    let time_segment = ([
        (ansi reset)
        (ansi white)
        (date now | format date '%H:%M:%S')
    ] | str join)

    let last_exit_code = if ($env.LAST_EXIT_CODE != 0) {([
        (ansi rb)
        ($env.LAST_EXIT_CODE)
    ] | str join)
    } else { "" }

    ([$last_exit_code, (char space), $time_segment] | str join)
}

$env.PROMPT_COMMAND = {|| create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = {|| create_right_prompt }
$env.PROMPT_INDICATOR = {|| $"(ansi white) ❯ " }

# Directories to search for scripts when calling `source` or `use`
$env.NU_LIB_DIRS = [ ([$nu.home-path .dotfiles nu lib] | path join) ]

if (sys | get host.name) == Darwin {
    $env.PATH = $"($env.PATH):/opt/homebrew/bin"
}

$env.DOTFILES = ([$nu.home-path .dotfiles] | path join)

# TODO: Remove this if/when --env-config ever gets a sane default.
export def run [script: string, ...args: string] {
    ^nu --env-config $nu.env-path $script ...$args
}
