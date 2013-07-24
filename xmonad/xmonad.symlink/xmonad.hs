import XMonad
import XMonad.Config.Gnome
import XMonad.Util.EZConfig
import XMonad.Hooks.ManageHelpers
import qualified XMonad.StackSet as W
--import XMonad.Util.NamedScratchpad
import XMonad.Hooks.EwmhDesktops

main = xmonad $ gnomeConfig {       -- We use gnome rather than default
    modMask           = mod4Mask            -- Use super key for mod
    , terminal        = myTerminal
    , workspaces      = myWorkspaces
    , manageHook      = myManageHook 
    , handleEventHook = fullscreenEventHook
   } `additionalKeysP` myKeys

myTerminal = "gnome-terminal"

myWorkspaces = ["1:subl", "2:terminal", "3:web", "4:research", 
  "5:research", "6", "7:todo", "8:nautilus", "9:system"]

myKeys = [
  -- Instead of killing window manager, log out
    ("M-S-q", spawn "gnome-session-quit") 
  , ("M-S-d", spawn "gnome-control-center display") 
  , ("M-S-n", spawn "nautilus --new-window") 
  , ("M-S-s", spawn "gnome-control-center") 
  , ("M-S-f", spawn "gnome-search-tool")
  --, ("M-S-p", scratchTerm) 
  --, ("M-S-o", scratchBrowser) 
  ] 
  --where
    --scratchTerm = namedScratchpadAction myScratchPads "terminal"
    --scratchBrowser = namedScratchpadAction myScratchPads "browser"

-- Scratchpad configuration tips from
-- http://pbrisbin.com/posts/scratchpad_everything
-- http://pbrisbin.com/posts/xmonad_scratchpad
--myScratchPads = [
--    NS "terminal" spawnTerm findTerm manageTerm
--  , NS "browser" spawnBrowser findBrowser manageBrowser
--  ] where
--    spawnTerm = "gnome-terminal --disable-factory --hide-menubar --name=scratchpad"
--    findTerm  = resource    =? "scratchpad"
--    manageTerm = customFloating $ W.RationalRect l t w h
--      where
--        h = 0.55      -- height as percent
--        w = 0.55      -- width as percent
--        t = (1 - h)/2 -- centered top/bottom
--        l = (1 - w)/2 -- centered left/right
--    spawnBrowser = "chromium-browser --name=qbrowser"   -- Better if we could use Chrome
--    findBrowser  = resource =? "qbrowser"
--    manageBrowser = customFloating $ W.RationalRect l t w h
--      where
--        h = 0.94     -- height as percent
--        w = 0.94     -- width as percent
--        t = (1 - h)/2 -- centered top/bottom
--        l = (1 - w)/2 -- centered left/right

myManageHook = composeAll [
    manageHook gnomeConfig
  , (className =? "Gnome-panel" <&&> title =? "Run Application") --> doCenterFloat
  , (className =? "gnome-search-tool") --> doCenterFloat
  , (className =? "sublime-text-2" <&&> title =? "Open File") --> doCenterFloat
  , (className =? "Empathy") --> doFloat
  , (className =? "Deja-dup") --> doCenterFloat
  , (className =? "Transmission-gtk") --> doCenterFloat
  , (stringProperty "WM_WINDOW_ROLE" =? "pop-up") --> doCenterFloat
  , (resource =? "Dialog") --> doFloat
  ] 
  --] <+> namedScratchpadManageHook myScratchPads
