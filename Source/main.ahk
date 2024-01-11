#NoEnv
#Persistent
#NoTrayIcon
#InstallKeybdHook
#SingleInstance, Force
#MaxThreadsBuffer
#MaxThreadsPerHotkey 3
#MaxHotkeysPerInterval 300
#MaxThreads 30

setPklInfo("name", "manning's pesonalized ROSE layout test")

SendMode Event
SetKeyDelay 0
SetBatchLines, -1
Process, Priority, , H
Process, Priority, , R
SetWorkingDir, %A_ScriptDir%
StringCaseSense, On

global HotKeyBuffer = [] ;keeps tracks of keypresses

setKeyInfo( "CurrNumOfDKs", 0 ) 
setKeyInfo( "CurrNameOfDK", 0 )
setKeyInfo( "CurrBaseKey_", 0 )
setPklInfo( "File_Settings", "Files\settings.ini" )
setPklInfo( "File_Layout", "Files\layout.ini")
setPklInfo("File_LayoutMap", "Files\layoutMap.ini")
setPklInfo("File_Deadkeys", "Files\deadkeys.ini")

;set uiglobal
initPkl()
activatePKL()

Return

processKeyPress0:
processKeyPress1:
processKeyPress2:
processKeyPress3:
processKeyPress4:
processKeyPress5:
processKeyPress6:
processKeyPress7:
processKeyPress8:
processKeyPress9:
processKeyPress10:
processKeyPress11:
processKeyPress12:
processKeyPress13:
processKeyPress14:
processKeyPress15:
processKeyPress16:
processKeyPress17:
processKeyPress18:
processKeyPress19:
processKeyPress20:
processKeyPress21:
processKeyPress22:
processKeyPress23:
processKeyPress24: 	; eD WIP: What's the ideal size of this cycle? Does #MaxThreads apply?
processKeyPress25:
processKeyPress26:
processKeyPress27:
processKeyPress28:
processKeyPress29:
processKeyPress30:
processKeyPress31:
	runKeyPress()
Return

keyPressed: 
	Critical
	processKeyPress(SubStr(A_ThisHotkey, 2), "down")
Return

keyReleased:
	Critical
	processKeyPress(SubStr( A_ThisHotkey, 2, -3 ), "up")
Return

modifierDown:
	Critical
	setModifierState( getKeyInfo( SubStr( A_ThisHotkey, 2 ) . "vkey" ), 1 )
Return

modifierUp:
	Critical
	setModifierState( getKeyInfo( SubStr( A_ThisHotkey, 2, -3 ) . "vkey" ), 0 )
Return

tapOrModDown:
	Critical
	setTapOrModState(SubStr( A_ThisHotkey, 2 ), 1 )
Return

tapOrModUp:
	Critical
	setTapOrModState(SubStr( A_ThisHotkey, 2, -3 ), 0 )
Return

showAbout:
	pkl_about()
Return

suspendOn:
	Suspend, On
	Goto afterSuspend
Return

suspendOff:
	Suspend, Off
	Goto afterSuspend
Return

suspendToggle: 
	Suspend
	Goto afterSuspend
Return

afterSuspend:
	if ( A_IsSuspended ) {
		Menu, Tray, Icon, % getLayInfo( "Icon_Off_File" )
	} else {
		Menu, Tray, Icon, % getLayInfo( "Icon_On_File" )
	}
Return

openDir:
	Run, %A_ScriptDir%
Return

refreshPKL:
	Menu, Tray, Icon,,, 1
	Suspend, On
	
	if ( A_IsCompiled )
		Run %A_ScriptName% /f 
	else
		Run %A_AhkPath% /f %A_ScriptName%
Return

exitPKL: 
	ExitApp
Return

doNothing:
Return

#Include init.ahk
#Include gui_menu.ahk
#Include keypress.ahk
#Include send.ahk
#Include deadkey.ahk
#Include utility.ahk
#Include get_set.ahk
#Include ini_read.ahk