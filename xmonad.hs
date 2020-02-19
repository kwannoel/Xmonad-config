import XMonad
import XMonad.Actions.SpawnOn
import XMonad.Actions.UpdatePointer
import XMonad.Actions.PhysicalScreens
import Data.Default
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys, additionalKeysP)
import XMonad.Actions.Volume
import System.IO

main = do
    xmproc <- spawnPipe "xmobar"
    
    xmonad $ def
        { --startupHook = do
            -- spawnAndDo (doShift "Prog1") "emacsclient -c -a \"\""
            -- spawnAndDo (doShift "Prog2") "emacsclient -c -a \"\""
            -- spawnAndDo (doShift "Term") "emacsclient -c -a \"\""
           -- spawnAndDo (doShift "Spotify") "spotify"
          workspaces = ["Firefox", "Chromium", "Prog1", "Prog2", "Scratch", "Notes", "term1", "term2", "School1", "School2"]
        , manageHook = manageSpawn <+> manageDocks <+> manageHook defaultConfig
        , layoutHook = avoidStruts  $  layoutHook defaultConfig
        , handleEventHook    = handleEventHook defaultConfig <+> docksEventHook
        , logHook = do
            updatePointer (0.5, 0.5) (0, 0)
            dynamicLogWithPP xmobarPP
                { ppOutput = hPutStrLn xmproc
                , ppTitle = xmobarColor "green" "" . shorten 50
                , ppOrder = formatXmobarPP -- Remove layout and title
                }
        , modMask = mod4Mask     -- Rebind Mod to the Windows key
        } `additionalKeys`
        [ ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s -e \'mv $f ~/Pictures/screenshots\'")
        , ((0, xK_Print), spawn "scrot -e \'mv $f ~/Pictures/screenshots\'")
        , ((mod4Mask, xK_x), spawn "emacsclient -c -a \"\"")
        , ((mod4Mask, xK_s), spawn "source /home/noel/user-utils/screen-multi.sh")
        , ((mod4Mask, xK_a), spawn "source /home/noel/user-utils/screen-single.sh")
        , ((mod4Mask, xK_i), spawn "source /home/noel/user-utils/intellij.sh")
        -- Workaround for screen ordering
        , ((mod4Mask, xK_w), viewScreen horizontalScreenOrderer (P 0))
        , ((mod4Mask, xK_e), viewScreen horizontalScreenOrderer (P 1))
        , ((mod4Mask, xK_r), viewScreen horizontalScreenOrderer (P 2))
        , ((mod4Mask, xK_F9), setMute True >> lowerVolume 4 >> return ())
        , ((mod4Mask, xK_F10), setMute True >> raiseVolume 4 >> return ())
        , ((mod4Mask, xK_F8), toggleMute >> return ())
        , ((mod4Mask, xK_F6), spawn "light -U 15")
        , ((mod4Mask, xK_F7), spawn "light -A 15")
        ]

formatXmobarPP :: [String] -> [String]
formatXmobarPP ls = case ls of
  [workspace, layout, title] -> [workspace, "", ""]
  _ -> ls
-- firefoxHook = [ className =? b --> doF (shift "Browser") | b <- myClass ]
