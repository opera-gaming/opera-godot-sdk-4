extends GxRuntimeRequest
class_name GxGamesSubmitScore

signal submit_score_completed(
	data: GxGamesSubmitScoreData,
	ok: bool, 
	error_codes: Array # of String
)

func challenge_submit_score(score: int, challengeId: String = "") -> void:
	var gameId = _utils.get_query_param("game")
	var finalChallengeId = challengeId if challengeId else _utils.get_query_param("challenge")
	var trackId = _utils.get_query_param("track")
	
	var hash = _calculate_hash(gameId + finalChallengeId + trackId + str(score))
	
	var headers = JavaScriptBridge.create_object("Object")
	headers['Accept'] = 'application/json'
	headers['Content-Type'] = 'application/json'
	
	var fetch_options = JavaScriptBridge.create_object("Object")
	fetch_options.body = '{
		"score": {score}, 
		"hash": "{hash}", 
		"releaseTrackId": "{releaseTrackId}"
	}'.format({
		"score": score,
		"hash": hash,
		"releaseTrackId": trackId,
	})
	fetch_options.credentials = "include"
	fetch_options.method = "POST"
	fetch_options.headers = headers
	
	_do_request(
		OperaSdkConfig.SERVER_URL + 'gg/v2/games/{gameId}/challenges/{challengeId}/scores'.format({
			"gameId": gameId,
			"challengeId": finalChallengeId,
		}),
		fetch_options
	)

func _calculate_hash(input: String) -> String:
	var ctx = HashingContext.new()
	ctx.start(HashingContext.HASH_SHA1)
	
	ctx.update(input.to_utf8_buffer())
	
	var res = ctx.finish()
	
	return res.hex_encode()

# virtual
func _try_parse_data(data: Dictionary) -> bool:
	var data_parsed = GxGamesSubmitScoreData.from_dict(data)
	
	if data_parsed:
		submit_score_completed.emit(data_parsed, true, [])
		return true
	else:
		return false

# virtual
func _emit_error(
	errors: Array # of String
) -> void:
	submit_score_completed.emit(null, false, errors)
