extends RefCounted
class_name FindGroupResult

var success: bool
var group: GroupDataApi

func _init(_success: bool, _group: GroupDataApi):
	success = _success
	group = _group
