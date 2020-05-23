/*
  Lex' Mouse Gestures
  by Lexikos (Steve Gray)
*/

#Include GesturesS.ahk
return


/*
 * Scripted gestures
 */
 
#Include %A_ScriptDir%              ; Set working directory for #Include.
#Include *i Gestures_User.ahk       ; User-defined gestures, etc.
#Include *i Gestures_Default.ahk    ; Default gestures.


/*
 * Tray menu subroutines
 */

TrayMenu_Open:
    DetectHiddenWindows, On
    Process, Exist
    PostMessage, 0x111, 65300,,, ahk_class AutoHotkey ahk_pid %ErrorLevel%
return
TrayMenu_Help:
    MsgBox, Sorry, feature not implemented!
return
TrayMenu_Reload:
    Reload
return
TrayMenu_Debug:
    ListLines
return
TrayMenu_Suspend:
    gosub ToggleGestureSuspend
return
TrayMenu_Edit:
    G_EditFile(A_ScriptDir "\" RegExReplace(A_ThisMenuItem,"^Edit |&"))
return
TrayMenu_Exit:
ExitApp


/*
 * Gesture recognition and hotkeys
 */

ToggleGestureSuspend:
    Suspend, Toggle
    G_SetTrayIcon(!A_IsSuspended)
    if A_IsSuspended {
        Menu, Tray, Check, &Suspend
        SoundPlay, %m_DisabledSound%
    } else {
        Menu, Tray, Uncheck, &Suspend
        SoundPlay, %m_EnabledSound%
    }
return


CancelGesture:
    Hotkey, *Escape, CancelGesture, Off
    m_ExitLoop := true
return

GestureKey_Up:
    Hotkey, %A_ThisHotkey%, Off
    MouseGetPos, m_EndX, m_EndY
    G_ExitGesture()
    if m_PassKeyUp
    {
        Send {Blind}{%m_LastGestureKey% Up}
        m_PassKeyUp := false
    }
    if (m_CustomKeyUp)
    {
        G_Execute("m_CustomKeyUp")
        m_CustomKeyUp := ""
    }
return

GestureKey_Down:

    if m_WaitForRelease && m_LastGestureKey ; Key pressed while loop was running for the other key.
        return
    Thread, NoTimers  ; Disable keyless timer for the duration of this subroutine.
    
    m_LastGestureKey := A_ThisHotkey
    Hotkey, *%m_LastGestureKey% Up, GestureKey_Up, On
    Hotkey, *Escape, CancelGesture, On
    if (%m_GesturePrefix%_WheelUp!="" || IsLabel(m_GesturePrefix "_WheelUp"))
        Hotkey, *WheelUp, GestureWheelUp, On
    if (%m_GesturePrefix%_WheelDown!="" || IsLabel(m_GesturePrefix "_WheelDown"))
        Hotkey, *WheelDown, GestureWheelDown, On
    if (%m_GesturePrefix%_LButton!="" || IsLabel(m_GesturePrefix "_LButton"))
        Hotkey, *LButton, GestureLButton, On
    if (%m_GesturePrefix%_MButton!="" || IsLabel(m_GesturePrefix "_MButton"))
        Hotkey, *MButton, GestureMButton, On
    if (%m_GesturePrefix%_RButton!="" || IsLabel(m_GesturePrefix "_RButton"))
        Hotkey, *RButton, GestureRButton, On

GestureKeyless:
    ; If the keyless timer started this thread, the gesture loop mustn't be active since
    ; a) the keyed entry-point above disables timers and b) no timer can execute its
    ; subroutine again until the previous instance returns.  We don't want to register
    ; any hotkeys since they wouldn't work intuitively with the keyless method.
    
    ; Increase interval between message checks so that any interruption will happen during
    ; 'Sleep' rather than at any random point.  Interruption happens if a keyless loop
    ; is running when the user presses a gesture key; when it happens, we want to recognize
    ; the "explicit" gesture and exit the keyless loop's thread as soon as it resumes.
    ; This must be done because of the use of global variables in the gesture loop.
    if A_ThisLabel=GestureKeyless
    {
        Critical % 100+m_Interval  ; Add m_Interval in case it is reasonably high/long.
        m_LastGestureKey := ""
    }
    
    m_WaitForRelease := true    ; Legacy naming: true while running the loop (even if its not really waiting for key-up).
    m_ExitLoop := false         ; Only overridden by scrolling/pressing Escape.
    m_ScrolledWheel := false    ;
    beginTimeout := A_TickCount
    startX := -1
    startY := -1
    totalDistance := 0
    lastZone := -1

    m_Gesture := ""
    m_GestureLength := 0

    ; get starting mouse position
    MouseGetPos, lastX, lastY

    ; record for later use
    m_EndX := m_StartX := lastX
    m_EndY := m_StartY := lastY
    
    if hdc_canvas && m_LastGestureKey
    {
        SysGet, XVirtualScreen, 76
        SysGet, YVirtualScreen, 77
        SysGet, CXVirtualScreen, 78
        SysGet, CYVirtualScreen, 79
        ; Set origin to top-left of primary screen (since mouse co-ords are relative to this).
        DllCall("SetViewportOrgEx", "uint", hdc_canvas, "int", -XVirtualScreen, "int", -YVirtualScreen, "uint", 0)
        ; Show the trail canvas over the entire virtual screen (all monitors).
        Gui, Show, X-30000 Y-30000 W%CXVirtualScreen% H%CYVirtualScreen% NA
        ; Showing the Gui initially off-screen may help reduce "screen flash".
        Gui, Show, X%XVirtualScreen% Y%YVirtualScreen% NA
        ; Set the initial position, where the first line will begin.
        DllCall("MoveToEx", "uint", hdc_canvas, "int", m_StartX, "int", m_StartY, "uint", 0)
    }
    
    Loop
    {
        ; Logic below requires that only keyless mode enables 'Critical'.
        if (A_ThisLabel="GestureKeyless" && m_wasCritical := A_IsCritical)
                Critical Off ; Allow interruption temporarily.
        
        ; wait for mouse to move
        Sleep, m_Interval
        
        if (A_ThisLabel="GestureKeyless" && m_wasCritical)
        {   ; If a gesture key was pressed, the globals this instance was using
            ; have probably been overwritten, so just break out of the loop.
            if m_LastGestureKey
                return
            Critical %m_wasCritical%
        }

        if m_ExitLoop
        {
            if m_ScrolledWheel
                KeyWait, %m_LastGestureKey%
            G_ExitGesture()
            return
        }

        if !m_WaitForRelease
        { ; use location mouse was released at
            x := m_EndX
            y := m_EndY
        }
        else ; get current mouse position
            MouseGetPos, x, y

        offsetX := x - lastX
        offsetY := y - lastY

        ; Check if mouse has moved.
        if (offsetX!=0 || offsetY!=0)
        {
            if hdc_canvas
                ; Draw a line to the current mouse position, from the starting position or end of the previous line.
                DllCall("LineTo", "uint", hdc_canvas, "int", x, "int", y)
            
            ; Calculate distance and angle from origin.
            ; Note origin changes only when a new stroke is detected, so distance will continue
            ; to increase while the mouse contiues to move in the same approximate direction.
            distance := Sqrt(offsetX*offsetX + offsetY*offsetY)

            if (distance > m_LowThreshold)
            {
                angle := G_GetAngle(offsetX, offsetY)

                lastX := x
                lastY := y
                
                ; Allow the initial stroke to be more or less specific than subsequent strokes,
                ; ensuring the initial stroke can be extended according to m_InitialZoneCount.
                if ( m_GestureLength = 0
                  || m_GestureLength = 1 && G_GetZone(angle, m_InitialZoneCount, m_Tolerance) = lastZone )
                     zoneCount := m_InitialZoneCount
                else zoneCount := m_ZoneCount
                
                zone := G_GetZone(angle, zoneCount, m_Tolerance)

                if zone =
                {
                    ; Error, or gesture stroke exceeded zone tolerance (m_Tolerance).
                    if !m_DisableDing
                        SoundPlay, *-1
                    G_ExitGesture()
                    return
                }
                
                if (lastZone != zone)
                {
                    if (hdc_canvas && m_NodePenWidth && lastZone != zone && lastZone != -1)
                        DllCall( "Ellipse", "uint", hdc_canvas
                                    , "int", lastZoneEndX-m_NodePenWidth
                                    , "int", lastZoneEndY-m_NodePenWidth
                                    , "int", lastZoneEndX+m_NodePenWidth
                                    , "int", lastZoneEndY+m_NodePenWidth )

                    ; Record length of this stroke.
                    totalDistance := distance

                    ; Remember zone index for subsequent iterations.
                    lastZone := zone
                    
                    ; Record this stroke.
                    m_Gesture .= m_Delimiter . zone
                    m_GestureLength += 1
                }
                else
                {
                    ; Extend length of this stroke.
                    totalDistance += distance
                }
                ; Reset timeout.
                beginTimeout := A_TickCount
                
                lastZoneEndX := x
                lastZoneEndY := y

                if (m_HighThreshold > 0 && totalDistance > m_HighThreshold)
                {
                    ; Gesture stroke exceeded maximum stroke length (m_HighThreshold).
                    if !m_DisableDing
                        SoundPlay, *-1
                    G_ExitGesture()
                    Sleep, 150
                    if !m_DisableDing
                        SoundPlay, *-1
                    return
                }
            }
        }

        timeout := m_Gesture="" ? m_InitialTimeout : m_ActiveTimeout
        
        if (timeout && A_TickCount-beginTimeout > timeout)
        {
            ; Timed out.
            if (m_Gesture!="" && (m_ActiveTimeoutMode=2 || !m_LastGestureKey))
            {
                ; Complete gesture. Circumvent m_Timeout.
                beginTimeout := A_TickCount
                m_WaitForRelease := false
                break
            }
            if !m_DisableDing && m_LastGestureKey
                SoundPlay, *64
            ; G_ExitGesture attempts default function of gesture key if the first parameter is true.
            G_ExitGesture(m_Gesture="" || m_ActiveTimeoutMode=1)
            return
        }

        ; End loop when gesture key is released.
        if !m_WaitForRelease
            break
    }

    ; Cancel gesture if the mouse was immobile for too long after the last stroke.
    if (m_Timeout && A_TickCount-beginTimeout > m_Timeout)
    {
        ; Gesture timed out.
        if !m_DisableDing && m_LastGestureKey
            SoundPlay, *64
        G_ExitGesture(m_DefaultOnTimeout && m_LastGestureKey)
        return
    }

    if m_Gesture !=
    {
        if !G_PerformAction(m_Gesture) && !m_DisableDing && m_LastGestureKey
            SoundPlay, *48
    }
    else
        G_ExitGesture(true)
    
return

GestureWheelUp:
GestureWheelDown:
GestureLButton:
GestureMButton:
GestureRButton:
    m_ExitLoop := true
    gosub gCleanUp
    G_PerformAction(m_Delimiter . SubStr(A_ThisLabel,8), m_gesture)
    m_ScrolledWheel := true
return

G_Execute(action)
{
    if IsLabel(action)
        gosub % action
    else if %action% !=
        Send % %action%
    else
        return false
    return true
}

G_PerformAction(action_name, other_action = "")
{
    local action, params, final_name
        , list := m_LastGestureKey ? m_GesturePrefix ",Default" : m_KeylessPrefix
    if other_action !=
        list := list "," m_GesturePrefix . other_action
        
    Loop, Parse, list, `,
    {
        final_name = %A_LoopField%%action_name%
        
        if not G_Execute(final_name)
            continue
        
        ; Tell the user what just happened
        final_executed = %A_LoopField%Name%action_name%
        if %final_executed% !=
        {
            G_ToolTip(%final_executed%)
        }
        
        if m_DelayedAction !=
        {
            Hotkey, Escape, gCancelAction, On
            m_canceled = false
            SetTimer, gDelayedAction, 3000
        }

        return true
    }
    return false
}
return

gDelayedAction:
    Hotkey, Escape, gCancelAction, Off
    SetTimer, gDelayedAction, Off

    if m_DelayedAction =
        return
    
    if m_canceled = true
    {
        G_ToolTip("Canceled")
    } 
    else 
    {
        gosub %m_DelayedAction%
        ;DllCall("PowrProf\SetSuspendState", "int", 0, "int", 1, "int", 0)
    }
    m_canceled = false
    m_DelayedAction =
return

gCancelAction:
    Hotkey, Escape, gCancelAction, Off
    m_canceled = true
    gosub gDelayedAction
return

G_ToolTip(tip)
{
    ToolTip %tip%
    SetTimer, gRemoveToolTip, -500
}

gRemoveToolTip:
    ToolTip
return

gCleanUp:
    if hdc_canvas  ; Hide the mouse-trail canvas.
    {
        if m_TransTrail
        {
            ; Clear the canvas before hiding it. Otherwise, the next time the window is shown,
            ; the previous gesture can be shown for a brief moment before the window updates.
            VarSetCapacity(rect, 16, 0)
            NumPut(CYVirtualScreen + YVirtualScreen, NumPut(CXVirtualScreen + XVirtualScreen
                , NumPut(YVirtualScreen, NumPut(XVirtualScreen, rect, 0))))
            DllCall("FillRect", "uint", hdc_canvas, "int", &rect, "uint", brush)
        }
        Gui, Hide
    }
return

G_ExitGesture(sendkey=false)
{
    local btn
    
    Hotkey, *Escape, CancelGesture, Off
    Hotkey, *WheelUp, GestureWheelUp, Off
    Hotkey, *WheelDown, GestureWheelDown, Off
    Hotkey, *LButton, GestureLButton, Off
    Hotkey, *MButton, GestureMButton, Off
    Hotkey, *RButton, GestureRButton, Off
    
    gosub gCleanUp
    
    if !(sendkey && m_LastGestureKey)
    {
        m_WaitForRelease := false
        return
    }
    
    if m_LastGestureKey in LButton,MButton,RButton
    {
        ; Try to leave mouse button functionality intact.
        StringLeft, btn, m_LastGestureKey, 1
        if m_WaitForRelease
            MouseGetPos, m_EndX, m_EndY
        ; Move to point where gesture started, then press and hold button.
        MouseClick, %btn%, m_StartX, m_StartY,, 1, D
        ; Move back into place. Release if button has been physically released.
        if m_WaitForRelease
            MouseMove, m_EndX, m_EndY
        else
            MouseClick, %btn%, m_EndX, m_EndY,,, U
    }
    else
    {
        if m_WaitForRelease
            Send {Blind}{%m_LastGestureKey% Down}
        else
            Send {Blind}{%m_LastGestureKey%}
    }
    ; Pass through gesture button release to active window if applicable.
    m_PassKeyUp := m_WaitForRelease
    m_WaitForRelease := false

}

; Get angle (in degrees) of {x,y} relative to {0,0} -> {1,0}.
G_GetAngle(x, y)
{
    if (x != 0) {
        deg := ATan(y/x) * 57.295779513082323 ; deg := rad * 180/PI
        if x < 0
            return deg + 180
        else ; x > 0
            if y < 0
                return deg + 360
        ; x > 0 && y >= 0
        return deg
    } else ; x = 0
        if y > 0
            return 90.0
        else if y < 0
            return 270.0 ;-90
        ; else no return value.
}

; Get the zone of an angle
;  angle:       Angle in degrees, between 0.0 and 360.0 inclusive.
;  zoneCount:   Number of zones.
;  tolerance:   Allowed deviance from centre of zone.
;               If positive, specifies percentage of zone (between 1 and 100).
;               If negative, absolute value specifies tolerance in degrees.
G_GetZone(angle, zoneCount, tolerance)
{
    local degPerZone
    local zone

    if zoneCount < 2
        return ; ERROR.

    ; Calculate zone size.
    degPerZone := 360/zoneCount

    ; Calculate nearest zone integer.
    zone := Mod(Round(angle/degPerZone),zoneCount)

    ; Calculate tolerance.
    if tolerance < 0
        tolerance := Abs(tolerance)                 ; -n : must not exceed n degrees.
    else
        tolerance := degPerZone/2 * tolerance/100   ; n : must not exceed n percent.

    if (zone = 0 && angle > 180)
        angle -= 360

    ; Check if within tolerated distance from centre of zone.
    if (Abs(angle-(zone*degPerZone)) > tolerance)
        return

    ; Resolve to text form if available.
    if c_Zone%zoneCount%_%zone% !=
        return c_Zone%zoneCount%_%zone%

    return zone
}


/*
 * Tray icon maintenance
 */

G_SetTrayIcon(is_enabled)
{
    local icon := is_enabled ? m_EnabledIcon : m_DisabledIcon
    if icon !=
    {
        ifExist, %icon%
                Menu, Tray, Icon, %icon%,, 1
        else    Menu, Tray, Icon, *
        Menu, Tray, Icon
    }
    else
        Menu, Tray, NoIcon
    %m_OnUpdateIcon%(icon, is_enabled)
}

WM_COMMAND(wParam, lParam, msg, hwnd)
{
    static IsPaused, IsSuspended
    Critical
    id := wParam & 0xFFFF
    if id in 65305,65404,65306,65403
    {  ; "Suspend Hotkeys" or "Pause Script" - either A_IsPaused or A_IsSuspended is about to be toggled.
        if id in 65306,65403
            IsPaused := ! A_IsPaused
        else
            IsSuspended := ! A_IsSuspended
        G_SetTrayIcon(!(IsPaused or IsSuspended))
    }
}

/*
 * Helper functions
 */

G_EditFile(file)
{
    ;Run "C:\Program Files\AutoHotkey\SciTE\SciTE.exe" %file%,, UseErrorLevel
    ;Run "C:\Program Files\Sublime Text 2\Sublime 4 AutoHotkey.exe" %file%,, UseErrorLevel
    Run %A_Editor% %file%,, UseErrorLevel
    ;MsgBox %A_Editor%
    if ErrorLevel = ERROR
        Run, notepad "%file%"
}

G_MinimizeActiveWindow()
{
    global
    ifWinActive, ahk_group CloseBlacklist
        return
    lastMinTime := A_TickCount
    lastMinID   := WinExist("A")
    ifWinActive, ahk_group MinHidelist
    {
        WinMinimize
        WinHide
    }
    else
        PostMessage, 0x112, 0xF020
    ; unlike WinMinimize, using WM_SYSCOMMAND, SC_MINIMIZE
    ; causes the system-wide "Minimize" sound to be played
}

G_GetLastMinimizedWindow()
{
    WinGet, w, List

    Loop %w%
    {
        wi := w%A_Index%
        WinGet, m, MinMax, ahk_id %wi%
        if m = -1 ; minimized
        {
            lastFound := wi
            break
        }
    }

    return "ahk_id " . (lastFound ? lastFound : 0)
}

G_ControlExist(Control, WinTitle="")
{
    ControlGet, temp, HWND, , %Control%, %WinTitle%
    return temp
}
