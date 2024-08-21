@tool
extends "res://addons/opera_sdk/UI/UrlButton.gd"

func _get_url():
	return _opera_adapter.EditUrl
	
func _on_EditGameOnOpera_button_up():
	_on_button_up()
