;
; AutoHotkey Version: 1.x
; Language:       English
; Platform:       WinNT
; Author:         David Earls
;
; Script Function:
;   Ghost inactive Windows like XFCE
;
; Attribution: The code to loop through windows was paraphrased from the AHK forums.
; script of Unambiguous adjusted for use with PSPad


#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetTitleMatchMode, 2
#SingleInstance, force
DetectHiddenWindows, Off 

iniread, TransLvl, fadetoblack.ini, Preferences, Transparent, 150
iniread, delay, fadetoblack.ini, Preferences, Delay, 0

ifexist, %A_Windir%\System32\accessibilitycpl.dll
  menu, tray, icon, %A_Windir%\System32\accessibilitycpl.dll, 15
menu, tray, nostandard
menu, tray, add, &Configure, Configure
menu, tray, default, &Configure
menu, tray, add
menu, tray, add, E&xit, ExitRoutine
menu, tray, tip, Fades Inactive Windows - Please exit properly.


OnExit, ExitRoutine
#Persistent
SetTimer, CheckIfActive, 200
return



CheckIfActive:
WinGet, id, list, , , Program Manager
Loop, %id%
{
    StringTrimRight, this_id, id%a_index%, 0
    WinGetTitle, title, ahk_id %this_id%
    
    If title =
        continue

    WinGetClass class , ahk_id %this_id%

    if class = Shell_TrayWnd ;Look down
        continue
    if class = Button ;Start Menu
        continue
    
    winget processname,processname, ahk_id %this_id%

    ;Exclusions
    if ( processname = "PSPad.exe" and class = "TApplication" )
     continue

    WinGet, id_trans, ID, ahk_id %this_id%
    WinGet, Trans, Transparent, ahk_id %this_id%

    ; if active task, Set vis.
    IfWinActive, ahk_id %id_trans%
   {
       winset, Transparent, Off, ahk_id %id_trans%
      continue
   }
    If Trans = %TransLvl% ; already Transparent
        continue
    if delay
    {
        if wininactive%ID_trans% < %delay%
             wininactive%ID_trans% += 1
        else
        {
            Winset,Transparent, %TransLvl%, ahk_id %id_trans%
            wininactive%ID_min% = 0
        }
    }
    else    
       Winset,Transparent, %TransLvl%, ahk_id %id_trans%
}
return


ExitRoutine:
WinGet, id, list, , , Program Manager
Loop, %id%
{
    StringTrimRight, this_id, id%a_index%, 0
    WinGetTitle, title, ahk_id %this_id%
    WinGet, id_trans, ID, ahk_id %this_id%
    winget processname,processname, ahk_id %this_id%
    WinGetClass class , ahk_id %this_id%
    ;Exclusions
    if ( processname = "PSPad.exe" and class = "TApplication" )
     continue
    If title =
        continue
    if class = Shell_TrayWnd
        continue
   if class = Button ;you get a large square if you remove this.
       continue
    
   Winset,Transparent,off, ahk_id %id_trans%

}
ExitApp
return

Configure:
gui, add, text,,Transparency:
gui, add, text,,Ghost
gui, add, slider,x+5 vTransSlider Range20-255 tooltip,%TransLvl%
gui, add, text,x+5,HiDef
gui, add, text,xm,`nInactivity Delay (Seconds):
gui, add, text,,Zero
gui, add, slider,x+5 tooltip vDelaySlider Range0-90, %delay%
gui, add, text,x+5,Ninety
gui, add, button,xm,&Save
gui, show,,Configure
return ;the gui

buttonSave:
gui, submit
iniwrite, %TransSlider%, fadetoblack.ini, Preferences, Transparent
iniwrite, %DelaySlider%, fadetoblack.ini, Preferences, Delay
reload
return

GuiEscape:
GuiClose:
gui, destroy
return

return ;configure sub
