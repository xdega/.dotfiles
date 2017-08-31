# Name: Liam's Bash Settings
# Author: Liam Hockley
# Description: Aesthetically pleasing and minimal, yet functional.

# Bash Core Setup Options
export GREP_OPTIONS='--color=always'
export EDITOR=vim
source ~/.git-prompt.sh

# Source Bashrc
if [ -f $HOME/.bashrc ]; then
    . $HOME/.bashrc
fi

# Source Custom Aliases
if [ -f $HOME/.bash_aliases ]; then
    . $HOME/.bash_aliases
fi

# Source Custom Extensions
if [ -f $HOME/.bash_ext ]; then
    . $HOME/.bash_ext
fi

# Set Basic Aliases
alias lla="ls -lhA"
alias claer="clear"

# Set LS Colors
export CLICOLOR=1
LS_COLORS=$LS_COLORS:'di=1;94:fi=0;0'
export LS_COLORS

# Set PS1 Prompt
export PS1='\[\e[01;30m\]\h`if [ $? = 0 ]; then echo "\[\e[32m\] ✔ "; else echo "\[\e[31m\] ✘ "; fi`\[\e[00;37m\]\u\[\e[01;37m\]:`[[ $(git status 2> /dev/null) =~ Changes\ to\ be\ committed: ]] && echo "\[\e[33m\]" || echo "\[\e[31m\]"``[[ ! $(git status 2> /dev/null) =~ nothing\ to\ commit,\ working\ .+\ clean ]] || echo "\[\e[32m\]"`$(__git_ps1 "(%s)\[\e[00m\]")\[\e[01;34m\]\w\[\e[00m\]\ $ '

