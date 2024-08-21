extends CachedCloudData
class_name CachedGroupData

# override
func _get_request_url():
	return "gamedev/studios?pageSize=1000"

# override
func _reset_storage() -> void:
	_session_storage.GroupsData = []

# override
func _set_data_to_storage(data: Dictionary) -> bool:
	var result = []
	
	if data.has("studios"):
		var studios = data["studios"]
		if studios is Array:
			for studio in studios:
				result.push_back(GroupDataApi.from_dict(studio))
	else:
		_utils.print_deferred("Could not find studios data in the response")
		return false
	
	_session_storage.GroupsData = result
	return true
