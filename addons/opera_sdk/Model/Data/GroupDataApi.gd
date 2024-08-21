extends RefCounted
class_name GroupDataApi

var gameMaxSize: int;
var name: String;
var studioId: String;

func _init(_gameMaxSize: int, _name: String, _studioId: String):
	gameMaxSize = _gameMaxSize
	name = _name
	studioId = _studioId

static func from_dict(dict: Dictionary) -> GroupDataApi:
	if dict is Dictionary &&\
		dict.has("gameMaxSize")&&\
		dict.has("name") &&\
		dict.has("studioId"):
		return GroupDataApi.new(
			dict["gameMaxSize"], 
			dict["name"],
			dict["studioId"])
	else:
		return GroupDataApi.new(0, "", "")
