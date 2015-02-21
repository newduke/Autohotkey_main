; ErgoBreaks.ahk
; author: Jordan Weitz (newduke@gmail.com) 
;
; TODO: improve GUI (add pictures?)
; TODO: save state to .ini so times aren't reset by script reload


; Fall-through for auto-execute
SetupErgoBreak:
	; constants
	; (seconds) time between breaks
	eb_interval := 1200		
	; (seconds) time between nags
	eb_nag := 60			
	; sound file to play when nagging
	eb_ergo_sound := "" ;boing_x.wav"
	; | separated list of messages to deliver.  
	; Loops back to first message after delivering all messages
	eb_instructions := "Backbend and twist.|Leg stretch|Neck stretch"
	; Max number of missed nags before auto-off
	eb_maxnag = 8
	
	; set up intermediates
	StringSplit, eb_texts, eb_instructions, |
	eb_field := 1
	eb_numfields := eb_texts0
	eb_ignorednags := 0

	; set up GUI
	Gui, ergo:new
	Gui, ergo:+hwndeb_hwnd
	Gui, ergo:margin, 15, 15
	Gui, ergo:color, FF3333
	Gui, ergo:add, text, w500, Time for a break!
	Gui, ergo:add, text, vErgoText, Special instructions...
	Gui, ergo:add, button, gErgoDone Default, Done
	Gui, ergo:add, button, gErgoDelay3 x+20, Gimme 3
	
	; set timer
	SetErgoTimer(eb_interval)
return

GetErgoTimer() {
	global eb_zero
	if (eb_zero = 0)
		return 0
	return (eb_zero - A_TickCount)/1000
}

SetErgoTimer(time) 
{
	global eb_zero, eb_exit
	eb_exit := 1
	if (time = 0) {
		eb_zero := 0
		SetTimer, ErgoNag, Off
		return
	}
	SetTimer, ErgoNag, % time*1000
	eb_zero := A_tickcount + time*1000
}

ShowTickCount()
{
	global eb_zero
	if (eb_zero = 0)
		ToolTip, Disabled
	else
		ToolTip, % GetErgoTimer()/60 . " minutes"
	SetTimer, HideTip, -1500
}

; Display time left on current nag
eb_display_time() {
	ShowTickCount()
}

; Set current nag to secs
eb_set_timer(secs) {
	eb_ignorednags := 0
	SetErgoTimer(secs)
	ShowTickCount()
}
; Add secs to current nag
eb_set_timer_rel(secs) {
	eb_set_timer(secs + GetErgoTimer())
}

; Toggle nagger
eb_toggle() {
	eb_ignorednags := 0
	gosub ErgoHide
	if (eb_zero = 0)
		SetErgoTimer(eb_interval)
	else
		SetErgoTimer(0)
	ShowTickCount()
}

; Display nag window, flashing it
^#n::eb_show_nag()

eb_show_nag()
{
	global eb_field, eb_texts
ErgoNag:
	eb_ignorednags += 1 
	GuiControl, ergo:, ErgoText, % eb_texts%eb_field%
	Gui, ergo:show, NA
	; Toggle the AlwaysOnTop to ensure the window stacks above all other windows (even though it doesn't activate)
	WinSet,AlwaysOnTop,Toggle,ahk_id %eb_hwnd%
	WinSet,AlwaysOnTop,Toggle,ahk_id %eb_hwnd%
	; if too many nags were ignored, bail on nags.
	if (eb_ignorednags > eb_maxnag) {
		; disable nags?
		;SetErgoTimer(0)
		;return
	}
	else
		SoundPlay, % eb_ergo_sound
	SetErgoTimer(eb_nag)
	eb_exit := 0
	Loop, 3
	{
		Sleep, 300
		Gui, ergo:show, hide
		Sleep, 200
		if (eb_exit)
			break
		Gui, ergo:show, NA
	}
	if (eb_exit) {
		; MsgBox, "race condition: exit specified, window still showing"
		gosub ErgoHide
	}
return
}

; Hide window, setting nag timer to eb_nag
^#m::
	SetErgoTimer(eb_nag)
	gosub ErgoHide
return
	
ErgoHide:
	eb_exit := 1
	Gui, ergo:show, hide
return

; Hide window, reset nag timer, go to next nag field
ErgoDone:
	gosub ErgoHide
	eb_ignorednags := 0
	eb_field := mod(eb_field, eb_numfields) + 1
	SetErgoTimer(eb_interval)
return

; Hide window, set 3-minute delay
ErgoDelay3:
	Gosub ErgoHide
	SetErgoTimer(180)
return

