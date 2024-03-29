# Initially cribbed from https://github.com/nushell/nu_scripts/blob/main/custom-completions/git/git-completions.nu

# Stage files
export extern "git add" [
  ...file: string@"nu-complete git files"  # File to add
  --all(-A)                                # Add all files
  --dry-run(-n)                            # Don't actually add the file(s), just show if they exist and/or will be ignored
  --edit(-e)                               # Open the diff vs. the index in an editor and let the user edit it
  --force(-f)                              # Allow adding otherwise ignored files
  --interactive(-i)                        # Add modified contents in the working tree interactively to the index
  --patch(-p)                              # Interactively choose hunks to stage
  --verbose(-v)                            # Be verbose
]

# Start a binary search to find the commit that introduced a bug
export extern "git bisect start" [
  bad?: string   # A commit that has the bug
  good?: string  # A commit that doesn't have the bug
]

# Mark the current (or specified) revision as bad
export extern "git bisect bad" [
]

# Mark the current (or specified) revision as good
export extern "git bisect good" [
]

# Skip the current (or specified) revision
export extern "git bisect skip" [
]

# End bisection
export extern "git bisect reset" [
]

# List or change branches
export extern "git branch" [
  branch?: string@"nu-complete git local branches"                # Name of branch to operate on
  --abbrev                                                        # Use short commit hash prefixes
  --edit-description                                              # Open editor to edit branch description
  --merged                                                        # List reachable branches
  --no-merged                                                     # List unreachable branches
  --set-upstream-to: string@"nu-complete git available upstream"  # Set upstream for branch
  --unset-upstream                                                # Remote upstream for branch
  --all                                                           # List both remote and local branches
  --copy                                                          # Copy branch together with config and reflog
  --format                                                        # Specify format for listing branches
  --move                                                          # Rename branch
  --points-at                                                     # List branches that point at an object
  --show-current                                                  # Print the name of the current branch
  --verbose                                                       # Show commit and upstream for each branch
  --color                                                         # Use color in output
  --quiet                                                         # Suppress messages except errors
  --delete(-d)                                                    # Delete branch
  --list                                                          # List branches
  --contains: string@"nu-complete git commits all"                # Show only branches that contain the specified commit
  --no-contains                                                   # Show only branches that don't contain specified commit
  --track(-t)                                                     # When creating a branch, set upstream
]

# Check out git branches and files
export extern "git checkout" [
  ...targets: string@"nu-complete git checkout"  # Name of the branch or files to checkout
  --conflict: string                             # Conflict style (merge or diff3)
  --detach(-d)                                   # Detach HEAD at named commit
  --force(-f)                                    # Force checkout (throw away local modifications)
  --guess                                        # Second guess 'git checkout <no-such-branch>' (default)
  --ignore-other-worktrees                       # Do not check if another worktree is holding the given ref
  --ignore-skip-worktree-bits                    # Do not limit pathspecs to sparse entries only
  --merge(-m)                                    # Perform a 3-way merge with the new branch
  --orphan: string                               # New unparented branch
  --ours(-2)                                     # Checkout our version for unmerged files
  --overlay                                      # Use overlay mode (default)
  --overwrite-ignore                             # Update ignored files (default)
  --patch(-p)                                    # Select hunks interactively
  --pathspec-from-file: string                   # Read pathspec from file
  --progress                                     # Force progress reporting
  --quiet(-q)                                    # Suppress progress reporting
  --recurse-submodules                           # Control recursive updating of submodules
  --theirs(-3)                                   # Checkout their version for unmerged files
  --track(-t)                                    # Set upstream info for new branch
  -b                                             # Create and checkout a new branch
  -B: string                                     # Create/reset and checkout a branch
  -l                                             # Create reflog for new branch
]

# Apply the change introduced by an existing commit
export extern "git cherry-pick" [
  commit?: string@"nu-complete git commits all"  # The commit ID to be cherry-picked
  --edit(-e)                                     # Edit the commit message prior to committing
  --no-commit(-n)                                # Apply changes without making any commit
  --signoff(-s)                                  # Add Signed-off-by line to the commit message
  --ff                                           # Fast-forward if possible
  --continue                                     # Continue the operation in progress
  --abort                                        # Cancel the operation
  --skip                                         # Skip the current commit and continue with the rest of the sequence
]

# Commit changes
export extern "git commit" [
  --all(-a)      # Automatically stage all modified and deleted files
  --amend        # Amend the previous commit rather than adding a new one
  --message(-m)  # Specify the commit message rather than opening an editor
  --no-edit      # Don't edit the commit message (useful with --amend)
]

# Show changes between commits, working tree, etc.
export extern "git diff" [
  rev1_or_file?: string@"nu-complete git files-or-refs"
  rev2?: string@"nu-complete git refs"
  --cached                                               # Show staged changes
  --name-only                                            # Only show names of changed files
  --name-status                                          # Show changed files and kind of change
  --no-color                                             # Disable color output
]

# Download objects and refs from another repository
export extern "git fetch" [
  repository?: string@"nu-complete git remotes"  # Name of the branch to fetch
  --all                                          # Fetch all remotes
  --append(-a)                                   # Append ref names and object names to .git/FETCH_HEAD
  --atomic                                       # Use an atomic transaction to update local refs.
  --depth: int                                   # Limit fetching to n commits from the tip
  --deepen: int                                  # Limit fetching to n commits from the current shallow boundary
  --shallow-since: string                        # Deepen or shorten the history by date
  --shallow-exclude: string                      # Deepen or shorten the history by branch/tag
  --unshallow                                    # Fetch all available history
  --update-shallow                               # Update .git/shallow to accept new refs
  --negotiation-tip: string                      # Specify which commit/glob to report while fetching
  --negotiate-only                               # Do not fetch, only print common ancestors
  --dry-run                                      # Show what would be done
  --write-fetch-head                             # Write fetched refs in FETCH_HEAD (default)
  --no-write-fetch-head                          # Do not write FETCH_HEAD
  --force(-f)                                    # Always update the local branch
  --keep(-k)                                     # Keep dowloaded pack
  --multiple                                     # Allow several arguments to be specified
  --auto-maintenance                             # Run 'git maintenance run --auto' at the end (default)
  --no-auto-maintenance                          # Don't run 'git maintenance' at the end
  --auto-gc                                      # Run 'git maintenance run --auto' at the end (default)
  --no-auto-gc                                   # Don't run 'git maintenance' at the end
  --write-commit-graph                           # Write a commit-graph after fetching
  --no-write-commit-graph                        # Don't write a commit-graph after fetching
  --prefetch                                     # Place all refs into the refs/prefetch/ namespace
  --prune(-p)                                    # Remove obsolete remote-tracking references
  --prune-tags(-P)                               # Remove any local tags that do not exist on the remote
  --no-tags(-n)                                  # Disable automatic tag following
  --refmap: string                               # Use this refspec to map the refs to remote-tracking branches
  --tags(-t)                                     # Fetch all tags
  --recurse-submodules: string                   # Fetch new commits of populated submodules (yes/on-demand/no)
  --jobs(-j): int                                # Number of parallel children
  --no-recurse-submodules                        # Disable recursive fetching of submodules
  --set-upstream                                 # Add upstream (tracking) reference
  --submodule-prefix: string                     # Prepend to paths printed in informative messages
  --upload-pack: string                          # Non-default path for remote command
  --quiet(-q)                                    # Silence internally used git commands
  --verbose(-v)                                  # Be verbose
  --progress                                     # Report progress on stderr
  --server-option(-o): string                    # Pass options for the server to handle
  --show-forced-updates                          # Check if a branch is force-updated
  --no-show-forced-updates                       # Don't check if a branch is force-updated
  -4                                             # Use IPv4 addresses, ignore IPv6 addresses
  -6                                             # Use IPv6 addresses, ignore IPv4 addresses
]

# Show help for a git subcommand
export extern "git help" [
  command: string@"nu-complete git subcommands"  # Subcommand to show help for
]

# Create a new git repository
export extern "git init" [
  --initial-branch(-b)  # Initial branch name
]

# List commits
export extern "git log" [
  # Ideally we'd allow completion of revisions here, but that would make completion of filenames not work.
  -U              # Show diffs
  --follow        # Show history beyond renames (single file only)
  --grep: string  # Show log entries matching supplied regular expression
]

# Prune all unreachable objects
export extern "git prune" [
  --dry-run(-n)     # Dry run
  --expire: string  # Expire objects older than value
  --progress        # Show progress
  --verbose(-v)     # Report all removed objects
]

# Pull changes
export extern "git pull" [
  remote?: string@"nu-complete git remotes",        # The name of the remote
  ...refs: string@"nu-complete git local branches"  # The branch / refspec
  --rebase                                          # Rebase current branch on top of upstream after fetching
]

# Push changes
export extern "git push" [
  remote?: string@"nu-complete git remotes",        # The name of the remote
  ...refs: string@"nu-complete git local branches"  # The branch / refspec
  --all                                             # Push all refs
  --atomic                                          # Request atomic transaction on remote side
  --delete(-d)                                      # Delete refs
  --dry-run(-n)                                     # Dry run
  --exec: string                                    # Receive pack program
  --follow-tags                                     # Push missing but relevant tags
  --force-with-lease                                # Require old value of ref to be at this value
  --force(-f)                                       # Force updates
  --ipv4(-4)                                        # Use IPv4 addresses only
  --ipv6(-6)                                        # Use IPv6 addresses only
  --mirror                                          # Mirror all refs
  --no-verify                                       # Bypass pre-push hook
  --porcelain                                       # Machine-readable output
  --progress                                        # Force progress reporting
  --prune                                           # Prune locally removed refs
  --push-option(-o): string                         # Option to transmit
  --quiet(-q)                                       # Be more quiet
  --receive-pack: string                            # Receive pack program
  --recurse-submodules: string                      # Control recursive pushing of submodules
  --repo: string                                    # Repository
  --set-upstream(-u)                                # Set upstream for git pull/status
  --signed: string                                  # GPG sign the push
  --tags                                            # Push tags (can't be used with --all or --mirror)
  --thin                                            # Use thin pack
  --verbose(-v)                                     # Be more verbose
]

# Rebase the current branch
export extern "git rebase" [
  branch?: string@"nu-complete git rebase"    # Name of the branch to rebase onto
  upstream?: string@"nu-complete git rebase"  # Upstream branch to compare against
  --continue                                  # Restart rebasing process after editing/resolving a conflict
  --abort                                     # Abort rebase and reset HEAD to original branch
  --quit                                      # Abort rebase but do not reset HEAD
  --interactive(-i)                           # Rebase interactively with list of commits in editor
  --onto?: string@"nu-complete git rebase"    # Starting point at which to create the new commits
  --root                                      # Start rebase from root commit
]

# Show or change the reflog
export extern "git reflog" [
]

# List or change tracked repositories
export extern "git remote" [
  --verbose(-v)  # Show URL for remotes
]

# Add a new tracked repository
export extern "git remote add" [
]

# Rename a tracked repository
export extern "git remote rename" [
  remote: string@"nu-complete git remotes"  # Remote to rename
  new_name: string                          # New name for remote
]

# Remove a tracked repository
export extern "git remote remove" [
  remote: string@"nu-complete git remotes"  # Remote to remove
]

# Get the URL for a tracked repository
export extern "git remote get-url" [
  remote: string@"nu-complete git remotes"  # Remote to get URL for
]

# Set the URL for a tracked repository
export extern "git remote set-url" [
  remote: string@"nu-complete git remotes"  # Remote to set URL for
  url: string                               # New URL for remote
]

# Delete file from the working tree and the index
export extern "git rm" [
  -r             # Recursive
  --force(-f)    # Override the up-to-date check
  --dry-run(-n)  # Don't actually remove any file(s)
  --cached       # Unstage and remove paths only from the index
]

# Stash changes for later
export extern "git stash push" [
  --patch(-p)  # Interactively choose hunks to stash
]

# Unstash previously stashed changes
export extern "git stash pop" [
  stash?: string@"nu-complete git stash-list"  # Stash to pop
  --index(-i)                                  # Try to reinstate not only the working tree's changes, but also the index's ones
]

# List stashed changes
export extern "git stash list" [
]

# Show a stashed change
export extern "git stash show" [
  stash?: string@"nu-complete git stash-list"
  -U                                           # Show diff
]

# Drop a stashed change
export extern "git stash drop" [
  stash?: string@"nu-complete git stash-list"
]

# Show the working tree status
export extern "git status" [
  --verbose(-v)  # Be verbose
  --short(-s)    # Show status concisely
  --branch(-b)   # Show branch information
  --show-stash   # Show stash information
]

# Switch between branches and commits
export extern "git switch" [
  switch?: string@"nu-complete git switch"    # Name of branch to switch to
  --create(-c)                                # Create a new branch
  --detach(-d): string@"nu-complete git log"  # Switch to a commit in a detatched state
  --force-create(-C): string                  # Forces creation of new branch, if it exists then the existing branch will be reset to starting point
  --force(-f)                                 # Alias for --discard-changes
  --guess                                     # If there is no local branch which matches then name but there is a remote one then this is checked out
  --ignore-other-worktrees                    # Switch even if the ref is held by another worktree
  --merge(-m)                                 # Attempts to merge changes when switching branches if there are local changes
  --no-guess                                  # Do not attempt to match remote branch names
  --no-progress                               # Do not report progress
  --no-recurse-submodules                     # Do not update the contents of sub-modules
  --no-track                                  # Do not set "upstream" configuration
  --orphan: string                            # Create a new orphaned branch
  --progress                                  # Report progress status
  --quiet(-q)                                 # Suppress feedback messages
  --recurse-submodules                        # Update the contents of sub-modules
  --track(-t)                                 # Set "upstream" configuration
]

# List or manipulate tags
export extern "git tag" [
  --delete(-d): string@"nu-complete git tags"  # Delete a tag
]

const built_in_refs = [HEAD FETCH_HEAD ORIG_HEAD]

# See `man git-status` under "Short Format"
# This is incomplete, but should cover the most common cases.
const short_status_descriptions = {
  ".D": "Deleted"
  ".M": "Modified"
  "!" : "Ignored"
  "?" : "Untracked"
  "AU": "Staged, not merged"
  "MD": "Some modifications staged, file deleted in work tree"
  "MM": "Some modifications staged, some modifications untracked"
  "R.": "Renamed"
  "UU": "Both modified (in merge conflict)"
}

def "nu-complete git available upstream" [] {
  ^git branch -a | lines | each { |line| $line | str replace '\* ' "" | str trim }
}

def "nu-complete git checkout" [] {
  (nu-complete git local branches)
  | parse "{value}"
  | insert description "local branch"
  | append (nu-complete git remote branches nonlocal without prefix
            | parse "{value}"
            | insert description "remote branch")
  | append (nu-complete git remote branches with prefix
            | parse "{value}"
            | insert description "remote branch")
  | append (nu-complete git commits all)
  | append (nu-complete git files | where description != "Untracked" | select value)
}

# Yield all existing commits in descending chronological order.
def "nu-complete git commits all" [] {
  ^git rev-list --all --remotes --pretty=oneline | lines | parse "{value} {description}"
}

# Yield commits of current branch only. This is useful for e.g. cut points in
# `git rebase`.
def "nu-complete git commits current branch" [] {
  ^git log --pretty="%h %s" | lines | parse "{value} {description}"
}

def "nu-complete git files" [] {
  let relevant_statuses = ["?",".M", "MM", "MD", ".D", "UU"]
  ^git status -uall --porcelain=2
  | lines
  | each { |$it|
    if $it starts-with "1 " {
      $it | parse --regex "1 (?P<short_status>\\S+) (?:\\S+\\s?){6} (?P<value>\\S+)"
    } else if $it starts-with "2 " {
      $it | parse --regex "2 (?P<short_status>\\S+) (?:\\S+\\s?){6} (?P<value>\\S+)"
    } else if $it starts-with "u " {
      $it | parse --regex "u (?P<short_status>\\S+) (?:\\S+\\s?){8} (?P<value>\\S+)"
    } else if $it starts-with "? " {
      $it | parse --regex "(?P<short_status>.{1}) (?P<value>.+)"
    } else {
      { short_status: 'unknown', value: $it }
    }
  }
  | flatten
  | where $it.short_status in $relevant_statuses
  | insert "description" { |e| $short_status_descriptions | get $e.short_status}
}

def "nu-complete git files-or-refs" [] {
  nu-complete git switchable branches
  | parse "{value}"
  | insert description Branch
  | append (nu-complete git files | where description == "Modified" | select value)
  | append (nu-complete git tags | parse "{value}" | insert description Tag)
  | append $built_in_refs
}

# Yield local branches like `main`, `feature/typo_fix`
def "nu-complete git local branches" [] {
  ^git branch | lines | each { |line| $line | str replace '* ' "" | str trim }
}

def "nu-complete git log" [] {
  ^git log --pretty=%h | lines | each { |line| $line | str trim }
}

# Arguments to `git rebase --onto <arg1> <arg2>`
def "nu-complete git rebase" [] {
  (nu-complete git local branches)
  | parse "{value}"
  | insert description "local branch"
  | append (nu-complete git remote branches with prefix
            | parse "{value}"
            | insert description "remote branch")
  | append (nu-complete git commits all)
}

def "nu-complete git refs" [] {
  nu-complete git switchable branches
  | parse "{value}"
  | insert description Branch
  | append (nu-complete git tags | parse "{value}" | insert description Tag)
  | append $built_in_refs
}

def "nu-complete git remotes" [] {
  ^git remote | lines | each { |line| $line | str trim }
}

# Yield remote branches like `origin/main`, `upstream/feature-a`
def "nu-complete git remote branches with prefix" [] {
  ^git branch -r | lines | parse -r '^\*?(\s*|\s*\S* -> )(?P<branch>\S*$)' | get branch | uniq
}

# Yield remote branches *without* prefix which do not have a local counterpart.
# E.g. `upstream/feature-a` as `feature-a` to checkout and track in one command
# with `git checkout` or `git switch`.
def "nu-complete git remote branches nonlocal without prefix" [] {
  # Get regex to strip remotes prefixes. It will look like `(origin|upstream)`
  # for the two remotes `origin` and `upstream`.
  let remotes_regex = (["(", ((nu-complete git remotes | each {|r| [$r, '/'] | str join}) | str join "|"), ")"] | str join)
  let local_branches = (nu-complete git local branches)
  ^git branch -r | lines | parse -r (['^[\* ]+', $remotes_regex, '?(?P<branch>\S+)'] | flatten | str join) | get branch | uniq | where {|branch| $branch != "HEAD"} | where {|branch| $branch not-in $local_branches }
}

def "nu-complete git stash-list" [] {
  git stash list | lines | parse "{value}: {description}"
}

def "nu-complete git subcommands" [] {
  ^git help -a | lines | where $it starts-with "   " | parse -r '\s*(?P<value>[^ ]+) \s*(?P<description>\w.*)'
}

def "nu-complete git switch" [] {
  (nu-complete git local branches)
  | parse "{value}"
  | insert description "local branch"
  | append (nu-complete git remote branches nonlocal without prefix
            | parse "{value}"
            | insert description "remote branch")
}

def "nu-complete git tags" [] {
  ^git tag | lines
}
