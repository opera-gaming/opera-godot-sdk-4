extends RefCounted
class_name CachedCloudData

var _request: HttpRequestWrapper
var _session_storage: SessionStorage
var _gx_response_handler: GxResponseHandler
var _utils: Utils

func _init(
	request: HttpRequestWrapper, 
	session_storage: SessionStorage, 
	utils: Utils, 
	gx_response_handler: GxResponseHandler
):
	_request = request
	_session_storage = session_storage
	_utils = utils
	_gx_response_handler = gx_response_handler

func RefetchData() -> bool:
	_reset_storage()
	
	var response: String = _request.get_request(_get_request_url())
	var data = _gx_response_handler.get_data_from(response)
	
	if data == {}:
		return false
	
	var parsed_successfully = _set_data_to_storage(data)
	return parsed_successfully

# virtual
func _get_request_url():
	return ""

# virtual
func _reset_storage() -> void:
	pass

# virtual
func _set_data_to_storage(data: Dictionary) -> bool:
	return false
