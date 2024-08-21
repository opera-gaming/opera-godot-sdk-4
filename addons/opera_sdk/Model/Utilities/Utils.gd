extends RefCounted
class_name Utils

# This function is necessary because sometimes the standard "print" function does not work from
# another thread. This one, actually, also doesn't work sometimes, but not so often :) Couldn't 
# find out what's causing it.
# TODO(pavelg): Probably we may add deferred print function for errors and warnings.
func print_deferred(value: String):
	call_deferred("_print", value)

func _print(value: String):
	print(value)

func get_query_parameters_from(request_string: String) -> Dictionary:
	var regex = RegEx.new()
	regex.compile("GET (?<path>[^ ]+) HTTP/1.1")
	var request_path_matches = regex.search(request_string)
	
	if request_path_matches:
		var request_path = request_path_matches.get_string("path")
		var path_query = request_path.split("?")
		return _get_query_from(path_query)

	return {}

func _get_query_from(path_query: PackedStringArray) -> Dictionary:
	if path_query.size() < 2:
		return {}
	
	return _extract_query_params(path_query[1])
	
func _extract_query_params(query_string: String) -> Dictionary:
	var query: Dictionary = {}
	if query_string == "":
		return query
	var parameters: Array = query_string.split("&")
	for param in parameters:
		if not "=" in param:
			continue
		var kv : Array = param.split("=")
		var value: String = kv[1]
		if value.is_valid_int():
			query[kv[0]] = value.to_int()
		elif value.is_valid_float():
			query[kv[0]] = value.to_float()
		else:
			query[kv[0]] = value
	return query
