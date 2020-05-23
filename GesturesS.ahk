/*
 * GesturesS.ahk
 * #included setup for Gestures.ahk
 */
 
/*
 * Configuration Defaults:
 *      Override these in Gestures_User.ahk (in the "Gestures:" sub).
 */

m_GestureKey = XButton1 ; Gesture key.
m_GestureKey2 =         ; Alternate gesture key.
m_Interval = 20         ; How long to sleep between each iteration of the gesture-recognition loop.
m_LowThreshold = 25     ; Minimum distance to register as a gesture "stroke."
m_HighThreshold = 0     ; Maximum total gesture length. Exceeding this cancels the gesture.
m_Timeout = 500         ; Maximum time in milliseconds between the last mouse movement
                        ; and release of the gesture key/button.
m_InitialTimeout = 250  ; Maximum time in milliseconds that the mouse can remain in its initial
                        ; position before gesture-recognition is cancelled.
                        ; This makes it easier to click and drag with the gesture button.
m_ActiveTimeout = 0     ; Maximum time in milliseconds that the mouse can remain in any one
                        ; position before gesture-recognition is cancelled. 0 means forever.
m_ActiveTimeoutMode = 0 ; 0: cancel. 1: cancel & perform default action. 2: complete gesture.
m_DefaultOnTimeout = 0  ; If true, default action is performed whenever m_Timeout is applied.
m_Tolerance = 100       ; Maximum percent of deviance from "zone center" that will be tolerated.
                        ; If there are 4 zones, 100 percent = 45 degrees.
m_ZoneCount = 4         ; The number of zones.
m_InitialZoneCount =    ; If set, defines the number of zones allowed for the *first* stroke.
m_DisableDing = 0
m_GesturePrefix = Gesture   ; Default prefix for gesture variables/labels.
m_KeylessPrefix =           ; Prefix for keyless gestures, or blank to disable.
m_Delimiter = _

m_EnabledIcon = %A_ScriptDir%\gestures.ico
m_DisabledIcon = %A_ScriptDir%\nogestures.ico
m_EnabledSound = %A_ScriptDir%\wurt_enabled.wav
m_DisabledSound = %A_ScriptDir%\wurt_disabled.wav

m_PenWidth =            ; Width of the pen to draw trails with.
m_NodePenWidth =        ; Radius of "nodes" on the trails, indicating where each stroke begins.
m_PenColor =            ; Colour of trails and nodes.
m_TransTrail = 1        ; Make trail window transparent (recommended if DWM/Aero theme is enabled).

/*
 * Basic global init
 */

#NoEnv
#SingleInstance Force       ; Never allow more than one instance of this script.
CoordMode, Mouse, Screen    ; Let mouse commands use absolute/screen co-ordinates.
SendMode Input              ; Set recommended send-mode.
SetTitleMatchMode, 2        ; Match anywhere in window title.
SetWorkingDir %A_ScriptDir% ; Set working directory to script's directory for consistency.
SetBatchLines, -1           ; May improve responsiveness. Shouldn't negatively affect other
                            ; apps as the script sleeps every %m_Interval% ms while active.

/*
 * Set text labels to be used in other areas
 */

; Zone labels used when four zones are active:
c_Zone4_0 = R
c_Zone4_1 = D
c_Zone4_2 = L
c_Zone4_3 = U

; Zone labels used when eight zones are active:
c_Zone8_0 = R
c_Zone8_1 = DR
c_Zone8_2 = D
c_Zone8_3 = DL
c_Zone8_4 = L
c_Zone8_5 = UL
c_Zone8_6 = U
c_Zone8_7 = UR

/*
 * Default values
 */
m_ScrolledWheel := false    ;


/*
 * Load configuration
 */

; Run "auto-execute" sections of Gestures_Default.ahk and Gestures_User.ahk, in that order.
; Explicit labels are required in case the file contains only gesture definitions or hotkeys.

if IsLabel(ErrorLevel:="DefaultGestures")
    gosub %ErrorLevel%

if IsLabel(ErrorLevel:="Gestures")
    gosub %ErrorLevel%


/*
 * Initialize script - don't mess with this unless you know what you're doing
 */

G_SetTrayIcon(true)         ; Set custom tray icon (also called by ToggleGestureSuspend).

; Hook "Suspend Hotkeys" messages to update the tray icon.
; Note: This has the odd side-effect of "disabling" the tray menu
;       if the script is paused from the tray menu.
OnMessage(0x111, "WM_COMMAND")

; Set tooltip for tray icon.
Menu, Tray, Tip, Mouse Gestures
; Setup custom tray menu.
Menu, Tray, NoStandard
Menu, Tray, Add, &Open      , TrayMenu_Open
Menu, Tray, Add, &Help      , TrayMenu_Help
Menu, Tray, Add, &Debug      , TrayMenu_Debug
Menu, Tray, Add
Menu, Tray, Add, &Reload    , TrayMenu_Reload
Menu, Tray, Add, &Suspend   , TrayMenu_Suspend
Menu, Tray, Add
Menu, Tray, Add, Edit &Gestures.ahk         , TrayMenu_Edit

Menu, Tray, Add, Edit Gestures_&Default.ahk , TrayMenu_Edit
Menu, Tray, Add, Edit Gestures_&User.ahk    , TrayMenu_Edit
Menu, Tray, Add
Menu, Tray, Add, E&xit      , TrayMenu_Exit
Menu, Tray, Default, &Open

; Create a group for easy identification of Windows Explorer windows.
GroupAdd, Explorer, ahk_class CabinetWClass
GroupAdd, Explorer, ahk_class ExploreWClass

; Some code relies on m_InitialZoneCount being set.
if m_InitialZoneCount < 2
    m_InitialZoneCount := m_ZoneCount

; The following are relied on by the script and should not be changed:
c_PI := 3.141592653589793, c_Degrees := 180/c_PI

m_WaitForRelease := false   ; Are we waiting for the gesture key to be released? Not yet.
m_PassKeyUp := false        ; Should GestureKey_Up pass key-release to the active window? Not yet.
m_ClosingWindow := 0        ; We aren't about to close any window.

; Set up the canvas for mouse-trails, if configured.
if m_PenWidth
{
    ; Set default trail colour or convert RRGGBB to 0xBBGGRR.
    if m_PenColor =
        m_PenColor := 0
    else
        m_PenColor := "0x" . SubStr(m_PenColor,5,2) . SubStr(m_PenColor,3,2) . SubStr(m_PenColor,1,2)
    m_PenColor &= 0xffffff
    ; Use any other colour as the trail-Gui background.
    m_TransColor := m_PenColor ? "000000" : "FFFFFF"

    ; Create the Gui if not already created, and set it as the Last Found Window.
    Gui, +LastFound
    if m_TransTrail
    {
        ; Make the Gui background transparent.
        Gui, Color, %m_TransColor%
        WinSet, TransColor, %m_TransColor%
    }
    else
    {
        ; Prevent the GUI background from being painted, giving the illusion of transparency.
        OnMessage(0x14, "G_DisableEraseBkgnd")
        G_DisableEraseBkgnd() {
            return 1
        }
    }
    ; Remove the caption and borders, and hide the Gui from the taskbar.
    Gui, -Caption +ToolWindow +AlwaysOnTop
    ; Get the HWND and HDC of the Last Found Window (the Gui).
    hw_canvas := WinExist()
    hdc_canvas := DllCall("GetDC", "uint", hw_canvas)
    ; Create the pen, if not already created.
    pen := DllCall("CreatePen", "int", 0, "int", m_PenWidth, "uint", m_PenColor)
    ; Select the pen and store a handle to the previously selected pen (common GDI practice).
    old_pen := DllCall("SelectObject", "uint", hdc_canvas, "uint", pen)
    ; Create a brush for erasing the Gui background.
    brush := DllCall("CreateSolidBrush", "uint", "0x" m_TransColor)
    
    brush2 := DllCall("CreateSolidBrush", "uint", m_PenColor)
    old_brush := DllCall("SelectObject", "uint", hdc_canvas, "uint", brush2)
}

; Register hotkeys.
Hotkey, %m_GestureKey%, GestureKey_Down
Hotkey, #%m_GestureKey%, ToggleGestureSuspend
if m_GestureKey2 {
    Hotkey, %m_GestureKey2%, GestureKey_Down
    Hotkey, #%m_GestureKey2%, ToggleGestureSuspend
}

SoundPlay, %m_EnabledSound%

if m_KeylessPrefix {
    if !m_ActiveTimeout
        if m_Timeout
            m_ActiveTimeout := m_Timeout
        else
            m_ActiveTimeout := 1000
    SetTimer, GestureKeyless, %m_Interval%  ; Won't run while in the gesture recognition loop.
}

/*
 * END OF INIT SECTION
 */
