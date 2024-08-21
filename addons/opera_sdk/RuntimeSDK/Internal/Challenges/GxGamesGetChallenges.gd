extends GxRuntimeRequest
class_name GxGamesGetChallenges

signal challenges_received(
	data: GxGamesGetChallengesData,
	ok: bool, 
	error_codes: Array
)

func get_challenges(
	page: int = 0,
	pageSize: int = 25,
	trackId: String = "",
) -> void:
	if !_window:
		_emit_error([])
		return
	
	var arguments = {
		"gameId": _utils.get_query_param("game"),
		"trackId": trackId if trackId else _utils.get_query_param("track"),
		"page": page,
		"pageSize": pageSize,
	}
	
	_do_request(
		OperaSdkConfig.SERVER_URL + \
			"gg/games/{gameId}/challenges?trackId={trackId}&page={page}&pageSize={pageSize}"
			.format(arguments),
		FetchOptionsFactory.with_credentials()
	)

# override
func _try_parse_data(data: Dictionary) -> bool:
	var data_parsed = GxGamesGetChallengesData.from_dict(data)
	
	if data_parsed:
		challenges_received.emit(data_parsed, true, [])
		return true
	else:
		return false

# override
func _emit_error(
	errors: Array # of String
) -> void:
	challenges_received.emit(null, false, errors)
