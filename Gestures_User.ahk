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
        || WinActive("ahk_class Chrome_WidgetWin_1") || WinActive("ahk_exe vlc.exe")) {
        if (m_gesture = "_R_U_R") {
            ; Theater mode
            if (WinActive("- Twitch -")) {
                send, !{t}
            } else if  (WinActive("- YouTube -")) {
                send, {t}
            } else {
                goto MaximizeOrRestore
            }
        } else {
            if (WinActive("- Twitch -") || WinActive("ahk_exe vlc.exe")) {
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
    } else if (WinActive("ahk_exe zoom.exe")) {
        Send, !f
    }
MaximizeOrRestore:
    WinGet,KDE_Win,MinMax,ahk_id %KDE_id%
    If (KDE_Win) {
        ; OSD("restore")
        WinRestore,ahk_id %KDE_id%
    } Else {
        ; OSD("max")
        WinMaximize,ahk_id %KDE_id%
    }
return

Gesture_RButton:
    If (WinActive("ahk_class Shell_TrayWnd") || WinActive("ahk_class Shell_SecondaryTrayWnd")) {
        WinSet AlwaysOnTop, Toggle, %ActiveWin%
    } else if (m_gesture = "_U") {
        SendInput, {Media_Play_Pause}
    } else if (m_gesture = "_L" && WinActive("Hanab Live")) {
        sendKeys("{up}")
    } else if (m_gesture = "_L" && WinActive("- YouTube -")) {
        sendKeys("k")
    } else if (m_gesture = "_R") {
        gosub WinSwapMon
        return
    } else if (WinActive("ahk_class MozillaWindowClass")) {
        Send,!b
        Sleep, 100
        Send, l{Enter}
        clipboard := "" ; Empty the clipboard
        Sleep, 200
        Send, ^c^l^a
        ClipWait, .5
        Sleep, 100
        Send, ^v
        Sleep, 100
        Send, {enter}
        Send, ^{Tab}
    } else {
        Send, ^c
    }
return

WinSwapMon:
    OSD("swap mon")
	MouseGetPos, ClickX, ClickY, win_id
	; if (InTitleBar()) {
		SwapMon(win_id, 0)
	; }
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

sendKeys(keys, ahk_id:=0) {
    if (ahk_id) {
        ; ControlFocus, Chrome_RenderWidgetHostHWND1
        ; ControlSend, , %keys%, ahk_id %ahk_id%
        global old_id
        if (!old_id) {
            WinGet, old_id, , A
            WinActivate, ahk_id %ahk_id%
            WinWaitActive, ahk_id %ahk_id%,, .2 
        }
        send %keys%
        SetTimer, restore_win, -100
        ; Log("Timer set for " old_id)
        ; sleep, .01
    } else {
        send %keys%
    }
}

restore_win:
    if (old_id) {
        ; OSD("Reactivate" old_id)
        ; Log("Reactivate" old_id)
        WinActivate, ahk_id %old_id%
        old_id := 0
    }
return

Show_Volume:
    SoundGet, vol
    OSD(Round(vol))
return

Gesture_WheelDown:
Gesture_WheelUp:
    MouseGetPos, X,Y,id
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
            SoundGet, vol
            if (vol < 16) {
                mul := 2
            } else if (vol > 40) {
                mul := 8
            } else {
                mul := 4
            }
            vol += mul*(up ? 1 : -1)
            vol := max(0, min(100, vol))
            OSD(Round(vol))
            SoundSet, vol
       }
    } else if (m_gesture = "_L") {
        ; Repeat find
        if (WinActive("ahk_class SciTEWindow")) {
            sendKeys((up ? "+" :"") "F3")
        } else if (WinExist("- YouTube - ahk_id " id)) {
            ; TODO return focus after sendkeys.
            ; also make this default behavior
            mult := GetKeyState("Ctrl") ? 5 : 1
            sendKeys("{" (up ? "left" : "right") " " mult "}", id)
            ; OSD("scroll yT")
            ; sendKeys("{" (up ? "left" : "right") " " mult "}")            
        } else if (WinExist("Hanab Live ahk_id " id) || WinExist("- YouTube - ahk_id " id) || WinExist("ahk_exe vlc.exe ahk_id " id) 
                   || WinExist("Netflix - ahk_id " id) || WinExist("- Chess.com ahk_id " id) || WinExist("ichess ahk_id " id)
                   || WinExist("ahk_class MozillaWindowClass ahk_id " id)) {
        ; } else if (WinActive("Hanab Live") || WinActive("- YouTube -") || WinActive("ahk_exe vlc.exe") 
        ;            || WinActive("Netflix -") || WinActive("- Chess.com") || WinActive("ichess")
        ;            || WinActive("ahk_class MozillaWindowClass")) {
            mult := GetKeyState("Ctrl") ? 5 : 1
            ; OSD("scroll")
            sendKeys("{" (up ? "left" : "right") " " mult "}", id)
        } else if (WinExist("ahk_class Chrome_WidgetWin_1")) {
            sendKeys((up ? "+" :"") "^g", id)
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
        NavigateTabs(up)
    }
return

#IfWinActive, Pics @
[::Send, {WheelUp}
]::Send, {WheelDown}
#IfWinActive
![::NavigateTabs(1)
!]::NavigateTabs(0)

NavigateTabs(up:=0) {
    if (WinActive("ahk_class SciTEWindow") || WinActive("ahk_class PX_WINDOW_CLASS")) {
        sendKeys("^" (up ? "{PgUp}" : "{PgDn}"))
    } else if (WinActive("ahk_exe Code.exe") || WinActive("ahk_exe brave.exe")) {
        sendKeys("^" (up ? "{PgUp}" : "{PgDn}"))
    } else if (WinActive("ahk_class ShImgVw:CPreviewWnd")) {
        sendKeys(up ? "{Left}" : "{Right}")
    } else {
        sendKeys((up ? "+" :"") "^{tab}")
    }
}

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
