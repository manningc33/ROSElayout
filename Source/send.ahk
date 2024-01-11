pkl_Send(ch, UD = "down", caps = 0) {
    if pkl_CheckForDKs(ch) 
        Return
    char := Chr(ch)
	pre := ""
    if ( ch == 32 ) {
		char    := "Space"
	} else if ( ch == 9 ) {
		char    := "Tab"
	} else if ( ch > 0 && ch <= 26 ) {
		char    := "^" . Chr( ch + 64 )
	} 
	if caps {
		pre := "{Blind}"
	}
	Send, %pre%{%char% %UD%}
}

pkl_CheckForDKs(ch){
	static SpaceWasSentForSystemDKs = 0
	
	if ( getKeyInfo( "CurrNumOfDKs" ) == 0 ) {					; No active DKs
		SpaceWasSentForSystemDKs = 0
		Return false
	} else {
		setKeyInfo( "CurrBaseKey_", ch )						; DK(s) active, so record the pressed key as Base key
		if ( SpaceWasSentForSystemDKs == 0 )					; If there is an OS dead key that needs a Spc sent, do it
			Send {Space}
		SpaceWasSentForSystemDKs = 1
		Return true
	}
}

pkl_ParseSend(entry, UD = "down", mode = "Input") {
    if (StrLen(entry) < 2) 
        Return false
    psp := SubStr(entry, 1, 1) ; parse syntax prefix (issue with reading greek characters)
    if not InStr( "%→$§*α=β~«@Ð&¶", psp )
        Return false
    pfix := -1
    entry := SubStr(entry, 2)
    if ( psp == "%" || psp == "→" ) { 					; %→ : Literal/string by SendInput {Text}
		mode    := "Input"
		pfix    := "{Text}"
	} else if ( psp == "$" || psp == "§" ) { 					; $§ : Nonkeyboard inputs
		mode    := "SendOnce"
		pfix    := ""
	} else if ( entry == "{CapsLock}" && UD = "down") {						; CapsLock toggle. Stops further entries from misusing Caps?
		togCap  := getKeyState("CapsLock", "T") ? "Off" : "On"
		SetCapsLockState % togCap
	} else if ( psp == "*" || psp == "α" ) { 					; *α : AHK special !+^#{} syntax, omitting {Text}
		pfix    := ""
	} else if ( psp == "=" || psp == "β" ) { 					; =β : Send {Blind} - as above w/ current mod state
		pfix    := "{Blind}"
	} else if ( psp == "~" || psp == "«" ) { 					; ~« : Hex Unicode point U+####
		pfix    := ""
		entry    := "{U+" . entry . "}"
	} else if ( psp == "@" || psp == "Ð" ) { 					; @Ð : Named dead key (may vary between layouts!)
		mode    := "DeadKey"
		pfix    := ""
	} else if ( psp == "&" || psp == "¶" ) { 					; &¶ : Named literal/powerstring (may vary between layouts!)
		mode    := "PwrString"
		pfix    := ""
	}
    if (pfix != -1 && UD = "down") {
        if ( entry && mode == "SendThis" ) { 
			pkl_Send( "", pfix . entry ) 
		} 
		else if ( mode == "DeadKey" ) {
			send_DeadKey( entry )
		} else if (mode == "SendOnce") {
			Send {Blind}{%entry%} 
		}
		else { 
			SendInput % pfix . entry
		}
    }
    Return % psp
}