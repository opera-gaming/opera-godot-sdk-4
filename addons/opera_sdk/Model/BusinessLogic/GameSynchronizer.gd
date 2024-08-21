extends RefCounted
class_name GameSynchronizer

var _utils: Utils
var _game_data_storage: LocalGameData
var _refetchables: Array
var _session_storage: SessionStorage
var _versions_synchronizer: BuildVersionsSynchronizer = BuildVersionsSynchronizer.new()

func _init(
	utils: Utils, 
	game_data_storage: LocalGameData, 
	session_storage: SessionStorage,
	refetchables: Array):
	_utils = utils
	_game_data_storage = game_data_storage
	_session_storage = session_storage
	_refetchables = refetchables
	
func SynchronizeAll(forceMinimalNextVersion: bool) -> bool:
	return \
		RefetchAll() &&\
		SynchronizeGameWithGx(forceMinimalNextVersion);
		
func RefetchAll() -> bool:
	var refetchSuccess = true
	
	for refetchable in _refetchables:
		if refetchable is CachedCloudData:
			refetchSuccess = refetchSuccess && refetchable.RefetchData()
	
	return refetchSuccess

func SynchronizeGameWithGx(forceMinimalNextVersion: bool) -> bool:
	var localGameId = _game_data_storage.id;
	
	if !localGameId:
		return SynchronizeNewGame(forceMinimalNextVersion);
	else:
		return SynchronizeExistingGame(localGameId, forceMinimalNextVersion);
	
func SynchronizeExistingGame(gameId: String, forceMinimalNextVersion: bool) -> bool:
	var games = _session_storage.GamesData
	
	var games_with_same_id = games.filter(func (game: GameDataApi): 
		return game.gameId == gameId)

	if (games_with_same_id.size() == 0):
		_utils.print_deferred("Synchronization error: Game data has not been found on the cloud. You may register it as a new game");
		SynchronizeNewGame(forceMinimalNextVersion);
		return false;

	var cloudGameData = games_with_same_id[0]
	
	return SetGameData(cloudGameData, false, forceMinimalNextVersion);

func SynchronizeNewGame(forceMinimalNextVersion: bool) -> bool:
	var group_search_result = GroupForNewGameFinder.FindGroup(_game_data_storage.group, _session_storage.GroupsData)
	var success = group_search_result.success
	var group = group_search_result.group
	
	if !success:
		_utils.print_deferred("Could not find the same group when updating data for the new game.")
	
	_game_data_storage.Set(
		_game_data_storage.name, 
		group, 
		BuildVersion.new(), 
		_versions_synchronizer.FindNewNextVersion("", BuildVersion.new(), _game_data_storage.NextVersion, forceMinimalNextVersion))
	
	return success

func SetDataForNewGame() -> void:
	_game_data_storage.Set(
		_game_data_storage.name,
		_game_data_storage.group,
		BuildVersion.new(),
		_game_data_storage.NextVersion
	);

func SetGameData(cloudGameData: GameDataApi, refetchAll: bool, forceMinimalNextVersion: bool = false) -> bool:
	var refetchSuccess = true;
	
	if (refetchAll):
		refetchSuccess = RefetchAll();
	
	var version = BuildVersion.create_from_string(cloudGameData.version);
	var nextVersion = _game_data_storage.NextVersion
	
	_game_data_storage.Set(
		cloudGameData.title,
		cloudGameData.studio,
		version,
		_versions_synchronizer.FindNewNextVersion(cloudGameData.gameId, version, nextVersion, forceMinimalNextVersion),
		cloudGameData.gameId,
		cloudGameData.editUrl,
		cloudGameData.internalShareUrl,
		cloudGameData.publicShareUrl
	);
	
	return refetchSuccess;
