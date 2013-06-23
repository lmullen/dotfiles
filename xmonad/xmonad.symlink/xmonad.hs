import XMonad
import XMonad.Config.Gnome

-- Imports needed for view rather than greedyView
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig

-- Imports need to float windows
import XMonad.Hooks.ManageHelpers

main = xmonad $ gnomeConfig {       -- We use gnome rather than default
      modMask = mod4Mask            -- Use super key for mod
    , workspaces = myWorkspaces
    , manageHook = myManageHook 
   } `additionalKeysP` myKeys

myWorkspaces = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

myKeys = [
    -- Instead of killing window manager, log out
    ("M-S-q", spawn "gnome-session-quit") 
  ] ++   -- (++) is needed here because the following list comprehension
         -- is a list, not a single key binding. Simply adding it to the
         -- list of key bindings would result in something like [ b1, b2,
         -- [ b3, b4, b5 ] ] resulting in a type error. (Lists must
         -- contain items all of the same type.)
  [ (otherModMasks ++ "M-" ++ [key], action tag)
    | (tag, key) <- zip myWorkspaces "123456789"
    , (otherModMasks, action) <- [ ("", windows . W.view) -- was W.greedyView
                                    , ("S-", windows . W.shift)]
  ]

myManageHook = composeAll [
      manageHook gnomeConfig
    , (className =? "Gnome-panel" <&&> title =? "Run Application") --> doCenterFloat
    , (className =? "sublime-text-2" <&&> title =? "Open File") --> doCenterFloat
    , (className =? "Empathy") --> doFloat
    , (resource =? "Dialog") --> doFloat
  ]
