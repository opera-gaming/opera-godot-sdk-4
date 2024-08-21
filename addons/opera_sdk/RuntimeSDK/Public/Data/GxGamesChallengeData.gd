extends RefCounted
class_name GxGamesChallengeData

## The ID of the challenge.
var challengeId: String

## A link to the cover art for the challenge.
var coverArt: String

## The date and time when the challenge was created.
var creationDate: String

## The type of the challenge (e.g., "duration").
var type: String

## The winning criteria for the challenge (e.g., "lowest_wins").
var criteria: String

## The date and time when the challenge starts (if timed).
var startsAt: String

## The date and time when the challenge ends (if timed).
var endsAt: String

## Has the challenge ended? (if timed).
var hasEnded: bool

## Has the challenge started? (if timed).
var hasStarted: bool

## Is the challenge published?
var isPublished: bool

## Is the challenge timed?
var isTimedChallenge: bool

## The short description of the challenge.
var shortDescription: String

## The long description of the challenge.
var longDescription: String

## The name of the challenge.
var name: String

## The amount of players who have submitted scores for this challenge.
var players: int

static var _props_names = [
	'challengeId',
	'coverArt',
	'creationDate',
	'type',
	'criteria',
	'startsAt',
	'endsAt',
	'hasEnded',
	'hasStarted',
	'isPublished',
	'isTimedChallenge',
	'shortDescription',
	'longDescription',
	'name',
	'players',
]

static func from_dict(data_raw) -> GxGamesChallengeData:
	return GxParseUtils.try_fill_from_dict(
		GxGamesChallengeData.new(),
		data_raw,
		_props_names
	)

static func from_dict_to_array(data_raw) -> Array:
	return GxParseUtils.from_raw_to_array(data_raw, from_dict)
