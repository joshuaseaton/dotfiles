const BLUE_PASTEL = "#b3d9ff"
const CREAM = "#fff5e6" 
const GREEN_PASTEL = "#b8e6b8"
const PEACH_PASTEL = "#ffd1b3"
const PINK_PASTEL = "#ffd1f0"
const PURPLE_PASTEL = "#d1b3ff"
const RED_PASTEL = "#ffb3b3"
const YELLOW_PASTEL = "#fff2b3"

$env.config.color_config = {
    # Commented-out settings show upstream defaults.

    # Data/output colors

    #binary: default
    #binary_ascii_other: purple_bold
    #binary_non_ascii: yellow_bold
    #binary_null_char: { fg: "#6c6c6c" }
    #binary_printable: cyan_bold
    #binary_whitespace: green_bold
    #block: default
    bool: $GREEN_PASTEL
    #cell-path: default
    closure: white
    datetime: $PINK_PASTEL
    duration: $BLUE_PASTEL
    #empty: blue
    filesize: $BLUE_PASTEL
    float: $BLUE_PASTEL
    glob: white
    header: $PEACH_PASTEL
    #hints: dark_gray
    int: $BLUE_PASTEL
    #leading_trailing_space_bg: { bg: "#808080" }
    list: white
    #nothing: default
    range: $YELLOW_PASTEL
    record: white
    #row_index: green_bold
    search_result: { bg: "white", fg: "black", attr: "i" }
    separator: white
    string: $RED_PASTEL

    # Syntax highlighting shapes

    #shape_binary: purple_bold
    shape_block: white
    shape_bool: $GREEN_PASTEL
    shape_closure: white
    shape_custom: white
    shape_datetime: $RED_PASTEL
    shape_directory: white
    shape_external: white
    shape_externalarg: white
    #shape_external_resolved: light_yellow_bold
    shape_filepath: white
    shape_flag: white
    shape_float: $BLUE_PASTEL
    shape_garbage: { fg: "red", attr: "i" }
    shape_glob_interpolation: white
    shape_globpattern: white
    shape_int: $BLUE_PASTEL
    shape_internalcall: {fg: white, attr: "u"}
    shape_keyword: $YELLOW_PASTEL
    shape_list: white
    #shape_literal: blue
    shape_match_pattern: $PEACH_PASTEL
    #shape_matching_brackets: { attr: u }
    shape_nothing: {fg: white, attr: "i"}
    shape_operator: $CREAM
    shape_pipe: $CREAM
    shape_range: $YELLOW_PASTEL
    #shape_raw_string: light_magenta_bold
    shape_record: white
    shape_redirection: $PURPLE_PASTEL
    #shape_signature: green_bold
    shape_string: $RED_PASTEL
    #shape_string_interpolation: cyan_bold
    #shape_table: blue_bold
    shape_variable: $PURPLE_PASTEL
    shape_vardecl: $PURPLE_PASTEL
}
$env.config.footer_mode = "always"
$env.config.history.file_format = "sqlite"
$env.config.history.isolation = true
$env.config.history.sync_on_enter = true
$env.config.ls.use_ls_colors = false
$env.config.show_banner = false
$env.config.table.mode = "thin"
$env.config.table.index_mode = "never"
$env.config.table.missing_value_symbol = " ∅ "

$env.config.keybindings = ($env.config.keybindings | append [
    {
        name: fzf_history
        modifier: control
        keycode: char_r
        mode: [emacs, vi_normal, vi_insert]
        event: {
            send: executehostcommand
            cmd: "
                let result = (
                    history | get command | reverse | uniq | str join (char newline) |
                    ^fzf ...$env.FZF_CTRL_R_OPTS | str trim
                );
                if ($result | is-not-empty) { commandline edit --replace $result }
            "
        }
    }
    {
        name: fzf_cd
        modifier: alt
        keycode: char_c
        mode: [emacs, vi_normal, vi_insert]
        event: {
            send: executehostcommand
            cmd: "
                let result = (
                    fd --type d --follow --exclude .git --exclude .jj |
                    ^fzf ...$env.FZF_ALT_C_OPTS | str trim
                );
                if ($result | is-not-empty) { cd $result }
            "
        }
    }
])

let carapace_completer = {|spans|
  load-env {
  	CARAPACE_SHELL_BUILTINS: (
        help commands |
        where category != "" |
        get name |
        each { split row " " | first } |
        uniq |
        str join (char newline)
    )
  	CARAPACE_SHELL_FUNCTIONS: (
        help commands |
        where category == "" |
        get name |
        each { split row " " | first } |
        uniq |
        str join (char newline)
    )
  }

  # Module subcommands arrive as a single span (e.g., "git log").
  # Split them so carapace sees individual words.
  let spans = $spans | each { split row " " } | flatten

  # If the current command is an alias, get its expansion.
  let expanded_alias = (scope aliases | where name == $spans.0 | $in.0?.expansion?)

  let spans = (if $expanded_alias != null  {
    $spans | skip 1 | prepend ($expanded_alias | split row " " | take 1)
  } else {
    $spans
  })

  carapace $spans.0 nushell ...$spans | from json
}

$env.config.completions = ($env.config.completions | merge {
    case_sensitive: false  # case-insensitive matching
    algorithm: "fuzzy"  # fuzzy match instead of prefix-only
    sort: "smart"
    quick: true  # auto-accept sole matches
    partial: true  # fill common prefix on tab
    external: {
        enable: true
        completer: $carapace_completer
    }
})

def create-left-prompt [] {
    let dir = match (do --ignore-errors { $env.PWD | path relative-to $nu.home-dir }) {
        null => $env.PWD
        '' => '~'
        $relative_pwd => ([~ $relative_pwd] | path join)
    }

    let path_color = ansi white
    let separator_color =  ansi white
    let path_segment = $"($path_color)($dir)"

    $path_segment | str replace --all (char path_sep) $"($separator_color)(char path_sep)($path_color)"
}

def create-right-prompt [] {
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
        [(ansi reset) (ansi $PURPLE_PASTEL) $context] | str join
    }

    [$last_exit_code $git_context $time_segment] |
        compact |
        str join (char space)
}

$env.PROMPT_COMMAND = {|| create-left-prompt }
$env.PROMPT_COMMAND_RIGHT = {|| create-right-prompt }
$env.PROMPT_INDICATOR = {|| $"(ansi white) ❯ " }

let dotfiles = ([$nu.home-dir .dotfiles] | path join)

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

if $env.EDITOR? == null {
    # A saner default than Vim. VSCode and Zed will specify their own integrated
    # terminals.
    $env.EDITOR = "micro"
}
$env.MICRO_CONFIG_HOME = ([$nu.home-dir .config micro] | path join)

# The default value, but it's handy in scripts to be able to refer to it without
# taking the location as a hard-coded dependency.
$env.GOBIN = ([$nu.home-dir go bin] | path join)

$env.PATH = ($env.PATH |
    split row (char esep) |
    append [ "/bin", "/sbin", "/usr/bin", "/usr/local/bin", "/usr/sbin" ] |
    prepend [
       ([$nu.home-dir .cargo bin] | path join),
       ([$nu.home-dir .local bin] | path join),   # pipx installation directory
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
$env.PAGER = "bat" # jj uses this.
$env.BAT_THEME = "kanagawa-forest"

# Pastel color scheme for fzf, matching the nushell theme.
let fzf_colors = ({
    fg: "-1"                # terminal default
    bg: "-1"                # terminal default
    hl: $RED_PASTEL         # matched substrings
    "fg+": $RED_PASTEL    # current line text
    "bg+": "-1"             # terminal default
    "hl+": $RED_PASTEL      # current line matched substrings
    prompt: $BLUE_PASTEL
    pointer: $RED_PASTEL
    info: $PEACH_PASTEL
    preview-scrollbar: "white:-1"
    border: white
} | items {|k, v| $"($k):($v)" } | str join ",")

# This command includes an alternate config with internal utilities for defining
# fzf bindings. We keep it separate to not pollute the global command/module
# namespace with these internals.
let fzf_shell_command = ([
    nu
    --config ([$env.HOME .dotfiles shell nu config.fzf-internal.nu] | path join)
    --commands
] | str join " ")
$env.FZF_DEFAULT_OPTS = ([
    --with-shell $"'($fzf_shell_command)'"

    # Styling.
    --border none
    --color $fzf_colors

    # Navigation.
    --layout reverse
    --multi
    --scroll-off 3

    # Core search bindings.
    --bind "'start:transform<fzf-internal-start>'"
    --bind "'enter:transform<fzf-internal-dispatch-enter>'"
    --bind "'alt-.:transform<fzf-internal-toggle-hidden>'"
    --bind "'alt-o:transform<fzf-internal-toggle-open>'"
    --bind "'ctrl-c:transform<fzf-internal-clear-or-abort>'"
    --bind "'tab:toggle'"

    # Previews.
    --preview "'bat --color=always --style=numbers --line-range=:500 {}'"
    --preview-window border-none
    --preview-window noinfo
    --bind "'ctrl-/:toggle-preview'"
    --bind "'shift-up:preview-up'"
    --bind "'shift-down:preview-down'"
] | str join " ")

$env.FZF_CTRL_R_OPTS = [
    --scheme history
    --no-sort
    --no-preview
    --bind "start:change-prompt(history ❯ )"
    --bind "enter:accept"
    --bind "alt-.:ignore"
    --bind "alt-o:ignore"
    --bind "tab:toggle"
]

$env.FZF_ALT_C_OPTS = [
    --scheme path
    --no-preview
    --bind "start:change-prompt(cd ❯ )"
    --bind "enter:accept"
    --bind "alt-.:ignore"
    --bind "alt-o:ignore"
]

# TODO: Remove this if/when --config ever gets a sane default.
export def run [script: string, ...args: string] {
    if not ($script | path exists) {
        error make --unspanned $"Script does not exist: ($script)"
    }
    ^nu --config $nu.config-path $script ...$args
}
