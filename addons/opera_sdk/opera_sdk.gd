@tool
extends EditorPlugin
class_name OperaSdk

const GxSettings = preload("res://addons/opera_sdk/UI/GxSettings.gd")
const ProgressBarScene = preload("res://addons/opera_sdk/UI/ProgressBar.tscn")
const ProgressBarType = preload("res://addons/opera_sdk/UI/ProgressBar.gd")

var _dock_instance: GxSettings
var _opera_adapter: OperaSdkFacade
var _progress_bar: ProgressBarType
var _exporter: GxGamesExportPlugin

func _enter_tree():
	_dock_instance = preload("res://addons/opera_sdk/UI/GxSettings.tscn").\
		instantiate()
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, _dock_instance)
	
	var export_preset_added = GxExportPreset.try_add_export_preset()
	GxExportPreset.create_folder_for_game_bundle()
	
	_opera_adapter = OperaSdkFactory.create_opera_sdk(_dock_instance)
	OperaSdkFactory.subscribe_signals(_opera_adapter, self)
	_opera_adapter.OnPluginActivated()
	_dock_instance.initialize(_opera_adapter)
	
	_exporter = GxGamesExportPlugin.new(_opera_adapter)
	add_export_plugin(_exporter)
	
	# Note: The way autoload scripts are stored in the project settings could
	# be changed in next versions of Godot.
	if(!ProjectSettings.get_setting("autoload/GxGames")):
		add_autoload_singleton("GxGames", "res://addons/opera_sdk/RuntimeSDK/Public/GxGames.gd")
	
	if export_preset_added:
		_show_restart_request_dialogue()

func _exit_tree():
	remove_control_from_docks(_dock_instance)
	_dock_instance.queue_free()
	remove_export_plugin(_exporter)
	
	remove_autoload_singleton("GxGames")

func on_process_started():
	_dock_instance.call_deferred("on_process_started")

func on_state_changed():
	_dock_instance.call_deferred("on_state_changed")
	
func on_progress_began(title, info, progress_value):
	call_deferred("on_progress_began_main_thread", title, info, progress_value)
	
func on_progress_began_main_thread(title, info, progress_value):
	_progress_bar = ProgressBarScene.instantiate()
	EditorInterface.popup_dialog_centered(_progress_bar)
	_progress_bar.initialize(title, info, progress_value, _opera_adapter)

func on_progress_step(title, info, progress_value):
	call_deferred("on_progress_step_main_thread", title, info, progress_value)

func on_progress_step_main_thread(title, info, progress_value):
	_progress_bar.on_progress_step(title, info, progress_value)

func on_progress_ended():
	call_deferred("on_progress_ended_main_thread")

func on_progress_ended_main_thread():
	_progress_bar.close()
	
func show_message(message: String):
	call_deferred("_do_show_message", message)

func _do_show_message(message: String):
	var dialog = AcceptDialog.new()
	dialog.dialog_text = message
	dialog.title = "GX.Games"
	dialog.exclusive = true
	dialog.transient = true
	dialog.unresizable = true
	EditorInterface.popup_dialog_centered(dialog)

func _show_restart_request_dialogue():
	var dialog = AcceptDialog.new()
	dialog.dialog_text = "Added an export template for GX.Games.\nIt is necessary to restart the " +\
		"editor to apply the changes. Restart now?"
	dialog.title = "GX.Games"
	dialog.exclusive = true
	dialog.transient = true
	dialog.unresizable = true
	EditorInterface.popup_dialog_centered(dialog)
	
	dialog.get_ok_button().button_up.connect(EditorInterface.restart_editor)
	dialog.add_cancel_button("Cancel")
