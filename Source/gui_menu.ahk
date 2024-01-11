setTrayMenu() 
{
	menuItems := {	"aboutMe" : ["about...", ""]
				,	"openDir" : ["open containing folder", ""] ; "menuVariable Name" : ["display string", "hotkeyname"]
				,	"refresh" : ["refresh", "Refresh"]
				,	"suspend" : ["suuspend", "Suspend"]
				,	"exitApp" : ["exit", "ExitApp"]	}
	For itemName, info in menuItems {
		%itemName%MenuItem := info[1]
		hotkeyInMenu := getReadableHotkeyString(getPklInfo("HK_" . info[2]))
		%itemName%MenuItem .= ( hotkeyInMenu ) ? _FixAmpInMenu( hotkeyInMenu ) : ""
	}
	name := getPklInfo("name")
	;Menu, Tray, NoStandard 
	Menu, Tray, Tip, %name%
	
	Menu, Tray, add, %aboutMeMenuItem%, showAbout
	Menu, Tray, add, %openDirMenuItem%, openDir
	Menu, Tray, add
    Menu, Tray, add, %refreshMenuItem%, refreshPkl
	Menu, Tray, add, %suspendMenuItem%, suspendToggle
	Menu, Tray, add, %exitAppMenuItem%, exitPKL

	Menu, Tray, Click, 2
	Menu, Tray, Default, %suspendMenuItem%

	Menu, Tray, Icon, %aboutMeMenuItem%, shell32.dll, 24
	Menu, Tray, Icon, %openDirMenuItem%, shell32.dll, 4
	Menu, Tray, Icon, %refreshMenuItem%, shell32.dll, 239
	Menu, Tray, Icon, %suspendMenuItem%, shell32.dll, 110
	Menu, Tray, Icon, %exitAppMenuItem%, shell32.dll, 28
}

pkl_about()
{
	aboutTitle := "about ROSE layout"
	if WinActive( aboutTitle ) { 
		GUI, About: Destroy
		Return
	}
	GUI, About:New,, %aboutTitle%
	GUI, About:Add, Text,, ROSE (revised optimized and stylized extended) keyboard layout created by manning.
	GUI, About:Add, Text,, Based on EPKL (EPiKaL Portable Keyboard Layout) by OEystein B `"Dreymar`" Gadmar
	GUI, About:Add, Text,, created for personal use only. 
	GUI, About:Show
}

readLayoutIcons() {
	For ix, icon in ["on.ico", "off.ico"] {
		iconFile%ix% := "Resources\icon_" . icon
	}
	return {OnIcon : iconFile1, OffIcon : iconFile2}
}

_FixAmpInMenu( menuItem )
{
	menuItem := StrReplace(menuItem, " & ", "+")
	menuItem := " (" . menuItem . ")"
	Return menuItem
}
