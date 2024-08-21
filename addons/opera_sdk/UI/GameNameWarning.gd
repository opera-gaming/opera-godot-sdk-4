@tool
extends Label

var _opera_adapter: OperaSdkFacade

func initialize(opera_adapter: OperaSdkFacade):
	_opera_adapter = opera_adapter
	update_state()
	
func update_state():
	visible = !_opera_adapter.IsGameNameValid

func _on_LineEdit_text_changed(new_text):
	update_state()
