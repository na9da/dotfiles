#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

alias ssh='TERM=${TERM%-256color} ssh'
alias diff='colordiff'        
alias grep='grep --color=auto'
alias ..='cd ..'
alias pacman='pacman-color'
alias pacs="pacman -Ss"

aur() {
  package=$1
  frag=${package:0:2}
  wget "http://aur.archlinux.org/packages/$frag/$package/$package.tar.gz" --quiet -O - | tar xzf - -C ~/.install/ 
  if [ 0 -ne "$?" ]; then
    echo "Failed to fetch package $package!"
  fi 
}

man() {
	env \
		LESS_TERMCAP_mb=$(printf "\e[1;31m") \
		LESS_TERMCAP_md=$(printf "\e[1;31m") \
		LESS_TERMCAP_me=$(printf "\e[0m") \
		LESS_TERMCAP_se=$(printf "\e[0m") \
		LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
		LESS_TERMCAP_ue=$(printf "\e[0m") \
		LESS_TERMCAP_us=$(printf "\e[1;32m") \
			man "$@"
}

export LESSOPEN="| /usr/bin/source-highlight-esc.sh %s"
export LESS=' -R '

PATH=$HOME/.opt/bin:/opt/android-sdk/tools:/opt/android-sdk/platform-tools:$PATH

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
[[ -s "/home/nanda/.rvm/scripts/rvm" ]] && source "/home/nanda/.rvm/scripts/rvm"

if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
  exec startx
fi

