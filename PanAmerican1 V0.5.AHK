#NoEnv
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#KeyHistory 0
ListLines Off
Process, Priority, , A
SetBatchLines, -1
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.

SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
DetectHiddenWindows, On
#Persistent



; --------- Controls
accel := "Enter"
turnLeft := "Left"
turnRight := "Right"
brake := "Up"
nitros := "Down"

; --------- Constants 
; Time at turn in seconds and Stablizing control
t := 220000
intensity := 220
delay := 160

color_check1 :=  0x3E1858
color_check2 :=  0x48A267
c1_alt := false

; ---------- Gui Setup -------------
Gui, -MaximizeBox
Gui, 2: -MaximizeBox
Gui, 2: -MinimizeBox
Gui, Color, c282a36, c6272a4
Gui, Add, Button, x15 y10 w70 default, Start
Gui, Add, Button, x15 y40 w70 default gVariableWindow, Variables
Gui, Add, Button, x15 y70 w70 default gGetColo_p, ColorP1
Gui, Add, Button, x110 y70 w70 default gGetColo_g, ColorP2
Gui, Font, ce8dfe3 s9 w550 Bold

;--------- Gui 2 Setup --------------
Gui, 2: Color, c535770, c6272a4
Gui, 2: Font, c11f s9 Bold
Gui, 2: Add, Text,, Turn Length (time miliseconds)
Gui, 2: Add, Edit,  w70 vA, %t%
Gui, 2: Add, Text,, Turn Intensity
Gui, 2: Add, Edit,  w40 vB, %intensity%
Gui, 2: Add, Text,, Turn Delay
Gui, 2: Add, Edit,  w40 vC, %delay%


Gui, 2: Add, Button, x20  y170 gSaveVars, Save 
Gui, 2: Add, Button, x100 y170 gVarDef, Defaults
Gui, Show,w220 h120,  GT7 Pan American AFK
return

VariableWindow:
    Gui, 2: Show, w220 h205, Variables
    return

SaveVars:
    Gui, 2:Submit
    GuiControlGet, t, 2:, A
    GuiControlGet, intensity, 2:, B
    GuiControlGet, delay, 2:, C
    return

VarDef:
    t = 220000
	intensity = 220
	delay := 140
    GuiControl, 2:, A, %t%
    GuiControl, 2:, B, %intensity%
    GuiControl, 2:, C, %delay%
    return

ButtonStart:
    Gui, Submit, NoHide
    id := ""
    SetKeyDelay, 10
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
    loop{
		 ;gosub, Menu
		 gosub, PressX
        DllCall("Sleep", "UInt", 10000) ; This is dependent on load time, probably different for ps4 version
        gosub, Race
        gosub, Menu
    }
    return

PressX:
; Just for menuing, does not hold X down
    ControlSend,, {%accel% down}, ahk_id %id% 
	DllCall("Sleep", "UInt", 200)
    ControlSend,, {%accel% up}, ahk_id %id% 
    return
    
PressRight:
; For turning 
    ControlSend,, {%turnRight% down}, ahk_id %id% 
    Sleep, 50
    ControlSend,, {%turnRight% up}, ahk_id %id% 
    return
    
; given time t in miliseconds, turn right for that long, with intensity being how much the turn button is held for
TurnRight:
	t0 := A_TickCount
	tf := t0+t
	
	loop 	{
		ControlSend,, {%turnRight% down}, ahk_id %id% 
		 DllCall("Sleep", "UInt", intensity)
		ControlSend,, {%turnRight% up}, ahk_id %id% 	
		 DllCall("Sleep", "UInt", delay)
	} until A_TickCount > tf
    return


TurnLeft:
	t0 := A_TickCount
	tf := t0+t
	
	loop 	{
		ControlSend,, {%turnLeft% down}, ahk_id %id% 
		DllCall("Sleep", "UInt", intensity)
		ControlSend,, {%turnLeft% up}, ahk_id %id% 
	
		DllCall("Sleep", "UInt", delay)
	} until A_TickCount > tf
    return


Race:
; Hold Acceleration and manage turning
    
	ControlSend,, {%accel% down}, ahk_id %id% 
	ControlSend,, {%nitros% down}, ahk_id %id% 
	DllCall("Sleep", "UInt", 8200)
	gosub TurnRight
/* 
; This section detects the end of the race. Can be used to be faster/more accurate at the ending but good timing takes less computer resources
Screen:	218, 359 (less often used)
Window:	222, 357 (default)
Client:	214, 326 (recommended)
Color:	3F1757 (Red=3F Green=17 Blue=57)
*/
    loop {
        PixelSearch, x, y, 216, 357, 220, 361, %color_check1%, 20, Fast RGB
            If (ErrorLevel != 0) {
                ControlSend,, {%turnRight% down}, ahk_id %id% 
				Sleep, 140
				ControlSend,, {%turnRight% up}, ahk_id %id% 
				Sleep, 200
            }
            else{
                /* haven't gotten this to work, for color picking when pixel search acting dumb
                if (c1_alt ) {
                    loop, 10{
                        gosub, PressX
                        Sleep, 2000
                    }
                }
                While c1_alt
                    Sleep 1000
                    */
                break
            }
        
        
    }

    ControlSend,, {%accel% up}, ahk_id %id% 
	ControlSend,, {%nitros% up}, ahk_id %id% 
    return
    
        

Menu:
     loop {
         PixelSearch, x, y, 340, 361, 344, 365, %color_check2%, 20, Fast RGB
            If (ErrorLevel != 0) {
                 gosub, PressX
                 sleep 300
            }
            else{
                break
            }
    }
    Sleep, 2000
    ControlSend,, {Esc down}, ahk_id %id% 
    Sleep, 200
    ControlSend,, {Esc up}, ahk_id %id% 
    Sleep, 200
    ControlSend,, {Right down}, ahk_id %id% 
    Sleep, 200
    ControlSend,, {Right up}, ahk_id %id% 
    Sleep, 500
    gosub, PressX
    Sleep, 14000
	gosub, PressX
	Sleep, 1000
	ControlSend,, {Esc down}, ahk_id %id% 
    Sleep, 200
    ControlSend,, {Esc up}, ahk_id %id% 
	loop, 2 {
		gosub, PressX
		Sleep, 500
	}
	Sleep, 7000
	ControlSend,, {Down down}, ahk_id %id% 
    Sleep, 200
    ControlSend,, {Down up}, ahk_id %id% 
	Sleep, 500
	loop, 6 {
		ControlSend,, {Right down}, ahk_id %id% 
		Sleep, 200
		ControlSend,, {Right up}, ahk_id %id% 
		Sleep, 200
	}
	loop, 2{
        gosub, PressX
        Sleep, 1200
    }
	Sleep, 8400
	loop, 2{
        gosub, PressX
        Sleep, 1000
    }
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
WinMove, ahk_id %id%,,  0, 0, 640, 360
ControlFocus,, ahk_class %remotePlay_class%
WinActivate, ahk_id %id%
return

RPwind:
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
WinMove, ahk_id %id%,,  -700, -400, 640, 360
ControlFocus,, ahk_class %remotePlay_class%
WinActivate, ahk_id %id%
return

PixelColorSimple(pc_x, pc_y)
{
    WinGet, remotePlay_id, List, ahk_exe RemotePlay.exe
    if (remotePlay_id = 0)
    {
        MsgBox, PS4 Remote Play not found
        return
    }
    if remotePlay_id
    {
        pc_wID := remotePlay_id[0]
        pc_hDC := DllCall("GetDC", "UInt", pc_wID)
        pc_fmtI := A_FormatInteger
        SetFormat, IntegerFast, Hex
        pc_c := DllCall("GetPixel", "UInt", pc_hDC, "Int", pc_x, "Int", pc_y, "UInt")
        pc_c := pc_c >> 16 & 0xff | pc_c & 0xff00 | (pc_c & 0xff) << 16
        pc_c .= ""
        SetFormat, IntegerFast, %pc_fmtI%
        DllCall("ReleaseDC", "UInt", pc_wID, "UInt", pc_hDC)
        return pc_c
        
    }
}


Distance(c1, c2)
{ ; function by [VxE], return value range = [0, 441.67295593006372]
return Sqrt((((c1>>16)-(c2>>16))**2)+(((c1>>8&255)-(c2>>8&255))**2)+(((c1&255)-(c1&255))**2))
}

GetColo_p:
;Screen:	218, 359 (less often used)
color_check1 := PixelColorSimple(218, 359)
;MsgBox, At the screen with [Replay] [Next Race], Press ColorP2
c1_alt := true

return

GetColo_g:
;Screen:	218, 359 (less often used)
color_check2 := PixelColorSimple(343, 363)
c1_alt := false
return

PauseLoop:
    ControlSend,, {%accel% up}, ahk_id %id% 
	ControlSend,, {%nitros% up}, ahk_id %id% 
    ControlSend,, {%turnLeft% up}, ahk_id %id% 
    ControlSend,, {%turnRight% up}, ahk_id %id% 
    return

GuiClose:
    gosub, PauseLoop
    ExitApp

^Esc::ExitApp