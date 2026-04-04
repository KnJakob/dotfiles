# My dotfiles
This directory contains the dotfiles for my system.

## Requirements
1. Git
2. Stow

##  Installation
First, check out the dotfiles in the $HOME directory using git:
```
$ git clone git@github.com:KnJakob/dotfiles.git
$ cd dotfiles
```

Then create the symlinks using stow:
```
$ stow .
```

If you already have any configuration files stored on your system, you may use
the adopt flag.
```
$ stow --adopt .
```

