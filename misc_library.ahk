;common functions ---------------------------------------------------------
global vHotkeyText
global vMyText
global MyText

; counter := new SecondCounter
; counter.Start()
; Sleep 5000
; counter.Stop()
; Sleep 2000

; An example class for counting the seconds...
class OSDManager {
    __New(label) {
		ToolTipTime("NEW")

        this.interval := 1000
		this.label := label
        this.count := 0
        ; Tick() has an implicit parameter "this" which is a reference to
        ; the object, so we need to create a function which encapsulates
        ; "this" and the method to call:
        this.timer := ObjBindMethod(this, "HideOSD")
		this.OSDSetup()
    }
    ; Start() {
    ;     ; Known limitation: SetTimer requires a plain variable reference.
    ;     timer := this.timer
    ;     SetTimer % timer, % this.interval
    ;     ToolTip % "Counter started"
    ; }
    ; Stop() {
    ;     ; To turn off the timer, we must pass the same object as before:
    ;     timer := this.timer
    ;     SetTimer % timer, Off
    ;     ToolTip % "Counter stopped at " this.count
    ; }
    ; ; In this example, the timer calls this method:
    ; Tick() {
    ;     ToolTip % ++this.count
    ; }
	OSDSetup() {
		ToolTipTime("SETUP")
		; static
		CustomColor := "010102"  ; Can be any RGB color (it will be made transparent below).
		; Gui %label%:+LastFound +AlwaysOnTop -Caption +ToolWindow  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
		Gui, New, +HwndGuiHwnd
		Gui +LastFound +AlwaysOnTop -Caption +ToolWindow  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
		Gui, %GuiHwnd%:Default
		Gui, Color, %CustomColor%
		Gui, Font, s32  ; Set a large font size (32-point).
		; vMyText needs to be class variable
		Gui, Add, Text, vMyText HwndTextHwnd cFFFFFF, XXXXX YYYYY YYYYY ; XX & YY serve to auto-size the window.
		; Make all pixels of this color transparent and make the text itself translucent (150):
		WinSet, TransColor, %CustomColor% 150
	}
	OSD(text, time:=1000) {
		ToolTipTime("START", 5000)
        timer := this.timer
		label := this.label
        ; SetTimer % timer, % time

		; SetTimer, HideOSD, %time%
		GuiControl,%label%:, MyText, %text%
		Gui %label%:+LastFound +AlwaysOnTop -Caption +ToolWindow  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
		WinSet, TransColor, %CustomColor% 150
		; Gui, Show, x0 y400 NoActivate  ; NoActivate avoids deactivating the currently active window.

		CurrentMon := 0
		MouseGetPos, MouseX, MouseY
		Loop {
			CurrentMon := CurrentMon + 1
			SysGet, Monitor, MonitorWorkArea, %CurrentMon%
			if (MonitorLeft = "")
				break
			if (MouseX >= MonitorLeft and MouseX <= MonitorRight and MouseY >= MonitorTop and MouseY <= MonitorBottom) {
				CenterX := (MonitorLeft + MonitorRight)/2 - 200
				global guiY := MonitorBottom - 150
				; ToolTipTime(QuotedVar("guiY"))
				Gui, %label%:Show, x%CenterX% y%guiY% NoActivate  ; NoActivate avoids deactivating the currently active window.
				; Gui, Show, xCenter y400 NoActivate  ; NoActivate avoids deactivating the currently active window.
				break
			}
		}
	}

	HideOSD() {
		label := this.label
		Gui, %label%:Hide
	}
}

main_osd := new OSDManager("OSD")
; OSD(text, time:=1000) {
; 	ToolTipTime("OSD", 1000)
; 	main_osd.OSD(text, time)
; }

; static
	CustomColor := "010102"  ; Can be any RGB color (it will be made transparent below).
	Gui OSD:+LastFound +AlwaysOnTop -Caption +ToolWindow  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
	Gui, OSD:New
	Gui, OSD:Color, %CustomColor%
	Gui, OSD:Font, s32  ; Set a large font size (32-point).
	Gui, OSD:Add, Text, vMyText cFFFFFF, XXXXX YYYYY YYYYY ; XX & YY serve to auto-size the window.
	; Make all pixels of this color transparent and make the text itself translucent (150):
	WinSet, TransColor, %CustomColor% 150

OSD(text, time:=1000) {
	SetTimer, HideOSD, %time%
	GuiControl,OSD:, MyText, % text
	Gui OSD:+LastFound +AlwaysOnTop -Caption +ToolWindow  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
	WinSet, TransColor, %CustomColor% 150
	; Gui, Show, x0 y400 NoActivate  ; NoActivate avoids deactivating the currently active window.

	CurrentMon := 0
	MouseGetPos, MouseX, MouseY
	Loop {
		CurrentMon := CurrentMon + 1
		SysGet, Monitor, MonitorWorkArea, %CurrentMon%
		if (MonitorLeft = "")
			break
		if (MouseX >= MonitorLeft and MouseX <= MonitorRight and MouseY >= MonitorTop and MouseY <= MonitorBottom) {
			CenterX := (MonitorLeft + MonitorRight)/2 - 200
			global guiY := MonitorBottom - 150
			; ToolTipTime(QuotedVar("guiY"))
			Gui, OSD:Show, x%CenterX% y%guiY% NoActivate  ; NoActivate avoids deactivating the currently active window.
			; Gui, Show, xCenter y400 NoActivate  ; NoActivate avoids deactivating the currently active window.
			break
		}
	}
	return

HideOSD:
	Gui, OSD:Hide
	return
}


; https://autohotkey.com/board/topic/7718-mbutton-close-windowstaskbartitlebar-open-ie-links/
InTitleBar(win_id:=0) {
	; if (!win_id) {
		MouseGetPos, ClickX, ClickY, win_id
	; }
	SendMessage, 0x84,, ( ClickY << 16 )|ClickX,, ahk_id %win_id% 
	WM_NCHITTEST_Result = %ErrorLevel%
	if WM_NCHITTEST_Result in 2,3,8,9,20,21 
	{ ; in titlebar enclosed area - top of window
		; OSD(WM_NCHITTEST_Result)
		return win_id
	}
	return 0
}

ToolTipTime(tip, time = 1000) {
	ToolTip, % tip
	SetTimer, HideTip, % time
}
DebugTip(tip, level = 1, time = 5000) {
	if (DebugLevel >= level)
		ToolTipTime(tip, time)
}
HideTip:
	ToolTip
return

Join(sep, params*) {
    for index,param in params
        str .= param . sep
    return SubStr(str, 1, -StrLen(sep))
}

; just for debugging --------------------------------------------------------
TrueFalse(bool) {
	if (bool)
		return "true"
	return "false"
}
; Prints the variable name and its contents
; ex: name := "Harry"; QuotedVar("name") = 'name: "Harry"'
QuotedVar(var) {
	return var ": " vartostring(%var%)
}
quoted(string){
	return "%string%"
}
vartostring(var) {
    builder := ""
    if (var[1]) { ; array
        builder .= "["
        len := var.length()
        loop % len - 1 {
            builder .= vartostring(var[a_index]) ", "
        }
        builder .= vartostring(var[len]) "]"
    } else { ; don't know how to see if var is associative other than try to loop through it
        count := 0
        for index, value in var {
            count += 1
            builder .= index ": " vartostring(value) ", "
        }
        if (count) {
            builder := "{ " substr(builder, 1, -2) . " }"
        } else {
            builder = "%var%"
        } 
    }
    return builder
}


BeginsWith(word, part) {
	return (substr(word, 1, StrLen(part)) == part)
}

; Maximize or restore given window. Defaults to window under cursor
; returns found window
MaximizeRestore(win:=0){
	if (!win) {
    	MouseGetPos,,,ahk_id
		win := "ahk_id" ahk_id
	}
    WinGet,winState,MinMax,%win%
    If (winState) {
        WinRestore,%win%
    } Else {
        WinMaximize,%win%
    }
	return win
}
