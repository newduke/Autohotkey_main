;  --------------------------------------------------------------------------
; Control Media -------------------------------------------------------------
;  --------------------------------------------------------------------------

; these scripts will work even with LWin disabled (so they work in games)
;LWin & WheelUp::SoundSet, +10 ; Win+MouseWheel forward: Louder
;~LWin & WheelDown::SoundSet, -10 ; Win+MouseWheel backward: Lower
;~LWin & Numpad0::SoundSet, +1,, mute ; Win+Numpad0: Volume on/off

; Get the HWND of the Spotify main window.
getSpotifyHwnd() {
	WinGet, spotifyHwnd, ID, ahk_exe spotify.exe
	; We need the app's third top level window, so get next twice.
	spotifyHwnd := DllCall("GetWindow", "uint", spotifyHwnd, "uint", 2)
	spotifyHwnd := DllCall("GetWindow", "uint", spotifyHwnd, "uint", 2)
	Return spotifyHwnd
}

; Send a key to Spotify.
spotifyKey(key) {
	spotifyHwnd := getSpotifyHwnd()
	; Chromium ignores keys when it isn't focused.
	; Focus the document window without bringing the app to the foreground.
	ControlFocus, Chrome_RenderWidgetHostHWND1, ahk_id %spotifyHwnd%
	ControlSend, , %key%, ahk_id %spotifyHwnd%
	Return
}

#i::
ActivateMedia:
	title:="ahk_exe spotify.exe"
	if WinActive( title ) {
		WinMinimize
		return
	}
	WinGet, id, list,%title%
	if (id = 0) {
		Run C:\Users\%A_UserName%\AppData\Roaming\Spotify\Spotify.exe ; hopefully its the same for everyone else?
		return
	}
	Loop, %id%
	{
		this_id := id%A_Index%
		WinActivate, ahk_id %this_id%
		WinGetTitle, this_title, ahk_id %this_id%
		if (this_title != "") {
            WinMaximize
			return
		}
	}
return

#x::
Send, {Media_Prev}
;If WinExist("ahk_class iTunes") or WinExist("ahk_class SpotifyMainWindow")
;ControlSend, ahk_parent, ^{LEFT}  ; < previous
;ControlSend, ahk_parent, #c  ; < previous
return

#c::
Send, {Media_Next}
;If WinExist("ahk_class iTunes") or WinExist("ahk_class SpotifyMainWindow")
;ControlSend, ahk_parent, ^{RIGHT}  ; > next
;WinActivate
;Send, ^{RIGHT}
return

#z::
	Send, {Media_Play_Pause}
	; If WinExist("ahk_class SpotifyMainWindow") or WinExist("ahk_class iTunes")
	; ControlSend, ahk_parent, {SPACE}  ; play/pause
return

; these no longer work
#If 0
#up::
+Volume_up::
SpotifyVolumeUp:
{
	spotifyKey("^{Up}")
	Return
}

; shift+volumeDown: Volume down
#down::
+Volume_down::
SpotifyVolumeDown:
{
	spotifyKey("^{Down}")
	Return
}
#If