@tool
extends LineEdit

var _opera_adapter: OperaSdkFacade

func initialize(opera_adapter: OperaSdkFacade):
	_opera_adapter = opera_adapter
	update()
	
func update():
	text = _opera_adapter.Name
	_set_disabled(!_opera_adapter.IsNewGame)

func _set_disabled(isDisabled):
	if isDisabled:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		modulate = Color(1, 1, 1, 0.6)
	else:
		mouse_filter = Control.MOUSE_FILTER_STOP
		modulate = Color(1, 1, 1, 1)

func _on_LineEdit_text_changed(new_text):
	_opera_adapter.Name = new_text
