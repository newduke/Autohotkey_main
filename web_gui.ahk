#include com.ahk

;Com_init()

COM_AtlAxWinInit()
Gui, +LastFound +Resize
;pwb := COM_AtlAxGetControl(COM_AtlAxCreateContainer(WinExist(),top,left,width,height, "Shell.Explorer") )  ;left these here just for reference of the parameters
pwb := COM_AtlAxGetControl(COM_AtlAxCreateContainer(WinExist(),0,0,510,600, "Shell.Explorer") )
gui,show, w510 h600 ,Gui Browser
;take from the IE example
url:="http://www.google.com"
COM_Invoke(pwb, "Navigate", url)
loop
	  If (rdy:=COM_Invoke(pwb,"readyState") = 4)
		 break
url:="http://www.Yahoo.com"
COM_Invoke(pwb, "Navigate", url)
loop
	  If (rdy:=COM_Invoke(pwb,"readyState") = 4)
		 break
MsgBox, 262208, Done, Goodbye,5
Gui, Destroy
COM_AtlAxWinTerm()
ExitApp

 ;~ #include com.ahk

;~ GoSub, GuiOpen

;~ oWeb := COM_AtlAxCreateControl(WinExist(), "Shell.Explorer")
;~ sink := COM_ConnectObject(oWeb, "Web_")
;~ pipa := COM_QueryInterface(oWeb, "{00000117-0000-0000-C000-000000000046}")
;~ oWeb.Silent := True
;~ oWeb.Navigate2("http://www.autohotkey.com/forum/")
;~ Return

;~ Navigate:
;~ oWeb.Navigate2(_URL_)
;~ Return

;~ GuiOpen:
;~ Gui, +Resize +LastFound
;~ Gui, Add, StatusBar
;~ Gui, Show, w1024 h768 Center, WebBrowser
;~ OnMessage(WM_KEYDOWN:=0x0100, "WM_KEY"), OnMessage(WM_KEYUP:=0x0101, "WM_KEY")
;~ OnMessage(WM_SYSKEYDOWN:=0x0104, "WM_KEY"), OnMessage(WM_SYSKEYUP:=0x0105, "WM_KEY")
;~ Return
;~ GuiClose:
;~ Gui, Destroy
;~ COM_DisconnectObject(sink)
;~ ExitApp

;~ Web_NewWindow3(prms)
;~ {
	;~ Global	_URL_ := COM_DispGetParam(prms,4)
	;~ COM_DispSetParam(-1,prms,1,11)
	;~ SetTimer, Navigate, -10
;~ } 

;~ Web_StatusTextChange(prms)
;~ {
	;~ SB_SetText(COM_DispGetParam(prms,0))
;~ }

;~ WM_KEY(wParam, lParam, nMsg, hWnd)
;~ {
	;~ WinGetClass, Class, ahk_id %hWnd%
	;~ If	(Class = "Internet Explorer_Server")
	;~ {
	;~ Global	pipa
	;~ VarSetCapacity(Msg, 28), NumPut(hWnd,Msg), NumPut(nMsg,Msg,4), NumPut(wParam,Msg,8), NumPut(lParam,Msg,12), NumPut(A_EventInfo,Msg,16), NumPut(A_GuiX,Msg,20), NumPut(A_GuiY,Msg,24)
	;~ If	DllCall(NumGet(NumGet(1*pipa)+20), "Uint", pipa, "Uint", &Msg)=0
	;~ Return	0
	;~ }
;~ } 