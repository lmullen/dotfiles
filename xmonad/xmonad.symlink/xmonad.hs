import XMonad
import XMonad.Config.Gnome
import XMonad.Util.EZConfig
import XMonad.Hooks.ManageHelpers
import qualified XMonad.StackSet as W
import XMonad.Util.NamedScratchpad

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
  , ("M-S-t", scratchTerm) 
  ] 
  where
    scratchTerm = namedScratchpadAction myScratchPads "terminal"

-- Scratchpad configuration tips from
-- http://pbrisbin.com/posts/scratchpad_everything
-- http://pbrisbin.com/posts/xmonad_scratchpad
myScratchPads = [
  NS "terminal" spawnTerm findTerm manageTerm
  ] where
    spawnTerm = myTerminal ++ " --disable-factory --hide-menubar --name scratchpad"
    findTerm  = resource    =? "scratchpad"
    manageTerm = customFloating $ W.RationalRect l t w h
      where
        h = 0.55      -- height as percent
        w = 0.55      -- width as percent
        t = (1 - h)/2 -- centered top/bottom
        l = (1 - w)/2 -- centered left/right

myManageHook = composeAll [
    manageHook gnomeConfig
  , (className =? "Gnome-panel" <&&> title =? "Run Application") --> doCenterFloat
  , (className =? "sublime-text-2" <&&> title =? "Open File") --> doCenterFloat
  , (className =? "Empathy") --> doFloat
  , (stringProperty "WM_WINDOW_ROLE" =? "pop-up") --> doCenterFloat
  , (resource =? "Dialog") --> doFloat
  ] <+> namedScratchpadManageHook myScratchPads
