extends RefCounted
class_name GroupForNewGameFinder

static func FindGroup(
	currentGroup: GroupDataApi, 
	allGroups: Array #of GroupDataApi
	) -> FindGroupResult:
	var currentGroupId = currentGroup.studioId;
	
	var groupsWithSameId = allGroups.filter(func (group: GroupDataApi): 
		return group.studioId == currentGroupId);
	
	var is_group_empty = !currentGroup || !currentGroup.studioId
	var success: bool = is_group_empty || groupsWithSameId.size() > 0
	var group = _get_group_to_return(groupsWithSameId, allGroups)
	
	return FindGroupResult.new(success, group)

static func _get_group_to_return(groupsWithSameId, allGroups) -> GroupDataApi:
	if groupsWithSameId.size() > 0:
		return groupsWithSameId[0]
	
	if allGroups.size() > 0:
		return allGroups[0]
	
	return GroupDataApi.new(0, "", "")
