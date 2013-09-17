import XMonad
import XMonad.Config.Gnome
import XMonad.Config.Desktop
import XMonad.Util.EZConfig
import XMonad.Hooks.ManageHelpers
import qualified XMonad.StackSet as W
import XMonad.Util.NamedScratchpad
import XMonad.Hooks.EwmhDesktops
import XMonad.Actions.CycleWindows
import XMonad.Actions.CycleWS
import XMonad.Layout.SimplestFloat
import XMonad.Layout.IM
import XMonad.Layout.Grid
import Data.Ratio ((%))
import XMonad.Layout.PerWorkspace (onWorkspace)
import XMonad.Layout.NoBorders (noBorders)
import XMonad.Layout.Reflect

main = xmonad $ gnomeConfig {       -- We use gnome rather than default
    modMask           = mod4Mask            -- Use super key for mod
    , borderWidth     = 2
    , terminal        = myTerminal
    , workspaces      = myWorkspaces
    , manageHook      = myManageHook  <+> manageHook gnomeConfig
    , layoutHook      = desktopLayoutModifiers $ myLayoutHook
    , handleEventHook = fullscreenEventHook <+> handleEventHook gnomeConfig
   } `additionalKeysP` myKeys

myTerminal = "gnome-terminal"

myWorkspaces = ["1:web", "2:text", "3:zotero", "4:rstudio",
                "5", "6", "7:todo", "8:im", "9:system", "NSP"]

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
  , ("M-<Up>",      toggleWS)
  , ("M-<Down>",    toggleWS)
  --, ("M-<Down>",    nextScreen)
  --, ("M-<Up>",      prevScreen)
  , ("M-S-<Right>", shiftTo Next EmptyWS)
  , ("M-S-<Left>",  shiftTo Prev EmptyWS)
  , ("M-S-t",       scratchTerm)
  ]
  where
    scratchTerm = namedScratchpadAction myScratchPads "terminal"
    --scratchBrowser = namedScratchpadAction myScratchPads "browser"

-- Scratchpad configuration tips from
-- http://pbrisbin.com/posts/scratchpad_everything
-- http://pbrisbin.com/posts/xmonad_scratchpad
myScratchPads = [
    NS "terminal" spawnTerm findTerm manageTerm
  ] where
    spawnTerm = "gnome-terminal --disable-factory --hide-menubar --name=scratchpad"
    findTerm  = resource    =? "scratchpad"
    manageTerm = customFloating $ W.RationalRect l t w h
      where
        h = 0.55      -- height as percent
        w = 0.55      -- width as percent
        t = (1 - h)/2 -- centered top/bottom
        l = (1 - w)/2 -- centered left/right

myManageHook = composeAll [
  -- Float certain windows
    (className =? "Gnome-panel" <&&> title =? "Run Application") --> doCenterFloat
  , (className =? "gnome-search-tool")                           --> doCenterFloat
  , (className =? "Gimp-2.8")                                    --> doFloat
  , (className =? "sublime-text-2" <&&> title =? "Open File")    --> doCenterFloat
  , (className =? "Sublime_text" <&&> title =? "Open File")      --> doCenterFloat
  , (stringProperty "WM_WINDOW_ROLE" =? "pop-up")                --> doCenterFloat
  , (resource =? "Dialog")                                       --> doFloat
  , (className =? "Birdie" <&&> title =? "Preview")              --> doCenterFloat

  -- Move certain classes of windows
  , (className =? "Google-chrome")                               --> doShift "1:web"
  , (className =? "Birdie")                                      --> doShift "1:web"
  , (className =? "Zotero")                                      --> doShift "3:zotero"
  , (className =? "Rstudio")                                     --> doShift "4:rstudio"
  , (className =? "Gimp-2.8")                                    --> doShift "6"
  , (className =? "Empathy")                                     --> doShift "8:im"
  , (className =? "Synaptic")                                    --> doShift "9:system"
  , (className =? "Transmission-gtk")                            --> doShift "9:system"
  , (className =? "Update-manager")                              --> doShift "9:system"
  , (className =? "Deja-dup")                                    --> doShift "9:system"
  , (className =? "Update-manager")                              --> doShift "9:system"
  , (className =? "Rhythmbox")                                   --> doShift "9:system"
  --]
  ] <+> namedScratchpadManageHook myScratchPads

-- Define default layouts used on most workspaces
defaultLayouts = layoutHook gnomeConfig

-- Define layout for specific workspaces
webLayout    = reflectHoriz $ withIM (1%3) (ClassName "Birdie") tiled ||| Mirror tiled ||| Full
  where
    tiled   = Tall nmaster delta ratio
    nmaster = 1
    ratio   = 1/2
    delta   = 1/100
imLayout     = withIM (1%4) (Title "Contact List") Grid ||| Full
systemLayout = Grid ||| Full

-- Put all layouts together
myLayoutHook  = onWorkspace "1:web"     webLayout $
                onWorkspace "8:im"      imLayout $
                onWorkspace "9:system"  systemLayout $
                defaultLayouts
