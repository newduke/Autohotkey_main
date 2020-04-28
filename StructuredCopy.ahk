;
#Include SpeedReader.ahk

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
