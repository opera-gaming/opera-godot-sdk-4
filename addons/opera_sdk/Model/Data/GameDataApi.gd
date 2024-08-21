extends RefCounted
class_name GameDataApi

var title: String
var editUrl: String
var studio: GroupDataApi
var gameId: String
var internalShareUrl: String
var publicShareUrl: String
var version: String

func _init(
	_title: String,
	_editUrl: String,
	_studio: GroupDataApi,
	_gameId: String,
	_internalShareUrl: String,
	_publicShareUrl: String,
	_version: String
):
	title = _title
	editUrl = _editUrl
	studio = _studio
	gameId = _gameId
	internalShareUrl = _internalShareUrl
	publicShareUrl = _publicShareUrl
	version = _version

static func from_dict(game: Dictionary) -> GameDataApi:
	if game is Dictionary &&\
		game.has("gameId"):
		return GameDataApi.new(
			game["title"] if game.has("title") && game["title"] != null else "",
			game["editUrl"] if game.has("editUrl") && game["editUrl"] != null else "",
			GroupDataApi.from_dict(game["studio"]) if game.has("studio") else GroupDataApi.new(0, "", ""),
			game["gameId"] if game.has("gameId") && game["gameId"] != null else "",
			game["internalShareUrl"] if game.has("internalShareUrl") && game["internalShareUrl"] != null else "",
			game["publicShareUrl"] if game.has("publicShareUrl") && game["publicShareUrl"] != null else "",
			game["version"] if game.has("version") && game["version"] != null else "",
		)
	else:
		return null
