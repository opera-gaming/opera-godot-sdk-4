extends CachedCloudData
class_name CachedGameData

# override
func _get_request_url():
	return "gamedev/games?pageSize=1000"

# override
func _reset_storage() -> void:
	_session_storage.GamesData = []

# override
func _set_data_to_storage(data: Dictionary) -> bool:
	var result = []
	
	if data.has("games"):
		var games = data["games"]
		if games is Array:
			for game in games:
				var gameData = GameDataApi.from_dict(game)
				
				if gameData != null:
					result.push_back(gameData)
	else:
		_utils.print_deferred("Could not find games data in the response")
		return false
	
	_session_storage.GamesData = result
	return true
