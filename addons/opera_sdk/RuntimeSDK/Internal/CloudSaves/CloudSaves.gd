extends Node
class_name CloudSaves

const FILE_SYSTEM_TABLE_NAME = "userfs"

var _window: JavaScriptObject
var _utils: GxUrlUtils

func _init(window: JavaScriptObject, utils: GxUrlUtils):
	_window = window
	_utils = utils

func generate_data_path() -> String:
	if !_window:
		printerr("variable `window` is undefined")
		return ""
	
	var gameId = _utils.get_query_param("game")
	
	if !gameId:
		return ""
	else:
		var directory = "/{root}/{gameId}/".format({
			"root": FILE_SYSTEM_TABLE_NAME,
			"gameId": gameId
		})
		
		if !DirAccess.dir_exists_absolute(directory):
			DirAccess.make_dir_recursive_absolute(directory)
		
		return directory
