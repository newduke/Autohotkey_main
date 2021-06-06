; regsvr32 WMIUTILS.DLL
; -------------------------------------------------------------------------
; AutoHotkey.ahk
; author: Jordan Weitz (newduke@gmail.com)
; 

;
; setup
;

; #InstallMouseHook

; various other scripts to run
; #include ArrowKeyS.ahk
; #include VimKey.ahk
#Include GesturesS.ahk
#Include logging.ahk
global shiftState := ""

SetWinDelay,2
CoordMode,Mouse
;SendMode, Input

; common variables ---------------------------------------------------------
global browserExe := "ahk_exe brave.exe"
global chromeExe :=  "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
global browserLocation := "C:\Program Files (x86)\BraveSoftware\Brave-Browser\Application\brave.exe"
; A_Editor = "C:\Program Files\TextPad 4\TextPad.exe"
; A_Editor = "C:\Program Files\AutoHotkey\SciTE\SciTE.exe"
; A_Editor = "c:\Windows\Notepad.exe"
; A_Editor = "C:\Program Files\Sublime Text 2\Sublime_text.exe"
global A_Editor = "C:\Users\Jordan\AppData\Local\Programs\Microsoft VS Code\Code.exe"

global DebugLevel := 0
; DebugLevel := 3

;--------------------------------------------------------------------------
; Setup the program-specific scripts.  A timer is run that checks whether
; the foreground app has changed, and if so, it kills the old specific
; ahk and loads in the new one.
; The last app-specific script loaded
HoldLastScriptFile := ""
; The current app-specific script loaded
LastScriptFile := "foo.ahk"
; Full-screen toggle. 
; 0: not full-screen
; 1: full-screen
; other: not yet known
fs := 2

; SetTimer, CheckFullScreen, 50
SetTimer, ScriptStartup, -50

; TODO: integrate into this script
run, DragToScroll.ahk

#include misc_library.ahk
#include CheckFullScreen.ahk
#Include, MediaControls.ahk
; #include ErgoBreaks.ahk

#include VimKey.ahk
; #include ArrowKey.ahk

; currently must be last include
#Include Gestures.ahk
#Include KDEDrag.ahk
; #Include, Chord.ahk
; #Include, ../WindowPadX/WPXA.ahk

; All code below has no context
#if
return

; Run once at startup, handle configuration, etc.  -------------------------
ScriptStartup:
	if (DebugLevel) {
		LogInitGUI(, DebugLevel - 1)
	}
	VimSetup()
	; MakeChord("Enter", "a", "OpenWorkflowy")
	; MakeChord("Enter", "t", "OpenHangouts")
	; MakeChord("Enter", "u", "Home")
	; MakeChord("Enter", "o", "End")
	; gosub SetupSpeedReader
	; gosub SetupErgoBreak
	IniRead, timeLeft, hotkeys.ini, Ergo, timeLeft, % 20*60
	IniRead, eb_field, hotkeys.ini, Ergo, eb_field, % eb_field
	if (eb_field= "") {
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
^!e::
	run, %A_Editor% "AutoHotkey Main.code-workspace", %A_ScriptDir%
	run, %A_Editor% AutoHotkey.ahk, %A_ScriptDir%
return
; ^!e::run, %A_Editor% AutoHotkey.ahk, %A_ScriptDir%

; ^!t::run, %A_Editor% %A_ScriptDir%\Specific\%LastScriptFile%
^+!Space::Suspend 

#[::Click, WheelUp
#]::Click, WheelDown

#Space::
keywait, LWin
keywait, RWin
; Send, {AppsKey}
SendEvent, +{F10}
return

; Navigate Chrome tabs
#if WinActive("Window Manager - Google Chrome") or WinActive("Window Manager - Brave")
~^Enter::
	SaveCapsDownState()
	SendEvent, {Tab}{Down}{Enter}
	RestoreCapsDownState()
return
#if

^!w::
OpenTabSearch:
	SaveCapsDownState()
	SendInput, +!w
	WinWait, Window Manager - Brave, , .5
	WinActivate
	WinWaitActive, Window Manager - Brave, , .5
	Sleep, 100
	SendPlay, ^l
	Sleep, 100
	SendPlay, {Tab}^a
	RestoreCapsDownState()
return

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
^+q::SendInput, {right}{Ctrl Down}{left}+{right}{Ctrl Up}

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
; ----------------------------------------------------------------------------
; Navigate between virtual desks
#o::Send, ^#{Left}
#p::Send, ^#{Right}
#If WinActive("ahk_exe Code.exe") and WinActive(".ahk -")
	F1::
		SendInput, {right}{CtrlDown}{right}+{left}^c{CtrlUp}
		ClipWait, .2
		if (ErrorLevel)
			return
		cursorWord := Trim(clipboard)
		DebugTip(cursorWord)
		; AutoHotkeyCommands(cursorWord) ; broken?
		SetTitleMatchMode, 2
		AutoHotkeyWindowText := "| AutoHotkey -"
		RunRestoreMinApp(AutoHotkeyWindowText, "https://autohotkey.com/docs/commands/")
		; RunRestoreMinApp(AutoHotkeyWindowText, "https://webcache.googleusercontent.com/search?q=cache:0m64PuHFC-wJ:https://www.autohotkey.com/docs/KeyList.htm+&cd=3&hl=en&ct=clnk&gl=us")
		SetTitleMatchMode, 2
		WinWaitActive, %AutoHotkeyWindowText%, , .5
		If (ErrorLevel) {
			DebugTip("Not found here!")
			return
		}
		OSD("waiting...")
		sleep, 100
		OSD("sending...")
		SetKeyDelay, 10, , Play
		SetKeyDelay, 10, , 
		SendEvent, ^l{Tab}{Esc}!ngi
		SendEvent, ^a^v{Enter}
		SendEvent, {Esc}w
		sleep, 100
		SendEvent, gg
	return
#If

#m:: WinMinimize, A
+#m:: win:=MaximizeRestore("A")

; Run window spy
#w::Run, "C:\Program Files\AutoHotkey\AU3_Spy.exe"

; #t::RunRestoreHideApp("Hangouts", "")
+#t::
#t::
OpenMessages:
	global browserExe
	keyHeld := GetKeyState("shift")
	if (keyHeld) {
		OpenBrowserTab("Mess|Facebook", "Messenger")
		return
	}

	OpenBrowserTab("Messages", "Messages")
return

#IfWinActive, WorkFlowy
^s::Send,^k
^+Enter::Send,+{Enter 2}{Enter}
#If

#s::RunRestoreHideApp("ahk_class ENMainFrame","C:\Users\Jordan\AppData\Local\Programs\Evernote\Evernote.exe")

^#e::
#e::
	GroupAdd, Explorers, ahk_class CabinetWClass
	RunCycleApp("Explorers", "C:\Users\Jordan\Downloads\", "ctrl")
	return
^#k::
#k::
	OpenBrowser()
return

OpenBrowserTab(tabName, windowName:="", launch:=1) {
	windowName := windowName ? windowName : tabName . " - "
	if (!tabName) windowName := ""
	SetTitleMatchMode, 2
	; OSD(A_DDD . " " . A_DD . " " . A_MMMM . " " . A_YYYY . "  " . A_Hour . ":" . A_Min, 2000)
	If (windowName && WinActive(windowName)) {
		WinMinimize
		return
	} else if (windowName && WinExist(windowName)) {
		WinActivate
		return
	}
	OpenBrowser(1, 1)
	SendInput, {ShiftUp}
	WinWaitActive, %browserExe%,, .1
	Send, !q
	Sleep, 200
	Log("Open tab: " tabName)
	if (!tabName) 
		return

	Suspend, on
	SendRaw, %tabName%
	if (launch) {
		Sleep, 300
		Send, {Enter}
	}
	Suspend, off
	return
}

OpenBrowser(waitActive:=0, noCycle:=0) {
	; TODO: Only select real brave windows
	; GroupAdd, Browser, ahk_exe chrome.exe,,,,Hangouts
	GroupAdd, Browser, %browserExe%,,,Hangouts,Hangouts
	; RunCycleApp("Browser", "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe", "ctrl")
	if (!noCycle || !WinActive(browserExe) || WinActive("Hangouts")) {
		; OSD(browserLocation)
		action := RunCycleApp("Browser", browserLocation, "ctrl")
	}
	While (noCycle && WinActive("Hangouts")) {
		Sleep, 50
	}
	if (waitActive) {
		WinWaitActive, %browserExe%,, .5
	}
	return action
}

^#j::
#j::
	GroupAdd, Consoles, ahk_class ConsoleWindowClass
	GroupAdd, Consoles, ahk_class mintty
	GroupAdd, Consoles, ahk_exe Terminus.exe
	; RunCycleApp("Consoles", "cmd", "ctrl")
	RunCycleApp("Consoles", "C:\Program Files\Terminus\Terminus.exe", "ctrl")
return

; open github
;#g::RunRestoreMinApp("GitHub ahk_class HwndWrapper[DefaultDomain;;6ef39290-3072-4acc-9987-9c336f2987b5]","C:\Users\Ash\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\GitHub Inc\GitHub.appref-ms")

^#n::
#n::
	GroupAdd, Code, ahk_exe Code.exe
	RunCycleApp("Code", A_Editor, "ctrl", "min")
return

; paste key stuff (to circumvent fields without paste, this just stuffs the keys)
;TODO: turn \r\n's into \r's
LWin & p::
~ RWin & o::
	SetKeyDelay, -1 ;100
	StringReplace, clip, clipboard, `r`n, `r, All
	SendRaw, %clip%
return

; LWin:: 
; return ; nothing

; yes, it does nothing.  used to disable keys
Noop:
return

RunCycleApp(group1, app, forcekey := "ctrl", activeAction := "") {
	keyHeld := 0
	if (forcekey != "")	{
		keyHeld := GetKeyState(forcekey)
	}
	if (keyHeld || !WinExist("ahk_group" . group1)) {
		DebugTip("ran")
		run, %app%
		return "ran"
	}
	if (WinActive("ahk_group" . group1)) {
		if ("min" = activeAction) {
			WinMinimize
			return "min"
		}
	}
	GroupActivate, %group1%, R
	return "act"
}

RunRestoreMinApp(title1, app, title2 := "") {
	DetectHiddenWindows, On
	app = "%app%"
	If (WinExist(title1) or (title2 != "" and WinExist(title2))) {
		IfWinActive 
		{
			WinMinimize
			return "min"
		} else {
			WinShow
			WinActivate
			return "act"
		}
	} else {
		Run, %app%
		return "ran"
	}
}

RunRestoreHideApp(title1,app, app2 := "") {
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
#b::Send, {alt down}d{alt up}*{space}

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

#Warn All, Off
#!k::
Lock:
	RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Policies\System, DisableLockWorkstation, 0
	if (ErrorLevel) {
		OSD(A_LastError)
		return
	}
	DllCall("LockWorkStation")
	sleep, 1000
	RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Policies\System, DisableLockWorkstation, 1
return
; #Warn

; -------------------------------------------------------------------------
; Temporary scripts -------------------------------------------------------
; -------------------------------------------------------------------------

IsMappedWindow(this_id) {
	WinGetPos,X,Y,W,H,ahk_id %this_id%
	return !(X = 0 && Y = 0 && W = 0 && H = 0)
}

SaveWinCoords(this_id, wintitle) {
	WinGetPos,X,Y,W,H,ahk_id %this_id%
	WinGetTitle, title, ahk_id %this_id%
	WinGetClass, klass, ahk_id %this_id%
	coords := Join(",", [X,Y,W,H]*)
	Log("coords: " title " " klass " " A_Index " ahk_id " this_id "---" coords)
	IniWrite, % coords, hotkeys.ini, WinPos %wintitle%, %title%%klass%
}

LoadWinCoords(this_id, wintitle) {
	; global
	; Log("coords: " title " " this_class " " A_Index " ahk_id " this_id "---")
	WinGetTitle, title, ahk_id %this_id%
	WinGetClass, klass, ahk_id %this_id%
	IniRead, coords, hotkeys.ini, WinPos %wintitle%, %title%%klass%
	vals := StrSplit(coords, ",")
	; Log(QuotedVar("vals"))
	X := vals[1], Y := vals[2], W := vals[3], H := vals[4]
	; Log(QuotedVar("X") QuotedVar("Y") QuotedVar("W") QuotedVar("H"))
	; MsgBox, %vals1%, %vals2%, %vals3%, %vals4%
	WinMove, ahk_id %this_id%,, %X%, %Y%, %W%, %H%
	Log("coords: " title " " this_class " " A_Index " ahk_id " this_id "---" coords)
}

^!+1::
	LoopWindows("ahk_exe Zoom.exe", "IsMappedWindow", "SaveWinCoords")
return	

^!1::
	LoopWindows("ahk_exe Zoom.exe", "IsMappedWindow", "LoadWinCoords")
return	

^!0::
    WinMove, A,,0,0,500,500
return

^!+2::
	MouseGetPos,KDE_X1,KDE_Y1,KDE_id

	LoopWindows("ahk_exe Zoom.exe", "IsMappedWindow", "SaveWinCoords")
return	

^!2::
	LoopWindows("ahk_exe Zoom.exe", "IsMappedWindow", "LoadWinCoords")
return	


LoopWindows(title, filter:=0, action:=0) {
	WinGet, win_list, List, %title%
	Loop, %win_list%
	{
		this_id := win_list%A_Index%
		if (filter && !(filter.(this_id)))
			Continue
		if (action) 
			action.(this_id, title)
	}
}

; MonSwap - Swaps all the application windows from one monitor to another.
; v1.0.1
; Author: Alan Henager
;
; v1.0.1 - xenrik - Updated to use relative screen size when swapping


; Set this key combination to whatever.
^+#s::
SwapAll:
{
  SetWinDelay, 0 ; This switching should be instant
  DetectHiddenWindows, Off ; I think this is default, but just for safety's sake...
  WinGet, WinArray, List ; , , , Sharp
  ; Enable the above commented out portion if you are running SharpE

  i := WinArray
  Loop, %i% {
	; if (A_Index > 100) {
	; 	OSD("Max index reached")
	; 	break
	; }
	; OSD("Max index reached: " A_Index)

	WinID := WinArray%A_Index%
	WinGetTitle, CurWin, ahk_id %WinID%
	; If (CurWin = "") ; For some reason, CurWin <> didn't seem to work.
	; {}
	; OSD(QuotedVar("WinID"))

	if (Curwin != "" && Curwin != "Setup") {
		WinGet, IsMin, MinMax, ahk_id %WinID% ; The window will re-locate even if it's minimized
		If (IsMin = -1) {
			WinRestore, ahk_id %WinID%
			SwapMon(WinID)
			WinMinimize, ahk_id %WinID%
		} else {
			SwapMon(WinID)
		}
	}
  }
  OSD("swap done")
  return
}

; ~MButton::
	MouseGetPos, ClickX, ClickY, win_id
	if (InTitleBar()) {
		SwapMon(win_id)
	}
return

SwapMon(WinID, scaling:=1) ; Swaps window with an ID of WinID onto the other monitor
{
	WinGet, IsMin, MinMax, ahk_id %WinID% ; The window will re-locate even if it's minimized

	SysGet, Mon1, Monitor, 1
	Mon1Width := Mon1Right - Mon1Left
	Mon1Height := Mon1Bottom - Mon1Top

	SysGet, Mon2, Monitor, 2
	Mon2Width := Mon2Right - Mon2Left
	Mon2Height := Mon2Bottom - Mon2Top

	WinGetPos, WinX, WinY, WinWidth, WinHeight, ahk_id %WinID%
	WinCenterX := WinX + (WinWidth / 2)
	WinCenterY := WinY + (WinHeight / 2)
	NewWidth := WinWidth 
	NewHeight:= WinHeight

	if (WinCenterX >= Mon1Left and WinCenterX <= Mon1Right and WinCenterY >= Mon1Top and WinCenterY <= Mon1Bottom) {
		Src := 1
		Dest := 2
	} else {
		Src := 2
		Dest := 1
	}
	for i, subvar in ["Left", "Right", "Top", "Bottom", "Width", "Height"] {
		Dest%subvar% := Mon%Dest%%subvar%
		Src%subvar% := Mon%Src%%subvar%
	}
	if (IsMin = 1) {
		NewWidth := DestWidth
		NewHeight := DestHeight
	} else if (scaling) {
		NewWidth *= DestWidth / SrcWidth
		NewHeight *= DestHeight / SrcHeight
	}
	NewX := (WinX - SrcLeft) / SrcWidth
	NewX := DestLeft + (DestWidth * NewX)
	NewY := (WinY - SrcTop) / SrcHeight
	NewY := DestTop + (DestHeight * NewY)
	WinMove, ahk_id %WinID%, , %NewX%, %NewY%, %NewWidth%, %NewHeight%
	return
}
