@tool
extends AcceptDialog

var _opera_adapter: OperaSdkFacade
@onready var _info_label = $Panel/HBoxContainer2/InfoLabel

func initialize(_title, info, progress_value, opera_adapter: OperaSdkFacade):
	title = _title
	_info_label.text = info
	
	_opera_adapter = opera_adapter
	
	var ok_button = get_ok_button()

func on_progress_step(_title, info, progress_value):
	title = _title
	_info_label.text = info

func close():
	# Need to set this flag to `false`. Otherwise all the other exclusive
	# dialogues would be closed as well, not sure why.
	exclusive = false
	
	queue_free()

func _on_cancel_button_button_up():
	_opera_adapter.CancelProgress()

func _on_canceled():
	_opera_adapter.CancelProgress()

func _on_confirmed():
	_opera_adapter.CancelProgress()
