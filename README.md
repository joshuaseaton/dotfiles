# .dotfiles

Dotfiles with Nushell-driven installation.

## Bootstrap

This routine is just intended to set things up on a new machine, bootstrapping
the checkout of this repo and installing Nushell (along with our custom
configuration for it).

```sh
# The checkout *must* take place at $HOME/.dotfiles.
git clone git@github.com:joshuaseaton/dotfiles.git "${HOME}/.dotfiles"
cd "${HOME}/.dotfiles"
git submodule update --init --recursive
./bootstrap.sh
```

## Installation

Once bootstrapped, running `run ~/.dotfiles/install.nu` should complete
the installation (which should always be a idemptotent operation).

## Updating

Once installed, running `run ~/.dotfiles/update.nu` will update any
relevant installations (e.g., those managed by a package manager).

## Dot-files in dotfiles

Any dot-files that appear at the root of dotfiles.git are specific to the repo
and are not intended to be a part of a wider user installation.
