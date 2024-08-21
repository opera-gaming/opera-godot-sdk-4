extends RefCounted
class_name GxResponseHandler

var _utils: Utils

func _init(utils: Utils):
	_utils = utils

# Returns the dictionary extracted from "data" property of the response.
# If extraction failed returns the empty dictionary
func get_data_from(response: String) -> Dictionary:
	var response_dictionary = JSON.parse_string(response)
	
	if !(response_dictionary is Dictionary):
		_utils.print_deferred("Could not parse the data: " + response)
		return {}
	
	if response_dictionary.has("errors") &&\
		response_dictionary["errors"] is Array &&\
		response_dictionary["errors"].size() > 0\
	:
		log_backend_errors("Error in the response: ", response_dictionary["errors"])
		return {}
	
	var data = response_dictionary["data"]
	
	return data if data is Dictionary else {}

func log_backend_errors(message: String, errors: Array):
	var error_codes = []
	
	for error in errors:
		if error is Dictionary:
			if error.has("code"):
				error_codes.push_back(error["code"])
				
	_utils.print_deferred(message + ", ".join(error_codes))

func get_errors_from(response: String) -> Array:
	var response_dictionary = JSON.parse_string(response)
	
	if !(response_dictionary is Dictionary):
		return []
	
	var error_codes = []
	
	if response_dictionary.has("errors") &&\
		response_dictionary["errors"] is Array\
	:
		for error in response_dictionary["errors"]:
			if error is Dictionary:
				if error.has("code"):
					error_codes.push_back(error["code"])
	
	return error_codes
