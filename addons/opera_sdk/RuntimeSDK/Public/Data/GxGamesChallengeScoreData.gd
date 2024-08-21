extends RefCounted
class_name GxGamesChallengeScoreData

## The date and time when this score was submitted.
var achievementDate: String

## The country code of the score submitter.
var countryCode: String

## A struct containing the following information about the submitter.
var player: GxGamesPlayerData

## The score value.
var score: int

## The ID of the submitted score.
var scoreId: String

func _init(
	_achievementDate: String,
	_countryCode: String,
	_player: GxGamesPlayerData,
	_score: int,
	_scoreId: String,
):
	achievementDate = _achievementDate
	countryCode = _countryCode
	player = _player
	score = _score
	scoreId = _scoreId

static func from_dict_to_array(data_raw) -> Array:
	return GxParseUtils.from_raw_to_array(data_raw, from_dict)

static func from_dict(data_raw) -> GxGamesChallengeScoreData:
	if data_raw is Dictionary:
		var achievementDate = data_raw.get("achievementDate")
		var countryCode = data_raw.get("countryCode")
		var player = GxGamesPlayerData.from_dict(data_raw.get("player"))
		var score = data_raw.get("score")
		var scoreId = data_raw.get("scoreId")
		
		if  achievementDate && \
			countryCode && \
			player && \
			score != null && \
			scoreId:
			return GxGamesChallengeScoreData.new(achievementDate, countryCode, player, score, scoreId)
	
	return null
