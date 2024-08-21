extends RefCounted
class_name AutomatedProcesses

signal process_started
signal process_finished_successfully(message: String)
signal process_failed(message: String)
signal process_settled

var thread = Thread.new()
var _opera_authorization: OperaAuthorization
var _sessionStorage: SessionStorage
var _utils: Utils
var _game_synchronizer: GameSynchronizer
var _local_game_data: LocalGameData
var _new_game_registrator: NewGameRegistrator
var _post_build_actions_manager: PostBuildActionsManager
var _bundle_verifier: BundleVerifier

func _init(
	sessionStorage: SessionStorage, 
	utils: Utils, 
	opera_authorization: OperaAuthorization,
	game_synchronizer: GameSynchronizer,
	local_game_data: LocalGameData,
	new_game_registrator: NewGameRegistrator,
	post_build_actions_manager: PostBuildActionsManager,
	bundle_verifier: BundleVerifier
):
	_sessionStorage = sessionStorage
	_utils = utils
	_opera_authorization = opera_authorization
	_game_synchronizer = game_synchronizer
	_local_game_data = local_game_data
	_new_game_registrator = new_game_registrator
	_post_build_actions_manager = post_build_actions_manager
	_bundle_verifier = bundle_verifier

func Update(withSynchronization: bool, forceMinimalNextVersion: bool) -> void:
	RunInThread(_Update.bind(withSynchronization, forceMinimalNextVersion))

func _Update(withSynchronization: bool, forceMinimalNextVersion: bool) -> void:
	if withSynchronization:
		ActWithEvents(func():
			return Authorize() &&\
			Synchronize(forceMinimalNextVersion),
		"",
		"Failed to update")
	else:
		ActWithEvents(func():
			_game_synchronizer.SetDataForNewGame())

func RegisterGameAutomated() -> void:
	RunInThread(_RegisterGameAutomated)

func _RegisterGameAutomated() -> void:
	ActWithEvents(func():
		return Authorize() &&\
		Synchronize() &&\
		RegisterGame(),
		"Successfully registered the game",
		"Failed to register the game. See the console for details.");

func BuildAndUploadAutomated(index_file_path: String, editorExportPlugin: EditorExportPlugin) -> void:
	RunInThread(_BuildAndUploadAutomated.bind(index_file_path, editorExportPlugin))

func _BuildAndUploadAutomated(index_file_path: String, editorExportPlugin: EditorExportPlugin) -> void:
	ActWithEvents(func(): return \
		VerifyBundle(index_file_path, editorExportPlugin) &&\
		Authorize() &&\
		Synchronize() &&\
		RegisterGame() &&\
		PostBuildActions(index_file_path),
		"Successfully uploaded the game",
		"Failed to upload the game. See the console for details.");

func VerifyBundle(index_file_path: String, editorExportPlugin: EditorExportPlugin) -> bool:
	return _bundle_verifier.VerifyBundle(index_file_path, editorExportPlugin)

func PostBuildActions(index_file_path: String) -> bool:
	var gameId = _local_game_data.id;
	return _post_build_actions_manager.PostBuildActions(gameId, index_file_path);

func Authorize() -> bool:
	if IsAuthorized:
		return _opera_authorization.OAUTH2_Reauthorise_Act()
	else:
		return _opera_authorization.OAUTH2_GetToken()

func Synchronize(forceMinimalNextVersion = false) -> bool:
	return _game_synchronizer.SynchronizeAll(forceMinimalNextVersion)

func RegisterGame() -> bool:
	var isAlreadyRegistered = _local_game_data.id != ""
	
	if (isAlreadyRegistered):
		return true;
	
	var gameName: String = _local_game_data.name;
	var groupId: String = _local_game_data.group.studioId;
	
	return _new_game_registrator.RegisterGame(gameName, groupId);

func ActWithEvents(action: Callable, successMessage: String = "", failureMessage: String = "") -> void:
	process_started.emit()
	
	var success = action.call()
	
	if (success && successMessage != ""):
		process_finished_successfully.emit(successMessage);
	
	if (!success && failureMessage != ""):
		process_failed.emit(failureMessage);
	
	process_settled.emit()

func SelectNewGame(newGameId: String, isAuthorized: bool) -> void:
	_local_game_data.id = newGameId;
	
	var newGameIsNew = newGameId == ""
	var skipSynchronization = !isAuthorized && newGameIsNew;
	
	RunInThread(_Update.bind(!skipSynchronization, true))

func RunInThread(action: Callable) -> void:
	var thread_function = func() -> void:
		action.call()
		call_deferred("EndThread")
	
	var threadError = thread.start(thread_function, Thread.PRIORITY_HIGH)

func EndThread() -> void:
	thread.wait_to_finish()

var IsAuthorized: bool:
	get:
		return _sessionStorage.OAUTH2_access_token != ""
