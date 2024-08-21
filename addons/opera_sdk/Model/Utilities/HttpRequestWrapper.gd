extends RefCounted
class_name HttpRequestWrapper

const TIMEOUT_MILLISECONDS = 10 * 1000 * 1000

var _httpRequest: HTTPRequest
var _serverResponse = ""
var _isWaitingForResponse = false
var _utils: Utils
var _session_storage: SessionStorage
var _progress_ui: ProgressIndicationInterface

var _timeout_remaining: int

func _init(
	httpRequest: HTTPRequest, 
	utils: Utils, 
	session_storage, 
	progress_ui: ProgressIndicationInterface
):
	_httpRequest = httpRequest
	_utils = utils
	_session_storage = session_storage
	_progress_ui = progress_ui
	
func on_http_request_completed(
	result: int, 
	response_code: int, 
	headers: PackedStringArray, 
	body: PackedByteArray) -> void:
	
	if response_code != HTTPClient.RESPONSE_OK:
		_utils.print_deferred("Request error " + str(response_code) + "; result: " + str(result))
	
	_serverResponse = body.get_string_from_utf8()
	
	_isWaitingForResponse = false

func post(
	url: String, 
	postData: String, 
	contentType: String, 
	authorization = "", 
	accept = ""
) -> String:
	if _isWaitingForResponse:
		_utils.print_deferred("Is already waiting for response")
		return ""
		
	_serverResponse = ""
	_isWaitingForResponse = true
	_timeout_remaining = TIMEOUT_MILLISECONDS
	
	var customHeaders = []
	
	if contentType:
		customHeaders.push_back("Content-Type: " + contentType)
	if authorization:
		customHeaders.push_back("Authorization: " + authorization)
	if accept:
		customHeaders.push_back("Accept: " + accept)
	
	call_deferred("_doRequest", url, HTTPClient.METHOD_POST, customHeaders, postData)
	
	_wait_for_response()
	
	return _serverResponse

func get_request(requestPath: String) -> String:
	if _isWaitingForResponse:
		_utils.print_deferred("Is already waiting for response")
		return ""
		
	_serverResponse = ""
	_isWaitingForResponse = true
	_timeout_remaining = TIMEOUT_MILLISECONDS
	
	var request = OperaSdkConfig.SERVER_URL + requestPath
	var customHeaders = [ "Authorization: Bearer " + _session_storage.OAUTH2_access_token ]
	
	call_deferred("_doRequest", request, HTTPClient.METHOD_GET, customHeaders)
	
	_wait_for_response()
	
	return _serverResponse

# This function is supposed to be called in the main thread. Otherwise it doesn't work
func _doRequest(url, method, customHeaders, postData = ""):
	var error = _httpRequest.request(
		url, 
		customHeaders,
		method, 
		postData)
	
	if (error != OK):
		print("An error occurred in the HTTP request: " + str(error))
		_isWaitingForResponse = false
		return ""

func UploadGame(gameId: String, version: String, file_path: String) -> String:
	# Currently, the implementation is synchronous without informing about the progress. It looks like the progress could be 
	# implemented with Godot.HTTPClient only.
	
	if _isWaitingForResponse:
		_utils.print_deferred("Is already waiting for response")
		return ""
		
	_serverResponse = ""
	_isWaitingForResponse = true
	_timeout_remaining = TIMEOUT_MILLISECONDS
	
	var requestUri = "{serverURL}gamedev/games/{gameId}/bundles?version={version}".format({
		"serverURL": OperaSdkConfig.SERVER_URL,
		"gameId": gameId,
		"version": version,
	});
	
	const BOUNDARY = "BOUNDARY_7c649d7b-b230-4982-964b-569d09cb38ac"
	
	var filename = "game-bundle"
	
	var data_bytes = FileAccess.get_file_as_bytes(file_path)
	if data_bytes.size() == 0:
		_utils.print_deferred("Error on reading the file: " + str(FileAccess.get_open_error()))
		return ""
	
	var content = ('''--{boundary}\r\n''' + \
		'''Content-Type: application/zip\r\n''' + \
		'''Content-Disposition: form-data; name=file; filename={filename}; filename*=utf-8''{filename}\r\n\r\n'''
	).format({
		"boundary": BOUNDARY,
		"filename": filename,
		"data_bytes": data_bytes,
	}).to_utf8_buffer() + \
	data_bytes + \
	'''\r\n--{boundary}--\r\n'''.format({
		"boundary": BOUNDARY,
		"filename": filename,
		"data_bytes": data_bytes,
	}).to_utf8_buffer()
	
	var customHeaders = [
		r'''Authorization: Bearer {bearer}'''.format({"bearer": _session_storage.OAUTH2_access_token}),
		r'''Content-Type: multipart/form-data; boundary="{boundary}"'''.format({"boundary": BOUNDARY}),
		r'''Connection: keep-alive''', 
	]
	
	call_deferred("_doRawRequest", requestUri, customHeaders, HTTPClient.METHOD_POST, content)
	
	_progress_ui.DisplayCancelableProgressBar("Uploading", "Uploading...", -1)
	
	_wait_for_response()
	
	return _serverResponse

func _wait_for_response():
	while _isWaitingForResponse:
		OS.delay_msec(1)
		
		_timeout_remaining -= 1
		
		if _timeout_remaining <= 0:
			_utils.print_deferred("Connection timed out")
			_httpRequest.call_deferred("cancel_request")
			_isWaitingForResponse = false
			break
		
		if _progress_ui.is_cancelled:
			_utils.print_deferred("Cancelled by the user")
			_httpRequest.call_deferred("cancel_request")
			_isWaitingForResponse = false
			break

func _doRawRequest(requestUri: String, customHeaders: PackedStringArray, method: HTTPClient.Method, content: PackedByteArray) -> void:
	var error = _httpRequest.request_raw(requestUri, customHeaders, method, content)
	
	if error != OK:
		print("An error occurred in the HTTP request: " + str(error))
		_isWaitingForResponse = false

func _get_filename_from(path: String) -> String:
	var slices = path.split("/")
	
	if slices.size() > 0:
		return slices[slices.size() - 1]
	else:
		return ""
