Gestures:

/*
 * Gestures
 */

; Wheel:        Switch between tabs.
; see below
;~ Gesture_WheelUp = ^+{Tab}
;~ Gesture_WheelDown = ^{Tab}

; Up:           Launch My Computer (usually).
Gesture_U = {Esc}

; "F"           Full Screen
Gesture_L_D_U_R = {f11}

; Down:         Keyboard inserts
Gesture_D = {Enter}
Gesture_D_U = ^r
Gesture_L_D_R = ^x
Gesture_L_U_R = ^c
Gesture_U_R_D = ^v

; Left, Up:     Go up one level in explorer.
; Gesture_L_U = !{Up}

; Up, ...:      Control media player.
GestureName_U_L = Media_Prev
Gesture_U_L = {Media_Prev}
GestureName_U_R = Media_Next
Gesture_U_R = {Media_Next}
GestureName_U_D = Media_Play_Pause
Gesture_U_D = {Media_Play_Pause}
GestureName_U_D_U = Media_Launch
Gesture_U_D_U = {Media_Launch}
GestureName_U_L_R = Launch_Media
Gesture_U_L_R = {Launch_Media}

; Down, Right, Left: Close window immediately.
Gesture_D_R_L = !{F4}

; Names for labeled gestures ----------------------------------------------
GestureName_L_D_R_D_L = Sleep (esc to cancel)
GestureName_R_U = MaximizeRestore

/*
 * Option Overrides
 */

m_PenWidth = 6
m_NodePenWidth = 4
m_PenColor = 0000FF
m_InitialTimeout = 750
;m_EnabledIcon = 

/*
 * Init for Additional Scripts
 */

SetWinDelay, 2  ; For EasyWindowDrag.ahk

; Windows which gestures are disabled in.  Search below for "#if" or "G_Blacklisted()".
GroupAdd, Blacklist, ahk_class VMPlayerFrame
GroupAdd, Blacklist, ahk_class SynergyDesk
GroupAdd, Blacklist, ahk_class TSSHELLWND
GroupAdd, Blacklist, ahk_class TaskSwitcherWnd  ; Aero Alt+Tab
GroupAdd, Blacklist, Sun VirtualBox ahk_class QWidget

; Use WinClose instead of !{F4} with these windows.
GroupAdd, WinCloseGroup, ahk_class ConsoleWindowClass
GroupAdd, WinCloseGroup, ahk_class AutoHotkey

/*
 * END OF INIT/CONFIG SECTION
 */
return

; ; Hold XButton1 to show the Alt+Tab dialog.  Release to switch applications.
; ; With the Aero task-switcher, one can also click the thumbnail to switch.
; *XButton1::
;     if m_WaitForRelease ; Holding gesture button.
;     {
;         m_ScrolledWheel := true
;         m_ExitLoop := true
;         Send {Media_Next}
;         return
;     }
;     Send {Blind}{Alt Down}{Tab}
;     MouseGetPos, x, y
;     if (x < 0) ; Put it on the appropriate monitor, assumes only two monitors,
;     {          ; where the secondary monitor is to the left of the primary.
;         WinWait, ahk_class TaskSwitcherWnd,, 0.2
;         if !ErrorLevel
;         {
;             SysGet, Mon2, MonitorWorkArea, 1
;             WinGetPos, x, y, w, h
;             x := Mon2Left+(Mon2Right-Mon2Left-w)//2
;             y := Mon2Top+(Mon2Bottom-Mon2Top-h)//2
;             WinMove, x, y
;             ifWinExist, ahk_class TaskSwitcherOverlayWnd
;                 WinMove, x, y
;         }
;     }
;     KeyWait, XButton1
;     Send {Blind}{Alt Up}
; *XButton1 Up::
;     return

; Allow WheelLeft/Right keybindings.
; #IfWinActive ahk_class Valve001 ; HALF-LIFE 2
;     *WheelLeft::Send, {Blind}-
;     *WheelRight::Send, {Blind}=
; #IfWinActive World of Warcraft ahk_class GxWindowClassD3d
;     *WheelLeft::Send, {Blind}[
;     *WheelRight::Send, {Blind}]
; #IfWinActive

; Use AutoHotkey_L's #if feature for more effective blacklisting.
#if m_WaitForRelease || !G_Blacklisted()

#Include *i ..\EasyWindowDrag.ahk

; activate spotify
Gesture_U_D_U:
    gosub ActivateMedia
return

; paste 
PasteSpecial:
;~ Gesture_U:
    IfWinActive, ahk_class ConsoleWindowClass
    {
        Send, !{space}ep
        return
    }
    send, ^v
return

; isPuzzleActive() {
;     SetTitleMatchMode, 2
;     if (WinActive("Stitches -")) {
;         return true
;     }
;     return false
; }

; S-shape:      Sleep
Gesture_L_D_R_D_L:
    m_DelayedAction = DoSleep
return

Gesture_D_L:
    MouseGetPos,,,lastMinID
    WinActivate, ahk_id %lastMinID%
    G_MinimizeActiveWindow()
    ;~ WinMinimize, ahk_id %KDE_id%
return

Gesture_R_U:
Gesture_R_U_R:
    MouseGetPos,,,KDE_id
    WinActivate, ahk_id %KDE_id%
    WinGet,KDE_Win,MinMax,ahk_id %KDE_id%

    if (WinActive("ahk_class MozillaWindowClass") || WinActive("ahk_class Chrome_WidgetWin_0")
        || WinActive("ahk_class Chrome_WidgetWin_1") || WinActive("ahk_class QWidget" /* VLC */)) {
        if (m_gesture = "_R_U_R") {
            ; Theater mode
            if (WinActive("- Twitch -")) {
                send, !{t}
            } else if  (WinActive("- YouTube -")) {
                send, {t}
            } else {
                send, {f11}
            }
        } else {
            if (WinActive("- Twitch -")) {
                send, f
            ; } else if  (WinActive("- YouTube -")) {
            ;    send, f 
            } else if (KDE_Win && !WinActive("ahk_class MozillaWindowClass")) {
                WinRestore,ahk_id %KDE_id%
            } else {
                Send, {f11}
            }
        }
        return
    } else if (WinActive("ahk_class QWidget")) {
        Send, f
        return
    } else if (WinActive("ahk_exe zoom.exe")) {
        Send, !f
    }

    If KDE_Win
    WinRestore,ahk_id %KDE_id%
    Else
    WinMaximize,ahk_id %KDE_id%
return

Gesture_RButton:
    If (WinActive("ahk_class Shell_TrayWnd") || WinActive("ahk_class Shell_SecondaryTrayWnd")) {
        WinSet AlwaysOnTop, Toggle, %ActiveWin%
    } else if (m_gesture = "_U") {
        SendInput, {Media_Play_Pause}
    } else if (WinActive("ahk_class MozillaWindowClass")) {
        Send,!b
        Sleep, 100
        Send, l{Enter}
        clipboard := "" ; Empty the clipboard
        Sleep, 200
        Send, ^c^l^a
        ClipWait, .5
        Sleep, 100
        Send, ^v{enter}
        Send, ^{Tab}
    } else {
        Send, ^c
    }
return

Gesture_MButton:
    if (m_gesture = "_U") {
        Send {Volume_Mute}
        SoundGet, vol
        OSD(Round(vol))
        return        
    }

    MouseGetPos,,,KDE_id
    WinActivate, ahk_id %KDE_id%
    WinWaitActive,ahk_id %KDE_id%,,.1

    if WinActive("ahk_class CabinetWClass")
        send, ^w
    else
        send, ^{f4}
return

Gesture_LButton:
    if m_gesture = _U
    {
        gosub ActivateMedia
        return
    }
    gosub PasteSpecial
return

; Jump to previous window
Gesture_R_L:
    send, {alt down}{tab}{alt up}
return

sendKeys(keys) {
    send %keys%
}

Gesture_WheelDown:
Gesture_WheelUp:
    up := A_ThisHotkey == "*WheelUp"
    if (m_gesture = "_R") {
        ; Navigate windows (alt tab)
        m_CustomKeyUp := "{alt up}"
        sendKeys("{alt down}" . (up ? "+" : "") . "{tab}")
    } else if (m_gesture = "_D_R_U") {
        ; "undo" 
        sendKeys(up ? "^z" : "^y")
    } else if (m_gesture = "_U") {
        ; Change volume on spotify if active, else globally
        if WinActive("ahk_exe Spotify.exe") {
            sendKeys("^" (up ? "{Up}" : "{Down}"))
        } else {
            sendKeys("{Volume_" . (up ? "Up" : "Down") . " 2}")
            Sleep 100
            SoundGet, vol
            OSD(Round(vol))
        }
    } else if (m_gesture = "_L") {
        ; Repeat find
        if (WinActive("ahk_class SciTEWindow")) {
            sendKeys ((up ? "+" :"") "F3")
        } else if (WinActive("ahk_class Chrome_WidgetWin_1")) {
            sendKeys ((up ? "+" :"") "^g")
        }
    } else if (m_gesture = "_D") {
        ; Navigate desktops
        sendKeys("^#" (up ? "{Left}" : "{Right}"))
    } else {
        ; Navigate tabs (ctrl tab)
        if (m_ScrolledWheel = 0) {
            MouseGetPos,,,KDE_id
            WinActivate, ahk_id %KDE_id%
        }
        if (WinActive("ahk_class SciTEWindow") || WinActive("ahk_class PX_WINDOW_CLASS")) {
            sendKeys("^" (up ? "{PgUp}" : "{PgDn}"))
        } else if (WinActive("ahk_exe Code.exe")) {
            sendKeys("^" (up ? "{PgUp}" : "{PgDn}"))
        } else if (WinActive("ahk_class ShImgVw:CPreviewWnd")) {
            sendKeys(up ? "{Left}" : "{Right}")
        } else {
            sendKeys((up ? "+" :"") "^{tab}")
        }
    }
return

Gesture_U:
    if (WinActive("ahk_class MozillaWindowClass")) {
        Send,{home}
    } else {
        Send,{Esc}
    }
return

#If ; end blacklisted

G_Blacklisted()
{
    MouseGetPos,,, MouseWinId
    return WinExist("ahk_group Blacklist ahk_id " MouseWinId)
}
