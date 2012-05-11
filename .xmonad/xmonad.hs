import XMonad
import XMonad.Hooks.EwmhDesktops
import XMonad.Util.EZConfig


main = xmonad $ defaultConfig { 
      terminal    = "urxvt"
    , modMask     = mod4Mask
    , borderWidth = 1
    , handleEventHook = fullscreenEventHook
    } 
    `additionalKeysP` myKeys


myKeys = 
  [ ("<XF86Sleep>", spawn "slock && dbus-send --system --print-reply --dest='org.freedesktop.UPower' /org/freedesktop/UPower org.freedesktop.UPower.Suspend")
  , ("<XF86Suspend>", spawn "slock && dbus-send --system --print-reply --dest='org.freedesktop.UPower' /org/freedesktop/UPower org.freedesktop.UPower.Hibernate")
  , ("<XF86ScreenSaver>", spawn "slock")
  ]

