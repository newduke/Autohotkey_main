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
Gesture_L_D_R = ^x
Gesture_L_U_R = ^c
Gesture_U_R_D = ^v

; Left, Up:     Go up one level in explorer.
Gesture_L_U = !{Up}

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

; Hold XButton1 to show the Alt+Tab dialog.  Release to switch applications.
; With the Aero task-switcher, one can also click the thumbnail to switch.
*XButton1::
    if m_WaitForRelease ; Holding gesture button.
    {
        m_ScrolledWheel := true
        m_ExitLoop := true
        Send {Media_Next}
        return
    }
    Send {Blind}{Alt Down}{Tab}
    MouseGetPos, x, y
    if (x < 0) ; Put it on the appropriate monitor, assumes only two monitors,
    {          ; where the secondary monitor is to the left of the primary.
        WinWait, ahk_class TaskSwitcherWnd,, 0.2
        if !ErrorLevel
        {
            SysGet, Mon2, MonitorWorkArea, 1
            WinGetPos, x, y, w, h
            x := Mon2Left+(Mon2Right-Mon2Left-w)//2
            y := Mon2Top+(Mon2Bottom-Mon2Top-h)//2
            WinMove, x, y
            ifWinExist, ahk_class TaskSwitcherOverlayWnd
                WinMove, x, y
        }
    }
    KeyWait, XButton1
    Send {Blind}{Alt Up}
*XButton1 Up::
    return

; Allow WheelLeft/Right keybindings.
#IfWinActive ahk_class Valve001 ; HALF-LIFE 2
*WheelLeft::Send, {Blind}-
*WheelRight::Send, {Blind}=
#IfWinActive World of Warcraft ahk_class GxWindowClassD3d
*WheelLeft::Send, {Blind}[
*WheelRight::Send, {Blind}]

#IfWinActive
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
    MouseGetPos,,,KDE_id
    WinGet,KDE_Win,MinMax,ahk_id %KDE_id%

    if (WinActive("ahk_class MozillaWindowClass") or WinActive("ahk_class Chrome_WidgetWin_0")
    or WinActive("ahk_class Chrome_WidgetWin_1") or WinActive("ahk_class QWidget" /* VLC */)) {
        ;if (WinActive("Netflix - ")) {
        ;    Send, {f11}{Esc}f
        ;} else {
            If KDE_Win
                WinRestore,ahk_id %KDE_id%
            Else
                Send, {f11}
        ;}
        return
    } else if (WinActive("ahk_class QWidget")) {
        Send, f
        return
    }

    If KDE_Win
    WinRestore,ahk_id %KDE_id%
    Else
    WinMaximize,ahk_id %KDE_id%
return

Gesture_RButton:
    ;G_MinimizeActiveWindow()
IfWinActive, ahk_class Shell_TrayWnd
{
    WinSet AlwaysOnTop, Toggle, %ActiveWin%
}
else if (0 && WinActive("ahk_class MozillaWindowClass"))
{
    if (instr( Title, "img2tab")) {
        Send, ^{tab}
        return
    }
    Click, Right
    sleep, 1000
    sendinput {up}{up}{right}{up}
    sleep, 1000
    send {enter}
    sendinput ^{pgup}^w^{pgdn}
    ;sendinput {down}

    return

    ; In firefox, open images in tab and move to next tab.
    WinGetTitle, Title, A
    CoordMode, Pixel, Client 
    if (instr( Title, "Pictures linked from")) {
        Send, ^{tab}
        return
    }
    XP := 427
    YP := 89
    
    PixelGetColor, OutputVar, %XP%, %YP%
    DebugTip(OutputVar)
    if (OutputVar != 0x00B800) {
        Sleep, 1
        XP := 425
        YP := 82
        PixelGetColor, OutputVar, %XP%, %YP%
    }
    if (OutputVar = 0x00B800) {
        CoordMode, Mouse, Client
        MouseGetPos, X, Y
        Click %XP%, %YP%
        sleep, 200
        send, ^{tab}
        MouseMove, X, Y, 0
    } else {
        send, ^w
    }
    return
}
else {
    Send, ^c
}
return

Gesture_MButton:
    if m_gesture = _U
    {
        Send {Volume_Mute}
        SoundGet, vol
        G_ToolTip(vol)
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
; ; WIP ---------------------------------------------------------------------
if (0 && WinActive("ahk_class MozillaWindowClass"))
{
    Clipboard =
    Click right
    ;~ sleep 1000
    send, a
    ClipWait, .2
    RealLink := InStr(Clipboard, "http://",false, 3)
    DebugTip(Clipboard . "`r`n" . RealLink)
    sleep 1000
    if (RealLink > 0) {
        RealLink := SubStr(Clipboard, RealLink)
        send, !d^v{Blind}!{enter}^{tab}
    } else {
        ;~ send, {mbutton}
    }
    return
}
;  --------------------------------------------------------------------------
#If
    if m_gesture = _U
    {
        gosub ActivateMedia
        return
    }
    ;Send, {alt down}{tab}{alt up}
    ;Click
    ;Send, ^v
    gosub PasteSpecial
return

; Initiate Alt-tab, wheelup/down continues.
Gesture_R_L:
send, {alt down}{tab}{alt up}
    ;m_gesture = _R
    ;gosub Gesture_WheelDown
return

Gesture_WheelUp:
    ;MsgBox, %m_gesture%
    if m_gesture = _R
    {
        m_CustomKeyUp := "{alt up}"
        send, {alt down}+{tab}
        return
    }
    if m_gesture = _U
    {
        if WinActive("ahk_exe Spotify.exe") 
        {
            Send, ^{up}
            return
        }

        Send {Volume_Up 2}
        Sleep 1
        SoundGet, vol
        G_ToolTip(vol)
        return        
    }
    if m_gesture = _L
    {
        if WinActive("ahk_class SciTEWindow")
            Send, +{F3}
        else if WinActive("ahk_class Chrome_WidgetWin_1")
            Send, +^g
        return        
    }
    if m_gesture = _D
    {
        send, #{pgup}
        return
    }
    XButton2&WheelUp:
    if m_ScrolledWheel = 0
    {
        MouseGetPos,,,KDE_id
        WinActivate, ahk_id %KDE_id%
    }
    if (WinActive("ahk_class SciTEWindow") || WinActive("ahk_class PX_WINDOW_CLASS"))
        Send ^{PgUp}
    else if (WinActive("ahk_exe Code.exe"))
        Send !{Left}
    else if WinActive("ahk_class ShImgVw:CPreviewWnd")
        Send {Left}
    else
        Send ^+{tab}
return

Gesture_WheelDown:
    if m_gesture = _R
    {
        m_CustomKeyUp := "{alt up}"
        send, {alt down}{tab}
        return
    }
    if m_gesture = _U
    {
        if WinActive("ahk_exe Spotify.exe") 
        {
            Send, ^{down}
            return
        }
        Send {Volume_Down 2}
        Sleep 1       
        SoundGet, vol
        G_ToolTip(vol)
        return        
    }
    if m_gesture = _L
    {
        if WinActive("ahk_class SciTEWindow")
            Send, {F3}
        else if WinActive("ahk_class Chrome_WidgetWin_1")
            Send, ^g
        return        
    }
    if m_gesture = _D
    {
        send, #{pgdn}
        return
    }
    XButton2&WheelDown:
    if m_ScrolledWheel = 0
    {
        MouseGetPos,,,KDE_id
        WinActivate, ahk_id %KDE_id%
    }
    if (WinActive("ahk_class SciTEWindow") || WinActive("ahk_class PX_WINDOW_CLASS"))
        Send ^{PgDn}
    else if (WinActive("ahk_exe Code.exe"))
        Send !{Right}
    else if WinActive("ahk_class ShImgVw:CPreviewWnd")
        Send {Right}
    else
        Send ^{tab}
return

XButton2&RButton:
    if WinActive("XP - Microsoft Virtual PC 2007")
        Send {Alt Down} n{Alt Up}
    else
        G_MinimizeActiveWindow()
return

XButton2&MButton:
/*    if WinActive("ahk_group WinCloseGroup")
        WinClose
    else
        Send {Alt Down}{F4}{Alt Up}
        */
    Send ^c
    IfWinActive, ahk_class SciTEWindow
    {
        Sleep, 300
        Send {esc}
    }
return

XButton2&LButton:
/*    if WinActive("ahk_group WinCloseGroup")
        WinClose
    else
        Send {Alt Down}{F4}{Alt Up}
        */
    MouseGetPos, MouseX, MouseY
    MouseClick, Left, MouseX, MouseY
    Send ^v
    
return

; Implement XButton2 as a prefix key while also allowing the
; duration of the press to decide its final (default) effect.
XButton2::
    IfWinActive, ahk_class MozillaWindowClass
    {
	;send,!b
	;sleep, 500
	;send,[right]b{up}{up}{enter}
	CoordMode, Mouse, Window
	MouseGetPos, X, Y
	Click 394,97
    sleep, 200
	send, ^{tab}
	MouseMove, X, Y, 0
    return
}
    if m_WaitForRelease ; Holding gesture button.
    {
        m_ScrolledWheel := true
        m_ExitLoop := true
        KeyWait, XButton2
        Send {Media_Prev}
        return
    }
    Hotkey, WheelUp,   XButton2&WheelUp,   On
    Hotkey, WheelDown, XButton2&WheelDown, On
    Hotkey, LButton,   XButton2&LButton,   On
    Hotkey, RButton,   XButton2&RButton,   On
    Hotkey, MButton,   XButton2&MButton,   On

    XButton2_tick := A_TickCount

    KeyWait, XButton2
    
    if (A_ThisHotkey = "XButton2") {
        short_press := (A_TickCount - XButton2_tick) < 200
        if short_press
            Send ^{Tab}
        else
            Send ^+{Tab}
    } ; else: some other hotkey has fired
        
    Hotkey, WheelUp,   Off
    Hotkey, WheelDown, Off
    Hotkey, LButton,   Off
    Hotkey, RButton,   Off
    Hotkey, MButton,   Off
    
    ; Reapply gesture keys in case they overlap with the above.
    Hotkey, %m_GestureKey%, GestureKey_Down, On
    if m_GestureKey2
        Hotkey, %m_GestureKey2%, GestureKey_Down, On
return

G_Blacklisted()
{
    MouseGetPos,,, MouseWinId
    return WinExist("ahk_group Blacklist ahk_id " MouseWinId)
}
