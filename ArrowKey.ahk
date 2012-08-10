#include ArrowKeyS.ahk
return

HandleCaps:
gosub KeyStates
; ctrl+shift+caps = functional capslock
if KSM = ^!
{
	;^!CapsLock::
	GetKeyState, capsdown, CapsLock, T
	if capsdown = D
		capsdown = Off
	else
		capsdown = On
	SetCapsLockState, %capsdown%
}
CapsHeld := 1
NextPressTime := A_TickCount
DiffTime := NextPressTime
DiffTime -= PressTime
if (DiffTime < 300 || AK_toggle == "On")
{
	CapsHeld := 0
}
PressTime := NextPressTime

; /////// fall through ////////////
;*CapsLock Up::
goto ToggleIt

ScrollLock::
CapsHeld = 0
;Send, {ScrollLock}

ToggleIt:
if AK_toggle = On
	AK_toggle = Off
else
	AK_toggle = On
SetScrollLockState, %AK_toggle%
;Send, {RAlt Up}
hotkey, *u, %AK_toggle%
hotkey, *u up, %AK_toggle%
hotkey, *o, %AK_toggle%
hotkey, *o up, %AK_toggle%
hotkey, *i, %AK_toggle%
hotkey, *i up, %AK_toggle%
hotkey, *j, %AK_toggle%
hotkey, *j up, %AK_toggle%
hotkey, *k, %AK_toggle%
hotkey, *k up, %AK_toggle%
hotkey, *l, %AK_toggle%
hotkey, *l up, %AK_toggle%
hotkey, *;, %AK_toggle%
hotkey, *; up, %AK_toggle%
hotkey, *h, %AK_toggle%
hotkey, *h up, %AK_toggle%
hotkey, *m, %AK_toggle%
hotkey, *m up, %AK_toggle%
hotkey, *`,, %AK_toggle%
hotkey, *`, up, %AK_toggle%

; this loop is necessary at the moment to avoid repeated capslock presses from toggling the script.
; ahk should be able to differentiate between key downs and key repeats
Loop
{
	Sleep, 10
	GetKeyState, state, CapsLock, P
	if state = U  ; The key has been released, so break out of the loop.
		break
	; ... insert here any other actions you want repeated.
}

If CapsHeld
{
	CapsHeld := 0
	goto ToggleIt
}
return

; When should ctrl+{up} send multiple up/down?
; TODO: should let user decide which modifier has this behavior
; TODO: 
AllowMultiarrow() {
	SetTitleMatchMode, 2
	If WinActive("SciTE4AutoHotkey") {
		return true
	}
	return false
}

; get states of modifiers and stuff them into variables shiftstate, ctrlstate, altstate
KeyStates:
GetKeyState, shiftstate, Shift
GetKeyState, ctrlstate, Ctrl
GetKeyState, altstate, Alt
; from key states, concat the corresponding AHK modifiers, + ^ !,
; e.g., shiftstate=altstate=D ==> KSM = +!
KeyStatesFaked:
KSM = 
if shiftstate = D
	KSM = +
if ctrlstate = D
	KSM = %KSM%^
if altstate = D
	KSM = %KSM%!
return

Backspace:
gosub KeyStates
Send, %KSM%{BACKSPACE Down}
return
BackspaceR:
gosub KeyStates
Send, %KSM%{BACKSPACE Up}
return
Home:
gosub KeyStates
Send, %KSM%{HOME Down}
return
HomeR:
gosub KeyStates
Send, %KSM%{HOME Up}
return
End:
gosub KeyStates
Send, %KSM%{END Down}
return
EndR:
gosub KeyStates
Send, %KSM%{END Up}
return
Up:
gosub KeyStates
if (ctrlstate = "D" and AllowMultiarrow())
{
	SetKeyDelay, -1
	ctrlstate = U
	gosub KeyStatesFaked
	Send, %KSM%{UP 6}
} 
else
	Send, %KSM%{UP Down}
return
UpR:
gosub KeyStates
Send, %KSM%{UP Up}
return
Down:
gosub KeyStates
if (ctrlstate = "D" and AllowMultiarrow())
{
	SetKeyDelay, -1
	ctrlstate = U
	gosub KeyStatesFaked
	Send, %KSM%{DOWN 6}
} 
else
	Send, %KSM%{DOWN Down}
return
DownR:
gosub KeyStates
Send, %KSM%{DOWN Up}
return
Right:
gosub KeyStates
Send, %KSM%{RIGHT Down}
return
RightR:
gosub KeyStates
Send, %KSM%{RIGHT Up}
return
Left:
gosub KeyStates
Send, %KSM%{LEFT Down}
return
LeftR:
gosub KeyStates
Send, %KSM%{LEFT Up}
return
Del:
gosub KeyStates
Send, %KSM%{DELETE Down}
return
DelR:
gosub KeyStates
Send, %KSM%{DELETE Up}
return
PageUp:
gosub KeyStates
Send, %KSM%{PGUP Down}
return
PageUpR:
gosub KeyStates
Send, %KSM%{PGUP Up}
return
PageDn:
gosub KeyStates
Send, %KSM%{PGDN Down}
return
PageDnR:
gosub KeyStates
Send, %KSM%{PGDN Up}
return
