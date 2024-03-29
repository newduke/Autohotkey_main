; See also https://www.reddit.com/r/vim/comments/4d6iym/what_do_you_all_do_with_caps_lock_control_and/
; https://github.com/MarcWeber/autohotkey_viper
; and https://github.com/achalddave/Vimdows-Navigation
; from this discussion: https://autohotkey.com/board/topic/41206-modal-vim/

#Include logging.ahk

VimSetup() {
    ; LogInitGUI()
    Send, {RCtrl Up} ; fixes stuck key during reload
    global keyMap := {}
    global vimMode := "normal"
    global vimNum := ""
    global vimChord := ""
    global waitForEnter := ""
    keyMap["i"] := "{Up}"
    keyMap["j"] := "{Left}"
    keyMap["k"] := "{Down}"
    keyMap["l"] := "{Right}"
    keyMap["h"] := "{Delete}"
    ; keyMap["i"] := "{Delete}"
    ; keyMap["j"] := "{Down}"
    ; keyMap["k"] := "{Up}"
    ; keyMap["l"] := "{Right}"
    ; keyMap["h"] := "{Left}"
    keyMap["u"] := "{Home}"
    keyMap["o"] := "{End}"
    keyMap[";"] := "{Backspace}"
    keyMap["m"] := "{PgUp}"
    keyMap[","] := "{PgDn}"
}

~LShift::
    startTime := A_TickCount
    KeyWait,RShift,D T0.1 ; ... and the next press.
    Sleep, 1
	If (Errorlevel || A_TickCount - startTime > 100) ; If it never comes or takes too long, do not toggle.
		return
    capsToggle := (GetKeyState("CapsLock", "T")) ? "OFF" : "ON"
    SetCapsLockState, %capsToggle%
    OSD("Capslock: " . capsToggle)
return

*CapsLock::
    if (capsDown) {
        ; Log("down held, ignoring")
        return
    }
    capsDownStartTime := A_TickCount
    capsDown := 1    
	Send {RControl Down}
    ; if (GetKeyState("Shift")) {
    if (EnterDown) {
        if (vimMode = "vim") {
            EnterDown := 0
        } else {
            ChangeMode("vim")
            enterVimMode := 1
        }
    } else if (waitForEnter) {
        ChangeMode(waitForEnter)
        waitForEnter := vimMode
    }
    else if (vimMode = "normal") {
        ChangeMode("quick vim")
        vimMode := "quick vim"
    }
    ; OSD(vimMode)
Return

*CapsLock up::
	Send {RControl Up}
    capsDown := 0
    if (waitForEnter) {
        waitForEnter := ""
        Send, {Esc}
        enterVimMode := 0
        return
    }
    capsPressDuration := A_TickCount - capsDownStartTime
	if (A_PriorKey="CapsLock" && capsPressDuration < 300 && !enterVimMode) {
        Suspend On
        Send, {Esc}
        Suspend Off
        ChangeMode("normal")
    }
    if (vimMode = "quick vim") {
        ChangeMode("normal")
    }
    enterVimMode := 0
Return

; Enter acts like chord key for launching apps, just enter when pressed alone
Enterdown := 0
Enter::
+Enter::
    hotkey := LTrim(A_ThisHotkey, " +!#^*")
    gosub KeyStates
    if (%hotkey%down) {
        Send, {Blind}{Enter}
        return
    }
    %hotkey%StartTime := A_TickCount
    %hotkey%down := 1    
Return

~*Enter up::
    hotkey := RegExReplace(A_ThisHotkey, " up")
    hotkey := LTrim(hotkey, " +!#^*~")

    %hotkey%PressDuration := A_TickCount - %hotkey%StartTime
    if (%hotkey%down && A_PriorKey=hotkey && %hotkey%PressDuration < 300) {
        Suspend On
        Send, %KSM%{Enter}
        Suspend Off
    }
    %hotkey%down := 0
Return

EnterVimMode:
return

ChangeMode(newMode) {
    global vimMode, waitForEnter := ""
    global vimNum, vimChord, oldMode := vimMode
    ; Log("Change Mode: " newMode)
    ; OSD(vimMode)
    vimMode := newMode
    if (vimMode = "vim") {
        enterVimMode := 1
        vimNum := 0
        vimChord := ""
    }
}

#if waitForEnter
~enter::
ChangeMode(waitForEnter)
return
#If
OpenWorkflowy:
#a::
    ; If(!WinActive("ahk_exe brave.exe"))

	SetTitleMatchMode, 2
    if (!WinActive("WorkFlowy")) {
        ; OpenBrowser(1, 1)
	    OpenBrowserTab("WorkFlowy")
        ; Sleep, 200
        ; return
    }
    ; Sleep, 100
    SendInput, !w
return
	
; OpenToggl:
; #q::
; 	act := RunRestoreMinApp("- Toggl Desktop", "C:\Users\Jordan\AppData\Local\TogglDesktop\TogglDesktop.exe")
; return
OpenAnyTab:
#q::
	OpenBrowserTab("",,0)
return
	
OpenYoutube:
#y::
	OpenBrowserTab("youtube",,0)
return

#if Enterdown
a::goto OpenWorkflowy
q::goto OpenAnyTab
y::goto OpenYoutube
t::goto OpenMessages
+t::goto OpenMessages

#If vimMode = "vim" || vimMode = "visual"
0::
1::
2::
3::
4::
5::
6::
7::
8::
9::
    num := A_ThisHotkey
    vimNum = %vimNum%%num%
    OSD(vimNum)
return

.::executeLastAction()
/::
    Send, ^f
    ChangeMode("normal")
    waitForEnter := oldMode
return
n::MultiActionN("keyStuff", "next", "{f3}")
+n::MultiActionN("keyStuff", "prev", "+{f3}")
z::MultiActionN("keyStuff", "undo", "^{z}")
; y::MultiActionN("keyStuff", "redo", "^{y}")
+z::MultiActionN("keyStuff", "redo", "^{y}")

a::ChangeMode("normal") ; change mode without inserting any keys

; Chords --------------------------------------------------------------------
#If (vimMode = "vim" or vimMode = "visual") && vimChord = ""
d::vimChord := "d"
v::ChangeMode(vimMode = "vim" ? "visual" : "vim")

#If vimMode = "vim" && vimChord = "d"
d::MultiAction("LineDelete")

#If

LineDelete(count) {
    if (!count)
        count := 1
    if (0 && WinActive("ahk_exe Code.exe")) {
        Send, +{Delete %count%}
    } else {
        Send, {Home 2}{Right}{Home 2}+{Down %count%}{Delete}
    }
}

#If 0 && vimMode = "quick vim"
; Tried this alternative approach to sending keys with ctrl modifier to avoid sending additional ctrl up + down, 
; but it failed to recurse to pick up internal hotkeys.
; *q::
*`::
*tab::
*q::
*w::
*e::
*r::
*t::
*y::
; *u::
; *i::
; *o::
*p::
*[::
*]::
*\::
*a::
*s::
*d::
*f::
*g::
; *h::
; *j::
; *k::
; *l::
*;::
*'::
*enter::
*z::
*x::
*c::
*v::
*b::
*n::
; *m::
; *`,::
*.::
*/::
    original_key := RegExReplace(A_ThisHotkey, "(\*)")
    Log(original_key)
    SendEvent, ^!r
    ; SendEvent, {Blind}{CtrlDown}{%original_key%}{CtrlUp}
    
return

#If vimMode = "vim" || vimMode = "quick vim" || vimMode = "visual"
*u::
*i::
*o::
*j::
*k::
*l::
*h::
*;::
*m::
*,::
    original_key := RegExReplace(A_ThisHotkey, "(\*)")
    if (vimMode = "quick vim") {
        Send, {RCtrl Up}
    }
    states := {}
    if (vimMode = "visual") {
        states["shiftState"] := 1
    }
    stuffKey := keyMap[original_key]
	SetTitleMatchMode, 2
    if (GetKeyState("LCtrl") && InStr("{up}{down}", stuffKey) && !WinActive("WorkFlowy -")) {
        vimNum := 6
        states["ctrlState"] := 0
        MultiAction("KeyStuff", [stuffKey, states]*)
    } else if (!vimNum && InStr("{up}{down}{left}{right}", stuffKey)) {
        held%original_key% := 0
        vimChord := ""
    	RapidFire(250, 10, original_key, held%original_key%, "keyStuff", [stuffKey, states]*)
    } else {
        MultiAction("KeyStuff", [stuffKey, states]*)
    }
    if (vimMode = "quick vim") {
        Send, {RCtrl Down}
    }
#If

#If vimMode = "win"
#If

MultiActionN(action, name, params*) {
    OSD(name)
    MultiAction(action, params*)
}

MultiAction(action, params*) {
    global vimNum := Min(vimNum, 500)
    global vimChord
    global lastAction := action
    global lastNum := vimNum
    global lastParams := params
    vimNum := ""
    vimChord := ""
    executeLastAction()
}

executeLastAction() {
    global lastAction, lastNum, lastParams
    (lastAction).(lastNum, lastParams*)
}

KeyStuff(count, params*) {
    key := params[1]
    gosub KeyStates
    if (params.MaxIndex() >= 2) {
        For keyState, value in params[2] {
            %keyState% := value
        }
        gosub KeyStatesFaked
    }
    global KSM
    if (count) {
        key := RegExReplace(key, "}$", " " count "}")
    }
    sent := KSM . key
    ; OSD(sent)
    ; Log(sent)
    Send %sent%
}

SaveCapsDownState(key:="RCtrl") {
	SendInput, {%key% Up}
    return capsDown
}
RestoreCapsDownState(key:="RCtrl") {
	if (capsDown)
		SendInput, {%key% Down}
}

; While key is held for more than long ms, repeat action every short ms.
; mutex guards this block for reentry.
RapidFire(long, short, key, ByRef mutex, action, extraArgs*) {
	if mutex = 1
		return
	mutex := 1
	action.(0, extraArgs*)
	longHold := A_TickCount + long
	Loop {
		Sleep, %short%
		rapidPressed := GetKeyState(key, "P")
		If not rapidPressed
			Break
		if (A_TickCount < longHold)
			Continue
		gosub KeyStates
		action.(0, extraArgs*)
	}
	mutex := 0
}
KeyStates:
	shiftState := GetKeyState("Shift", "P")
	ctrlState := GetKeyState("Ctrl", "P")
	altState := GetKeyState("Alt", "P")
	winState := GetKeyState("LWin", "P")
	capState := GetKeyState("CapsLock", "P")
	; fall through
; from key states, concat the corresponding AHK modifiers, + ^ !,
; e.g., shiftstate=altstate=1 ==> KSM = +!
KeyStatesFaked:
	KSM := ""
	if shiftstate
		KSM := "+"
	if ctrlstate
		KSM := KSM . "^"
	if altstate
		KSM := KSM . "!"
	if winstate
		KSM := KSM . "#"
return
