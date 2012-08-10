; various other scripts to run
#include ArrowKeyS.ahk
SetWinDelay,2
CoordMode,Mouse

; common variables ---------------------------------------------------------
;A_Editor = "C:\Program Files\TextPad 4\TextPad.exe"
A_Editor = "C:\Program Files\AutoHotkey\SciTE_beta5\SciTE.exe"
;A_Editor = "c:\Windows\Notepad.exe"

; Initialize variables for borderless script: http://www.autohotkey.com/community/viewtopic.php?t=84446
X := 0
Y := 0
W := A_ScreenWidth
H := A_ScreenHeight

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
;--------------------------------------------------------------------------

;;!! I've forgotten what this is all about.
;;TODO: document me.
;OnMessage(0x4a, "Receive_WM_COPYDATA")  ; 0x4a is WM_COPYDATA
OnMessage(0x4a, "Receive_Hold")


;--------------------------------------------------------------------------
; for debugging, there is a GUI caled vDebugOut.  
; Also consider debugging in SciTE.
;Gui, Add, Edit, r9 vMyEdit, Text to appear inside the edit control 
Gui, Add, ListBox, w500 h300 vDebugOut, 
;Gui, Show

;;;!! need 5-button mouse
#include Mouse Gestures.ahk
Menu, TRAY, Icon, "Mouse Gestures.ico"

#include KDEDrag.ahk
#include ArrowKey.ahk

;;; no longer needed.  KDE drag has push-back; win 7 has finder in start menu
;#include WindowPushback.ahk
;#include FindIt.ahk

; text expansions ---------------------------------------------------------
;;!! text expansions are messing with timers
;;TODO: fixme
/*::uus::the United States
::hhg::Hope Josephine Maranatha Gardner
::aaj::Ashley Jordan
::jjw::Jordan Weitz
::cliche::cliché
;--------------------------------------------------------------------------
*/
; these scripts will work even with LWin disabled (so they work in games)
;~LWin & WheelUp::SoundSet, +10 ; Win+MouseWheel forward: Louder
;~LWin & WheelDown::SoundSet, -10 ; Win+MouseWheel backward: Lower
;~LWin & Numpad0::SoundSet, +1,, mute ; Win+Numpad0: Volume on/off

^!r::reload
^!e::run, %A_Editor% AutoHotkey.ahk, %A_ScriptDir%
^!t::run, %A_Editor% %A_ScriptDir%\Specific\%LastScriptFile%
^+!Space::Suspend 

^+F1::run, www.google.com/ig
^+F2::run, https://udn.epicgames.com/Three/WebChanges
^+F3::run, http://gmail.google.com

/*XButton1::
;f11::
send,!t
send,b{up}{up}{enter}
return
*/
/*XButton2::
      send,!t
      send,b{up}{up}{enter}
      return
*/

; The up key on the logitech is in a weird spot
up::Shift
; Toggle the up macro
^!z::
Hotkey, *up, toggle
Hotkey, *up up, toggle
return

Beeep()
{
	SoundPlay, *48
}

Receive_Hold()
{
	global
	HoldLastScriptFile := LastScriptFile
	;Beeep()
	;MsgBox
	;ToolTip %HoldLastScriptFile%`n%lastTitle%`nA blank string was received or there was an error.
	return true
}

Receive_WM_COPYDATA(wParam, lParam)
{
	lpDataAddress := lParam + 8  ; This is the address of CopyDataStruct's lpData member.
	lpData := 0  ; Init prior to accumulation in the loop.
	Loop 4  ; For each byte in the lpData integer
	{
		lpData := lpData | (*lpDataAddress << 8 * (A_Index - 1))  ; Build the integer from its bytes.
		lpDataAddress += 1  ; Move on to the next byte.
	}
	; lpData contains the address of the string to be copied (must be a zero-terminated string).
	DataLength := DllCall("lstrlen", UInt, lpData)
	if DataLength <= 0
		ToolTip %A_ScriptName%`nA blank string was received or there was an error.
	else
	{
		VarSetCapacity(CopyOfData, DataLength)
		DllCall("lstrcpy", str, CopyOfData, UInt, lpData)  ; Copy the string out of the structure.
		; Show it with ToolTip vs. MsgBox so we can return in a timely fashion:
		ToolTip %A_ScriptName%`nReceived the following string:`n%CopyOfData%
	}
	return true  ; Returning 1 (true) is the traditional way to acknowledge this message.
}

; window stats
^!y::run, WindowStats.ahk

;!! count words? WTF?
^F2::
If WinActive("ahk_class WindowsForms10.Window.8.app.0.218f99c")
{
	ID := WinExist("ahk_class WindowsForms10.Window.8.app.0.218f99c")
	ControlGetFocus, Focused, ahk_id %ID%
	ControlGetText, Text, %Focused%, ahk_id %ID%
	RegExReplace( Text, "\w+", "", Count )
	MsgBox, 64, Word Count, %  "Words:`t" Count
}
Return


;!! Document me (and others)
^#e::
#e::
GroupAdd, Explorers, ahk_class CabinetWClass
RunCycleApp("Explorers", "c:\", "ctrl")
return
^#q::
#q::
GroupAdd, Chrome, ahk_class Chrome_WidgetWin_0
GroupAdd, Chrome, ahk_class Chrome_WidgetWin_1
RunCycleApp("Chrome", "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe", "ctrl")
return
^#j::
#j::
GroupAdd, Consoles, ahk_class ConsoleWindowClass
RunCycleApp("Consoles", "cmd", "ctrl")
return

;;; Control iTunes --------------------------------------------------------------------------
;;#i::RunRestoreHideApp2("iTunes","iTunes","iTunes")
#i::RunRestoreHideApp2("Spotify","C:\Users\Ash\AppData\Roaming\Spotify\spotify.exe","Spotify")
;Browser_Back::
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
#Volume_up::
IfWinExist, ahk_class SpotifyMainWindow
ControlSend, ahk_parent, ^{up}  ; volume up
return
#down::
#Volume_down::
IfWinExist, ahk_class SpotifyMainWindow
ControlSend, ahk_parent, ^{down}  ; volume downa
return

;LWin & !k::goto KillActive
;RWin & !k::goto KillActive
;paste
;TODO: turn \r\n's into \r's
LWin & o::
RWin & o::
SetKeyDelay, -1 ;100
StringReplace, clip, clipboard, `r`n, `r, All
SendRaw, %clip%
return

^!n::
#n::
;~ RunRestoreHideApp("TextPad ","TextPad")
;~ GroupAdd, Editors, TextPad -
;~ GroupAdd, Editors, NotePad
;~ GroupAdd, Editors, ahk_class OpusApp;Microsoft Word
;~ GroupActivate, Editors, R
run, %A_Editor%
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

;#h::
; record a macro
input, myMacro, V T60, {RControl}
IfInString, ErrorLevel, EndKey
{
	MsgBox, = = %myMacro%
}
return

#p::
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
GetKeyState, AltHeld, RWin, P
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

;^!i::
GetAllWindows:
	WinGet, AllWindows, list,,, Program Manager
	loop, 0;3 ;%AllWindows%
	{
		foo := AllWindows%A_Index%
		WinGetTitle, title, ahk_id %foo%
		msgbox, %title%, %foo%
	}
return
	

;////////////////////////////////////////////////////////////////////////
CheckFullScreen:
	WinGetTitle, title, A
	if (title != lastTitle)
	{
		lastTitle := title
		; these windows need to go away.  kill em!
		if (lastTitle == "Purchase Reminder")
		{
			Send, {tab}{enter}
		}
		else if (lastTitle == "Please purchase WinRAR license")
		{
			Send, {tab}{tab}{enter}
		}
		else if (lastTitle == "Automatic Updates")
		{
;			Send, !l
		}
		else if (lastTitle == "Compare It!")
		{
			Send, {enter}
		}
		
	}


	;////////////////////////////////////////////////////////////////////////
	WinGet, title, ProcessName, A
	StringTrimRight, title, title, 4 ; strip .exe
	;WinGetTitle, title, A
	;StringMid, beg, title, 0, 3
	;if (beg = "BF2") 
	;	title := "BF2"
	ScriptFile := Title . ".ahk"
	Empty :=
	SplitPath, title,,,ext
	if (ext != "ahk" && Title != Empty && ScriptFile != LastScriptFile)
	{
		;GuiControl, Text, DebugOut, %ScriptFile%
		;GuiControl, Text, DebugOut, %ext%
			
		; find the old running script and kill it
		; have to be sure it's class AutoHotkey or it might match, say,
		;   an editor editing a script of the same name.
		DetectHiddenWindows, On
		SetTitleMatchMode, 2
		;MsgBox, %LastScriptFile%
		If (HoldLastScriptFile != LastScriptFile)
		{
			IfWinExist, %LastScriptFile% ahk_class AutoHotkey
			{
				;MsgBox, %LastScriptFile%
				If (LastScriptFile != "Autohotkey.ahk")
					WinClose
			}
		}
		HoldLastScriptFile := ""
		; if a script of the correct name exists, run it here
		IfExist, %A_scriptdir%\Specific\%ScriptFile%
		{
			; i hate that message that tells me i'm reloading a script
			IfWinNotExist, %ScriptFile% ahk_class AutoHotkey
			{
				run, "%A_scriptdir%\Specific\%ScriptFile%"
			}
		}
		; remember the name of this process regardless of whether a script is running
		LastScriptFile := ScriptFile
	}
	fs_latched := IsFullScreen()
	if (LastScriptFile = "Guild Wars.ahk")
		fs_latched := 1
	if (fs_latched != fs)
	{
		fs := fs_latched
		Full_Only := "Off"
		Windowed_Only := "On"
		if (fs)
		{
			Full_Only := "On"
			Windowed_Only := "Off"
		}
/*		IfWinExist, Mouse Gestures
		{
			;WinGetTitle, title
			;IfInString, (disabled)
			;	If (
			;SoundBeep
			Send, ^\
		}
		*/
		Disabled := 1 - fs
		gosub ToggleActive
		Hotkey, !LButton, %Windowed_Only%
		Hotkey, !RButton, %Windowed_Only%
		Hotkey, !MButton, %Windowed_Only%
		Hotkey, LAlt & WheelDown, %Windowed_Only%
		Hotkey, LAlt & WheelUp, %Windowed_Only%
		Hotkey, ^!e, %Windowed_Only%
		;Hotkey, ^!a, %Windowed_Only%
		Hotkey, ^!r, %Windowed_Only%
		Hotkey, !MButton, %Windowed_Only%
		Hotkey, LWin, %Full_Only%
		Hotkey, *Capslock, %Windowed_Only%
	}
return

CMDret(CMD)
{
  VarSetCapacity(StrOut, 10000)
  RetVal := DllCall("cmdret.dll\RunReturn", "str", CMD, "str", StrOut)
  Return, %StrOut%
}

RunRestoreHideApp2(title1, app, title2)
{
	DetectHiddenWindows, On
	SetTitleMatchMode, 2
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
			;~ WinGetPos, X, Y
			;~ MsgBox, %X% . ", " . %Y%
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
; returns 1 if the active app is full screen (as indicated by a window at 0,0 which extends to the full bounds of the desktop
IsFullScreen()
{
	WinGetActiveStats, Title, Width, Height, X, Y
	; need to special case this, as this is in fact a full screen window, but
	; it occurs when no apps are full screen
	If Title = Program Manager
		return 0
	If Title = Chrome
		return 0
	;MsgBox, %Title%
	;MsgBox %X%, %Y%, %Width%, %Height%, --  %A_ScreenWidth%, %A_ScreenHeight%
	if X != 0
		return 0
	if Y != 0
		return 0
	;SoundBeep
	;if Width == %A_ScreenWidth% && Height == %A_ScreenHeight%
	;	return 1
	;SoundBeep
	;MsgBox, %Width%"," %Height%", -- " %A_ScreenWidth%"," %A_ScreenHeight%
	if (width = %A_ScreenWidth% && Height = %A_ScreenHeight%)
		return 1
/*	if (Width = 640 && Height = 480)
		return 1
	if (Width = 800 && Height = 600)
		return 1
	if (Width = 1024 && Height = 768)
		return 1
	if (Width = 1152 && Height = 864)
		return 1
	if (Width = 1280 && Height = 1024)
		return 1
	if (Width = 1600 && Height = 1200)
		return 1
		*/
	;SoundBeep
	return 0
}

HideAIM:
DetectHiddenWindows, On
SetTitleMatchMode, 2
IfWinExist, Default Away Message
{
	WinActivate
	;WinWaitActive
	Send, {Enter}
}
else IfWinExist, Buddy List
{
	;WinActivate
	SendMessage, 0x111, 24003, 0
	;WinMenuSelectItem, Buddy List,,My AIM,Away Message,Default Away Message
	;MsgBox, Buddy
}
return

/*
#i::
WinGetClass, cl, A
If cl=wndclass_desked_gsk
{
	WinGet, hwnd, ID, A
	WinGet, ActiveControlList, ControlList, A
	Loop, Parse, ActiveControlList, `n
	{
		ControlGetText, ctitle, %A_LoopField%, A
		if ctitle=Output
		IfInString, A_LoopField, GenericPane
		{
			ControlGet, hwnd, ID, , A_LoopField, A
			SendMessage, 0x1043, 0, 0, A_LoopField, A
			SendMessage, 0x07B, 0, 0, A_LoopField, A
			;SendMessage, 0x1043, 0, 0, A_LoopField, A
			ControlClick, A_LoopField, A,,RIGHT
		}
	}
	
}
return
*/

; comment me! -------------------------------------------------------------
#c::
SetKeyDelay, -1  ; Most editors can handle the fastest speed.
send, {home}+{end}^c ; select all, copy
send, {- 75} ; line-o-dashes
send, {home}{insert}^v {insert}{home} ; paste old text back on top
return

^!u::
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
return

;/////////////////////////// Test /////////////////////////////////////////////


;!!! read, understand, modify, comment:
#w::
   WinGet, window, ID, A   ; Use the ID of the active window.
   Toggle_Window(window)
return

!^w::
   MouseGetPos,,, window   ; Use the ID of the window under the Mouse.
   Toggle_Window(window)
return

Toggle_Window(window)
{
   global X, Y, W, H   ; Since Toggle_Window() is a function, set Up X, Y, W, and H as globals
   WinGet, S, Style, % "ahk_id " window   ; Get the style of the window
   If (S & +0x840000)      ; if not borderless
   {
      WinGetPos, X, Y, W, H, % "ahk_id " window   ; Store window size/location
      XMed := (2* X + W) / 2   ; Find the middle of the window
      YMed := (2* Y + H) / 2   ; Find the middle of the window
      ; We check to see if the current window is outside of the default monitor.
      ; If it is, we increment our multiplier and try the next window (in all 4 directions).
      ; NOTE: This won't work for multi-monitor setups with different resolutions.
      Loop
      {
         if(XMed > A_ScreenWidth * A_Index || XMed < A_ScreenWidth * (-1 * A_Index))
            continue
         if(XMed > A_ScreenWidth * (A_Index - 1))
            XPos := (A_Index - 1) * A_ScreenWidth
         else
            XPos := (-1 * A_Index) * A_ScreenWidth
         break
      }
      Loop
      {
         if(YMed > A_ScreenHeight * A_Index || YMed < A_ScreenHeight * (-1 * A_Index))
            continue
         if(YMed > A_ScreenWidth * (A_Index - 1))
            YPos := (A_Index - 1) * A_ScreenHeight
         else
            YPos := (-1 * A_Index) * A_ScreenHeight
         break
      }
	  WinSet, Style, -0x840000, % "ahk_id " window   ; Remove borders
	  ;WinSet, Style, ^0xC00000 ; toggle title bar

      ;WinMove, % "ahk_id " window,, %XPos%, %YPos%, %A_ScreenWidth%, %A_ScreenHeight%  ; Stretch to Screen-size
      return
   }
   If (S & -0x840000)      ; if borderless
   {
      WinSet, Style, +0x840000, % "ahk_id " window   ; Reapply borders
      ;WinMove, % "ahk_id " window,, X, Y, W, H      ; return to original position
      return
   }
   Return   ; return if the other if's don't fire (shouldn't be possible in most cases)
}
