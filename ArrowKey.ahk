#include ArrowKeyS.ahk
return

HandleCaps:
	if (critical_caps = 1) {
		return
	}
	critical_caps := 1
	gosub KeyStates
	; ctrl+alt+caps = functional capslock
	if (KSM == "^!")
	{
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
	ForceHeld := 0
	if (KSM = "+") ; || DiffTime < 300)
	{
		DebugTip("Double tap", 3)
		ForceHeld := 1
	}
	PressTime := NextPressTime

	; /////// fall through ////////////
	;*CapsLock Up::
	gosub ToggleIt
return

HandleCapsUp:
	CapsHeld := 0
	critical_caps := 0
goto ToggleIt

ScrollLock::
	CapsHeld := 0
	;Send, {ScrollLock}
goto ToggleIt

ToggleIt:
	If (CapsHeld || ForceHeld) {
		AK_toggle = On
	} else {
		AK_toggle = Off
	}
	DebugTip(AK_toggle . " " . ForceHeld, 3)
	SetScrollLockState, %AK_toggle%
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
	hotkey, *n, %AK_toggle%
	hotkey, *n up, %AK_toggle%
	hotkey, *`,, %AK_toggle%
	hotkey, *`, up, %AK_toggle%
return

; When should ctrl+{up} send multiple up/down?
; TODO: should let user decide which modifier has this behavior
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
	GetKeyState, capstate, CapsLock, P
	; from key states, concat the corresponding AHK modifiers, + ^ !,
	; e.g., shiftstate=altstate=D ==> KSM = +!
	KeyStatesFaked:
	KSM = 
	if shiftstate = D
		KSM = +
	if ctrlstate = D
		KSM = %KSM%^
	else {
		; SC163 is the 'fn' key on many laptops
		GetKeyState, ctrlstate, SC163
		if ctrlstate = D
			KSM = %KSM%^
	}
	if altstate = D
		KSM = %KSM%!
return

Backspace:
Send, %KSM%{BACKSPACE Down}
return
BackspaceR:
Send, %KSM%{BACKSPACE Up}
return
Home:
Send, %KSM%{HOME Down}
return
HomeR:
Send, %KSM%{HOME Up}
return
End:
Send, %KSM%{END Down}
return
EndR:
Send, %KSM%{END Up}
return
Up:
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
Send, %KSM%{UP Up}
return
Down:
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
Send, %KSM%{DOWN Up}
return
Right:
Send, %KSM%{RIGHT Down}
return
RightR:
Send, %KSM%{RIGHT Up}
return
Left:
Send, %KSM%{LEFT Down}
return
LeftR:
Send, %KSM%{LEFT Up}
return
Del:
Send, %KSM%{DELETE Down}
return
DelR:
Send, %KSM%{DELETE Up}
return
PageUp:
Send, %KSM%{PGUP Down}
return
PageUpR:
Send, %KSM%{PGUP Up}
return
PageDn:
Send, %KSM%{PGDN Down}
return
PageDnR:
Send, %KSM%{PGDN Up}
return
EscD:
Send, %KSM%{Esc Down}
return
EscR:
Send, %KSM%{Esc Up}
return


Home_:
HomeR_:
End_:
EndR_:
Up_:
UpR_:
Left_:
LeftR_:
Down_:
DownR_:
Right_:
RightR_:
Backspace_:
BackspaceR_:
Del_:
DelR_:
PageUp_:
PageUpR_:
PageDn_:
PageDnR_:
EscD_:
EscR_:
	gosub KeyStates
	if (capstate = "U" && ForceHeld = 0) {
		; Something went wrong, but we'll bail out here
		original_key := RegExReplace(A_ThisHotkey, "(\*)")
		ToolTipTime(QuotedVar("original_key") . " " .  QuotedVar("A_ThisHotkey") . " " . QuotedVar("A_ThisLabel"))
		gosub HandleCapsUp
		send, {%original_key%}
	}
	NextLabel := SubStr(A_ThisLabel, 1, StrLen(A_ThisLabel) - 1)
	gosub %NextLabel%
return