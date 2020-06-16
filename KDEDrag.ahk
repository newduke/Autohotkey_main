

; This script was inspired by and built on many like it
; in the forum. Thanks go out to ck, thinkstorm, Chris,
; and aurelian for a job well done.


; The Double-Alt modifier is activated by pressing
; Alt twice, much like a double-click. Hold the second
; press down until you click.
;
; The shortcuts:
;  Alt + Left Button  : Drag to move a window.
;  Alt + Right Button : Drag to resize a window.
;  Double-Alt + Left Button   : Minimize a window.
;  Double-Alt + Right Button  : Maximize/Restore a window.
;  Double-Alt + Middle Button : Close a window.
;
; You can optionally release Alt after the first
; click rather than holding it down the whole time.

; TODO: fix conflict with RButton and DragToScroll

DoubleAlt := False ; Re-initialize DoubleAlt.

; from key states, concat the corresponding AHK modifiers, + ^ !,
; e.g., shiftstate=altstate=D ==> KSM = +!
KeyStates() 
{
	GetKeyState, shiftstate, Shift
	GetKeyState, ctrlstate, Ctrl
	GetKeyState, altstate, Alt
	KSM = 
	if shiftstate = D
		KSM = +
	if ctrlstate = D
		KSM = %KSM%^
	if altstate = D
		KSM = %KSM%!
	return KSM
}

; I decided I liked being able to alt + click, so I use double-alt + click to access native
; alt + click behavior.
#If !DoubleAlt and !WinActive("ahk_class MultitaskingViewFrame") and !tildeHeld

Alt & LButton::
KSM := KeyStates()
if (KSM != "!" or WinActive("ahk_class MultitaskingViewFrame") or tildeHeld)
{
	; fake the action
	MouseClick, Left,,,,,D
	return
}
If DoubleAlt
{
	MouseGetPos,,,KDE_id
	; This message is mostly equivalent to WinMinimize,f
	; but it avoids a bug with PSPad.
	PostMessage,0x112,0xf020,,,ahk_id %KDE_id%
	DoubleAlt := false
	return
}
; Get the initial mouse position and window id, and
; abort if the window is maximized.
MouseGetPos,KDE_X1,KDE_Y1,KDE_id
WinGet,KDE_Win,MinMax,ahk_id %KDE_id%
If KDE_Win
	return
; Get the initial window position.
WinGetPos,KDE_WinX1,KDE_WinY1,,,ahk_id %KDE_id%
Loop
{
	GetKeyState,KDE_Button,LButton,P ; Break if LButton has been released.
	If KDE_Button = U
		break
	MouseGetPos,KDE_X2,KDE_Y2 ; Get the current mouse position.
	KDE_X2 -= KDE_X1 ; Obtain an offset from the initial mouse position.
	KDE_Y2 -= KDE_Y1
	KDE_WinX2 := (KDE_WinX1 + KDE_X2) ; Apply this offset to the window position.
	KDE_WinY2 := (KDE_WinY1 + KDE_Y2)
	WinMove,ahk_id %KDE_id%,,%KDE_WinX2%,%KDE_WinY2% ; Move the window to the new position.
	;ToolTip, ( %KDE_WinX2% `, %KDE_WinY2% )
}
ToolTip
return

Alt & RButton::
If DoubleAlt
{
	MouseGetPos,,,KDE_id
	; Toggle between maximized and restored state.
	WinGet,KDE_Win,MinMax,ahk_id %KDE_id%
	If KDE_Win
		WinRestore,ahk_id %KDE_id%
	Else
		WinMaximize,ahk_id %KDE_id%
	DoubleAlt := false
	return
}
; Get the initial mouse position and window id, and
; abort if the window is maximized.
MouseGetPos,KDE_X1,KDE_Y1,KDE_id
WinGet,KDE_Win,MinMax,ahk_id %KDE_id%
If KDE_Win
	return
; Get the initial window position and size.
WinGetPos,KDE_WinX1,KDE_WinY1,KDE_WinW,KDE_WinH,ahk_id %KDE_id%
; Define the window region the mouse is currently in.
; The four regions are Up and Left, Up and Right, Down and Left, Down and Right.
KDE_ZoneX := 0
if (KDE_X1 < KDE_WinX1 + KDE_WinW / 3)
	KDE_ZoneX := -1
else if (KDE_X1 > KDE_WinX1 + 2 * KDE_WinW / 3)
	KDE_ZoneX := 1
KDE_ZoneY := 0
if (KDE_Y1 < KDE_WinY1 + KDE_WinH / 3)
	KDE_ZoneY := -1
else if (KDE_Y1 > KDE_WinY1 + 2 * KDE_WinH / 3)
	KDE_ZoneY := 1
if (KDE_ZoneX = 0 and KDE_ZoneY = 0) {
	KDE_OrigWinW := KDE_WinW
	KDE_OrigWinH := KDE_WinH
	KDE_OrigWinX1 := KDE_WinX1
	KDE_OrigWinY1 := KDE_WinY1
}

Loop
{
	GetKeyState,KDE_Button,RButton,P ; Break if LButton has been released.
	If KDE_Button = U
		break
	MouseGetPos,KDE_X2,KDE_Y2 ; Get the current mouse position.
	; Get the current window position and size.
	WinGetPos,KDE_WinX1,KDE_WinY1,KDE_WinW,KDE_WinH,ahk_id %KDE_id%
	KDE_X2 -= KDE_X1 ; Obtain an offset from the initial mouse position.
	KDE_Y2 -= KDE_Y1
	; Then, act according to the defined region.
	If (KDE_ZoneX = -1)
	{
		; Reverse and apply the offset to the size, and correct for the skewed position.
		KDE_WinX1 += KDE_X2
		KDE_WinW -= KDE_X2
	}
	Else If (KDE_ZoneX = 1)
		KDE_WinW += KDE_X2 ; Apply the offset to the size.
	If (KDE_ZoneY = -1)
	{
		; Reverse and apply, correct the position.
		KDE_WinY1 += KDE_Y2
		KDE_WinH -= KDE_Y2
	}
	Else If (KDE_ZoneY = 1)
		KDE_WinH += KDE_Y2 ; Apply the offset.
	
	; For center zone, resize to special zones (corners, sides)
	if (KDE_ZoneX = 0 and KDE_ZoneY = 0) {
		CurrentMon := 0
		Loop {
			CurrentMon := CurrentMon + 1
			SysGet, Monitor, MonitorWorkArea, %CurrentMon%
			if (MonitorLeft = "")
				break
			if (KDE_X1 >= MonitorLeft and KDE_X1 <= MonitorRight and KDE_Y1 >= MonitorTop and KDE_Y1 <= MonitorBottom) {
				break
			}
		}
		KDE_WinX1 := MonitorLeft
		KDE_WinX2 := MonitorRight
		KDE_WinY1 := MonitorTop
		KDE_WinY2 := MonitorBottom
		CenterX := KDE_WinX1 + (KDE_WinX2 - KDE_WinX1)*.5
		CenterY := KDE_WinY1 + (KDE_WinY2 - KDE_WinY1)*.5
		Sensitivity := 50
		if (KDE_X2 > Sensitivity) {
			KDE_WinX1 := CenterX
		} else if (KDE_X2 < -Sensitivity) {
			KDE_WinX2 := CenterX
		}
		if (KDE_Y2 > Sensitivity) {
			KDE_WinY1 := CenterY
		} else if (KDE_Y2 < -Sensitivity) {
			KDE_WinY2 := CenterY
		}
		if (KDE_X2 < Sensitivity and KDE_X2 > -Sensitivity and KDE_Y2 < Sensitivity and KDE_Y2 > -Sensitivity) {
			KDE_WinX1 := KDE_OrigWinX1
			KDE_WinY1 := KDE_OrigWinY1
			KDE_WinX2 := KDE_OrigWinX1 + KDE_OrigWinW
			KDE_WinY2 := KDE_OrigWinY1 + KDE_OrigWinH
		}
		WinMove,ahk_id %KDE_id%,,%KDE_WinX1%,%KDE_WinY1%,KDE_WinX2 - KDE_WinX1,(KDE_WinY2 - KDE_WinY1)
	} else {
		; Finally, apply all the changes to the window.
		WinMove,ahk_id %KDE_id%,,%KDE_WinX1%,%KDE_WinY1%,%KDE_WinW%,%KDE_WinH%
		KDE_X1 := (KDE_X2 + KDE_X1) ; Reset the initial position for the next iteration.
		KDE_Y1 := (KDE_Y2 + KDE_Y1)
		ToolTip, ( %KDE_WinX1% `, %KDE_WinY1% ) x ( %KDE_WinW% `, %KDE_WinH% )
	}
}
ToolTip
return

; "Alt + MButton" may be simpler, but I
; like an extra measure of security for
; an operation like this.
Alt & MButton::
	If DoubleAlt
	{
		MouseGetPos,,,KDE_id
		WinClose,ahk_id %KDE_id%
		DoubleAlt := false
		return
	}
	MouseGetPos,,,KDE_id
	WinSet,Bottom,,ahk_id %KDE_id%
return

Alt & WheelDown::AltTab
Alt & WheelUp::ShiftAltTab
#If

; Don't activate drag if tilde is held. This allows for faster alt-clicking as well as protects the script from 
; my alt-~ binding for discord push-to-talk.
*~`::
	tildeHeld:=1
return
*~` up::
	tildeHeld:=0
return
; This code detects "double-clicks" of
; the Alt key.
~Alt::
	DoubleAlt := False ; Re-initialize DoubleAlt.
	; Uncomment this line if you still want to use the Alt key to activate a program's 
	; menu bar. Note that even without this enabled, menu shortcuts such as Alt+F will
	; still operate correctly:
	;  Send,{Alt} 
	KeyWait,Alt,D T0.3 ; ... and the next press.
	If Errorlevel ; If it never comes or takes too long, DoubleAlt remains false.
		return
	DoubleAlt := True ; Otherwise, it's true until Alt is released (activating this hotkey again).
	; Double-click Alt to bring mouse window to top.
	MouseGetPos,,,KDE_id
	WinSet,AlwaysOnTop ,Toggle ,ahk_id %KDE_id%
	WinSet,AlwaysOnTop ,Toggle ,ahk_id %KDE_id%
	KeyWait,Alt,U T20 ; ... and the next press.
	DoubleAlt := False ; reset DoubleAlt when Alt is release (or times out)
return
