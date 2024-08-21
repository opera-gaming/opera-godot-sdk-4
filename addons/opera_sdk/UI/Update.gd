@tool
extends Button

var _opera_adapter: OperaSdkFacade

func initialize(opera_adapter: OperaSdkFacade):
	_opera_adapter = opera_adapter

func _on_Update_button_up():
	_opera_adapter.Update()
