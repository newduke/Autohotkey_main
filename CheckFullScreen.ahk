;--------------------------------------------------------------------------
; Setup the program-specific scripts.  A timer is run that checks whether
; the foreground app has changed, and if so, it kills the old specific
; ahk and loads in the new one.


;  --------------------------------------------------------------------------
; CheckFullScreen disables certain macros for fullscreen games and also launches specific ahk files
; based on the new current process
CheckFullScreen:
	WinGetTitle, title, A
	if (title != lastTitle)
	{
		lastTitle := title
		func := "WindowChanged"
		if (IsFunc(func))
			%func%(title)
	}

	;////////////////////////////////////////////////////////////////////////
	WinGet, title, ProcessName, A
	StringTrimRight, title, title, 4 ; strip .exe
	ScriptFile := Title . ".ahk"
	Empty :=
	SplitPath, title,,,ext
	if (ext != "ahk" && Title != Empty && ScriptFile != LastScriptFile)
	{
		; find the old running script and kill it
		; have to be sure it's class AutoHotkey or it might match, say,
		;   an editor editing a script of the same name.
		DetectHiddenWindows, On
		SetTitleMatchMode, 2
		If (HoldLastScriptFile != LastScriptFile)
		{
			IfWinExist, %LastScriptFile% ahk_class AutoHotkey
			{
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
		if (IsFunc("FullScreenChanged"))
			FullScreenChanged(fs)
	}
return

FullScreenChanged(fs) {
	Full_Only := "Off"
	Windowed_Only := "On"
	if (fs)
	{
		Full_Only := "On"
		Windowed_Only := "Off"
	}

	Hotkey, Alt & LButton, %Windowed_Only%,, UseErrorLevel
	Hotkey, Alt & RButton, %Windowed_Only%,, UseErrorLevel
	Hotkey, Alt & MButton, %Windowed_Only%,, UseErrorLevel
	Hotkey, Alt & WheelDown, %Windowed_Only%,, UseErrorLevel
	Hotkey, Alt & WheelUp, %Windowed_Only%,, UseErrorLevel
	Hotkey, ^!e, %Windowed_Only%
	;Hotkey, ^!a, %Windowed_Only%
	Hotkey, ^!r, %Windowed_Only%
	Hotkey, LWin, %Full_Only%
	Hotkey, *Capslock, %Windowed_Only%
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
	if X != 0
		return 0
	if Y != 0
		return 0
	if (width = %A_ScreenWidth% && Height = %A_ScreenHeight%)
		return 1
	return 0
}
