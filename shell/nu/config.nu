const BLUE_PASTEL = "#b3d9ff"
const GREEN_PASTEL = "#b8e6b8"
const PEACH_PASTEL = "#ffd1b3"
const PINK_PASTEL = "#ffd1f0"
const PURPLE_PASTEL = "#d1b3ff"
const RED_PASTEL = "#ffb3b3"
const YELLOW_PASTEL = "#fff2b3"

$env.config.color_config = {
    # Settings commented out are defaults I don't know yet what to do with
    # or haven't encountered.

    separator: white_bold
    #leading_trailing_space_bg: { attr: n }
    header: { fg: $PEACH_PASTEL, attr: "b" }
    #empty: blue
    bool: {fg: $GREEN_PASTEL, attr: "b"}
    int: $BLUE_PASTEL
    filesize: $BLUE_PASTEL
    duration: $BLUE_PASTEL
    datetime: $PINK_PASTEL
    range: $YELLOW_PASTEL
    float: $BLUE_PASTEL
    string: $RED_PASTEL
    #nothing: white
    #binary: white
    #cell-path: white
    #row_index: green_bold
    record: white
    list: white
    closure: white
    glob: white_bold
    #block: white
    #hints: dark_gray
    search_result: { bg: "white", fg: "black", attr: "i" }
    #shape_binary: purple_bold
    shape_block: white
    shape_bool: {fg: $GREEN_PASTEL, attr: "b"}
    shape_closure: white
    shape_custom: white
    shape_datetime: $RED_PASTEL
    #shape_directory: cyan
    shape_external: white
    shape_externalarg: $YELLOW_PASTEL
    #shape_external_resolved: light_yellow_bold
    shape_filepath: white
    shape_flag: $YELLOW_PASTEL
    shape_float: $BLUE_PASTEL
    shape_glob_interpolation: white_bold
    shape_globpattern: white_bold
    shape_int: $BLUE_PASTEL
    shape_internalcall: white_bold
    shape_keyword: $YELLOW_PASTEL
    shape_list: white
    #shape_literal: blue
    shape_match_pattern: $PEACH_PASTEL
    #shape_matching_brackets: { attr: u }
    #shape_nothing: light_cyan
    shape_operator: white_bold
    shape_pipe: white_bold
    shape_range: $YELLOW_PASTEL
    shape_record: white
    shape_redirection: {fg: $PURPLE_PASTEL, attr: "b"}
    #shape_signature: green_bold
    shape_string: $RED_PASTEL
    #shape_string_interpolation: cyan_bold
    #shape_table: blue_bold
    shape_variable: $PURPLE_PASTEL
    shape_vardecl: $PURPLE_PASTEL
    #shape_raw_string: light_purple
    shape_garbage: {fg: "red", attr: "bi" }
}
$env.config.completions.algorithm = "fuzzy"
$env.config.completions.sort = "smart"
$env.config.footer_mode = "always"
$env.config.ls.use_ls_colors = false
$env.config.show_banner = false
$env.config.table.mode = "thin"
$env.config.table.index_mode = "never"
$env.config.table.missing_value_symbol = " ∅ "

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

if ($env | get --optional EDITOR) == null {
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
    append [ "/bin", "/sbin", "/usr/bin", "/usr/sbin" ] |
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
            /opt/homebrew/opt/lld/bin,
            /opt/homebrew/opt/llvm/bin,
            /opt/homebrew/opt/llvm@18/bin,

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

# TODO: Remove this if/when --config ever gets a sane default.
export def run [script: string, ...args: string] {
    if not ($script | path exists) {
        error make --unspanned {msg: $"Script does not exist: ($script)"}
    }
    ^nu --config $nu.config-path $script ...$args
}
