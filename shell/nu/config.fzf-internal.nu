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

# Preview a line from `git status --short`, choosing the right view based on
# the XY status prefix: XY where X = index (staged) and Y = working tree.
export def fzf-internal-git-status-preview [line: string] {
    let index = $line | str substring 0..0
    let worktree = $line | str substring 1..1
    let file = $line | str substring 3..

    let is_untracked = $index == "?"
    let is_conflicted = (
        $index == "U" or $worktree == "U"  # unmerged
        or ($index == "A" and $worktree == "A")  # added
        or ($index == "D" and $worktree == "D")  # deleted
    )
    let has_unstaged_changes = $worktree != " "

    if $is_untracked or $is_conflicted {
        ^bat --color=always --style=numbers $file
    } else if $has_unstaged_changes {
        ^git diff --color=always -- $file
    } else {
        ^git diff --cached --color=always -- $file
    }
}

# Toggle the staging state of a file from `git status --short` and return a
# reload action for use in a transform binding.
export def fzf-internal-git-status-toggle-stage [line: string]: nothing -> string {
    let index = $line | str substring 0..0
    let file = $line | str substring 3..
    let is_staged = $index != " " and $index != "?" and $index != "U"  # space/untracked/unmerged

    if $is_staged {
        ^git restore --staged -- $file
    } else {
        ^git add -- $file
    }
    "reload(fzf-internal-git-status-list)"
}

# List `git status --short -uall` with staged files italicized.
export def fzf-internal-git-status-list [] {
    ^git status --short -uall | lines |
    sort-by { str substring 3.. } |
    each {|line|
        let index = $line | str substring 0..0
        if $index != " " and $index != "?" and $index != "U" {  # staged
            $"(ansi -e '3m')($line)(ansi reset)"
        } else {
            $line
        }
    } | str join (char newline)
}

# Clear the query if non-empty, otherwise abort.
export def fzf-internal-clear-or-abort []: nothing -> string {
    if ($env.FZF_QUERY | is-empty) {
        "abort"
    } else {
        "clear-query"
    }
}
