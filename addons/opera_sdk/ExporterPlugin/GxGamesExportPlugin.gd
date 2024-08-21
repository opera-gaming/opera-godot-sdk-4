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
	
	showDialogueBox()

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
	
	var cancel_button = dialog.add_cancel_button("Cancel")
	cancel_button.button_up.connect(_post_build_for_zip)
	
func _post_build():
	_opera_adapter.PostBuild(_path, self)

func _post_build_for_zip():
	print("Uploading cancelled. Postprocessing the code for GX.Games...")
	_opera_adapter.PostBuildActionsForZip(_path)
	print("Postprocessing the code for GX.Games finished.")
