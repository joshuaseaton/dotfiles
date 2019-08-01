#!/bin/bash
#
# Installs dotfiles and any additional packages and plugins.

readonly DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

readonly ORIGINAL_COLOUR="\033[1;0m"
readonly RED="\033[0;31m"
readonly GREEN="\033[0;32m"
readonly YELLOW="\033[1;33m"

# Ignore ".", "..", git-related files and directories, and swap files.
readonly IGNORE_PATTERNS="(^\.(\.)?$|^\.git|\.swp$)"

# Required Ubuntu packages.
readonly REQUIRED_PACKAGES=(
  # Needed by the youconpleteme vim plugin (assumes Ubuntu v16.04+)
  # (see https://github.com/ycm-core/YouCompleteMe#installation):
  "build-essential"
  "cmake"
  "python3-dev"
)

# An array of name, command pairs (when read two at a time) corresponding to a
# plugin and the command to execute in order to complete its installation.
readonly EXTRA_PLUGIN_INSTALLATION=(
  "youcompleteme"
  "python3 $DOTFILES_DIR/.vim/pack/plugins/start/youcompleteme/install.py --clang-completer --go-completer"
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
  echo "Installs dotfiles and required packages or plugins."
  echo "Usage: $0 <options>"
  echo ""
  echo "Options:"
  echo "-h|--help       Print this message and exit"
  echo "-d|--dry-run    Enable dry-run mode, which does not do any actual file or package operations"
  echo "-f|--force      Enable force mode, which will force links and not create backups"
  echo "-p|--plugins    Complete any additional installation of plugins"
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
    -*|--*)
      error "Error: Unsupported flag $1"
      exit 1
      ;;
  esac
done


install_packages() {
  for pkg in ${REQUIRED_PACKAGES[@]}; do
    dpkg -s $pkg &>/dev/null
    if [[ $? -ne 0 ]]; then
      if ! $dry_run_mode ; then
          warn "attempting to install $pkg"
          sudo apt install $pkg
          if [[ $? -eq 0 ]]; then
            success "successfully installed $pkg"
          else
            error "failed to install $pkg"
          fi
      fi
    fi
  done
}


install_plugins() {
  for (( i=0; i<${#EXTRA_PLUGIN_INSTALLATION[@]} ; i+=2 )) ; do
    name="${EXTRA_PLUGIN_INSTALLATION[i]}"
    cmd="${EXTRA_PLUGIN_INSTALLATION[i+1]}"
    warn "attempting to install the '$name' plugin"
    if ! $dry_run_mode; then
      $(cmd)
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

  cd $DOTFILES_DIR
  for entry in .*; do
    if [[ "$entry" =~ $IGNORE_PATTERNS ]]; then
      continue
    fi

    local this="$DOTFILES_DIR/$entry"
    local that="$HOME/$entry"
    link_entry() {
      if ! $dry_run_mode ; then
        local ln_opts="--symbolic --no-target-directory"
        if $force_mode ; then
          ln_opts="$ln_opts --force"
        fi

        ln $ln_opts $this $that
      fi
      success "$entry installed"
    }

    if [[ -s $that ]] || [[ -d $that ]]; then
      if ! diff --quiet --recursive $that $this &>/dev/null; then
        if ! $force_mode ; then
          local backup="$that.bkp"
          if ! $dry_run_mode ; then
            mv $that $backup
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
