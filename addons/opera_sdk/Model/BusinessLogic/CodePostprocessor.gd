extends RefCounted
class_name CodePostprocessor

# The config is supposed to be written in the very bottom of index.html under
# the commented section. We are extracting it from here and writing it into a 
# separate file.
# This is how this regex works:
# - <\!-- index.config [...] end index.config.js --> - we are interested in the
#   text between "<\!-- index.config" and "end index.config.js -->";
# - (?<config_code>[...]) - the match group;
# - (?s).* - all symbols including new lines. "(?s)" enables new lines matching mode.
const config_code_regex = r'''<\!-- index.config(?<config_code>(?s).*)end index.config.js -->'''

var _utils: Utils
var _progress_ui: ProgressIndicationInterface

func _init(utils: Utils, progress_ui) -> void:
	_utils = utils
	progress_ui = _progress_ui

func post_process_code(buildDirectory: String) -> bool:
	return _extract_config_js(buildDirectory)

func _extract_config_js(buildDirectory: String) -> bool:
	
	var index_html = FileAccess.get_file_as_string(buildDirectory + '/index.html')
	if !index_html:
		_utils.print_deferred("Could not read index.html. Error: " + str(FileAccess.get_open_error()))
		return false
	
	var regex = RegEx.create_from_string(config_code_regex)
	var result = regex.search(index_html)
	
	if !result:
		_utils.print_deferred(r'''Could not find a necessary code in index.html. Please check the setting "Custom HTML Shell" and use the shell for GX.Games.''')
		return false
	
	var config_code = result.get_string("config_code")

	var index_config_js_path = buildDirectory + '/index.config'
	var file = FileAccess.open(index_config_js_path, FileAccess.WRITE)
	
	if !file:
		_utils.print_deferred("Could not open " + index_config_js_path + " for writing.")
		return false
	
	file.store_string(config_code)
	
	return true
