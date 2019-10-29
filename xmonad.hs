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
        { startupHook = do
            -- spawnAndDo (doShift "Prog1") "emacsclient -c -a \"\""
            -- spawnAndDo (doShift "Prog2") "emacsclient -c -a \"\""
            -- spawnAndDo (doShift "Term") "emacsclient -c -a \"\""
            spawnAndDo (doShift "Spotify") "spotify"
        , workspaces = ["Browser", "Prog1", "Prog2", "Term", "School1", "School2", "Spotify", "8", "9"]
        , manageHook = manageSpawn <+> manageDocks <+> manageHook defaultConfig
        , layoutHook = avoidStruts  $  layoutHook defaultConfig
        , handleEventHook    = handleEventHook defaultConfig <+> docksEventHook
        , logHook = do
            updatePointer (0.5, 0.5) (0, 0)
            dynamicLogWithPP xmobarPP
                { ppOutput = hPutStrLn xmproc
                , ppTitle = xmobarColor "green" "" . shorten 50
                }
        , modMask = mod4Mask     -- Rebind Mod to the Windows key
        } `additionalKeys`
        [ ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s -e \'mv $f ~/Pictures/screenshots\'")
        , ((0, xK_Print), spawn "scrot -e \'mv $f ~/Pictures/screenshots\'")
        , ((mod4Mask, xK_x), spawn "emacsclient -c -a \"\"")
        -- Workaround for screen ordering
        , ((mod4Mask, xK_w), viewScreen horizontalScreenOrderer (P 0))
        , ((mod4Mask, xK_e), viewScreen horizontalScreenOrderer (P 1))
        , ((mod4Mask, xK_r), viewScreen horizontalScreenOrderer (P 2))
        ] `additionalKeysP`
        [ ("<XF86AudioLowerVolume>", setMute True >> lowerVolume 4 >> return ())
        , ("<XF86AudioRaiseVolume>", setMute True >> raiseVolume 4 >> return ())
        , ("<XF86AudioMute>", toggleMute >> return ())
        , ("<XF86MonBrightnessDown>", spawn "light -U 5")
        , ("<XF86MonBrightnessUp>", spawn "light -A 5")
        ]

-- firefoxHook = [ className =? b --> doF (shift "Browser") | b <- myClass ]
