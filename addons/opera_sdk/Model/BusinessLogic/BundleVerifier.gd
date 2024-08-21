extends RefCounted
class_name BundleVerifier

var _utils: Utils
var _local_game_data: LocalGameData
var _editorExportPlugin: EditorExportPlugin
var _errors: Array # of String
var _warnings: Array # of String
var _valid_names_checker: OperaGxValidNamesChecker = OperaGxValidNamesChecker.new()

func _init(utils: Utils, local_game_data: LocalGameData) -> void:
	_utils = utils
	_local_game_data = local_game_data

func VerifyBundle(index_file_path: String, editorExportPlugin: EditorExportPlugin) -> bool:
	_editorExportPlugin = editorExportPlugin
	_errors = []
	_warnings = []
	
	if !index_file_path.ends_with('index.html'):
		_errors.push_back('Error: Cannot upload to GX.Games. The main file of the bundle should be named "index.html"')
	
	if (_get_option('variant/thread_support')):
		_add_error('Please disable "Thread Support" in the export settings.')
	
	if (_get_option('html/custom_html_shell') != 'res://addons/opera_sdk/gx_html_shell.html'):
		_add_error('Custom HTML shell is not "res://addons/opera_sdk/gx_html_shell.html". Please assign this value to that setting in the export settings.')
	
	if (!_valid_names_checker.IsValid(_local_game_data.name)):
		_add_error('The name is empty or contains invalid characters. Please assign the valid game name in "GxSettings" window.')
	
	for warning in _warnings:
		_utils.print_deferred(warning)
	
	for error in _errors:
		_utils.print_deferred(error)
	
	return _errors.size() == 0

func _get_option(name: StringName):
	return _editorExportPlugin.get_option(name)

func _add_error(description: String) -> void:
	_errors.push_back('Error: Cannot upload to GX.Games. ' + description)

func _add_warning(description: String) -> void:
	_warnings.push_back('Warning: Possible errors when running the project on GX.Games. ' + description)
