extends RefCounted
class_name PostBuildActionsManager

var _gameDataStorage: LocalGameData;
var _synchronizer: GameSynchronizer;
var _request: HttpRequestWrapper
var _gameSizeAnalyzer: GameSizeAnalyzer;
var _utils: Utils
var _session_storage: SessionStorage
var _progress_ui: ProgressIndicationInterface
var _gx_response_handler: GxResponseHandler
var _code_postprocessor: CodePostprocessor
var _zip_directory_packer: ZIPDirectoryPacker = ZIPDirectoryPacker.new()

var _gameId: String;
var _buildDirectory: String;

func _init(
	gameDataStorage: LocalGameData, 
	synchronizer: GameSynchronizer, 
	request: HttpRequestWrapper,
	gameSizeAnalyzer: GameSizeAnalyzer,
	utils: Utils, 
	session_storage: SessionStorage,
	progress_ui: ProgressIndicationInterface,
	gx_response_handler: GxResponseHandler,
	code_postprocessor: CodePostprocessor
):
	_gameDataStorage = gameDataStorage
	_synchronizer = synchronizer
	_request = request
	_gameSizeAnalyzer = gameSizeAnalyzer
	_utils = utils
	_session_storage = session_storage
	_progress_ui = progress_ui
	_gx_response_handler = gx_response_handler
	_code_postprocessor = code_postprocessor

func PostBuildActions(gameId: String, index_file_path: String) -> bool:
	_gameId = gameId;
	_buildDirectory = get_directory_of(index_file_path);
	
	# Checking that we do not export to the project root
	if _buildDirectory == ".":
		_utils.print_deferred("You are trying to export the game to the project's root. " +
			"Please choose another folder")
		return false
	
	_progress_ui.OnProgressBegin("Post build actions", "Starting post build actions");
	
	var actions_result = PostprocessCode() &&\
						 CheckBuildSize() &&\
						 CompressBuild() &&\
						 Upload();
	
	_progress_ui.OnProgressEnd();
	
	return actions_result

func PostprocessCode() -> bool:
	return _code_postprocessor.post_process_code(_buildDirectory)

func CheckBuildSize() -> bool:
	return _gameSizeAnalyzer.UploadingIsAllowedFor(_buildDirectory);

func CompressBuild() -> bool:
	_progress_ui.DisplayCancelableProgressBar("Compressing the build", "Compressing the build", -1);
	
	var success = _zip_directory_packer.archive(_buildDirectory, _buildDirectory + ".zip")
	
	if (_progress_ui.is_cancelled):
		_utils.print_deferred("Cancelled by the user")
	
	return success && !_progress_ui.is_cancelled;

func Upload() -> bool:
	_progress_ui.DisplayCancelableProgressBar("Uploading the game", "Preparing to upload the game", -1);
	
	var gameDataResponse = _request.UploadGame(
		_gameId, 
		_gameDataStorage.NextVersion.to_string(),
		_buildDirectory + ".zip"
	);
	
	var gameData = _parse_game_data(gameDataResponse)
	
	if (gameData != null):
		_synchronizer.SetGameData(gameData, false);
		return true;
	else:
		return false;

func get_directory_of(filename: String) -> String:
	# The filename is taken from Godot functions in this case. And it looks like it always
	# uses forward slashes. So it is the only delimiter here.
	
	var slices_count = filename.get_slice_count("/")
	
	# "+ 1" in the end - to erase the slash as well
	var last_slice_length = filename.get_slice("/", slices_count - 1).length() + 1
	
	return filename.erase(filename.length() - last_slice_length, last_slice_length)

func _parse_game_data(serverResponse: String) -> GameDataApi:
	if serverResponse:
		var data = _gx_response_handler.get_data_from(serverResponse)
		
		if data == {}:
			_utils.print_deferred("Error on uploading the game. See the console for details.")
			_utils.print_deferred("Could not parse the following response:" + serverResponse)
			return null
		
		return GameDataApi.from_dict(data)
	
	_utils.print_deferred("Unknown error on uploading the game.")
	return null

func PostBuildActionsForZip(index_file_path: String) -> void:
	_buildDirectory = get_directory_of(index_file_path);
	
	# Checking that we do not export to the project root
	if _buildDirectory == ".":
		_utils.print_deferred("You are trying to export the game to the project's root. " +
			"Please choose another folder")
		return
	
	_progress_ui.OnProgressBegin("Post build actions", "Starting postprocessing the code");
	
	PostprocessCode();
	
	_progress_ui.OnProgressEnd();
