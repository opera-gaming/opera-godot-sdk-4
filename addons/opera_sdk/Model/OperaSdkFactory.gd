extends RefCounted
class_name OperaSdkFactory

const GxSettings = preload("res://addons/opera_sdk/UI/GxSettings.gd")

static func create_opera_sdk(dock_instance: GxSettings) -> OperaSdkFacade:
	var sessionStorage = SessionStorage.new()
	var local_game_data = LocalGameData.new()
	var utils = Utils.new()
	var progress_ui = ProgressIndicationInterface.new()
	var httpRequestWrapper = _create_http_request_wrapper(
		dock_instance, utils, sessionStorage, progress_ui)
	var gx_response_handler = GxResponseHandler.new(utils)
	
	var register_game_request = RegisterGameRequest.new(
		utils, 
		httpRequestWrapper, 
		sessionStorage,
		gx_response_handler)
	
	var cached_profile_data = CachedProfileData.new(httpRequestWrapper, sessionStorage, utils, gx_response_handler)
	var cached_groups_data = CachedGroupData.new(httpRequestWrapper, sessionStorage, utils, gx_response_handler)
	var cached_games_data = CachedGameData.new(httpRequestWrapper, sessionStorage, utils, gx_response_handler)
	
	var game_synchronizer = GameSynchronizer.new(
		utils, 
		local_game_data, 
		sessionStorage, 
		[
			cached_profile_data,
			cached_groups_data,
			cached_games_data,
		])
	
	var new_game_registrator = NewGameRegistrator.new(
		game_synchronizer, 
		register_game_request)
	
	var game_size_analyzer = GameSizeAnalyzer.new(utils, local_game_data)
	var code_postprocessor = CodePostprocessor.new(utils, progress_ui)
	
	var post_build_actions_manager = PostBuildActionsManager.new(
		local_game_data, 
		game_synchronizer, 
		httpRequestWrapper,
		game_size_analyzer,
		utils, 
		sessionStorage,
		progress_ui,
		gx_response_handler,
		code_postprocessor)
	
	var bundle_verifier = BundleVerifier.new(utils, local_game_data)
	
	var automated_processes = AutomatedProcesses.new(
		sessionStorage, 
		utils, 
		OperaAuthorization.new(
			utils, 
			progress_ui,
			httpRequestWrapper,
			sessionStorage),
		game_synchronizer,
		local_game_data,
		new_game_registrator,
		post_build_actions_manager,
		bundle_verifier)
	
	var options_factory = OptionsFactory.new(sessionStorage, local_game_data)
	
	return OperaSdkFacade.new(
		automated_processes,
		sessionStorage,
		progress_ui,
		options_factory,
		local_game_data,
		post_build_actions_manager)

static func subscribe_signals(
	sdkFacade: OperaSdkFacade, 
	observer: OperaSdk) -> void:
	sdkFacade.process_started.connect(observer.on_process_started)
	sdkFacade.process_settled.connect(observer.on_state_changed)
	sdkFacade.process_finished_successfully.connect(observer.show_message)
	sdkFacade.process_failed.connect(observer.show_message)
	sdkFacade.on_progress_began.connect(observer.on_progress_began)
	sdkFacade.on_progress_step.connect(observer.on_progress_step)
	sdkFacade.on_progress_ended.connect(observer.on_progress_ended)

static func _create_http_request_wrapper(
	dock_instance: GxSettings,
	utils: Utils,
	sessionStorage: SessionStorage,
	progress_ui: ProgressIndicationInterface
) -> HttpRequestWrapper:
	var httpRequestWrapper = HttpRequestWrapper.new(\
		dock_instance.http_request, utils, sessionStorage, progress_ui)
	dock_instance.http_request.request_completed.connect(\
		httpRequestWrapper.on_http_request_completed)
	
	return httpRequestWrapper
