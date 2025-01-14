gh-nate's dotfiles

- Focused solely on setting up a minimal command line environment.
- Essentials in a single file for an easier download.

required prerequisites

  # apt install curl

recommended prerequisites

  # apt install tmux zsh
  # pacman -S less man-db tmux zsh

install

  $ curl -sLS https://github.com/gh-nate/dots/raw/main/install.sh | sh

optional

  # apt install fzf git ripgrep vim
  # snap set system refresh.timer=19:00~20:00

  # pacman -S fzf git pacman-contrib ripgrep
  # systemctl enable paccache.timer
  # systemctl start paccache.timer
