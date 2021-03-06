DetectHiddenWindows, On
#Persistent
#NoEnv

/*
==================== Script Notes =======================
=                                                                                                                              =
= Script for farming credits in GT7                                                                           =
=     Using the course Special Stage Route X                                                         =
=     Set control scheme to directional button steering                                           =
=     Set X to accelerate                                                                                           =
=                                                                                                                              =
=     Have game ready with "Start" button before the race                                    =
=     Press start on the script                                                                                   =
=                                                                                                                           =
====================================================
*/
; --------- Controls
accel := "Enter"
turnLeft := "Left"
turnRight := "Right"

; --------- Constants 
; Time at turn in seconds and Stablizing control
FTEnt = 85
FTExi = 110
STEnt = 205
STExi = 248
BO = 200
FTS = 400
STS = 401

script = 1
; ---------- Gui Setup -------------
Gui, -MaximizeBox
Gui, -MinimizeBox
Gui, 2: -MaximizeBox
Gui, 2: -MinimizeBox
Gui, Color, c282a36, c6272a4
Gui, Add, Button, x15 y10 w70 default, Start
Gui, Add, Button, x15 y40 w70 default gVariableWindow, Variables
Gui, Font, ce8dfe3 s9 w550 Bold


;--------- Gui 2 Setup --------------
Gui, 2: Color, c535770, c6272a4
Gui, 2: Font, c11f s9 Bold
Gui, 2: Add, Text,, First Turn Enter
Gui, 2: Add, Edit,  w40 vA, %FTEnt%
Gui, 2: Add, Text,, First Turn Exit
Gui, 2: Add, Edit,  w40 vB, %FTExi%
Gui, 2: Add, Text,, Second Turn Enter
Gui, 2: Add, Edit,  w40 vC, %STEnt%
Gui, 2: Add, Text,, Second Turn Exit
Gui, 2: Add, Edit,  w40 vD, %STExi%
Gui, 2: Add, Text, x125 y0, Beginning Overtake
Gui, 2: Add, Edit,  w40 x120 y25 vE, %BO%
Gui, 2: Add, Text, x125 y50, First Turn Stabilize
Gui, 2: Add, Edit,  w40 x120 y70 vF, %FTS%
Gui, 2: Add, Text, x125 y95, Second Turn Stabilize
Gui, 2: Add, Edit,  w40 x120 y115 vG, %STS%

Gui, 2: Add, Button, x20  y192 gSaveVars, Save 
Gui, 2: Add, Button, x100 y192 gVarDef, Defaults 
Gui, Show,w220 h120,  GT7 Special Track X AFK
return

VariableWindow:
    Gui, 2: Show, w260 h225, Variables
    return

SaveVars:
    Gui, 2:Submit
    GuiControlGet, FTEnt, 2:, A
    GuiControlGet, FTExi, 2:, B
    GuiControlGet, STEnt, 2:, C
    GuiControlGet, STExi, 2:, D
    GuiControlGet, BO, 2:, D
    GuiControlGet, FTS, 2:, D
    GuiControlGet, STS, 2:, D
    return

VarDef:
    FTEnt = 85
    FTExi = 110
    STEnt = 205
    STExi = 248
    BO = 200
    FTS = 400
    STS = 401
    GuiControl, 2:, A, %FTEnt%
    GuiControl, 2:, B, %FTExi%
    GuiControl, 2:, C, %STEnt%
    GuiControl, 2:, D, %STExi%
    GuiControl, 2:, E, %BO%
    GuiControl, 2:, F, %FTS%
    GuiControl, 2:, G, %STS%
    return

ButtonStart:
    Gui, Submit, NoHide
    id := ""
    SetKeyDelay, 100
    Process, priority, , High
    gosub, GrabRemotePlay
    if  (id = "")
        return
    gosub, PauseLoop
    CoordMode, Pixel, Screen
    CoordMode, ToolTip, Screen
    sleep 1000
    gosub, AFKLoop
; ---------- Gui Setup End-------------

AFKLoop:
/*
Actual Loop for the script, will switch between functions/subroutines for racing/menuing
Some data below for knowing when racing ends/menuing
  --------- Window Watches

  --- Next Button (race finished)
  Screen:    734, 855 (less often used)
  Window:    699, 823 (default)
  Client:    691, 792 (recommended)
  Color:    CACACA (Red=CA Green=CA Blue=CA)

  --- Purple Banner (race finished)
  Screen:    761, 823 (less often used)
  Window:    726, 791 (default)
  Client:    718, 760 (recommended)
  Color:    481A63 (Red=48 Green=1A Blue=63)
  
  (Race Finished: Enter 6x)
            Right 1x)
            Enter 1x)
*/

; Enter race
    loop{
        gosub, PressX
        Sleep, 5600 ; This is dependent on load time, probably different for ps4 version

        gosub, Race
        gosub, Menu
    }
    return

PressX:
; Just for menuing, does not hold X down
    ControlSend,, {%accel% down}, ahk_id %id% 
    Sleep, 200
    ControlSend,, {%accel% up}, ahk_id %id% 
    return
    
PressRight:
; For turning 
    ControlSend,, {%turnRight% down}, ahk_id %id% 
    Sleep, 50
    ControlSend,, {%turnRight% up}, ahk_id %id% 
    return
    
Race:
; Hold Acceleration and manage turning
    timer := 0
    ControlSend,, {%accel% down}, ahk_id %id% 
    Sleep, 2200
    gosub, BeginOvertake
    
/* Potential tuning here    
    start_time := A_TickCount
    firstTurnAt := FTEnt*1000+start_time
    firstTurnDone := FTExi*1000+start_time
    secTurnAt := STEnt*1000+start_time
    secTurnDone := STExi*1000+start_time
    
    
    Loop {
        timer += 1
        Sleep, 1000
        ToolTip, %timer%, 400, 400
    } Until A_TickCount - start_time > FTEnt*1000
    
    ;begin first turn
    Loop {
        timer += 1
        Sleep, 750
        ToolTip, %timer%, 400, 400
        gosub, PressRight
    } Until A_TickCount - start_time > FTExi*1000
    
    ;end first turn
    Loop {
        timer += 1
        Sleep, 1000
        ToolTip, %timer%, 400, 400
    } Until A_TickCount - start_time > STEnt*1000
    
    ;begin second turn
    Loop  {
        timer += 1
        Sleep, 750
        ToolTip, %timer%, 400, 400
        gosub, PressRight
    } Until A_TickCount - start_time > STExi*1000
*/    
    loop, %STExi% {
        timer += 1
        Sleep, 1000
        ToolTip, %timer%, 400, 400
    }
    
    loop, 20 {
        timer += 1
        Sleep, 1000
        ToolTip, %timer%, 400, 400
    }
    
/* 
; This section detects the end of the race. Can be used to be faster/more accurate at the ending but good timing takes less computer resources
    loop {
        PixelSearch, x, y, 697, 821, 701, 825, 0xCACACA, 20, Fast RGB
            If (ErrorLevel != 0) { ; race finished
            Sleep, 1000    
            }
            else{
                ToolTip, Race Finished, 400, 400
                break
            }
        
        
    }
*/    

    ControlSend,, {%accel% up}, ahk_id %id% 
    return
    
    
BeginOvertake:
; Overtake the first car by going left of it towards the rail
; Stablize before hitting rail
    ToolTip, Adjusting Car, 400, 400
    ControlSend,, {%turnLeft% down}, ahk_id %id% 
    Sleep, %BO%
    ControlSend,, {%turnLeft% up}, ahk_id %id% 
    Sleep, 5500
    
    
    return 
    
    
Menu:
    loop, 8{
        gosub, PressX
    ToolTip, %A_Index% X, 400, 400
        Sleep, 1400
    }
    Sleep, 2000
    ToolTip, Press right, 400, 400
    ControlSend,, {%turnRight% down}, ahk_id %id% 
    Sleep, %BO%
    ControlSend,, {%turnRight% up}, ahk_id %id% 
    Sleep, 500
    ToolTip, Press X, 400, 400
    gosub, PressX
    Sleep, 3000
    return


;; General Functions for AHK

GrabRemotePlay:
WinGet, remotePlay_id, List, ahk_exe RemotePlay.exe
if (remotePlay_id = 0)
{
    MsgBox, PS4 Remote Play not found
    return
}
Loop, %remotePlay_id%
{
  id := remotePlay_id%A_Index%
  WinGetTitle, title, % "ahk_id " id
  If InStr(title, "PS Remote Play")
    break
}    
WinGetClass, remotePlay_class, ahk_id %id%
WinMove, ahk_id %id%,, 0, 0, 640, 360
ControlFocus,, ahk_class %remotePlay_class%
WinActivate, ahk_id %id%
return


PauseLoop:
    ControlSend,, {%accel% up}, ahk_id %id% 
    ControlSend,, {%turnLeft% up}, ahk_id %id% 
    ControlSend,, {%turnRight% up}, ahk_id %id% 
    return

GuiClose:
    gosub, PauseLoop
    ExitApp

^Esc::ExitApp