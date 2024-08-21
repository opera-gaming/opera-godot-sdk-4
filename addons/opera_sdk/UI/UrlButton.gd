@tool
extends Button

var _opera_adapter: OperaSdkFacade

func initialize(opera_adapter: OperaSdkFacade):
	_opera_adapter = opera_adapter
	
	var url = _get_url()
	disabled = url == null || url == ""
	
func update():
	var url = _get_url()
	disabled = url == null || url == ""

func _on_button_up():
	var url = _get_url()
	
	if url != null && url != "":
		_opera_adapter.OpenInGxBrowser(url)

func _get_url():
	return null
