import XMonad
import XMonad.Config.Gnome
import XMonad.Util.EZConfig
import XMonad.Hooks.ManageHelpers
import qualified XMonad.StackSet as W
--import XMonad.Util.NamedScratchpad
import XMonad.Hooks.EwmhDesktops
--import XMonad.Layout.IM
--import XMonad.Layout.PerWorkspace
import XMonad.Actions.CycleWindows
import XMonad.Actions.CycleWS

main = xmonad $ gnomeConfig {       -- We use gnome rather than default
    modMask           = mod4Mask            -- Use super key for mod
    , borderWidth     = 2
    , terminal        = myTerminal
    , workspaces      = myWorkspaces
    , manageHook      = myManageHook  <+> manageHook gnomeConfig
    , handleEventHook = fullscreenEventHook <+> handleEventHook gnomeConfig
   } `additionalKeysP` myKeys

myTerminal = "gnome-terminal"

myWorkspaces = ["1:text", "2:web", "3:terminal", "4:research", 
  "5:research", "6", "7", "8:im", "9:system"]

myKeys = [
  -- Instead of killing window manager, log out
    ("M-S-q",       spawn "gnome-session-quit") 
  , ("M-S-d",       spawn "gnome-control-center display") 
  , ("M-S-n",       spawn "nautilus --new-window") 
  , ("M-S-s",       spawn "gnome-control-center") 
  , ("M-S-f",       spawn "gnome-search-tool")
  , ("M-u",         rotUnfocusedUp)                         -- Cycle windows
  , ("M-i",         rotUnfocusedDown)
  , ("M-<Right>",   nextWS)                               -- Cycle workstations
  , ("M-<Left>",    prevWS)
  , ("M-<Down>",    nextScreen)
  , ("M-<Up>",      prevScreen)
  , ("M-S-<Right>", shiftTo Next EmptyWS)
  , ("M-S-<Left>",  shiftTo Prev EmptyWS)
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
  -- Float certain windows
    (className =? "Gnome-panel" <&&> title =? "Run Application") --> doCenterFloat
  , (className =? "gnome-search-tool")                        --> doCenterFloat
  , (className =? "sublime-text-2" <&&> title =? "Open File") --> doCenterFloat
  , (className =? "Empathy")                                  --> doFloat
  , (className =? "Deja-dup")                                 --> doCenterFloat
  , (className =? "Transmission-gtk")                         --> doCenterFloat
  , (className =? "Update-manager")                           --> doFloat
  , (stringProperty "WM_WINDOW_ROLE" =? "pop-up")             --> doCenterFloat
  , (resource =? "Dialog")                                    --> doFloat

  -- Move certain classes of windows
  , (className =? "sublime-text-2")    --> doShift "1:text"
  , (className =? "Google-chrome")     --> doShift "2:web"
  , (className =? "Empathy")           --> doShift "8:im"
  , (className =? "Synaptic")          --> doShift "9:system"
  , (className =? "Transmission-gtk")  --> doShift "9:system"
  , (className =? "Update-manager")    --> doShift "9:system"
  ] 
  --] <+> namedScratchpadManageHook myScratchPads


-- Todo
-- Next and previous workspace keys
-- XMonad.Layout.PerWorkspace: http://xmonad.org/xmonad-docs/xmonad-contrib/XMonad-Layout-PerWorkspace.html
-- http://www.nepherte.be/step-by-step-configuration-of-xmonad/
-- http://superuser.com/questions/192271/tiling-window-managers-and-multi-head-setup-gnome-style-workspace
-- http://pbrisbin.com/posts/xmonads_im_layout
