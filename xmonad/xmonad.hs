import XMonad hiding ((|||))
import Data.Monoid
import System.Exit
import XMonad.Layout.Spacing   (Border (..), spacingRaw)
import XMonad.Layout.NoBorders (smartBorders)
import XMonad.Layout.Named     (named)
import XMonad.Layout.LayoutCombinators
import XMonad.Layout.ZoomRow
import XMonad.Prompt
import XMonad.Prompt.Window
import XMonad.Prompt.FuzzyMatch
import XMonad.Util.Run         (spawnPipe)
import XMonad.Util.EZConfig
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import System.IO

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

myTerminal      = "alacritty -e tmux"

myPrompt = def
  { position = Top
  , font = "xft:Inconsolata-g for Powerline:style=Regular:size=12:antialias=true"
  , height = 44
  , bgColor = "#1f1f1f"
  , fgColor = "white"
  , promptBorderWidth = 0
  , searchPredicate = fuzzyMatch
  , alwaysHighlight = True
  }

myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)
    , ((modm,               xK_p), spawn "dmenu_run")
    , ((modm .|. shiftMask, xK_c), kill)
    , ((modm .|. controlMask, xK_l), spawn "slock")
    , ((modm, xK_o), spawn "firefox")
    , ((modm, xK_e), spawn "alacritty -e tmux -c 'emacs -nw'")
    , ((modm .|. shiftMask, xK_g), windowPrompt myPrompt { autoComplete = Just 500000 } Goto allWindows)
    , ((modm .|. shiftMask, xK_b), windowPrompt myPrompt { autoComplete = Just 500000 } Bring allWindows)

      -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp)

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster)

    -- Jump to layouts 
    , ((modm .|. controlMask, xK_f), sendMessage $ JumpToLayout "F")
    , ((modm .|. controlMask, xK_t), sendMessage $ JumpToLayout "T")
    , ((modm .|. controlMask, xK_h), sendMessage $ JumpToLayout "H")
    , ((modm .|. controlMask, xK_z), sendMessage $ JumpToLayout "Z")

    , ((modm .|. shiftMask, xK_minus), sendMessage zoomIn)
    , ((modm              , xK_minus), sendMessage zoomOut)
    , ((modm              , xK_equal), sendMessage zoomReset)
    , ((modm              , xK_f    ), sendMessage ZoomFullToggle)
    
    -- Swap the focused window and the master window
    , ((modm,               xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)

    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    , ((modm              , xK_b     ), sendMessage ToggleStruts)

    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modm              , xK_q     ), spawn "xmonad --recompile; xmonad --restart")

    -- Run xmessage with a summary of the default keybindings (useful for beginners)
    , ((modm .|. shiftMask, xK_slash ), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

myLayout = smartBorders . avoidStruts
  $   tiled
  ||| horizontal
  ||| full
  ||| named "Z" zoomRow
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   = named "T" $ spaces (Tall nmaster delta ratio)

     horizontal = named "H" $ spaces (Mirror tiled)

     full = named "F" $ Full

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 3/5

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

     -- Useless gaps
     spaces = spacingRaw True (Border 0 0 0 0) True (Border 3 3 3 3) True

myManageHook = composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , title     =? "wpa_gui"        --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore ]

myEventHook = docksEventHook

myLogHook bar = do
  dynamicLogWithPP xmobarPP
    { ppOutput = hPutStrLn bar
    , ppTitle = xmobarColor "grey" "" . shorten 50
    , ppCurrent = xmobarColor "darkorange" "" . wrap "[" "]"
    }      

myStartupHook = do
  spawn "~/.fehbg"

main = do
  statusBar <- spawnPipe "xmobar ~/.xmonad/xmobarrc"
  xmonad $ defaults
    { logHook = myLogHook statusBar
    } `additionalKeysP`
    [ ("<XF86AudioMute>", spawn "pactl set-sink-mute 0 toggle")
    , ("<XF86AudioLowerVolume>", spawn "pactl set-sink-volume 0 -5%")
    , ("<XF86AudioRaiseVolume>", spawn "pactl set-sink-volume 0 +5%")    
    ]

defaults = def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = True,
        clickJustFocuses   = False,
        borderWidth        = 1,
        modMask            = mod4Mask,
        workspaces         = ["1","2","3","4","5","6","7","8","9"],
        normalBorderColor  = "#dddddd",
        focusedBorderColor = "#ff0000",
        
      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        startupHook        = myStartupHook
    }

-- | Finally, a copy of the default bindings in simple textual tabular format.
help :: String
help = unlines ["The default modifier key is 'alt'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch xterminal",
    "mod-p            Launch dmenu",
    "mod-Shift-p      Launch gmrun",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging"]
