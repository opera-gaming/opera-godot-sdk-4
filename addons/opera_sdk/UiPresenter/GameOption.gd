extends RefCounted
class_name GameOption

var gameId: String
var optionName: String

func _init(_gameId: String, _optionName: String):
	gameId = _gameId
	optionName = _optionName

static func create_new_game_option() -> GameOption:
	return GameOption.new("", "[New Game...]")
