; Mod of rrhuffy http://www.autohotkey.com/community/viewtopic.php?p=539379#p539379
; by Guest (very nice guy, really)

#SingleInstance,Force
#NoTrayIcon
#Persistent

SetupSpeedReader:
	#MaxThreadsBuffer 2
	#MaxThreadsPerHotkey 2
	SetBatchLines,-1
	SetFormat,Float,0.2
	Gui srgui:Default
	gui, font, s8, arial   ; Preferred font.
	SetTitleMatchMode, 2

	NumDisplayedLines = 1
	NumberOfDisplayedWords = 2
	WordPerMinute = 300
	Jump = 20

	ReadBreakCode := 1
	ReadCount=
	WantedPosition = 0
	Reading = 0
	Paused = 0

	gui, Font, s31
	gui, Add, Text, x2 y2 w626 h156 vTextLargeDisplay Center, ***clipboard too small***
	;gui, Font, s20
	;gui, Add, Text, xp+400 y117 w100 h50 vWordRight Left, right
	gui, Font, s8
	gui, Add, Button, x2 y165 w50 h30 +0x8000 vButtonRead gButtonRead Default, &Read >
	gui, Add, GroupBox, xp+54 y157 w50 h39, Words
	gui, Add, DropDownList, x60 y170 w41 h20 R3 vDropdownNumber gDropdownNumber,0|1||2|3|
	GuiControl, Choose, DropdownNumber, % NumberOfDisplayedWords
	gui, Add, GroupBox, xp+48 y157 w50 h39, Lines
	gui, Add, DropDownList, x115 y171 w30 h20 R3 vDropdownLines gDropdownNumber,1||2|3|
	GuiControl, Choose, DropdownLines, % NumDisplayedLines

	;~ gui, Add, GroupBox, xp+48 y157 w40 h39, Jump
	;~ gui, Add, Edit, x115 y171 w30 h20 vJumpSpeed gJumpSpeed,20

	gui, Add, GroupBox, x155 y157 w520 h39, Speed (wpm)
	gui, Add, Edit, xp+4 y171 w40 h20 +center vEditSpeed gEditSpeed, % WordPerMinute
	gui, Add, Slider, xp+43 y171 w430 h20 vSliderSpeed gSliderSpeed Range50-1000 TickInterval50 AltSubmit, % WordPerMinute
	gui, Add, Progress, x0 y197 w630 h10 vProgressBar, 25
	gui, Add, Edit, xp+4 yp+14 h90 w620 vEditText, 
	gui, -Resize +e0x20000
	gui, Add, StatusBar,, Number of words in the clipboard: 0
	SB_SetParts(260)
	GuiControl, , ProgressBar,0
Return

; Try to open clipboard for speedreading.
; returns true if capable, false otherwise.
TryReader(doc) {
	global NumberOfWords, ClipboardString, EditText, TextLargeDisplay
	;~ if (A_EventInfo != 1)
		;~ return false
	  ;~ ToolTip % "Loading clipboard to SpeedReader: " . doc
	  ;~ Sleep 1300

	Gui srgui:Default
	GuiControl, ,EditText,%doc%
	COUNT(doc)
	gui, Font, s31
	GuiControl, ,TextLargeDisplay,***clipboard too small***
	gui, font, s8, arial   ; Preferred font.
	;~ GuiControl, ,EditSpeed,69

	if (NumberOfWords < 10)
		return false
	GuiControl, ,EditText,%ClipboardString%

	return true
	;~ DoReader()
	;~ ToolTip  ; Turn off the tip.
	;~ return false
}

DoReader:
	global ClipboardString
	 
	Gui srgui:Default
	gui, Show, x336 y221 h327 w630 , SpeedReader ; 2 words display
	GoSub, DisplayFullClipboard
	
	;~ gui, show ;+AlwaysOnTop ;  -caption  -ToolWindow -SysMenu
return

COUNT(doc) {
	global ClipboardString, NumberOfWords=
	global NumberOfDots=
	ClipboardString:=doc ;, , EditText
	StringReplace, ClipboardString, ClipboardString, ., ., UseErrorLevel
	NumberOfDots=%ErrorLevel%

	Temp := RegExReplace(ClipboardString, "(([.][^0-9a-zA-Z]|[,][^0-9]|\r|\n|[-/\?<>;: ])+)", "${1}`r")
	StringReplace, Temp, Temp, %A_Space% ,, All
	StringReplace, Temp, Temp, `n,`r, All
	StringReplace, ClipboardString, Temp, `r, %A_Space% , UseErrorLevel
	NumberOfWords=%ErrorLevel%
	SB_SetText("Number of words: " NumberOfWords,1)
	;~ ToolTipTime(ClipboardString, 20000)
	;~ ToolTipTime(QuotedVar("NumberOfWords"))

	gosub SliderSpeed
	GoSub, EstimateReadingTime
	Return
}

#IfWinActive SpeedReader ahk_class AutoHotkeyGUI
$WheelDown::
$Left::
ControlGetFocus, Focus, SpeedReader
If (Focus = "Edit3") and (A_ThisHotkey = "$Left")
	{
	 Send {Left}
	 Return
	}
WantedPosition = %ReadCount%
WantedPosition -= %Jump%
if(WantedPosition < 0)
   WantedPosition = 1
return

$WheelUp::
$Right::
ControlGetFocus, Focus, SpeedReader
If (Focus = "Edit3") and (A_ThisHotkey = "$Right")
	{
	 Send {Right}
	 Return
	}
WantedPosition = %ReadCount%
WantedPosition += %Jump%
if(WantedPosition > NumberOfWords)
{
   WantedPosition = 0
}
else
return

~LButton & WheelUp::
$Up::
ControlGetFocus, Focus, SpeedReader
If (Focus = "Edit3") and (A_ThisHotkey = "$Up")
	{
	 Send {Up}
	 Return
	}
GuiControlGet,WordPerMinute,srgui:,SliderSpeed,
WordPerMinute := WordPerMinute + 50
GuiControl, srgui: , SliderSpeed, %WordPerMinute%
GoSub, SliderSpeed
return

~LButton & WheelDown::
$Down::
ControlGetFocus, Focus, SpeedReader
If (Focus = "Edit3") and (A_ThisHotkey = "$Down")
	{
	 Send {Down}
	 Return
	}
GuiControlGet,WordPerMinute,srgui:,SliderSpeed,
WordPerMinute := WordPerMinute - 50
GuiControl, srgui: , SliderSpeed, %WordPerMinute%
GoSub, SliderSpeed
return

~MButton::
Space::
paused := 1 - paused
Return

Esc::
if(ReadBreakCode == 0)
{
   ReadBreakCode := 1
}
else
{
   gui, srgui:Hide
}
return
#IfWinActive

ButtonRead:
if (reading) {
	paused := 1 - paused
	return
}
Reading = 1
SetTimer, Rewind, -1
return

Rewind:
Gui srgui:Default
GuiControlGet, ClipboardString, srgui:, EditText
;~ gosub SliderSpeed
Count(ClipboardString)
ReadCount=0
ProgressTime=
ReadBreakCode=0
DisplayTextString=
GuiControlGet,NumberOfDisplayedWords,,DropdownNumber,
GuiControlGet,NumDisplayedLines,,DropdownLines,
; This prevents the parsing loop to skip the last/ 2 last words
GuiControl, disable,DropdownNumber
GuiControl, ,TextLargeDisplay,
gui, Font, s31, arial
GuiControl,  Font, TextLargeDisplay
GuiControl,  +center, TextLargeDisplay

; variables for keeping track of text scrolling by
len := StrLen(ClipboardString)
avelen := len/NumberOfWords + 1 ; + 1 includes the space
HardLimit := avelen * (NumberOfDisplayedWords - .2)
SoftLimit := avelen * (NumberOfDisplayedWords - 1)
sr_remainder := 0
Position := 0
Lines := 0
Paragraph := ""
Loop,Parse,ClipboardString,%A_Space%
{
	while (paused = 1)
		Sleep, 20
	word := A_LoopField
	NextLen := InStr(ClipboardString, " ", false, Position+1) - Position
	NextWord := SubStr(ClipboardString, Position, NextLen)
	Position += StrLen(word) + 1

	;~ Tooltip, %ReadCount% %WantedPosition% %ReadBreakCode%
	ReadCount+=1
	; if we want to be before actual position then we have to leave loop
	if(WantedPosition != 0 && WantedPosition < ReadCount || ReadBreakCode == 1)
		break
	else if (WantedPosition != 0 && WantedPosition > ReadCount)	{
		;~ Tooltip, Continued...%ReadCount% / %WantedPosition%
		continue
	} else if( WantedPosition != 0 && WantedPosition == ReadCount) { ; last statement, for readability
		WantedPosition := 0 ; when equal 0, then we dont want to change position of text
	}
	ProgressValue:=100.0*ReadCount/NumberOfWords
	GuiControl, , ProgressBar,%ProgressValue%

	CurLen := StrLen(DisplayTextString)
	;~ ToolTip, % (DisplayTextString . ",, " . NextWord . "] rem: " . sr_remainder . " : " 
		;~ . strlen(DisplayTextString) . " len " . avelen*NumberOfDisplayedWords
		;~ . QuotedVar("HardLimit") . QuotedVar("SoftLimit"))
	;~ sleep, %ReadDelay%
	if ( (CurLen > SoftLimit && CurLen + sr_remainder > avelen * NumberOfDisplayedWords)
		|| CurLen > HardLimit 
		|| CurLen + NextLen > HardLimit + avelen ) {
		sr_remainder := sr_remainder + StrLen(DisplayTextString) - avelen*NumberOfDisplayedWords

		Paragraph := Paragraph . DisplayTextString . "`n"
		Lines += 1
		if ( Lines >= NumDisplayedLines ) {
			GuiControl, ,TextLargeDisplay,%Paragraph%

			If (InStr(Paragraph, ".") || InStr(Paragraph, "?")) {
				Sleep %DotDelay%
				ProgressTime+=DotDelay/500.0
			}
			Sleep %ReadDelay%
			Paragraph := ""
			Lines := 0
		}
		DisplayTextString=%word%
		DoubleWord=1
	} else {
		DisplayTextString=%DisplayTextString% %word%
		DoubleWord+=1
		continue
	}	
	ProgressTime+=ReadDelay/1000.0
	String=Reading time: %ProgressTime% s
	SB_SetText(String,2)
}
if(WantedPosition != 0 && WantedPosition < ReadCount && ReadBreakCode == 0) ; loop ended but we wanted to rewind
{
   Goto, Rewind ; go to loop, then (in loop) rewind to wanted position
}
else
{
   ReadBreakCode = 1 ;after end of text prepare ESC button to close by setting this to 1
}
GuiControl, ,TextLargeDisplay,%Paragraph% %DisplayTextString%
Sleep %ReadDelay%
Sleep %DotDelay%
GuiControl, enable,DropdownNumber
GoSub, DisplayFullClipboard
GoSub, EstimateReadingTime
GuiControl, , ProgressBar,0
Reading = 0
Return

JumpSpeed:
GuiControlGet,Jump,,JumpSpeed,
return

SliderSpeed:
GuiControlGet,WordPerMinute,srgui:,SliderSpeed, ; WordPerMinute in wpm
ReadDelay:=60000/WordPerMinute
GoSub, EstimateReadingTime
GuiControl, srgui:,EditSpeed,%WordPerMinute%
return


EditSpeed:
GuiControlGet,WordPerMinute,srgui:,EditSpeed, ; WordPerMinute in wpm
ReadDelay:=60000/WordPerMinute
GoSub, EstimateReadingTime
GuiControl, srgui:,SliderSpeed,%WordPerMinute%
return


DropdownNumber:
GuiControlGet,NumberOfDisplayedWords,srgui:,DropdownNumber,
GuiControlGet,WordPerMinute,srgui:,EditSpeed, ; WordPerMinute in wpm
GoSub, EstimateReadingTime
return


EstimateReadingTime:
DotDelay:=.7*ReadDelay
TotalTime:=(ReadDelay*NumberOfWords/NumberOfDisplayedWords+DotDelay*NumberOfDots)/1000.0
String=Estimated reading time: %TotalTime% s
SB_SetText(String,2)
return


DisplayFullClipboard:
gui, srgui:Font, s7 ; , small fonts ; this is all I changed 123
GuiControl, srgui: Font, TextLargeDisplay
GuiControl, srgui: +left, TextLargeDisplay
GuiControl, srgui:,TextLargeDisplay,%ClipboardString%
gui, srgui:font, s8, arial   ; Preferred font.
return


GuiSize:
If A_EventInfo=1
  Return
GuiControl, srgui:Move,listview, % "W" . (A_GuiWidth - 10) . " H" . (A_GuiHeight - 77)
GuiControl, srgui:Move,box3, % "x" (A_GuiWidth - 350) "W" . (A_GuiWidth - 300) . " H" . (72)
Return


;~ GuiClose:
;~ ExitApp
