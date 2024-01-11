
initPkl() 
{
    settingsFile := getPklInfo("File_Settings")
    if !FileExist(settingsFile) {
        MsgBox, %setFile% file NOT FOUND`nSorry. layout will exit.
    }
    layoutFile := getPklInfo("File_Layout")
    
    ;language set maybe??
    ; set hotkeys
    pklSetHotkey( "suspendMeHotkey", "suspendToggle", "HK_Suspend" )
	pklSetHotkey( "exitMeNowHotkey", "exitPKL", "HK_ExitApp" )
	pklSetHotkey( "refreshMeHotkey", "refreshPKL", "HK_Refresh" )


    For ix,suspApp in pklIniCSVs( "suspendingApps" ) {
		shorthand := { "C " : "ahk_class " , "X " : "ahk_exe " , "T " : "" }
		For needle, newtxt in shorthand
			suspApp := RegExReplace( suspApp, "^" . needle, newtxt )
		GroupAdd, SuspendingApps, %suspApp% 
	}
    
    extMods := pklIniCSVs( "extendMods" )
	setPklInfo( "extendMod1", ( extMods[1] ) ? extMods[1] : "" )
	setPklInfo( "extendMod2", ( extMods[2] ) ? extMods[2] : "" )

    _pklSetInf( "tapModTime" )

   
    ; beginning of layini
    mapFile := getPklInfo("File_LayoutMap")
    QWSCdic := ReadKeyLayMapPDic( "QW", "SC", mapFile )
    setPklInfo( "QWSCdic", QWSCdic )
	QWVKdic := ReadKeyLayMapPDic( "QW", "VK", mapFile )
	setPklInfo( "QWVKdic", QWVKdic )
    mapVK := detectCurrentWinLayOEMs()
	setPklInfo( "oemVKdic", mapVK )

    ; maybe can get rid of
    shiftStates := pklIniRead("shiftStates", "0:1", layoutFile, "baselayout") ; check if theres altgr taken out
    shiftStates := StrSplit( RegExReplace( shiftStates, "[ `t]+" ), ":" )
    setLayInfo( "shiftStates", shiftStates )

    map := pklIniSect(layoutFile, "baselayout")
    extKey := ""
    For ix, row in map {
        separateKeyVal( row, key, entries, 0, 0 )
        if InStr( "<NoKey><Blank>shiftStates", key ) 
		    Continue
        
        _mapKLM(key, "SC")

        entries := RegExReplace( entries, "[ `t]+", "`t" )
        entry   := StrSplit( entries, "`t" )
        numEntr := ( entry.MaxIndex() < 2 + shiftStates.MaxIndex() ) ? entry.MaxIndex() : 2 + shiftStates.MaxIndex() 
        entr1   := ( numEntr > 0 ) ? entry[1] : ""
		entr2   := ( numEntr > 1 ) ? entry[2] : ""
    
        if(InStr(entr1, "/")) {
            tomEnts := StrSplit( entr1, "/" ) 
			entr1   := tomEnts[1]
			tapMod  := _checkModName( tomEnts[2] )
			extKey  := ( loCase( tapMod ) == "extend" ) ? key : extKey 
			setKeyInfo( key . "ToM", tapMod )
        }
        else {
            tapMod := ""
        }
        vkNeedle := "i)^(virtualkey|vk|vkey|-1)$" 
        if RegExMatch(entr1, vkNeedle) {
            numEntr := 2
            entr1 := "VK" . Format( "{:X}", GetKeyVK( key ) )
            entr2 := "VKey"
        }
        if ( numEntr < 2 ) || ( entr1 == "--" ) { 
			Hotkey, *%key%   ,  doNothing 
			Hotkey, *%key% Up,  doNothing 
			Continue
		}
        if ( InStr( "modifier", loCase(entr2) ) == 1 ) { 
			entr1     := _checkModName( entr1 ) 
			extKey    := ( entr1 == "Extend" ) ? key : extKey 
			setKeyInfo( key . "vkey", entr1 )
			entr2     := -2 
		}
        else {
            _mapKLM(entr1, "VK")
            mpdVK  := getVKnrFromName( entr1 )
            mpdVK  := ( mapVK[mpdVK] ) ? mapVK[ mpdVK ] : mpdVK 
            setKeyInfo( key . "vkey", mpdVK )
            entr2   := RegExMatch( entr2, vkNeedle ) ? -1 : entr2
        }
        setKeyInfo(key . "capSt", entr2)
        if ( tapMod ) {
            Hotkey, *%key%   ,  tapOrModDown
			Hotkey, *%key% Up,  tapOrModUp
        }
        else if ( entr2 == -2 ) {
            Hotkey, *%key%   ,  modifierDown
			Hotkey, *%key% Up,  modifierUp
            Continue
        }
        else {
            Hotkey, *%key%,     keyPressed
			Hotkey, *%key% Up,  keyReleased
        }

        Loop % numEntr - 2 {
            keystate := shiftStates[ A_Index ]
            keystateEntry := entry[ A_Index + 2 ]
            if ( StrLen(keystateEntry) == 0 ) {
                Continue
            }
            else if ( StrLen( keystateEntry ) == 1 ) {
                setKeyInfo(key . keystate, Ord(keystateEntry))
            }
            else if (keystateEntry == "--") || (keystateEntry == -1) {
                setKeyInfo(key . keystate, "")
            } 
            else if (keystateEntry == "##") {							; Send this state {Blind} as its VK##
                setKeyInfo( key . keystate , -1 ) 
				setKeyInfo( key . keystate . "s", mpdVK )
            }
            else if RegExMatch(keystateEntry, "i)^(spc|=.space.)") {
                setKeyInfo( key . keystate, 32)
            }
            else {
                keystatePrefix := SubStr(keystateEntry, 1, 1)
                if InStr( "%→$§*α=β~«@Ð&¶", ksP ) {
					keystateEntry :=  SubStr(keystateEntry, 2)
				}
                else {
                    ksP := "%"
                }
                setKeyInfo(key . keystate, keystatePrefix)
                setkeyInfo(key . keystate . "s", keystateEntry)
            }
        }
    } ; end of for loop 
    if (extKey) {
        setLayInfo("ExtendKey", extKey)
        hardLayers := StrSplit(pklIniRead("extHardLayers", "1/1/1/1", settingsFile, "ext"), "/", " ")
        
        Loop % 4 {
            extendNum := A_Index
            thisSect := pklIniRead("ext" .  extendNum,,settingsFile, "ext")
            map := pklIniSect(layoutFile, thisSect)
            if (map.Length() == 0)
                Continue
            For ix, row in map {
                separateKeyVal(row, key, extMapping)
                _mapKLM(key, "SC")
                key := upCase(key)
                if (getKeyInfo(key . "ext" . extendNum) != "")
                    Continue
                setKeyInfo(key . "ext" . extendNum, extMapping)
           } 
        }
        setPklInfo("extReturnTo", StrSplit(pklIniRead("extReturnTo", "1/2/3/4", settingsFile), "/", " "))
    }
    ; dk stuff
    dknames := "deadKeyNames"
    dkFile := getPklInfo("File_Deadkeys")
    For ix, row in pklInisect(dkFile, dknames) {
        separateKeyVal(row, key, val)
        if (val)
            setKeyInfo(key, val)
    }

    ; ico stuff
    icon := readLayoutIcons()
    setLayInfo("Icon_On_File", icon.OnIcon)
    setLayInfo("Icon_Off_File", icon.OffIcon)
    setTrayMenu()
}

activatePKL()
{
    SetTitleMatchMode 2
    DetectHiddenWindows on
    WinGet, id, list, %A_ScriptName%
    Loop % id {
        id := id%A_Index%
        PostMessage, 0x398, 422,,, ahk_id %id%
    }
    Sleep, 10
    Menu, Tray, Icon, % getLayInfo("Icon_On_file")
    Menu, Tray, Icon,,, 1
    Sleep, 10

    setPklInfo("extLvl", 1)

    Sleep, 200
    OnMessage( 0x398, "_MessageFromNewInstance" )

    SetTimer, pklJanitorTic, 1000
}

_pklSetInf(pklInfo) 
{
    setPklInfo(pklInfo, pklIniRead(pklInfo))
}


_mapKLM(ByRef key, type)
{
	static initialized  := false
	static QWSCdic      := []
	static QWVKdic      := []
	static CoSCdic      := []
	if ( not initialized ) {
		mapFile := getPklInfo("File_LayoutMap")
		QWSCdic := getPklInfo( "QWSCdic")
		QWVKdic := getPklInfo("QWVKdic")
		CoSCdic := ReadKeyLayMapPDic( "Co", "SC", mapFile ) 
		initialized := true
	}
	
	KLM := RegExMatch( key, "i)^(Co|QW|vc)" ) 
		? SubStr( key, 1, 2 ) : false 				; Co/QW-2-SC/VK KLM remappings
	KLM := ( KLM == "vc" ) ? "QW" : KLM 			; The vc synonym (case sensitive!) for QW is used for VK codes
	if ( KLM )
		key := %KLM%%type%dic[ SubStr( key, 3 ) ] 	; [Co|QW][SC|VK]dic from Colemak/QWERTY KLM codes to SC/VK
}

_checkModName( key )
{
	static modNames := [ "LShift", "RShift", "CapsLock", "Extend", "AltGr", "SGCaps", "LCtrl", "RCtrl", "LAlt", "RAlt", "LWin", "RWin" ]
	
	For ix, modName in modNames {
		if (InStr( modName, key, 0 ) == 1)
			key := modName
	}
	Return key
}

_MessageFromNewInstance( lparam ) 
{ 
	if ( lparam == 422 )
		ExitApp
}