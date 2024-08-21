extends Control

@onready var score_input = $ScoreInput
@onready var challengeId_input = $challengeID
@onready var page_input = $page
@onready var pageSize_input = $pageSize
@onready var trackId_input = $trackId

func _ready():
	print('Current challenge ID: ' + GxGames.get_query_param('challenge'))
	
	# Subscribe events
	GxGames.submit_score_completed.connect(on_submit_score_completed)
	GxGames.global_scores_received.connect(on_global_scores_received)
	GxGames.user_scores_received.connect(on_user_scores_received)
	GxGames.challenges_received.connect(on_challenges_received)
	GxGames.profile_info_received.connect(on_profile_info_received)

func _on_button_button_up():
	GxGames.challenge_submit_score(int(score_input.text), _get_challenge_id())

func on_submit_score_completed(
	data: GxGamesSubmitScoreData,
	ok: bool, 
	error_codes: Array # of String
) -> void:
	print("Score submitted. OK: " + str(ok) + "; error_codes: " + str(error_codes))
	
	if data:
		print("Is new best score: " + str(data.newBestScore))

func _on_get_global_scores_button_up():
	GxGames.challenge_get_global_scores(
		_get_page(), 
		_get_page_size(), 
		_get_challenge_id(), 
		_get_track_id()
	)

func _on_get_user_scores_button_up():
	GxGames.challenge_get_user_scores(
		_get_page(), 
		_get_page_size(), 
		_get_challenge_id(), 
		_get_track_id()
	)

func on_global_scores_received(
	data: GxGamesGetScoresData,
	ok: bool, 
	error_codes: Array # of String
) -> void:
	_on_scores_received("global", data, ok, error_codes)

func on_user_scores_received(
	data: GxGamesGetScoresData,
	ok: bool, 
	error_codes: Array # of String
) -> void:
	_on_scores_received("user", data, ok, error_codes)

func _on_scores_received(
	endpoint_ending: String,
	data: GxGamesGetScoresData,
	ok: bool, 
	error_codes: Array # of String
) -> void:
	print(endpoint_ending + " score received. OK: " + str(ok) + "; error_codes: " + str(error_codes))
	
	if data:
		_print_scores_list(data)

func _on_get_challenges_button_up():
	GxGames.get_challenges(
		_get_page(), 
		_get_page_size(), 
		_get_track_id()
	)

func on_challenges_received(
	data: GxGamesGetChallengesData,
	ok: bool, 
	error_codes: Array
) -> void:
	print("Challenges received. OK: " + str(ok) + "; error_codes: " + str(error_codes))
	
	if data:
		print("Received " + str(data.challenges.size()) + " challenges.")
		
		for challenge in data.challenges:
			_print_challenge_details(challenge)
		
		_print_pagination_details(data.pagination)

func _on_get_profile_button_up():
	GxGames.profile_get_info()

func on_profile_info_received(
	data: GxGamesPlayerData,
	ok: bool, 
	error_codes: Array
):
	print("Profile info received: OK: " + str(ok) + "; error_codes: " + str(error_codes))
	print("profile: \n" + \
		' data.avatarUrl: ' + data.avatarUrl + '\n' + \
		' data.userId: ' + data.userId + '\n' + \
		' data.username: ' + data.username
	)

func _print_scores_list(scores: GxGamesGetScoresData) -> void:
	print("Scores received: " + str(scores))
	
	_print_challenge_details(scores.challenge)
	_print_scores_details(scores.scores)
	_print_pagination_details(scores.pagination)

func _print_challenge_details(challenge: GxGamesChallengeData) -> void:
	print("data.challenge: \n" + \
		' challenge.challengeId: ' + challenge.challengeId + '\n' + \
		' challenge.coverArt: ' + challenge.coverArt + '\n' + \
		' challenge.creationDate: ' + challenge.creationDate + '\n' + \
		' challenge.type: ' + challenge.type + '\n' + \
		' challenge.criteria: ' + challenge.criteria + '\n' + \
		' challenge.startsAt: ' + challenge.startsAt + '\n' + \
		' challenge.endsAt: ' + challenge.endsAt + '\n' + \
		' challenge.hasEnded: ' + str(challenge.hasEnded) + '\n' + \
		' challenge.hasStarted: ' + str(challenge.hasStarted) + '\n' + \
		' challenge.isPublished: ' + str(challenge.isPublished) + '\n' + \
		' challenge.isTimedChallenge: ' + str(challenge.isTimedChallenge) + '\n' + \
		' challenge.shortDescription: ' + challenge.shortDescription + '\n' + \
		' challenge.longDescription: ' + challenge.longDescription + '\n' + \
		' challenge.name: ' + challenge.name + '\n' + \
		' challenge.players: ' + str(challenge.players)
	)

func _print_scores_details(scores: Array) -> void:
	print("Received " + str(scores.size()) + " scores.")
	
	for score_untyped in scores:
		var score = score_untyped as GxGamesChallengeScoreData
		print("data.score: \n" + \
			' score.achievementDate: ' + score.achievementDate + '\n' + \
			' score.countryCode: ' + score.countryCode + '\n' + \
			'  score.player.avatarUrl: ' + score.player.avatarUrl + '\n' + \
			'  score.player.userId: ' + score.player.userId + '\n' + \
			'  score.player.username: ' + score.player.username + '\n' + \
			' score.score: ' + str(score.score) + '\n' + \
			' score.scoreId: ' + score.scoreId
		)

func _print_pagination_details(pagination: GxGamesPaginationData) -> void:
	print("data.pagination: \n" + \
		' pagination.currPage: ' + str(pagination.currPage) + '\n' + \
		' pagination.numPerPage: ' + str(pagination.numPerPage) + '\n' + \
		' pagination.totalItems: ' + str(pagination.totalItems) + '\n' + \
		' pagination.totalPages: ' + str(pagination.totalPages)
	)

func _get_challenge_id() -> String:
	return challengeId_input.text

func _get_track_id() -> String:
	return trackId_input.text

func _get_page() -> int:
	if page_input.text == "":
		return 0
	else:
		return int(page_input.text)

func _get_page_size() -> int:
	if pageSize_input.text == "":
		return 25
	else:
		return int(pageSize_input.text)
