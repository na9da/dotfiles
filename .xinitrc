xrdb -merge ~/.Xresources 
xrdb -merge ~/.Xresources.urxvt 
xsetroot -cursor_name left_ptr &  

xset b off &
xmodmap ~/.Xmodmap &

xset +fp /usr/share/fonts/local &
xset fp rehash &

exec ck-launch-session dbus-launch ~/.xstart
