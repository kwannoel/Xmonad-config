import XMonad
import XMonad.Actions.SpawnOn
import XMonad.Actions.UpdatePointer
import XMonad.Actions.PhysicalScreens
import Data.Default
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe, safeSpawnProg)
import XMonad.Util.EZConfig(additionalKeys, additionalKeysP)
import XMonad.Actions.Volume
import XMonad.Operations (kill)
import System.IO

main = do
    xmproc <- spawnPipe "xmobar"
    
    xmonad $ docks $ def
        { --startupHook = do
            -- spawnAndDo (doShift "Prog1") "emacsclient -c -a \"\""
            -- spawnAndDo (doShift "Prog2") "emacsclient -c -a \"\""
            -- spawnAndDo (doShift "Term") "emacsclient -c -a \"\""
           -- spawnAndDo (doShift "Spotify") "spotify"
          workspaces = ["Firefox", "Chromium", "Prog1", "Prog2", "Scratch", "Notes", "term1", "term2", "School1", "School2"]
        , manageHook = manageSpawn <+> manageDocks <+> manageHook def
        , layoutHook = avoidStruts  $  layoutHook def
        -- , handleEventHook    = handleEventHook def <+> docksEventHook
        , logHook = do
            updatePointer (0.5, 0.5) (0, 0)
            dynamicLogWithPP xmobarPP
                { ppOutput = hPutStrLn xmproc
                , ppTitle = xmobarColor "green" "" . shorten 50
                , ppOrder = formatXmobarPP -- Remove layout and title
                }
        -- FIXME: See why this is bugged.
        -- xev shows mod4Mask pressed on sporadically.
        -- There could be hardware issue + xmonad issue.
        -- e.g. if hardware key is unresponsive,
        -- xmonad ignores the presses from it after some time.
        -- , modMask = mod4Mask     -- Rebind Mod to the Windows key
        -- additionally seems like superL works after alt is pressed.
        -- regression happens overtime, e.g. maybe 4-5 times after pc is rebooted and xmonad is spawned.
        -- start xmonad:
        -- ~/.xmonad/xmonad-x86_64-linux --restart
        } `additionalKeys`
        [ ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s -e \'mv $f ~/Pictures/screenshot.jpg\'")
        , ((0, xK_Print), spawn "scrot -e \'mv $f ~/Pictures/screenshot.jpg\'")
        , ((mod1Mask, xK_m), safeSpawnProg "dmenu_run") -- remap from defaults
        , ((mod1Mask, xK_d), safeSpawnProg "emacs")
        , ((mod1Mask, xK_s), spawn "source /home/noel/user-utils/screen-multi-2.sh")
        , ((mod1Mask, xK_a), spawn "source /home/noel/user-utils/screen-single.sh")
        -- , ((mod4Mask, xK_i), safeSpawnProg "source /home/noel/user-utils/intellij.sh")
        -- Workaround for screen ordering
        , ((mod1Mask, xK_w), viewScreen horizontalScreenOrderer (P 0))
        , ((mod1Mask, xK_e), viewScreen horizontalScreenOrderer (P 1))
        , ((mod1Mask, xK_r), viewScreen horizontalScreenOrderer (P 2))
        , ((mod1Mask, xK_F9), setMute True >> lowerVolume 4 >> return ())
        , ((mod1Mask, xK_F10), setMute True >> raiseVolume 4 >> return ())
        , ((mod1Mask, xK_F8), toggleMute >> return ())
        , ((mod1Mask, xK_F6), spawn "light -U 15")
        , ((mod1Mask, xK_F7), spawn "light -A 15")
        ]

-- unresponsive xmonad
-- cat /proc/$(ps aux | grep [x]monad | cut -d" " -f4)/fd/* > /dev/null

formatXmobarPP :: [String] -> [String]
formatXmobarPP ls = case ls of
  [workspace, layout, title] -> [workspace, "", ""]
  _ -> ls
-- firefoxHook = [ className =? b --> doF (shift "Browser") | b <- myClass ]
