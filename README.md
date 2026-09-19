# dotfiles

My personal configs

# Usage (WIP)

```bash
$ dconf dump /org/gnome/terminal/ > gnome-terminal.conf
$ dconf load /org/gnome/terminal/ < gnome-terminal.conf

$ stow -t ~ nvim
$ stow -t ~ i3
$ stow -t ~ alacritty
$ stow -t ~ bash
```

Machine-specific or private shell settings go in `~/.bashrc.local`, which
`~/.bashrc` sources and git does not track.
