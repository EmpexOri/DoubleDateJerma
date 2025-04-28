extends Node

var top_scores_player_1 = []
var top_scores_player_2 = []

var current_score_player_1 = 0
var current_score_player_2 = 0

const MAX_SCORES = 10
const SCORE_FILE = "user://scores.dat"

func _ready():
	load_scores()

func save_scores():
	var save_data = {
		"player_1_scores": top_scores_player_1,
		"player_2_scores": top_scores_player_2
	}
	var file = FileAccess.open(SCORE_FILE, FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()

func load_scores():
	var file = FileAccess.open(SCORE_FILE, FileAccess.READ)
	if file:
		var data = file.get_var()
		top_scores_player_1 = data.get("player_1_scores", [])
		top_scores_player_2 = data.get("player_2_scores", [])
		file.close()

func add_score(player: int, score: int):
	if player == 1:
		top_scores_player_1.append(score)
		top_scores_player_1.sort()
		top_scores_player_1.reverse()
		top_scores_player_1 = top_scores_player_1.slice(0, MAX_SCORES)
	elif player == 2:
		top_scores_player_2.append(score)
		top_scores_player_2.sort()
		top_scores_player_2.reverse()
		top_scores_player_2 = top_scores_player_2.slice(0, MAX_SCORES)

	save_scores()

func reset_current_scores():
	current_score_player_1 = 0
	current_score_player_2 = 0
