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
        (ansi reset)
        (ansi rb)
        ($env.LAST_EXIT_CODE)
    ] | str join)
    }

    let in_git_repo = ^git rev-parse --is-inside-work-tree |
        complete |
        get stderr |
        is-empty

    let git_context = if $in_git_repo {
        let branch = ^git branch --show-current
        let context = if ($branch | is-empty) {
            let first = ^git branch | lines | first
            let detached = $first | parse "* (HEAD detached {at_or_from} {name})"
            if ($detached | is-not-empty) {
                $detached.name.0
            } else {
                let rebasing = $first |
                    parse "* (no branch, rebasing {branch})" |
                    get branch.0
                $rebasing + " (rebasing)"
            }
        } else {
            $branch
        }
        [(ansi reset) (ansi purple) $context] | str join
    }

    [$last_exit_code $git_context $time_segment] |
        where $it != null |
        str join (char space)
}

$env.PROMPT_COMMAND = {|| create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = {|| create_right_prompt }
$env.PROMPT_INDICATOR = {|| $"(ansi white) ❯ " }

# Directories to search for scripts when calling `source` or `use`
$env.NU_LIB_DIRS = [ ([$nu.home-path .dotfiles nu lib] | path join) ]

let brew_bin_dir = (match $nu.os-info.name {
    linux => "/home/linuxbrew/.linuxbrew/bin"
    macos => "/opt/homebrew/bin"
})

# But of course.
$env.SHELL = $nu.current-exe

if ($env | get --ignore-errors EDITOR) == null {
    # A saner default than Vim. VSCode and Zed will specify their own integrated
    # terminals.
    $env.EDITOR = ([$brew_bin_dir micro] | path join)
}
$env.MICRO_CONFIG_HOME = ([$nu.home-path .config micro] | path join)

# The default value, but it's handy in scripts to be able to refer to it without
# taking the location as a hard-coded dependency.
$env.GOBIN = ([$nu.home-path go bin] | path join)

$env.PATH = ($env.PATH |
    split row (char esep) |
    prepend [
        $brew_bin_dir,
       ([$nu.home-path .cargo bin] | path join),
       ([$nu.home-path .local bin] | path join),   # pipx installation directory
       $env.GOBIN,
    ] |
    uniq)

$env.DOTFILES = ([$nu.home-path .dotfiles] | path join)

$env.CCACHE = "ccache"

$env.HOMEBREW_NO_ANALYTICS = 1

# Do not print any hints about changing Homebrew’s behaviour with
# environment variables.
$env.HOMEBREW_NO_ENV_HINTS = 1

# TODO: Remove this if/when --env-config ever gets a sane default.
export def run [script: string, ...args: string] {
    ^nu --env-config $nu.env-path $script ...$args
}
