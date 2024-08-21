extends RefCounted
class_name FetchOptionsFactory

# This class contains factory methods for different fetch options.

static func with_credentials():
	var fetch_options = JavaScriptBridge.create_object("Object")
	fetch_options.credentials = "include"
	
	return fetch_options
