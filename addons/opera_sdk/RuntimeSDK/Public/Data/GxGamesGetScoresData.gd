extends RefCounted
class_name GxGamesGetScoresData

## Requested challenge details.
var challenge: GxGamesChallengeData

## An array containing structs as the scores; these will be sorted from best to
## worst (so the best score will be the first entry in the array, and the worst
## will be the last).
var scores: Array # of GxGamesChallengeScoreData

## Pagination data of the list.
var pagination: GxGamesPaginationData

func _init(
	_challenge: GxGamesChallengeData, 
	_scores: Array, 
	_pagination: GxGamesPaginationData
):
	challenge = _challenge
	scores = _scores
	pagination = _pagination

static func from_dict(data: Dictionary) -> GxGamesGetScoresData:
	if data.has("challenge") && \
		data.has("scores") && \
		data.has("pagination") \
	:
		var challenge = GxGamesChallengeData.from_dict(data["challenge"])
		var scores = GxGamesChallengeScoreData.from_dict_to_array(data["scores"])
		var pagination = GxGamesPaginationData.from_dict(data["pagination"])
		
		if challenge != null && \
			scores != null && \
			pagination != null\
		:
			return GxGamesGetScoresData.new(challenge, scores, pagination)
	
	return null
