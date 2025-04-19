# Check if XDG_RUNTIME_DIR is set, exists, and is writeable
if [ -z "$XDG_RUNTIME_DIR" ] || [ ! -d "$XDG_RUNTIME_DIR" ] || [ ! -w "$XDG_RUNTIME_DIR" ]; then
  export XDG_RUNTIME_DIR="/tmp/$USER-runtime"
  mkdir -p "$XDG_RUNTIME_DIR"
  chmod 700 "$XDG_RUNTIME_DIR"
fi

### ALIAS ###
alias ls="eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions"
alias bc="bat"
### ALIAS ###

### Homebrew ###
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
### Homebrew ###

### PATH ###
export PATH=/snap/bin:$HOME/bin:/usr/local/bin:$HOME/.local/bin:$PATH
export PATH=$HOME/.sdkman/candidates/java/current/bin:$PATH
export PATH=$HOME/.sdkman/candidates/maven/current/bin:$PATH
export PATH=$HOME/.sdkman/candidates/quarkus/current/bin:$PATH
### PATH ###

### ZSH ###
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
ZSH_TMUX_AUTOSTART=true

plugins=(
  tmux
  git
  git-commit
  nodenv
  nvm
  npm
  yarn
  sdk
  docker
  docker-compose
  golang
  aws
  fancy-ctrl-z
  fzf
)

source $ZSH/oh-my-zsh.sh
source <(fzf --zsh)
eval "$(oh-my-posh init zsh --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/refs/heads/main/themes/amro.omp.json)"
### ZSH ###

### BAT ###
export BAT_THEME=tokyonight_night
### BAT ###

### FZF ###
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

fg="#CBE0F0"
bg="#011628"
bg_highlight="#143652"
purple="#B388FF"
blue="#06BCE4"
cyan="#2CF9ED"

export FZF_DEFAULT_OPTS="--color=fg:${fg},bg:${bg},hl:${purple},fg+:${fg},bg+:${bg_highlight},hl+:${purple},info:${blue},prompt:${cyan},pointer:${cyan},marker:${cyan},spinner:${cyan},header:${cyan}"

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo ${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                    "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview"   "$@" ;;
  esac
}
### FZF ###

### NVM ###
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
### NVM ###

