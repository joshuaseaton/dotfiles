#!/bin/bash
#
# Installs dotfiles.

readonly DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

readonly ORIGINAL_COLOUR="\033[1;0m"
readonly RED="\033[0;31m"
readonly GREEN="\033[0;32m"
readonly YELLOW="\033[1;33m"

# Ignore ".", "..", git-related files and directories, and swap files.
readonly IGNORE_PATTERNS="(^\.(\.)?$|^\.git|\.swp$)"

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
  echo "Usage: $0 <options>"
  echo ""
  echo "Options:"
  echo "-h|--help       Print this message and exit"
  echo "-d|--dry-run    Enable dry-run mode, which does not do any actual file operations"
  echo "-f|--force      Enable force mode, which will force links and not create backups"
  echo ""
}

dry_run=false
force=false
while (( "$#" )); do
  case "$1" in
    -d|--dry-run)
      dry_run=true
      shift
      ;;
    -f|--force)
      force=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*|--*)
      error "Error: Unsupported flag $1"
      exit 1
      ;;
  esac
done

if $dry_run && $force ; then
  error "dry-run and force modes cannot be enabled at the same time"
  exit 1
fi

main() {
  cd $DOTFILES_DIR
  for entry in .*; do
    if [[ "$entry" =~ $IGNORE_PATTERNS ]]; then
      continue
    fi

    local this="$DOTFILES_DIR/$entry"
    local that="$HOME/$entry"
    link_entry() {
      if ! $dry_run ; then
        local ln_opts="--symbolic"
        if $force ; then
          ln_opts="$ln_opts --force"
        fi
        ln $ln_opts $this $that
      fi
      success "$entry installed"
    }

    if [[ -s $that ]] || [[ -d $that ]]; then
      if ! diff --quiet --recursive $that $this &>/dev/null; then
        if ! $force ; then
          local backup="$that.bkp"
          if ! $dry_run ; then
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
