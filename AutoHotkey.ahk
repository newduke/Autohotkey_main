; regsvr32 WMIUTILS.DLL
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
global A_Editor = "C:\Program Files\AutoHotkey\SciTE\SciTE.exe"
;A_Editor = "c:\Windows\Notepad.exe"
;A_Editor = "C:\Program Files\Sublime Text 2\Sublime 4 AutoHotkey.exe"

global DebugLevel := 0
;DebugLevel := 3

; Initialize variables for borderless script: http://www.autohotkey.com/community/viewtopic.php?t=84446
;~ X := 0
;~ Y := 0
;~ W := A_ScreenWidth
;~ H := A_ScreenHeight

;~ 0 = colemak; 1 = qwerty
KeyboardToggle := 1
keyboardNames1 := "Qwerty", keyboardNames0 := "Colemak"

;~ GroupAdd, Chrome, ahk_class Chrome_WidgetWin_0,,,,Tabs Outliner
;~ GroupAdd, Chrome, ahk_class Chrome_WidgetWin_1,,,,Tabs Outliner

;--------------------------------------------------------------------------
; Setup the program-specific scripts.  A timer is run that checks whether
; the foreground app has changed, and if so, it kills the old specific
; ahk and loads in the new one.

; TODO: put this stuff into the full screen script.
; The last app-specific script loaded
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
#Include SpeedReader.ahk
#if
return

;common functions ---------------------------------------------------------
{
ToolTipTime(tip, time = 1000) {
	ToolTip, % tip
	SetTimer, HideTip, % time
}
DebugTip(tip, level = 1, time = 5000) {
	if (DebugLevel >= level)
		ToolTipTime(tip, time)
}
QuotedVar(var) {
	return % var . ": " . %var%
}

HideTip:
	ToolTip
return
}
; Run window spy
#w::  Run, %A_AHKPath%\..\Au3_spy.exe

;- common functions -------------------------------------------------------


; Run once at startup, handle configuration, etc.  -------------------------
ScriptStartup:
	gosub SetupSpeedReader

	gosub SetupErgoBreak
	IniRead, timeLeft, hotkeys.ini, Ergo, timeLeft, % 20*60
	IniRead, eb_field, hotkeys.ini, Ergo, eb_field, % eb_field
	if (eb_field = "") {
		eb_field := 1
		DebugTip("field was empty")
	}
	SetErgoTimer(timeLeft)

	IniRead, UpAsShift, hotkeys.ini, KeyStates, UpAsShift, False
	if (UpAsShift = "False") {
		gosub ToggleUpAsShift
	}
	run, hotstrings.ahk
return

ScriptReload:
	IniWrite, % GetErgoTimer(), hotkeys.ini, Ergo, timeLeft
	IniWrite, % eb_field, hotkeys.ini, Ergo, eb_field
	reload
return


; WIP Colemak -------------------------------------------------------------
{
; Colemak keyboard, only when not in meta state.
#If (NOT ((GetKeyState("Control", "P")) OR (GetKeyState("Alt", "P")) OR (GetKeyState("LWin", "P")) 
	OR CapsHeld OR KeyboardToggle OR colemakWindow OR ForceHeld))
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
	p::`; ; SC027

	;~ +æ::"
	;~ æ::'
	;~ '::SC01B
	
	
	;~ <^>!m::Send {*}
	;~ <^>!i::Send {_}
	;~ <^>!t::Send {&}
	;~ <^>!o::Send {=}
	;~ <^>!r::Send {+}
	;~ <^>!q::Send {?}
	;~ <^>!w::Send {!}
	;~ <^>!f::Send {(}
	;~ <^>!j::Send {)}
	;~ <^>!g::Send {<}
	;~ <^>!h::Send {>}
	;~ <^>!a::Send {@}
	
	;~ <::/
	
	;~ ; p->ø
	;~ p::SC027
	;~ ; SC01A::SC027 ; 27=ø
	;~ ; ¨->æ
	;~ SC01B::SC028
	
	
	;vkDDsc01A::
	
	;~ Capslock::Backspace
	;~ Backspace::Capslock
	sendlevel 0
}
#IF

; Toggle Colemak
LWin & space::
	KeyboardToggle := 1 - KeyboardToggle
	ToolTipTime("Active: " . keyboardNames%KeyboardToggle%, 1000)
return
} ; WIP

; Hack to disable alternate keyboard if in a gmail window
WindowChanged(title) {
	global colemakWindow = 0

	if (InStr(title, "Google Chrome")) {
		ControlGetText, omni, Chrome_OmniboxView1, A ;ahk_class Chrome_WidgetWin_1
		gmailTitle := "- Gmail - Google Chrome"
		;~ DebugTip(omni)
		if ( (substr(title, -22) == gmailTitle && instr(title, "Compose") == 0
				&& instr(omni, "view=btop") == 0)
			|| InStr(omni, "www.feedly.com") ) {
			colemakWindow := 1
		}
	}
}

ToNumber(num) {
	curr := 0
	loop, % strlen(num) {
		part := SubStr(num, 1, A_Index)
		if part is number
			curr := part
	}
	return curr
}

GetColumn(var, col) {
	arr := Object()
	len := %var%0
	DebugTip(var . " len: " len)
	
	Loop, %len% {
		item := %var%%A_Index%c%col%
		arr[A_Index] := item
	}
	return arr
}

#IfWinActive Column select ahk_class AutoHotkeyGUI
esc::Gui, clip:Hide
#IfWinActive

TryStructured(doc) {
	global
	StringSplit, rows, Clipboard, `r, `n
	line := rows%rows0%
	; Empty last line is removed
	if (StrLen(line) = 0)
		rows0--
	; Only look for structured data. Fewer than 4 lines or different 
	; # fields  per lines cannot be used.
	if (rows0 < 4)
		return false
	cols := 0
	Loop, %rows0% {
		StringSplit, rows%A_Index%c, rows%A_Index%, %A_tab%
		if (cols = 0) {
			cols := rows%A_Index%c0
			if (cols < 2)
				return false ; unstructured data
		} else if (cols != rows%A_Index%c0) {
			return false
		}
	}
	Gui, clip:new
	Gui, clip:margin, 15, 15
	Loop, %rows1c0% {
		Gui, clip:add, Button, gColSelect w50 x+4, Col%A_Index%
	}	
	Loop, %rows1c0% {
		if (A_Index > 1) {
			Gui, clip:add, text, w50 x+4, % rows1c%A_Index%
		} else {
			Gui, clip:add, text, x20 w50, % rows1c%A_Index%
		}
	}
	Gui, clip:Show, AutoSize, Column select
	return true
}

ColSelect:
	Gui, clip:Hide
	; TODO: create GUI of options for using data
	;~ Gui, func:new
	;~ Gui, func:margin, 15, 15
	Col := SubStr(A_GuiControl, 4)
	Col := GetColumn("rows", Col)
	Sum := 0
	Loop, % Col._MaxIndex() {
		num := ToNumber(Col[A_Index])
		Sum += num
	}
	ToolTipTime("Sum: " . sum . " Avg: " . sum/Col._MaxIndex())
	Clipboard = % sum
return

; Text grabber.
; Examine the clipboard and offer intelligent menu of suggestions.
OnClipboardChange:
	; Only fall through on ctrl-c double-tap
	Transform, CtrlC, Chr, 3 ; Store the character for Ctrl-C in the CtrlC var. 
	Input, OutputVar, L1 M V T.2
	if (OutputVar != CtrlC)
		return
#y::
	
	;~ if (A_EventInfo = 1)
	{
		doc := Clipboard
		; Analyze clipboard contents
		DebugTip(Clipboard)
		;~ Sleep, 300
		if (TryStructured(doc)) {
			return
		}
		if (TryReader(Clipboard)) {
			gosub DoReader
			return
		}
		
	}
return

; --------------------------------------------------------------------------
; Key bindings -------------------------------------------------------------
; --------------------------------------------------------------------------
^!r::gosub ScriptReload
^!e::run, %A_Editor% AutoHotkey.ahk, %A_ScriptDir%
^!t::run, %A_Editor% %A_ScriptDir%\Specific\%LastScriptFile%
^+!Space::Suspend 

; The up key on the logitech is in a weird spot
Up::RShift
RShift::Up ;F23

; Toggle the up macro
;~ LShift & RShift::
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
	sleep, 100
	ControlFocus, Tree1, A
	send, t!e!a  ; toggle tapping
	Send, {esc}
	winwaitactive,Mouse Properties
	Send, {esc}
return

; ----------------------------------------------------------------------------
; --------------------- Navigating and program launching ---------------------
; -------------------------------------  -------------------------------------
!space::run, "C:\Program Files (x86)\Launchy\Launchy.exe" /show

;!! TODO: Document me (and others)

; Focus Tictrac
;~ #t::RunRestoreMinApp("Tictrac - Google Chrome ahk_class Chrome_WidgetWin_1", "https://www.tictrac.com/project/back-pain")
; Focus Toggl
;#t::RunRestoreHideApp("Toggl ahk_class Chrome_WidgetWin_0", "C:\Program Files (x86)\Toggl\TogglDesktop\TogglDesktop.exe")
#t::
	RunRestoreHideApp("Hangouts", "")
	WinWaitActive, Hangouts,,1
	if ErrorLevel { 
		return 
	}
	CoordMode,Mouse, Client
	Click, 80, 50
return

#a::
	GroupAdd, Tasks, Tasks - Google Chrome
	GroupAdd, Tasks, WorkFlowy - 
	GroupAdd, Tasks, Checkvist - Google Chrome
	ToolTipTime(A_DDD . " " . A_DD . " " . A_MMMM . " " . A_YYYY . "  " . A_Hour . ":" . A_Min, 2000)
	;RunRestoreHideApp("ahk_group Tasks", "https://mail.google.com/tasks/ig?pli=1")
	RunRestoreHideApp("ahk_group Tasks", "https://WorkFlowy.com/#")
return

#c::RunRestoreHideApp("ahk_class ENMainFrame","C:\Program Files (x86)\Evernote\Evernote\evernote.exe")

#!s::
sleep, 1200111
DoSleep:
    DllCall("PowrProf\SetSuspendState", "int", 0, "int", 1, "int", 0)
return

!#1::eb_display_time()
!#2::eb_set_timer(120*60)
!#3::eb_set_timer_rel(30*60)
!#4::eb_toggle()

#1::
#2::
#3::
#4::
#^1::
#^2::
#^3::
#^4::
	win := SubStr(A_ThisHotkey, 2)
	;MsgBox, %win%
	Send, #!+%win%
return

; Add task via chrome task extension
;~ #t:: ; it's pretty broken and i never use it.
 ;   if not WinActive("ahk_group Chrome")
	;{
	;	GroupActivate, Chrome
	;	WinWaitActive, ahk_group Chrome
	;}
	;send, !d^at{space}
	;return
^#e::
#e::
	GroupAdd, Explorers, ahk_class CabinetWClass
	RunCycleApp("Explorers", "c:\", "ctrl")
	return
^#q::
#q::
	GroupAdd, Chrome, ahk_class Chrome_WidgetWin_0  ;,,,,Tabs Outliner
	GroupAdd, Chrome, ahk_class Chrome_WidgetWin_1  ;,,,,Tabs Outliner
	RunCycleApp("Chrome", "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe", "ctrl")
return
^#j::
#j::
	GroupAdd, Consoles, ahk_class ConsoleWindowClass
	GroupAdd, Consoles, ahk_class mintty
	;RunCycleApp("Consoles", "cmd", "ctrl")
	RunCycleApp("Consoles", "C:\cygwin64\bin\mintty.exe -i /Cygwin-Terminal.ico -", "ctrl")
return
; open github
;#v::RunRestoreMinApp("GitHub ahk_class HwndWrapper[DefaultDomain;;6ef39290-3072-4acc-9987-9c336f2987b5]","C:\Users\Ash\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\GitHub Inc\GitHub.appref-ms")

; open link in VLC
#v::
	if WinActive("ahk_class Chrome_WidgetWin_1") {
		;ClipWait, .1
		SendInput, !d
		Sleep, 100
		Send, ^c
		;Sleep, 200
		ClipWait, 1
	}
	vlc := "C:\Users\Jojo\Downloads\vlc-2.1.5-win32\vlc-2.1.5\vlc.exe"
	StringReplace, file, Clipboard, https, http
	cmd := vlc . " " . file
	Run, %cmd%
return

;  --------------------------------------------------------------------------
; Control Media -------------------------------------------------------------
; these scripts will work even with LWin disabled (so they work in games)
;LWin & WheelUp::SoundSet, +10 ; Win+MouseWheel forward: Louder
;~LWin & WheelDown::SoundSet, -10 ; Win+MouseWheel backward: Lower
;~LWin & Numpad0::SoundSet, +1,, mute ; Win+Numpad0: Volume on/off

#i::
ActivateMedia:
RunRestoreHideApp("ahk_class SpotifyMainWindow","C:\Users\Ash\AppData\Roaming\Spotify\spotify.exe","Spotify")
;RunRestoreMinApp2("iTunes","iTunes","iTunes")
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
If WinExist("ahk_class SpotifyMainWindow") or WinExist("ahk_class iTunes")
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
		;app = "%app%"
		;Msgbox, %app% 
		run, %app%
		return ran
	}
	GroupActivate, %group1%, R
	return act
}

RunRestoreMinApp(title1, app, title2 = "")
{
	DetectHiddenWindows, On
	;~ SetTitleMatchMode, 3
	app = "%app%"
	If WinExist(title1) or (title2 != "" and WinExist(title2))
	{
		IfWinActive
		{
			WinMinimize
			return "min"
		}
		else
		{
			WinShow
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
RunRestoreHideApp(title1,app, app2 = "") {
	act := RunRestoreMinApp(title1, app, app2)
	if ("min" = act) {
		WinHide
		return "hide"
	}
	return act
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
#If WinActive("SciTE4AutoHotkey") AND NOT CapsHeld
^j::Send, {f2}
^k::Send, +{f2}
^l::Send, ^{f2}
; It would be nice to quit the hotkey with the same hotkey, but
; reentrant hotkeys aren't working.
#MaxThreadsBuffer 2
!/::
	if (command != "") {
		autocompl_exit := 1
		DebugTip("compl")
		return
	}
	command := "^{enter}"
	gosub autocomplete
	autocompl_exit := 0
	command =
return
;~ ^i::
^space::
	command := "^i"
	gosub autocomplete
	autocompl_exit := 0
	command =
return
#MaxThreadsBuffer 1	

autocomplete:
	SuccessKeys := "{{}{}}{(}{)}{space}{.}{-}{enter}{backspace}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}"
	passThru := InStr(SuccessKeys, "{backspace}")
	send, %command%
	j := 0
	Loop {
		j++
		DebugTip("LOOP " . j . ": Key: " . k . " : " asc(k) . " " . ErrorLevel)
		Input k,L1MT.2,{RControl}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Del}{Ins}{Numlock}{PrintScreen}{Pause}%SuccessKeys%
		if (autocompl_exit)
			break
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
	if (comment = "" || ! BeginsWith(A_ThisHotkey, "^")) {
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
; just for debugging --------------------------------------------------------
TrueFalse(bool) {
	if (bool)
		return "true"
	return "false"
}
;~ #u::
	comment := "; xyz"	
	;~ comment := Trim(substr(comment, strlen(GetComment()) + 1)) . ".."
	DebugTip(TrueFalse(BeginsWith("abcd", "abc")) . chr(13) 
	. TrueFalse(BeginsWith("abcd", "abcde"))
	. chr(13) . TrueFalse(BeginsWith("abcd", "bc")) . chr(13)
	. TrueFalse(BeginsWith("max", "longish")) . chr(13) )
	;ToolTipTime(comment)
	DebugTip(QuotedVar("Comment"))
return

; Convert Google Tasklist items to numbered items
; one row at a time
;~ #k::Send, +{up}{del}^{up}
}
;#k::send, :{down}{end}
;#include ArrowKey.ahk
