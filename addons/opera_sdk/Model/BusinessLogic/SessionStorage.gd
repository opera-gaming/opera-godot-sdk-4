extends Node
class_name SessionStorage

var OAUTH2_access_token: String
var OAUTH2_refresh_token: String
var OAUTH2_expires_in: int

# Unix timestamp in seconds passed since 1970-01-01 at 00:00:00
var Expiry: int

var ProfileData: ProfileDataApi
var GroupsData: Array # of GroupDataApi
var GamesData: Array # of GameDataApi

func clear_auth():
	OAUTH2_access_token = ""
	OAUTH2_refresh_token = ""
	OAUTH2_expires_in = 0
	Expiry = 0
