global ctrlstate
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

; Is this needed?
; ScrollLock::
; 	CapsHeld := 0
; 	;Send, {ScrollLock}
; goto ToggleIt

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
	return true
	SetTitleMatchMode, 2
	If WinActive("ahk_exe Code.exe") {
		return true
	}
	return false
}

; get states of modifiers and stuff them into variables shiftstate, ctrlstate, altstate, winstate
KeyStates:
	shiftstate := GetKeyState("Shift")
	ctrlstate := GetKeyState("Ctrl")
	altstate := GetKeyState("Alt")
	winstate := GetKeyState("LWin")
	capstate := GetKeyState("CapsLock", "P")
	; fall through
; from key states, concat the corresponding AHK modifiers, + ^ !,
; e.g., shiftstate=altstate=1 ==> KSM = +!
KeyStatesFaked:
	KSM := ""
	if shiftstate
		KSM := "+"
	if ctrlstate
		KSM := KSM . "^"
	; else {
	; 	; SC163 is the 'fn' key on many laptops
	; 	ctrlstate := GetKeyState("SC163")
	; 	if ctrlstate
	;		KSM := KSM . "^"
	; }
	if altstate
		KSM := KSM . "!"
	if winstate
		KSM := KSM . "#"
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

upAction() {
	if (ctrlstate and AllowMultiarrow())
	{
		SetKeyDelay, -1
		ctrlstate := false
		gosub KeyStatesFaked
		Send, %KSM%{UP 6}
	} 
	else
		Send, %KSM%{UP Down}
	}
Up:
	RapidFire(250, 10, original_key, uHeld, "upAction")
return
UpR:
	uHeld := 0
	Send, %KSM%{LEFT Up}
return
downAction() {
	if (ctrlstate and AllowMultiarrow())
	{
		SetKeyDelay, -1
		ctrlstate := false
		gosub KeyStatesFaked
		Send, %KSM%{DOWN 6}
	} 
	else
		Send, %KSM%{DOWN Down}
	}
Down:
	RapidFire(250, 10, original_key, dHeld, "downAction")
return
DownR:
	dHeld := 0
	Send, %KSM%{LEFT Up}
return

leftAction() {
	Send, %KSM%{LEFT Down}
}
Left:
	RapidFire(200, 10, original_key, lHeld, "leftAction")
return
LeftR:
	lHeld := 0
	Send, %KSM%{LEFT Up}
return
rightAction() {
	Send, %KSM%{RIGHT Down}
}
Right:
	RapidFire(200, 10, original_key, rHeld, "rightAction")
return
RightR:
	rHeld := 0
	Send, %KSM%{RIGHT Up}
return

; While key is held for more than long ms, repeat action every short ms.
; mutex guards this block for reentry.
RapidFire(long, short, key, ByRef mutex, action) {
	if mutex = 1
		return
	mutex := 1
	action.()
	longHold := A_TickCount + long
	Loop {
		Sleep, %short%
		rapidPressed := GetKeyState(key, "P")
		If not rapidPressed
			Break
		if (A_TickCount < longHold)
			Continue
		gosub KeyStates
		action.()
	}
	mutex := 0
}
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
	original_key := RegExReplace(A_ThisHotkey, "(\*)")
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
