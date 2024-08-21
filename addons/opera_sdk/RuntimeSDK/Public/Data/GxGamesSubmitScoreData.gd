extends RefCounted
class_name GxGamesSubmitScoreData

## The flag indicating whether submitted score is the new best score for the given challenge.
var newBestScore: bool

static func from_dict(data: Dictionary) -> GxGamesSubmitScoreData:
	return GxParseUtils.try_fill_from_dict(
		GxGamesSubmitScoreData.new(), 
		data, 
		["newBestScore"]
	)
