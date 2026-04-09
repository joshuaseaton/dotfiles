#
# An alternate config used internally in the definition of fzf bindings.
#

export def fzf-internal-copy [input: string] {
    match $nu.os-info.name {
        linux => { $input | ^xclip -in -selection clipboard }
        macos => { $input | ^pbcopy }
    }
}

export def fzf-internal-open [input: string] {
    ^($env.EDITOR | split words | first) $input
}

def get-prompt-state []: nothing -> record {
    let prompt = $env.FZF_PROMPT
    {
        hidden: ("+." in $prompt)
        open: ("open" in $prompt)
    }
}

def prompt-state-to-string [state: record]: nothing -> string {
    let hidden_suffix = if $state.hidden { "+." } else { "" }
    let on_enter = if $state.open { "open" } else { "copy" }
    $on_enter + $hidden_suffix + " > "
}

# TODO: needs to toggle the actual find command as well.
export def fzf-internal-toggle-hidden []: nothing -> string {
    mut state = get-prompt-state
    $state.hidden = not $state.hidden
    let new_prompt = prompt-state-to-string $state
    $"change-prompt\(($new_prompt)\)"
}

# TODO: needs to toggle the actual enter command as well.
export def fzf-internal-toggle-open []: nothing -> string {
    mut state = get-prompt-state
    $state.open = not $state.open
    let new_prompt = prompt-state-to-string $state
    $"change-prompt\(($new_prompt)\)"
}
