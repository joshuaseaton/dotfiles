# Nushell Environment Config File
#
# version = "0.98.0"

def create_left_prompt [] {
    let dir = match (do --ignore-errors { $env.PWD | path relative-to $nu.home-path }) {
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

let dotfiles = ([$nu.home-path .dotfiles] | path join)

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
$env.ENV_CONVERSIONS = {
    "PATH": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
}

# Directories to search for scripts when calling `source` or `use`
$env.NU_LIB_DIRS = [ ([$dotfiles shell nu lib] | path join) ]

# Directories to search for plugin binaries when calling register
$env.NU_PLUGIN_DIRS = []

# But of course.
$env.SHELL = $nu.current-exe

if ($env | get --ignore-errors EDITOR) == null {
    # A saner default than Vim. VSCode and Zed will specify their own integrated
    # terminals.
    $env.EDITOR = "micro"
}
$env.MICRO_CONFIG_HOME = ([$nu.home-path .config micro] | path join)

# The default value, but it's handy in scripts to be able to refer to it without
# taking the location as a hard-coded dependency.
$env.GOBIN = ([$nu.home-path go bin] | path join)

$env.PATH = ($env.PATH |
    split row (char esep) |
    prepend [
       ([$nu.home-path .cargo bin] | path join),
       ([$nu.home-path .local bin] | path join),   # pipx installation directory
       $env.GOBIN,
    ] |
    prepend (match $nu.os-info.name {
        linux => [ /home/linuxbrew/.linuxbrew/bin ]
        macos => [
            /opt/homebrew/bin,
            /opt/homebrew/opt/binutils/bin,
            /opt/homebrew/opt/dosfstools/sbin,

            # The mac `make` brew package only puts "gmake" in
            # /opt/homebrew/bin; this directory defines a symlink to it called
            # "make".
            /opt/homebrew/opt/make/libexec/gnubin,
        ]
    }) |
    uniq)

$env.CCACHE = "ccache"

$env.HOMEBREW_NO_ANALYTICS = 1

# Do not print any hints about changing Homebrew’s behaviour with
# environment variables.
$env.HOMEBREW_NO_ENV_HINTS = 1

# A saner default than less.
$env.MANPAGER = "bat"

# TODO: Remove this if/when --env-config ever gets a sane default.
export def run [script: string, ...args: string] {
    if not ($script | path exists) {
        error make --unspanned {msg: $"Script does not exist: ($script)"}
    }
    ^nu --env-config $nu.env-path $script ...$args
}
