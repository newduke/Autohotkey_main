; -------------------------------------------------------------------------
; AutoHotkey.ahk
; author: Jordan Weitz (newduke@gmail.com)
; 

;
; setup
;
; various other scripts to run
#include ArrowKeyS.ahk
#Include GesturesS.ahk

SetWinDelay,2
CoordMode,Mouse
;SendMode, Input

; common variables ---------------------------------------------------------
;A_Editor = "C:\Program Files\TextPad 4\TextPad.exe"
A_Editor = "C:\Program Files\AutoHotkey\SciTE\SciTE.exe"
;A_Editor = "c:\Windows\Notepad.exe"

global DebugLevel := 0
;DebugLevel := 1

; Initialize variables for borderless script: http://www.autohotkey.com/community/viewtopic.php?t=84446
X := 0
Y := 0
W := A_ScreenWidth
H := A_ScreenHeight

KeyboardToggle := 1
keyboardNames1 := "Qwerty", keyboardNames0 := "Colemak"

GroupAdd, Chrome, ahk_class Chrome_WidgetWin_0,,,,Tabs Outliner
GroupAdd, Chrome, ahk_class Chrome_WidgetWin_1,,,,Tabs Outliner

;--------------------------------------------------------------------------
; Setup the program-specific scripts.  A timer is run that checks whether
; the foreground app has changed, and if so, it kills the old specific
; ahk and loads in the new one.

;;! The last app-specific script loaded
HoldLastScriptFile := ""
; The current app-specific script loaded
LastScriptFile := "foo.ahk"
; Full-screen toggle. 
; 0: not full-screen
; 1: full-screen
; other: not yet known
fs := 2

SetTimer, CheckFullScreen, 50
SetTimer, ScriptStartup, -50
;~ Gosub SetupErgoBreak

;--------------------------------------------------------------------------
;;; no longer needed.  KDE drag has push-back; win 7 has finder in start menu
;#include WindowPushback.ahk
;#include FindIt.ahk

; TODO: integrate into this script
run, DragToScroll.ahk

#include misc_library.ahk
#include CheckFullScreen.ahk
#include ErgoBreaks.ahk
#include KDEDrag.ahk
#include ArrowKey.ahk

; currently must be last include
#Include Gestures.ahk
#Include KDEDrag.ahk
#if

return

;common functions ---------------------------------------------------------
{
ToolTipTime(tip, time = 1000) {
	ToolTip, % tip
	SetTimer, HideTip, % time
}
DebugTip(tip, level = 1) {
	if (DebugLevel >= level)
		ToolTipTime(tip, 5000)
}

HideTip:
	ToolTip
return
}
;! common functions -------------------------------------------------------


; WIP Colemak -------------------------------------------------------------
{
; Colemak keyboard, only when not in meta state.
#If (NOT ((GetKeyState("Control", "P")) OR (GetKeyState("Alt", "P")) OR (GetKeyState("WIN", "P")) 
	OR CapsHeld OR KeyboardToggle OR colemakWindow))
{
	sendlevel 1
	e::f
	r::p
	t::g
	y::j
	u::l
	i::u
	o::y
	
	s::r
	d::s
	f::t
	g::d
	j::n
	k::e
	l::i
	n::k
	`;::o

	;~ +æ::"
	;~ æ::'
	;~ '::SC01B
	
	
	<^>!m::Send {*}
	<^>!i::Send {_}
	<^>!t::Send {&}
	<^>!o::Send {=}
	<^>!r::Send {+}
	<^>!q::Send {?}
	<^>!w::Send {!}
	<^>!f::Send {(}
	<^>!j::Send {)}
	<^>!g::Send {<}
	<^>!h::Send {>}
	<^>!a::Send {@}
	
	<::/
	
	; p->ø
	p::SC027
	; SC01A::SC027 ; 27=ø
	; ¨->æ
	SC01B::SC028
	
	
	;vkDDsc01A::
	
	;~ Capslock::Backspace
	;~ Backspace::Capslock
}
#IF

; Toggle Colemak
LAlt & space::
	KeyboardToggle := 1 - KeyboardToggle
	ToolTipTime("Active: " . keyboardNames%KeyboardToggle%, 1000)
return
} ; WIP

; Hack to disable alternate keyboard if in a gmail window
WindowChanged(title) {
	global colemakWindow
	
	gmailTitle := "- Gmail - Google Chrome"
	if (substr(title, -22) == gmailTitle && instr(title, "Compose") == 0) {
		colemakWindow := 1
	} else {
		colemakWindow := 0
	}
}

; Text grabber.
; Examine the clipboard and offer intelligent menu of suggestions.
;~ OnClipboardChange:
	if (A_EventInfo = 1)
	{
		; Analyze clipboard contents
		DebugTip(Clipboard)
	}
return


;  --------------------------------------------------------------------------
; text expansions (hotstrings) --------------------------------------------------
;; NOTE: text expansions were messing with timers
;; see also "texter:" http://lifehacker.com/238306/lifehacker-code-texter-windows
::uus::the United States
::aaj::Ashley Jordan
::jjw::Jordan Weitz
::jauth::author: Jordan Weitz (newduke@gmail.com)
::cliche::cliché 
::DATE::
	send, % A_DD . " " . A_MMM . " " . A_YYYY
return
; -------------------------------------------------------------------------
;--------------------------------------------------------------------------

; Run once at startup, handle configuration, etc.  -------------------------
ScriptStartup:
	IniRead, UpAsShift, hotkeys.ini, KeyStates, UpAsShift, False
	if (UpAsShift = "False") {
		gosub ToggleUpAsShift
	}
return

; --------------------------------------------------------------------------
; Key bindings -------------------------------------------------------------
; --------------------------------------------------------------------------
^!r::reload
^!e::run, %A_Editor% AutoHotkey.ahk, %A_ScriptDir%
^!t::run, %A_Editor% %A_ScriptDir%\Specific\%LastScriptFile%
^+!Space::Suspend 

; The up key on the logitech is in a weird spot
Up::RShift
RShift::Up ;F23

; Toggle the up macro
LShift & RShift::
	IniRead, UpAsShift, hotkeys.ini, KeyStates, UpAsShift, False
	if (UpAsShift = "False") {
		UpAsShift = "True"
	} else {
		UpAsShift = "False"
	}		
	IniWrite, %UpAsShift%, hotkeys.ini, KeyStates, UpAsShift
ToggleUpAsShift:
	Hotkey, *up, toggle
	Hotkey, *up up, toggle
	Hotkey, *rshift, toggle
	Hotkey, *rshift up, toggle
return

Beeep()
{
	SoundPlay, *48
}

; This is how you can use fn hotkey.  see also http://www.autohotkey.com/docs/KeyList.htm#SpecialKeys
;~ SC163::ToolTipTime("fn")
;~ return
	
; toggle touchpad tapping (disable clicking from annoying touchpad, win 7)
^F12::
   Run, rundll32.exe shell32.dll`,Control_RunDLL main.cpl @0 ;mouse options
   winwaitactive,Mouse Properties
   Send, ^+{TAB}
   ;Send, !t!a ;; disable
   Send, !n ; settings
   winwaitactive,TouchPad Properties
   Send, +{tab}+{tab}t!e!a  ; toggle tapping
   Send, {esc}
   winwaitactive,Mouse Properties
   Send, {esc}
return

;!! TODO: Document me (and others)
; Add task via chrome task extension
#t::
    if not WinActive("ahk_group Chrome")
	{
		GroupActivate, Chrome
		WinWaitActive, ahk_group Chrome
	}
	send, !d^at{space}
	return
^#e::
#e::
	GroupAdd, Explorers, ahk_class CabinetWClass
	RunCycleApp("Explorers", "c:\", "ctrl")
	return
^#q::
#q::
	RunCycleApp("Chrome", "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe", "ctrl")
return
^#j::
#j::
GroupAdd, Consoles, ahk_class ConsoleWindowClass
RunCycleApp("Consoles", "cmd", "ctrl")
return
#v::RunRestoreHideApp("GitHub","C:\Users\Ash\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\GitHub, Inc\GitHub.appref-ms")

;  --------------------------------------------------------------------------
; Control Media -------------------------------------------------------------
; these scripts will work even with LWin disabled (so they work in games)
;~LWin & WheelUp::SoundSet, +10 ; Win+MouseWheel forward: Louder
;~LWin & WheelDown::SoundSet, -10 ; Win+MouseWheel backward: Lower
;~LWin & Numpad0::SoundSet, +1,, mute ; Win+Numpad0: Volume on/off

;;#i::RunRestoreHideApp2("iTunes","iTunes","iTunes")
#i::
ActivateMedia:
RunRestoreHideApp2("ahk_class SpotifyMainWindow","C:\Users\Ash\AppData\Roaming\Spotify\spotify.exe","Spotify")
return

#m::
Send, {Media_Prev}
;If WinExist("ahk_class iTunes") or WinExist("ahk_class SpotifyMainWindow")
;ControlSend, ahk_parent, ^{LEFT}  ; < previous
;ControlSend, ahk_parent, #c  ; < previous
return
;Browser_Forward::
#,::
Send, {Media_Next}
;If WinExist("ahk_class iTunes") or WinExist("ahk_class SpotifyMainWindow")
;ControlSend, ahk_parent, ^{RIGHT}  ; > next
;WinActivate
;Send, ^{RIGHT}
return
;Media_Play_Pause::
#.::
;Send, {Media_Play_Pause}
If WinExist("ahk_class iTunes") or WinExist("ahk_class SpotifyMainWindow")
ControlSend, ahk_parent, {SPACE}  ; play/pause
return
#up::
!Volume_up::
IfWinExist, ahk_class SpotifyMainWindow
ControlSend, ahk_parent, ^{up}  ; volume up
return
#down::
!Volume_down::
IfWinExist, ahk_class SpotifyMainWindow
ControlSend, ahk_parent, ^{down}  ; volume downa
return

;LWin & !k::goto KillActive
;RWin & !k::goto KillActive

; paste key stuff (to circumvent fields without paste, this just stuffs the keys)
;TODO: turn \r\n's into \r's
LWin & p::
;~ RWin & o::
SetKeyDelay, -1 ;100
StringReplace, clip, clipboard, `r`n, `r, All
SendRaw, %clip%
return

;~ ^!n::
#n::
run, %A_Editor%
return

#w::  Run, %A_AHKPath%\..\Au3_spy.exe

;#h::
; record a macro
input, myMacro, V T60, {RControl}
IfInString, ErrorLevel, EndKey
{
	MsgBox, = = %myMacro%
}
return

;~ #p::
; send current clipboard buffer to ventrillo comment area
IfWinExist, Ventrilo
{
	ControlClick, Button5
	WinWait, Comment
	If ErrorLevel = 0
	{
		ControlSend, Edit1, ^v
		ControlSend, ahk_parent, {enter}
	}
}
return

LWin:: 
return ; nothing

; kill the active window via its process.  
KillActive:
	IfWinActive, Program Manager
		return
	GetKeyState, AltHeld, Alt, P
	if AltHeld = U
		return
	GetKeyState, AltHeld, LWin, P
	if AltHeld = U
		return

	;don't kill PID 0 or 4 (killing system threads = bad)
	WinGet, pid, PID , A
	if (pid && pid != 0 && pid != 4)
		Process, Close, %pid%
	;WinKill, A
return

; yes, it does nothing.  used to disable keys
Nothing:
return

RunCycleApp(group1, app, forcekey)
{
	keyHeld := U
	if (forcekey != "")
	{
		GetKeyState, keyHeld, %forcekey%, P
	}
	;MsgBox, %group1%, %app%, %keyHeld%
	;GroupAdd, FindWindows, title1
	If (keyHeld = "D" || !WinExist("ahk_group" . group1))
	{
		app = "%app%"
		run, %app%
		return ran
	}
	GroupActivate, %group1%, R
	return act
}

RunRestoreHideApp2(title1, app, title2)
{
	DetectHiddenWindows, On
	SetTitleMatchMode, 3
	app = "%app%"
	If WinExist(title1) or (title2 <> "" and WinExist(title2))
	{
		IfWinActive
		{
			WinMinimize
			return "min"
		}
		else
		{
			WinActivate
			return "act"
		}
	}
	else
	{
		Run, %app%
		return "ran"
	}
}
Quoted(string)
{
	string = "%string%"
}
RunRestoreHideApp(title1, app)
{
	a:= RunRestoreHideApp2(title1, app, "")
	return %a%
}

; -------------------------------------------------------------------------
; App-specific scripts ----------------------------------------------------
; -------------------------------------------------------------------------

; chrome --------------------------------------------------------------------
#IfWinActive, ahk_class Chrome_WidgetWin_1
; open bookmark in chrome
#b::Send, {alt down}d{alt up}b{space}

#IfWinActive

; SciTE hotkeys -------------------------------------------------------------
{
#If WinActive("SciTE4AutoHotkey")
!/::
	command := "^{enter}"
	goto autocomplete
^i::
^space::
	command := "^i"
	goto autocomplete
autocomplete:
	SuccessKeys := "{{}{}}{(}{)}{space}{.}{-}{enter}{backspace}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}"
	passThru := InStr(SuccessKeys, "{backspace")
	send,%command%
	j:=0
	Loop {
		j++
		DebugTip("LOOP " . j . ": Key: " . k . " : " asc(k) . " " . ErrorLevel)
		Input k,L1MT14,{RControl}{LAlt}{RAlt}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Del}{Ins}{Numlock}{PrintScreen}{Pause}%SuccessKeys%
		DebugTip("iLOOP " . j . ": Key: " . k . " : " asc(k) . " " . ErrorLevel)
		If (ErrorLevel && BeginsWith(ErrorLevel, "EndKey:")) {
			DebugTip("key " . k . " - " . ErrorLevel . " - " . BeginsWith(ErrorLevel, "EndKey:"))
			EndKey := SubStr(ErrorLevel, 8)
			SearchKey := "{" . EndKey . "}"
			found := InStr(SuccessKeys, SearchKey)
			if (found) {
				if (EndKey = "enter") {
					send, {enter}
					return
				}
				if (found = passThru) {
					send, % SearchKey
					send, %command%
					continue					
				}
				if (found >= passThru) {
					send, % SearchKey
					continue
				}
				Send, {return}
				Send, %SearchKey%
				;DebugTip("key " . k . " - " . ErrorLevel)
				return
			}
			break
		}
		If (ErrorLevel == "Max") {
			DebugTip("mLOOP " . j . ": Key: " . k . " : " asc(k) . " " . ErrorLevel)
			If (k == chr(27)) { ; escape
				DebugTip("ESC")
				Send, {esc}
				return
			}
			SendRaw, %k%
			send, %command%
		}
	}
	DebugTip("Exit: " . ErrorLevel . " -- " . EndKey)
	send,{esc}
return
#If
}

; GetComment() returns comment style
; TODO: generalize
GetComment() {
If (WinActive("SciTE4AutoHotkey"))
	return ";"
else
	return "//"
}

; Fancy-comment current line.  Hold ctrl to center comment
;x --> leads to
; x -------------------------------------------------------------------------
^#-::
#-::
	SetKeyDelay, -1  ; Most editors can handle the fastest speed.
	clipboard =
	send, {end}+{home}+{home}^c ; select all, copy
	ClipWait, .2
	if (ErrorLevel)
		return
	comment := Trim(clipboard)
	commentChar := GetComment()
	if (BeginsWith(comment, commentChar)) {
		comment := Trim(substr(comment, strlen(commentChar) + 1))
	} else {
	}
	blockLength = 74 ; TODO: make global/setting
	n := blockLength - StrLen(comment)
	if (n < 0) 
		return
	line := ""
	if (! BeginsWith(A_ThisHotkey, "^")) {
		loop, %n%
			line := "-" + line
		line = %commentChar% %comment% %line%
	} else {
		n := n/2
		loop, %n%
			line := "-" + line
		line = %commentChar% %line% %comment% %line%
	}
	Clipboard := line
	Send, ^v{right}
return

; input repeated
; ex: input: "5q" sends "qqqqq"
^!u::
{
	input, rep, T3, qwertyuiop[]\asdfghjkl;'zxcvbnm{comma}./<>?:"{}|-=
	SetKeyDelay, -1  ; Most editors can handle the fastest speed.
	if ErrorLevel = Max
		return
	if ErrorLevel = Timeout
		return
	StringRight, key, ErrorLevel, 1
	loop, %rep%
	{
		SendRaw, %key%
	}
}
return

; -------------------------------------------------------------------------
; Temporary scripts -------------------------------------------------------
; -------------------------------------------------------------------------
{
; autofill password
^#i::send, 408{tab}dpq3v{enter}

; just for debugging --------------------------------------------------------
TrueFalse(bool) {
	if (bool)
		return "true"
	return "false"
}
#u::
	;~ comment := "; xyz"	
	;~ comment := Trim(substr(comment, strlen(GetComment()) + 1)) . ".."
	DebugTip(TrueFalse(BeginsWith("abcd", "abc")) . chr(13) 
	. TrueFalse(BeginsWith("abcd", "abcde"))
	. chr(13) . TrueFalse(BeginsWith("abcd", "bc")) . chr(13)
	. TrueFalse(BeginsWith("max", "longish")) . chr(13) )
	;ToolTipTime(comment)
return

; Convert Google Tasklist items to numbered items
; one row at a time
;~ #k::Send, +{up}{del}^{up}
}