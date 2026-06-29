# Roderick McLean's Stow'ed Configuration

## How to Install

``` bash
/bin/bash -c "$(curl -fsSL https://github.com/roddersmc/dotfiles/archive/refs/heads/main.tar.gz | tar -xz -C /tmp && /tmp/dotfiles-main/install.sh)"
```

## what install does

1. Install Homebrew with ```/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"```
1. Clone this directory to your `~` home directory
1. run the bootstrap-scripts
1. `stow <directory_name> --adopt` to symlink configuration on device.

## ZSH configuration

`zsh/.zprofile` - Used on login

`zsh/.zshrc` - Main configuration file

`zsh/.zshenv` - Environment file

## Learn touch typing

[Touch type training](https://www.edclub.com/sportal/program-3/137.play)
