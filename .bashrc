#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

PATH=$PATH:$HOME/.cabal/bin
PATH=/usr/share/perl5/vendor_perl/auto/share/dist/Cope:$PATH

alias ssh='TERM=${TERM%-256color} ssh'
alias diff='colordiff'        
alias grep='grep --color=auto'
alias ..='cd ..'

aur() {
  package=$1
  frag=${package:0:2}
  wget "http://aur.archlinux.org/packages/$frag/$package/$package.tar.gz" --quiet -O - | tar xzf - -C ~/.install/ 
  if [ 0 -ne "$?" ]; then
    echo "Failed to fetch package $package!"
  fi 
}

pacs() {
  echo -e "$(pacman -Ss $@ | sed \
  -e 's#core/.*#\\033[1;31m&\\033[0;37m#g' \
  -e 's#extra/.*#\\033[0;32m&\\033[0;37m#g' \
  -e 's#community/.*#\\033[1;35m&\\033[0;37m#g' \
  -e 's#^.*/.* [0-9].*#\\033[0;36m&\\033[0;37m#g' )"
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

if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
  exec startx
fi

