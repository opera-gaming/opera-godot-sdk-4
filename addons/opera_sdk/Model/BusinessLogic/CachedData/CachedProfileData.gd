extends CachedCloudData
class_name CachedProfileData

# override
func _get_request_url():
	return "gamedev/profile"

# override
func _reset_storage() -> void:
	_session_storage.ProfileData = ProfileDataApi.new()
	_session_storage.ProfileData.username = ""

# override
func _set_data_to_storage(data: Dictionary) -> bool:
	if data.has("username"):
		if data["username"] != null:
			var new_profile_data = ProfileDataApi.new()
			new_profile_data.username = data["username"]
			_session_storage.ProfileData = new_profile_data
			
			return true
		else:
			print("Your username is empty. This may mean that your registration " + 
				"is not completed. Please complete your registration on GX Dev " + 
				"and try again.")
			
			return false
	
	return false
