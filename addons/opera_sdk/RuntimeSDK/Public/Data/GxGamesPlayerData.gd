extends RefCounted
class_name GxGamesPlayerData

var avatarUrl: String
var userId: String
var username: String

static var _props_names = [
	"avatarUrl",
	"userId",
	"username",
]

static func from_dict(data_raw) -> GxGamesPlayerData:
	return GxParseUtils.try_fill_from_dict(
		GxGamesPlayerData.new(),
		data_raw,
		_props_names
	)
