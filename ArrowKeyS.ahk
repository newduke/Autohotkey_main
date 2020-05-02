; ArroyKeys
; author: Jordan Weitz (newduke@gmail.com) 
;
; holding caps turns right-hand keys (ijkl) into arrows
; ctrl+alt+caps = functional capslock
;
; TODO: generalize

#MaxHotkeysPerInterval 200
global CapsHeld := 0
global KSM := ""

hotkey, *u, Home_
hotkey, *u up, HomeR_
hotkey, *o, End_
hotkey, *o up, EndR_
hotkey, *i, Up_
hotkey, *i up, UpR_
hotkey, *j, Left_
hotkey, *j up, LeftR_
hotkey, *k, Down_
hotkey, *k up, DownR_
hotkey, *l, Right_
hotkey, *l up, RightR_
hotkey, *;, Backspace_
hotkey, *; up, BackspaceR_
hotkey, *h, Del_
hotkey, *h up, DelR_
hotkey, *m, PageUp_
hotkey, *m up, PageUpR_
hotkey, *n, EscD_
hotkey, *n up, EscR_
; backquote the ,
hotkey, *`,, PageDn_
hotkey, *`, up, PageDnR_

hotkey, *CapsLock, HandleCaps
hotkey, *CapsLock up, HandleCapsUp

;~ AK_toggle = On
gosub ToggleIt
