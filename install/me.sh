#!/bin/bash
#
# Installs dotfiles, and any required packages or plugins.

set -o errexit    # exit when a command fails
set -o nounset    # error when an undefined variable is referenced
set -o pipefail   # error if the input command to a pipe fails
set -u            # treat unset variables as an error when substituting

readonly DOTFILES_ROOT="$( cd "$( dirname "$(dirname "${BASH_SOURCE[0]}" )")" >/dev/null 2>&1 && pwd )"

# Text file containing all required Debian packages.
readonly DEBIAN_PKGS_TXT="$DOTFILES_ROOT/install/debian-pkgs.txt"

# The JSON files below are of the form
# [
#   {
#     "key": <key>,
#     "val": <val>
#   },
#   ...
# ]
# Contains the mappings of how to install this repo's contents into $HOME.
readonly MAPPINGS_JSON="$DOTFILES_ROOT/install/mappings.json"
# Contains commands to run for additional installation steps, along with
# descriptions.
readonly COMMANDS_JSON="$DOTFILES_ROOT/install/commands.json"

readonly ORIGINAL_COLOUR="\\033[1;0m"
readonly RED="\\033[0;31m"
readonly GREEN="\\033[0;32m"
readonly YELLOW="\\033[1;33m"

error() {
  echo -e "${RED}$1${ORIGINAL_COLOUR}" >&2
}
success() {
  echo -e "${GREEN}$1${ORIGINAL_COLOUR}"
}
warn() {
  echo -e "${YELLOW}$1${ORIGINAL_COLOUR}"
}

print_usage_and_exit() {  
  echo ""
  echo "Installs dotfiles, and any required packages or plugins"
  echo "Usage: $0 <options>"
  echo ""
  echo "Options:"
  echo "-h|--help       Print this message and exit"
  echo "-d|--dry-run    Enable dry-run mode, which does not do any actual file or package operations"
  echo "-f|--force      Enable force mode, which will force links and not create backups"
  echo ""
  
  exit "$1"
}

dry_run_mode=false
force_mode=false
while (( "$#" )); do
  case "$1" in
    -h|--help) print_usage_and_exit 0 ;;
    -d|--dry-run) dry_run_mode=true ;;
    -f|--force) force_mode=true ;;
    -*)
      error "Error: Unsupported flag $1"
      print_usage_and_exit 1
      ;;
  esac
  shift
done


read_json_into_array() {
    local -n arr=$1
    arr=()
    host_os="$(uname --operating-system)"
    IFS=$'\n'
    for row in $(jq -c '.[]' < "$2"); do
        # If the OS is specified for the mapping and does not match the host
        # OS, skip.
        os="$(echo "$row" | jq -r '.os')"
        if [[ -z "$os" ]] && [[ "$host_os" -ne "$os" ]] ; then
            continue
        fi

        key="$(echo "$row" | jq -r '.key')"
        val="$(echo "$row" | jq -r '.val')"
        arr+=("$key" "$val")
    done
}

link_dot() {
    name="$1"
    src="$2"
    dest="$3"
    warn "attempting to link $src -> $dest"
    if $dry_run_mode ; then
      success "would have linked $dest"
    else
      ln_opts=(--symbolic --no-target-directory)
      if $force_mode ; then
        ln_opts+=(--force)
      fi
      ln "${ln_opts[@]}" "$src" "$dest"
      success "linked $dest"
    fi
}

main() {
  if $dry_run_mode && $force_mode ; then
    error "dry-run and force modes cannot be enabled at the same time"
    exit 1
  fi

  # (1) Install required Debian packages.
  readarray -t pkgs < "$DEBIAN_PKGS_TXT"
  for pkg in "${pkgs[@]}"; do
    if ! dpkg -s "$pkg" &>/dev/null; then
      if ! $dry_run_mode ; then
          warn "attempting to install $pkg"
          if sudo apt install "$pkg"; then
            success "successfully installed $pkg"
          else
            error "failed to install $pkg"
          fi
      fi
    fi
  done

  # (2) Link dotfiles to $HOME.
  local mappings
  read_json_into_array mappings "$MAPPINGS_JSON"
  for (( i=0; i<${#mappings[@]} ; i+=2 )) ; do
    local src="$DOTFILES_ROOT/${mappings[i]}"
    local name="${mappings[i+1]}"
    local dest="$HOME/$name"

    if [[ -s $dest ]] || [[ -d $dest ]]; then
      if ! diff --quiet --recursive "$dest" "$src" &>/dev/null; then
        if ! $force_mode ; then
          local backup="$dest.bkp"
          if ! $dry_run_mode ; then
            mv "$dest" "$backup"
          fi
          warn "existing $name found; moved to $backup"
        fi
        link_dot "$name" "$src" "$dest"
      else
        success "$name is already up to date"
      fi
    else
      link_dot "$name" "$src" "$dest"
    fi
  done

  # (3) Run additional installation steps.
  local cmds
  read_json_into_array cmds "$COMMANDS_JSON"
  for (( i=0; i<${#cmds[@]} ; i+=2 )) ; do
    desc="${cmds[i]}"
    cmd="${cmds[i+1]}"
    warn "attempting to: $desc"
    if $dry_run_mode; then
      success "would have ran \`$cmd\`"
    else
      eval "$cmd"
    fi
  done
}

main
