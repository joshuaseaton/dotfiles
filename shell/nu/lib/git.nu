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

    let git_dir = ^git rev-parse --git-dir | str trim
    let rebase_merge = [$git_dir rebase-merge] | path join
    let rebase_apply = [$git_dir rebase-apply] | path join

    let header_args = if ($rebase_merge | path exists) {
        let head_name = open ([$rebase_merge head-name] | path join) | str trim | str replace "refs/heads/" ""
        let onto_short = open ([$rebase_merge onto] | path join) | str trim | ^git rev-parse --short $in | str trim
        let done = open ([$rebase_merge done] | path join) | lines | where { $in | is-not-empty } | length
        let todo = open ([$rebase_merge git-rebase-todo] | path join) | lines | where { not ($in | str starts-with "#") and ($in | is-not-empty) } | length
        [--header $"rebasing ($head_name) onto ($onto_short) \(($done)/($done + $todo)\)"]
    } else if ($rebase_apply | path exists) {
        let next = open ([$rebase_apply next] | path join) | str trim
        let last = open ([$rebase_apply last] | path join) | str trim
        [--header $"rebase in progress \(($next)/($last)\)"]
    } else {
        []
    }

    ^git status --short -uall |
        (
            ^fzf ...$GIT_FZF_OPTS ...$header_args
            --ansi
            --bind "start:change-prompt(status ❯ )+reload(fzf-internal-git-status-list)"
            --bind "tab:transform(fzf-internal-git-status-toggle-stage {})"
            --preview "fzf-internal-git-status-preview {}"
        ) | ignore
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
