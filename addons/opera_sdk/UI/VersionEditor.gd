@tool
extends HBoxContainer

signal version_changed(new_version)
var _version: BuildVersion

func update_state(version: BuildVersion, isDisabled: bool):
	_version = version
	_set_is_disabled(isDisabled)
	_display()

func _set_is_disabled(isDisabled):
	_set_node_disabled($HBoxContainer/Major, isDisabled)
	_set_node_disabled($HBoxContainer/Minor, isDisabled)
	_set_node_disabled($HBoxContainer/Build, isDisabled)
	_set_node_disabled($HBoxContainer/Revision, isDisabled)

func _set_node_disabled(node, isDisabled):
	if isDisabled:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
		node.modulate = Color(1, 1, 1, 0.6)
	else:
		node.mouse_filter = Control.MOUSE_FILTER_STOP
		node.modulate = Color(1, 1, 1, 1)

func _display():
	display_category($HBoxContainer/Major, _version.major)
	display_category($HBoxContainer/Minor, _version.minor)
	display_category($HBoxContainer/Build, _version.build)
	display_category($HBoxContainer/Revision, _version.revision)

func display_category(node: LineEdit, version_category: int):
	node.text = str(version_category)
	node.caret_column = node.text.length()

func _on_Major_text_changed(new_text):
	_version.major = int(new_text)
	_commit_version_change()

func _on_Minor_text_changed(new_text):
	_version.minor = int(new_text)
	_commit_version_change()

func _on_Build_text_changed(new_text):
	_version.build = int(new_text)
	_commit_version_change()

func _on_Revision_text_changed(new_text):
	_version.revision = int(new_text)
	_commit_version_change()

func _commit_version_change():
	_display()
	emit_signal("version_changed", _version)
