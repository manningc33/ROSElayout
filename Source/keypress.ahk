processKeyPress(ThisHotKey, UD = "down")
{
    Critical
    
    global HotKeyBuffer
    static keyTimerCounter = 0
    HotKeyBuffer.Push([ThisHotKey, UD])
    if (++keyTimerCounter > 31) {
        keyTimerCounter = 0
    }
    SetTimer, processKeyPress%keyTimerCounter%, -1
}

runKeyPress()
{
    Critical
    global HotKeyBuffer
    
    if HotKeyBuffer.Length() == 0
        Return
    ThisHotKey := HotKeyBuffer[1][1]
    UD := HotKeyBuffer[1][2]

    HotKeyBuffer.RemoveAt(1)
    Critical, Off
    _keyPressed(ThisHotKey, UD)
}

_keyPressed(HKey, UD = "down")
{
    state := 0
    capHK := getKeyInfo(HKey . "capSt")
    caps := getKeyState("CapsLock", "T")

    if ExtendIsPressed() {
        extendKeyPress(HKey, UD)
        Return
    }

    if (capHK == -1) {
        theVKey := getKeyInfo(HKey . "vkey")
        Send {Blind}{%theVKey% %UD%}
        Return
    }

    if getKeyState("RAlt", "P") {
        sh := getKeyState("Shift")
        if ((capHK & 4) && caps) {
            sh := 1 - sh
            caps := 0
        }
        state := 6 + sh
    }
    else {
        if (getKeyState("LAlt") || getKeyState("Ctrl") || getKeyState("LWin") || getKeyState("RWin")) {
            state := "vkey"
        }
        else {
            state := getKeyState("Shift")
        }
    }

    Pri := getKeyInfo(HKey . state)
    Ent := getKeyInfo(HKey . state . "s")
    if (Pri == "") {
        Return
    }
    else if (Pri == -1) {
        Send {Blind}{%Ent% %UD%}
    } 
    else if (state == "vkey") {
        Send {Blind}{%Pri% %UD%}
    }
    else if ((Pri + 0) > 0) {
        pkl_Send(Pri, UD, caps)
    }
    else {
        Ent := (Ent == "") ? getKeyInfo(HKey . "0s") : Ent
        pkl_ParseSend(Pri . Ent, "SendThis")
    }
}

extendKeyPress(HKey, UD = "up") {
    Critical
    extLevel := getPklInfo("extLvl")
    extVal := getKeyInfo(HKey . "ext" . extLevel)
    static activeKeys := { }

    if (HKey == -1) {
        if (activeKeys.Count()) {
            for ix, key in activeKeys {
                Send {Blind}{%key% Up}
            }
            activeKeys := {}
        }
        Return
    }
    if (extVal == "")
        Return
    if ( RegExMatch( extVal, "i)^([LR]?(?:Shift|Alt|Ctrl|Win))$", mod ) == 1 ) {
		if (UD == "down")
            activeKeys[HKey] := extVal
        else
            activeKeys.Delete(HKey)
        
        Send {Blind}{%extVal% %UD%}
        Return
    }
    returnTo := getPklInfo("extReturnTo")
    setPklInfo("extLvl", returnTo[extLevel])
    
    if not pkl_ParseSend(extVal, UD) {
        if (UD == "down")
            activeKeys[HKey] := extVal
        else
            activeKeys.Delete(HKey)

        Send {Blind}{%extVal% %UD%} 
    }
    Critical, Off
}

setModifierState(theMod, keyDown = 1) 
{
    if ( theMod == "Extend" ) {
		_setExtendState( keyDown )
	} 
    else if (theMod == "AltGr") {
        
    }
    else {
		UD := ( keyDown ) ? "Down" : "Up"
		Send {Blind}{%theMod% %UD%}
	}
}

ExtendIsPressed()
{
    ext := getLayInfo( "ExtendKey" )
	Return % ( ext && getKeyState( ext, "P" ) ) ? true : false
}

_setExtendState(set = 0) 
{
    static extendKey    := -1
	static extMod1      := ""
	static extMod2      := ""
	static extHeld      := 0

    if (extendKey == -1) {
        extendKey := getLayInfo( "ExtendKey" )
		extMod1 := getPklInfo( "extendMod1" )
		extMod2 := getPklInfo( "extendMod2" )
    }

    if (set == 1) && (!extHeld) {
        extLvl  := getKeyState( extMod1, "P" ) ? 2 : 1
        extLvl  += getKeyState( extMod2, "P" ) ? 2 : 0
        setPklInfo("extLvl", extLvl)
        extHeld := 1
    }
    else if (set == 0) {
        extendKeyPress(-1)
        extHeld := 0
    }
}

setTapOrModState(HKey, set = 0) {
    static tapTime := {}
    static tomHeld := {}
    
    tomMod := getKeyInfo(HKey . "ToM")
    tomTime := getPklInfo("tapModTime")

    if (set == 1) {
        if ( ! tomHeld[HKey] ) {
			tomHeld[HKey] := 1 
			SetTimer, tomTimer, -%tomTime% 
			tapTime[HKey] := A_TickCount + tomTime 
			setPklInfo( "tomKey", HKey )
			setPklInfo( "tomMod", tomMod )
        }
        Return 
    } 
    else {
        SetTimer, tomTimer, Off
		setPklInfo( "tomKey", "" )
		tomHeld[HKey] := 0
		if ( A_TickCount < tapTime[HKey] ){
			processKeyPress( HKey )
            processKeyPress(HKey, "up")
        }
		if ( getPklInfo( "tomMod" ) == -1 ) 
			setModifierState( tomMod, 0 )
    }
}

tomTimer: 
    setModifierState(getPklInfo("tomMod"), 1)
	setPklInfo( "tomKey", "" ) 	
	setPklInfo( "tomMod", -1 )
Return

_pkl_CapsState( capState ) 
{
	res = 0
	res := getKeyState("Shift")
	if ( (capState & 1) && getKeyState("CapsLock", "T") )
		res := 1 - res

	Return res
}