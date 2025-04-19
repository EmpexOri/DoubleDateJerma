extends Node

var top_scores_player_1 = []
var top_scores_player_2 = []

const MAX_SCORES = 10
const SCORE_FILE = "user://scores.dat"

func _ready():
	# Load the scores from the file when the game starts
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
		top_scores_player_1.reverse()  # Highest score first
		top_scores_player_1 = top_scores_player_1.slice(0, MAX_SCORES)  # Keep only the top 10
	elif player == 2:
		top_scores_player_2.append(score)
		top_scores_player_2.sort()
		top_scores_player_2.reverse()  # Highest score first
		top_scores_player_2 = top_scores_player_2.slice(0, MAX_SCORES)  # Keep only the top 10

	save_scores()
