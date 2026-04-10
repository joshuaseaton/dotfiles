#
# An alternate config used internally in the definition of fzf bindings.
#

const DEFAULT_STATE = {hidden: false, open: false}

const FIND_WITHOUT_HIDDEN = "fd --type f --follow --exclude .git --exclude .jj"
const FIND_WITH_HIDDEN = "fd --type f --follow --unrestricted --exclude .git --exclude .jj"

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
    $on_enter + $hidden_suffix + " ❯ "
}

# Set the default prompt and find command.
export def fzf-internal-start [] {
    let prompt = prompt-state-to-string $DEFAULT_STATE
    [
        $"change-prompt<($prompt)>"
        $"reload<($FIND_WITHOUT_HIDDEN)>"
    ] | str join "+"
}

# Dispatch the enter action in the context of an transform, keying off the
# prompt state to determine whether to open the file or copy its path.
export def fzf-internal-dispatch-enter []: nothing -> string {
    let state = get-prompt-state
    let command = if $state.open {
        $"^($env.EDITOR | split words | first) {+}"
    } else {
        match $nu.os-info.name {
            linux => "[{+}] | str join (char newline) | ^xclip -selection clipboard",
            macos => "[{+}] | str join (char newline) | ^pbcopy",
        }
    }
    $"become<($command)>"
}

# Toggle whether hidden files are included in the fzf results, and update the
# prompt accordingly.
export def fzf-internal-toggle-hidden []: nothing -> string {
    mut state = get-prompt-state
    $state.hidden = not $state.hidden

    let new_prompt = prompt-state-to-string $state
    let new_command = if $state.hidden { $FIND_WITH_HIDDEN } else { $FIND_WITHOUT_HIDDEN }
    [
        $"change-prompt<($new_prompt)>"
        $"reload<($new_command)>"
    ] | str join "+"
}

# Toggle whether the "enter" action opens the file or copies its path, and
# update the prompt accordingly.
export def fzf-internal-toggle-open []: nothing -> string {
    mut state = get-prompt-state
    $state.open = not $state.open

    let new_prompt = prompt-state-to-string $state
    $"change-prompt<($new_prompt)>"
}
