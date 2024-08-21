@tool
extends Button

var _opera_adapter

func initialize(opera_adapter):
	_opera_adapter = opera_adapter

func _on_UploadToGxGames_button_up():
	_opera_adapter.PostBuild()
