@tool
extends OptionButton

var _opera_adapter: OperaSdkFacade
var _popup
var _game_options

func initialize(opera_adapter):
	_opera_adapter = opera_adapter
	_popup = get_popup()
	_popup.id_pressed.connect(_on_item_pressed)
	
	update()
	
func update():
	_popup.clear()
	_game_options = _opera_adapter.GameOptions
	
	for option in _game_options:
		_popup.add_item(option.optionName)
		
	select_current_game()
		
func select_current_game():
	for option in _game_options:
		if option.gameId == _opera_adapter.Id:
			var new_index = _game_options.find(option, 0)
			_popup.set_focused_item(new_index)
			
			text = option.optionName
			return
			
	_popup.set_focused_item(0)
	text = _game_options[0].optionName

func _on_item_pressed(ID):
	var new_game_id = _game_options[ID].gameId
	_opera_adapter.SelectNewGame(new_game_id)
