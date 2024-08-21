@tool
extends Button

var _opera_adapter: OperaSdkFacade

func initialize(opera_adapter: OperaSdkFacade):
	_opera_adapter = opera_adapter
	update()

func update():
	disabled = !_opera_adapter.IsNewGame || !_opera_adapter.IsGameNameValid

func _on_RegisterOnGxGames_button_up():
	_opera_adapter.RegisterGame()

func _on_line_edit_text_changed(new_text: String) -> void:
	update()
