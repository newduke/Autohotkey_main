;common functions ---------------------------------------------------------
ToolTipTime(tip, time = 1000) {
	ToolTip, % tip
	SetTimer, HideTip, % time
}
DebugTip(tip, level = 1, time = 5000) {
	if (DebugLevel >= level)
		ToolTipTime(tip, time)
}
HideTip:
	ToolTip
return

; just for debugging --------------------------------------------------------
TrueFalse(bool) {
	if (bool)
		return "true"
	return "false"
}
QuotedVar(var) {
	return % var . ": " . %var%
}
Quoted(string){
	string = "%string%"
}

BeginsWith(word, part) {
	return (substr(word, 1, StrLen(part)) == part)
}
