xrdb -merge ~/.Xresources 
xrdb -merge ~/.Xresources.urxvt 
xsetroot -cursor_name left_ptr &  

xset b off &
xmodmap ~/.Xmodmap &
xbindkeys &

xset +fp /usr/share/fonts/local &
xset fp rehash &

~/.xstart
