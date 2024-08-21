class_name BuildVersion

var major: int
var minor: int
var build: int
var revision: int

func _init(
	_major: int = 0,
	_minor: int = 0,
	_build: int = 0,
	_revision: int = 0
):
	major = _major
	minor = _minor
	build = _build
	revision = _revision

static func create_from_string(_version: String) -> BuildVersion:
	var sections = _version.split('.');
	
	var _major: int = 1;
	var _minor: int = 0;
	var _build: int = 0;
	var _revision: int = 0;
	
	_major = (sections[0] as String).to_int()
	if (1 < sections.size()): _minor = (sections[1] as String).to_int()
	if (2 < sections.size()): _build = (sections[2] as String).to_int()
	if (3 < sections.size()): _revision = (sections[3] as String).to_int()
	
	return BuildVersion.new(_major, _minor, _build, _revision)
	
static func clone(_version: BuildVersion) -> BuildVersion:
	var _major = _version.major
	var _minor = _version.minor;
	var _build = _version.build;
	var _revision = _version.revision;
	
	return BuildVersion.new(_major, _minor, _build, _revision)

func is_higher_then(other: BuildVersion) -> bool:
	return CompareTo(other) > 0

func CompareTo(other: BuildVersion) -> int:
	if (major > other.major):
		return 1;
	if (major < other.major):
		return -1;

	if (minor > other.minor):
		return 1;
	if (minor < other.minor):
		return -1;

	if (build > other.build):
		return 1;
	if (build < other.build):
		return -1;

	if (revision > other.revision):
		return 1;
	if (revision < other.revision):
		return -1;

	return 0;

func _to_string():
	return str(major) + "." + str(minor) + "." + str(build) + "." + str(revision);
