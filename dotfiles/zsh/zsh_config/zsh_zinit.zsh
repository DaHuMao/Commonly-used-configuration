### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

if [[ $ENABLE_CUSTOM_COMPLETE -eq 1 ]]; then
  log_info "enabling custom complete ......."
  SourceSh $ZSH_CONFIG_DIR/zsh_complete.zsh
  if [ $? -ne 0 ]; then
    log_warn "SourceSh $ZSH_CONFIG_DIR/zsh_complete.zsh failed, try to install zsh-users/zsh-completions"
    zinit ice wait lucid atload'_zsh_autosuggest_start'
    zinit light zsh-users/zsh-autosuggestions
  fi
else
  zinit ice wait lucid atload'_zsh_autosuggest_start'
  zinit light zsh-users/zsh-autosuggestions
fi


zinit ice wait lucid atinit='zpcompinit'
zinit light zdharma/fast-syntax-highlighting


if is_windows;then
fi
### End of Zinit's installer chunk
