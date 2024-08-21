extends RefCounted
class_name OperaAuthorization

const RESPONSE_PAGE = r"<!DOCTYPE html>
<html>
<body>
<h1>Ok. OAuth2 received... please close this tab and go back to the game engine</h1>
</body>
</html>"

const ALLOWED_NONCE_CHARS = \
	"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

const AUTH_URI_TEMPLATE = \
	"{authHost}?response_type={responseType}&client_id={clientID}&redirect_uri={redirect_uri}&state={stateNonce}&scope={scope}"

var _utils: Utils
var _progress_ui: ProgressIndicationInterface
var _request: HttpRequestWrapper
var _session_storage: SessionStorage

func _init(
	utils: Utils, 
	progress_ui: ProgressIndicationInterface, 
	request: HttpRequestWrapper,
	session_storage: SessionStorage
):
	_utils = utils
	_progress_ui = progress_ui
	_request = request
	_session_storage = session_storage

func OAUTH2_Reauthorise_Act() -> bool:
	var ret = false
	
	if _get_time_now_int() > _session_storage.Expiry:
		if !OAUTH2_RefreshToken():
			OAUTH2_GetToken()
	
	if _session_storage.OAUTH2_access_token:
		ret = true
		
	return ret

func OAUTH2_GetToken() -> bool:
	var uri = AUTH_URI_TEMPLATE.format({
		"authHost": get_auth_host(),
		"responseType": "code",
		"clientID": OperaSdkConfig.CLIENT_ID,
		"redirect_uri": OperaSdkConfig.REDIRECT_URI,
		"stateNonce": get_nonce(),
		"scope": OperaSdkConfig.SCOPE,
	})
	
	var server = TCPServer.new()
	var listenError = server.listen(8891)
	
	if listenError != OK:
		_utils.print_deferred("Could not listen the port 8891 on localhost. Error: " + str(listenError))
		return false
	
	OS.shell_open(uri)
	
	_progress_ui.OnProgressBegin(
		"Authorization", "Waiting for an action from you in the browser...")

	var is_listening = true
	var clients = []
	var code = ""
	var exiting_early = false
	var timeout = 10 * 1000 * 1000
	
	while  is_listening:
		OS.delay_msec(1000)
		
		if _progress_ui.DisplayCancelableProgressBar(
			"Authorization", 
			"Waiting for an action from you in the browser...", 
			-1):
			_utils.print_deferred("Authorization has been cancelled.")
			break
			
		timeout -= 1000
		if timeout <= 0:
			_utils.print_deferred("Timeout for authorization is over.")
			break
		
		var new_client = server.take_connection()
		if new_client:
			clients.append(new_client)
		
		for client in clients:
			if client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
				var bytes = client.get_available_bytes()
				if bytes > 0:
					is_listening = false
					
					if !exiting_early:
						var request_string = client.get_string(bytes)
						var query = _utils.get_query_parameters_from(request_string)
						
						if query.has("code"):
							code = query["code"]
							
							var response = HttpResponse.new()
							response.client = client
							response.send(200, RESPONSE_PAGE)
						else:
							if query.has("error") && query.has("error_description"):
								_utils.print_deferred("Error received {error} - {description}".format({
									"error": query["error"],
									"description": query["error_description"],
								}))
							else:
								_utils.print_deferred("Unknown error received: " + str(query))
					
					break
		
	_progress_ui.OnProgressEnd()
	
	for client in clients:
		client.disconnect_from_host()
	server.stop()
	
	if code == "":
		return false
	else:
		return OAUTH2_Authorisation(
			get_token_host(), 
			OperaSdkConfig.REDIRECT_URI, 
			OperaSdkConfig.CLIENT_ID, 
			"", 
			OperaSdkConfig.SCOPE, 
			code)

func get_nonce() -> String:
	var result = ""
	
	for i in 32:
		var randomCharIndex = randi_range(0, ALLOWED_NONCE_CHARS.length() - 1)
		result += ALLOWED_NONCE_CHARS[randomCharIndex]
	
	return result

func get_auth_host() -> String:
	return OperaSdkConfig.OAUTH_SERVER + "authorize/"

func get_token_host() -> String:
	return OperaSdkConfig.OAUTH_SERVER + "token/"

func OAUTH2_RefreshToken() -> bool:
	var postData = "grant_type=refresh_token&refresh_token={0}&client_id={1}&client_secret{2}"\
		.format([_session_storage.OAUTH2_refresh_token, OperaSdkConfig.CLIENT_ID, ""], "{_}")
	
	var serverResponse = _request.post(
		get_token_host(), postData, "application/x-www-form-urlencoded")
	
	if serverResponse:
		HandleOAuthTokenResponse(serverResponse)
		
		if _session_storage.OAUTH2_access_token:
			return true
		else:
			_utils.print_deferred("Reauthorization error: Could not extract access token from the oauth response")
			return false
	else:
		_utils.print_deferred("Reauthorization error: Could not get oauth response")
		return false

func OAUTH2_Authorisation(
	tokenHost: String, 
	redirect: String, 
	clientID: String, 
	clientSecret: String, 
	scope: String, 
	code: String
) -> bool:
	var postData = "grant_type=authorization_code&code={0}&redirect_uri={1}&scope={2}&client_id={3}&client_secret{4}"\
		.format([code, redirect, scope, clientID, clientSecret], "{_}");
	
	var serverResponse = _request.post(
		tokenHost, postData, "application/x-www-form-urlencoded")
	
	if serverResponse:
		HandleOAuthTokenResponse(serverResponse)
		
		if _session_storage.OAUTH2_access_token:
			return true
		else:
			_utils.print_deferred("Authorization error: Could not extract access token from the oauth response")
			return false
	else:
		_utils.print_deferred("Authorization error: Could not get oauth response")
		return false
	
func HandleOAuthTokenResponse(serverResponse: String) -> void:
	_session_storage.clear_auth()
	
	var parsedResponse = JSON.parse_string(serverResponse)
	
	if parsedResponse == null:
		_utils.print_deferred("Could not parse the oauth response")
		return
	
	if parsedResponse.has("access_token"):
		_session_storage.OAUTH2_access_token = parsedResponse.access_token
	if parsedResponse.has("refresh_token"):
		_session_storage.OAUTH2_refresh_token = parsedResponse.refresh_token
	if parsedResponse.has("expires_in"):
		_session_storage.OAUTH2_expires_in = parsedResponse.expires_in
		_session_storage.Expiry = _get_expiry_from(parsedResponse.expires_in)

func _get_expiry_from(OAUTH2_expires_in) -> int:
	return _get_time_now_int() + OAUTH2_expires_in

func _get_time_now_int() -> int:
	return Time.get_unix_time_from_datetime_dict(Time.get_datetime_dict_from_system())
