class_name GxGamesExportPlugin 
extends EditorExportPlugin

var _is_gx_export: bool
var _opera_adapter: OperaSdkFacade
var _path: String

func _init(opera_adapter: OperaSdkFacade):
	_opera_adapter = opera_adapter

func _get_name() -> String:
	return "GX.Games uploader"

func _export_begin(
	features: PackedStringArray, 
	is_debug: bool, 
	path: String, 
	flags: int
):
	_path = path
	_is_gx_export = features.has(GxExportPreset.GX_EXPORT_FEATURE)
	
func _export_end():
	if not _is_gx_export:
		return
	
	print("Uploading cancelled. Postprocessing the code for GX.Games...")
	var postprocess_success = _opera_adapter.PostProcessCode(_path, self)
	print("Postprocessing finished. Success: " + str(postprocess_success))
	
	if postprocess_success:
		showDialogueBox()
	else:
		show_error_dialogue_box()

func showDialogueBox():
	var dialog = AcceptDialog.new()
	dialog.exclusive = false
	dialog.dialog_text = "Upload to GX.Games?"
	dialog.title = "GX.Games"
	dialog.exclusive = true
	dialog.transient = true
	dialog.unresizable = true
	EditorInterface.popup_dialog_centered(dialog)
	
	dialog.get_ok_button().button_up.connect(_post_build)
	dialog.add_cancel_button("Cancel")

func _post_build():
	_opera_adapter.PostBuild(_path, self)

func show_error_dialogue_box():
	var dialog = AcceptDialog.new()
	dialog.exclusive = false
	dialog.dialog_text = "Failed to postprocess the compiled game files. See the console for details."
	dialog.title = "GX.Games"
	dialog.exclusive = true
	dialog.transient = true
	dialog.unresizable = true
	EditorInterface.popup_dialog_centered(dialog)
