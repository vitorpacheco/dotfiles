export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:/usr/local/bin
export PATH=$PATH:/snap/bin
export PATH=$PATH:$HOME/bin
export PATH=$PATH:$HOME/go/bin
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:$HOME/.local/apps
export PATH=$PATH:$HOME/.local/scripts
export PATH=$PATH:$HOME/.local/share/JetBrains/Toolbox/scripts

export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/vitor/.lmstudio/bin"
# End of LM Studio CLI section

