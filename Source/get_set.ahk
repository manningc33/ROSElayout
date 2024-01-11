setKeyInfo( key, value )
{
	Return getKeyInfo( key, value, 1 )
}

setLayInfo( var, val )
{
	Return getLayInfo( var, val, 1 )
}

setPklInfo( key, value )
{
	getPklInfo( key, value, 1 )
}

getKeyInfo( key, value = "", set = 0 )
{
	static pdic     := {}
	if ( set == 1 )
		pdic[key]   := value
	else
		Return pdic[key]
}

getLayInfo( key, value = "", set = 0 )
{
	static pdic     := {}
	if ( set == 1 )
		pdic[key]   := value
	else
		Return pdic[key]
}

getPklInfo( key, value = "", set = 0 )
{
	static pdic     := {}
	if ( set == 1 )
		pdic[key]   := value
	else
		Return pdic[key]
}

getReadableHotkeyString( str ) 
{
	strDic := { "<^>!" : "AltGr"
		,  "<+" : "LShift"  ,  "<^" : "LCtrl"  ,  "<!" : "LAlt"  ,  "<#" : "LWin"
		,  ">+" : "RShift"  ,  ">^" : "RCtrl"  ,  ">!" : "RAlt"  ,  ">#" : "RWin" }
	For key, val in strDic
		str := StrReplace( str, key, val . " & " )
	strDic := { ""
		.  "+"    :  "shift & " ,  "^"    :  "ctrl & " ,  "!"    :  "Alt & " ,  "#"    :  "Win & "
		, "SC029" : "Tilde"     ,  "*"    : ""         ,  "$"    : ""        ,  "~"    : "" }
	For key, val in strDic
		str := StrReplace( str, key, val )
	Return str
}