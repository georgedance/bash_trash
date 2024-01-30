# bash_trash
trash for bash

## about
This is a personal project that attempts to implement the [freedesktop.org trash specification](https://specifications.freedesktop.org/trash-spec/trashspec-latest.html). It is still very much a work in progress, but feel free to make a pull request. `bash_trash` takes inspiration from [`trash-cli`](https://github.com/andreafrancia/trash-cli) for its usage and behaviour. My reasoning for making this is because on [`termux`](https://termux.dev/en/), `trash-cli` isn't able to run as it tries to access outside of android's sandbox. This made me want to look for alternatives, which I found [`tra.sh`](https://github.com/prosoitos/tra.sh) which requires [`zsh`](https://www.zsh.org/) and [`fzf`](https://github.com/junegunn/fzf). Because of these dependencies (and thoughts of making my own dotfiles repo), I decided to make my own version that worked in bash, so I could have a portable solution.

## requirements
These bash functions require a few common scriping tools which you may already have installed, such as;
- python
- which
- grep

## usage
First, download and move into the project directory.
```bash
git clone https://github.com/georgedance/bash_trash
cd bash_trash
```

To use the `bash_trash` bash functions, source the file in the [`src`](/src) directory.
```bash
source src/bash_trash.sh
# or
. src/bash_trash.sh
```

I would recommend copying the file to somewhere like `~/.config/bash/bash_trash`, then sourcing it from your `.bashrc` to have the functions always available.
```bash
mkdir -pv ~/.config/bash
cp src/bash_trash.sh ~/.config/bash/bash_trash
echo ". ~/.config/bash/bash_trash" >> ~/.bashrc
```

## functions
a list of the functions that are included.

| function name | implemented | notes |
| --- | --- | --- |
| `trash_init` | [x] | |
| `trash` | [x] | "alias" of `trash_put` |
| `trash_put` | [x] | |
| `trash_list` | [x] | |
| `trash_restore` | [ ] | |
| `trash_rm` | [ ] | |
| `trash_empty` | [/] | to be rewritten |

