import XMonad
import XMonad.Config.Gnome
import XMonad.Util.EZConfig
import XMonad.Hooks.ManageHelpers

main = xmonad $ gnomeConfig {       -- We use gnome rather than default
      modMask = mod4Mask            -- Use super key for mod
    , terminal = myTerminal
    , workspaces = myWorkspaces
    , manageHook = myManageHook 
   } `additionalKeysP` myKeys

myTerminal = "gnome-terminal"

myWorkspaces = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

myKeys = [
  -- Instead of killing window manager, log out
  ("M-S-q", spawn "gnome-session-quit") 
  ] 

myManageHook = composeAll [
    manageHook gnomeConfig
  , (className =? "Gnome-panel" <&&> title =? "Run Application") --> doCenterFloat
  , (className =? "sublime-text-2" <&&> title =? "Open File") --> doCenterFloat
  , (className =? "Empathy") --> doFloat
  , (stringProperty "WM_WINDOW_ROLE" =? "pop-up") --> doCenterFloat
  , (resource =? "Dialog") --> doFloat
  ]
