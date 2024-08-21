extends RefCounted
class_name GxExportPreset

const GX_EXPORT_FEATURE = "opera_gx"
const EXPORT_PRESETS_PATH = "res://export_presets.cfg"
const EXPORT_BUNDLE_DIR = "./GxGamesBundle"

# Returns "true" if the export template has been added.
# False if it already exists in the project.
static func try_add_export_preset() -> bool:
	var cfg = ConfigFile.new()
	cfg.load(EXPORT_PRESETS_PATH)
	
	if (_is_preset_added(cfg)):
		print("GX.Games export preset has been already added")
		return false
	else:
		_add_export_preset(cfg)
		cfg.save(EXPORT_PRESETS_PATH)
		print("Added an export template for GX.Games. Please reload the current project to " +
			"apply the changes")
		return true

static func _add_export_preset(cfg: ConfigFile) -> void:
	var arr = cfg.get_sections()
	var num_exports = len(arr)/2
	var gx_section = "preset" + "." + str(num_exports)
	var gx_options = gx_section + ".options"
	
	#preset.x
	cfg.set_value(gx_section, "name", "Opera GX")
	cfg.set_value(gx_section, "platform", "Web")
	cfg.set_value(gx_section, "runnable", true)
	cfg.set_value(gx_section, "custom_features", GX_EXPORT_FEATURE)
	cfg.set_value(gx_section, "export_filter", "all_resources")
	cfg.set_value(gx_section, "export_path", EXPORT_BUNDLE_DIR + "/index.html")
	cfg.set_value(gx_section, "include_filter", "")
	cfg.set_value(gx_section, "exclude_filter", "")

	#preset.x.options
	cfg.set_value(gx_options, "html/custom_html_shell", "res://addons/opera_sdk/gx_html_shell.html")
	cfg.set_value(gx_options, "variant/thread_support", false)

static func _is_preset_added(cfg: ConfigFile) -> bool:
	var preset_exists = false
	for key in cfg.get_sections():
		if cfg.has_section_key(key, "name"):
			var name: String = cfg.get_value(key, "name")
			if name == "Opera GX":
				preset_exists = true
				break
	return preset_exists

static func create_folder_for_game_bundle():
	if !DirAccess.dir_exists_absolute(EXPORT_BUNDLE_DIR):
		var make_dir_error = DirAccess.make_dir_absolute(EXPORT_BUNDLE_DIR)
		
		if make_dir_error == OK:
			print("Created a folder for the GX.Games bundle: " + EXPORT_BUNDLE_DIR)
		else:
			push_warning("Could not create a default export folder for GX.Games project: " +
				EXPORT_BUNDLE_DIR + ". Error: " + make_dir_error +
				". The project may be exported anyway into another folder.")
