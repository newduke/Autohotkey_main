; Old applications ---------------------------------------------------------------
; Focus Tictrac
;~ #t::RunRestoreMinApp("Tictrac - Google Chrome ahk_class Chrome_WidgetWin_1", "https://www.tictrac.com/project/back-pain")
; Focus Toggl
;#t::RunRestoreHideApp("Toggl ahk_class Chrome_WidgetWin_0", "C:\Program Files (x86)\Toggl\TogglDesktop\TogglDesktop.exe")

; This is how you can use fn hotkey.  see also http://www.autohotkey.com/docs/KeyList.htm#SpecialKeys
; SC163::ToolTipTime("fn")
; return

; "take a break" timer shortcuts ------------------------------------------
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

; change brightness (gamma ramp)
br := 128   ; brightness, in the range of 0 - 255, where 128 is normal
^#WheelUp::
^#WheelDown::
	br += (InStr(A_ThisHotkey, "down") ? -8 : 8 )
	If ( br > 256 )
		br := 256
	If ( br < 0 )
		br := 0
	VarSetCapacity(gr, 512*3)
	Loop,   256
	{
	   If  (nValue:=(br+128)*(A_Index-1))>65535
	        nValue:=65535
	   NumPut(nValue, gr,      2*(A_Index-1), "Ushort")
	   NumPut(nValue, gr,  512+2*(A_Index-1), "Ushort")
	   NumPut(nValue, gr, 1024+2*(A_Index-1), "Ushort")
	}
	hDC := DllCall("GetDC", "Uint", 0)
	DllCall("SetDeviceGammaRamp", "Uint", hDC, "Uint", &gr)
	DllCall("ReleaseDC", "Uint", 0, "Uint", hDC)
return


; WIP Colemak -------------------------------------------------------------
{
;~ 0 = colemak; 1 = qwerty
KeyboardToggle := 1
keyboardNames1 := "Qwerty", keyboardNames0 := "Colemak"

; Colemak keyboard, only when not in meta state.
#If 0 AND (NOT ((GetKeyState("Control", "P")) OR (GetKeyState("Alt", "P")) OR (GetKeyState("LWin", "P")) 
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

	;~ +�::"
	;~ �::'
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
	
	;~ ; p->�
	;~ p::SC027
	;~ ; SC01A::SC027 ; 27=�
	;~ ; �->�
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

;LWin & !k::goto KillActive
;RWin & !k::goto KillActive
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


;#h::
; record a macro
input, myMacro, V T60, {RControl}
IfInString, ErrorLevel, EndKey
{
	MsgBox, = = %myMacro%
}
return

; example: +Backspace::MsgBox % "Morse press pattern " Morse()
; Morse turns long and short keypresses into a return pattern of 0's and 1's
Morse(timeout = 400) {
   tout := timeout/1000
   key := RegExReplace(A_ThisHotKey,"[\*\~\$\#\+\!\^]") ; remove modifiers: +BS -> BS
   Loop {
	  t := A_TickCount
	  KeyWait %key%					  ; Wait for key release
	  Pattern .= A_TickCount-t > timeout ; How long the key was pressed
	  
	  Input k,L1MT%tout%V,{LControl}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{Capslock}{Numlock}{PrintScreen}{Pause}
	  If (ErrorLevel && ErrorLevel != "Max" && ErrorLevel != "EndKey:" key
		 || !ErrorLevel && k != key)	 ; Break at long no-press time or foreign keys
		 Return Pattern
   }
}

; input repeated
; ex: input: "5q" sends "qqqqq"
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
#if

; --------------------------------------------------------------------------
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

; F1::
; Broken attempt to load autohotkey help into memory
AutoHotkeyCommands(q:="") {
	static command
	; global c := q
	; ToolTipTime(QuotedVar("c"))
	url:="https://autohotkey.com/docs/commands/"
	
	If (q="")	
		If !(q:=Trim(CtrlC()," `t`n`r"))
			Return
	If !(0 command){
		html:=UrlDownloadToVar(url), command:={}, i:=1
		While i:=RegExMatch(html,"<a href=""([^""]*)"">([^<]*)</a>",s,i+1)
			command[s2]:=s1
	}
	; global c := command
	; ToolTipTime(QuotedVar("c"))

	If (v:=command[q]) || (v:=command[q "()"])
		t:=url v
	Else
		For k,v in command
			If InStr(k,q){
				t:=url v
				Break
			}
	If t
		Run % t	
Return
}
CtrlC(){
	WholeClipBoard:=ClipBoardAll
	ClipBoard =
	Send ^c
	ClipWait,.3
	str:=ClipBoard
	ClipBoard:=WholeClipBoard
	Return, str
}
; This is erroring
UrlDownloadToVar(URL) {
	ComObjError(false)
	WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	WebRequest.SetTimeouts(5000, 5000, 3000, 3000)
	WebRequest.Open("GET", URL)
	WebRequest.Send()
	TooltipTime("doh!" . A_LastError,3000)
	Return WebRequest.ResponseText
}
