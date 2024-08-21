@tool
extends "res://addons/opera_sdk/UI/UrlButton.gd"
	
func _get_url():
	return _opera_adapter.InternalShareUrl

func _on_InternalShareUrl_button_up():
	_on_button_up()
