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
  [ ("<XF86Sleep>", spawn "dbus-send --system --print-reply --dest='org.freedesktop.UPower' /org/freedesktop/UPower org.freedesktop.UPower.Suspend && slock")
  , ("<XF86Suspend>", spawn "dbus-send --system --print-reply --dest='org.freedesktop.UPower' /org/freedesktop/UPower org.freedesktop.UPower.Hibernate && slock")
  , ("<XF86ScreenSaver>", spawn "slock")
  , ("M-e", spawn "urxvt -e emacsclient -t")
  ]

