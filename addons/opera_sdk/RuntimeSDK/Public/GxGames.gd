extends Node

## A singleton providing access to GxGames features.

## This signal is emitted after the payment flow is completed. It is invoked
## after calling the function [method GxGames.trigger_payment]. Connect this
## signal to a method to handle the received data.
## The signal is emitted whenever the payment is completed/failed or interrupted.
## This callback does not contain any information about the payment status. You
## should trigger the function [method GxGames.get_full_version_payment_status] to 
## check if the user owns the full version: that is the only reliable way to 
## ensure that the user now has the item.
## [br]
## Arguments:
## [br]
## ● [code]id[/code] - the hashed ID of the item to purchase.
signal payment_completed(id: String)

## This signal is emitted after getting the payment status from the backend. It 
## is invoked after calling the function [method GxGames.get_full_version_payment_status]. 
## Connect this signal to a method to handle the received data.
## [br]
## Arguments:
## [br]
## ● [code]is_full_version_purchased[/code] - tells if the full version has been purchased by the user.
## [br]
## ● [code]error_codes[/code] - an array of error codes extracted from the response. It is also possible that the request was not successful and the error codes array is empty. It may happen if the format of the error response for some reason has unexpected format.
signal payment_status_received(
	is_full_version_purchased: bool,
	ok: bool, 
	error_codes: Array # of String
)

## This signal is emitted after submitting the score to the backend is finished.
## It is invoked after calling the function [method GxGames.challenge_submit_score]. Connect
## this signal to a method to handle the received data.
## [br]
## Arguments:
## [br]
## ● [code]data[/code] - score submission data.
## [br]
## ● [code]ok[/code] - a flag which indicates whether the request was successful or not.
## [br]
## ● [code]error_codes[/code] - an array of error codes extracted from the response. It is also possible that the request was not successful and the error codes array is empty. It may happen if the format of the error response for some reason has unexpected format.
signal submit_score_completed(
	data: GxGamesSubmitScoreData,
	ok: bool, 
	error_codes: Array # of String
)

## This signal is emitted after getting the global scores from the backend. It 
## is invoked after calling the function [method GxGames.challenge_get_global_scores]. 
## Connect this signal to a method to handle the received data.
## [br]
## Arguments:
## [br]
## ● [code]data[/code] - global scores data.
## [br]
## ● [code]ok[/code] - a flag which indicates whether the request was successful or not.
## [br]
## ● [code]error_codes[/code] - an array of error codes extracted from the response. It is also possible that the request was not successful and the error codes array is empty. It may happen if the format of the error response for some reason has unexpected format.
signal global_scores_received(
	scores: GxGamesGetScoresData,
	ok: bool, 
	error_codes: Array)

## This signal is emitted after getting the user scores from the backend. It is
## invoked after calling the function [method GxGames.challenge_get_user_scores]. Connect
## this signal to a method to handle the received data.
## [br]
## Arguments:
## [br]
## ● [code]data[/code] - user scores data.
## [br]
## ● [code]ok[/code] - a flag which indicates whether the request was successful or not.
## [br]
## ● [code]error_codes[/code] - an array of error codes extracted from the response. It is also possible that the request was not successful and the error codes array is empty. It may happen if the format of the error response for some reason has unexpected format.
signal user_scores_received(
	scores: GxGamesGetScoresData,
	ok: bool, 
	error_codes: Array)

## This signal is emitted after getting the challenges list from the backend. 
## It is invoked after calling the function [method GxGames.get_challenges].
## Connect this signal to a method to handle the received data.
## [br]
## Arguments:
## [br]
## ● [code]data[/code] - user scores data.
## [br]
## ● [code]ok[/code] - a flag which indicates whether the request was successful or not.
## [br]
## ● [code]error_codes[/code] - an array of error codes extracted from the response. It is also possible that the request was not successful and the error codes array is empty. It may happen if the format of the error response for some reason has unexpected format.
signal challenges_received(
	data: GxGamesGetChallengesData,
	ok: bool, 
	error_codes: Array
)

## This signal is emitted after getting the profile info from the backend.
## It is invoked after calling the function [method GxGames.profile_get_info].
## Connect this signal to a method to handle the received data.
## [br]
## Arguments:
## [br]
## ● [code]data[/code] - profile data.
## [br]
## ● [code]ok[/code] - a flag which indicates whether the request was successful or not.
## [br]
## ● [code]error_codes[/code] - an array of error codes extracted from the response. It is also possible that the request was not successful and the error codes array is empty. It may happen if the format of the error response for some reason has unexpected format.
signal profile_info_received(
	data: GxGamesPlayerData,
	ok: bool, 
	error_codes: Array
)

var _window: JavaScriptObject

var _utils: GxUrlUtils
var _payment_trigger: GxGamesPaymentTrigger
var _payment_checker: GxGamesFullVersionChecker
var _cloud_saves: CloudSaves
var _score_submitter: GxGamesSubmitScore
var _user_scores_getter: GxGamesGetScores
var _global_scores_getter: GxGamesGetScores
var _challenges_getter: GxGamesGetChallenges
var _profile_info_getter: GxGamesGetPlayerInfo

func _ready() -> void:
	if !OS.has_feature('web'):
		return
	
	_window = JavaScriptBridge.get_interface("window")
	
	if !_window:
		print('Object "window" is not defined.')
		return
	
	_utils = GxUrlUtils.new(_window)
	
	_payment_trigger = GxGamesPaymentTrigger.new(_window)
	_payment_trigger.payment_completed.connect(func(id: String): payment_completed.emit(id))
	
	_payment_checker = GxGamesFullVersionChecker.new(_window, _utils)
	_payment_checker.payment_status_received.connect(
		func(
			is_full_version_purchased: bool,
			ok: bool, 
			error_codes: Array
		): payment_status_received.emit(is_full_version_purchased, ok, error_codes))
	
	_cloud_saves = CloudSaves.new(_window, _utils)

	_score_submitter = GxGamesSubmitScore.new(_window, _utils)
	_score_submitter.submit_score_completed.connect(
		func(
			data: GxGamesSubmitScoreData,
			ok: bool, 
			error_codes: Array
		): submit_score_completed.emit(data, ok, error_codes)
	)
	
	_global_scores_getter = GxGamesGetScores.new(_window, _utils, "scores")
	_global_scores_getter.scores_received.connect(
		func(
			data: GxGamesGetScoresData,
			ok: bool,
			error_codes: Array
		): global_scores_received.emit(data, ok, error_codes)
	)
	
	_user_scores_getter = GxGamesGetScores.new(_window, _utils, "user-scores")
	_user_scores_getter.scores_received.connect(
		func(
			data: GxGamesGetScoresData,
			ok: bool,
			error_codes: Array
		): user_scores_received.emit(data, ok, error_codes)
	)
	
	_challenges_getter = GxGamesGetChallenges.new(_window, _utils)
	_challenges_getter.challenges_received.connect(
		func(
			data: GxGamesGetChallengesData,
			ok: bool, 
			error_codes: Array
		): challenges_received.emit(data, ok, error_codes)
	)
	
	_profile_info_getter = GxGamesGetPlayerInfo.new(_window, _utils)
	_profile_info_getter.profile_info_received.connect(
		func(
			data: GxGamesPlayerData,
			ok: bool, 
			error_codes: Array
		): profile_info_received.emit(data, ok, error_codes)
	)

## Start the payment flow prompting the user to make a payment and making the
## necessary interactions with the server. Once the payment flow is finished,
## [signal GxGames.payment_completed] signal will be emitted. The signal is emitted whenever
## the payment is completed/failed or interrupted.
## [br]
## Arguments:
## [br]
## ● [code]id[/code] - the hashed ID of the item to purchase.
func trigger_payment(id: String) -> void:
	if _payment_trigger:
		_payment_trigger.trigger_payment(id)


## Start receiving the payment status for the game. This function is used to
## check whether the user has purchased the full version of the game. The
## function makes an HTTP request to get this data from the backend. Once the
## data is received, [signal GxGames.payment_status_received] signal will be
## invoked.
func get_full_version_payment_status() -> void:
	if _payment_checker:
		_payment_checker.get_full_version_payment_status()


## When your game is played on GX.Games, some extra parameters are passed into
## the URL of the game so they can be retrieved in-game. This function will
## return the value of the parameter specified in the argument as a string.
## [br]
## For example, if the game is open in a browser window and its address is
## [code]localhost:8000/?game=1234&track=7890[/code], the following function: 
## [codeblock]
## get_query_param('track')
## [/codeblock]
## will return [code]7890[/code].
## [br]
## Arguments:
## [br]
## ● [code]param[/code] - the name of the query parameter.
func get_query_param(param: String) -> String:
	return _utils.get_query_param(param) if _utils else ""

## Generates a path to the folder for the save files in a GX.Games-compatible
## format. The files which are located in this folder are managed by the cloud
## saves system. The function returns the folder in the following format:
## [code]/userfs/<gameId>/[/code].  "userfs" is the name of the root folder
## which is used by Godot. "gameId" is the ID of the game on GX.Games.
## [br]
## If the folder does not exist, the function creates it.
## [br]
## The function runs only on WebGL. If the platform is different, the function
## returns an empty string.
## [br]
## The game ID is extracted from the query parameter [code]game[/code] of the
## page URL where the game is running. If the page's URL does not contain this
## parameter, the function returns an empty string.
func generate_data_path() -> String:
	return _cloud_saves.generate_data_path() if _cloud_saves else ""

## This function is used to submit a new score to the currently active
## challenge, for the user that is currently logged in. You specify the score
## value to submit to the challenge. When the request is completed,
## [signal GxGames.submit_score_completed] signal will be invoked.
## [br]
## Arguments:
## [br]
## ● [code]score[/code] - the score submitted for the challenge.
## [br]
## ● [code]challengeId[/code] - The challenge ID to use (if not specified, defaults to the
## currently active challenge).
func challenge_submit_score(
	score: int,
	challengeId: String = ""
) -> void:
	if _score_submitter:
		_score_submitter.challenge_submit_score(score, challengeId)

## This function is used to retrieve all the scores for the currently active
## challenge. Signing into GX.Games is not required for this function to work.
## When the request is completed, [signal GxGames.global_scores_received]
## signal will be invoked.
## [br]
## Arguments: 
## [br]
## ● [code]page[/code] - The page number to return.
## [br]
## ● [code]pageSize[/code] - The maximum number of items to return.
## [br]
## ● [code]challengeId[/code] - The challenge ID to use (if not specified, defaults to the currently active challenge).
## [br]
## ● [code]trackId[/code] - The track ID to use (if not specified, defaults to the currently active track).
func challenge_get_global_scores(
	page: int = 0,
	pageSize: int = 25,
	challengeId: String = "",
	trackId: String = "",
) -> void:
	if _global_scores_getter:
		_global_scores_getter.get_scores(page, pageSize, challengeId, trackId)

## This function is used to retrieve the current user's submitted scores for the
## currently active challenge. Signing into GX.Games is required for this
## function to work. When the request is completed,
## [signal GxGames.user_scores_received] signal will be invoked.
## [br]
## Arguments: 
## [br]
## ● [code]page[/code] - The page number to return.
## [br]
## ● [code]pageSize[/code] - The maximum number of items to return.
## [br]
## ● [code]challengeId[/code] - The challenge ID to use (if not specified,
## defaults to the currently active challenge).
## [br]
## ● [code]trackId[/code] - The track ID to use (if not specified, defaults to
## the currently active track).
func challenge_get_user_scores(
	page: int = 0,
	pageSize: int = 25,
	challengeId: String = "",
	trackId: String = "",
) -> void:
	if _user_scores_getter:
		_user_scores_getter.get_scores(page, pageSize, challengeId, trackId)

## This function is used to retrieve all the challenges that have been created
## for the game on the currently active track (or the one specified in options).
## When the request is completed, [signal GxGames.challenges_received] signal
## will be invoked.
## [br]
## Arguments:
## [br]
## * [code]page[/code] - The page number to return.
## [br]
## * [code]pageSize[/code] - The maximum number of items to return.
## [br]
## * [code]trackId[/code] - The track ID to use (if not specified, defaults to
## the currently active track).
func get_challenges(
	page: int = 0,
	pageSize: int = 25,
	trackId: String = "",
) -> void:
	if _challenges_getter:
		_challenges_getter.get_challenges(page, pageSize, trackId)

## This function is used to retrieve information about the current user's
## profile. The function makes an HTTP request to get this data from the
## backend. Once the data is received, [signal GxGames.profile_info_received]
## signal will be invoked.
func profile_get_info() -> void:
	if _profile_info_getter:
		_profile_info_getter.get_profile_info()
