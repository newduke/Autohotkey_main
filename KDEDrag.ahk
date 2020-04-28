
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
/*
If A_AhkVersion < 1.0.25.07
{
	MsgBox,20,,This script may not work properly with your version of AutoHotkey. Continue?
	IfMsgBox,No
	ExitApp
}

; This is the setting that runs smoothest on my
; system. Depending on your video card and cpu
; power, you may want to raise or lower this value.
SetWinDelay,2

CoordMode,Mouse
return
*/

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
#If !DoubleAlt and !WinActive("ahk_class MultitaskingViewFrame")

Alt & LButton::
KSM := KeyStates()
if (KSM != "!" or WinActive("ahk_class MultitaskingViewFrame"))
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
If (KDE_X1 < KDE_WinX1 + KDE_WinW / 2)
	KDE_WinLeft := true
Else
	KDE_WinLeft := false
If (KDE_Y1 < KDE_WinY1 + KDE_WinH / 2)
	KDE_WinUp := true
Else
	KDE_WinUp := false
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
	If KDE_WinLeft
	{
		; Reverse and apply the offset to the size, and correct for the skewed position.
		KDE_WinX1 += KDE_X2
		KDE_WinW -= KDE_X2
	}
	Else
		KDE_WinW += KDE_X2 ; Apply the offset to the size.
	If KDE_WinUp
	{
		; Reverse and apply, correct the position.
		KDE_WinY1 += KDE_Y2
		KDE_WinH -= KDE_Y2
	}
	Else
		KDE_WinH += KDE_Y2 ; Apply the offset.
	; Finally, apply all the changes to the window.
	WinMove,ahk_id %KDE_id%,,%KDE_WinX1%,%KDE_WinY1%,%KDE_WinW%,%KDE_WinH%
	KDE_X1 := (KDE_X2 + KDE_X1) ; Reset the initial position for the next iteration.
	KDE_Y1 := (KDE_Y2 + KDE_Y1)
	ToolTip, ( %KDE_WinX1% `, %KDE_WinY1% ) x ( %KDE_WinW% `, %KDE_WinH% )
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
	;WinSet,Bottom,,Program Manager
return

Alt & WheelDown::AltTab
Alt & WheelUp::ShiftAltTab
#If

; This code detects "double-clicks" of
; the Alt key.
~Alt::
	DoubleAlt := False ; Re-initialize DoubleAlt.
	; Uncomment this line if you still want to use the Alt key to activate a program's 
	; menu bar. Note that even without this enabled, menu shortcuts such as Alt+F will
	; still operate correctly:
	;  Send,{Alt} 
	KeyWait,Alt,D T0.6 ; ... and the next press.
	If Errorlevel ; If it never comes or takes too long, DoubleAlt remains false.
		return
	DoubleAlt := True ; Otherwise, it's true until Alt is released (activating this hotkey again).
	KeyWait,Alt,U T20 ; ... and the next press.
	DoubleAlt := False ; reset DoubleAlt when Alt is release (or times out)
return
