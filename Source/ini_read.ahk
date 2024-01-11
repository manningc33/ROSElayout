pklIniSect(file, section = "pkl", strip = 0)
{
    if not fileTxt := pklFileRead( file ) {
		MsgBox %file% not available
		ExitApp, 35
	}
	needle := "is)(?:^|\R)[ `t]*\[[ `t]*" . section . "[ `t]*\][^\R]*?\R\K(.*?)(?=$|\R[ `t]*\[)"
	RegExMatch( fileTxt, needle, secTxt )
	secTxt := RegExReplace( secTxt, "`am)^[ `t]*;.*" )
	secTxt := RegExReplace( secTxt, "\R([ `t]*\R)+", "`r`n" )
	secTxt := ( strip ) ? deleteComments( secTxt ) : secTxt 
	Return StrSplit( secTxt, "`n", "`r" )
}

pklIniRead( key, default = "", iniFile = "Files\settings.ini", section = "pkl", strip = 1) 
{
    if ( not key ) {
        Return
    }
    else {
		IniRead, val, %iniFile%, %section%, %key%, %A_Space%
	}

    val := convertToUTF8( val ) 
	val := ( val ) ? val : default
	val := ( strip ) ? deleteComments( val ) : val

	if ( SubStr( val, 1, 3 ) == "..\" ) {
		val := hereDir . "\.." . SubStr( val, 3 )
	} 
    else if ( SubStr( val, 1, 2 ) == ".\"  ) {
		val := hereDir . SubStr( val, 2 )
	}
    Return val
}

pklIniCSVs( key, default = "", iniFile = "Files\settings.ini", section = "pkl", sch = ",", ich = " `t" ) 
{
	val := pklIniRead( key, default, iniFile, section )
	Return StrSplit( val, sch, ich )
}



pklFileRead(file) { 
	try {
		FileRead, content, *P65001 %file% 
	} catch {
		pklErrorMsg( "Failed to read `n  " . file . "." )
		Return false
	}
	Return content
}
