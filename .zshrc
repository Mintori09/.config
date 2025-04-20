# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export EDITOR=nvim

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
# alias ff="nvim $(fzf --preview 'bat --style=numbers --color=always --line-range=:500 {}' --height 70%)"
alias x11="env GDK_BACKEND=x11"
alias si="sudo pacman -S"
alias empty='echo -n Taking out the trash | pv -qL 10 && rm -rf  ~/.local/share/Trash/files' 
alias nf="neofetch"
alias ls='ls --color'
alias vim='nvim'
alias c='clear'
alias cfz="nvim ~/.zshrc && source ~/.zshrc"
alias cls="clear"
alias cfnv="cd ~/.config/nvim && nvim"
alias obs="cd ~/Documents/my-obsidian/ && nvim"
alias yt="ytfzf -t -T kitty"
alias off="shutdown -P 0"
alias vi="trans -t vi"
alias vii="trans -t vi -I"
alias gpt="tgpt"
alias eng="trans -t en"
alias ff="fastfetch"
alias /e="exit"
alias ..="cd .."
alias syncToOnedrive="rclone sync ~/Documents/Obsidian Onedrive:/02\ _\ Obsidian/"
alias m=" mpv --shuffle ~/Music/ && exit"
alias tauri-build="NO_STRP=true pnpm tauri build"
# unalias lt

# Shell integrations
eval "$(zoxide init zsh)"

# Yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

function push() {
    git add .
    git commit -m $1 
    git push -u origin main
}

# git
function push() {
  git add .
  git commit -m "update"
  git push origin main
}
function pull() {
  git pull origin main
}
mkf() {
    mkdir "$1"
    cd "$1" || echo "Failed to change directory"
}
function lt() {
  local level="${1:-1}"
  eza --tree --level="$level"
}
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
