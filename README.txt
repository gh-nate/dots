gh-nate's dotfiles

- Focused solely on setting up a minimal command line environment.
- Everything in a single file for an easier download.

recommended prerequisites

  # dnf install tmux zsh

install

  $ curl -sLS https://github.com/gh-nate/dots/raw/main/install.sh | sh

optional

  # dnf install fzf git-core ripgrep vim

recommended optional configuration

  $ cat /etc/dnf/dnf.conf
  [main]
  ; ...
  fastestmirror=True
  max_parallel_downloads=20

issue since/with fedora:39 docker image

  # logout
  /etc/zlogout:7: command not found: clear

workaround

  $ cat /etc/zlogout
  if command -v clear > /dev/null; then
    clear
  fi
