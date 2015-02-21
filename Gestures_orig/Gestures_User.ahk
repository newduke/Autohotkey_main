Gestures:

/*
 * Gestures
 */

; Wheel:        Switch between tabs.
; see below
;~ Gesture_WheelUp = ^+{Tab}
;~ Gesture_WheelDown = ^{Tab}

; Up:           Launch My Computer (usually).
Gesture_U = {Launch_App1}

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
Gesture_U_R = {Media_Next}
Gesture_U_D = {Media_Play_Pause}
Gesture_U_D_U = {Media_Stop}
Gesture_U_L_R = {Launch_Media}

;~ Gesture_D_L = ^{F4}

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

;~ Gesture_U_D_U:
    ;~ gosub ActivateMedia
;~ return

; S-shape:      Sleep
Gesture_L_D_R_D_L:
    m_DelayedAction = DoSleep
return

DoSleep:
    DllCall("PowrProf\SetSuspendState", "int", 0, "int", 1, "int", 0)
return

Gesture_D_L:
    MouseGetPos,,,KDE_id
    WinMinimize, ahk_id %KDE_id%
return

Gesture_R_U:
    MouseGetPos,,,KDE_id
    WinGet,KDE_Win,MinMax,ahk_id %KDE_id%
    If KDE_Win
    WinRestore,ahk_id %KDE_id%
    Else
    WinMaximize,ahk_id %KDE_id%
return

Gesture_RButton:
    ;G_MinimizeActiveWindow()
    Send, ^c
return

Gesture_MButton:
    send, ^{f4}
return

Gesture_LButton:
    ;Send, {alt down}{tab}{alt up}
    Click
    Send, ^v
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
        Send {Volume_Up}
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
    XButton2&WheelUp:
    if m_ScrolledWheel = 0
    {
        MouseGetPos,,,KDE_id
        WinActivate, ahk_id %KDE_id%
    }
    if WinActive("ahk_class SciTEWindow")
        Send ^{PgUp}
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
        Send {Volume_Down}
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
    XButton2&WheelDown:
    if m_ScrolledWheel = 0
    {
        MouseGetPos,,,KDE_id
        WinActivate, ahk_id %KDE_id%
    }
    if WinActive("ahk_class SciTEWindow")
        Send ^{PgDn}
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
#If