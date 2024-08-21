@tool
extends Label

var _opera_adapter: OperaSdkFacade

func initialize(opera_adapter: OperaSdkFacade):
	_opera_adapter = opera_adapter
	update()
	
func update():
	var isAuthorized = _opera_adapter.IsAuthorized
	text = ("You are authorized as " + _opera_adapter.ProfileName) if isAuthorized else "You are not authorzied"
