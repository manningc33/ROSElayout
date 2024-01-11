ReadKeyLayMapPDic( keyType, valType, mapFile ) {
	pdic    := {}
	Loop % 5 {
		keyRow := pklIniCSVs( keyType . ( A_Index - 1 ), "", getPklInfo("File_LayoutMap"), "KeyLayoutMap", "|" )
		valRow := pklIniCSVs( valType . ( A_Index - 1 ), "", getPklInfo("File_LayoutMap"), "KeyLayoutMap", "|" )
		For ix, key in keyRow { 
			if ( ix > valRow.MaxIndex() ) 
				Break
			if ( not key ) 
				Continue
			key := ( keyType == "SC" ) ? upCase( key ) : key 
			key := ( keyType == "VK" ) ? getVKnrFromName( key ) : key 
			val := upCase( valRow[ ix ] )
			val := ( valType == "VK" ) ? getVKnrFromName( val ) : val
			pdic[ key ] := val
		}
	}
	Return pdic
}

detectCurrentWinLayOEMs() { 
	qSCdic  := getPklInfo( "QWSCdic" ) 	
	qVKdic  := getPklInfo( "QWVKdic" )
	oemDic  := {}  ;[ "29","0c","0d","1a","1b","2b","27","28","56","33","34","35" ] 	; "SC0" . SCs[ix]
	For ix, oem in  [ "GR","MN","PL","LB","RB","BS","SC","QU","LG","CM","PD","SL" ] {
		oem := "_" . oem
		qsc := qSCdic[ oem ]
		qvk := qVKdic[ oem ]
		ovk := Format( "VK{:X}", GetKeyVK( qsc ) )
		oemDic[qvk]  := ovk 
	}
	Return oemDic
}

getWinLocaleID() { 
	WinGet, WinID,, A
	WinThreadID := DllCall("GetWindowThreadProcessId", "Int", WinID, "Int", 0)
	WinLocaleID := DllCall("GetKeyboardLayout", "Int", WinThreadID)
	WinLocaleID := ( WinLocaleID & 0xFFFFFFFF )>>16
	Return Format( "{:04x}", WinLocaleID )
}

getVKnrFromName( name ) {
	name := upCase( name )
	if ( not RegExMatch( name, "^VK[0-9A-F]{2}$" ) == 1 ) {
		name := "VK" . pklIniRead( "VK_" . name, "00", getPklInfo("File_LayoutMap"), "VKeyCodeFromName" )
	}
	Return name
}

convertToUTF8( str ) {
	dum := "--" 
	VarSetCapacity( dum, StrPut( str, "CP0" ) ) 
	len := StrPut( str, &dum, "CP0" ) 
	Return StrGet( &dum, "UTF-8" )
}

separateKeyVal( row, ByRef key, ByRef val, esc=0, com=1 ) 	; Because PKL doesn't always use IniRead? Why though?
{
	pos := InStr( row, "=" )
	key := Trim( SubStr( row, 1, pos-1 ))
	val := Trim( SubStr( row,    pos+1 ))
	val := ( com ) ? deleteComments( val ) : val 					; Comment stripping
	val := ( esc ) ? replaceEscape( val ) : val 					; Character escapes
	if ( StrLen( row ) == 0 || SubStr( row, 1, 1 ) == ";" ) {
		key := "<Blank>"
	} else if ( pos == 0 ) {
		key := "<NoKey>"
	}
}

pklJanitorTic:
	_pklSuspendByApp()
;	_pklSuspendByLID()
Return

_pklSuspendByApp() {
	static suspendedByApp := false
	
	if WinActive( "ahk_group SuspendingApps" ) { 
		if ( not suspendedByApp ) {
			suspendedByApp := true
			Gosub suspendOn
		}
	} else if ( suspendedByApp ) {
		suspendedByApp := false
		Gosub suspendOff
	}
}

_pklSuspendByLID() { 											; Suspend EPKL if certain layouts are active
	static suspendedByLID := false 								; (They're specified by LID as seen in About...)

	suspendingLIDs := getPklInfo("suspendingLIDs")
	if inStr( suspendingLIDs, getWinLocaleID() ) { 				; If a specified layout is active...
		if ( not suspendedByLID ) { 							; ...and not already A_IsSuspended...
			suspendedByLID := true
			Gosub suspendOn
		}
	} else if ( suspendedByLID ) {
		suspendedByLID := false
		Gosub suspendOff
	}
}

pklErrorMsg( text ) {
	MsgBox, 0x10, EPKL ERROR, %text%`n`nError # %A_LastError% 	; Error type message box
}

pklSetHotkey(hkIniName, gotoLabel, pklInfoTag) { 				; Set a menu hotkey (used in pkl_init)
	For ix, hkey in pklIniCSVs(hkIniName) {
		if ( hkey == "" )
			Break
		Hotkey, %hkey%, %gotoLabel%
		if ( ix == 1 )
			setPklInfo( pklInfoTag, hkey )
	}
}

loCase( str ) {
	Return % Format( "{:L}", str )
}

upCase( str ) {
	Return % Format( "{:U}", str )
}

convertToANSI(str) {
	dum := "--" 
	VarSetCapacity(dum, StrPut(str, "UTF-8")) 
	len := StrPut(str, &dum, "UTF-8") 
	Return StrGet(&dum, "CP0")
}

deleteComments( str )
{
	str := RegExReplace( str, "m)[ `t]+;.*$" )
	Return str
}

replaceEscape( str )
{
	str := StrReplace( str, "\r", "`r" )
	str := StrReplace( str, "\n", "`n" )
	str := StrReplace( str, "\t", "`t" )
	str := StrReplace( str, "\b", "`b" )
	str := StrReplace( str, "\\", "\"  )
	Return str
}
