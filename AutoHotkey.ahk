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
global A_Editor
; A_Editor = "C:\Program Files\TextPad 4\TextPad.exe"
; A_Editor = "C:\Program Files\AutoHotkey\SciTE\SciTE.exe"
; A_Editor = "c:\Windows\Notepad.exe"
; A_Editor = "C:\Program Files\Sublime Text 2\Sublime_text.exe"
A_Editor = "C:\Users\Jordan\AppData\Local\Programs\Microsoft VS Code\Code.exe"

global DebugLevel := 0
;DebugLevel := 3

;--------------------------------------------------------------------------
; Setup the program-specific scripts.  A timer is run that checks whether
; the foreground app has changed, and if so, it kills the old specific
; ahk and loads in the new one.
SetTimer, ScriptStartup, -50

; TODO: integrate into this script
run, DragToScroll2.ahk

#include misc_library.ahk
#include CheckFullScreen.ahk
#Include, MediaControls.ahk
; #include ErgoBreaks.ahk
#include ArrowKey.ahk

; currently must be last include
#Include Gestures.ahk
#Include KDEDrag.ahk

; All code below has no context
#if
return

; Run once at startup, handle configuration, etc.  -------------------------
ScriptStartup:
	; gosub SetupSpeedReader

	; gosub SetupErgoBreak
	IniRead, timeLeft, hotkeys.ini, Ergo, timeLeft, % 20*60
	IniRead, eb_field, hotkeys.ini, Ergo, eb_field, % eb_field
	if (eb_fie= "") {
		eb_field := 1
		DebugTip("field was empty")
	}
	; SetErgoTimer(timeLeft)

	IniRead, UpAsShift, hotkeys.ini, KeyStates, UpAsShift, False
	if (UpAsShift = "False") {
		gosub ToggleUpAsShift
	}
	run, hotstrings.ahk
return

ScriptReload:
	; IniWrite, % GetErgoTimer(), hotkeys.ini, Ergo, timeLeft
	; IniWrite, % eb_field, hotkeys.ini, Ergo, eb_field
	reload
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
^!RShift::
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

Beeep() {
	SoundPlay, *48
}

; Select the currently focused word
^+i::SendInput, {right}{Ctrl Down}{left}+{right}{Ctrl Up}

; Set a sleep timer
^#!s::
	ToolTipTime("Sleep in 10 minutes")
	sleep, 600111
	; fall through
#!s::
	sleep, 1000
	; fall through
DoSleep:
    DllCall("PowrProf\SetSuspendState", "int", 0, "int", 1, "int", 0)
return

; ----------------------------------------------------------------------------
; --------------------- Navigating and program launching ---------------------
; -------------------------------------  -------------------------------------

; Run window spy
#w::  Run, "C:\Program Files\AutoHotkey\AU3_Spy.exe"

#t::RunRestoreHideApp("Hangouts", "")

#a::
	GroupAdd, Tasks, Tasks - Google Chrome
	GroupAdd, Tasks, WorkFlowy - 
	GroupAdd, Tasks, Checkvist - Google Chrome
	ToolTipTime(A_DDD . " " . A_DD . " " . A_MMMM . " " . A_YYYY . "  " . A_Hour . ":" . A_Min, 2000)
	RunRestoreHideApp("ahk_group Tasks", "https://WorkFlowy.com/#")
return

#s::RunRestoreHideApp("ahk_class ENMainFrame","C:\Program Files (x86)\Evernote\Evernote\evernote.exe")

^#e::
#e::
	GroupAdd, Explorers, ahk_class CabinetWClass
	RunCycleApp("Explorers", "c:\", "ctrl")
	return
^#q::
#q::
	GroupAdd, Chrome, ahk_class Chrome_WidgetWin_0,,,,ahk_exe Spotify.exe
	GroupAdd, Chrome, ahk_class Chrome_WidgetWin_1,,,,ahk_exe Spotify.exe
	RunCycleApp("Chrome", "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe", "ctrl")
return
^#j::
#j::
	GroupAdd, Consoles, ahk_class ConsoleWindowClass
	GroupAdd, Consoles, ahk_class mintty
	RunCycleApp("Consoles", "cmd", "ctrl")
	; RunCycleApp("Consoles", "c:\windows\system32\cmd", "ctrl")
	;RunCycleApp("Consoles", "C:\cygwin64\bin\mintty.exe -i /Cygwin-Terminal.ico -", "ctrl")
	; RunCycleApp("Consoles", "C:\Users\Jordan\AppData\Local\GitHub\GitHub.appref-ms --open-shell", "ctrl")
return

; open github
;#v::RunRestoreMinApp("GitHub ahk_class HwndWrapper[DefaultDomain;;6ef39290-3072-4acc-9987-9c336f2987b5]","C:\Users\Ash\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\GitHub Inc\GitHub.appref-ms")

^#n::
#n::
	GroupAdd, Code, ahk_exe Code.exe
	; GroupAdd, Code, ahk_class Chrome_WidgetWin_1,,,,ahk_exe Spotify.exe
	RunCycleApp("Code", A_Editor, "ctrl")
return

; paste key stuff (to circumvent fields without paste, this just stuffs the keys)
;TODO: turn \r\n's into \r's
LWin & p::
;~ RWin & o::
	SetKeyDelay, -1 ;100
	StringReplace, clip, clipboard, `r`n, `r, All
	SendRaw, %clip%
return

LWin:: 
return ; nothing

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
	If (keyHeld = "D" || !WinExist("ahk_group" . group1))
	{
		run, %app%
		return ran
	}
	GroupActivate, %group1%, R
	return act
}

RunRestoreMinApp(title1, app, title2 = "")
{
	DetectHiddenWindows, On
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

; Fancy-comment current line.  Hold ctrl to center comment
;x --> leads to
; x -------------------------------------------------------------------------
^#/::
#/::
	SetKeyDelay, -1  ; Most editors can handle the fastest speed.
	clipboard =
	send, {end}+{home}+{home}^c ; select all, copy
	ClipWait, .2
	if (ErrorLevel)
		return
	comment := Trim(clipboard)
	firstChar := SubStr(comment, 0, 1)
	validComments := [";", "//", "#"]
	For index, value in validComments {
		commentChar := validComments[A_Index]
		if (BeginsWith(comment, commentChar)) {
			comment := Trim(substr(comment, strlen(commentChar) + 1))
			break
		} 
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

; -------------------------------------------------------------------------
; Temporary scripts -------------------------------------------------------
; -------------------------------------------------------------------------

