# bash_trash
### trash for bash

## about
this is a personal project that attempts to implement the [freedesktop.org trash specification](https://specifications.freedesktop.org/trash-spec/trashspec-latest.html). it is still very much a work in progress. `bash_trash` takes inspiration from [`trash-cli`](https://github.com/andreafrancia/trash-cli) for its usage and behaviour. my reasoning for making this is because on termux `trash-cli` isn't able to run as it tries to access outside of android's sandbox. this made me want to look for alternatives, which i found [`tra.sh`](https://github.com/prosoitos/tra.sh) which requires [`zsh`](https://www.zsh.org/) and [`fzf`](https://github.com/junegunn/fzf). because of these dependencies (and thoughts of making my own dotfiles repo), i decided to make my own version that worked in bash, so i could have a portable solution.

## usage
first, download and move into the project directory.
```bash
git clone https://github.com/georgedance/bash_trash
cd bash_trash
```

to use these bash functions, source the file in the src directory.
```bash
source src/bash_trash.sh
# or
. src/bash_trash.sh
```

i would recommend copying the file to somewhere like `~/.config/bash/bash_trash`, then sourcing it from your .bashrc.
```bash
mkdir -pv ~/.config/bash
cp src/bash_trash.sh ~/.config/bash/bash_trash
echo ". ~/.config/bash/bash_trash" >> ~/.bashrc
```

