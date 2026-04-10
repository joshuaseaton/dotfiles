# Git operations via fzf.

const GIT_FZF_OPTS = [
    --no-info
    --preview-window noinfo
    --bind "enter:accept"
    --bind "alt-.:ignore"
    --bind "alt-o:ignore"
]

# `git log` with a nice fzf view of commits when executed without args.
@complete external
export def --wrapped "log" [...args] {
    if ($args | is-not-empty) {
        ^git log ...$args
        return
    }

    let line = ^git log --pretty=format:"%h %an %s" --no-merges -100 |
        (
            ^fzf ...$GIT_FZF_OPTS
            --no-sort
            --bind "start:change-prompt(log ❯ )"
            --preview "git show --stat --patch --color=always {1}"
        ) |
        str trim
    if ($line | is-not-empty) {
        let short = $line | split row " " | first
        let hash = ^git rev-parse $short
        commandline edit --append $hash
    }
}

# `git stash` with a nice fzf view of stashes when executed with only "list".
@complete external
export def --wrapped "stash" [...args] {
    if ($args != [list]) {
        ^git stash ...$args
        return
    }
    let line = ^git stash list --format="%gd %s" |
        (
            ^fzf ...$GIT_FZF_OPTS
            --bind "start:change-prompt(stash ❯ )"
            --preview "git stash show --patch --color=always {1}"
        ) |
        str trim
    if ($line | is-not-empty) {
        let stash = $line | split row " " | first
        commandline edit --append $stash
    }
}

# `git status` with a nice fzf view of changed files when executed without args.
@complete external
export def --wrapped "status" [...args] {
    if ($args | is-not-empty) {
        ^git status ...$args
        return
    }

    let line = ^git status --short |
        (
            ^fzf ...$GIT_FZF_OPTS
            --bind "start:change-prompt(status ❯ )"
            --preview "git diff --color=always -- {-1}"
        ) |
        str trim
    if ($line | is-not-empty) {
        let file = $line | split row " " | last
        commandline edit --append $file
    }
}

# `git diff` with a nice fzf view of changed files when executed without args.
@complete external
export def --wrapped "diff" [...args] {
    if ($args | is-not-empty) {
        ^git diff ...$args
        return
    }
    let result = ^git diff --name-only |
        (
            ^fzf ...$GIT_FZF_OPTS
            --bind "start:change-prompt(diff ❯ )"
            --preview "git diff --color=always -- {}"
        ) |
        str trim
    if ($result | is-not-empty) {
        commandline edit --append $result
    }
}


# `git branch` with a nice fzf view of available branches when executed
# without args.
@complete external
export def --wrapped "branch" [...args] {
    if ($args | is-not-empty) {
        ^git branch ...$args
        return
    }
    let result = ^git branch --format '%(refname:short)' |
        (
            ^fzf ...$GIT_FZF_OPTS
            --bind "start:change-prompt(branch ❯ )"
            --preview "git log --oneline --color=always -20 {}"
        ) |
        str trim
    if ($result | is-not-empty) {
        commandline edit --append $result
    }
}
