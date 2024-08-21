extends GxRuntimeRequest
class_name GxGamesGetPlayerInfo

signal profile_info_received(
	data: GxGamesPlayerData,
	ok: bool, 
	error_codes: Array
)

func get_profile_info():
	if !_window:
		_emit_error([])
		return
	
	_do_request(
		OperaSdkConfig.SERVER_URL + "gg/profile",
		FetchOptionsFactory.with_credentials()
	)

# override
func _try_parse_data(data: Dictionary) -> bool:
	var data_parsed = GxGamesPlayerData.from_dict(data)
	
	if data_parsed:
		profile_info_received.emit(data_parsed, true, [])
		return true
	else:
		return false

# override
func _emit_error(
	errors: Array # of String
) -> void:
	profile_info_received.emit(null, false, errors)
