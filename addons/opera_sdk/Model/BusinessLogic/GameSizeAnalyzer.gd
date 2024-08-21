extends RefCounted
class_name GameSizeAnalyzer

const BYTES_IN_MEGABYTES = 1024 * 1024;

var _utils: Utils
var _local_game_data: LocalGameData

var _actual_size_bytes: int
var _has_errors_on_finding_directory_size: bool

func _init(utils: Utils, local_game_data: LocalGameData):
	_utils = utils
	_local_game_data = local_game_data

func UploadingIsAllowedFor(pathToFolder: String) -> bool:
	_actual_size_bytes = 0
	_has_errors_on_finding_directory_size = false
	
	FindDirectorySizeBytes(pathToFolder)
	
	if _has_errors_on_finding_directory_size:
		return false
	
	var gameMaxSizeMegaBytes = _local_game_data.group.gameMaxSize;
	var gameMaxSizeBytes = gameMaxSizeMegaBytes * BYTES_IN_MEGABYTES;
	
	if (_actual_size_bytes <= gameMaxSizeBytes):
		return true;
	
	var size_error_message = "Cannot upload the game to GX.Games. Project Size (unpacked): %0.2f MB. Maximum allowed size on GX.Games: %0.2f MB" %\
		[float(_actual_size_bytes) / BYTES_IN_MEGABYTES, gameMaxSizeMegaBytes]
	
	return false

func FindDirectorySizeBytes(folderPath: String) -> void:
	var dir = DirAccess.open(folderPath)
	
	if dir:
		var files = dir.get_files()
		
		for file in files:
			_actual_size_bytes += _get_size_of_file(folderPath + "/" + file)
		
		var subdirectories = dir.get_directories()
		
		for subdirectory in subdirectories:
			FindDirectorySizeBytes(folderPath + "/" + subdirectory)
	else:
		_has_errors_on_finding_directory_size = true
		_utils.print_deferred("The folder {folder} could not be opened. Error: {error}".format({
			"folder": folderPath,
			"error": DirAccess.get_open_error(),
		}))
	
func _get_size_of_file(path_to_file: String) -> int:
	var file = FileAccess.open(path_to_file, FileAccess.READ)
	return file.get_length()
