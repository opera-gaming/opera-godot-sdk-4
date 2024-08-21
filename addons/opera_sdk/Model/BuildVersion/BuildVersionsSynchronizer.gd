extends Node
class_name BuildVersionsSynchronizer

func FindNewNextVersion(
	gameId: String, 
	currentVersionObj: BuildVersion, 
	nextVersionObj: BuildVersion, 
	forceMinimalNextVersion: bool,
) -> BuildVersion:
	if (forceMinimalNextVersion):
		return BuildVersion.new() if IsNewProject(gameId) else IncrementVersion(currentVersionObj);

	if nextVersionObj.is_higher_then(currentVersionObj):
		return nextVersionObj;

	return IncrementVersion(currentVersionObj);

func IncrementVersion(currentVersionObj: BuildVersion) -> BuildVersion:
	var newNextVersion = BuildVersion.clone(currentVersionObj);
	newNextVersion.revision += 1;
	return newNextVersion;

func IsNewProject(gameId: String) -> bool:
	return gameId == "";
