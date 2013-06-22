{-Setup for xmonad-}

import XMonad
import XMonad.Config.Gnome

-- Imports needed for view rather than greedyView
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig

main = xmonad $ gnomeConfig {
      modMask = mod4Mask
    , workspaces = myWorkspaces
   } `additionalKeysP` myKeys

myWorkspaces = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

myKeys = [
    ("M-S-q", spawn "gnome-session-quit")
  ] ++  

  [ (otherModMasks ++ "M-" ++ [key], action tag)
    | (tag, key) <- zip myWorkspaces "123456789"
    , (otherModMasks, action) <- [ ("", windows . W.view) -- was W.greedyView
                                    , ("S-", windows . W.shift)]
  ]
