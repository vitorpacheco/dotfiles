#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/vitor/.lmstudio/bin"
# End of LM Studio CLI section

