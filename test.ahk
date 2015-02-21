;/////////////////////////// Test /////////////////////////////////////////////

;--------------------------------------------------------------------------
; for debugging, there is a GUI caled vDebugOut.  
; Also consider debugging in SciTE.
;!! TODO: add helper functions to make this usable
;Gui, Add, Edit, r9 vMyEdit, Text to appear inside the edit control 
;~ Gui, Debug:New
;~ Gui, Debug:Add, ListBox, w500 h300 vDebugOut, 
;~ Gui, Debug:Show


;!!! read, understand, modify, comment:
;~ #w::
   ;~ WinGet, window, ID, A   ; Use the ID of the active window.
   ;~ Toggle_Window(window)
;~ return

;~ !^w::
   ;~ MouseGetPos,,, window   ; Use the ID of the window under the Mouse.
   ;~ Toggle_Window(window)
;~ return

; Hide all the border styling of the given window
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

;;!! I've forgotten what this is all about.
;;TODO: document me.
;OnMessage(0x4a, "Receive_WM_COPYDATA")  ; 0x4a is WM_COPYDATA
;~ OnMessage(0x4a, "Receive_Hold")

;~ VarSetCapacity( APPBARDATA, 36, 0 )

