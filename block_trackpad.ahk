SetTitleMatchMode, 1

^F12::
   Run, rundll32.exe shell32.dll`,Control_RunDLL main.cpl @0 ;mouse options
   winwaitactive,Mouse Properties
   Send, ^+{TAB}
   ;Send, !t!a ;; disable
   Send, !s ; settings
   winwaitactive,Properties for Synaptics
   Send, +{tab}+{tab}t!e!a  ; toggle tapping
   Send, {esc}
   winwaitactive,Mouse Properties
   Send, {esc}
return
