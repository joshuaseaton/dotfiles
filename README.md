# .dotfiles

Dotfiles with Nushell-driven installation.

## Bootstrap

This routine is just intended to set things up on a new machine, bootstrapping
the checkout of this repo, the installation of Nushell and the custom
configuration contained within, and the setting of it as the default terminal
shell.

```sh
# The checkout *must* take place at $HOME/.dotfiles.
git clone git@github.com:joshuaseaton/dotfiles.git "${HOME}/.dotfiles"

"${HOME}/.dotfiles/bootstrap/nu.sh"
```

## Installation

Once bootstrapped, running `run $"($env.DOTFILES)/install.nu` should complete
the installation (which should always be a idemptotent process).

## Updating

Once installed, running `run $"($env.DOTFILES)/update.nu` will update any
relevant installations (e.g., those managed by a package manager).
