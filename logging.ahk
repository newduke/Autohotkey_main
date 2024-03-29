; modified from https://autohotkey.com/board/topic/49105-hot-to-make-a-scrolling-log-window/

defaulLogFile := "log.txt"
global Console
global logLevel

LogInitGUI(title:="Logger", _logLevel:=0) {   
    logLevel := _logLevel
    Gui, LogGUI:New
    ; Gui LogGUI:+AlwaysOnTop ; I wanted this to stay on top even though there are other windows opening and being moved around.
    Gui, LogGUI:Add, Edit, x10 y10 w600 h600 vConsole
    Gui, LogGUI:Show, x100 y100 w620 h620, %title% - AutoHotkey
    if (!logLevel) {
        Gui, LogGUI:Minimize 
    }
}

LogExit() {
    Gui, Destroy ; Close the logging window
    ; ExitApp
}

;Function that writes to the logs. This is where the magic happens.
Log(msg, fileName:="") {
    fileName := fileName ? fileName : defaulLogFile
    FileAppend, ( %msg%`n ), %fileName%
    ; Gui, LogGUI:Flash
    GuiControlGet, Console, LogGUI:
    GuiControl, LogGUI:, Console, %msg%`r`n%Console%
    if (logLevel >= 2) {
        OSD(msg)
    }
    ; GUI write
    ; sleep 3000 ; Pause for smooth log scrolling
}

LogSave(fileName:="", appendTimestamp:=0) {
    fileName := fileName ? fileName : defaulLogFile
    if (appendTimestamp) {
        FormatTime, TimeString, A_Now, yyyyMMdd-HHmmss ; Get time in the desired format o suffix to log file
        fileName := fileName TimeString ".txt" ; Creat a new file name and location
        FileCopy, StartupScriptLog.txt, %fileName% ; Copy the file to the new name and location
    }
}
