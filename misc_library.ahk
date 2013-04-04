BeginsWith(word, part) {
	return (substr(word, 1, StrLen(part)) == part)
}
; Select whole word
SelectWholeWord() {
;~ If (WinActive("SciTE4AutoHotkey"))
	Send, {right}^{left}+^{right}
}

; SendMail sends mail
SendMail(sender, senderPass, receiver, subject, message)
{
	pmsg 			:= ComObjCreate("CDO.Message")
	pmsg.From 		:= sender
	pmsg.To 		:= receiver
	pmsg.BCC 		:= ""   ; Blind Carbon Copy, Invisable for all, same syntax as CC
	pmsg.CC 		:= "" ; Somebody@somewhere.com, Other-somebody@somewhere.com"
	pmsg.Subject 	:= subject

	;You can use either Text or HTML body like
	pmsg.TextBody 	:= message
	;OR
	;pmsg.HtmlBody := "<html><head><title>Hello</title></head><body><h2>Hello</h2><p>Testing!</p></body></html>"


	sAttach   		:= "Path_Of_Attachment" ; can add multiple attachments, the delimiter is |

	fields := Object()
	fields.smtpserver   := "smtp.gmail.com" ; specify your SMTP server
	fields.smtpserverport     := 25 ; 465 ; 25
	fields.smtpusessl      := True ; False
	fields.sendusing     := 2   ; cdoSendUsingPort
	fields.smtpauthenticate     := 1   ; cdoBasic
	fields.sendusername := sender
	fields.sendpassword := senderPass
	fields.smtpconnectiontimeout := 60
	schema := "http://schemas.microsoft.com/cdo/configuration/"


	pfld :=   pmsg.Configuration.Fields

	For field,value in fields
		pfld.Item(schema . field) := value
	pfld.Update()

	Loop, Parse, sAttach, |, %A_Space%%A_Tab%
	  pmsg.AddAttachment(A_LoopField)
	pmsg.Send()
}

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


