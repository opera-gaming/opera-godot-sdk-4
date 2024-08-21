extends RefCounted
class_name OperaGxValidNamesChecker

# The regex matches the line (^...$) consisting of zero or more of the following characters:
# any letter from any language (\p{L})
# any number, decimal digit (\p{Nd})
# any of the other symbols until the closed square bracket ("\-" is an escaped symbol)
const regex_pattern = r"^[\p{L}\p{Nd}!? :.,()'&\-]*$"

func IsValid(gameName: String) -> bool:
	if (gameName == ""): 
		return false;
	
	var regex = RegEx.new()
	regex.compile(regex_pattern)
	return regex.search(gameName) != null
