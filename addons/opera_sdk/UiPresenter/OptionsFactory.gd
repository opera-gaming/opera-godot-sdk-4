extends RefCounted
class_name OptionsFactory

var _session_storage: SessionStorage
var _current_local_game: LocalGameData

func _init(session_storage: SessionStorage, current_local_game: LocalGameData):
	_session_storage = session_storage
	_current_local_game = current_local_game

func CreateGameOptions() -> Array: #of GameOption
	var gameOptions = _to_game_options(_session_storage.GamesData)
	gameOptions.push_front(GameOption.create_new_game_option())
	
	var games_in_list_with_same_id = gameOptions.filter(func (game: GameOption):
		return game.gameId == _current_local_game.id)
		
	if (games_in_list_with_same_id.size() == 0):
		gameOptions.push_back(GameOption.new(_current_local_game.id, _current_local_game.name))
	
	return gameOptions
	
func _to_game_options(
	games: Array # of GameDataApi
) -> Array: # of GameOption
	var result = []
	
	for game in games:
		if game is GameDataApi:
			result.push_back(GameOption.new(game.gameId, game.title))
	
	return result

func CreateGroupOptions() -> Array: #of GroupOption
	var all_groups = _session_storage.GroupsData
	
	if all_groups != null && all_groups.size() > 0:
		return _to_group_options(all_groups)
	else:
		var locally_saved_group = _current_local_game.group
		return _to_group_options([locally_saved_group])

func _to_group_options(
	groups: Array # of GroupDataApi
	) -> Array: #of GroupOption
	var result = []
	
	for group in groups:
		if group is GroupDataApi:
			result.push_back(GroupOption.new(group.studioId, group.name))
	
	return result
