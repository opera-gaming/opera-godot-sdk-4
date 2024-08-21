extends GxRuntimeRequest
class_name GxGamesFullVersionChecker

signal payment_status_received(
	is_full_version_purchased: bool,
	ok: bool, 
	error_codes: Array)

func get_full_version_payment_status() -> void:
	if !_window:
		_emit_error([])
		return
	
	var gameId = _utils.get_query_param("game")
	
	_do_request(
		OperaSdkConfig.SERVER_URL + "gg/games/{gameId}/full-version".format({
			"gameId": gameId
		}),
		FetchOptionsFactory.with_credentials()
	)

# override
func _try_parse_data(data: Dictionary) -> bool:
	if data.has("isFullVersionPurchased"):
		var isFullVersionPurchased = data["isFullVersionPurchased"]
		if isFullVersionPurchased is bool:
			payment_status_received.emit(isFullVersionPurchased, true, [])
			return true
	
	return false

# override
func _emit_error(
	errors: Array # of String
) -> void:
	payment_status_received.emit(false, false, errors)
