extends GxRuntimeRequest
class_name GxGamesGetScores

var _endpoint_ending: String

func _init(window: JavaScriptObject, utils: GxUrlUtils, endpoint_ending: String):
	super(window, utils)
	_endpoint_ending = endpoint_ending

signal scores_received(
	scores: GxGamesGetScoresData,
	ok: bool, 
	error_codes: Array
)

func get_scores(
	page: int = 0,
	pageSize: int = 25,
	challengeId: String = "",
	trackId: String = "",
) -> void:
	if !_window:
		_emit_error([])
		return
	
	var arguments = {
		"gameId": _utils.get_query_param("game"),
		"challengeId": challengeId if challengeId else _utils.get_query_param("challenge"),
		"endpoint_ending": _endpoint_ending,
		"trackId": trackId if trackId else _utils.get_query_param("track"),
		"page": page,
		"pageSize": pageSize,
	}
	
	_do_request(
		OperaSdkConfig.SERVER_URL + \
			"gg/games/{gameId}/challenges/{challengeId}/{endpoint_ending}?trackId={trackId}&page={page}&pageSize={pageSize}"
			.format(arguments),
		FetchOptionsFactory.with_credentials()
	)

# override
func _try_parse_data(data: Dictionary) -> bool:
	var data_parsed = GxGamesGetScoresData.from_dict(data)
	
	if data_parsed:
		scores_received.emit(data_parsed, true, [])
		return true
	else:
		return false

# override
func _emit_error(
	errors: Array # of String
) -> void:
	scores_received.emit(null, false, errors)
