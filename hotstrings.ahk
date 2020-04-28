#SingleInstance FORCE 
#NoTrayIcon
;  --------------------------------------------------------------------------
; text expansions (hotstrings) --------------------------------------------------
;; NOTE: text expansions were messing with timers
;; see also "texter:" http://lifehacker.com/238306/lifehacker-code-texter-windows
::uus::the United States
::aaj::Ashley Jordan
::jjw::Jordan Weitz
::new@::newduke@gmail.com
::1184::1184 Florida Street, San Francisco, CA 94110
::1550::1550 5th St, Oakland, CA 94607
::jauth::author: Jordan Weitz (newduke@gmail.com)
::cliche::cliché 
::<?<?::
	Send, <?php{enter} ?>{left 3}
return

:C:#DATE::
	SendRaw, % "#" . A_YYYY . "-" . A_MM . "-" . A_DD
return

:C:DATE::
	send, % A_DD . " " . A_MMM . " " . A_YYYY
return

::{{::
	send, {{}{enter 2}{}}{up}{end}
return 
; -------------------------------------------------------------------------
;--------------------------------------------------------------------------
