extends RefCounted
class_name NewGameRegistrator

var _synchronizer: GameSynchronizer;
var _registerGameRequest: RegisterGameRequest;

func _init(synchronizer: GameSynchronizer, registerGameRequest: RegisterGameRequest):
	_synchronizer = synchronizer
	_registerGameRequest = registerGameRequest

func RegisterGame(gameName: String, groupId: String) -> bool:
	var newGameData = _registerGameRequest.GXC_Create(gameName, groupId);
	
	var registeringSuccess = newGameData != null;
	
	if (registeringSuccess):
		return _synchronizer.SetGameData(newGameData, true);
	else:
		return false;
