extends RefCounted
class_name OperaSdkFacade

var _automatedProcesses: AutomatedProcesses
var _sessionStorage: SessionStorage
var _progress_ui: ProgressIndicationInterface
var _options_factory: OptionsFactory
var _local_game_data: LocalGameData
var _valid_names_checker: OperaGxValidNamesChecker = OperaGxValidNamesChecker.new()
var _post_build_actions_manager: PostBuildActionsManager

signal on_progress_began
signal on_progress_step
signal on_progress_ended
signal process_started
signal process_finished_successfully(message: String)
signal process_failed(message: String)
signal process_settled

func _init(
	automatedProcesses: AutomatedProcesses,
	sessionStorage: SessionStorage,
	progress_ui: ProgressIndicationInterface,
	options_factory: OptionsFactory,
	local_game_data: LocalGameData,
	post_build_actions_manager: PostBuildActionsManager
):
	_automatedProcesses = automatedProcesses
	_sessionStorage = sessionStorage
	_progress_ui = progress_ui
	_options_factory = options_factory
	_local_game_data = local_game_data
	_post_build_actions_manager = post_build_actions_manager
	
	# Connect events
	_automatedProcesses.process_started.connect(func(): process_started.emit())
	_automatedProcesses.process_finished_successfully.connect(func (message: String): process_finished_successfully.emit(message))
	_automatedProcesses.process_failed.connect(func (message: String): process_failed.emit(message))
	_automatedProcesses.process_settled.connect(func(): process_settled.emit())
	
	progress_ui.on_progress_began.connect(
		func(title: String, info: String, progressValue: float): 
			on_progress_began.emit(title, info, progressValue))
	
	progress_ui.on_progress_step.connect(
		func(title: String, info: String, progressValue: float):
			on_progress_step.emit(title, info, progressValue)
	)
	
	progress_ui.on_progress_ended.connect(func(): on_progress_ended.emit())

var GroupOptions:
	get:
		return _options_factory.CreateGroupOptions()
	
var IsNewGame: bool:
	get:
		return Id == ""
	
var GroupId: String:
	get:
		return _local_game_data.group.studioId

var GameOptions:
	get:
		return _options_factory.CreateGameOptions()
	
var Id: String:
	get:
		return _local_game_data.id
	
var PublicShareUrl: String:
	get:
		return _local_game_data.PublicShareUrl

var InternalShareUrl: String:
	get:
		return _local_game_data.InternalShareUrl
	
var Version: BuildVersion:
	get:
		return _local_game_data.Version

var NextVersion: BuildVersion:
	get:
		return _local_game_data.NextVersion
	set(value):
		_local_game_data.NextVersion = value
	
var IsGameNameValid: bool:
	get:
		return _valid_names_checker.IsValid(Name)

var Name: String:
	get:
		return _local_game_data.name
	set(value):
		_local_game_data.name = value
	
var EditUrl: String:
	get:
		return _local_game_data.EditUrl
	
var IsAuthorized: bool:
	get:
		return _sessionStorage.OAUTH2_access_token != ""
	
var ProfileName: String:
	get:
		return _sessionStorage.ProfileData.username

func OnPluginActivated() -> void:
	if !_local_game_data.name:
		_local_game_data.name = ProjectSettings.get_setting("application/config/name")
		print("Assigned the game name from the project settings.")
	pass

func OpenInGxBrowser(url: String) -> void:
	# TODO: need to use GX.Browser
	OS.shell_open(url)
	
func Update() -> void:
	_automatedProcesses.Update(true, false)

func SelectNewGroup(new_group_id: String) -> void:
	var groups_with_same_id = _sessionStorage.GroupsData.filter(func (group: GroupDataApi):
		return group.studioId == new_group_id)
		
	_local_game_data.group = groups_with_same_id[0] if groups_with_same_id.size() > 0 else GroupDataApi.new(0, "", "")
	
func SelectNewGame(new_game_id: String) -> void:
	_automatedProcesses.SelectNewGame(new_game_id, IsAuthorized)
	
func RegisterGame() -> void:
	_automatedProcesses.RegisterGameAutomated()

func PostBuild(indexFilePath: String, editorExportPlugin: EditorExportPlugin) -> void:
	_automatedProcesses.BuildAndUploadAutomated(indexFilePath, editorExportPlugin)
	pass

func CancelProgress() -> void:
	_progress_ui.CancelProgress()

func PostBuildActionsForZip(index_file_path: String) -> void:
	_post_build_actions_manager.PostBuildActionsForZip(index_file_path)
