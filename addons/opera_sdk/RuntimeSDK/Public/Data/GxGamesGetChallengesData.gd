extends RefCounted
class_name GxGamesGetChallengesData

## An array containing structs for the challenges returned.
var challenges: Array # of GxGamesChallengeData

## Pagination data of the list.
var pagination: GxGamesPaginationData

func _init(
	_challenges: Array,
	_pagination: GxGamesPaginationData,
):
	challenges = _challenges
	pagination = _pagination

static func from_dict(data: Dictionary) -> GxGamesGetChallengesData:
	if data.has("challenges") && \
		data.has("pagination") \
	:
		var challenges = GxGamesChallengeData.from_dict_to_array(data["challenges"])
		var pagination = GxGamesPaginationData.from_dict(data["pagination"])
		
		if challenges != null && \
			pagination != null\
		:
			return GxGamesGetChallengesData.new(challenges, pagination)
	
	return null
