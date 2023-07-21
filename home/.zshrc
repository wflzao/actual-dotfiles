#!/bin/sh
export ZDOTDIR=$HOME/.config/zsh
HISTFILE=~/.zsh_history
setopt appendhistory

fetch
# some useful options (man zshoptions)
setopt autocd extendedglob nomatch menucomplete
setopt interactive_comments
stty stop undef		# Disable ctrl-s to freeze terminal.
zle_highlight=('paste:none')

# beeping is annoying
unsetopt BEEP

# completions
autoload -Uz compinit
zstyle ':completion:*' menu select
zstyle ':completion::complete:lsof:*' menu yes select
zmodload zsh/complist
# compinit
_comp_options+=(globdots)		# Include hidden files.

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# Colors
autoload -Uz colors && colors

# Useful Functions
source "$ZDOTDIR/zsh-functions"

# Normal files to source
zsh_add_file "zsh-exports"
zsh_add_file "zsh-vim-mode"
zsh_add_file "zsh-aliases"
zsh_add_file "zsh-prompt"

# Plugins
zsh_add_plugin "zsh-users/zsh-autosuggestions"
# zsh_add_plugin "zsh-users/zsh-syntax-highlighting"
zsh_add_plugin "hlissner/zsh-autopair"
# zsh_add_completion "esc/conda-zsh-completion" false
# For more plugins: https://github.com/unixorn/awesome-zsh-plugins
# More completions https://github.com/zsh-users/zsh-completions

# Key-bindings
bindkey -s '^o' 'ranger^M'
bindkey -s '^s' 'ncdu^M'
bindkey -s '^n' 'nvim^M'
bindkey '^[[P' delete-char
bindkey "^p" up-line-or-beginning-search # Up
# bindkey "^n" down-line-or-beginning-search # Down
bindkey "^k" up-line-or-beginning-search # Up
bindkey "^j" down-line-or-beginning-search # Down
bindkey -r "^u"
bindkey -r "^d"

# FZF
# TODO update for mac
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/doc/fzf/examples/completion.zsh ] && source /usr/share/doc/fzf/examples/completion.zsh
[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f $ZDOTDIR/completion/_fnm ] && fpath+="$ZDOTDIR/completion/"
# export FZF_DEFAULT_COMMAND='rg --hidden -l ""'
compinit

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
# bindkey '^e' edit-command-line

setxkbmap -option Caps:escape
xset r rate 210 40

# Environment variables set everywhere
export EDITOR="nvim"
export TERMINAL="kitty"
export BROWSER="firefox"

# remap caps to escape
# setxkbmap -option caps:escape
# swap escape and caps
# setxkbmap -option caps:swapescape

# For QT Themes
export QT_QPA_PLATFORMTHEME=qt5ct

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PYENV_VIRTUALENV_DISABLE_PROMPT=1

# if command -v pyenv 1>/dev/null 2>%1; then
#   eval "$(pyenv init --path)"
#   eval "$(pyenv init -)"
#   eval "$(pyenv virtualenv-init -)"
# fi
#

# Aliases
alias py="python3"
alias vim="nvim"
alias cin="cat"
alias q="exit"
alias xsel="xsel --clipboard"

# Quick terminal directory actions
# git
function qpush() {
    git add .;
    git commit -m "$1";
    git push;
}

function pullsh() {
    git pull;
    qpush $1;
}

# print file with index $1
function lsii() {
	ls | sed -n $1p;
}

# cd to folder with index $1
function cdi() {
	cd "`ls | sed -n $1p`";
}

# copy $1 to clipboard
function clip() {
	echo "$1" | xsel --clipboard;
}

# yank current directory path
function yd() {
	echo "`pwd`" | xsel --clipboard;
}

# yank the path of the file with index $1
function yf() {
    echo "`readlink -f ./`/`ls | sed -n $1p`" | xsel --clipboard
}

# mpv alias
# mpv plays a file
function mpvp() {
	mpv "`ls | sed -n $1p`";
}

# mpv plays audio with no display
function mpva() {
	mpv "`ls | sed -n $1p`" --no-audio-display;
}

# mpv plays everything in directory
function mpvd() {
        ls | egrep '\.flac$|\.wav$|\.ogg$|\.mka$|\.webm$|\.m4a$|\.mp3$|\.mkv$|>' > ".mpv-pl-list";

        mpv -playlist=".mpv-pl-list";
        rm ".mpv-pl-list";
}

# mpv plays everything in directory with no display
function mpvl() {
	ls | egrep '\.flac$|\.wav$|\.ogg$|\.mka$|\.webm$|\.m4a$|\.mp3$|\.mkv$|\.mp4$' > ".mpv-pl-list";

	mpv -playlist=".mpv-pl-list" --no-audio-display;
	rm ".mpv-pl-list";
}

# recursively plays everything in directory with no display
function mpvlr() {
    find . -print | egrep '\.flac$|\.wav$|\.ogg$|\.mka$|\.webm$|\.m4a$|\.mp3$|\.mkv$|\.mp4$' > ".mpv-pl-list";

	mpv -playlist=".mpv-pl-list" --no-audio-display;
	rm ".mpv-pl-list";
}

# conversions
# download via m3u8 link
function m3u8dl() {
	ffmpeg -protocol_whitelist file,http,https,tcp,tls,crypto -i "$1" -c copy "$2";
}

