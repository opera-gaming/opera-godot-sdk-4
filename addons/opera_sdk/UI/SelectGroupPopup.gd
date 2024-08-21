@tool
extends OptionButton

var _opera_adapter: OperaSdkFacade
var _popup: PopupMenu
var _group_options

func initialize(opera_adapter: OperaSdkFacade):
	_opera_adapter = opera_adapter
	_popup = get_popup()
	_popup.id_pressed.connect(_on_item_pressed)
	
	update()
	
func update():
	_popup.clear()
	
	_group_options = _opera_adapter.GroupOptions
	
	for option in _group_options:
		_popup.add_item(option.optionName)
		
	select_current_group()
	disabled = !_opera_adapter.IsNewGame

func select_current_group():
	for option in _group_options:
		if option.groupId == _opera_adapter.GroupId:
			var new_index = _group_options.find(option, 0)
			_popup.set_focused_item(new_index)
			
			text = option.optionName
			return
			
	_popup.set_focused_item(0)
	text = _group_options[0].optionName

func _on_item_pressed(ID):
	var new_group_id = _group_options[ID].groupId
	_opera_adapter.SelectNewGroup(new_group_id)
	_popup.set_focused_item(ID)
	text = _group_options[ID].optionName
