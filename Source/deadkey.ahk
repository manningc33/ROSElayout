DeadKeyValue(dkName, base) {
    val := getKeyInfo("DKval_" . dkName . "_" . base)
    if (not val) {
        dkFile := getPklInfo("File_Deadkeys")
        chr := Chr(base)
        upp := ((64 < base) && (base < 91)) ? "+" : "" 
        cha := convertToANSI(chr)
        val :=  pklIniRead(base,, dkFile, "dk_" . dkName)
        val := (val) ? val : pklIniRead("<" . cha . ">" . upp  ,, dkFile, "dk_" . dkName)
		val := (val) ? val : pklIniRead(Format("0x{:04X}",base),, dkFile, "dk_" . dkName)
		val := (val) ? val : pklIniRead(Format( "~{:04X}",base),, dkFile, "dk_" . dkName)
		val := (val == "--" ) ? -1 : val
		val := (val) ? val : "--"
		if val is integer
			val := Format( "{:i}", val )
		setKeyInfo("DKval_" . dkName . "_" . base, val)
    }
    val := ( val == "--" ) ? 0 : val 
    Return val
}

send_DeadKey(DK) {
    CurrNumOfDKs := getKeyInfo( "CurrNumOfDKs" )
    CurrBaseKey_ := getKeyInfo( "CurrBaseKey_" )
    DK := getKeyInfo( "@" . DK )
    static PVDK := ""
    DeadKeyChar := DeadKeyValue( DK, "s0" ) 
	DeadKeyChr1 := DeadKeyValue( DK, "s1" )


}