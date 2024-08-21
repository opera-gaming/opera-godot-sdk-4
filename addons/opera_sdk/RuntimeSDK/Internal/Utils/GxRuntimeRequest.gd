extends RefCounted
class_name GxRuntimeRequest

var _window: JavaScriptObject
var _utils: GxUrlUtils
var _response_handler: GxResponseHandler

# JS callbacks references should be stored in the class fields, see the Godot docs.
var _js_callback_parse_response_object: JavaScriptObject
var _js_callback_parse_response_text: JavaScriptObject
var _js_callback_catch: JavaScriptObject

func _init(window: JavaScriptObject, utils: GxUrlUtils):
	_window = window
	_utils = utils
	
	_js_callback_parse_response_object = JavaScriptBridge.create_callback(_parse_response_object)
	_js_callback_parse_response_text = JavaScriptBridge.create_callback(_parse_response_text)
	_js_callback_catch = JavaScriptBridge.create_callback(_catch)
	
	_response_handler = GxResponseHandler.new(Utils.new())

func _do_request(resourse: String, fetch_options) -> void:
	if !_window:
		_emit_error([])
		return
	
	var promise = _window.fetch(
		resourse,
		fetch_options
	).then(
		# calls _parse_response_object through JavaScriptBridge
		_js_callback_parse_response_object
	).catch(
		# calls _catch through JavaScriptBridge
		_js_callback_catch
	)

# This function is converted into a JS callback. See _init() function
func _parse_response_object(args: Array) -> void:
	var response: JavaScriptObject = args[0]
	
	if !response:
		printerr("Error: Could not read the response")
		_emit_error([])
		return
	
	if !response.ok:
		printerr("HTTP Error: " + str(response.status))
		response.text().then(_js_callback_parse_response_text)
		return
	
	response.text().then(
		# calls _parse_response_text through JavaScriptBridge
		_js_callback_parse_response_text
	)

# This function is converted into a JS callback. See _init() function
func _parse_response_text(args: Array) -> void:
	var response_text = args[0]
	
	var data = _response_handler.get_data_from(response_text)
	
	var is_parsing_successfull = _try_parse_data(data)
	
	if !is_parsing_successfull:
		var errors = _response_handler.get_errors_from(response_text)
		_emit_error(errors)

# This function is converted into a JS callback. See _init() function
func _catch(args: Array) -> void:
	var reason = args[0]
	_window.console.error(reason)
	_emit_error([])

# virtual
func _try_parse_data(data: Dictionary) -> bool:
	push_warning("_try_parse_data is not implemented")
	return false

# virtual
func _emit_error(
	errors: Array # of String
) -> void:
	push_warning("_emit_error is not implemented")
