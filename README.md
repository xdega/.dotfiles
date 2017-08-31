# .dotfiles: Liam Hockley

## Introduction
In an ongoing effort to improve my workflow, I decided it was time to dive into Vim in a more intentional manner. As part of this, I also figured it was time to clean-up my configurations to be consistent across all environments I work in. 

I am highly concerned with aesthetics, and favor a clean and minimal design. My Vim editor is designed to offer a consistent look and feel to the default VSCode Dark theme. I also have also included some common plugins for Vim, such as [CtrlP](https://github.com/ctrlpvim/ctrlp.vim) and [Snipmate](https://github.com/garbas/vim-snipmate) (along with a few helpful PHP snippets defined in `.vim/snippets/php.snippets`). 

Feel free to use these settings as a starting point (or in leiu of) for your own journey. You will find each of the configuration files to be well organized and commented. Enjoy.

## Screenshots

### Bash

<img width="1171" alt="Terminal View" src="https://user-images.githubusercontent.com/8093386/29902847-43f19570-8dc6-11e7-8e46-4f9d6816bafd.png">

### Vim

<img width="1170" alt="Vim Editor View" src="https://user-images.githubusercontent.com/8093386/29902846-43d6aef4-8dc6-11e7-9fd3-7d55055ce392.png">

## Installation

- Clone the repository in your home directory like so: `git clone https://github.com/xdega/.dotfiles.git`
- From your `.dotfiles` directory run `./install.sh`
- Run `vim` and then the command `:PluginInstall` from inside Vim (pulls in Vim plugins via [Vundle](https://github.com/VundleVim/Vundle.vim))
- From your `.dotfiles` directory, open `.gitconfig` and edit the following section to match your Git user:
```
[user]
    email = xdega121@gmail.com
    name = Liam Hockley`
```
- Thats It! (You will want to reload your bash session to see changes)

## Extending Configuration

### Aliases

To define custom aliases that will be loaded by the `.bash_profile`, you can create a `~/.bash_aliases` file.

### Bash Profile
To define custom extention settings to the `.bash_profile` (not included in `.bashrc`), you can create a `~/.bash_ext` file.
