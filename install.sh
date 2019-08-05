#!/bin/bash
#
# Installs dotfiles, and any required packages or plugins.

set -o nounset    # error when an undefined variable is referenced
set -o errexit    # exit when a command fails

readonly DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

readonly ORIGINAL_COLOUR="\\033[1;0m"
readonly RED="\\033[0;31m"
readonly GREEN="\\033[0;32m"
readonly YELLOW="\\033[1;33m"

# Ignore ".", "..", git-related files and directories, and swap files.
readonly IGNORE_PATTERNS="(^\\.(\\.)?$|^\\.git|\\.swp$)"

# Required Ubuntu packages.
readonly REQUIRED_PACKAGES=(
  # To install the python language server.
  python3-pip
  # For clangd, for the C/C++ language server.
  clang-tools
)

# An array of (description, command) pairs, when read two at a time,
# giving additional plugin installation steps that need to be performed.
readonly EXTRA_PLUGIN_INSTALL_STEPS=(
  "install python language server"
  "pip3 install python-language-server"

  "get go language server"
  "go get -u golang.org/x/tools/cmd/gopls"

  "build go language server"
  "go build -o $HOME/go/bin/gopls $HOME/go/src/golang.org/x/tools/cmd/gopls"
)


error() {
  echo -e "${RED}$1${ORIGINAL_COLOUR}" >&2
}
success() {
  echo -e "${GREEN}$1${ORIGINAL_COLOUR}"
}
warn() {
  echo -e "${YELLOW}$1${ORIGINAL_COLOUR}"
}

usage() {
  echo ""
  echo "Installs dotfiles, and any required packages or plugins"
  echo "Usage: $0 <options>"
  echo ""
  echo "Options:"
  echo "-h|--help       Print this message and exit"
  echo "-d|--dry-run    Enable dry-run mode, which does not do any actual file or package operations"
  echo "-f|--force      Enable force mode, which will force links and not create backups"
  echo "-p|--plugins    Performs any additional plugin installation"
  echo ""
}

dry_run_mode=false
force_mode=false
plugin_mode=false
while (( "$#" )); do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    -d|--dry-run)
      dry_run_mode=true
      shift
      ;;
    -f|--force)
      force_mode=true
      shift
      ;;
    -p|--plugins)
      plugin_mode=true
      shift
      ;;
    -*)
      error "Error: Unsupported flag $1"
      exit 1
      ;;
  esac
done


install_packages() {
  for pkg in "${REQUIRED_PACKAGES[@]}"; do
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
}


install_plugins() {
  for (( i=0; i<${#EXTRA_PLUGIN_INSTALL_STEPS[@]} ; i+=2 )) ; do
    desc="${EXTRA_PLUGIN_INSTALL_STEPS[i]}"
    cmd="${EXTRA_PLUGIN_INSTALL_STEPS[i+1]}"
    warn "attempting to: $desc"
    if ! $dry_run_mode; then
      $cmd
    fi
  done
}


main() {
  if $dry_run_mode && $force_mode ; then
    error "dry-run and force modes cannot be enabled at the same time"
    exit 1
  fi

  install_packages

  if $plugin_mode; then
    install_plugins
  fi

  cd "$DOTFILES_DIR" || exit 1
  for entry in .*; do
    if [[ "$entry" =~ $IGNORE_PATTERNS ]]; then
      continue
    fi

    local this="$DOTFILES_DIR/$entry"
    local that="$HOME/$entry"
    link_entry() {
      if ! $dry_run_mode ; then
        ln_opts=(--symbolic --no-target-directory)
        if $force_mode ; then
          ln_opts+=(--force)
        fi

        ln "${ln_opts[@]}" "$this" "$that"
      fi
      success "$entry installed"
    }

    if [[ -s $that ]] || [[ -d $that ]]; then
      if ! diff --quiet --recursive "$that" "$this" &>/dev/null; then
        if ! $force_mode ; then
          local backup="$that.bkp"
          if ! $dry_run_mode ; then
            mv "$that" "$backup"
          fi
          warn "existing $entry found; moved to $backup"
        fi
        link_entry
      else
        success "$entry is already up to date"
      fi
    else
      link_entry
    fi
  done
}

main
