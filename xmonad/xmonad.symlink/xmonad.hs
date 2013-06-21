{-Setup for xmonad-}

import XMonad
-- import XMonad.Hooks.DynamicLog
import XMonad.Config.Gnome

main = xmonad gnomeConfig {
  modMask = mod4Mask
}
