extends RefCounted
class_name GxUrlUtils

var _window: JavaScriptObject

func _init(window: JavaScriptObject):
	_window = window
	
func get_query_param(param: String) -> String:
	if !_window:
		return ""
	
	var searchParams = JavaScriptBridge.create_object(
		'URLSearchParams',
		_window.location.search
	)
	
	var result = searchParams.get(param)
	return result if result else ""
