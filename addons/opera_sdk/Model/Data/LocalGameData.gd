extends RefCounted
class_name LocalGameData

var name: String:
	get:
		return GetFromSettingsString("name")
	set(value):
		PutToSettings("name", value)

var id: String:
	get:
		return GetFromSettingsString("id")
	set(value):
		PutToSettings("id", value)

var group: GroupDataApi:
	get:
		return GetGroupFromSettings();
	set(value):
		PutGroupToSettings(value)
	
var Version: BuildVersion:
	get:
		return GetVersionFromSettings("version")
	set(value):
		PutVersionToSettings("version", value)
	
var NextVersion: BuildVersion:
	get:
		return GetVersionFromSettings("next_version")
	set(value):
		PutVersionToSettings("next_version", value)

var EditUrl: String:
	get:
		return GetFromSettingsString("edit_url");
	set(value):
		PutToSettings("edit_url", value);

var InternalShareUrl: String:
	get:
		return GetFromSettingsString("internal_share_url"); 
	set(value):
		PutToSettings("internal_share_url", value);
	
var PublicShareUrl: String: 
	get:
		return GetFromSettingsString("public_share_url"); 
	set(value):
		PutToSettings("public_share_url", value);

var _config: ConfigFile
var CONFIG_FILE_PATH: String = 'res://gxgames.cfg'
var CONFIG_SECTION_NAME: String = 'opera_gx'

func Set(
	_name: String,
	_group: GroupDataApi, 
	_version: BuildVersion,
	_nextVersion: BuildVersion,
	_id: String = "",
	_editUrl: String = "",
	_internalShareUrl: String = "",
	_publicShareUrl: String = "",
) -> void:
	name = _name
	group = _group
	Version = _version
	NextVersion = _nextVersion
	id = _id
	EditUrl = _editUrl
	InternalShareUrl = _internalShareUrl
	PublicShareUrl = _publicShareUrl

func GetFromSettingsString(propertyName: String) -> String:
	var result = GetSettingWithoutWarnings(propertyName)
	return result if result != null else ""

func GetFromSettingsInt(propertyName: String) -> int:
	var result = GetSettingWithoutWarnings(propertyName)
	return result if result != null else 0

func GetSettingWithoutWarnings(name: String):
	_init_config()
	
	if !_config.has_section(CONFIG_SECTION_NAME):
		return null
	
	if !_config.has_section_key(CONFIG_SECTION_NAME, name):
		return null
	
	return _config.get_value(CONFIG_SECTION_NAME, name)

func GetGroupFromSettings() -> GroupDataApi:
	var gameMaxSize = GetFromSettingsInt("group/gameMaxSize")
	var name = GetFromSettingsString("group/name")
	var studioId = GetFromSettingsString("group/groupId")
	
	return GroupDataApi.new(gameMaxSize, name, studioId)

func GetVersionFromSettings(propertyName: String) -> BuildVersion:
	return BuildVersion.new(
		GetFromSettingsInt(propertyName + "/major"),
		GetFromSettingsInt(propertyName + "/minor"),
		GetFromSettingsInt(propertyName + "/build"),
		GetFromSettingsInt(propertyName + "/revision")
	)

func PutToSettings(propertyName: String, value) -> void:
	_init_config()
	_config.set_value(CONFIG_SECTION_NAME, propertyName, value)
	var err = _config.save(CONFIG_FILE_PATH)

func PutGroupToSettings(group: GroupDataApi) -> void:
	PutToSettings("group/groupId", group.studioId);
	PutToSettings("group/name", group.name);
	PutToSettings("group/gameMaxSize", group.gameMaxSize);

func PutVersionToSettings(propertyName: String, version: BuildVersion) -> void:
	PutToSettings(propertyName + "/major", version.major);
	PutToSettings(propertyName + "/minor", version.minor);
	PutToSettings(propertyName + "/build", version.build);
	PutToSettings(propertyName + "/revision", version.revision);

func _init_config():
	if !_config:
		_config = ConfigFile.new()
		_config.load(CONFIG_FILE_PATH)
