extends RefCounted
class_name RegisterGameRequest

var operaAuthorization: OperaAuthorization;
var _utils: Utils
var _request: HttpRequestWrapper
var _session_storage: SessionStorage
var _gx_response_handler: GxResponseHandler

func _init(
	utils: Utils, 
	request: HttpRequestWrapper, 
	session_storage: SessionStorage, 
	gx_response_handler: GxResponseHandler
):
	_utils = utils
	_request = request
	_session_storage = session_storage
	_gx_response_handler = gx_response_handler

func GXC_Create(gameName: String, groupId: String) -> GameDataApi:
	var postData = ('{' +\
		"\"name\": \"{gameName}\"," +\
		"\"studioId\": \"{groupId}\"," +\
		"\"gameEngine\": \"{engineAlias}\"" +\
	'}').format({
		"gameName": gameName,
		"groupId": groupId,
		"engineAlias": OperaSdkConfig.ENGINE_ALIAS,
	});
	
	var serverResponse = _request.post(
		"{0}gamedev/games".format([OperaSdkConfig.SERVER_URL]),
		postData,
		"application/json",
		"Bearer {0}".format([_session_storage.OAUTH2_access_token]),
		"*/*");
	
	if serverResponse:
		var data = _gx_response_handler.get_data_from(serverResponse)
		
		if data == {}:
			_utils.print_deferred("Error on registering the game. See the console for details")
			_utils.print_deferred("Could not parse the following response:" + serverResponse)
			return null
		
		return GameDataApi.from_dict(data)
		
	_utils.print_deferred("Unknown error on registering the game.")
	return null
