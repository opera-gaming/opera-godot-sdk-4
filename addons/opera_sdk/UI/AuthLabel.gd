@tool
extends Label

var _opera_adapter: OperaSdkFacade

func initialize(opera_adapter: OperaSdkFacade):
	_opera_adapter = opera_adapter
	update()
	
func update():
	var isAuthorized = _opera_adapter.IsAuthorized
	
	if isAuthorized:
		var displayedName = (_opera_adapter.ProfileName) \
			if (_opera_adapter.ProfileName != null && _opera_adapter.ProfileName != "") \
			else "[Username Not Set]"
		text = "You are authorized as " + displayedName
	else:
		text = "You are not authorzied"
